Function Install-KeePass {
<#
.SYNOPSIS
This cmdlet is used to install/update KeePass on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates KeePass installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-KeePass
# This example downloads the KeePass installer and verifies the checksum before installing it

.EXAMPLE
Install-KeePass -OutFile "$env:TEMP\KeePass-Setup.exe"
# This example downloads the KeePass installer and verifies the checksum before installing it

.EXAMPLE
Install-KeePass -OutFile "$env:TEMP\KeePass-Setup.exe" -DownloadOnly
# This example downloads the KeePass installer and verifies the checksum


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
            [ValidateScript({$_ -like "*.exe"})]
            [String]$OutFile = "$env:TEMP\KeePass-Setup.exe",
 
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

    $DLUserAgebt = "wget"
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
    $DownloadPage = 'https://keepass.info/download.html'
    $CheckSumPage = 'https://keepass.info/integrity.html'
   
    Try {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading KeePass"
        $Uri = ((Invoke-WebRequest -Uri $DownloadPage -UseBasicParsing -UserAgent $UserAgent -ContentType 'text/html').Links | Where-Object -Property "OuterHTML" -like "<a href=`"https://sourceforce.net/projects/keepass/files/KeePass%202.x/2.*Setup.exe/download*").href
        Invoke-WebRequest -Uri $Uri -UseBasicParsing -UserAgent $DLUserAgebt -OutFile $OutFile -ContentType 'application/octet-stream' | Out-Null
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Obtaining KeePass checksums"
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA1).Hash.ToLower()
    $CResponse = Invoke-WebRequest -UseBasicParsing -Uri $CheckSumPage -Method GET -UserAgent $UserAgent -ContentType 'text/html; charset=UTF-8'
 
    $Hashes = ($CResponse.RawContent.Split("`n") | Select-String -Pattern "SHA-1:" | Out-String).Replace('<tr><td>','').Replace('</td><td><code>','').Replace('</code></td></tr>','').Replace("SHA-1:","").Replace(" ","").Trim().ToLower()
    $CheckSum = $Hashes.Split([System.Environment]::NewLine) | Where-Object -FilterScript { $_ -like $FileHash }
 
    If ($CheckSum -eq $FileHash) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for KeePass"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of KeePass"
            Start-Process -FilePath $OutFile -ArgumentList @('/VERYSILENT') -NoNewWindow -Wait -PassThru
 
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for KeePass"
 
    }  # End If Else
 
}  # End Function Install-KeePass
