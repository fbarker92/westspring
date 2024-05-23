$Uri = "https://nodejs.org/dist/v20.13.1/node-v20.13.1-x64.msi"
$OutFile = $Uri.Split('/')[-1]
$InstallDir = "C:\Program Files\nodejs\"
$Exe = "node.exe"

if ($CurrVers -lt "v20.13.1") {
    Write-Host "Node.js 20.12.1 or newer is already installed.." -ForegroundColor Yellow
        Exit 1
}

if (Test-Path $InstallDir) {
    Write-Host "Current Node Version: $CurrVers" -ForegroundColor Green

        Invoke-WebRequest -Uri $Uri -OutFile "$env:TEMP\$OutFile"
        if (Test-Path -Path $env:TEMP\$OutFile) {
            Write-Host "Download successful" -ForegroundColor Green
            Write-Host "Installing Node.js" -ForegroundColor Green
            msiexec.exe /i "$env:TEMP\$OutFile" /qn /norestart
            Write-Progress "Installing Node.js" -Status "Complete" -Completed
            #sleep 300
            $NewVers = (Get-Item $InstallDir$Exe).VersionInfo.ProductVersion
            Write-Host "New Node Version: $NewVers" -ForegroundColor Green
            Write-Host "Cleaning up..."
            Remove-Item "$env:TEMP\$OutFile" -Force -ErrorAction SilentlyContinue

        }
        else {
            Write-Host "Download failed, please try again" -ForegroundColor Red
        }
    } else {
        Write-Host "Node.js is not installed, exiting..." -ForegroundColor Yellow
        Exit 1
    }
