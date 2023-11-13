$Uri = "https://cdn.watchguard.com/SoftwareCenter/Files/MUVPN_SSL/12_10/WG-MVPN-SSL_12_10.exe"
$FilePath =  "C:\IT\Watchguard\"
$EXEName = "WG-MVPN-SSL_12_10.exe"
$EXEPath =  "$FilePath$EXEName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Close WGSSSLVPN if it is running
$appRunning = get-process | Where-Object {$_.Name -like "wgsslvpnc"}
If (!($appRunning.Name -ne $null)){
    Stop-Process -Name $appRunning.Name -Force
}

# Download the latest WG MVPN SSL
Invoke-WebRequest -Uri $Uri -OutFile $EXEPath

# Install WG MVPN SSL
Start-Process -FilePath $EXEPath