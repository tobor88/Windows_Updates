Function Install-AzureCli {
<#
.SYNOPSIS
This cmdlet is used to install/update AzureCli for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates AzureCli installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-AzureCli
# This example downloads the AzureCli installer and verifies the checksum before installing it

.EXAMPLE
Install-AzureCli -OutFile "$env:TEMP\AzureCli-Setup.exe"
# This example downloads the AzureCli installer and verifies the checksum before installing it

.EXAMPLE
Install-AzureCli -OutFile "$env:TEMP\AzureCli-Setup.exe" -DownloadOnly
# This example downloads the AzureCli installer and verifies the checksum


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
            [String]$OutFile = "C:\Windows\Temp\azure-cli-version.msi",
 
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch]$DownloadOnly,
 
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch]$TryTLSv13
        )   # End param
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.2"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    If ($TryTLSv13.IsPresent) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.3"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls13
 
    }  # End If
 
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox  
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Azure CLI from GitHub"
    Try {
 
        $DownloadLink = 'https://aka.ms/installazurecliwindows'
        Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -UserAgent $UserAgent -OutFile $OutFile -Method GET -Verbose:$False | Out-Null
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') I have not been able to find a checksum for the Azure CLI installer file"
    If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {

        Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file for Azure CLI.`n[i] File saved to $OutFile"

    } Else {

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Microsoft Azure CLI for Windows"
    If (Test-Path -Path $OutFile) {

        Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList @('/i', "$OutFile", '/quiet') -NoNewWindow -Wait -PassThru -ErrorAction Stop

    } Else {

        Throw "[x] Failed to download file for Azure CLI"

    }  # End If Else
 
}  # End FunctionInstall-AzureCli