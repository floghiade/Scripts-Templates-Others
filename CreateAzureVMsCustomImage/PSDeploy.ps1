1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
#requires -Version 1 -Modules Azure.Storage, AzureRM.Storage
$ResourceGroupName = 'RGNName'
$StorageAccountName = 'SAName'
$ContainerName = 'ContainerName'
 
$StorageContainer = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName | `
                    Get-AzureStorageContainer -Container $ContainerName -ErrorAction SilentlyContinue
 
$osDiskVhdUri = (Get-AzureStorageBlob -Context $StorageContainer.Context -Container $ContainerName).ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri
 
#Scenario 1:
 
$Parameters = @{
 
adminUserName = ''
adminPassword = ''
osDiskVhdUri = $osDiskVhdUri[0].ToString()
storageAccountName = ''
vmName = ''
dnsNameForPublicIP = ''
virtualNetworkName = ''
osType = ''
vmSize = ''
}
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName-TemplateFile '<pathtoJSONfile' -TemplateParameterObject $Parameters -Verbose
 
#Scenario 2:
 
$parameters = @{
 
adminUserName = ''
adminPassword = ''
vmName = ''
osType = ''
osDiskVhdUri = $osDiskVhdUri[0].ToString()
storageAccountName = ''
vmSize = ''
existingVirtualNetworkName = ''
subnetName = ''
dnsNameForPublicIP = ''
}
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile '<pathtoJSONfile' -TemplateParameterObject $Parameters -Verbose