[DSCLocalConfigurationManager()]
configuration PullClient
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30 
            RebootNodeIfNeeded = $true
            ConfigurationMode = 'ApplyAndAutoCorrect'
            ConfigurationModeFrequencyMins = 15
        }
        ConfigurationRepositoryWeb DSC-Pull
        {
            ServerURL = 'https://DSC-Pull:8080/PSDSCPullServer.svc'
            RegistrationKey = '30193897-7283-4915-ba46-486e039305c4'
            ConfigurationNames = 'SomeConfiguration'
            #AllowUnsecureConnection =             $true #Use this parameter only if you do not have a certificate installed on the pull server
        }      
    }
}
PullClient
Set-DSCLocalConfigurationManager localhost –Path .\PullClient –Verbose