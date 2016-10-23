$WorkingDir = $psISE.CurrentFile.FullPath | Split-Path
    Set-Location $WorkingDir
    $DSCPublish = @{
    ResourceGroupName = 'DSCConfigs'
    ConfigurationPath = "$workingdir\configuremachine.ps1"
    StorageAccountName = 'dscconfigurations'
    ConfigurationDataPath = "$workingdir\configuremachine.psd1"
 
}
 
Publish-AzureRmVMDscConfiguration @DSCPublish -Force -Verbose