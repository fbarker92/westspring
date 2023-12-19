$StartDate = ((Get-Date).AddDays(-90)).Date
$EndDate = (Get-Date).Date
$PageNum = 0
$ExportPath = "\UnifiedAuditLogs.csv"
$AuditOutput = @()

Param (
    [Parameter(Mandatory = $true)]
    [switch]$Admin,
    [Switch]$User,
    [switch]$ExportPath
)


############################################################################################

$PageNum = $PageNum + 1
Write-Host "Exporting Audit Logs - Page $PageNum"
$AuditResults = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -UserIds $UserID -ResultSize 5000 -Formatted -SessionCommand ReturnLargeSet
$AuditOutput | Export-Csv -Path $ExportPath -Append -NoTypeInformation

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
    $ExportResults | Select-Object 'Activity Time','User Name','Operation','Result','Workload','More Info' | Export-Csv -Path $ExportPath -Notype -Append 
}
