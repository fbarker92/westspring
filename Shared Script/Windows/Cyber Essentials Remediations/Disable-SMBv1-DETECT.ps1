$SMBv1Status = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

$values = @(
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol;
)

If (($values[0].State -eq "Disabled")) {
	Write-host 'SMBv1 Currently Disabled'
        Exit 0
}else {
	Write-host 'SMBv1 not currently disabled'
        Exit 1  
}