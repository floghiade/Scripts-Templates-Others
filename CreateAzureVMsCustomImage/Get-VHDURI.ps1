#requires -Version 1 -Modules Azure.Storage, AzureRM.Storage
$ResourceGroupName = 'RGNName'
$StorageAccountName = 'SAName'
$ContainerName = 'ContainerName'
 
 
$StorageContainer = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName | `
                    Get-AzureStorageContainer -Container $ContainerName -ErrorAction SilentlyContinue
 
(Get-AzureStorageBlob -Context $StorageContainer.Context -Container $ContainerName).ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri