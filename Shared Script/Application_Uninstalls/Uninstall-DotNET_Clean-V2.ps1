# Remove all donet componants
Set-Location "C:\Program Files (x86)\dotnet-core-uninstall\"
<<<<<<< HEAD
=======
$Version = "{[.NET_Version_Number]}"
>>>>>>> 62d4e333c13ff2fc7d71d823793443281abf4b9f
$Arguments = @("remove --all --aspnet-runtime  --force --yes", 
            "remove --all --hosting-bundle  --force --yes", 
            "remove --all --runtime  --force --yes", 
            "remove --all --sdk  --force --yes")

foreach ($Argument in $Arguments) {
    Write-Host "Now uninstalling  "$Argument.Substring(13)""
    Start-Process dotnet-core-uninstall.exe $Argument
}

foreach ($version in $removeSDKs) {
    if (Test-Path $installPath) {
        Write-Host "Removing .NET SDK $version at C:\Program Files\dotnet\sdk\$version" 
        Remove-Item $installPath -Recurse -Force -ErrorAction SilentlyContinue
      }
}

