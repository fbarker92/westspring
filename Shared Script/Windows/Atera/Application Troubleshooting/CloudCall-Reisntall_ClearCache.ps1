$Uri = "https://cloudcall.com/wp-content/uploads/2024/06/cloudcall-setup-1.64.103.260.zip"
$FilePath =  "C:\IT\Cloudcall_Communicator\"
$ZIPName = "Communicator.zip"
$ZIPPath = "$FilePath$ZIPName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Close Communicator if it is running
$appRunning = get-process | Where-Object {$_.ProcessName -like "*cloud*call*"}
If ($null -ne $appRunning.ProcessName){
    Stop-Process -Name $appRunning.ProcessName -Force
}

# Unisntall current Communicator app
$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'CloudCall'"
& msiexec /x $app.IdentifyingNumber /norestart /qn

# Clearing cache and local files
Write-Host "Clearing cache and local files in:"
Write-Host "AppData\Roaming\"
Remove-item -Path "C:\Users\*\AppData\Roaming\CloudCall" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "AppData\Local\"
Remove-item -Path "C:\Users\*\AppData\Local\CloudCall" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "AppData\LocalLow\"
Remove-item -Path "C:\Users\*\AppData\LocalLow\CloudCall" -Recurse -Force -ErrorAction SilentlyContinue

# Clearing Reg Keys

New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
Remove-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" -Name "*cloudcall*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKU:\*\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched" -Name "*cloudcall*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKU:\*\Software\Microsoft\Windows\CurrentVersion\UFH\SHC" -Name "*cloudcall*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKU:\*\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" -Name "*cloudcall*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" -Name "*cloudcall*" -ErrorAction SilentlyContinue

# Clear browser extension cache

# Download the latest Communicator .msi
Invoke-WebRequest -Uri $Uri -OutFile $ZIPPath

# Expand the .zip archive that was downloaded.
Expand-Archive -Path $ZIPPath -DestinationPath $FilePath -Force
$msi = Get-ChildItem -Path $FilePath | Where-Object {$_.Name -like "*.msi"}
$msi = $msi.Name

# Install communicator .msi
msiexec.exe /i "$FilePath$msi" /qn /norestart

Start-Sleep -Seconds 60

# Script Clean up
Remove-Item -Path $ZIPPath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue