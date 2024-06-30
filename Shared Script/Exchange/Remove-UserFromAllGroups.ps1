$User = Read-Host "Enter the users full email address (e.g. user@domain.tld)"
$Date = get-Date -Format "yyyy-MM-dd-HH_mm_ss"
$csv = "$user-Group_Membership-$date.csv"
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

$MGGroups = Get-MgGroup -All -Filter
$EXOUnifiedGroups = Get-UnifiedGroup -ResultSize Unlimited
$EXODLGroups = Get-DistributionGroup -ResultSize Unlimited
$EXODynamicDLGroups = Get-DynamicDistributionGroup -ResultSize Unlimited

foreach ($group in $MGGroups) {
    $groupDetails = Get-MgGroup -GroupId $group.Id
    $groupMembers = Get-MgGroupMemberAsUser -GroupId $group.Id | Select-Object UserPrincipalName
    Try {$isDirSynced = [System.Convert]::ToBoolean($groupDetails.OnPremisesSyncEnabled) } catch [FormatException] {$dirSynced = $false}
    Try {$isDynamic = [System.Convert]::ToBoolean($null -ne $groupDetails.MembershipRule) } catch [FormatException] {$isDynamic = $false}
    Try {$isMember = [System.Convert]::ToBoolean($groupMembers.UserPrincipalName -contains $User) } catch [FormatException] {$isMember = $false}
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

ForEach ($group in $EXOUnifiedGroups) {
    $groupDetails = Get-UnifiedGroup -Identity $group.Identity
    $groupMembers = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members | Where-Object {$_.PrimarySmtpAddress -eq $user}
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
    Try {$isDynamic = [System.Convert]::ToBoolean($null -ne $groupDetails.RecipientFilter) } catch [FormatException] {$isDynamic = $false}
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

$exportObjects = $outputObjects | Sort-Object Mail -Unique
ForEach ($exportObject in $exportObjects) {
    If ($true -eq ($exportObject.DirSynced -or $exportObject.Dynamic)) {
        Write-Host "$($exportObject.DisplayName) is a dynamic group or synced from on prem, please remove user manually" -ForegroundColor Yellow
    } elseif ($null -ne $outputObject) {
        Write-Host "Removing $User from group: $($exportObject.DisplayName)" -ForegroundColor Green
    }
}
$exportObjects | Export-Csv -Path ./$csv -NoTypeInformation