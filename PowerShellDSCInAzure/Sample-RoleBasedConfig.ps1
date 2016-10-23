#requires -Version 4
configuration ConfigureMachine {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
 
    Node $AllNodes.Where{
        $_.Role -eq 'WebServer'
    }.NodeName
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
 
    Node $AllNodes.Where{
        $_.Role -eq 'MidServer'
    }.NodeName
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
 
    Node $AllNodes.Where{
        $_.Role -eq 'BackendServer'
    }.NodeName
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