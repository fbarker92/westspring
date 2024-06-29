$User = Read-Host "Enter the users full email address (e.g. user@domain.tld)"
$Date = get-Date -Format "yyyy-MM-dd-HH_mm_ss"

If (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Installing Microsoft.Graph module"
    Install-Module -Name Microsoft.Graph -Force
}
If (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Installing Microsoft.Graph module"
    Install-Module -Name ExchangeOnlineManagement -Force
}

Write-Host "Connecting to Microsoft Graph and Exchange Online"
Connect-MgGraph
Connect-ExchangeOnline

$MGmemberOf = Get-MgUserMemberOf -UserId $User 
$EXOUnifiedGroups = Get-UnifiedGroup -ResultSize Unlimited
$EXODLGroups = Get-DistributionGroup -ResultSize Unlimited
$EXODynamicDLGroups = Get-DynamicDistributionGroup -ResultSize Unlimited

foreach ($group in $MGmemberOf) {
    $groupDetails = Get-MgGroup -GroupId $group.Id
    $isMember = Get-MgGroupMemberAsUser -GroupId $group.Id | Select-Object PrimarySmtpAddress
    If ($null -ne $isMember) {
        If ($null -eq (Get-MgGroup -GroupId $group.Id).OnpremisesDomainName) {
            Write-Host "Removing $User from group:  $($groupDetails.DisplayName)"
            #Remove-MgGroupMember -GroupId $group.Id -MemberId $User
        }
        else {
            Write-Host "Group $($groupDetails.DisplayName) is managed on prem, please remove user manually from the $($groupDetails.OnpremisesDomainName) Domain"
        }
    }
    $output = [PSCustomObject]@{
        DisplayName = $groupDetails.DisplayName
        Id          = $group.Id
        MailEnabled = $groupDetails.MailEnabled
        Mail        = $groupDetails.Mail
    } 
    #$output | Export-Csv -Path .\$User-$Date-Groups.csv -Append -NoTypeInformation
}

ForEach ($group in $EXOUnifiedGroups) {
    $groupDetails = Get-UnifiedGroup -Identity $group.Identity
    $isMember = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members | Where-Object { $_.PrimarySmtpAddress -eq $User }
    If ($null -ne $isMember) {
        Write-Host "Removing $User from group: $($groupDetails.DisplayName)"
        #Remove-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -Links $User
    }
    $output = [PSCustomObject]@{
        DisplayName = $group.DisplayName
        Id          = $group.Id
        MailEnabled = $true
        Mail        = $group.PrimarySmtpAddress
    } 
    #$output | Export-Csv -Path .\$User-$Date-Groups.csv -Append -NoTypeInformation
}

ForEach ($group in $EXODLGroups) {
    $isMember = Get-DistributionGroupMember -Identity $group.Identity | Where-Object { $_.PrimarySmtpAddress -eq $User }
    IF ($null -ne $isMember) {
        Write-Host "Removing $User from group: " $(Get-DistributionGroup -Identity $group.Identity).DisplayName
        #Remove-DistributionGroupMember -Identity $group.Identity -Member $User
    }
    $output = [PSCustomObject]@{
        DisplayName = $group.DisplayName
        Id          = $group.Id
        MailEnabled = $true
        Mail        = $group.PrimarySmtpAddress
    } 
    #$output | Export-Csv -Path .\$User-$Date-Groups.csv -Append -NoTypeInformation
}

ForEach ($group in $EXODynamicDLGroups) {
    $isMember = Get-Recipient -RecipientPreviewFilter (Get-DynamicDistributionGroup -Identity $group.PrimarySmtpAddress).RecipientFilter | Where-Object { $_.PrimarySmtpAddress -eq $User }
    IF ($null -ne $isMember) {
        Write-Host "$User is a member of:  $($(Get-DistributionGroup -Identity $group.Identity).DisplayName), please evaluate the membership condidtions and remove the user manually."
    }
    $output = [PSCustomObject]@{
        DisplayName = $group.DisplayName
        Id          = $group.Id
        MailEnabled = $true
        Mail        = $group.PrimarySmtpAddress
    } 
    #$output | Export-Csv -Path .\$User-$Date-Groups.csv -Append -NoTypeInformation
}
