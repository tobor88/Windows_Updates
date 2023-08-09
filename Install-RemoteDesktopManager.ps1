Function Install-RemoteDesktopManager {
<#
.SYNOPSIS
This cmdlet is used to install/update Remote Desktop Manager for Windows on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates Remote Desktop Manager installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 8/9/2023 due to 1.3 being so new


.EXAMPLE
Install-RemoteDesktopManager
# This example downloads the RemoteDesktopManager installer and verifies the checksum before installing it

.EXAMPLE
Install-RemoteDesktopManager -OutFile "$env:TEMP\RemoteDesktopManager-Installer.exe"
# This example downloads the Remote Desktop Manager installer and verifies the checksum before installing it

.EXAMPLE
Install-RemoteDesktopManager -OutFile "$env:TEMP\RemoteDesktopManager-Installer.exe" -DownloadOnly
# This example downloads the Remote Desktop Manager installer and verifies the checksum


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://github.com/tobor88
https://github.com/osbornepro
https://www.powershellgallery.com/profiles/tobor
https://osbornepro.com
https://writeups.osbornepro.com
https://encrypit.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges


.INPUTS
None


.OUTPUTS
System.Management.Automation.PSObject
#>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$False
            )]  # End Parameter
            [ValidateScript({$_ -like "*.exe"})]
            [String]$OutFile = "$env:TEMP\RemoteDesktopManager-installer.exe",
    
            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Switch]$DownloadOnly,
    
            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Switch]$TryTLSv13
        )   # End param
    
    $TlsVersion = "TLSv1.2"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    If ($TryTLSv13.IsPresent) {
    
        $TlsVersion = "TLSv1.3"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls13
    
    }  # End If
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing $TlsVersion"
    
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
    $VersionUri = "https://devolutions.net/remote-desktop-manager/home/download/"
    $Version = (((Invoke-WebRequest -UseBasicParsing -Uri $VersionUri -Method GET -UserAgent $UserAgent -ContentType 'text/html' -Verbose).Content.Split("`n") | Select-String -Pattern "data-g-version=")[0] | Out-String).Trim().Split('"')[1]
    $Uri = "https://cdn.devolutions.net/download/Setup.RemoteDesktopManager.$($Version).exe"
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading RemoteDesktopManager"
    Invoke-WebRequest -UseBasicParsing -Method GET -Uri $Uri -OutFile $OutFile -UserAgent $UserAgent -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Getting hash values for RemoteDesktopManager"
    #$FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA512).Hash.ToLower()

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for Remote Desktop Manager version $Version"
    If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash: $OutFile"

    } Else {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Remote Desktop Manager version $Version"
        Start-Process -FilePath $OutFile -ArgumentList @('/S') -NoNewWindow -Wait -PassThru

    }  # End If Else
    
}  # End Function Install-RemoteDesktopManager
