$Uri = "https://download.visualstudio.microsoft.com/download/pr/ab5e947d-3bfc-4948-94a1-847576d949d4/bb11039b70476a33d2023df6f8201ae2/dotnet-sdk-8.0.201-win-x64.exe"
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