$Uri = "https://cloudcall.com/wp-content/uploads/2022/11/Communicator_6.5.5.2_113417-1.msi_.zip"
$FilePath =  "C:\IT\Cloudcall_Communicator\"
$ZIPName = "Communicator.zip"
$ZIPPath = "$FilePath$ZIPName"


If (!(Test-Path $FilePath)) {
    New-Item -ItemType Directory -Path $FilePath -Force
}

Invoke-WebRequest -Uri $Uri -OutFile $ZIPPath
Expand-Archive -Path $ZIPPath -DestinationPath $FilePath 
$msi = Get-ChildItem -Path $FilePath | Where-Object {$_.Name -like "*.msi"}
$msi = $msi.Name
msiexec.exe /i "$FilePath$msi" /qn