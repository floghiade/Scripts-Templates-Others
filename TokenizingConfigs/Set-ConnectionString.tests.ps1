# this is a Pester test file

#region LoadScript
# load the script file into memory
# attention: make sure the script only contains function definitions
# and no active code. The entire script will be executed to load
# all functions into memory
. ($PSCommandPath -replace '\.tests\.ps1$', '.ps1')
#endregion

$ConnectionFile = 'c:\inetpub\wwwroot\webui\Configuration\connectionStrings.kos.config'

Describe 'Set-ConnectionString' {

    Context 'Set Connection Strings'   {
    
        Mock Get-Content {Write-Output '<?xml version="1.0"?><connectionStrings><clear /><add name="LocalSqlServer" connectionString="data source=;Initial Catalog=;User ID=;Password=" providerName="System.Data.SqlClient" /></connectionStrings>'}
                                
        It 'runs without errors' {
            { Set-ConnectionString -ConnectionFile $ConnectionFile } | Should Not Throw
        }
    
        It 'does not return anything'     {
            Set-ConnectionString -ConnectionFile $ConnectionFile | Should BeNullOrEmpty 
        }
    }
}
