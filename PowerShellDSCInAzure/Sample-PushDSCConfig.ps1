$NodeName = 'DSC-Push'
$RG = Get-AzureRmResourceGroup -Name DSC
$DSCRG = Get-AzureRmResourceGroup -Name DSCConfigs
$StorageAccountName = 'dscconfigurations'
$Location = 'westeurope'
 
$Node = $RG | Get-AzureRmVM -Name $NodeName
 
$DSCExtensionArgs = @{
    ResourceGroupName = $RG.ResourceGroupName
    VMName = $Node.Name
    ArchiveBlobName = 'ConfigureMachine.ps1.zip'
    ArchiveStorageAccountName = $DSCStorageAccount.StorageAccountName
    ArchiveResourceGroupName = $DSCRG.ResourceGroupName
    ArchiveContainerName = 'windows-powershell-dsc'
    ConfigurationName = 'configuremachine'
    ConfigurationData = 'configuremachine.psd1'
    WmfVersion = 'latest'
    Version = '2.15' #https://blogs.msdn.microsoft.com/powershell/2014/11/20/release-history-for-the-azure-dsc-extension/
    Autoupdate = $true
}
 
Set-AzureRmVMDscExtension @DSCExtensionArgs -Force -Verbose