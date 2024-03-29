$Uri = "http://https://download-installer.cdn.mozilla.net/pub/firefox/releases/123.0/win64/en-GB/Firefox%20Setup%20123.0.msi"
$FilePath =  "C:\IT\mozilla_firefox\"
$MSIName = "mozialla-firefox.msi"
$MSIPath = "$FilePath$MSIName"
$IsInstalled = $null
$RegTest = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe'

# Check registry if chrome keys are present
if($RegTest -eq $false){
   Write-Host "Firefox is not installed, exiting..."
   exit 0
}else{
# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $MSIPath
Do {
    Start-Sleep -Seconds 5
    $downloadStatus = Get-Item $MSIPath
} While ($downloadStatus.Length -lt $downloadStatus.Length)


# Install .msi
msiexec.exe /i $MSIPath /qn /norestart

# Clean up
Remove-Item -Path $FilePath -Recurse -ErrorAction SilentlyContinue
}