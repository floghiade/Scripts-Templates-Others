
<#
        .Synopsis
        This script will deploy a number of ASM Azure VMs that will be deployed in a Resource Group and configured for load balacing on ports 80 and 443
        .DESCRIPTION
        New-AzureMassDeployment deploys multiple VMs configured for load balancing web content on ports 80 and 443.
        Once run the script will prompt will check if the provided storage account, virtual network and cloud service exists. If the storage account and virtual network do no exist, the script will halt.
        After it passes the first checks it will then prompt for a set of credentials that will be used to login to the VMs and after that it will open a grid view where the user will
        select the image SKU that will be used for the deployment. The grid view is filtered to show only the image SKUs that are available for the provided VMType "Windows or Linux"
        It will then proceed to fetch the image SKU that was previosly selected and start the provisioning of the VMs.
        In the creation process, the VMs are also updated to use their assigned DHCP internal IP as a static IP.

        The best way to use the script is by using PowerShell Splatting as show in the second example.
        .PARAMETER SubscriptionID
        Specify the subscription ID in which you will deploy the virtual machines
        .PARAMETER Location
        Specify the datacenter region in which you want the virtual machines deployed
        .PARAMETER ServiceName
        The name of the Cloud Service where the virtual machines will be deployed
        .PARAMETER VirtualNetwork
        The name of the Virtual Network where the virtual machines will reside
        .PARAMETER VNetSubnet
        The name of the Virtual Network subnet
        .PARAMETER VMType
        Specify which type of VM you require - Windows or Linux
        .PARAMETER VMName
        The name of the Virtual Machines
        .PARAMETER StorageAccount
        The name of the Storage Account where the Virtual Machines OS and Data Disk VHDs will reside
        .PARAMETER VMSize
        Virtual Machine Instance Size
        .PARAMETER NumberOfVMInstances
        Specify the number of virtual machines to be created and added to the load balancer
        .PARAMETER AvailabilityGroup
        Optional - The name of the Availability Group
        .PARAMETER HTTPLoadBalancedName
        Optional - Specify the label for the port 80 load balancer endpoint
        .PARAMETER HTTPSLoadBalancedName
        Optional - Specify the label for the port 443 load balancer endpoint
        .PARAMETER HostCaching
        Specify if you want caching to be done on the local disk drive - None, ReadOnly, ReadWrite
        .PARAMETER VMImaage
        Optional - Specify a VM Image label that will we used to create the virtual machines. If not specified a grid view will open prompting the user to chose an image.
        .NOTES 
        This script has two caveats, due to the way Azure now works with IaaS V2, every new ASM deployment is put in a resource group and the user is required to manually create the Resource Group, Virtual Network
        and Storage Account.
        .EXAMPLE
        New-AzureMassDeployment -SubscriptionID <SubID> -Location '<location>' -ServiceName '<Servicename>' -VMName '<VMNAME>' -VMSize '<VMSize>' -VMType '<Type>' -StorageAccount '<StorageAccountName>' -NumberOfVMInstances <number> -VirtualNetwork '<VNETNAME>' -VNetSubnet '<VNETSUBNETNAME>'
        .EXAMPLE
        $Deployment = @{
        SubscriptionID= 'SubID';
        Location = 'Location';
        ServiceName = 'ServiceName';
        VMType = 'Windows or Linux';
        VMName ='VMPrefix';
        VirtualNetwork = 'VMNetworkName'
        VNetSubnet = 'VMSubnet';
        StorageAccount = 'StorageAccount';
        VMSize = 'Small';
        NumberOfVMInstances = 1;
        HostCaching = 'ReadWrite'
        VMImage ='OpenLogic 7.1'
        }
        New-AzureMassDeployment @Deployment -Verbose


#>

#requires -Version 3 -Modules Azure
$VerbosePreference = 'Continue'
function  New-AzureMassDeployment
{
    [CmdletBinding(SupportsShouldProcess = $true, 
            PositionalBinding = $false,
    ConfirmImpact = 'Medium')]
   
    [OutputType([String])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $SubscriptionID,
        
        [Parameter(Mandatory = $true)]
        [ValidatePattern('[a-z]*')]
        [ValidateSet('Central US', 'South Central US', 'East US', 'West US', 'North Central US', 'East US 2', 'North Europe', 'West Europe', 'Southeast Asia', 'East Asia', 'Japan West', 'Japan East', 'Brazil South')]
        [String]
        $Location,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ServiceName,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1,15)]
        [String]
        $VMName,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
                    If ($_ -cmatch "^[^A-Z]*$") 
                    {
                        $true
                    }
                    else 
                    {
                        Throw "The Storage account parameter can only contain lowercase letters and numbers. Name has to be between 3 and 24 characters. Storage account provided: $_"
                    }
        })]
        [String]
        $StorageAccount,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $VMSize,
        
        [Parameter(Mandatory = $false)]
        [String]
        $VMType = 'Windows',
                                           
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [Int]
        $NumberOfVMInstances = 2,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $VirtualNetwork,
                
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $VNetSubnet = 'default',
                
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $HTTPLoadBalancedName = 'HTTP-LBSet',
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $HTTPSLoadBalancedName = 'HTTPS-LBSet',
      
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $AvailabilityGroup = 'WEB-AVGroup',
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('None','ReadOnly', 'ReadWrite')]
        [String]
        $HostCaching = 'None',
        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]
        $VMImage

    )

    Begin
    {
        
        Write-Verbose -Message "$(Get-Date -Format T) -  Selecting the Azure Subscription"
        Select-AzureSubscription -SubscriptionId $SubscriptionID
        
        try
        {
            Set-AzureSubscription -SubscriptionId $SubscriptionID -CurrentStorageAccountName $StorageAccount -ErrorAction Stop
        }
        catch
        {
            "Error was $_"
            $line = $_.InvocationInfo.ScriptLineNumber
            "Error was in Line $line"
            break
        }
            
        Write-Verbose -Message "$(Get-Date -Format T) - Verifying if the virtual network: $VirtualNetwork exists"
        
        $null = Get-AzureVNetSite -VNetName "Group $ServiceName $VirtualNetwork" -ErrorAction Stop -ErrorVariable VnetMissing -OutVariable VNET
        
        if ($VirtualNetwork -eq $null)
        {
            throw $_
            Write-Error $VnetMissing
            break
        }
        else
        {
            $VNET = "Group $ServiceName $VirtualNetwork"
        }
        
        try
        {
            $null = Get-AzureService -ServiceName $ServiceName -ErrorAction Stop
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
                     
            if($PSCmdlet.ShouldProcess($ServiceName))
            {
                Write-Verbose -Message "$(Get-Date -Format T) - A cloud service was not found...Creating a cloud service named $ServiceName"
                New-AzureService -ServiceName $ServiceName -Location $Location 
            }
        }
                       
        $Credentials = Get-Credential -Message 'Type the name and password for the initial account.'

        if ($Credentials -eq $null)
        {
            Write-Error -Message 'No credentials have been supplied.'
            break
        }
        
        if ($VMImage -eq '')
        {
            Write-Verbose -Message "$(Get-Date -Format T) - Fetching a list of $VMType images"
            $GetLabelName = Get-AzureVMImage |
            Where-Object -Property OS -EQ -Value "$VMType" |
            Select-Object -Property Label, PublishedDate |
            Out-GridView -PassThru
            $Label = $GetLabelName.Label
            $Image = Get-AzureVMImage |
            Where-Object -FilterScript {
                $_.Label -eq $Label
            } |
            Sort-Object -Property PublishedDate -Descending |
            Select-Object -ExpandProperty ImageName -First 1
        }
        else
        {
            Write-Verbose -Message "$(Get-Date -Format T) - Fetching the VMImageName for $VMImage"
            $Image = Get-AzureVMImage |
            Where-Object -FilterScript {
                $_.Label -eq $VMImage
            } |
            Sort-Object -Property PublishedDate -Descending |
            Select-Object -ExpandProperty ImageName -First 1 -ErrorAction Stop
        }


        Write-Verbose -Message "$(Get-Date -Format T) - Setting HTTP and HTTPS ports and protocols"
        
        $Protocol = 'tcp'
        $ProbeProtocol = 'tcp'
        $HTTPPort = 80
        $HTTPPublicPort = 80
        $HTTPProbePort = 80
        $HTTPEndpointName = 'LB-HTTP'

        $HTTPSPort = 443
        $HTTPSPublicPort = 443
        $HTTPSProbePort = 443
        $HTTPSEndpointName = 'LB-HTTPS'
    
    }
    Process
    {
        $StartTime = Get-Date
        Write-Verbose -Message "$(Get-Date -Format T) - Preparing to create the VMs"
        for ($i = 10; $i -le $NumberOfVMInstances; $i++) 
        {
            $VMs = $VMName.ToString() + $i.ToString()
            $VMs = New-AzureVMConfig -Name $VMs -InstanceSize $VMSize -ImageName $Image -AvailabilitySetName $AvailabilityGroup
            
            if ($VMType -eq 'Windows')
            {
                $VMs | Add-AzureProvisioningConfig -Windows -AdminUsername $Credentials.UserName -Password $Credentials.Password
            }
            else
            
            {
                $VMs | Add-AzureProvisioningConfig -Linux -LinuxUser $Credentials.GetNetworkCredential().Username -Password $Credentials.GetNetworkCredential().Password
            }
            $DiskSize = 1023
            $DiskName = $VMName.ToString() + $i.ToString() + '-datadisk'
    
            $VMs | Set-AzureSubnet -SubnetNames $VNetSubnet
            $VMs | Add-AzureDataDisk -CreateNew -DiskLabel $DiskName -DiskSizeInGB $DiskSize -LUN 0 -HostCaching $HostCaching
            #$VMs | Add-AzureEndpoint -Name $HTTPEndpointName -Protocol $Protocol -LocalPort $HTTPPort -PublicPort $HTTPPublicPort -LBSetName $HTTPLoadBalancedName -ProbeProtocol $ProbeProtocol -ProbePort $HTTPProbePort
            #$VMs | Add-AzureEndpoint -Name $HTTPSEndpointName -Protocol $Protocol -LocalPort $HTTPSPort -PublicPort $HTTPSPublicPort -LBSetName $HTTPSLoadBalancedName -ProbeProtocol $ProbeProtocol -ProbePort $HTTPSProbePort
            
                        
            $j = $i - 1
                       
            $PercentComplete = ($j / $NumberOfVMInstances) * 100
            
            $ProgressParameters = @{
                Activity         = 'Creating VMs'
                Status           = "Creating VM number $i"
                CurrentOperation = "$PercentComplete% complete"
                PercentComplete  = $PercentComplete
            }
                        
            Write-Progress @ProgressParameters
            
            if ($PSCmdlet.ShouldProcess($ServiceName))
            {
                New-AzureVM -ServiceName $ServiceName -VMs $VMs -VNetName "$VNET" -WaitForBoot -ErrorAction Stop
            }
            Write-Verbose -Message "$(Get-Date -Format T) - Waiting for the VM to fully boot"
            
            Start-Sleep 15            
            
            AzureVMName = $VMName.ToString() + $i.ToString()
            $AzureVM = Get-AzureVM -ServiceName $ServiceName -Name $VMName$i
            
            Write-Verbose -Message "$(Get-Date -Format T) - Setting a static IP address on $VMName$i"
            if ($PSCmdlet.ShouldProcess($AzureVM))
            {
                Set-AzureStaticVNetIP -VM $AzureVM -IPAddress ($AzureVM.IpAddress).ToString()
            }
        
            Add-AzureEndpoint -Name $HTTPEndpointName -Protocol $Protocol -LocalPort $HTTPPort -PublicPort $HTTPPublicPort -LBSetName $HTTPLoadBalancedName -ProbeProtocol $ProbeProtocol -ProbePort $HTTPProbePort -VM $AzureVM
            Add-AzureEndpoint -Name $HTTPSEndpointName -Protocol $Protocol -LocalPort $HTTPSPort -PublicPort $HTTPSPublicPort -LBSetName $HTTPSLoadBalancedName -ProbeProtocol $ProbeProtocol -ProbePort $HTTPSProbePort -VM $AzureVM
            Update-AzureVM
        }
        
        $EndTime = Get-Date
        
        $EndCompare = New-TimeSpan -Start $StartTime -End $EndTime
        
        Write-Output -InputObject ('The deployment was completed in ' +$EndCompare.Minutes+ ' minutes')
        }
}
