$User = Read-Host "Enter the users full email address (e.g. user@domain.tld)"
$Date = get-Date -Format "yyyy-MM-dd-HH_mm_ss"

If(!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Installing Microsoft.Graph module"
    Install-Module -Name Microsoft.Graph -Force
}
If(!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Installing Microsoft.Graph module"
    Install-Module -Name ExchangeOnlineManagement -Force
}

Write-Host "Connecting to Microsoft Graph and Exchange Online"
Connect-MgGraph
Connect-ExchangeOnline

$MGmemberOf = Get-MgUserMemberOf -UserId $User 
$EXOUnifiedGroups = Get-UnifiedGroup -ResultSize Unlimited
$EXODLGroups = Get-DistributionGroup -ResultSize Unlimited

ForEach ($EXOUnifiedGroup in $EXOUnifiedGroups) {
    Get-UnifiedGroupLinks -Identity $EXOUnifiedGroup.Identity -LinkType Members | Where-Object {$_.PrimarySmtpAddress -eq $User}
    [PSCustomObject]@{
        DisplayName = $EXOUnifiedGroup.DisplayName
        Id = $groEXOUnifiedGroupup.Id
        MailEnabled = $true
        Mail = $EXOUnifiedGroup.PrimarySmtpAddress
             } #| Export-Csv -Path .\$User-$Date-Groups.csv -Append -NoTypeInformation
}

foreach ($group in $MGmemberOf) {
       If ($null -eq (Get-MgGroup -GroupId $group.Id).OnpremisesDomainName){
        Write-Host "Removing $User from group: " $(Get-MgGroup -GroupId $group.Id).DisplayName
        Remove-MgGroupMember -GroupId $group.Id -MemberId $User
    } else {
        Write-Host "Group "($(Get-MgGroup -GroupId $group.Id).DisplayName)" is managed on prem, please remove user manually from the $((Get-MgGroup -GroupId $group.Id).OnpremisesDomainName) Domain"
    }
    [PSCustomObject]@{
        DisplayName = $(Get-MgGroup -GroupId $group.Id).DisplayName
        Id = $group.Id
        MailEnabled = $(Get-MgGroup -GroupId $group.Id).MailEnabled
        Mail = $(Get-MgGroup -GroupId $group.Id).Mail
             } #| Export-Csv -Path .\$User-$Date-Groups.csv -Append -NoTypeInformation
}
