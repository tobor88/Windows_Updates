Function Install-Signal {
<#
.SYNOPSIS
This cmdlet is used to install/update Signal for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates Signal installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-Signal
# This example downloads the Signal installer and verifies the checksum before installing it

.EXAMPLE
Install-Signal -OutFile "$env:TEMP\SignalClientx64.exe"
# This example downloads the Signal installer and verifies the checksum before installing it

.EXAMPLE
Install-Signal -OutFile "$env:TEMP\SignalClientx64.exe" -DownloadOnly
# This example downloads the Signal installer and verifies the checksum


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
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [ValidateScript({$_ -like "*.exe"})]
            [String]$OutFile = "$env:TEMP\SignalSetup.exe",
 
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$DownloadOnly,

            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$TryTLSv13
        )   # End param
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.2"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    If ($TryTLSv13.IsPresent) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.3"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls13

    }  # End If
    
    $Uri = 'https://api.github.com/repos/signalapp/Signal-Desktop/releases/latest'
    $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36'

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Notepad++ from GitHub"
    Try {
        
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -ContentType 'application/json; charset=utf-8'
        $Version = $GetLinks.name.Replace("v", "")
        $DownloadLink = "https://updates.signal.org/desktop/signal-desktop-win-$($Version).exe"

    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Signal"
    $DResponse = Invoke-WebRequest -UseBasicParsing -Uri $DownloadLink -UserAgent $UserAgent -OutFile $OutFile -ContentType 'application/octet-stream'

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for Signal version $Version"
    If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
        Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
    } Else {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Signal version $Version"
        Start-Process -FilePath $OutFile -ArgumentList @('/S') -NoNewWindow -Wait -PassThru
 
    }  # End If Else

}  # End Function Install-Signal
