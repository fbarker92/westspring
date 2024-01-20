$Uri = "https://download.visualstudio.microsoft.com/download/pr/cb56b18a-e2a6-4f24-be1d-fc4f023c9cc8/be3822e20b990cf180bb94ea8fbc42fe/dotnet-sdk-8.0.101-win-x64.exe"
$DirPath =  "C:\IT\.NET_Latest\"
$InstallerName = "DotNet_SDK_Latest.exe"
$InstallerPath = "$DirPath$InstallerName"
$ArgList = '/install /quiet /norestart'
#$start_time = Get-Date
$maxRetries = 3
$retries = 0 

# Validate Uri
if (-not [uri]::IsWellFormedUriString($Uri, [System.UriKind]::Absolute)) {
    Write-Error "Invalid URL $Uri"
    exit 1 
  }

# Create detination directory if it doesn't already exist
If (!(Test-Path $DirPath)) {
    Write-Host "Creating the following directory - $DirPath" -ForegroundColor Green
    New-Item -ItemType Directory -Path $DirPath -Force
}

# Download the .NET SDK .exe
do {
    try {
      Invoke-WebRequest -Uri $Uri -OutFile $InstallerPath
      break
    }
    catch {
      $retries++
      if ($retries -ge $maxRetries) {
        throw "Download failed after $maxRetries retries."
      }
      else {
        Write-Warning "Download failed, retrying..." 
        Start-Sleep -Seconds 5 
      }
    }
  } while ($true)
  
  if (Test-Path $InstallerPath) {
    Write-Host "Download succeeded."
  }
<# Invoke-RestMethod -Uri $Uri -OutFile $InstallerPath
"Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
Invoke-WebRequest -Uri $Uri -OutFile $InstallerPath;
If ((Test-Path $InstallerPath)) {
    Write-Host "The fileile, $InstallerName, Successfully downloaded" -ForegroundColor Green
} else {
    Write-Host "the File download failed, please try again" -ForegroundColor Red
    Exit
} #>

# Install .NET SDK .exe
Start-Process -FilePath $InstallerPath -ArgumentList $ArgList

# Clean up
Remove-Item -Path $DirPath -Recurse -ErrorAction SilentlyContinue
If (!(Test-Path $InstallerPath)) {
    Write-Host "Installation files successfully removed"
}
