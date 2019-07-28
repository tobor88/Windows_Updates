<#
.Synopsis
    Repair-UpdateFailure is a cmdlet created to run Windows Update Troubleshooting steps through a PowerShell Command.
    This works best used with Task Scheduler or inside a Windows Update PowerShell script.

.DESCRIPTION
    Repair-UpdateFailure is a cmdlet created to run Windows Update Troubleshooting steps through a PowerShell Command.

.NOTES
    Author: Ryan Nemeth
    Contributor: Rob Osborne
    Alias: tobor
    Contact: rosborne@osbornepro.com
    https://roberthosborne.com
    
.RELATED LINKS
    Original Version: https://gallery.technet.microsoft.com/scriptcenter/Reset-WindowsUpdateps1-e0c5eb78

.EXAMPLE
   Repair-UpdateFailure

.EXAMPLE
   Repair-UpdateFailure -Verbose
#>
Function Repair-UpdateFailure {
    [CmdletBinding()]
        param()

    Set-Location -Path "$env:SystemRoot\System32" 
    
    Write-Verbose "1.) Stopping Windows Update Services..." 
    Stop-Service -Name "BITS", "wuauserv", "appidsvc", "cryptsvc" 

    Write-Verbose "2.) Remove QMGR Data file..." 
    Remove-Item -Path "$env:AllUsersProfile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue -Force

    Write-Verbose "3.) Backing up the now old Software Distribution directory..." 
    Rename-Item -Path "$env:SystemRoot\SoftwareDistribution" -NewName "SoftwareDistribution.bak" -ErrorAction SilentlyContinue -Force

    Write-Verbose "4.) Backing up the now old CatRoot2 Directory..."
    Rename-Item -Path "$env:SystemRoot\System32\Catroot2" -NewName "catroot2.bak" -ErrorAction SilentlyContinue -Force 

    Write-Verbose "5.) Removing old Windows Update log..." 
    Remove-Item -Path "$env:SystemRoot\WindowsUpdate.log" -ErrorAction SilentlyContinue -Force

    Write-Verbose "6.) Resetting the Windows Update Services to defualt settings..." 
    cmd.exe /C "sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
    cmd.exe /C "sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
    
    Write-Verbose "7.) Registering some DLLs..." 
    $RegistryDllFiles = "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll", "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll", "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll", "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll", "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll", "wuapi.dll", "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll", "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll" 

    ForEach ($Dll in $RegistryDllFiles)
    {

        Start-Process -FilePath 'regsvr32.exe' -Args "/s $env:SystemRoot\System32" -Wait -NoNewWindow -PassThru

    } # End ForEach

    Write-Verbose "8.) Removing WSUS client settings..." 
    $WSUSSettings = "AccountDomainSid", "PingID", "SusClientId"

    ForEach ($WSUSSetting in $WSUSSettings)
    {

        Remove-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name $WSUSSetting -ErrorAction SilentlyContinue -Force
    
    } # End ForEach

    Write-Verbose "9.) Resetting the WinSock..." 
    netsh winsock reset 
    netsh winhttp reset proxy 
    
    Write-Verbose "10.) Delete all BITS jobs..." 
    Get-BitsTransfer | Remove-BitsTransfer 
    
    Write-Verbose "11.) Attempting to install the Windows Update Agent..." 
    If ($env:PROCESSOR_ARCHITECTURE -like "*64") 
    {

        wusa Windows8-RT-KB2937636-x64 /quiet 

    } # End If 
    Else
    { 

        wusa Windows8-RT-KB2937636-x86 /quiet 

    } # End Else 
    
    Write-Verbose "12.) Starting Windows Update Services..." 
    Start-Service -Name "BITS", "wuauserv", "appidsvc", "cryptsvc"
    
    Write-Verbose "13.) Forcing discovery..." 
    $UpdateSearch = New-Object -ComObject Microsoft.Update.Searcher
    $UpdateSearch.Search("IsInstalled=0 and Type='Software' and IsHidden=0") | Out-Null

    Write-Verbose "Running DISM tool to cleanup any image corruptions"
    DISM /Online /Cleanup-Image /RestoreHealth

    Write-Verbose "Checing for and repairing any Critical WIndows Files and the corresponding registry values."
    sfc /scannow

    [int]$HourOfDay = Get-Date -Format HH

    If ($HourOfDay -lt 7 -or $HourOfDay -gt 17)
    {

        Restart-Computer -Force -WhatIf

    } # End If
    Elseif ($HourOfDay -ge 7 -and $HourOfDay -lt 18)
    {

        $WaitTime = (18 - $HourOfDay) * 3600 # Converts Hours into Seconds for the Timeout Paramter in Restart-Computer

        Restart-Computer -Timeout $WaitTime -Force

    } # End Elseif

} # End Function
