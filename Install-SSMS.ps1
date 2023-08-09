Function Install-SSMS {
<#
.SYNOPSIS
This cmdlet is used to install/update SQL Server Management Studio (SSMS) on a Windows machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates SQL Server Management Studio and install for Windows


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 8/9/2023 due to 1.3 being so new


.EXAMPLE
Install-SSMS
# This example downloads the SSMS installer and installs it

.EXAMPLE
Install-SSMS -OutFile "$env:TEMP\SSMS-installer.exe"
# This example downloads the SSMS installer and installs it

.EXAMPLE
Install-SSMS -OutFile "$env:TEMP\SSMS-installer.exe" -DownloadOnly
# This example downloads the SSMS installer


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
            [String]$OutFile = "$env:TEMP\SSMS-installer.exe",
 
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
    $Uri = 'https://aka.ms/ssmsfullsetup'

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading SSMS from Microsoft"
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -OutFile $OutFile -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Getting hash values for SSMS"
    $Version = (Get-Item -Path $OutFile).VersionInfo.FileVersion
    #$FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA512).Hash.ToLower()

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for SSMS version $Version"
    If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file: $OutFile"

    } Else {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of SSMS version $Version"
        Start-Process -FilePath $OutFile -ArgumentList "/Install /Quiet" -NoNewWindow -Wait -PassThru

    }  # End If Else
   
}  # End Function Install-SSMS
