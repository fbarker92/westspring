$Uri = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
$InstallerDir =  "C:\IT\Installers\"
$InstallerName = "Teams.msi"
$InstallerPath = "$InstallerDir$InstallerName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $InstallerDir)) {New-Item -ItemType Directory -Path $InstallerDir -Force}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $InstallerPath
while ($isLocked) {
    Try {
        $stream = [System.IO.File]::Open($OutFile, 'Open', 'Write')
        $stream.Close()
        $stream.Dispose()
        $isLocked = $false
    }
    catch {
        Start-Sleep -Seconds 30
    }
}


# Install Chrome .msi
msiexec.exe /i $InstallerPath OPTIONS="noAutoStart=false" ALLUSERS=1

# Pause while Installer runs
Start-Sleep 20

# Clean up
Remove-Item -Path $InstallerPath -ErrorAction SilentlyContinue