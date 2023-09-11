$Uri = "https://github.com/fbarker92/westspring/raw/main/Speedtest/speedtest.exe"
$FilePath =  "C:\IT\Speedtest\"
$ExePath = "C:\IT\Speedtest\speedtest.exe"

If (Test-Path $FilePath) {
    Invoke-WebRequest -Uri $Uri -OutFile $ExePath
    & $ExePath
} else {
    New-Item -ItemType Directory -Path $FilePath -Force
    Invoke-WebRequest -Uri $Uri -OutFile $ExePath
    & $ExePath
}

Remove-Item -Path $FilePath -Recurse