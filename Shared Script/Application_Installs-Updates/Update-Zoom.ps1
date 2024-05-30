$Uri = "https://cdn.zoom.us/prod/6.0.10.39647/x64/ZoomInstallerFull.msi"
$InstallerName = [System.IO.Path]::GetFileName($Uri)
$InstallerPath = "$env:TEMP\$InstallerName"
$installTest = Test-Path -Path "C:\Program Files\Zoom\bin\Zoom.exe"
$CurrVers = $null
$NewVers = $null

# Check registry if chrome keys are present
if($installTest -eq $false){
   Write-Host "Zoom is not installed, exiting..."
   exit 0
}else{
   $CurrVers = (Get-Item -Path "C:\Program Files\Zoom\bin\Zoom.exe").VersionInfo.ProductVersion
# Download the latest Zoom .msi
Invoke-WebRequest -Uri $Uri -OutFile $InstallerPath
# Install Zoom .msi
msiexec.exe /i $InstallerPath /quiet /qn /norestart ZoomAutoUpdate=1
# Pause while Installer runs
Start-Sleep 60
$NewVers = (Get-Item -Path "C:\Program Files\Zoom\bin\Zoom.exe").VersionInfo.ProductVersion
Write-Host "Zoom has been updated from $CurrVers to $NewVers"
# Clean up
Remove-Item -Path $InstallerPath -ErrorAction SilentlyContinue
}