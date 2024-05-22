$Path = "C:\Program Files\Docker\Docker\"
If (Test-Path -Path "$Path\Docker Desktop Installer.exe") {
    Start-Process -FilePath "$Path\Docker Desktop Installer.exe" -ArgumentList "uninstall --quiet" -Wait -PassThru
    Write-Host "Docker Desktop has been uninstalled..."
} else {
    Write-Host "Docker Desktop is not Installed, now exiting... "
    Exit 1
}