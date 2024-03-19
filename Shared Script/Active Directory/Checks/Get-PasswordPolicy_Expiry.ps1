#Check Local domain connection
$DCConnection = Test-ComputerSecureChannel -Server "UTAX.local"
If ($DCConnection -eq $False) {
    Write-Host "Domain connection failed"
    Exit 0
} Else {
# Export Data
secedit /export /cfg c:\temp\secpol.cfg

#Format Data
$secpol = (Get-Content C:\temp\secpol.cfg)

#Scrape Data
$HostName = $env:computername
$CurrUser = Get-WMIObject -class Win32_ComputerSystem | select username
$MaximumPasswordAge = $secpol | where{ $_ -like "MaximumPasswordAge*" }

#Append to CSV
$NewRow = "$HostName,$($CurrUser.username),$MaximumPasswordAge"
$NewRow | Add-Content -Path "\\DC04\PasswordPolicy$\PasswordPolicy.csv"
}