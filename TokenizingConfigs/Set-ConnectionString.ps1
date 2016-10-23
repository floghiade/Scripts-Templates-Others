function Set-ConnectionString
{
    param(
        [CmdletBinding()]
        [Parameter(Mandatory = $true, 
                   ValueFromPipeline = $true)]
                   [ValidateNotNullOrEmpty()]
        [String]
        $ConnectionFile
    )
    
    $ConnectionFile = 'c:\inetpub\wwwroot\webui\Configuration\connectionStrings.kos.config'
    
    Write-Verbose -Message "Tokenizing '$ConnectionFile' File"
    $ConfigString =   [xml](Get-Content "$ConnectionFile")
    $RootDocument = $ConfigString.DocumentElement
    $ConnectionString = $RootDocument.add.connectionString `
            -replace '(?m)(?<=\bdata source=).*?[^;]+', '__DATA_SOURCE__' `
            -replace '(?m)(?<=\bCatalog=).*?[^;]+', '__INITIAL_CATALOG__' `
            -replace '(?m)(?<=\bID=).*?[^;]+', '__USER_ID__' `
    -replace '(?m)(?<=\bPassword=).*','__PASSWORD__' 
    
    $RootDocument.add.connectionString = $ConnectionString
    $ConfigString.Save($ConnectionFile)
}

$name ='LocalSqlServer'

$DataSource = '__DATA_SOURCE__'
$InitialCatalog = '__INITIAL_CATALOG__'
$User = '__USER_ID__'
$Password = '__PASSWORD__'

$ConfigString.connectionStrings.SelectSingleNode("add[@name='" + $name + "']").connectionString = "data source=$DataSource;Initial Catalog=$InitialCatalog;User ID=$User;Password=$Password"
    
