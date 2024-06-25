$values = @(
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters";
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters";
)

If (
	($values[0].enablesecuritysignature -eq 1) -and
	($values[0].requiresecuritysignature -eq 1) -and
	($values[1].EnablePlainTextPassword -eq 0) -and 
	($values[1].EnableSecuritySignature -eq 1) -and 
	($values[1].RequireSecuritySignature -eq 1)) {
	Write-host "Reg Key(s) already Exists and is set correctly"
        Exit 0
}else {
	Write-host "Reg Key(s) does not exist or is not set correctly"
        Exit 1  
}