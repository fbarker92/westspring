$uri = "https://curl.se/windows/latest.cgi?p=win64-mingw.zip"
$BaseDir = "C:\Windows\System32"
$OutFile = "$env:TEMP\curl-latest.zip"
$CurrVers = (Get-Item -Path "$BaseDir\curl.exe").VersionInfo.ProductVersion
$Acl = Get-Acl -Path $BaseDir\curl.exe
$Account = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList 'BUILTIN\Administrators';
$TmpAcl = $Acl.SetOwner($Account)


Invoke-WebRequest -Uri $uri -OutFile $OutFile
If (Test-Path -Path $OutFile) {
    Write-Host "Expanding curl.zip..."
    Expand-Archive -Path $OutFile -DestinationPath "$env:TEMP\curl-latest"
} else {
    Write-Host "Download Failed. Exiting..."
    Exit 1
}

$LatestCurl = (Get-ChildItem -Path "$env:TEMP\curl-latest" -Recurse -Filter "curl.exe")
If ($LatestCurl.VersionInfo.ProductVersion -le $CurrVers) {
    Write-Host "Latest curl version is less than or equal to current version. Exiting..."
    Exit 1
} else {
    Write-Host "Latest curl version is greater than current version. Updating..."
    Set-Acl -Path $BaseDir\curl.exe -AclObject $TmpAcl
    Rename-Item -Path "$BaseDir\curl.exe" -NewName "curl-$CurrVers.exe" -Force
    Write-Host "Renaming curl.exe to curl-$CurrVers.exe"
    Write-Host "Copying curl.exe : $($LatestCurl.VersionInfo.ProductVersion) to $BaseDir "
    Copy-Item -Path $LatestCurl.FullName -Destination "$BaseDir\curl.exe" -Force
    $NewVers = (Get-Item -Path "$BaseDir\curl.exe").VersionInfo.ProductVersion
    Write-Host "Curl has been updated from $CurrVers to $NewVers"
    Set-Acl -Path $BaseDir\curl.exe -AclObject $Acl
}

Write-Host "Removing Temp Files..."
Remove-Item -Path "$env:TEMP\curl-latest.zip" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:TEMP\curl-latest\" -Recurse -Force -ErrorAction SilentlyContinue
If (((Test-Path -Path $OutFile) -or (Test-Path -Path "$env:TEMP\curl-latest")) -eq $true) {
    Write-Host "Failed to remove temp files. Please remove manually."
}