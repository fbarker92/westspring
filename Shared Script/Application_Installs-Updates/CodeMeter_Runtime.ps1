$Uri = "https://www.wibu.com/support/user/user-software/file/download/12529.html?tx_wibudownloads_downloadlist%5BdirectDownload%5D=directDownload&tx_wibudownloads_downloadlist%5BuseAwsS3%5D=0&cHash=8dba7ab094dec6267346f04fce2a2bcd"
$FilePath =  "C:\IT\CodeMeter_Runtime\"
$MSIName = "codemter-runtime.exe"
$MSIPath = "$FilePath$MSIName"

# Create detination directory if it doesn't already exist
If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

# Download the latest Chrome .msi
Invoke-WebRequest -Uri $Uri -OutFile $MSIPath

# Install Chrome .msi
msiexec.exe /i $MSIPath /qn /norestart
Start-Process -FilePath $MSIPath -ArgumentList

# Clean up
Remove-Item -Path $FilePath -Recurse -ErrorAction SilentlyContinue



$username = "wsadmin"
$password = "L0cal01!"
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
$InvokeArgs = "$MSIPath /ComponentArgs *:/qn"
Invoke-Command -ScriptBlock {$InvokeArgs}
Start-Process -FilePath $MSIPath -ArgumentList $InvokeArgs -Credential $credentials

start-pr