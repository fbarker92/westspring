# First we create the request.
$HTTP_Request1 = [System.Net.WebRequest]::Create('http://qagpublic.qg2.apps.qualys.eu/CloudAgent/')
$HTTP_Request2 = [System.Net.WebRequest]::Create('http://bing.com')



# We then get a response from the site.
$HTTP_Response1 = $HTTP_Request1.GetResponse()
$HTTP_Response2 = $HTTP_Request2.GetResponse()

# We then get the HTTP code as an integer.
$HTTP_Status1 = [int]$HTTP_Response1.StatusCode
$HTTP_Status2 = [int]$HTTP_Response2.StatusCode

If ($HTTP_Status1 -eq "true") {
    Write-Host "$($HTTP_Request1.Address.AbsoluteUri) is OK!" -ForegroundColor Green
}
Else {
    Write-Host "The Site may be down, please check!" -ForegroundColor Yellow
}
If ($HTTP_Status2 -eq "true") {
    Write-Host "$($HTTP_Request2.Address.AbsoluteUri) is OK!" -ForegroundColor Green
}
Else {
    Write-Host "The Site may be down, please check!" -ForegroundColor Yellow
}