$BingKey = "Au6p1Z3k6CYZZ6zgAJnTKa5mCQTIlfQS2imNze6ocEWUJV-vIuepawH8BvHh_ukB"
$IPInfo = Invoke-RestMethod http://ipinfo.io/json
$Location = $IPInfo.loc
$BingTimeZoneURL = “http://dev.virtualearth.net/REST/v1/TimeZone/$Location” + “?key=$BingKey”

$ResultTZ = Invoke-RestMethod $BingTimeZoneURL

$WindowsTZ = $ResultTZ.resourceSets.resources.timeZone.windowsTimeZoneId

If (![string]::IsNullOrEmpty($WindowsTZ)){
Get-TimeZone -Name $WindowsTZ
Set-TimeZone -Name $WindowsTZ
}

w32tm /config /update /manualpeerlist:1.uk.pool.ntp.org /syncfromflags:manual /reliable:yes 
w32tm /resync /rediscover
Start-Service w32time