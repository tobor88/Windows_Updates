<#
.SYNOPSIS
This cmdlet is used to run SCCM client actions on a remote or local device(s)
 
.DESCRIPTION
Execute the SCCM client actions found in Configuration Manager under the Actions tab
 
- Application Deployment Evaluation Cycle – This action when run re-evaluates the requirement rules for all deployments. If an application is required, and not installed when the Application Deployment Evaluation Cycle runs, Configuration Manager automatically triggers a re-install.The Application Deployment Evaluation Cycle only applies to applications and not to the packages. The default value is set to run every 7 days.
- Discovery Data Collection Cycle – This action invokes a Discovery Data Collection on each computer in the selected collection and causes the client to generate a new discovery data record (DDR). When the DDR is processed by the site server, Discovery Data Manager adds or updates resource information from the DDR in the site database.
- File Collection Cycle – This action searches for specific file that you have defined in client Agent settings. When a file is specified for collection, the SCCM software inventory agent searches for that file when it runs a software inventory scan on each client in the site. If the software inventory client agent finds a file that should be collected, the file is attached to the inventory file and sent to the site server.
- Hardware Inventory Cycle – As the name says this cycle collects information such as available disk space, processor type, and operating system about each computer. Hardware inventory information will be logged into inventoryagent.log.
- Machine Policy Retrieval & Evaluation Cycle –  You might have run this action cycle if you have worked on SCCM a lot. We know that the client downloads its policy on a schedule (By default, this value is configured to every 60 minutes and is configured with the option Policy polling interval). This action initiates ad-hoc machine policy retrieval from the client outside its scheduled polling interval.
- Software Inventory Cycle – Do not get confused with Hardware Inventory Cycle and Software Inventory Cycle. The difference between these two is Hardware Inventory uses WMI to get the information about computer and software inventory works on files to get information in the file header. This action cycle collects software inventory data directly from files (such as .exe files) by inventorying the file header information. You can also configure Configuration Manager to collect copies of files that you specify.
- Software Metering Usage Report Cycle – This action cycle when run collects the data that allows you to monitor the client software usage.
- Software Updates Deployment Evaluation Cycle – This cycle initiates a scan for software updates compliance. Before client computers can scan for software update compliance, the software updates environment must be configured, in other words the WSUS server should be available for this scan to run successfully.
- User Policy Retrieval & Evaluation Cycle – This is very similar to Machine Policy Retrieval & Evaluation Cycle, but this action initiates ad-hoc user policy retrieval from the client outside its scheduled polling interval.
- Windows Installer Source List Update Cycle –  When you install an application using Windows Installer, those Windows Installer applications try to return to the path they were installed from when they need to install new components, repair the application, or update the application. This location is called the Windows Installer source location. This cycle causes the Product Source Update Manager to complete a full update cycle. Windows Installer Source Location Manager can automatically search Configuration Manager distribution points for the source files, even if the application was not originally installed from a distribution point.
 
 
.PARAMETER ComputerName
Define the Fully Qualified Domain Names of devices you wish to remotely access to run the SCCM client actions against
 
.PARAMETER ClientAction
Define the client actions you want to execute against the -ComputerName values you set
 
.PARAMETER UseSSL
Specifies whether you want to use SSL to add integrity and an extra layer of encryption to your CIM session connections
 
.PARAMETER Credential
Credentials used to authenticate too and create CIM sessions with remote devices


.EXAMPLE
Invoke-SccmClientAction -ClientAction "MachinePolicy","DiscoveryData","ComplianceEvaluation","AppDeployment","HardwareInventory","UpdateDeployment","UpdateScan","SoftwareInventory"
# This example runs all the possible client actions against the device the cmdlet is running on locally
 
.EXAMPLE
Invoke-SccmClientAction -ComputerName DC01.domain.com,DHCP.domain.com -ClientAction "MachinePolicy" -Credential (Get-Credential)
# This example runs the MachinePolicy action in the SCCM client actions against a DC01.domain.com and DHCP.domain.com using WinRM created CIM sessions
 
.EXAMPLE
Invoke-SccmClientAction -ComputerName DC01.domain.com,DHCP.domain.com -UseSSL -ClientAction "MachinePolicy","AppDeployment" -Credential (Get-Credential)
# This example runs the MachinePolicy and AppDeployment actions in the SCCM client actions against a DC01.domain.com and DHCP.domain.com using WinRM over HTTPS created CIM sessions


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com
 
 
.INPUTS
System.String[]
 
 
.OUTPUTS
None
 
 
.LINK
https://docs.microsoft.com/en-us/mem/configmgr/develop/reference/core/clients/client-classes/triggerschedule-method-in-class-sms_client
https://docs.microsoft.com/en-us/mem/configmgr/develop/reference/core/clients/client-classes/sms_client-client-wmi-class
https://osbornepro.com
https://btpssecpack.osbornepro.com
https://encrypit.osbornepro.com
https://writeups.osbornepro.com
https://github.com/OsbornePro
https://github.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
#>
Function Invoke-SccmClientAction {
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$False,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage="Define the FQDN of the machine(s) to run the action against. Separate multiple values with a comma: ")]
            [String[]]$ComputerName = $env:COMPUTERNAME,
 
            [Parameter(
                Position=1,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Define the SCCM action(s) to run against the -ComputerName values. Separate multiple values with a comma: ")]  # End Pararmeter
            [ValidateSet("MachinePolicy","DiscoveryData","ComplianceEvaluation","AppDeployment","HardwareInventory","UpdateDeployment","UpdateScan","SoftwareInventory")]
            [String[]]$ClientAction,
 
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$UseSSL,
           
            [Parameter(
                Mandatory=$False,
                ParameterSetName="Credential")]
            $Credential = [System.Management.Automation.PSCredential]::Empty)  # End param
 
    $Results = @()
    $UseSSL = $False
    If ($UseSSL.IsPresent) {
 
        $UseSSL = $True
 
    }  # End If
   
    If ($ComputerName.Count -ne 1 -and $ComputerName -ne $env:COMPUTERNAME) {
 
        Write-Verbose "Building CIM Session"
        $CimSession = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption (New-CimSessionOption -UseSSL:$UseSSL -SkipCACheck -SkipCNCheck -SkipRevokationCheck)
 
        ForEach ($MethodName in $ClientAction) {
 
            If ($MethodName -like 'MachinePolicy') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000021}' }
 
            } ElseIf ($MethodName -like 'DiscoveryData') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000003}' }
 
            } ElseIf ($MethodName -like 'ComplianceEvaluation') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000071}'}
           
            } ElseIf ($MethodName -like 'AppDeployment') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000121}' }
           
            } ElseIf ($MethodName -like 'HardwareInventory') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000001}' }
           
            } ElseIf ($MethodName -like 'UpdateDeployment') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000108}' }
           
            } ElseIf ($MethodName -like 'UpdateScan') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000113}'}
           
            } ElseIf ($MethodName -like 'SoftwareInventory') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -CimSession $CimSession -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000002}'}
       
            }  # End If ElseIf
 
        }  # End ForEach
 
        Write-Verbose "Completed executing all actions"
   
    } Else {
 
        ForEach ($MethodName in $ClientAction) {
 
            If ($MethodName -like 'MachinePolicy') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000021}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
           
            } ElseIf ($MethodName -like 'DiscoveryData') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000003}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
 
            } ElseIf ($MethodName -like 'ComplianceEvaluation') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000071}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
           
            } ElseIf ($MethodName -like 'AppDeployment') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000121}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
           
            } ElseIf ($MethodName -like 'HardwareInventory') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000001}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
           
            } ElseIf ($MethodName -like 'UpdateDeployment') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000108}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
           
            } ElseIf ($MethodName -like 'UpdateScan') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000113}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
           
            } ElseIf ($MethodName -like 'SoftwareInventory') {
        
                Write-Verbose "Executing client action: $MethodName"
                $Results += Invoke-CimMethod -Namespace "Root\CCM" -ClassName "SMS_Client" -MethodName TriggerSchedule -Arguments @{ sScheduleID='{00000000-0000-0000-0000-000000000002}' } -ErrorVariable Issue
                If ($Issue) {
 
                    Write-Output "[x] Issue running Schedule ID : $MethodName"
 
                }  # End If
       
            }  # End If ElseIf
 
        }  # End ForEach
 
        Write-Verbose "Completed executing all actions"
 
    }  # End If Else
 
    Return $Results
 
}  # End Invoke-SccmClientAction
