$Uri = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
$FilePath =  "C:\IT\Google_Chrome\"
$MSIName = "google-chrome.msi"
$MSIPath = "$FilePath$MSIName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Close Communicator if it is running
$appRunning = get-process | Where-Object {$_.Name -like "chrome"}
If (!($appRuningn.Name -ne $null)){
    Stop-Process -Name $appRunning.Name -Force
}

# Download the latest Communicator .msi
Invoke-WebRequest -Uri $Uri -OutFile $MSIPath

# Install communicator .msi
msiexec.exe /i $MSIPath /qn /norestart

# Start running the chrome application
Start-Process chrome 

