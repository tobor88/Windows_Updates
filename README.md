# Windows Updates
PowerShell Funcitons to avoid having to purchase and install centralized update applications. ASP.NET Core 2.2 will soon be updated to 3.0. 

### Required Applications
- Visual Studio 2019 Preview
- ASP.NET Core SDK v2.2
- PowerShell v5+
- SQL Server 2017 Express

The purpose of these PowerShell modules is to allow admins the ability to automatically deploy Windows Updates for packages already installed on a device. I plan on adding more to these as time goes on to improve their functionality and make them more appealing than paid providers. It is not at 100% yet. I am updating as I go.

### Tasks Carried Out By These Functions
1. Download and Install Needed Windows Updates based on installed packages
2. Create a Log File containing Windows Update Download and Installation information. This log file is saved to C:\Windows\Temp\$env:COMPUTERNAME\ If that directory does not already exist it will of course be created.
3. If an update fails, the same functions the Windows Update Troubleshooter would carry out as done through the Control Panel Troubleshooter or the Settings Troubleshooter will be carried out. The computer will be restarted as long as it is outside business hours. If it is not outside business hours, the script will wait until it is outside business hours to restart the device.
4. Send an Email alert to the System Administrators if an udate fails. This alerts the Administrator an error occured while updating windows. The troubleshooter will run automatically. The admin will need to still verify the troubleshooter worked.
5. To verify the trouble shooter worked, check the log file located at C:\Windows\Temp\$env:COMPUTERNAME\ If there is a .old log file for todays date it means the Windows Update module has run at least twice on that day.
6. Uploads the results to a SQL database for easy viewing. Provides a function to create the database if it does not exist already.

### I am merely a contributor to the Update-Windows script. I have modified it to work with the web application and wrote the other functions in the module.
__REFERENCE:__ <a href="https://social.technet.microsoft.com/Forums/en-US/6f35129d-735d-4ca0-8cc4-786ae901e4f2/powershell-script-to-download-install-windows-updates?forum=winserverwsus">HERE</a> 
__REFERENCE:__ <a href="https://gallery.technet.microsoft.com/scriptcenter/Reset-WindowsUpdateps1-e0c5eb78">HERE</a>. 

I have added some functionality and improved them wherever I saw fit.

If you make any changes or find a better way to do something feel free to send it to me so I have it too. :)

I will also add a script to configure everything needed once everything is said and done.
