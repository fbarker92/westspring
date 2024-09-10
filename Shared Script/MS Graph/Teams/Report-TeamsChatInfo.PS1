# Check PowserShell Version
If ($PSVersionTable.PSVersion -lt "7.1") {
    Write-Host "This script requires PowerShell 7.1 or higher. Please update your PowerShell version and re-run the script." -BackgroundColor Red -ForegroundColor White
    Exit 1
}
# Check if required module is installed, install if not
$modulePresent = Get-Module -Name Microsoft.Graph.Teams -ListAvailable
If (!($modulePresent)) {
    Write-Host "Microsoft.Graph.Teams module not found. Now attempting to install..."
    Install-Module -Name Microsoft.Graph.Teams -Scope CurrentUser -Force -AllowClobber
    If (!($modulePresent)) {
        Write-Host "Unable to install Microsoft.Graph.Teams module. Please install manually and re-run script."
        Exit 1
    }
}
Else {
    Write-Host "Microsoft.Graph.Teams module found. Continuing..." -ForegroundColor Green
}
# Initialise Vars
$ApplicationClientId = '' # Application (Client) ID
$ApplicationClientSecret = '' # Application Secret Value
$SecureClientSecret = ConvertTo-SecureString -String $ApplicationClientSecret -AsPlainText -Force
$ClientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationClientId, $SecureClientSecret
$TenantId = '' # Tenant ID
# Import the excluded participants from a CSV file
[array]$teacherUsers = Import-Csv -Path "C:\path\to\file.csv"
[array]$studentUsers = Import-Csv -Path "C:\Path\to\file.csv" 

try {
    Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $ClientSecretCredential -NoWelcome -ErrorAction Stop
}
catch {
    Write-Host "There was an error connecting to MsGraph:" -BackgroundColor Red -ForegroundColor White
    Write-Host $Error[0] -BackgroundColor Red -ForegroundColor White
    Write-Host ". Please check the application conenction paramters and try again" -BackgroundColor Red -ForegroundColor White
    Exit 0
}


ForEach ($studentUser in $studentUsers) {

    # Get UserId for the user
    $UserId = (Get-MgUser -UserId $UserPrincipalName.PrimarySmtpAddress).Id

    # Get chats for the user
    [array]$Chats = Get-MgUserChat -Userid $UserId -All -Filter "chattype eq 'oneonone'" | Sort-Object LastUpdatedDateTime -Descending

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
        [array]$Members = Get-MgUserChatMember -UserId $UserId -ChatId $Chat.Id

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
        Remove-MgChat -ChatId $Item.Id
        Write-Host "Chat $($Item.Id) deleted" -BackgroundColor Yellow -ForegroundColor Blue
        Write-Host "Participants: $($Item.Participants)" -BackgroundColor Yellow -ForegroundColor Blue
        # The below should hard delete the chat, but it is not accepting the ChatId, and the documentation isn't clear on how to do this.
        $deltedChatId = Get-MgTeamworkDeletedChat -DeletedChatId $($Item.Id) | Select-Object -ExpandProperty Id
        Remove-MgBetaTeamworkDeletedChat -DeletedChatId $deltedChatId
        Write-Host "Deleted Chat $deltedChatId deleted"
    } 
}
