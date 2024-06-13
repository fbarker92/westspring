Connect-ExchangeOnline

$user= Read-Host -Prompt 'Input the user name'
$useremail = "$user"

#List and removes FullAccess Rights
Write-Host Processing Full Access Rights
$Mailboxes = Get-Mailbox | Get-MailboxPermission -user $User
Write-Host Removing Full Access Rights
ForEach ($member in $Mailboxes) {Remove-MailboxPermission $member.identity -AccessRights FullAccess -user $User } 
#List and removes SendAs Rights
Write-Host Processing SendAs Rights
$SendAsMailboxes = Get-Mailbox -ResultSize Unlimited | Get-RecipientPermission | ? {$_.Trustee -eq $useremail}
Write-Host Removing SendAs Rights
ForEach ($member in $SendAsMailboxes) {Remove-RecipientPermission $member.identity -AccessRights SendAs -Trustee $useremail}
#List and removes SendOnBehalf Rights
Write-Host Processing SendOnBehalf Rights
$SendOnBehalfMailboxes = Get-Mailbox -ResultSize Unlimited |  ? {$_.GrantSendOnBehalfTo -match $user}
Write-Host Removing SendOnBehalf Rights
ForEach ($member in $SendOnBehalfMailboxes) {Set-Mailbox $member.alias -GrantSendOnBehalfTo @{remove=$useremail}}

$users = get-mailbox
 $count = 0
 #Prompt for the username
 $usertoremove = $user #'Please Input the user name of the person you want to remove from ALL Calendar Permissions'

 foreach ($user in $users)
 {
 $count++
 #Remove all mailbox:
 remove-MailboxFolderPermission -identity ($user.PrimarySmtpAddress.ToString() + ":\Calendar") -user "$usertoremove" -Confirm:$false -ErrorAction SilentlyContinue #Removes all current permissions Leave in by default

 Write-Progress -Activity 'Processing Users' -CurrentOperation $user -PercentComplete (($count / $users.count) * 100)
 Start-Sleep -Milliseconds 200
 }