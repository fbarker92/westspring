$StartDate = ((Get-Date).AddDays(-365)).Date
$EndDate = (Get-Date).Date
$PageNum = 0
$UserID = "accounts@tstcglobal.com"
$AuditOutput = @()

$PageNum = $PageNum + 1
Write-Host "Exporting Audit Logs - Page $PageNum"
$AuditResults = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -UserIds $UserID -ResultSize 5000 -Formatted -SessionCommand ReturnLargeSet
$AuditOutput | Export-Csv -Path "C:\Users\fergusbarker\OneDrive - WestSpring IT\Documents\TSTC\aaccounts@ account breach\unified_logs-NEW.csv" -Append -NoTypeInformation

foreach($AuditResult in $AuditResults) {
    $i++
    $MoreInfo=$Result.auditdata
    $AuditData=$Result.auditdata | ConvertFrom-Json
    $ActivityTime=Get-Date($AuditData.CreationTime) -format g
    $UserID=$AuditData.userId
    $Operation=$AuditData.Operation
    $ResultStatus=$AuditData.ResultStatus
    $Workload=$AuditData.Workload
  
    #Export result to csv
    $ExportResult=@{'Activity Time'=$ActivityTime;'User Name'=$UserID;'Operation'=$Operation;'Result'=$ResultStatus;'Workload'=$Workload;'More Info'=$MoreInfo}
    $ExportResults= New-Object PSObject -Property $ExportResult  
    $ExportResults | Select-Object 'Activity Time','User Name','Operation','Result','Workload','More Info' | Export-Csv -Path $OutputCSV -Notype -Append 
}





$StartDate = (Get-Date).Date
$EndDate = ((Get-Date).AddDays(-365)).Date

Connect-ExchangeOnline -UserPrincipalName
 $Results=Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -UserIds $UserID -SessionId s -SessionCommand ReturnLargeSet -ResultSize 5000
 $ResultCount=($Results | Measure-Object).count
 $AllAuditData=@()
 foreach($Result in $Results)
 {
  $i++
  $MoreInfo=$Result.auditdata
  $AuditData=$Result.auditdata | ConvertFrom-Json
  $ActivityTime=Get-Date($AuditData.CreationTime) -format g
  $UserID=$AuditData.userId
  $Operation=$AuditData.Operation
  $ResultStatus=$AuditData.ResultStatus
  $Workload=$AuditData.Workload

  #Export result to csv
  $ExportResult=@{'Activity Time'=$ActivityTime;'User Name'=$UserID;'Operation'=$Operation;'Result'=$ResultStatus;'Workload'=$Workload;'More Info'=$MoreInfo}
  $ExportResults= New-Object PSObject -Property $ExportResult  
  $ExportResults | Select-Object 'Activity Time','User Name','Operation','Result','Workload','More Info' | Export-Csv -Path $OutputCSV -Notype -Append 
 }