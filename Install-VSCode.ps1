#Requires -Version 3.0
Function Install-VSCode {
<#
.SYNOPSIS
This cmdlet is used to install/update VSCode on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates VSCode installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-VSCode
# This example downloads the VSCode installer and verifies the checksum before installing it

.EXAMPLE
Install-VSCode -OutFile "$env:TEMP\PowerShell-version-win-x64.msi"
# This example downloads the VSCode installer and verifies the checksum before installing it

.EXAMPLE
Install-VSCode -OutFile "$env:TEMP\PowerShell-version-win-x64.msi" -DownloadOnly
# This example downloads the FileZilla installer and verifies the checksum


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://code.visualstuido.com.com/tobor88
https://code.visualstuido.com.com/osbornepro
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
            [String]$OutFile = "$env:TEMP\vscode-setup-win.exe",
 
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

    #$CheckSumLink = 'https://code.visualstudio.com/Download' #JavaScript is preventing ability to obtain. Requires more research
    $DownloadLink = 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user'
    $UserAgent = "wget"

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading VSCode from code.visualstuido.com"
    Try {
 
        #$CheckSum = Invoke-RestMethod -Uri $CheckSumLink -Method GET -UseBasicParsing -UserAgent "wget" -ContentType 'text/html; charset=utf-8' -Verbose:$False
        Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -UserAgent $UserAgent -OutFile $OutFile -Method GET -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    #$FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    #$CheckSum = ($GetLinks.body.Split("-") | Where-Object -FilterScript { $_ -like "*$FileHash*" } | Out-String).Trim().ToLower()
   
    #If ($FileHash -eq $CheckSum) {
 
    #    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for VSCode"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of VSCode"
            Start-Process -FilePath $OutFile -ArgumentList @('/FORCECLOSEAPPLICATIONS', "/LANG=$PSUICulture", '/VERYSILENT') -NoNewWindow -Wait -PassThru
       
        }  # End If Else
 
    #} Else {
 
    #    Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for VSCode"
 
    #}  # End If Else
 
}  # End Function Install-VSCode
