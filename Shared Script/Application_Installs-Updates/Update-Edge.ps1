# Initialise vars
$Uri = "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/3621e33c-826a-4d7c-b6a7-4e14ed9e5fa1/MicrosoftEdgeEnterpriseX64.msi"
$OutName = [System.IO.Path]::GetFileName($Uri)
$OutFile = "$env:TEMP\$OutName"
$InstallDir = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if ((Test-Path $InstallDir) -eq $false) {
   Write-Host "Edge is not installed, exiting..."
   exit 0
}
else {
   $currVers = (Get-Item $InstallDir).VersionInfo.ProductVersion
   Write-Host "Edge is current on version $($currVers)"
   # Download the latest Edge .msi
   $webClient = New-Object System.Net.WebClient
   $webClient.DownloadFile($Uri, $OutFile)

   # Install Edge .msi
   msiexec.exe /i $OutFile /qn /norestart

   # Pause script while install is in progress
   #Start-Sleep -Seconds 300

   # Clean up
   $newVers = (Get-Item $InstallDir).VersionInfo.ProductVersion
   Write-Host "Edge has been updated to version: $($newVers)"
   Remove-Item -Path $OutFile -Recurse -ErrorAction SilentlyContinue
}

