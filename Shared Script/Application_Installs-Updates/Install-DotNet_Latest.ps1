$Uri = "https://download.visualstudio.microsoft.com/download/pr/ab5e947d-3bfc-4948-94a1-847576d949d4/bb11039b70476a33d2023df6f8201ae2/dotnet-sdk-8.0.201-win-x64.exe"
$DirPath =  "C:\IT\.NET_Latest\"
$InstallerName = "DotNet_SDK_Latest.zip"
$InstallerPath = "$DirPath$InstallerName"
$ArgList = '/install /quiet /norestart'

# Create detination directory if it doesn't already exist
If (!(Test-Path $DirPath)) {
    Write-Host "Creating the following directory - $DirPath" -ForegroundColor Green
    New-Item -ItemType Directory -Path $DirPath -Force
}

# Download the .NET SDK .exe
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
If ((Test-Path $InstallerPath)) {
    Write-Host "The file, $InstallerName, Successfully downloaded" -ForegroundColor Green
} else {
    Write-Host "the File download failed, please try again" -ForegroundColor Red
    Exit 1
}

# Install .NET SDK .exe
Write-Host "Starting the installation of the.NET SDK" -ForegroundColor Green
Start-Process -FilePath $InstallerPath -ArgumentList $ArgList

# Pause script while install is in progress
Start-Sleep -Seconds 300

# Clean up
Remove-Item -Path $DirPath -Recurse -ErrorAction SilentlyContinue
If (!(Test-Path $InstallerPath)) {
    Write-Host "Installation files successfully removed" -ForegroundColor Green
}