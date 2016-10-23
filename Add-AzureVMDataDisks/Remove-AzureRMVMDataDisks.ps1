#requires -Version 2 -Modules AzureRM.Compute
function Remove-AzureRMVMDataDisks
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $ResourceGroup,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $VMname
    )
    
    $VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $ResourceGroup
    
    $GetMaxDataDiskCount = $VM.StorageProfile.DataDisks.Count
    for($i = 0; $i -le $GetMaxDataDiskCount-1; $i++) 
    {
        $DiskName = "$VMname-datadisk" + $i.ToString() 
        Remove-AzureRmVMDataDisk -VM $VM -Name $DiskName
    }        
    
    $VM | Update-AzureRmVM
}

