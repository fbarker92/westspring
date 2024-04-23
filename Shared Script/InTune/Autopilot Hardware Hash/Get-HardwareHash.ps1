
$NewRow = PowerShell -NoProfile -ExecutionPolicy Unrestricted -Command Get-WindowsAutoPilotInfo.ps1
#Append to CSV
$NewRow | Add-Content -Path ".\AutopilotHWIDs.csv"
Write-Host "Data sucessfully saved to CSV"

