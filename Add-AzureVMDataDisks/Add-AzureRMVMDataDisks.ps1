#requires -Version 3 -Modules AzureRM.Compute
function Add-AzureRMVMDataDisks
{
    [CmdletBinding(DefaultParameterSetName = 'nrofdisks')]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]
        $ResourceGroup,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $VMname,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'MaxDisks', Position = 2)]
        [Switch]
        $MaxDisks,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'NrOfDisks', Position = 2)]
        [Int]
        $NoOfDisks,
        
        [Parameter(Mandatory = $false, Position = 3)]
        [Int]
        $DiskSize = 1023,
        
        [Parameter(Mandatory = $false, Position = 4)]
        [String]
        [ValidateSet('None','ReadOnly', 'ReadWrite')]
        $HostCaching = 'None'
        
    )
    
    $VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $ResourceGroup
    $GetMaxDataDiskCount = Get-AzureRmVMSize -Location $VM.Location | Where-Object -Property Name -EQ -Value $VM.HardwareProfile.VmSize
    
    If ($MaxDisks -eq $true)
    
    {
    $NoOfDisks = $GetMaxDataDiskCount.MaxDataDiskCount
    }
        
    if ($NoOfDisks -gt $GetMaxDataDiskCount.MaxDataDiskCount)
    {
        Write-Error -Message "The VM does not support $NoOfDisks data disks. Please reduce the number to a number lesser or equal to $GetMaxDataDiskCount"
        break
    }
    
    $GetStorageURI = ($VM.StorageProfile.OSDisk.Vhd.Uri).Split('/')[2]

    for($i = 0; $i -le $NoOfDisks-1; $i++) 
    {
        $DiskName = "$VMname-datadisk" + $i.ToString() 
        Add-AzureRmVMDataDisk -VM $VM -Name $DiskName -VhdUri "https://$GetStorageURI/vhds/$DiskName.vhd" -Lun $i -Caching $HostCaching -DiskSizeInGB $DiskSize -CreateOption empty
    }        
    $VM | Update-AzureRmVM
}

