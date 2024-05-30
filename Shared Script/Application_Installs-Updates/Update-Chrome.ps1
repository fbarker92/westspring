# Initialise vars
$Uri = "http://dl.google.com/chrome/install/latest/chrome_installer.exe"
$OutName = [System.IO.Path]::GetFileName($Uri)
$OutFile = "$env:TEMP\$OutName"
$test = (Get-ChildItem -recurse -Path "C:\Program Files*" -filter "chrome.exe" -ErrorAction SilentlyContinue).FullName
# Check registry if chrome keys are present
if ($null -eq $test) {
   Write-Host "Chrome is not installed, exiting..."
   exit 0
}
else {
   $InstallDir = (Get-Item -Path $test)
   Write-Host "Chrome is current on version $($InstallDir.VersionInfo.ProductVersion)"
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

