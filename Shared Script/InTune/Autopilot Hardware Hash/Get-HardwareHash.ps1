[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
$NewRow = .\Get-WindowsAutoPilotInfo.ps1

#Append to CSV
$NewRow | Add-Content -Path ".\AutopilotHWIDs.csv"
Write-Host "Data sucessfully saved to CSV"

