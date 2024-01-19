# Remove all donet componants
CD "C:\Program Files (x86)\dotnet-core-uninstall\"
$Arguments = @("remove --all --aspnet-runtime  --force --yes", 
            "remove --all --hosting-bundle  --force --yes", 
            "remove --all --runtime  --force --yes", 
            "remove --all --sdk  --force --yes")

foreach ($Argument in $Arguments) {
    Write-Host $Argument
    Write-Host "Now uninstalling  "$Argument.Substring(13)""
    #Start-Process dotnet-core-uninstall.exe $Argument
}


