$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$result = Get-CimInstance -Namespace $namespaceName -Class $className | Invoke-CimMethod -MethodName UpdateScanMethodGet-AppxPackageAutoUpdateSettings