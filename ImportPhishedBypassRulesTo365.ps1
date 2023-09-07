$Uri = 'https://raw.githubusercontent.com/fbarker92/westspring/main/PhishedMailfloWRulesTemplate.xml?token=GHSAT0AAAAAACGIXGKUCSOH24GEDQ7JKHEMZHZPJYQ'
$PhishedMailflowRule = "C:\TMP\PhishedMailflowRules.xml"
Invoke-WebRequest -ContentType 'application/xml' -Uri $Uri -OutFile $PhishedMailflowRule

# Set variable
$365GA = Read-Host "Enter the UPN for a Global Administrator"
$PhishedIPs = "143.55.236.228,143.55.236.227,143.140.69.192,34.140.69.192,34.22.133.124"
$PhishedDomains = "psr.phished.io,phished.io"
$ClientSecurityHeader = Read-Host "Enter the Client Security Header (Found in the phished portal)"

#Import Exchange Online Management Module
Import-Module ExchangeOnlineManagement

#Connect to the Exchange Online Management Module 
Connect-IPPSSession -UserPrincipalName $365GA

# Check if there is a pre-existing PhishSimOverridePolicy to use, will create one if not
If ((Get-PhishSimOverridePolicy).count -ne 0) {
    $PhishSimOverridePolicyName = Get-PhishSimOverridePolicy | Select-Object Name
    #$PhishSimOverrideRule = Get-PhishSimOverrideRule | Select Name
    New-PhishSimOverrideRule -Name 'Phished' -Policy $PhishSimOverridePolicyName -Domains $PhishedDomains -SenderIpRanges $PhishedIPs
} else {
    New-PhishSimOverridePolicy -Name PhishSimOverridePolicy
    New-PhishSimOverrideRule -Name 'Phished' -Policy PhishSimOverridePolicy -Domains $PhishedDomains -SenderIpRanges $PhishedIPs
}

Start-Sleep 5

# Import the Mailflow rules
[xml]$xml = Get-Content $PhishedMailflowRule
$rulesToImport = $xml.SelectNodes("//rules/rule")
if ($rulesToImport.Count -eq 0)
{
    Write-Host "There are no mail flow rules to be imported."
    return
}
Write-Host "Importing $($rulesToImport.Count) mail flow rules."
$index = 0
foreach ($rule in $rulesToImport)
{
    $index++
    Write-Host "Importing rule '$($rule.Name)' $index/$($rulesToImport.Count)."
    Invoke-Expression $($rule.version.commandBlock.InnerText) | Out-Null
}
