function script:Connect-AzureVMstoOMS 
{
  <#
      .SYNOPSIS
      This script will allow you to en-roll multiple or all VMs from your 
      Azure Subscription in Operations Management Suite

      .DESCRIPTION
      The purpose of this script is to ease the enrollment process of Azure VMs in in a specific 
      OMS account. 
      The script requires the user to already be logged in on his Azure subscription.
      The script works with Windows or Linux VMs
      If the currently selected Azure Subscription does not have an OMS account then the user has
      the option to provide a OMS WorkSpace ID and a WorkSpace Key.
  
      .PARAMETER SelectionMethod
      Mandatory Parameter -Selection Method is used to select which VMs
      you want be en-rolled in OMS or all of them. Mandatory Values = Multiple / All

      .PARAMETER OMSWorkSpaceID
      Optional Parameter -If an OMS account doesn't exist in the specified Azure Subscription 
      then a Workspace ID is required.

      .PARAMETER OMSWorkSpaceKey
      Optional Parameter -If an OMS account doesn't exist in the specified Azure Subscription 
      then a Workspace Key is required.

      .EXAMPLE
      Connect-AzureVMstoOM -SelectionMethod Multiple -OMSWorkSpaceID Value -OMSWorkSpaceKey Value
      The script is executed and prompts the user which VMs he should en-roll in a OMS account 
      which was provided
      
      Connect-AzureVMstoOM -SelectionMethod All
      The script will en-roll all the VMs from the selected Azure subscription in the OMS account 
      that's present in the subscription.

  #>



  param(
    [Parameter(Mandatory = $true,HelpMessage = 'The input for this parameter is Multiple or All. 
    The value <Multiple> allows you to select a number of VMs that you want to enroll in OMS. 
    The value <All> will enroll all VMs Windows / Linux VMs in OMS')]
    [ValidateSet('Multiple','All')]
    [string]
    $SelectionMethod,
    
    [String]
    $OMSWorkSpaceID,
    
    [String]
    $OMSWorkSpaceKey
    
  )
           
  try
  {
    $Subscription = Get-AzureRmContext
  }
  catch
  {
    Write-Error -Message "No Azure Context was found.
    Please run Login-AzureRmAccount and select an Azure subscription"
  }


  
  if(($OMSWorkSpaceID -eq '') -and ($OMSWorkSpaceKey -eq ''))
  {   
    if ((Get-AzureRmOperationalInsightsWorkspace).Count -gt 1)
    {
      $OMSWorkSpace = Get-AzureRmOperationalInsightsWorkspace | Out-GridView -OutputMode Single
    }
    else
    {
      $OMSWorkSpace = Get-AzureRmOperationalInsightsWorkspace
    }
      
    if ($OMSWorkSpace -eq $null)
    {
      Write-Error -Message ('Cannot find an OMS account in the current subscription.
                            Subscription Name = {0} 
                            Subscription ID = {1}' `
                            -f $Subscription.Subscription.SubscriptionName, `
                               $Subscription.Subscription.SubscriptionID) `
                            -Category ObjectNotFound
      break
    }
    $OMSWorkSpaceID = $OMSWorkSpace.CustomerId
    $OMSWorkSpaceKey = (Get-AzureRmOperationalInsightsWorkspaceSharedKeys `
                        -ResourceGroupName $OMSWorkSpace.ResourceGroupName `
                        -Name $OMSWorkSpace.Name).PrimarySharedKey
  }
    
  
  switch ($SelectionMethod){
  
    'Multiple'
    {
      $VMs = Get-AzureRmVM | Out-GridView -OutputMode Multiple
    }
    'All'
    {
      $VMs = Get-AzureRmVM
    }
  }
  foreach ($VM in $VMs)
  {
    if ($VM.StorageProfile.OsDisk.OsType -eq 'Windows')
    {
      Write-Verbose -Message ('Installing Windows OMS Agent on {0}' -f $VM.Name)
      Set-AzureRmVMExtension -ResourceGroupName $VM.ResourceGroupName `
                             -VMName $VM.Name `
                             -Name 'MicrosoftMonitoringAgent' `
                             -Publisher 'Microsoft.EnterpriseCloud.Monitoring' `
                             -ExtensionType 'MicrosoftMonitoringAgent' `
                             -TypeHandlerVersion '1.0' `
                             -Location $VM.Location `
                             -SettingString "{'workspaceId': '$OMSWorkSpaceID'}" `
                             -ProtectedSettingString "{'workspaceKey': '$OMSWorkSpaceKey'}"
    }
    elseif ($VM.StorageProfile.OsDisk.OsType -eq 'Linux')
    {
      Write-Verbose -Message ('Installing Linux OMS Agent on {0}.Name' -f $VM.Name)
      Set-AzureRmVMExtension -ResourceGroupName $VM.ResourceGroupName `
                             -VMName $VM.Name -Name 'OmsAgentForLinux' `
                             -Publisher 'Microsoft.EnterpriseCloud.Monitoring' `
                             -ExtensionType 'OmsAgentForLinux' `
                             -TypeHandlerVersion '1.0' `
                             -Location $VM.Location `
                             -SettingString "{'workspaceId': '$OMSWorkSpaceID'}" `
                             -ProtectedSettingString "{'workspaceKey': '$OMSWorkSpaceKey'}"
    }
  }
}
