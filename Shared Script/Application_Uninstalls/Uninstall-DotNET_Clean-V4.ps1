# Function to get all installed .NET versions
function Get-InstalledDotNetVersions {
    $dotNetInstallations = @()

    # Get .NET Framework versions
    $dotNetInstallations += Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
        Get-ItemProperty -Name Version,Release -EA 0 |
        Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} |
        Select-Object @{
            Name = 'Version'
            Expression = { $_.Version }
        }, @{
            Name = 'Release'
            Expression = { $_.Release }
        }, @{
            Name = 'Type'
            Expression = { '.NET Framework' }
        }

    # Get .NET Core versions
    $dotNetInstallations += Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledVersions' -Recurse |
        Get-ItemProperty -Name 'InstallLocation' -EA 0 |
        Where-Object { $_.InstallLocation -ne $null } |
        Select-Object @{
            Name = 'Version'
            Expression = {
                $versionPath = Split-Path $_.InstallLocation -Leaf
                $versionPath.Split('-')[0]
            }
        }, @{
            Name = 'Release'
            Expression = { '' }
        }, @{
            Name = 'Type'
            Expression = { '.NET Core' }
        }

    # Get .NET Runtime versions
    $dotNetInstallations += Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Recurse |
        Get-ItemProperty -Name Release -EA 0 |
        Select-Object @{
            Name = 'Version'
            Expression = { '4.0' }
        }, @{
            Name = 'Release'
            Expression = { $_.Release }
        }, @{
            Name = 'Type'
            Expression = { '.NET Runtime' }
        }

    $dotNetInstallations | ForEach-Object {
        $version = $_.Version
        $release = $_.Release
        $type = $_.Type

        $versionString = "$type $version"
        if ($release) {
            $versionString += " ($release)"
        }

        $versionString
    }
}

# Function to download and install the latest .NET updates
function Update-DotNet {
    $dotNetInstallations = Get-InstalledDotNetVersions

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
