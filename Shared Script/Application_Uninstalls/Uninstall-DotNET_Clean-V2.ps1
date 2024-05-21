# Remove all donet componants
Set-Location "C:\Program Files (x86)\dotnet-core-uninstall\"
$BaseDir = "C:\Program Files\dotnet\shared"
$Vers = "4.6.2"
$Args = @("remove --all-below $Vers --aspnet-runtime --force --yes", 
               "remove --all-below $Vers --hosting-bundle --force --yes", 
               "remove --all-below $Vers --runtime --force --yes", 
               "remove --all-below $Vers --sdk --force --yes")

foreach ($Arg in $Args) {
    Write-Host "Now uninstalling"$Arg.Substring(13)""
    Start-Process dotnet-core-uninstall.exe $Argument
}