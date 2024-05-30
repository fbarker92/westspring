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

<<<<<<< HEAD
    foreach ($installation in $dotNetInstallations) {
        $version = $installation.Split(' ')[1]
        $type = $installation.Split(' ')[0]

        try {
            if ($type -eq '.NET Framework') {
                $installerPath = "$env:TEMP\dotNetInstaller.exe"
                $installerUrl = "https://go.microsoft.com/fwlink/?linkid=866021&clcid=0x409&setupVersion=$version"

                Write-Host "Downloading $type $version installer..."
                Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

                Write-Host "Installing $type $version updates..."
                Start-Process -FilePath $installerPath -ArgumentList "/q" -Wait

                Write-Host "Cleaning up..."
                Remove-Item $installerPath
            }
            elseif ($type -eq '.NET Core') {
                Write-Host "Updating $type $version..."
                dotnet tool update --global dotnet-core-uninstall
                dotnet-core-uninstall --version $version --force
                dotnet-core-install --version $version

                # Remove leftover files in C:\Program Files\dotnet\shared
                $sharedPath = "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\$version"
                if (Test-Path $sharedPath) {
                    Write-Host "Removing leftover files in $sharedPath..."
                    Remove-Item -Recurse -Force $sharedPath
                }
            }
            elseif ($type -eq '.NET Runtime') {
                $installerPath = "$env:TEMP\dotNetInstaller.exe"
                $installerUrl = "https://go.microsoft.com/fwlink/?linkid=866021&clcid=0x409&setupVersion=$version"

                Write-Host "Downloading $type $version installer..."
                Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

                Write-Host "Installing $type $version updates..."
                Start-Process -FilePath $installerPath -ArgumentList "/q" -Wait

                Write-Host "Cleaning up..."
                Remove-Item $installerPath
            }
        }
        catch {
            Write-Warning "Failed to update $type $version : $_"
        }
    }
}

# Function to list end-of-life/support .NET versions
function Get-EndOfLifeDotNetVersions {
    $endOfLifeVersions = @(
        '4.0',
        '4.5',
        '4.5.1',
        '4.5.2',
        '4.6',
        '4.6.1',
        '4.6.2',
        '4.7',
        '4.7.1',
        '4.7.2'
    )

    $installedVersions = Get-InstalledDotNetVersions | ForEach-Object { $_.Split(' ')[1] }

    $endOfLifeVersions | Where-Object { $installedVersions -contains $_ } | ForEach-Object {
        $type = (Get-InstalledDotNetVersions | Where-Object { $_.Split(' ')[1] -eq $_ }).Split(' ')[0]
        Write-Host "$type $_ is end-of-life/support"
    }
}

# Function to uninstall end-of-life .NET versions
function Uninstall-EndOfLifeDotNet {
    $endOfLifeVersions = @(
        '4.0',
        '4.5',
        '4.5.1',
        '4.5.2',
        '4.6',
        '4.6.1',
        '4.6.2',
        '4.7',
        '4.7.1',
        '4.7.2'
    )

    $installedVersions = Get-InstalledDotNetVersions | ForEach-Object { $_.Split(' ')[1] }

    $endOfLifeVersions | Where-Object { $installedVersions -contains $_ } | ForEach-Object {
        $version = $_
        $type = (Get-InstalledDotNetVersions | Where-Object { $_.Split(' ')[1] -eq $_ }).Split(' ')[0]
        $installerPath = "$env:TEMP\dotNetUninstaller.exe"
        $installerUrl = "https://go.microsoft.com/fwlink/?linkid=866021&clcid=0x409&setupVersion=$version"

        Write-Host "Downloading $type $version uninstaller..."
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

        Write-Host "Uninstalling $type $version..."
        if ($type -eq '.NET Runtime') {
            Start-Process -FilePath $installerPath -ArgumentList "/uninstall /q" -Wait
        } else {
            Start-Process -FilePath $installerPath -ArgumentList "/q" -Wait
        }

        Write-Host "Cleaning up..."
        Remove-Item $installerPath
    }
}

# Call the functions
Get-InstalledDotNetVersions
Update-DotNet
Get-EndOfLifeDotNetVersions

# Uncomment the following line to uninstall end-of-life .NET versions
# Uninstall-EndOfLifeDotNet
=======
# Clean up
Write-Host "Cleaning up..."
Remove-Item $toolPath
>>>>>>> ab3a160feedf1d0c5116121453b1bc847856c46b
