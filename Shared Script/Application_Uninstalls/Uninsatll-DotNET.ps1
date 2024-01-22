Param(
  [Parameter(Mandatory=$true)]
  [string]$RemoveBelowVersion
)

# .NET Framework versions
$dotnetFrameworks = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | Get-ItemProperty -name Version -EA 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} | Select-Object -ExpandProperty Version 

# .NET Core versions
$dotnetCores = Get-ChildItem "C:\Program Files\dotnet\shared" -Directory | Where-Object { $_.Name -match '^Microsoft\.NETCore\.App' } | ForEach-Object { $_.Name.Split('.')[2] } 

# .NET SDK versions
$dotnetSDKS = Get-ChildItem "C:\Program Files\dotnet\sdk" -Directory | Where-Object { $_.Name -match '^.\d+\.\d+\.\d+$' } | ForEach-Object { $_.Name }

# Filter to versions below specified
$removeFrameworks = $dotnetFrameworks | Where-Object { $_ -lt $RemoveBelowVersion }
$removeCores = $dotnetCores | Where-Object { [Version]$_ -lt [Version]$RemoveBelowVersion }  
$removeSDKs = $dotnetSDKS | Where-Object { [Version]$_ -lt $RemoveBelowVersion }

# Uninstall and remove .NET Frameworks
foreach ($version in $removeFrameworks) {
  Write-Host "Uninstalling .NET Framework $version"
  $installPath = "${env:windir}\Microsoft.NET\Framework\{0}" -f $version
  try {Start-Process -FilePath "$installPath\setup.exe" -ArgumentList "/uninstall /quiet /norestart" -Wait
  Write-Host "Removing $installPath"
  Remove-Item $installPath -Recurse -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Error "Uninstall failed for $installPath : $_"
    Write-Host "$($_.Exception.Message)"
}
}

# Uninstall and remove .NET Core runtimes
foreach ($version in $removeCores) {
  Write-Host "Uninstalling .NET Core $version"
  Start-Process -FilePath "dotnet-core-uninstall.exe" -ArgumentList "$version --silent" -Wait
  Write-Host "Removing C:\Program Files\dotnet\shared\Microsoft.NETCore.App\$version"
  Remove-Item "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\$version" -Recurse -Force -ErrorAction SilentlyContinue
} 

# Remove .NET SDK directories
foreach ($version in $removeSDKs) {
    if (Test-Path $installPath) {
        Write-Host "Removing .NET SDK $version at C:\Program Files\dotnet\sdk\$version" 
        Remove-Item $installPath -Recurse -Force -ErrorAction SilentlyContinue
      }
}

Write-Host "Done removing older .NET versions"