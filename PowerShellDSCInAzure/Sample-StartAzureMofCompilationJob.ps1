$ConfigurationDAta = @{
    AllNodes = @(
        @{
            NodeName          = 'WebXX'
            Role              = 'WebServer'
            WindowsFeatureList = ('AS-NET-Framework', 'NET-Framework-Core')
        }
        @{
 
            NodeName          = 'MidXX'
            Role              = 'MidServer'
            WindowsFeatureList = ('AS-NET-Framework', 'NET-Framework-Core')
 
        }
        @{
 
            NodeName          = 'BackendXX'
            Role              = 'BackendServer'
            WindowsFeatureList = ('AS-NET-Framework', 'NET-Framework-Core')
 
        }
    )
}
 
 
$CompilationParameters = @{
    ResourceGroup = 'Automation'
    AutomationAccountName = 'AzureAuto'
    ConfigurationName = 'ConfigureMachine'
    ConfigurationData = "$ConfigurationData"
   }
 
Start-AzureRmAutomationDscCompilationJob @CompilationParameters