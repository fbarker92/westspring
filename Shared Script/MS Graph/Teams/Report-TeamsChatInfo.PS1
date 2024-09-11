# Check PowserShell Version
If ($PSVersionTable.PSVersion -lt "7.1") {
    Write-Host "This script requires PowerShell 7.1 or higher. Please update your PowerShell version and re-run the script." -BackgroundColor Red -ForegroundColor White
    Write-LogMessage -Message "This script requires PowerShell 7.1 or higher. Please update your PowerShell version and re-run the script." -Level Error
    Exit 0
}
# Functions
function Install-RequiredModules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Modules
    )

    foreach ($module in $Modules) {
        $modulePresent = Get-Module -Name $module -ListAvailable
        If (!($modulePresent)) {
            Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
            Write-LogMessage -Message "[Installing] $module" -Level Info
            If (!(Get-Module -Name $module -ListAvailable)) {
                Write-LogMessage -Message "[Install Failed}] $module" -Level Error
                return $false
            }
        }
        Else {
            Write-LogMessage -Message "[Module Present] $module" -Level Info
        }
    }
    return $true
}
function Write-LogMessage {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    # Write to console with color-coding
    switch ($Level) {
        "Info"    { Write-Host $logEntry -ForegroundColor Green; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message"}
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message"}
        "Error"   { Write-Host $logEntry -ForegroundColor Red; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message"}
    }
    
    # Append to log file
    $logFilePath = "$($env:USERPROFILE)\Report-TeamsChatInfo.log"
    Add-Content -Path $logFilePath -Value $logEntry
}

# Check if required module is installed, install if not
$requiredModules = @("Microsoft.Graph.Teams", "Microsoft.Graph.Beta")
Install-RequiredModules -Modules $requiredModules

# Initialise Vars
$ApplicationClientId = '<Enterprise App Client ID>' # Application (Client) ID
$ApplicationClientSecret = '<Enterprise App Client Secret>' # Application Secret Value
$SecureClientSecret = ConvertTo-SecureString -String $ApplicationClientSecret -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationClientId, $SecureClientSecret
$TenantId = '<Tenant ID>' # Tenant ID
# Import the excluded participants from a CSV file

[array]$teacherUsers = Import-Csv -Path "C:\path\to\file.csv"
[array]$studentUsers = Import-Csv -Path "C:\Path\to\file.csv"


try {
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome -ErrorAction Stop -Verbose
    Write-LogMessage -Message "Connected to Microsoft Graph. TenantID: $($TenantId)" -Level Info
}
catch {
    $errorMessage = "There was an error connecting to MsGraph: $($Error[0]). Please check the application connection parameters and try again."
    Write-LogMessage -Message $errorMessage -Level Error
    Write-Error $errorMessage
    #throw $errorMessage
    Exit 0
}


$totalStudents = $studentUsers.Count
for ($i = 0; $i -lt $totalStudents; $i++) {
    $studentUser = $studentUsers[$i]
    Write-Progress -Activity "Processing $($studentUser)" -Status "$($i+1) of $totalStudents" -PercentComplete (($i+1) / $totalStudents * 100)

    # Get UserId for the user
    try {
        $UserId = (Get-MgUser -UserId $studentUser.PrimarySmtpAddress).Id
    } catch {
        Write-Host "Error getting user ID: $_" -ForegroundColor Red
        Write-LogMessage -Message $errorMessage -Level Error
        continue
    }
    # Get chats for the user
    [array]$Chats = Get-MgUserChat -Userid $UserId -All -Filter "chattype eq 'group' or chattype eq 'oneonone' or chattype eq 'Meeting'" | Sort-Object LastUpdatedDateTime -Descending

    # Extract the identifiers for the tenants that chat threads belong to so that we can resolve them to a tenant name
    $TenantList = [System.Collections.Generic.List[Object]]::new()
    ForEach ($Chat in $Chats) {
        $TenantList.Add($Chat.TenantId)
    }

    # Initialise output report
    $Report = [System.Collections.Generic.List[Object]]::new()

    # Extract information for each chat thread and write it out to the report file
    ForEach ($Chat in $Chats) {
        # Get members of the chat thread
        [array]$Members = Get-MgUserChatMember -UserId $UserId -ChatId $Chat.Id -All

        # Extract the member display names and remove any blanks (accounts that no longer exist)
        [array]$MemberNames = $Members.displayName | Sort-Object -Unique
        $NumberOfParticipants = $MemberNames.Count
        If ($MemberNames.Count -gt 0) {
            $MemberNamesOutput = $MemberNames -Join ", "
        }

        $ReportLine = [PSCustomObject][Ordered]@{
            ChatType             = $Chat.ChatType
            Topic                = $Chat.Topic
            Created              = $Chat.CreatedDateTime
            LastUpdated          = $Chat.LastUpdatedDateTime
            NumberOfParticipants = $NumberOfParticipants
            Participants         = $MemberNamesOutput
            TenantId             = $Chat.TenantId
            Tenant               = $TenantDisplayName
            Id                   = $Chat.Id
            WebUrl               = $Chat.WebUrl 
        }     
        $Report.Add($ReportLine) 
    } # End ForEach chats

    #$Report | Select-Object ChatType, Topic, Created, LastUpdated, NumberOfParticipants, Participants, Tenant, Id | Sort-Object LastUpdated -Descending | Out-GridView -passThru

    # Check if the chat participants are in the excluded list
    $ChatIdsToDelete = @()
    foreach ($Item in $Report) {
        $chatParticipants = $Item.Participants.Split(",").Trim()
        $shouldDelete = $true
        foreach ($participant in $chatParticipants) {
            if ($teacherUsers.displayName -contains $participant) {
                $shouldDelete = $false
                break
            }
        }
        if ($shouldDelete) {
            Write-Host "Chat Id: $($Item.Id)"
            Write-Host "Chat Participants: $($Item.Participants)"
            $ChatIdsToDelete += $Item
        }
    }
    # Soft delete the chats
    ForEach ($Item in $ChatIdsToDelete) {
        try {
            Remove-MgChat -ChatId $Item.Id
            Write-LogMessage -Message "[$($studentUser.PrimarySmtpAddress)], Chat: $($Item.Id) soft deleted" -Level Info 
            Write-LogMessage -Message "[Participants] $($Item.Participants)" -Level Info 
            $deltedChatId = Get-MgTeamworkDeletedChat -DeletedChatId $($Item.Id) | Select-Object -ExpandProperty Id
            Remove-MgBetaTeamworkDeletedChat -DeletedChatId $deltedChatId
            Write-LogMessage -Message "[Deleted] Chat $deltedChatId" -Level Info
        }
        catch {
            Write-LogMessage -Message "Error deleting chat $($Item.Id): $($_.Exception.Message)" -Level Error
        }
    } 
}
