# Download and install the dotnet-uninstall-tool MSI
$toolUrl = "https://github.com/dotnet/cli-lab/releases/download/1.7.521001/dotnet-core-uninstall-1.7.521001.msi"
$toolPath = "$env:TEMP\dotnet-core-uninstall.msi"

Write-Host "Downloading dotnet-uninstall-tool..."
Invoke-WebRequest -Uri $toolUrl -OutFile $toolPath

Write-Host "Installing dotnet-uninstall-tool..."
Start-Process msiexec.exe -ArgumentList "/i $toolPath /quiet" -Wait

# Get the installation directory of the dotnet-core-uninstall tool
$installDir = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object { $_.DisplayName -like 'Microsoft .NET Core Uninstall Tool*' }).InstallLocation

# Change the current directory to the installation directory
Push-Location $installDir

# List all installed .NET versions
Write-Host "Listing installed .NET versions:"
.\dotnet-core-uninstall list

# Prompt for uninstalling end-of-life versions
$choice = Read-Host "Do you want to uninstall end-of-life .NET versions? (Y/N)"

if ($choice -eq 'Y' -or $choice -eq 'y') {
    Write-Host "Uninstalling end-of-life .NET versions..."
    .\dotnet-core-uninstall uninstall --force --all-but-latest
}

# Restore the original current directory
Pop-Location

# Clean up
Write-Host "Cleaning up..."
Remove-Item $toolPath
