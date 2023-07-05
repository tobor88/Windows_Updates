Function Install-AzureStorageExplorer {
<#
.SYNOPSIS
This cmdlet is used to install/update Azure Storage Explorer for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates Azure Storage Explorer installed for Windows. I have not found a checksum to verify the hash


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 4/26/2023 due to 1.3 being so new


.EXAMPLE
Install-AzureStorageExplorer
# This example downloads the Azure Storage Explorer installer. I have not found a check to verify the hash before installing it

.EXAMPLE
Install-AzureStorageExplorer -OutFile "$env:TEMP\Windows_StorageExplorer.exe"
# This example downloads the Azure Storage Explorer installer and verifies the checksum before installing it

.EXAMPLE
Install-AzureStorageExplorer -OutFile "$env:TEMP\Windows_StorageExplorer.exe" -DownloadOnly
# This example downloads the Azure Storage Explorer installer and verifies the checksum


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
            [String]$OutFile = "C:\Windows\Temp\Windows_StorageExplorer.exe",
 
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
    $Uri = "https://api.github.com/repos/Microsoft/AzureStorageExplorer/releases/latest"
   
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Azure Storage Explorer from GitHub"
    Try {
 
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -ContentType 'application/json; charset=utf-8' -Verbose:$False
        $DownloadLink = ($GetLinks.assets | Where-Object -FilterScript { $_.Name -like "Windows-StorageExplorer.exe"}).browser_download_url
        Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -UserAgent $UserAgent -OutFile $OutFile -Method GET -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch

    If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {

        Write-Warning -Message "[!] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') I have not found a checksum value online to compare for Azure Storage Explorer"
        Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file for Azure Storage Explorer.`n[i] File saved to $OutFile"

    } Else {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Windows Azure Storage Explorer for Windows"
        Start-Process -FilePath $OutFile -ArgumentList @('/VERYSILENT', '/NORESTART', '/ALLUSERS') -NoNewWindow -Wait -PassThru -ErrorAction Stop

    }  # End If Else

}  # End Function Install-AzureStorageExplorer
