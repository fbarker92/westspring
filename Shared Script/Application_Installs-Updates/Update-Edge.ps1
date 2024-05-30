# Initialise vars
$Uri = "https://c2rsetup.officeapps.live.com/c2r/downloadEdge.aspx?platform=Default&source=EdgeStablePage&Channel=Stable&language=en&brand=M100"
$OutName = [System.IO.Path]::GetFileName($Uri)
$OutFile = "$env:TEMP\$OutName"
$InstallDir = (Get-AppxPackage | Where-Object {$_.Name -like "*edge.*"})
if ($null -eq $test) {
   Write-Host "Edge is not installed, exiting..."
   exit 0
}
else {
   Write-Host "Edge is current on version $($InstallDir.Version)"
   # Download the latest Edge .msi
   $webClient = New-Object System.Net.WebClient
   $webClient.DownloadFile($Uri, $OutFile)

   # Install Edge .msi
   msiexec.exe /i $OutFile /qn /norestart

   # Pause script while install is in progress
   Start-Sleep -Seconds 300

   # Clean up
   Write-Host "Edge has been updated to version: $($InstallDir.Version)"
   Remove-Item -Path $OutFile -Recurse -ErrorAction SilentlyContinue
}

