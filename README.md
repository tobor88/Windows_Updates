# Windows Updates
This repository contains a collection of PowerShell cmdlets that are useful in updating Windows and troubleshooting issues. Updates that deal with SCCM are also included.

### Cmdlet List
- **Clear-GpoRegistrySettings.ps1** (*Fix failed Windows Updates caused by policy errors*)
- **Get-WindowsUpdateError.ps1** (*Save a log file to your desktop containing logs on Windows Updates*)
- **Get-WindowsUpdateErrorCode.ps1** (*Return the error code reason for failed Windows Updates, save log files to desktop, and option to run troubleshooter*)
- **Remove-WindowsUpdate.ps1** (*Uninstall a Windows Update by KB number on a remote or local device*)
- **Repair-WindowsUpdate.ps1** (*Stops Windows Update related services and renames directory locations which fixes 90% of all update issues in my experience*)
- **Update-Windows.ps1** (*Install any missing Windows Updates*)

### I am merely a contributor to the Update-Windows script. I have modified it to work with the web application and wrote the other functions in the module.
__REFERENCE:__ <a href="https://social.technet.microsoft.com/Forums/en-US/6f35129d-735d-4ca0-8cc4-786ae901e4f2/powershell-script-to-download-install-windows-updates?forum=winserverwsus">HERE</a> 
__REFERENCE:__ <a href="https://gallery.technet.microsoft.com/scriptcenter/Reset-WindowsUpdateps1-e0c5eb78">HERE</a>. 

I have added some functionality and improved them wherever I saw fit.

If you make any changes or find a better way to do something feel free to send it to me so I have it too. :)

I will also add a script to configure everything needed once everything is said and done.
