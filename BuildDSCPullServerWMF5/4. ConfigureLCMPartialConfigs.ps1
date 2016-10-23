[DSCLocalConfigurationManager()]
configuration PartialConfigPull
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30 
            RebootNodeIfNeeded = $true
            ConfigurationID = 'a6546088-c6d0-4c8e-ad12-2723a6b1c2cd'
         
        }
        ConfigurationRepositoryWeb DSC-Pull
        {
            ServerURL = 'https://DSC-Pull:8080/PSDSCPullServer.svc'
            RegistrationKey = '30193897-7283-4915-ba46-486e039305c4'    

        }
        
        PartialConfiguration Base
        {
            Description = 'BaseOS'
            ConfigurationSource = '[ConfigurationRepositoryWeb]DSC-Pull'
            RefreshMode = 'Pull'
            
        }
           PartialConfiguration Extra
        {
            Description = 'ExtraOS'
            ConfigurationSource = '[ConfigurationRepositoryWeb]DSC-Pull'
            DependsOn = '[PartialConfiguration]Base'
            RefreshMode = 'Pull'
           
        }
              
    }
}
PartialConfigPull
Set-DSCLocalConfigurationManager localhost –Path .\PartialConfigPull –Verbose -Force