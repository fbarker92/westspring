$Uri = "https://anywhere.webrootcloudav.com/zerol/wsasme.msi"
$DirPath = "C:\IT\Webroot_Agent\"
$InstallerName = "wsasme.msi"
$InstallerPath = "$DirPath$InstallerName"
$keyCode = "804F-ENTP-31CB-27D2-4099"

# Create detination directory if it doesn't already exist
If (!(Test-Path $DirPath)) {
    Write-Host "Creating the following directory - $DirPath" -ForegroundColor Green
    New-Item -ItemType Directory -Path $DirPath -Force
}

# Download the installer 
Invoke-RestMethod -Uri $Uri -OutFile $InstallerPath
If ((Test-Path $InstallerPath)) {
    Write-Host "The file, $InstallerName, Successfully downloaded" -ForegroundColor Green
} else {
    Write-Host "the File download failed, please try again" -ForegroundColor Red
    Exit 1
}

# Install application
Write-Host "Installing the Application..."

msiexec /i $InstallerPath GUILIC="$keyCode" CMDLINE="SME,quiet" /qn
Start-Sleep -Seconds 30
# Clean up
Remove-Item -Path $DirPath -Recurse -ErrorAction SilentlyContinue
If (!(Test-Path $InstallerPath)) {
    Write-Host "Installation files successfully removed"
}