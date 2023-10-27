$Groups = Get-UnifiedGroup -ResultSize Unlimited

ForEach ($Group in $Groups) {
    $Alias = $Group.Alias.ToString()
    $Members = Get-UnifiedGroupLinks -Identity $Group | Select-Object PrimarySmtpAddress
}

$Groups = Get-UnifiedGroup -ResultSize Unlimited


foreach ($Group in $Groups) {
Write-Host $Group.PrimarySmtpAddress
Write-Host "---OWNERS---"
Get-UnifiedGroupLinks -Identity $Group -LinkType Owners
Write-Host "---MEMBERS---"
Get-UnifiedGroupLinks -Identity $Group -LinkType Members
Write-Host "------------"
Write-Host " "
}

$DistGroups = Get-DistributionGroup -ResultSize Unlimited 

foreach ($DistGroup in $DistGroups) {
Write-Host $Group.PrimarySmtpAddress
Write-Host "---MEMBERS---"
Get-DistributionGroupMember -Identity $Group
Write-Host "------------"
Write-Host " "
}