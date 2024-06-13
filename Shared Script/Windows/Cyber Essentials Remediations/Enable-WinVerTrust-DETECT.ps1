$values = @(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust\Config" -ErrorAction SilentlyContinue;
Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Cryptography\Wintrust\Config" -ErrorAction SilentlyContinue)

If (($values[0].EnableCertPaddingCheck -eq 1) -and 
    ($values[1].EnableCertPaddingCheck -eq 1)) {
	Write-host "Reg Key already Exists and is set to 1"
        Exit 0
}else {
	Write-host "Reg Key(s) does not exist or is not set correctly"
        Exit 1  
}
