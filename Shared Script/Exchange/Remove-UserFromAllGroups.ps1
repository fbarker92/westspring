$User = Read-Host "Enter the users full email address (e.g. user@domain.tld)"
$Date = get-Date -Format "yyyy-MM-dd-HH_mm_ss"
$csv = "$user-$date.csv"
$outputObjects = @()

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
    try {$isDynamic = [System.Convert]::ToBoolean($groupDetails.MembershipRule) } catch [FormatException] {$isDynamic = $false}
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
        Dynamic     = $isDynamic
        Mail        = $groupDetails.Mail
    } 
    $outputObjects += $output
}

ForEach ($group in $EXOUnifiedGroups) {
    $groupDetails = Get-UnifiedGroup -Identity $group.Identity
    $groupMembers = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members | Where-Object {$_.PrimarySmtpAddress -eq $user}
    Try {$isDirSynced = [System.Convert]::ToBoolean($groupDetails.IsDirSynced) } catch [FormatException] {$dirSynced = $false}
    Try {$isDynamic = [System.Convert]::ToBoolean($groupDetails.MembershipRule) } catch [FormatException] {$isDynamic = $false}
    Try {$isMember = [System.Convert]::ToBoolean($groupMembers.PrimarySmtpAddress -contains $User) } catch [FormatException] {$isMember = $false}
    Try {$isMailEnabled = [System.Convert]::ToBoolean($groupDetails.PrimarySmtpAddress) } catch [FormatException] {$isMailEnabled = $false}

    If ($true -eq ($dirSynced -or $isDynamic)) {
        Write-Host "$($groupDetails.DisplayName) is a dynamic group or synced from on prem, please remove user manually" -BackgroundColor Yellow
    } elseif ($true -eq $isMember) {
        Write-Host "Removing $User from group: $($groupDetails.DisplayName)" -BackgroundColor Green
        #Remove-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -Links $User
    }
    $output = [PSCustomObject]@{
        DisplayName = $group.DisplayName
        Id          = $group.Id
        MailEnabled = $isMailEnabled
        DirSynced   = $isDirSynced
        Dynamic     = $isDynamic
        Mail        = $group.PrimarySmtpAddress
    } 
    $outputObjects += $output
}

ForEach ($group in $EXODLGroups) {
    $groupDetails = Get-DistributionGroup -Identity $group.Identity
    $groupMembers = Get-DistributionGroupMember -Identity $group.Identity | Where-Object {$_.PrimarySmtpAddress -eq $user}
    Try {$isDirSynced = [System.Convert]::ToBoolean($groupDetails.IsDirSynced) } catch [FormatException] {$dirSynced = $false}
    Try {$isDynamic = [System.Convert]::ToBoolean($groupDetails.MembershipRule) } catch [FormatException] {$isDynamic = $false}
    Try {$isMember = [System.Convert]::ToBoolean($groupMembers.PrimarySmtpAddress -contains $User) } catch [FormatException] {$isMember = $false}
    Try {$isMailEnabled = [System.Convert]::ToBoolean($groupDetails.PrimarySmtpAddress) } catch [FormatException] {$isMailEnabled = $false}

    If ($true -eq ($dirSynced -or $isDynamic)) {
        Write-Host "$($groupDetails.DisplayName) is a dynamic group or synced from on prem, please remove user manually" -ForegroundColor Yellow
    } elseif ($true -eq $isMember) {
        Write-Host "Removing $User from group: $($groupDetails.DisplayName)" -ForegroundColor Green
        #Remove-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -Links $User
    }
    $output = [PSCustomObject]@{
        DisplayName = $group.DisplayName
        Id          = $group.Id
        MailEnabled = $isMailEnabled
        DirSynced   = $isDirSynced
        Dynamic     = $isDynamic
        Mail        = $group.PrimarySmtpAddress
    } 
    $outputObjects += $output
}

ForEach ($group in $EXODynamicDLGroups) {
    $groupDetails = Get-DynamicDistributionGroup -Identity $group.Identity
    $groupMembers = Get-DynamicDistributionGroupMember -Identity $group.Identity | Where-Object {$_.PrimarySmtpAddress -eq $user}
    Try {$isDirSynced = [System.Convert]::ToBoolean($groupDetails.IsDirSynced) } catch [FormatException] {$dirSynced = $false}
    Try {$isDynamic = [System.Convert]::ToBoolean($groupDetails.RecipientFilter) } catch [FormatException] {$isDynamic = $false}
    Try {$isMember = [System.Convert]::ToBoolean($groupMembers.PrimarySmtpAddress -contains $User) } catch [FormatException] {$isMember = $false}
    Try {$isMailEnabled = [System.Convert]::ToBoolean($groupDetails.PrimarySmtpAddress) } catch [FormatException] {$isMailEnabled = $false}

    If ($true -eq ($dirSynced -or $isDynamic)) {
        Write-Host "$($groupDetails.DisplayName) is a dynamic group or synced from on prem, please remove user manually" -ForegroundColor Yellow
    } elseif ($true -eq $isMember) {
        Write-Host "Removing $User from group: $($groupDetails.DisplayName)" -ForegroundColor Green
        #Remove-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -Links $User
    }
    $output = [PSCustomObject]@{
        DisplayName = $group.DisplayName
        Id          = $group.Id
        MailEnabled = $isMailEnabled
        DirSynced   = $isDirSynced
        Dynamic     = $isDynamic
        Mail        = $group.PrimarySmtpAddress
    } 
    $outputObjects += $output
}

$outputObjects | Sort-Object Mail -Unique | Export-Csv -Path ./$csv -NoTypeInformation