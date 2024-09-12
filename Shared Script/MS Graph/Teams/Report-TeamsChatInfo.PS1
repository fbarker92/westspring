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
            Write-LogMessage -Message "[Installing] $module" -Level Info
            If (!(Get-Module -Name $module -ListAvailable)) {
                Write-LogMessage -Message "[Install Failed] $module - $errormessage" -Level Error
                return $false
            }
        }
        Else {
            Write-LogMessage -Message "[Success] $module present" -Level Info
        }
    }
}
function Write-LogMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    # Write to console with color-coding
    switch ($Level) {
        "Info" { Write-Host $logEntry -ForegroundColor Green; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message" }
        "Warning" { Write-Host $logEntry -ForegroundColor Yellow; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message" }
        "Error" { Write-Host $logEntry -ForegroundColor Red; $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; $logEntry = "$timestamp [$Level] $Message" }
    }
    
    # Append to log file
    $PSScriptRoot
    $logFilePath = "$($PSScriptRoot)\$($timestamp.ToString().Split(" ")[0])-Report-TeamsChatInfo.log"
    Add-Content -Path $logFilePath -Value $logEntry
}
# Check PowserShell Version
If ($PSVersionTable.PSVersion -lt "7.1") {
    Write-LogMessage -Message "[Error] This script requires PowerShell 7.1 or higher. Please update your PowerShell version and re-run the script." -Level Error
    Exit 0
}
else {
    Write-LogMessage -Message "[Success] PowerShell Version: $($PSVersionTable.PSVersion)" -Level Info
}
# Check if required module is installed, install if not
$requiredModules = @("Microsoft.Graph.Teams", "Microsoft.Graph.Beta")
Install-RequiredModules -Modules $requiredModules
# Initialise Vars
$ApplicationClientId = '' # Application (Client) ID
$ApplicationClientSecret = '' # Application Secret Value
$SecureClientSecret = ConvertTo-SecureString -String $ApplicationClientSecret -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationClientId, $SecureClientSecret
$TenantId = '' # Tenant ID
# Import the excluded participants from a CSV file
[array]$teacherUsers = Import-Csv -Path "C:\Users\fergusbarker\Downloads\int_exportUsers_2024-9-12.csv"
If ($teacherUsers.Count -eq 0) {
    Write-LogMessage -Message "[Error] Teacher users failed to import, Please check the csv file or filepath" -Level Error
}
else {
    Write-LogMessage -Message "[Success] Teacher users imported: $($teacherUsers.Count)" -Level Info
}
[array]$studentUsers = Import-Csv -Path "C:\Users\fergusbarker\Downloads\ext_exportUsers_2024-9-12.csv"
If ($studentUsers.Count -eq 0) {
    Write-LogMessage -Message "[Error] Studen users failed to import, Please check the csv file or filepath" -Level Error
}
else {
    Write-LogMessage -Message "[Success] Student users imported: $($studentUsers.Count)" -Level Info
}
# Connect to MsGraph
try {
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome -ErrorAction Stop -Verbose 4>&1
    Write-LogMessage -Message "[Success] Connected to Microsoft Graph. TenantID: $($TenantId)" -Level Info
}
catch {
    $errorMessage = "There was an error connecting to MsGraph: $($Error[0]). Please check the application connection parameters and try again."
    Write-LogMessage -Message $errorMessage -Level Error
    Write-Error $errorMessage
    #throw $errorMessage
    Exit 0
}
# Check Enterprise App Permission
#TODO Add code to check and validate that the Enterprise App has the required permissions
$totalStudents = $studentUsers.Count
for ($i = 0; $i -lt $totalStudents; $i++) {
    $studentUser = $studentUsers[$i]
    Write-Progress -Activity "Processing $($studentUser.userPrincipalName)" -Status "$($i+1) of $totalStudents" -PercentComplete (($i + 1) / $totalStudents * 100)
    $processingResult = Measure-Command {
        try {
            # Existing code for processing student
            Write-LogMessage -Message "[Success] Starting processing for $($studentUser.userPrincipalName)" -Level Info
            # Get UserId for the user
            try {
                $UserId = (Get-MgUser -UserId $studentUser.userPrincipalName).Id
                Write-LogMessage -Message "[Success] User ID: $UserId" -Level Info
            }
            catch {
                Write-Host "Error getting user ID: $_" -ForegroundColor Red
                Write-LogMessage -Message "[Error] Failed to get user ID: $($_.Exception.Message)" -Level Error
                continue
            }
            # Get chats for the user
            try {
                [array]$Chats = Get-MgUserChat -Userid $UserId -All -Filter "chattype eq 'group' or chattype eq 'oneonone' or chattype eq 'Meeting'" | Sort-Object LastUpdatedDateTime -Descending
                Write-LogMessage -Message "[Success] Retrieved $($Chats.Count) chats for user $($studentUser.userPrincipalName)" -Level Info
            }
            catch {
                Write-LogMessage -Message "[Error] Failed to retrieve chats for user $($studentUser.userPrincipalName): $_" -Level Error
                Continue
            }
            # Extract the identifiers for the tenants that chat threads belong to so that we can resolve them to a tenant name
            $TenantList = [System.Collections.Generic.List[Object]]::new()
            ForEach ($Chat in $Chats) {
                $TenantList.Add($Chat.TenantId)
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
                    Write-LogMessage -Message "[Success] Retrieved $($Members.Count) members for chat $($Chat.Id)" -Level Info
                }
                catch {
                    Write-LogMessage -Message "[Error] Failed to retrieve members for chat $($Chat.Id): $_" -Level Error
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
                    TenantId             = $Chat.TenantId
                    Tenant               = $TenantDisplayName
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
                        Write-LogMessage -Message "[Success] ChatID: $($Item.Id) will not deleted because $participant is a teacher" -Level Info
                        $shouldDelete = $false
                        break
                    }
                }
                if ($shouldDelete) {
                    Write-LogMessage -Message "[Success] ChatID: $($Item.Id) is to be deleted because $($Item.Participants) are not teachers" -Level Info
                    $ChatIdsToDelete += $Item
                }
            }
            # Soft delete the chats
            $totalChatsToDelete = $ChatIdsToDelete.Count
            $successfullyDeletedChats = 0
            ForEach ($Item in $ChatIdsToDelete) {
                Write-LogMessage -Message "[Success] Processing ChatIDs for $($studentUser.userPrincipalName)" -Level Info
                try {
                    Remove-MgChat -ChatId $Item.Id -
                    Write-LogMessage -Message "[Success] Soft Deleted ChatID: $($Item.Id). Participants: $($Item.Participants)" -Level Info 
                    try {
                        $deltedChatId = Get-MgTeamworkDeletedChat -DeletedChatId $($Item.Id) | Select-Object -ExpandProperty Id
                        Remove-MgBetaTeamworkDeletedChat -DeletedChatId $deltedChatId
                        Write-LogMessage -Message "[Success] Hard Deleted Chat: $deltedChatId" -Level Info
                        $successfullyDeletedChats++
                    }
                    catch {
                        Write-LogMessage -Message "[Failure] Error Hard deleting deleted chat $($deltedChatId): $($_.Exception.Message)" -Level Error
                    }
                }
                catch {
                    Write-LogMessage -Message "[Failure] Error Soft deleting chat $($Item.Id): $($_.Exception.Message)" -Level Error
                }
            } 
            Write-LogMessage -Message "[Success] Deleted $successfullyDeletedChats out of $totalChatsToDelete chats for $($studentUser.userPrincipalName)" -Level Info
        }
        catch {
            Write-LogMessage -Message "[Failure] Error processing $($studentUser.userPrincipalName): $($_.Exception.Message)" -Level Error
        }
    }
    Write-LogMessage -Message "[Success] Completed processing $($studentUser.userPrincipalName) in $($processingResult.TotalSeconds) seconds" -Level Info
}
