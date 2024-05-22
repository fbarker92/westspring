#Check Winget Install
Write-Host "Checking if Winget is installed" -ForegroundColor Yellow
$TestWinget = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq "Microsoft.DesktopAppInstaller" }
If ([Version]$TestWinGet.Version -gt "2022.506.16.0") {
	Write-Host "WinGet is Installed" -ForegroundColor Green
}
Else {
	Try {
		Write-Host "Installing MSIXBundle for App Installer..." 
		Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
		Write-Host "Installed MSIXBundle for App Installer" -ForegroundColor Green
	}
	Catch {
		Write-Host "Failed to install MSIXBundle for App Installer..." -ForegroundColor Red
	} 
}