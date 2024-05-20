# Function to get all installed .NET versions
function Get-InstalledDotNetVersions {
    $dotNetInstallations = @()

    # Get .NET Framework versions
    $dotNetInstallations += Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
        Get-ItemProperty -Name Version,Release -EA 0 |
        Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} |
        Select-Object @{
            Name = 'Version'
            Expression = {
                [System.Version]::Parse(($_.Version -replace '\.\d+$', ''))
            }
        }, @{
            Name = 'Release'
            Expression = {
                ($_.Release -split '\.')[-1]
            }
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
                [System.Version]($versionPath.Split('-')[0])
            }
        }, @{
            Name = 'Release'
            Expression = { '' }
        }, @{
            Name = 'Type'
            Expression = { '.NET Core' }
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
            }
        }
        catch {
            Write-Warning "Failed to update $type $version: $_"
        }
    }
}

# Function to list end-of-life/support .NET versions
function Get-EndOfLifeDotNetVersions {
    $endOfLifeVersions = @(
        [System.Version]'4.0',
        [System.Version]'4.5',
        [System.Version]'4.5.1',
        [System.Version]'4.5.2',
        [System.Version]'4.6',
        [System.Version]'4.6.1',
        [System.Version]'4.6.2',
        [System.Version]'4.7',
        [System.Version]'4.7.1',
        [System.Version]'4.7.2'
    )

    $installedVersions = Get-InstalledDotNetVersions | ForEach-Object { [System.Version]($_.Split(' ')[1]) }

    $endOfLifeVersions | Where-Object { $installedVersions -contains $_ } | ForEach-Object {
        Write-Host ".NET Framework $_ is end-of-life/support"
    }
}

# Call the functions
Get-InstalledDotNetVersions
Update-DotNet
Get-EndOfLifeDotNetVersions
