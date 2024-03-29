# Windows Updates

This repository contains a collection of PowerShell cmdlets that are useful in updating Windows and troubleshooting issues. Updates that deal with SCCM are also included.


## Cmdlet List

- **Add-CMSystemDiscoveryMethodContainer** (*Adds new LDAP containers to query to the SCCM servers system discovery filter*)
- **Clear-GpoRegistrySettings.ps1** (*Fix failed Windows Updates caused by policy errors*)
- **Get-ComponentDescription** (*Return descriptino of log file based on component name*)
- **Get-KBDownloadLink.ps1** (*Returns a download link for the defined KB article ID for the current OS version and architecture or defined version and architecture*)
- **Get-KnownIssuesWindowsUpdates.ps1** (*Returns information on the latest months Windows patching issues*)
- **Get-MissingDeviceUpdate.ps1** (*Return information on missing updates or approved missing SCCM updates*)
- **Get-SccmSoftwareUpdateStatus.ps1** (*Return device in SCCM matching a certain status such as Error or Unknown*)
- **Get-WindowsUpdateError.ps1** (*Save a log file to your desktop containing logs on Windows Updates*)
- **Get-WindowsUpdateErrorCode.ps1** (*Return the error code reason for failed Windows Updates, save log files to desktop, and option to run troubleshooter*)
- **Get-UpdateHistory.p1** (*Returns information on the history of Windows Updates*)
- **Install-7Zip.ps1** (*Install or update 7Zip. I have not found a checksum to use for verification*)
- **Install-AzureCLI.ps1** (*Install or update the Azure CLI. I have not found a checksum to use for verification*)
- **Install-AzureStorageExplorer.ps1** (*Install or update the Azure Storage Explorer. I have not found a checksum to use for verification*)
- **Install-CherryTree.ps1** (*Install or update CherryTree after verifying checksum*)
- **Install-DrawIO.ps1** (*Install or update Draw.io after verifying checksum*)
- **Install-FileZilla.ps1** (*Install or update FileZilla after verifying checksum*)
- **Install-GitForWindows.ps1** (*Install or update Git for Windows after verifying checksum*)
- **Install-KeePass.ps1** (*Install or update KeePass after verifying checksum*)
- **Install-NodeJS.ps1** (*Install or update NodeJS after verifying checksum*)
- **Install-NotepadPlusPlus.ps1** (*Install or update Notepad++ after verifying checksum*)
- **Install-PowerShellCore.ps1** (*Install or update PowerShell Core after verifying checksum*)
- **Install-Putty.ps1** (*Download and install Putty and verifiy checksum*)
- **Install-RemoteDesktopManager.ps1** (*Download and install Remote Desktop Manager*)
- **Install-SccmAgent.ps1** (*Install or reinstall the SCCM Agent on a device*)
- **Install-Signal.ps1** (*Install or update Signal after verifying checksum*)
- **Install-SSMS.ps1** (*Installs or updates SSMS. No checksum value that can be verified*)
- **Install-VLC.ps1** (*Install or update VLC after verifying checksum*)
- **Install-VSCode.ps1** (*Install or update Visual Studio Code. Unable to verify checksum automatically yet*)
- **Install-WinRAR.ps1** (*Install or update WinRAR. They do not offer a checksum. Use 7Zip its better*)
- **Install-WinSCP.ps1** (*Install or update WinSCP after verifying checksum*)
- **Install-WinSCPNETAssembly.ps1** (*Download the WinSCP DLL required for writing PowerShell scripts with NET assembly. Checksum gets verified*)
- **Invoke-MissingUpdateInstallation.ps1** (*Installs SCCM approved missing updates ona device*)
- **Remove-CMSystemDiscoveryMethodContainer** (*Removes LDAP containers from query on the SCCM servers system discovery filter*)
- **Remove-WindowsUpdate.ps1** (*Uninstall a Windows Update by KB number on a remote or local device*)
- **Repair-WindowsUpdate.ps1** (*Stops Windows Update related services and renames directory locations which fixes 90% of all update issues in my experience*)
- **Reset-SccmAgent.ps1** (*Delete the SCCM cache files and restart the service*)
- **Update-Windows.ps1** (*Install any missing Windows Updates*)


### I am merely a contributor to the Update-Windows script. 

__REFERENCE:__ <a href="https://social.technet.microsoft.com/Forums/en-US/6f35129d-735d-4ca0-8cc4-786ae901e4f2/powershell-script-to-download-install-windows-updates?forum=winserverwsus">HERE</a> 
__REFERENCE:__ <a href="https://gallery.technet.microsoft.com/scriptcenter/Reset-WindowsUpdateps1-e0c5eb78">HERE</a>. 

I have added some functionality and improved them wherever I saw fit.

If you make any changes or find a better way to do something feel free to send it to me so I have it too. :)
