# Function to check for and install .NET updates
function Install-Updates($versionsToKeep) {
    Write-Output "Checking for .NET updates..."

    # Check for .NET Framework updates
    $ndpKeys = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
               Get-ItemProperty -Name Version, Release -EA 0
    foreach ($key in $ndpKeys) {
        if ($key.PSChildName -match '^(?!S)\p{L}') {
            $product = $key.PSChildName
            $version = [version]$key.Version
            $majorVersion = "$($version.Major).$($version.Minor).x"
            if ($versionsToKeep -contains $majorVersion) {
                $updatePath = "$env:TEMP\dotNetFx$($version.Major)$($version.Minor).exe"
                $url = "https://download.microsoft.com/download/$($version.Major).$($version.Minor).$($version.Build)/dotNetFx$($version.Major)$($version.Minor).exe"
                try {
                    Invoke-WebRequest -Uri $url -OutFile $updatePath -ErrorAction Stop
                    Write-Output "Installing $product update..."
                    Start-Process -FilePath $updatePath -ArgumentList "/q /norestart" -Wait
                    Write-Output "$product update installed successfully."
                }
                catch {
                    Write-Warning "Failed to install $product update: $_"
                }
                finally {
                    Remove-Item -Path $updatePath -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }

    # Check for .NET Core updates
    $sdkPath = "$env:ProgramFiles\dotnet\sdk"
    if (Test-Path $sdkPath) {
        $sdkComponents = Get-ChildItem $sdkPath -Directory | ForEach-Object {
            $sdkVersion = $_.Name
            $majorVersion = "$($sdkVersion.Split('.')[0]).$($sdkVersion.Split('.')[1]).x"
            if ($versionsToKeep -contains $majorVersion) {
                Write-Output "Updating .NET Core SDK $sdkVersion..."
                dotnet new globaljob --force
                dotnet tool update --global dotnet-sdk-update --version $sdkVersion
                dotnet sdk-update --update-mode=UpdateAndQuit
            }
        }
    }

    # Check for .NET Core runtime updates
    $runtimeComponents = dotnet --list-runtimes | ForEach-Object {
        $runtimeVersion = $_
        $majorVersion = "$($runtimeVersion.Split('.')[0]).$($runtimeVersion.Split('.')[1]).x"
        if ($versionsToKeep -contains $majorVersion) {
            Write-Output "Updating .NET Core Runtime $runtimeVersion..."
            dotnet new globaljob --force
            dotnet tool update --global dotnet-runtime-update --version $runtimeVersion
            dotnet runtime-update --update-mode=UpdateAndQuit
        }
    }
}

# Function to list and select components for uninstallation
function Select-ComponentsToUninstall {
    $components = @()

    # Prompt user to enter the .NET major versions to keep
    $versionsToKeep = Read-Host "Enter the .NET major versions to keep (e.g., 8.x.x, 6.x.x, 3.x.x) separated by commas"
    $versionsToKeep = $versionsToKeep.Split(',').Trim()

    # Install available updates for the versions to keep
    Install-Updates $versionsToKeep

    # List installed .NET Framework versions
    Write-Output "Installed .NET Framework versions:"
    $ndpKeys = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
               Get-ItemProperty -Name Version, Release -EA 0
    foreach ($key in $ndpKeys) {
        if ($key.PSChildName -match '^(?!S)\p{L}') {
            $product = $key.PSChildName
            $version = [version]$key.Version
            $majorVersion = "$($version.Major).$($version.Minor).x"
            $release = $key.Release
            if ($versionsToKeep -notcontains $majorVersion) {
                $components += [PSCustomObject]@{
                    Type    = ".NET Framework"
                    Version = "$version ($release)"
                    Path    = $null
                }
            }
            Write-Output "- $product $version ($release)"
        }
    }
    Write-Output ""

    # List installed .NET Core SDKs
    Write-Output "Installed .NET Core SDKs:"
    $sdkPath = "$env:ProgramFiles\dotnet\sdk"
    if (Test-Path $sdkPath) {
        $sdkComponents = Get-ChildItem $sdkPath -Directory | ForEach-Object {
            $sdkVersion = $_.Name
            $majorVersion = "$($sdkVersion.Split('.')[0]).$($sdkVersion.Split('.')[1]).x"
            if ($versionsToKeep -notcontains $majorVersion) {
                $components += [PSCustomObject]@{
                    Type    = "SDK"
                    Version = $sdkVersion
                    Path    = $_.FullName
                }
            }
            Write-Output "- $sdkVersion"
        }
    }
    Write-Output ""

    # List installed .NET Core runtimes
    Write-Output "Installed .NET Core Runtimes:"
    $runtimeComponents = dotnet --list-runtimes | ForEach-Object {
        $runtimeVersion = $_
        $majorVersion = "$($runtimeVersion.Split('.')[0]).$($runtimeVersion.Split('.')[1]).x"
        if ($versionsToKeep -notcontains $majorVersion) {
            $components += [PSCustomObject]@{
                Type    = "Runtime"
                Version = $runtimeVersion
                Path    = $null
            }
        }
        Write-Output "- $_"
    }
    Write-Output ""

    # List installed .NET Core hosting bundles
    Write-Output "Installed .NET Core Hosting Bundles:"
    $hostingBundleKeys = Get-ChildItem 'HKLM:\SOFTWARE\dotnet\Setup\InstalledHostingBundles' -Recurse |
                         Get-ItemProperty -Name 'Version' -EA 0
    foreach ($key in $hostingBundleKeys) {
        $version = $key.Version
        $majorVersion = "$($version.Split('.')[0]).$($version.Split('.')[1]).x"
        if ($versionsToKeep -notcontains $majorVersion) {
            $components += [PSCustomObject]@{
                Type    = "Hosting Bundle"
                Version = $version
                Path    = $null
            }
        }
        Write-Output "- $version"
    }
    Write-Output ""

    # List installed ASP.NET Core runtimes
    Write-Output "Installed ASP.NET Core Runtimes:"
    $aspNetCoreKeys = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Updates\.NETCore' -Recurse |
                      Get-ItemProperty -Name 'VersionMajor', 'VersionMinor' -EA 0
    foreach ($key in $aspNetCoreKeys) {
        $version = "{0}.{1}" -f $key.VersionMajor, $key.VersionMinor
        $majorVersion = "$($key.VersionMajor).$($key.VersionMinor).x"
        if ($versionsToKeep -notcontains $majorVersion) {
            $components += [PSCustomObject]@{
                Type    = "ASP.NET Core Runtime"
                Version = $version
                Path    = $null
            }
        }
        Write-Output "- $version"
    }
    Write-Output ""

    # List installed .NET Desktop runtimes
    Write-Output "Installed .NET Desktop Runtimes:"
    $desktopRuntimeKeys = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\VisualStudio\Bundles' -Recurse |
                          Get-ItemProperty -Name 'Version' -EA 0
    foreach ($key in $desktopRuntimeKeys) {
        $version = $key.Version
        $majorVersion = "$($version.Split('.')[0]).$($version.Split('.')[1]).x"
        if ($versionsToKeep -notcontains $majorVersion) {
            $components += [PSCustomObject]@{
                Type    = "Desktop Runtime"
                Version = $version
                Path    = $null
            }
        }
        Write-Output "- $version"
    }
    Write-Output ""

    # List .NET installations in C:\Program Files\dotnet\shared
    Write-Output "Installed .NET in shared folder:"
    $sharedDotNetPath = "$env:ProgramFiles\dotnet\shared"
    if (Test-Path $sharedDotNetPath) {
        $sharedComponents = Get-ChildItem $sharedDotNetPath -Directory | ForEach-Object {
            $version = $_.Name
            $majorVersion = "$($version.Split('.')[0]).$($version.Split('.')[1]).x"
            if ($versionsToKeep -notcontains $majorVersion) {
                $components += [PSCustomObject]@{
                    Type    = "Shared"
                    Version = $version
                    Path    = $_.FullName
                }
            }
            Write-Output "- $version"
        }
    }
    Write-Output ""

    return $components
}

# Function to uninstall selected components
function Uninstall-Components($components) {
    foreach ($component in $components) {
        Write-Output "Uninstalling $($component.Type) $($component.Version)..."

        # Remove component files
        if ($component.Path) {
            try {
                Remove-Item -Path $component.Path -Recurse -Force -ErrorAction Stop
                Write-Output "Files removed successfully."
            }
            catch {
                Write-Warning "Failed to remove files: $_"
            }
        }

        # Remove component registry entries (if applicable)
        switch ($component.Type) {
            "Hosting Bundle" {
                $hostingBundleKey = Get-ChildItem "HKLM:\SOFTWARE\dotnet\Setup\InstalledHostingBundles" -Recurse |
                                    Where-Object { $_.GetValue("Version") -eq $component.Version }
                if ($hostingBundleKey) {
                    try {
                        $hostingBundleKey.RemoveFromRegistry()
                        Write-Output "Registry entries removed successfully."
                    }
                    catch {
                        Write-Warning "Failed to remove registry entries: $_"
                    }
                }
            }
            "ASP.NET Core Runtime" {
                $aspNetCoreKey = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Updates\.NETCore" -Recurse |
                                 Where-Object { "{0}.{1}" -f $_.GetValue("VersionMajor"), $_.GetValue("VersionMinor") -eq $component.Version }
                if ($aspNetCoreKey) {
                    try {
                        $aspNetCoreKey.RemoveFromRegistry()
                        Write-Output "Registry entries removed successfully."
                    }
                    catch {
                        Write-Warning "Failed to remove registry entries: $_"
                    }
                }
            }
            ".NET Framework" {
                # .NET Framework uninstallation is not handled in this script
                Write-Warning "Uninstallation of .NET Framework is not supported in this script."
            }
            "Desktop Runtime" {
                # .NET Desktop Runtime uninstallation is not handled in this script
                Write-Warning "Uninstallation of .NET Desktop Runtime is not supported in this script."
            }
        }
    }
}

# Main script
$componentsToUninstall = Select-ComponentsToUninstall
if ($componentsToUninstall) {
    $confirmation = Read-Host "Are you sure you want to uninstall the selected components? (Y/N)"
    if ($confirmation.ToLower() -eq 'y') {
        Uninstall-Components $componentsToUninstall
    }
    else {
        Write-Output "Uninstallation canceled."
    }
}
else {
    Write-Output "No components selected for uninstallation."
}
