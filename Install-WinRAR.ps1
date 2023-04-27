Function Install-WinRAR {
<#
.SYNOPSIS
This cmdlet is used to install/update WinRAR for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates WinRAR installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-WinRAR
# This example downloads the WinRAR installer and verifies the checksum before installing it

.EXAMPLE
Install-WinRAR -OutFile "$env:TEMP\WinRAR-Installer.exe"
# This example downloads the WinRAR installer and verifies the checksum before installing it

.EXAMPLE
Install-WinRAR -OutFile "$env:TEMP\WinRAR-Installer.exe" -DownloadOnly
# This example downloads the WinRAR installer and verifies the checksum


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
            [String]$OutFile = "C:\Windows\Temp\winrar-x64-version.exe",
 
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch]$DownloadOnly,
 
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch]$TryTLSv13
        )  # End param
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.2"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    If ($TryTLSv13.IsPresent) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.3"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls13
 
    }  # End If
 
    $OutFile = $OutFile.Replace("version",$WrVersion)
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
    $WrVersion = (((Invoke-WebRequest -Uri https://www.rarlab.com/ -UseBasicParsing -UserAgent $UserAgent -Method GET).Links | Where-Object -FilterScript { $_.outerHTML -like "*/rar/winrar-x64-*" }).href.Split('=').Split('.') | Where-Object -FilterScript { $_ -match "(.*)\d{1,6}$"}).Split('-')[-1]
    $DownloadLink = https://rarlab.com/rar/winrar-x64-$WrVersion.exe
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading WinRAR version $WrVersion"
    Try {
 
        (New-Object -TypeName System.Net.WebCLient).DownloadFile("$DownloadLink", "$OutFile")
 
    } Catch [System.Net.WebException] {
 
        If ($Error[0] -like "*Request forbidden by administrative rules.*") {
 
            Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -Method GET -ContentType 'application/octet-stream' -UserAgent $UserAgent -OutFile $OutFile -Verbose:$False -ErrorAction Stop | Out-Null
       
        } Else {
 
            Throw $Error[0]
 
        }  # End If Else
 
    } Catch {
 
        Throw $Error[0]
 
    }  # End Try Catch Catch
 
    Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') WinRAR does NOT offer a checksum value to verify a files integrity with. Use 7Zip it is way better"
    If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
        Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded WinRAR file and verified hash.`n[i] File saved to $OutFile"
 
    } Else {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of WinRAR version $WrVersion"
        Start-Process -FilePath $OutFile -ArgumentList @('/S') -NoNewWindow -Wait -PassThru -ErrorAction Stop
 
    }  # End If Else
 
}  # End Function Install-WinRAR
