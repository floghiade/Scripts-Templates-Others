#requires -Version 4 -Modules PSDesiredStateConfiguration
configuration DSCPullServer
{ 
    param  
    ( 
        [string[]]$NodeName = 'localhost', 
 
        [ValidateNotNullOrEmpty()] 
        [string] $certificateThumbPrint 
    ) 
 
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 3.7.0.0
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node $NodeName 
    { 
        WindowsFeature DSCServiceFeature 
        { 
            Ensure = 'Present' 
            Name   = 'DSC-Service'             
        } 

        xDscWebService DSCPullSRV
        { 
            Ensure                  = 'Present' 
            EndpointName            = 'DSCPullSRV' 
            Port                    = 8080 
            PhysicalPath            = "$env:SystemDrive\inetpub\DSCPullSRV" 
            CertificateThumbPrint   = $certificateThumbPrint          
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules" 
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            RegistrationKeyPath     = "$env:PROGRAMFILES\WindowsPowerShell\DscService"   
            AcceptSelfSignedCertificates = $true    
            State                   = 'Started' 
            DependsOn               = '[WindowsFeature]DSCServiceFeature'                         
        }
    }
}

DSCPullServer -certificateThumbPrint $($DSCCert).Thumbprint
Start-DscConfiguration -Path $env:SystemDrive\DSCPullServer -Wait -Verbose