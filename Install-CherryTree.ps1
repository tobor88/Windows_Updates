Function Install-CherryTree {
<#
.SYNOPSIS
This cmdlet is used to install/update CherryTree for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates CherryTree installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-CherryTree
# This example downloads the CherryTree installer and verifies the checksum before installing it

.EXAMPLE
Install-CherryTree -OutFile "$env:TEMP\CherryTreeClientx64.exe"
# This example downloads the CherryTree installer and verifies the checksum before installing it

.EXAMPLE
Install-CherryTree -OutFile "$env:TEMP\CherryTreeClientx64.exe" -DownloadOnly
# This example downloads the CherryTree installer and verifies the checksum


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
            [String]$OutFile = "$env:TEMP\cherrytree-version_win64_setup.exe",
 
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
    
    $Uri = "https://api.github.com/repos/giuspen/cherrytree/releases/latest"
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading CherryTree from GitHub"
    Try {
        
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -ContentType 'application/json; charset=utf-8' -Verbose:$False
        $DownloadLink = ($GetLinks.assets | Where-Object -Property Name -like "cherrytree_*_win64_setup.exe").browser_download_url

    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading CherryTree"
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadLink -UserAgent $UserAgent -OutFile $OutFile -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Getting hash values for CherryTree"
    $Version = (Get-Item -Path $OutFile).VersionInfo.ProductVersion
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    $CheckSum = ((Invoke-WebRequest -UseBasicParsing -Uri "https://www.giuspen.net/cherrytree/#downl" -UserAgent $UserAgent -ContentType 'text/html; charset=UTF-8' -Verbose:$False).RawContent.Split("`n") | Select-String -Pattern "cherrytree_$($Version.Trim())_win64_setup.exe" | Out-String).Split(" ")[-3].Split('>')[-1].Trim()

    If ($CheckSum -eq $FileHash) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for CherryTree version $Version"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of CherryTree version $Version"
            Move-Item -Path $OutFile -Destination $OutFile.Replace("version", $Version) -Force -Confirm:$False
            Start-Process -FilePath $OutFile.Replace("version", $Version) -ArgumentList @('/VERYSILENT') -NoNewWindow -Wait -PassThru
 
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for CherryTree version $Version"
 
    }  # End If Else
   
}  # End Function Install-CherryTree
