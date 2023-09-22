<#
.SYNOPSIS
Import Organizational Units (OU) defined by their distinguished name to an Active Directory System Discovery components in ConfigMgr


.DESCRIPTION
This cmdlet uses the distinguished name defined in -SearchBase to the System Discovery method on an SCCM server. Existing containers for the specified Discovery Method will be preserved. If a container is already present, it will not be added again.


.NOTES
Author: Robert Osborne
Contact: rosborne@osbornerpo.com
Company: OsbornePro LLC.


.PARAMETER SiteServer
SCCM Site Server to connect too

.PARAMETER UseSSL
Creates CIM session to SCCM server using SSL (WinRM over HTTPS)

.PARAMETER SkipCACheck
Skip Certificate authority trust check on WinRM connnection

.PARAMETER SkipCNCheck
Skip verifying the CN/subject name on the WinRM certificate

.PARAMETER SkipRevocationCheck
Skip checking certificate revocation for WinRM connections

.PARAMETER SearchBase
Define the LDAP container OU path to new domains being added to System Discovery

.PARAMETER RestartService
Tells the SCCM server to restart the System Discovery service after adding new containers to search for

.PARAMETER Credential
Enter credentials to authenticate to the SCCM server


.EXAMPLE
Add-CMSystemDiscoveryMethodContainer -SiteServer sccm-server.domain.com -SearchBase "DC=domain,DC=com"
# This example adds the domain.com LDAP search base filter to the domain System Discovery method on the sccm-server.domain.com SCCM server

.EXAMPLE
Add-CMSystemDiscoveryMethodContainer -SiteServer sccm-server.domain.com -UseSSL -SkipCACheck -SkipCNCheck -SkipRevocationCheck -SearchBase "LDAP:\\DC=domain,DC=com"
# This example adds the domain.com LDAP search base filter to the domain System Discovery method on the sccm-server.domain.com SCCM server


.INPUTS
System.String


.OUTPUTS
PSCustomObject
#>
Function Add-CMSystemDiscoveryMethodContainer {
  [CmdletBinding(
      SupportsShouldProcess=$True,
      ConfirmImpact="Medium"
  )]  # End CmdletBinding
    param(
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$False,
            HelpMessage="Site server where the SMS Provider is installed.")]  # End Parameter
        [ValidateNotNullOrEmpty()]
        [String]$SiteServer,
        
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$UseSSL,
        
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$SkipCACheck,
        
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$SkipCNCheck,
        
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$SkipRevocationCheck,
 
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$False,
            HelpMessage="Specify the Active Directory Search Base `nEXAMPLE: DC=domain,DC=com : ")]  # End Parameter
        [ValidateScript({$_ -like "*DC=*,DC=*"})]
        [String]$SearchBase,
        
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$RestartService

         [ValidateNotNull()]
         [System.Management.Automation.PSCredential]
         [System.Management.Automation.Credential()]
         $Credential = [System.Management.Automation.PSCredential]::Empty
    )  # End param
 
BEGIN {
 
    $ComponentName = "SMS_AD_SYSTEM_DISCOVERY_AGENT"   
    Try {
 
        Write-Verbose -Message "Determining Site Code for Site server: '$($SiteServer)'"
        $CIMSession = New-CimSession -Credential $Credential -ComputerName $SiteServer -SessionOption (New-CimSessionOption -UseSSL:$UseSSL.IsPresent -SkipCACheck:$SkipCACheck.IsPresent -SkipCNCheck:$SkipCNCheck.IsPresent -SkipRevocationCheck:$SkipReovcationCheck.IsPresent -Verbose:$False) -Verbose:$False
        $SiteCodeObjects = Get-CimInstance -CimSession $CIMSession -Namespace "Root\SMS" -ClassName SMS_ProviderLocation -ErrorAction Stop
 
        ForEach ($SiteCodeObject in $SiteCodeObjects) {
 
            If ($SiteCodeObject.ProviderForLocalSite -eq $True) {
 
                $SiteCode = $SiteCodeObject.SiteCode
                Write-Verbose -Message "Site Code: $($SiteCode)"
                Break
 
            }  # End If
 
        }  # End ForEach
 
    } Catch [System.UnauthorizedAccessException] {
   
        Throw "[x] Access denied"
   
    } Catch [System.Exception] {
   
        Throw "[x] Unable to determine Site Code"
   
    }  # End Try Catch Catch
 
    If ($SearchBase -notlike "LDAP://*") {
   
        $SearchBase = "LDAP://$($SearchBase)"
   
    }  # End If
   
    Try {
 
        $ContainerData = New-Object -TypeName PSCustomObject -Property @{
            DistinguishedName="$($SearchBase)";
            Recursive="Yes";
            Group="Excluded";
        }  # End New-Object -Property
 
    } Catch [System.Exception] {
 
        Write-Warning -Message "$($_.Exception.Message). Line: $($_.InvocationInfo.ScriptLineNumber)"
        Break
   
    }  #  End Try Catch
 
    $OptionTable = @{
        Yes = 0
        No = 1
        Included = 0
        Excluded = 1
    }  # End $OptionTable
 
} PROCESS {
 
    # Determine existing containers for selected Discovery Method
    Try {
 
        $DiscoveryContainerList = New-Object -TypeName System.Collections.ArrayList
        $DiscoveryComponent = Get-WmiObject -Class SMS_SCI_Component -Namespace "Root\SMS\Site_$($SiteCode)" -ComputerName $SiteServer -Filter "ComponentName like '$($ComponentName)'" -Credential $Credential -ErrorAction Stop -Verbose:$False
        $DiscoveryPropListADContainer = $DiscoveryComponent.PropLists | Where-Object -FilterScript { $_.PropertyListName -like "AD Containers" }
 
        If ($DiscoveryPropListADContainer.PropertyListName -eq "AD Containers") {
 
            $DiscoveryContainerList.AddRange(@($DiscoveryPropListADContainer.Values)) | Out-Null
 
        }  # End If
 
    } Catch [System.Exception] {
 
        Throw "[x] Unable to determine existing discovery method component properties"
 
    }  # End Catch
 
 
    ForEach ($ContainerItem in $ContainerData) {
 
        If ($ContainerItem.DistinguishedName -notlike "LDAP://*") {
 
            $ContainerItem.DistinguishedName = "LDAP://$($ContainerItem.DistinguishedName)"
 
        }  # End If
 
 
        If ($ContainerItem.DistinguishedName -notin $DiscoveryContainerList) {
 
            Write-Verbose -Message "Adding new container item $($ContainerItem.DistinguishedName)"
            $DiscoveryContainerList.AddRange(@($ContainerItem.DistinguishedName, $OptionTable[$ContainerItem.Recursive], $OptionTable[$ContainerItem.Group])) | Out-Null
 
        } Else {
 
            Write-Verbose -Message "Detected duplicate container object: $($ContainerItem.DistinguishedName)"
 
        }  # End If Else
 
    }  # End ForEach
 
    Write-Verbose -Message "Attempting to save changes made to the $($ComponentName) component PropList"
    Try {
 
        $DiscoveryPropListADContainer.Values = $DiscoveryContainerList
        $DiscoveryComponent.PropLists = $DiscoveryPropListADContainer
        If ($PSCmdlet.ShouldProcess($DiscoveryComponent, '$DiscoveryComponent.Put()')) {
        
            $DiscoveryComponent.Put() | Out-Null

        }  # End If

    } Catch [System.Exception] {
 
        Throw "[x] Unable to save changes made to $($ComponentName) component"
 
    }  # End Try Catch
 
 
    If ($RestartService.IsPresent) {
    
        Write-Verbose -Message "Restarting the SMS_SITE_COMPONENT_MANAGER service"
        Try {
 
            Write-Output -InputObject "[*] Restarting the SMS_SITE_COMPONENT_MANAGER service on $SiteServer"
            Get-CimInstance -CimSession $CIMSession -ClassName Win32_Service -Filter 'Name = "SMS_SITE_COMPONENT_MANAGER"' -Verbose:$False | Invoke-CimMethod -MethodName StopService -WhatIf:$False -Verbose:$False | Out-Null
            Get-CimInstance -CimSession $CIMSession -ClassName Win32_Service -Filter 'Name = "SMS_SITE_COMPONENT_MANAGER"' -Verbose:$False | Invoke-CimMethod -MethodName StartService -WhatIf:$False -Verbose:$False | Out-Null
   
        } Catch [System.Exception] {
    
            Write-Warning -Message "$($_.Exception.Message). Line: $($_.InvocationInfo.ScriptLineNumber)"
            Break
   
        }  # End Try Catch
 
    }  # End If
    
} END {

     If ($CIMSession) {
     
        Remove-CimSession -CimSession $CIMSession -Confirm:$False -WhatIf:$False -Verbose:$False

     }  # End If

} # End END
 
}  # End Function Add-CMSystemDiscoveryMethodContainer
