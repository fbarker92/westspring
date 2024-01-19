$Uri1 = "https://www.eposaudio.com/globalassets/___image-library/_enterprise/files/english/epos-connect/epos-connect-7.7.0/epos_connect_for_win_msi_7.7.0.44457.7z"
$FilePath =  "C:\IT\EPOS Connect\"
$ZIPName = "Communicator.zip"
$ZIPPath = "$FilePath$ZIPName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Close Communicator if it is running
$appRunning = get-process | Where-Object {$_.Name -like "Communicator"}
If (!($appRuningn.Name -ne $null)){
    Stop-Process -Name $appRunning.Name -Force
}

# Unisntall current Communicator app
$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'Communicator'"
& msiexec /x $app.IdentifyingNumber /norestart /qn

# Download the latest Communicator .msi
Invoke-WebRequest -Uri $Uri -OutFile $ZIPPath

# Expand the .zip archive that was downloaded.
Expand-Archive -Path $ZIPPath -DestinationPath $FilePath 
$msi = Get-ChildItem -Path $FilePath | Where-Object {$_.Name -like "*.msi"}
$msi = $msi.Name

# Install communicator .msi
msiexec.exe /i "$FilePath$msi" /qn /norestart