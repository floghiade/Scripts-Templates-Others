Configuration ...{

     Import-DscResource -ModuleName PSDesiredStateConfiguration, xWebAdministration, xReleaseManagement

    Node localhost {
            xTokenize ModifyConnectionString
            {
                path = "Path/To/ConfigFile/"
                recurse =                 $false
                tokens = @{DATA_SOURCE="$($Node.ConnectionDB),1433";INITIAL_CATALOG="$($Node.ConnectionCatalog)";USER_ID="$($Node.ConnectionUser)";PASSWORD="$($Node.ConnectionPass)"}
            }                   
    }
}
@{
    AllNodes = @(
        @{
            NodeName           = 'localhost'
            ConnectionDB       = 'SQLSERVER'
            ConnectionCatalog  = 'SQLDATABASE'
            ConnectionUser     = 'USER'
            ConnectionPass     = 'PASSWORD'
        }
    )
}