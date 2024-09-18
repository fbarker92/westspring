# Functions
function Install-RequiredModules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Modules
    )

    foreach ($module in $Modules) {
        $modulePresent = Get-Module -Name $module -ListAvailable
        If (!($modulePresent)) {
            Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber -Verbose
            Write-LogMessage -Message "Installing $module" -Level Info
            If (!(Get-Module -Name $module -ListAvailable)) {
                Write-LogMessage -Message "Install Failed for $module - $errormessage" -Level Error
                return $false
            }
        }
        Else {
            Write-LogMessage -Message "$module present" -Level Info
        }
    }
}
function Write-LogMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    # Write to console with color-coding
    switch ($Level) {
        "Success" { Write-Host $logEntry -ForegroundColor Cyan; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$level] $Message" }
        "Info" { Write-Host $logEntry -ForegroundColor Green; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message" }
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message" }
        "Error" { Write-Host $logEntry -ForegroundColor Red; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message" }
    }
    # Append to log file
    #$logFilePath = "$($PSScriptRoot)\$($timestamp.ToString().Split(" ")[0])-Report-TeamsChatInfo.log"
    $logFilePath = "./$($timestamp.ToString().Split(" ")[0])-Report-TeamsChatInfo.log"
    Add-Content -Path $logFilePath -Value $logEntry
}
<# # Check Enterprise App Permission
function Check-ApplicationPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$TenantId,
        [Parameter(Mandatory = $true)]
        [string[]]$ApplicationClientId
    )
    Import-Module Microsoft.Graph.Applications
    $connectionScopes = @('Microsoft.Graph.Applications')
    $requiredPermissions = @('')
    Connect-Graph -TenantId $TenantId -NoWelcome -ErrorAction Stop -Verbose
    $client = Get-MgServicePrincipal -ServicePrincipalId $ApplicationClientId
} #>
function Test-PWSHVersion {
    If ($PSVersionTable.PSVersion -lt "7.1") {
        Write-LogMessage -Message "This script requires PowerShell 7.1 or higher. Please update your PowerShell version and re-run the script." -Level Error
        Exit 0
    }
    else {
        Write-LogMessage -Message "PowerShell Version: $($PSVersionTable.PSVersion)" -Level Info
    }
}
# Check PowserShell Version
Check-PWSHVersion
# Check if required module is installed, install if not
$requiredModules = @("Microsoft.Graph", "Microsoft.Graph.Applications", "Microsoft.Graph.Teams", "Microsoft.Graph.Beta")
Install-RequiredModules -Modules $requiredModules
## Initialise Vars
# Read .env file
$envContent = Get-Content "$PSScriptRoot\.env" -ErrorAction Stop
$envContent | ForEach-Object {
    if ($_ -match '^(.+)=(.+)$') {
        Set-Item -Path "env:$($Matches[1])" -Value $Matches[2]
    }
}
# Set variables from .env file
$ApplicationClientId = $env:APPLICATION_CLIENT_ID # Application (Client) ID
$ApplicationClientSecret = $env:APPLICATION_CLIENT_SECRET # Application Secret Value
$SecureClientSecret = ConvertTo-SecureString -String $ApplicationClientSecret -AsPlainText -Force # Generate secure string for client secret
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationClientId, $SecureClientSecret # Create credential object for client secret
$TenantId = $env:TENANT_ID # Tenant ID

# Import the excluded participants from a CSV file
[array]$teacherUsers = @() #mport-Csv -Path "C:\Users\fergusbarker\Downloads\int_exportUsers_2024-9-12.csv"
If ($teacherUsers.Count -eq 0) {
    Write-LogMessage -Message "Teacher users failed to import, Please check the csv file or filepath" -Level Error
    $isProceed = Read-Host -Prompt "Do you want to continue? (y/N)"
    if ($isProceed -ne "Y" -or $isProceed -ne "y") {
        Write-LogMessage -Message "User exited script at: Teacher User Import" -Level Error
        Exit 0
    } elseif ($isProceed -eq "Y" -or $isProceed -eq "y") {
        Write-LogMessage -Message "User overrided teacher user import... continuing" -Level info
    }
}
else {
    Write-LogMessage -Message "Teacher users imported: $($teacherUsers.Count)" -Level Success
}
[array]$studentUsers = @{userPrincipalName = 'fergusbarker@springwest-it.co.uk'}#Import-Csv -Path "C:\Users\fergusbarker\Downloads\ext_exportUsers_2024-9-12.csv"
If ($studentUsers.Count -eq 0) {
    Write-LogMessage -Message "Student users failed to import, Please check the csv file or filepath" -Level Error
    $isProceed = Read-Host -Prompt "Do you want to continue? (y/N)"
    if ($isProceed -ne "Y" -or $isProceed -ne "y") {
        Write-LogMessage -Message "User exited script at: Student User Import" -Level Error
        Exit 0
    } elseif ($isProceed -eq "Y" -or $isProceed -eq "y") {
        Write-LogMessage -Message "User overrided student user import... continuing" -Level info
    }
} 
else {
    Write-LogMessage -Message "Student users imported: $($studentUsers.Count)" -Level Success
}
## Connect to MsGraph
try {
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome -ErrorAction Stop -Verbose
    Write-LogMessage -Message "Connected to Microsoft Graph. TenantID: $($TenantId)" -Level Success
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
    Write-Progress -Activity "Processing $($studentUser.userPrincipalName)" -Status "$($i+1) of $totalStudents" -PercentComplete (($i + 1) / $totalStudents * 100)
    $processingResult = Measure-Command {
        try {
            # Existing code for processing student
            Write-LogMessage -Message "Starting processing for $($studentUser.userPrincipalName)" -Level Info
            # Get UserId for the user
            try {
                $UserId = (Get-MgUser -UserId $studentUser.userPrincipalName).Id
                Write-LogMessage -Message "[Success] User ID: $UserId" -Level Info
            }
            catch {
                Write-Host "Error getting user ID: $_" -ForegroundColor Red
                Write-LogMessage -Message "Failed to get user ID: $($_.Exception.Message)" -Level Error
                continue
            }
            # Get chats for the user
            try {
                [array]$Chats = Get-MgUserChat -Userid $UserId -All -Filter "chattype eq 'group' or chattype eq 'oneonone' or chattype eq 'Meeting'" | Sort-Object LastUpdatedDateTime -Descending
                Write-LogMessage -Message "Retrieved $($Chats.Count) chats for user $($studentUser.userPrincipalName)" -Level Success
            }
            catch {
                Write-LogMessage -Message "Failed to retrieve chats for user $($studentUser.userPrincipalName): $($_.ErrorDetails.Message)" -Level Error
                Continue
            }
            # Initialise output report
            $Report = [System.Collections.Generic.List[Object]]::new()
            # Extract information for each chat thread and write it out to the report file
            $chatCounter = 0
            ForEach ($Chat in $Chats) {
                $chatCounter++
                Write-Progress -Id 1 -ParentId 0 -Activity "Processing Chats" -Status "$chatCounter of $($Chats.Count)" -PercentComplete (($chatCounter / $Chats.Count) * 100)
                # Get members of the chat thread
                try {
                    [array]$Members = Get-MgUserChatMember -UserId $UserId -ChatId $Chat.Id -All
                    Write-LogMessage -Message "Retrieved $($Members.Count) members for chat $($Chat.Id)" -Level Info
                }
                catch {
                    Write-LogMessage -Message "Failed to retrieve members for chat $($Chat.Id): $_" -Level Error
                    Continue
                }
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
                    Id                   = $Chat.Id
                    WebUrl               = $Chat.WebUrl 
                }     
                $Report.Add($ReportLine) 
            }
            # Check if the chat participants are in the excluded list
            $ChatIdsToDelete = @()
            foreach ($Item in $Report) {
                $chatParticipants = $Item.Participants.Split(",").Trim()
                $shouldDelete = $true
                foreach ($participant in $chatParticipants) {
                    if ($teacherUsers.displayName -contains $participant) {
                        Write-LogMessage -Message "ChatID: $($Item.Id) will not deleted because $participant is a teacher" -Level Info
                        $shouldDelete = $false
                        break
                    }
                }
                if ($shouldDelete) {
                    Write-LogMessage -Message "ChatID: $($Item.Id) is to be deleted because $($Item.Participants) are not teachers" -Level Info
                    $ChatIdsToDelete += $Item
                }
            }
            # Soft delete the chats
            $totalChatsToDelete = $ChatIdsToDelete.Count
            $successfullyDeletedChats = 0
            ForEach ($Item in $ChatIdsToDelete) {
                $currentChatIndex = $successfullyDeletedChats + 1
                Write-Progress -Id 2 -ParentId 1 -Activity "Deleting Chats" -Status "Processing $currentChatIndex of $totalChatsToDelete" -PercentComplete (($currentChatIndex / $totalChatsToDelete) * 100)
                
                Write-LogMessage -Message "Processing ChatIDs for $($studentUser.userPrincipalName)" -Level Info
                
                $softDeleteSuccess = $false
                try {
                    Remove-MgChat -ChatId $Item.Id
                    Write-LogMessage -Message "Soft Deleted ChatID: $($Item.Id). Participants: $($Item.Participants)" -Level Success
                    $softDeleteSuccess = $true
                }
                catch {
                    Write-LogMessage -Message "Error soft deleting chat $($Item.Id): $($_.ErrorDetails)" -Level Error
                }
            
                if ($softDeleteSuccess) {
                    try {
                        $deltedChatId = Get-MgTeamworkDeletedChat -DeletedChatId $Item.Id | Select-Object -ExpandProperty Id
                        Remove-MgBetaTeamworkDeletedChat -DeletedChatId $deltedChatId
                        $successfullyDeletedChats++
                        Write-LogMessage -Message "Hard Deleted Chat: $deltedChatId" -Level Success
                    }
                    catch {
                        Write-LogMessage -Message "Error hard deleting chat $($deltedChatId): $($_.Exception.Message)" -Level Error
                    }
                }
            }
            
            Write-LogMessage -Message "Deleted $successfullyDeletedChats out of $totalChatsToDelete chats for $($studentUser.userPrincipalName)" -Level Info
        }
        catch {
            Write-LogMessage -Message "processing $($studentUser.userPrincipalName): $($_.Exception.Message)" -Level Error
        }
    }
    Write-LogMessage -Message "Completed processing $($studentUser.userPrincipalName) in $($processingResult.TotalSeconds) seconds" -Level Success
    Write-LogMessage -Message "Finished script: $(get-date -format "yyyy-MM-dd HH:mm:ss")" -Level Info
}

