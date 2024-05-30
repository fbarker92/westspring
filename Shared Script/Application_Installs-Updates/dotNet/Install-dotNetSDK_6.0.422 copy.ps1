$Uri = "https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-aspnetcore-2.2.8-windows-x64-installer"
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