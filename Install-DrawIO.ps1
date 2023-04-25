Function Install-DrawIO {
<#
.SYNOPSIS
This cmdlet is used to install/update Draw.IO for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates Draw.IO installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-DrawIO
# This example downloads the Draw.IO installer and verifies the checksum before installing it

.EXAMPLE
Install-DrawIO -OutFile "$env:TEMP\Draw.IOClientx64.exe"
# This example downloads the Draw.IO installer and verifies the checksum before installing it

.EXAMPLE
Install-DrawIO -OutFile "$env:TEMP\Draw.IOClientx64.exe" -DownloadOnly
# This example downloads the Draw.IO installer and verifies the checksum


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
            [String]$OutFile = "$env:TEMP\draw.io-version-windows-installer.exe",
 
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
    
    $Uri = 'https://api.github.com/repos/jgraph/drawio-desktop/releases/latest'
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Notepad++ from GitHub"
    Try {
        
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -ContentType 'application/json; charset=utf-8'
        $DownloadLink = ($GetLinks.assets | Where-Object -Property Name -like "draw.io-*-windows-installer.exe").browser_download_url
        $CheckSumLink = ($GetLinks.assets | Where-Object -FilterScript { $_.Name -like "Files-SHA256-Hashes.txt" }).browser_download_url
   
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Draw.IO"
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadLink -UserAgent $UserAgent -OutFile $OutFile -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Getting hash values for Draw.IO"
    $Version = (Get-Item -Path $OutFile).VersionInfo.ProductVersion
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    $CheckSum = ((Invoke-WebRequest -UseBasicParsing -Uri $CheckSumLink -UserAgent $UserAgent -ContentType 'application/octet-stream' -Method GET -Verbose:$False).RawContent.Split("`n") | Where-Object -FilterScript { $_ -like "draw.io-$($Version.Trim())-windows-installer.exe *"}).Split(' ')[-1]
   
    If ($CheckSum -eq $FileHash) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for Draw.IO version $Version"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Draw.IO version $Version"
            Move-Item -Path $OutFile -Destination $OutFile.Replace("version", $Version) -Force -Confirm:$False
            Start-Process -FilePath $OutFile -ArgumentList @('/S') -NoNewWindow -Wait -PassThru
 
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for Draw.IO version $Version"
 
    }  # End If Else
   
}  # End Function Install-DrawIO
