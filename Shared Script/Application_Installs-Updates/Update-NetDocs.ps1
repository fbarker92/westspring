# Initialise vars
$Uri = "https://apps.netdocuments.com/apps/ndOffice/ndOfficeSetup.exe"
$OutName = [System.IO.Path]::GetFileName($Uri)
$OutFile = "$env:TEMP\$OutName"
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{ED53770D-7567-4FEB-8C34-F94982A4075C}"
$test = Test-Path -Path $RegPath
# Check registry if install keys are present
if (-not($test)) {
   Write-Host "NetDocs is not installed, exiting..."
   exit 0
}
else {
   $InstallDir = (Get-Item -Path $test)
   Write-Host "NetDocs is current on version $($InstallDir.VersionInfo.ProductVersion)"
   # Download the latest Chrome .msi
   $webClient = New-Object System.Net.WebClient
   $webClient.DownloadFile($Uri, $OutFile)

   # Install Chrome .msi
   Start-Process -FilePath $OutFile -Args "/silent /install" -Verb RunAs -Wait

   # Pause script while install is in progress
   Start-Sleep -Seconds 300

   # Clean up
   Write-Host "Chrome has been updated to version: $($InstallDir.VersionInfo.ProductVersion)"
   Remove-Item -Path $OutFile -Recurse -ErrorAction SilentlyContinue
}