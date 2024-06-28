$values = @(
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\HTTP\Parameters";
)

If (
	($values[0].EnableHttp2Cleartext -eq 0) -and
	($values[0].EnableHttp2Cleartext -eq 0)
) {
	Write-host "Reg Key(s) already Exists and is set correctly"
        Exit 0
}else {
	Write-host "Reg Key(s) does not exist or is not set correctly"
        Exit 1  
}