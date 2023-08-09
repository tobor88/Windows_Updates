Function Install-FileZilla {
<#
.SYNOPSIS
This cmdlet is used to install/update FileZilla Client for Windows on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates FileZilla Client installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-FileZilla
# This example downloads the FileZilla installer and verifies the checksum before installing it

.EXAMPLE
Install-FileZilla -OutFile "$env:TEMP\FilezillaClientx64.exe"
# This example downloads the FileZilla installer and verifies the checksum before installing it

.EXAMPLE
Install-FileZilla -OutFile "$env:TEMP\FilezillaClientx64.exe" -DownloadOnly
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
                Position=0,
                Mandatory=$False
            )]  # End Parameter
            [ValidateScript({$_ -like "*.exe"})]
            [String]$OutFile = "$env:TEMP\filezilla-client-win64-setup.exe",
 
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
    $Uri = 'https://filezilla-project.org/download.php?show_all=1'

    Try {
 
        $HtmlLinks = Invoke-WebRequest -Uri $Uri -UserAgent $UserAgent -UseBasicParsing -Method GET -ContentType 'text/html; charset=UTF-8' -Verbose:$False
        $Links = (($HtmlLinks.Links | Where-Object -FilterScript { $_.href -like "*win64-setup.exe*" }).href | Out-String).Replace("$([System.Environment]::NewLine)","")
        $Url = $Links.Substring(0, $Links.IndexOf('download'))
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading FileZilla Client"
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $OutFile -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Getting hash values for FileZilla Client"
    $Version = (Get-Item -Path $OutFile).VersionInfo.FileVersion
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA512).Hash.ToLower()
    $Hashes = ($HtmlLinks.RawContent.Split("`n") | Select-String -Pattern "SHA-512 hash:" | Out-String)
    $CheckSum = $Hashes.Split(":").Replace(' ','').Split("`n") | ForEach-Object { If ($_.Length -ge 128) { $_.Replace('</p>', '') }}
    
    If ($CheckSum -like "*$FileHash*") {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for FileZilla Client version $Version"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of FileZilla Client version $Version"
            Start-Process -FilePath $OutFile -ArgumentList @('/S', '/D=%PROGRAMFILES%/FileZilla FTP Client', '/user=all') -NoNewWindow -Wait -PassThru
 
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for FileZilla Client version $Version"
 
    }  # End If Else
   
}  # End Function Install-FileZilla
