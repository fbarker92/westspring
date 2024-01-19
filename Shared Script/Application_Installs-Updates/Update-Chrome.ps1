$Uri = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
$FilePath =  "C:\IT\Google_Chrome\"
$MSIName = "google-chrome.msi"
$MSIPath = "$FilePath$MSIName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $MSIPath

# Install Chrome .msi
msiexec.exe /i $MSIPath /qn /norestart

# Clean up
Remove-Item -Path $FilePath -Recurse -ErrorAction SilentlyContinue
