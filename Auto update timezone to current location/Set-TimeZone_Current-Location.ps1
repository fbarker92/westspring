$BingKey = "Au6p1Z3k6CYZZ6zgAJnTKa5mCQTIlfQS2imNze6ocEWUJV-vIuepawH8BvHh_ukB"
$IPInfo = Invoke-RestMethod http://ipinfo.io/json
$Location = $IPInfo.loc

net start w32time

$BingTimeZoneURL = “http://dev.virtualearth.net/REST/v1/TimeZone/$Location” + “?key=$BingKey”

$ResultTZ = Invoke-RestMethod $BingTimeZoneURL

$WindowsTZ = $ResultTZ.resourceSets.resources.timeZone.windowsTimeZoneId

If (![string]::IsNullOrEmpty($WindowsTZ)){
Get-TimeZone -Name $WindowsTZ
Set-TimeZone -Name $WindowsTZ
}