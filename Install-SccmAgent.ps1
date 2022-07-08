<#
.SYNOPSIS
This cmdlet is used to install the SCCM Agent or Reinstall the SCCM agent on a local machine


.DESCRIPTION
Install the SCCM agent or reinstall the SCCM agent. This will require you to have a location to install the ccmsetup.exe file from


.PARAMETER FilePath
Set the aboslute path to the ccmsetup.exe file you want to use to install the SCCM Agent

.PARAMETER SiteCode
Define the Site Code for your SCCM server that should be used during the ccmsetup.exe installation

.PARAMETER Destination
Define the destination directory to save your ccmsetup.exe file too

.PARAMETER ReInstall
Set this parameter when you want to reinstall the SCCM Agent locally on a machine


.EXAMPLE
Install-SccmAgent -FilePath \\sccmserver\D$\Installer\ccmsetup.exe -Destination $env:TEMP -SiteCode OBP
# This example copies ccmsetup.exe to your users temp directory and install the SCCM Agent using site code OBP

.EXAMPLE
Install-SccmAgent -FilePath \\sccmserver\D$\Installer\ccmsetup.exe -SiteCode OBP -ReInstall
# This example copies ccmsetup.exe to your Downloads directory and uninstalls, waits 15 minutes then reinstalls the SCCM agent using site code OBP


.INPUTS
None
  
  
.OUTPUTS
None


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
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
  Function Install-SccmAgent {
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Enter the absolute path to the ccmsetup.exe file you wish to install. EXAMPLE: C:\Temp\ccmsetup.exe : "
            )]  # End Parameter
            [ValidateScript({[System.IO.File]::Exists($_)})]
            [String]$FilePath,
            
            [Parameter(
                Position=1,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Enter the site code to use when install the ccmsetup.exe file EXAMPLE: ABC : "
            )]  # End Parameter
            [String]$SiteCode,

            [Parameter(
                Position=2,
                Mandatory=$False,
                ValueFromPipeline=$False,
                HelpMessage="Enter the absolute path to the directory you wish to copy ccmsetup.exe too. EXAMPLE: C:\Temp : "
            )]  # End Parameter
            [ValidateScript({[System.IO.Directory]::Exists($_)})]
            [String]$Destination = "$env:USERPROFILE\Downloads",

            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Switch][Bool]$ReInstall
        )  # End param

    Write-Verbose "Copying installation file to $env:COMPUTERNAME"
    $FileName = $FilePath.Split("\")[-1]
    $Source = $FilePath.Replace("\$($FileName)","")

    robocopy $Source $Destination $FileName

    If ($ReInstall.IsPresent) {

        Write-Verbose "Uninstalling the SCCM Agent on $env:COMPUTERNAME"
        Start-Process -FilePath "$Destination\ccmsetup.exe" -ArgumentList @("/uninstall") -NoNewWindow  -Wait
   
        Start-Sleep -Seconds 300
   
    }  # End If

    Write-Verbose "Installing the SCCM Agent on $env:COMPUTERNAME"
    Start-Process -FilePath "$Destination\ccmsetup.exe" -ArgumentList @("SMSSITECODE=$SiteCode") -NoNewWindow -Wait

}  # End Function Install-SccmAgent
