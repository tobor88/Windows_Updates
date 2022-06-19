<#
.SYNOPSIS 
This cmdlet is used with the Get-WindowsUpdateErrorCode.ps1 file in this repository https://github.com/tobor88/Windows_Updates and returns a description translation for the "component" value found in log files in C:\Windows\CCM\Logs


.DESCRIPTION
Translates compnonent value in C:\Windows\CCM\Log log files to its description as defined in https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/hierarchy/log-files


.PARAMETER Name
Define the name of the component value returned from one of the C:\Windows\CCM\Log files


.EXAMPLE
Get-ComponentDescription -Name WUAHandler
# Returns the description of what WUAHandler logs contain


.INPUTS
None


.OUTPUTS
None


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com

.LINK
https://docs.microsoft.com/en-us/mem/configmgr/core/plan-design/hierarchy/log-files
https://github.com/tobor88
https://github.com/OsbornePro
https://www.powershellgallery.com/profiles/tobor
https://osbornepro.com
https://writeups.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
#>
Function Get-ComponentDescription {
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Enter the name of the log file to get a decsription of. EXAMPLE: WUAHandler"
            )]  # End Parameter
            #[ValidateSet("WUAhandler","UpdatesHandler","UpdatesDeployments","ComplRelayAgent","CcmEval","CertificateMaintenance","UpdatesDeploymentAgent","DataTransferService","AlternateHandler","DeltaDownload","ccmperf","PolicyEvaluator","RebootCoordinator","ScanAgent","SdmAgent","ServiceWindowManager","SmsWusHandler","StateMessage","SUPSetup","UpdatesStore","wsyncmgr")]
            [String]$Name
        )  # End param

    Switch -Wildcard ($Name) {

        'WUAhandler' { $Description = 'Windows Update Agent details on the client when searching for software updates'}
        'UpdatesHandler' { $Description = 'Records details about software updtae compliance scanning and the download and installation of software updates on the client'}
        'UpdatesDeployments' { $Description = 'Records deatils about deployments on the client; includeing software update activation; evaluation; and enforcement'}
        'ComplRelayAgent' { $Description = 'Records information for the co-management workload for compliance policies.' }
        'CcmEval' { $Description = "Records Configuration Manager client status evaluation activities and details for components that are required by the Configuration Manager client." }
        'CertificateMaintenance' { $Description = "Maintains certificates for Active Directory Domain Services and management points." }
        'UpdatesDeploymentAgent' { $Description = "Records details about deployments on the client, including software update activation, evaluation, and enforcement. Verbose logging shows additional information about the interaction with the client user interface." }
        'DataTransferService' { $Description = "Records all BITS communication for policy or package access. This log also is used for content management by pull-distribution points." }
        'AlternateHandler' { $Description = "Records details when the client calls the Office click-to-run COM interface to download and install Microsoft 365 Apps for enterprise client updates. It's similar to use of WuaHandler when it calls the Windows Update Agent API to download and install Windows updates." }
        'DeltaDownload' { $Description = "Records information about the download of express updates and updates downloaded using Delivery Optimization." }
        'ccmperf' { $Description = "Records activities related to the maintenance and capture of data related to client performance counters." }
        'PolicyEvaluator' { $Description = "Records details about the evaluation of policies on client computers, including policies from software updates." }
        'RebootCoordinator' { $Description = "Records details about the coordination of system restarts on client computers after software update installations." }
        'ScanAgent' { $Description = "Records details about scan requests for software updates, the WSUS location, and related actions. " }
        'SdmAgent' { $Description = "Records details about the tracking of remediation and compliance. However, the software updates log file, Updateshandler.log, provides more informative details about installing the software updates that are required for compliance. This log file is shared with compliance settings." }
        'ServiceWindowManager' { $Description = "Records details about the evaluation of maintenance windows." }
        'SmsWusHandler' { $Description = "Records details about the scan process for the Inventory Tool for Microsoft Updates." }
        'StateMessage' { $Description = "Records details about software update state messages that are created and sent to the management point." }
        'SUPSetup' { $Description = "Records details about the software update point installation. When the software update point installation completes, Installation was successful is written to this log file." }
        'UpdatesStore' { $Description = "Records details about compliance status for the software updates that were assessed during the compliance scan cycle." }
        'wsyncmgr' { $Description = "Records details about the software update sync process." }
        'UserAffinity' { $Description = "Records details about user device affinity." }
        'CCMEXEC' { $Description = "Records activities of the client and the SMS Agent Host service. This log file also includes information about enabling and disabling wake-up proxy." }
        'MaintenanceCoordinator' { $Description = "Records the activity for general maintenance tasks for the client." }
        'InventoryProvider' { $Description = "More details about hardware inventory, software inventory, and heartbeat discovery actions on the client." }
        'CIStateStore' { $Description = "Records changes in state for configuration items, such as compliance settings, software updates, and applications." }
        'AppGroupHandler' { $Description = "Records detection and enforcement information for application groups" }
        'AssetAdvisor' { $Description = "Records the activities of Asset Intelligence inventory actions. " }
        'ADALOperationProvider' { $Description = "Information about client authentication token requests with Azure Active Directory (Azure AD) Authentication Library (ADAL). (Replaced by CcmAad.log starting in version 2107)" }
        'CcmAad' { $Description = "Information about client authentication token requests with Azure Active Directory (Azure AD) Authentication Library (ADAL). (Replaced by CcmAad.log starting in version 2107)" }
        'PolicyAgent_RequestAssignments' { $Description = "Records requests for policies made by using the Data Transfer Service." }
        'ClientIDManagerStartup' { $Description = "Creates and maintains the client GUID and identifies tasks during client registration and assignment." }
        'CAS' { $Description = "The Content Access service. Maintains the local package cache on the client." }
        'Ccm32BitLauncher' { $Description = "Records actions for starting applications on the client marked run as 32 bit." }
        'BitLockerManagementHandler' { $Description = "Records information about BitLocker management policies." }
        'CCMNotificationAgent' { $Description = "Records activities related to client notification operations." }
        'CcmEvalTask' { $Description = "Records the Configuration Manager client status evaluation activities that are initiated by the evaluation scheduled task." }
        'CcmRestart' { $Description = "Records client service restart activity." }
        'CcmMessaging' { $Description = "Records activities related to communication between the client and management points." }
        'CCMSDKProvider' { $Description = "Records activities for the client SDK interfaces." }
        'ccmsqlce' { $Description = "Records activities for the built-in version of SQL Server Compact Edition (CE) that the client uses. This log is typically only used when you enable debug logging, or there's a problem with the component. The client health task (ccmeval) usually self-corrects problems with this component." }
        'CcmUsrCse' { $Description = "Records details during user sign on for folder redirection policies." }
        'CCMVDIProvider' { $Description = "Records information for clients in a virtual desktop infrastructure (VDI)." }
        'CertEnrollAgent' { $Description = "Records information for Windows Hello for Business. Specifically communication with the Network Device Enrollment Service (NDES) for certificate requests using the Simple Certificate Enrollment Protocol (SCEP)." }
        'CertificateMaintenance' { $Description = "Maintains certificates for Active Directory Domain Services and management points." }
        'CIAgent' { $Description = "Records details about the process of remediation and compliance for compliance settings, software updates, and application management." }
        'CIDownloader' { $Description = "Records details about configuration item definition downloads." }
        'CIStateStore' { $Description = "Records changes in state for configuration items, such as compliance settings, software updates, and applications." }
        'CIStore' { $Description = "Records information about configuration items, such as compliance settings, software updates, and applications." }
        'CITaskMgr' { $Description = "Records tasks for each application and deployment type, such as content download and install or uninstall actions." }
        'ClientAuth' { $Description = "Records signing and authentication activity for the client." }
        'ClientLocation' { $Description = "Records tasks that are related to client site assignment." }
        'ClientServicing' { $Description = "Records information for client deployment state messages during auto-upgrade and client piloting." }
        'CMBITSManager' { $Description = "Records information for Background Intelligent Transfer Service (BITS) jobs on the device." }
        'CMHttpsReadiness' { $Description = "Records the results of running the Configuration Manager HTTPS Readiness Assessment Tool. This tool checks whether computers have a public key infrastructure (PKI) client authentication certificate that can be used with Configuration Manager." }
        'CmRcService' { $Description = "Records information for the remote control service." }
        'CoManagementHandler' { $Description = "Use to troubleshoot co-management on the client." }
        'ComplRelayAgent' { $Description = "Records information for the co-management workload for compliance policies." }
        'ContentTransferManager' { $Description = "Schedules the Background Intelligent Transfer Service (BITS) or Server Message Block (SMB) to download or access packages." }
        'execmgr' { $Description = "Records details about packages and task sequences that run on the client." }
        'DCMAgent' { $Description = "Records high-level information about the evaluation, conflict reporting, and remediation of configuration items and applications." }
        'DCMReporting' { $Description = "Records information about reporting policy platform results into state messages for configuration items." }
        'DcmWmiProvider' { $Description = "Records information about reading configuration item synclets from WMI." }
        'DeltaDownload' { $Description = "Records information about the download of express updates and updates downloaded using Delivery Optimization." }
        'Diagnostics' { $Description = "Records the status of client diagnostic actions." }
        'EndpointProtectionAgent' { $Description = "Records information about the installation of the System Center Endpoint Protection client and the application of antimalware policy to that client." }
        'ExpressionSolver' { $Description = " Records details about enhanced detection methods that are used when verbose or debug logging is turned on" }
        'ExternalEventAgent' { $Description = "Records the history of Endpoint Protection malware detection and events related to client status" }
        'FileBITS' { $Description = "Records all SMB package access tasks." }
        'FileSystemFile' { $Description = "Records the activity of the Windows Management Instrumentation (WMI) provider for software inventory and file collection." }
        'FSPStateMessage' { $Description = "Records the activity for state messages that are sent to the fallback status point by the client." }
        'InternetProxy' { $Description = "Records the network proxy configuration and use activity for the client." }
        'InventoryAgent' { $Description = "Records activities of hardware inventory, software inventory, and heartbeat discovery actions on the client." }
        'LocationCache' { $Description = "Records the activity for location cache use and maintenance for the client." }
        'LocationServices' { $Description = "Records the client activity for locating management points, software update points, and distribution points." }
        'M365AHandler' { $Description = "Information about the Desktop Analytics settings policy" }
        'Mifprovider' { $Description = "Records the activity of the WMI provider for Management Information Format (MIF) files." }
        'mtrmgr' { $Description = "Monitors all software metering processes." }
        'PolicyAgent' { $Description = "Records requests for policies made by using the Data Transfer Service." }
        'PolicyAgentProvider' { $Description = "Records policy changes." }
        'PolicyEvaluator' { $Description = "Records details about the evaluation of policies on client computers, including policies from software updates." }
        'PolicyPlatformClient' { $Description = "Records the process of remediation and compliance for all providers located in \Program Files\Microsoft Policy Platform, except the file provider." }
        'PolicySdk' { $Description = "Records activities for policy system SDK interfaces." }
        'Pwrmgmt' { $Description = "Records information about enabling or disabling and configuring the wake-up proxy client settings." }
        'PwrProvider' { $Description = "Records the activities of the power management provider (PWRInvProvider) hosted in the WMI service. On all supported versions of Windows, the provider enumerates the current settings on computers during hardware inventory and applies power plan settings." }
        "SCClient_*_1" { $Description = "Records the activity in Software Center for the specified user on the client computer." }
        "SCClient_*_2" { $Description = "Records the historical activity in Software Center for the specified user on the client computer." }
        'Scheduler' { $Description = "Records activities of scheduled tasks for all client operations." }
        "SCNotify_*_1" { $Description = "Records the activity for notifying users about software for the specified user." }
        "SCNotify_*_2" { $Description = "Records the historical information for notifying users about software for the specified user." }
        'Scripts' { $Description = "Records the activity of when Configuration Manager scripts run on the client." }
        'SensorWmiProvider' { $Description = "Records the activity of the WMI provider for the endpoint analytics sensor." }
        'SensorEndpoint' { $Description = "Records the execution of endpoint analytics policy and upload of client data to the site server." }
        'SensorManagedProvider' { $Description = "Records the gathering and processing of events and information for endpoint analytics." }
        'setuppolicyevaluator' { $Description = "Records configuration and inventory policy creation in WMI." }
        "SleepAgent_*" { $Description = "The main log file for wake-up proxy." }
        'SmsClientMethodProvider' { $Description = "Records activity for sending client schedules. For example, with the Send Schedule tool or other programmatic methods." }
        'smscliui' { $Description = "Records use of the Configuration Manager client in Control Panel." }
        'SrcUpdateMgr' { $Description = "Records activity for installed Windows Installer applications that are updated with current distribution point source locations." }
        'StateMessageProvider' { $Description = "Records information for the component that sends state messages from the client to the site." }
        'StatusAgent' { $Description = "Records status messages that are created by the client components." }
        'SWMTRReportGen' { $Description = "Generates a use data report that is collected by the metering agent. This data is logged in Mtrmgr.log." }
        'UserAffinityProvider' { $Description = "Technical details from the component that tracks user device affinity." }
        'VirtualApp' { $Description = "Records information specific to the evaluation of Application Virtualization (App-V) deployment types." }
        'Wedmtrace' { $Description = "Records operations related to write filters on Windows Embedded clients." }
        'wakeprxy-install' { $Description = "Records installation information when clients receive the client setting option to turn on wake-up proxy." }
        'wakeprxy-uninstall' { $Description = "Records information about uninstalling wake-up proxy when clients receive the client setting option to turn off wake-up proxy, if wake-up proxy was previously turned on." }
        'ccmsetup' { $Description = "Records ccmsetup.exe tasks for client setup, client upgrade, and client removal. Can be used to troubleshoot client installation problems." }
        'ccmsetup-ccmeval' { $Description = "Records ccmsetup.exe tasks for client status and remediation." }
        'CcmRepair' { $Description = "Records the repair activities of the client agent." }
        'client.msi' { $Description = "Records setup tasks done by client.msi. Can be used to troubleshoot client installation or removal problems." }
        'ClientServicing' { $Description = "Records information for client deployment state messages during auto-upgrade and client piloting." }
        'AlternateHandler' { $Description = "Records details when the client calls the Office click-to-run COM interface to download and install Microsoft 365 Apps for enterprise client updates. It's similar to use of WuaHandler when it calls the Windows Update Agent API to download and install Windows updates." }
        'UpdatesDeploymentAgent' { $Description = "Records details about deployments on the client, including software update activation, evaluation, and enforcement. Verbose logging shows additional information about the interaction with the client user interface." }
        'DataTransferService' { $Description = "Records all BITS communication for policy or package access. This log also is used for content management by pull-distribution points." }
    }  # End Switch

    Return $Description

}  # End Function Get-ComponentDescription
