#requires -Version 1 -Modules Azure.Storage, AzureRM.Storage

Add-AzureRmAccount
$Subscription = Get-AzureRmSubscription | Out-GridView -PassThru
Set-AzureRmContext -SubscriptionId $Subscription.SubscriptionId

$ResourceGroupName = 'Insert RG HERE'
$Location = 'westeurope'
 New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
 
$Parameters = @{
workspaceId = ''
workspaceKey = ''
vmName = ''
osType = ''
adminUsername = ''
adminPassword = ''
dnsLabelPrefix = ''
}
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile '<pathtoJSONfile' -TemplateParameterObject $Parameters -Verbose
