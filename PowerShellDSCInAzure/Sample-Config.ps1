configuration ConfigureMachine {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
 
 
    Node $AllNodes.NodeName<a href="https://www.florinloghiade.ro/wp-content/uploads/2016/04/AzureAutomation_Compiled.png"><img src="https://www.florinloghiade.ro/wp-content/uploads/2016/04/AzureAutomation_Compiled-1024x811.png" alt="AzureAutomation_Compiled" width="1024" height="811" class="alignnone size-large wp-image-671" /></a>
    {
           foreach($WindowsFeature in $Node.WindowsFeatureList)
            {
                WindowsFeature $WindowsFeature
                {
                    Ensure = 'Present'
                    Name = $WindowsFeature
                }
        
            }
         }
    }