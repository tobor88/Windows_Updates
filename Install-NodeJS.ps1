Function Install-NodeJS {
<#
.SYNOPSIS
This cmdlet is used to install/update NodeJS for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the latest NodeJS installed for Windows, verify the checksum and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 7/5/2023 due to 1.3 being so new


.EXAMPLE
Install-NodeJS
# This example downloads the NodeJS installer and verifies the checksum before installing it

.EXAMPLE
Install-NodeJS -OutFile "$env:TEMP\NodeJS-Installer.exe"
# This example downloads the NodeJS installer and verifies the checksum before installing it

.EXAMPLE
Install-NodeJS -OutFile "$env:TEMP\NodeJS-Installer.exe" -DownloadOnly
# This example downloads the NodeJS installer and verifies the checksum


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
            [ValidateScript({$_ -like "*.msi"})]
            [String]$OutFile = "$env:TEMP\node-installer.msi",
 
            [Parameter(
                Position=1,
                Mandatory=$False
            )]  # End Parameter
            [ValidateSet("86", "64")]
            [String]$Architecture = $(If ($env:PROCESSOR_ARCHITECTURE -like "AMD64") { "64" } Else { "86" }),
 
            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [Switch]$DownloadOnly
        )   # End param
 
    $TlsVersion = "TLSv1.2"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    If ($TryTLSv13.IsPresent) {
 
        $TlsVersion = "TLSv1.3"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls13
 
    }  # End If
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing $TlsVersion"
 
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
    $Uri = "https://api.github.com/repos/nodejs/node/releases/latest"
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Node.JS from GitHub"
    Try {
 
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -Verbose:$False
        $DownloadLink = "https://nodejs.org/dist/$($GetLinks.tag_name)/node-$($GetLinks.tag_name)-x64.msi"
        $CheckSumLink = "https://nodejs.org/dist/$($GetLinks.tag_name)/SHASUMS256.txt"
        Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -UserAgent $UserAgent -OutFile $OutFile -Method GET -Verbose:$False | Out-Null
 
    } Catch {
 
        Throw $Error[0]
 
    }  # End Try Catch Catch
 
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256 -Verbose:$False).Hash.ToLower()
    $CheckSum = ((Invoke-WebRequest -Uri $CheckSumLink -Method GET -UseBasicParsing -UserAgent $UserAgent -Verbose:$False).RawContent.Split("`n") | Where-Object -FilterScript { $_ -like "*node-$($GetLinks.tag_name)-x64.msi" }).Split(' ')[0]
 
    If ($FileHash -eq $CheckSum) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for Node.JS"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Node.JS"
            If (Test-Path -Path $OutFile) {
 
                Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList @('/a', "$OutFile", '/quiet') -NoNewWindow -Wait -PassThru -ErrorAction Stop
 
            } Else {
 
                Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to download file"
 
            }  # End If Else
 
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for Node.JS"
 
    }  # End If Else
 
}  # End Function Install-NodeJS
