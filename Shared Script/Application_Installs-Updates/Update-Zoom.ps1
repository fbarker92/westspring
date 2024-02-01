$Uri = "https://cdn.zoom.us/prod/5.17.7.31859/x64/ZoomInstallerFull.msi"
$InstallerDir =  "C:\IT\Installers\"
$InstallerName = [System.IO.Path]::GetFileName($Uri)
$InstallerPath = "$InstallerDir$InstallerName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $InstallerDir)) {
    New-Item -ItemType Directory -Path $InstallerDir -Force
}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $InstallerPath

# Install Chrome .msi
msiexec.exe /i $InstallerPath /quiet /qn /norestart ZoomAutoUpdate=1

# Pause while Installer runs
Start-Sleep 20

# Clean up
Remove-Item -Path $InstallerPath -ErrorAction SilentlyContinue