Function Install-PowerShellCore {
<#
.SYNOPSIS
This cmdlet is used to install/update PowerShell Core on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates PowerShell Core installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-PowerShellCore
# This example downloads the PowerShell Core installer and verifies the checksum before installing it

.EXAMPLE
Install-PowerShellCore -OutFile "$env:TEMP\PowerShell-version-win-x64.msi"
# This example downloads the PowerShell Core installer and verifies the checksum before installing it

.EXAMPLE
Install-PowerShellCore -OutFile "$env:TEMP\PowerShell-version-win-x64.msi" -DownloadOnly
# This example downloads the FileZilla installer and verifies the checksum


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
                Position=1,
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [ValidateScript({$_ -like "*.msi"})]
            [String]$OutFile = "$env:TEMP\PowerShell-version-win-x64.msi",
 
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

    $Uri = 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
    $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36'

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading PowerShell Core from GitHub"
    Try {
 
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -ContentType 'application/json; charset=utf-8'
        $DownloadLink = ($GetLinks.assets | Where-Object -Property Name -like "*PowerShell-*-win-x64.msi").browser_download_url
        $DResponse = Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -UserAgent $UserAgent -OutFile $OutFile -Method GET -ContentType 'application/octet-stream'
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    $CheckSum = ($GetLinks.body.Split("-") | Where-Object -FilterScript { $_ -like "*$FileHash*" } | Out-String).Trim().ToLower()
   
    If ($FileHash -eq $CheckSum) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for PowerShell Core"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of PowerShell Core"
            Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList @('/i', "$OutFile", '/quiet') -NoNewWindow -Wait -PassThru
       
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for PowerShell Core"
 
    }  # End If Else
 
}  # End Function Install-PowerShellCore
