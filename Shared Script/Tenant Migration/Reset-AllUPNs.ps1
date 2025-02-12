# Ensure necessary modules are installed
$modules = @("Microsoft.Graph", "ExchangeOnlineManagement")
foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Install-Module -Name $module -Force -Scope CurrentUser
    }
}

# Import the necessary modules
Import-Module Microsoft.Graph
Import-Module ExchangeOnlineManagement

# Define the log file path
$logFile = "C:\path\to\$(Get-date -Format "yyy-MM-dd")logfile.txt"

# Function to log messages
function Write-LogMessage {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry
}

# Get Credentials
#$cred = Get-Credential

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All" #-Credential $cred

# Connect to Exchange Online
Connect-ExchangeOnline #-Credential $cred

# Get the .onmicrosoft.com domains
$tenantDetails = Get-MgOrganization
$onMicrosoftDomains = $tenantDetails.VerifiedDomains | Where-Object { $_.Name -like "*.onmicrosoft.com" }

# Prompt the user to select the default domain if multiple are present
if ($onMicrosoftDomains.Count -gt 1) {
    Write-Host "Multiple .onmicrosoft.com domains found. Please select the default domain:"
    for ($i = 0; $i -lt $onMicrosoftDomains.Count; $i++) {
        Write-Host "$($i + 1): $($onMicrosoftDomains[$i].Name)"
    }
    $selection = Read-Host "Enter the number of the domain to use"
    $defaultDomain = $onMicrosoftDomains[$selection - 1].Name
} else {
    $defaultDomain = $onMicrosoftDomains[0].Name
}

# Reset UPN for users
$users = Get-MgUser -All
foreach ($user in $users) {
    $newUPN = "$($user.UserPrincipalName.Split('@')[0])@$defaultDomain"
    #Update-MgUser -UserId $user.Id -UserPrincipalName $newUPN
    Write-LogMessage "User UPN changed: $($user.UserPrincipalName) -> $newUPN"
}

# Reset UPN for shared mailboxes
$sharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox
foreach ($mailbox in $sharedMailboxes) {
    $newUPN = "$($mailbox.UserPrincipalName.Split('@')[0])@$defaultDomain"
    #Set-Mailbox -Identity $mailbox.Identity -PrimarySmtpAddress $newUPN
    Write-LogMessage "Shared mailbox UPN changed: $($mailbox.UserPrincipalName) -> $newUPN"
}

# Reset UPN for groups
$groups = Get-MgGroup -All
foreach ($group in $groups) {
    $newUPN = "$($group.Mail.Split('@')[0])@$defaultDomain"
    #Update-MgGroup -GroupId $group.Id -MailNickname $newUPN
    Write-LogMessage "Group UPN changed: $($group.Mail) -> $newUPN"
}

Write-LogMessage "UPN reset script completed."
