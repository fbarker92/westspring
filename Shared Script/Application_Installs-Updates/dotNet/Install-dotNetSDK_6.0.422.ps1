$Uri = "https://download.visualstudio.microsoft.com/download/pr/47f095fd-7aa8-4def-82d0-57897cf32202/f063bf11d48ab31bb6f87a6d582a57a8/dotnet-sdk-6.0.422-win-x64.exe"
$InstallerName = $Uri.split("/")[-1]
$InstallerPath = "$env:TEMP\$InstallerName"
$ArgList = '/install /quiet /norestart'

# Download the .NET SDK .exe
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($Uri, $InstallerPath)

If ((Test-Path $InstallerPath)) {
    Write-Host "The file, $InstallerName, Successfully downloaded" -ForegroundColor Green
} else {
    Write-Host "the File download failed, please try again" -ForegroundColor Red
    Exit 1
}

# Install .NET SDK .exe
Write-Host "Starting the installation of $InstallerName" -ForegroundColor Green
Start-Process -FilePath $InstallerPath -ArgumentList $ArgList

# Pause script while install is in progress
Start-Sleep -Seconds 300

# Clean up
Remove-Item -Path $DirPath -Recurse -ErrorAction SilentlyContinue
If (!(Test-Path $InstallerPath)) {
    Write-Host "Installation files successfully removed" -ForegroundColor Green
}