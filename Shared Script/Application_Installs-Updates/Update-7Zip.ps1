$Uri = "https://www.7-zip.org/a/7z2404-x64.msi"
$InstallerDir =  "C:\IT\Installers\"
$InstallerName = [System.IO.Path]::GetFileName($Uri)
$InstallerPath = "$InstallerDir$InstallerName"
$IsInstalled = $null
$RegTest = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe'

# Check registry if chrome keys are present
if($RegTest -eq $false){
   Write-Host "7Zip is not installed, exiting..."
   exit 0
}else{

# Create detination directory if it doesn't already exist
If (!(Test-Path $InstallerDir)) {New-Item -ItemType Directory -Path $InstallerDir -Force}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $InstallerPath

# Install Chrome .msi
msiexec.exe /i $InstallerPath /q

# Pause while Installer runs
Start-Sleep 20

# Clean up
Remove-Item -Path $InstallerPath -ErrorAction SilentlyContinue
}