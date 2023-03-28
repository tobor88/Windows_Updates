Function Install-WinSCP {
<#
.SYNOPSIS
This cmdlet is used to install/update WinSCP on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates WinSCP installed for Windows, verify that hash and instal the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-WinSCP
# This example downloads the WinSCP installer and verifies the checksum before installing it

.EXAMPLE
Install-WinSCP -OutFile "$env:TEMP\WinSCP-Version-Setup.exe"
# This example downloads the WinSCP installer and verifies the checksum before installing it

.EXAMPLE
Install-WinSCP -OutFile "$env:TEMP\WinSCP-Version-Setup.exe" -DownloadOnly
# This example downloads the WinSCP installer and verifies the checksum


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
            [String]$OutFile = "$env:TEMP\WinSCP-Version-Setup.exe",
 
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
 
    $DLUserAgent = "Wget"
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
    $DlUrl = https://winscp.net/eng/download.php
    $Version = ((Invoke-WebRequest -Uri $DlUrl -UseBasicParsing -Method GET -UserAgent $UserAgent -ErrorAction Stop).Links | Where-Object -FilterScript { $_.outerHTML -like "*List of all changes*" }).href.Split('=')[-1]
    $Uri = https://winscp.net/download/WinSCP-$Version-Setup.exe
   
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading WinSCP from their website"
    Try {
 
        $DResponse = Invoke-WebRequest -Uri $Uri -UseBasicParsing -Method GET -UserAgent $DLUserAgent -OutFile $OutFile -ContentType 'application/octet-stream'
        $CheckSum = (((Invoke-WebRequest -Uri $Uri -UseBasicParsing -Method GET -UserAgent $UserAgent).Content).Split("`n") | Select-String -Pattern "SHA-256:").ToString().Trim().Replace('</li>','').Split(" ")[-1]
 
    } Catch [System.Net.WebException] {
 
        $SslAvailable = Test-SslOptions -UrlDomain "winscp.net" -Port 443 | Where-Object -Property TlsProtocolIsEnabled -eq $True
        If ($SslAvailable) {
 
            Write-Output -InputObject "[i] The below protocols and algorithms can be used to communicate with 'winscp.net'"
            $SslAvailable | Format-Table -AutoSize -Property TlsProtocol,HashAlgorithm,CipherAlgorithm,CipherStrength,KeyExchangeAlgorithm
            Send-SendGridEmail -ToAddress $FromAddress -ToName "Advisor360 Updates - TLS Issues" -FromAddress $FromAddress -FromName "Vinebrook Technology - Advisor360" -Subject "$env:COMPUTERNAME TLS Issue Fails Update" -HTMLBody "<p>Attention Vinebrook Patching Team, <br><br>The Advisor360 server $env:COMPUTERNAME has failed to update WinSCP due to TLS issues. The negiotable TLS protocols are listed below. These all need to be enabled on $env:COMPUTERNAME if you wish to update this and other applications.<br><br><strong>Tls Protocol:</strong> $($SslAvailable.TlsProtocol)<br><strong>Hash Algorithm:</strong> $($SslAvailable.HashAlgorithm)<br><strong>CipherAlgorithm:</strong> $($SslAvailable.CipherAlgorithm)<br><strong>CipherStrength:</strong> $($SslAvailable.CipherStrength)<br><strong>KeyExchangeAlgorithm:</strong> $($SslAvailable.KeyExchangeAlgorithm)<br></p>" -APIKey $APIKey
            Throw "[x] Enable the above protocols if you wish to upgrade WinSCP to teh latest version"
 
        } Else {
 
            Throw "[x] There are no TLS options available for use"
 
        }  # End If Else
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    If ($FileHash -eq $CheckSum) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for WinSCP"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of WinSCP"
            Start-Process -FilePath $OutFile -ArgumentList @('/VERYSILENT', '/ALLUSERS' ,'NORESTART') -NoNewWindow -Wait -PassThru -ErrorAction Stop
       
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for WinSCP"
 
    }  # End If Else
 
}  # End Function Install-WinSCP
