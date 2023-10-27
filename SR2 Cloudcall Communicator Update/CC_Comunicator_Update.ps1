$Uri = "https://cloudcall.com/wp-content/uploads/2022/11/Communicator_6.5.5.2_113417-1.msi_.zip"
$FilePath =  "C:\IT\Cloudcall_Communicator\"
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