Function Install-NotepadPlusPlus {
<#
.SYNOPSIS
This cmdlet is used to install/update Notepad++ on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates Notepad++ installed for Windows, verify that hash and instal the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer


.EXAMPLE
Install-NotepadPlusPlus
# This example downloads the Notepad++ installer and verifies the checksum before installing it

.EXAMPLE
Install-NotepadPlusPlus -OutFile "$env:TEMP\npp.latest.Installer.x64.exe"
# This example downloads the Notepad++ installer and verifies the checksum before installing it

.EXAMPLE
Install-NotepadPlusPlus -OutFile "$env:TEMP\npp.latest.Installer.x64.exe" -DownloadOnly
# This example downloads the Notepad++ installer and verifies the checksum


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
            [String]$OutFile = "$env:TEMP\npp.latest.Installer.x64.exe",
 
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$DownloadOnly
        )   # End param

    Try {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.3"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls13

    } Catch {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') utilizing TLSv1.2"
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    }  # End Try Catch

    $Uri = 'https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest'
    $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36'

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Notepad++ from GitHub"
    Try {
        
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent -ContentType 'application/json; charset=utf-8'
        $DownloadLink = ($GetLinks.assets | Where-Object -Property Name -like "npp.*.Installer.x64.exe").browser_download_url
        $DResponse = Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -UserAgent $UserAgent -OutFile $OutFile
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    $CheckSum = ($GetLinks.body.Split(" ") | Where-Object -FilterScript { $_ -like "*$FileHash*" } | Out-String).Trim().ToLower().Split("`n")[-1]
   
    If ($FileHash -eq $CheckSum) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for Notepad++"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Notepad++"
            Start-Process -FilePath $OutFile -ArgumentList @('/S') -NoNewWindow -Wait -PassThru
       
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for Notepad++"
 
    }  # End If Else
 
}  # End Function Install-NotepadPlusPlus