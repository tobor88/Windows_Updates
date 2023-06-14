Function Install-VLC {
<#
.SYNOPSIS
This cmdlet is used to install/update VLC for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates VLC installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-VLC
# This example downloads the VLC installer and verifies the checksum before installing it

.EXAMPLE
Install-VLC -OutFile "$env:TEMP\vlc-3.0.18-win64.exe"
# This example downloads the VLC installer and verifies the checksum before installing it

.EXAMPLE
Install-VLC -OutFile "$env:TEMP\vlc-3.0.18-win64.exe" -DownloadOnly
# This example downloads the VLC installer and verifies the checksum


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
            [String]$OutFile = "$env:TEMP\vlc-version-win64.exe",
 
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
    
    $Uri = 'https://www.videolan.org/vlc/download-windows.html'
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading VLC from GitHub"
    Try {
        
        $GetLinks = Invoke-WebRequest -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -ContentType 'text/html' -Verbose:$False
        $DLLink = "https:" + $($GetLinks.Links | Where-Object -FilterScript { $_.href -like "*//get.videolan.org*" -and $_.outerHTML -like "*win64.exe*" } | Select-Object -ExpandProperty href -First 1)
        $Version = $DownloadLink.Split('-')[-2]
        $DownloadLink = "https://mirrors.ocf.berkeley.edu/videolan-ftp/vlc/$($Version)/win64/vlc-$($Version)-win64.exe"

    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading VLC"
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadLink -UserAgent $UserAgent -OutFile $OutFile -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    $CheckSum = ((Invoke-RestMethod -UseBasicParsing -Uri $DLLink -UserAgent $UserAgent -ContentType 'text/html; charset=UTF-8' -Method GET -Verbose:$False).Split("`n") | Where-Object -FilterScript { $_ -like "*Display Checksum*" }).Split(':')[-1].Split('<')[0].Trim()

    If ($FileHash -eq $CheckSum) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for VLC version $Version"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of VLC version $Version"
            Move-Item -Path $OutFile -Destination $OutFile.Replace("version", $Version) -Force -Confirm:$False
            Start-Process -FilePath $OutFile.Replace("version", $Version) -ArgumentList @('/S') -NoNewWindow -Wait -PassThru
 
        }  # End If Else

    } Else {

        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Checsum value does not match the VLC sha256 hash of the downloaded file"

    }  # End If Else

}  # End Function Install-VLC
