Set-ExecutionPolicy Bypass

Write-Host `
" _____________________________________
|                                     |
|          Delete Script ESET         |
|      Endpoint Security + Agent      |
|                                     |
| (c) Drek_27                         |
|                                     |
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯" `
-ForegroundColor Yellow

Write-Host "Make sure to launch the script from the Computer where you need to uninstall software " -ForegroundColor Red
$password = $null #Read-Host "Enter the password for uninstallation of ESET Endpoint Security"

#$start = Read-host "You keep them you ? [O] / [N]"
#if ( $start -eq 'O' ) {

$uninstallEsetEA = "1" #gci "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | foreach { gp $_.PSPath } | ? { $_ -match "ESET Endpoint Antivirus" } | Select UninstallString
<# $uninstallEsetMA = gci "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | foreach { gp $_.PSPath } | ? { $_ -match "ESET Management Agent" } | select UninstallString
$uninstallEsetES = gci "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | foreach { gp $_.PSPath } | ? { $_ -match "ESET Endpoint Security" } | select UninstallString #>


if ($null -ne $password) {
    if ($uninstallEsetEA) {
$uninstallEsetEA = $uninstallEsetEA.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
$uninstallEsetEA = $uninstallEsetEA.Trim()
Write-Host "Uninstalling With password..."
#start-process "msiexec.exe" -arg "/X $uninstallEsetEA /qb /quiet password=$password REBOOT=ReallySuppress" -Wait
}
} elseif ($uninstallEsetEA) {
$uninstallEsetEA = $uninstallEsetEA.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
$uninstallEsetEA = $uninstallEsetEA.Trim()
Write-Host "Uninstalling..."
#start-process "msiexec.exe" -arg "/X $uninstallEsetEA /qb /quiet REBOOT=ReallySuppress" -Wait
}


<# $uninstall64 = gci "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "ESET Management Agent" } | select UninstallString

if ($uninstall64) {
$uninstall64 = $uninstall64.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
$uninstall64 = $uninstall64.Trim()
Write "Uninstalling..."
start-process "msiexec.exe" -arg "/X $uninstall64 /norestart" -Wait}

Set-NetFirewallProfile -Profile * -Enabled True

Write-Host "Deletion verification process ..."
$namelistappli = Get-WmiObject -Class Win32_Product | Select-Object -Property Name

if ($namelistappli -eq "Eset Management Agent" -and "ESET Endpoint Security" ){
    Write-Host "Eset Endpoint is not deleted" -BackgroundColor Black -ForegroundColor Green
}
else{
    Restart-Computer
}
#}
Else{Write-Host "Bye !"} #>