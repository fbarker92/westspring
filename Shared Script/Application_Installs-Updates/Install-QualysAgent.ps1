$Uri = "*download-url*"
$DirPath = "C:\IT\Qualys_Agent\"
$InstallerName = "Qualys_Agent.exe"
$InstallerPath = "$DirPath$InstallerName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $DirPath)) {
    Write-Host "Creating the following directory - $DirPath" -ForegroundColor Green
    New-Item -ItemType Directory -Path $DirPath -Force
}

# Download the Qualys Agent
Invoke-RestMethod -Uri $Uri -OutFile $InstallerPath
If ((Test-Path $InstallerPath)) {
    Write-Host "The file, $InstallerName, Successfully downloaded" -ForegroundColor Green
} else {
    Write-Host "the File download failed, please try again" -ForegroundColor Red
    Exit 1
}

# Install Qualys Agent
Write-Host "Installing the Qualys Agent..."
Start-Process $InstallerPath /silent

Start-Sleep -Seconds 30
# Clean up
Remove-Item -Path $DirPath -Recurse -ErrorAction SilentlyContinue
If (!(Test-Path $InstallerPath)) {
    Write-Host "Installation files successfully removed"
}