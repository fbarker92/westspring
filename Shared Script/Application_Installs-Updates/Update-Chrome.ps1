# Initialise vars
$Uri = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
$OutPath =  "C:\IT\Google_Chrome\"
$OutName = "google-chrome.msi"
$OutFile = "$OutPath$OutName"
$IsInstalled = $null
$RegTest = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe'

# Check registry if chrome keys are present
if($RegTest -eq $false){
   Write-Host "Chrome is not installed, exiting..."
   exit 0
}else{
   # Create detination directory if it doesn't already exist
If (!(Test-Path $OutPath)) {
    New-Item -ItemType Directory -Path $OutPath -Force
    }
}
# Download the latest Chrome .msi
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($Uri, $OutFile)


# Install Chrome .msi
msiexec.exe /i $OutFile /qn /norestart

# Pause script while install is in progress
Start-Sleep -Seconds 300

# Clean up
Remove-Item -Path $OutFile -Recurse -ErrorAction SilentlyContinue
$Vers = Get-Item -Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
Write-Host "Application version: $($Vers.VersionInfo.ProductVersion)"


