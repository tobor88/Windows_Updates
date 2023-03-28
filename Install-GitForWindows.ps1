Function Install-GitForWindows {
<#
.SYNOPSIS
This cmdlet is used to install/update Git For Windows on a machine. It can also be used to simply download the installer


.DESCRIPTION
Download the lates Git For Windows installed for Windows, verify that hash and instal the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER InfFile
Define an INF configuration file for Git if you have customizations you prefere to make.
SAMPLE INF FILE CONTENTS
[Setup]
Lang=default
Dir=C:\Program Files\Git
Group=Git
NoIcons=0
SetupType=default
Compontents=ext,ext\shellhere,ext\guihere,gitlfs,assoc,autoupdate
Tasks=
EditorOption=powershell
CustomEditorPath=
PathOption=Cmd
SSHOption=OpenSSH
TortoiseOption=false
CURLOption=WinSSL
CRLFOption=LFOnly
BashTerminalOption=ConHost
PerformanceTweaksFSCache=Enabled
UseCredentialManager=Enabled
UseCredentialManager=Enabled
EnableSymlinks=Disabled
EnalbedBuiltinInteractiveAdd=Disabled

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-GitForWindows
# This example downloads the Git For Windows installer and verifies the checksum before installing it

.EXAMPLE
Install-GitForWindows -OutFile "$env:TEMP\git-for-windows-x64-bit.exe"
# This example downloads the Git For Windows installer and verifies the checksum before installing it

.EXAMPLE
Install-GitForWindows -OutFile "$env:TEMP\git-for-windows-x64-bit.exe" -DownloadOnly
# This example downloads the Git For Windows installer and verifies the checksum


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
            [String]$OutFile = "$env:TEMP\git-for-windows-x64-bit.exe",
            
            [Parameter(
                Position=1,
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [ValidateScript({ ($_ -like "*.inf") -and (Test-Path -Path $_) })]
            [String]$InfFile,
 
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
    
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
    $Uri = 'https://api.github.com/repos/git-for-windows/git/releases/latest'
   
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Git for Windows from GitHub"
    Try {
 
        $GetLinks = Invoke-RestMethod -Uri $Uri -Method GET -UseBasicParsing -UserAgent $UserAgent #-ContentType 'application/json; charset=utf-8'
        $DownloadLink = ($GetLinks | ForEach-Object { $_.Assets } | Where-Object -Property Name -like "*64-bit.exe").browser_download_url
        $DResponse = Invoke-WebRequest -Uri $DownloadLink -UseBasicParsing -UserAgent $UserAgent -OutFile $OutFile -Method GET -ContentType 'application/octet-stream'
 
    } Catch {
 
        Throw $Error[0]
   
    }  # End Try Catch Catch
 
    $FileHash = (Get-FileHash -Path $OutFile -Algorithm SHA256).Hash.ToLower()
    $CheckSum = ($GetLinks.body.Split("`n") | Where-Object -FilterScript { $_ -like "*Git-*-64-bit.exe*" } | Out-String).Split(" ")[-1].Trim()
   
    If ($FileHash -eq $CheckSum) {
 
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for Git for Windows"
        If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
 
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] File saved to $OutFile"
 
        } Else {
 
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Git for Windows"
            If ($PSBoundParameters.ContainsKey("InfFile")) {
            
                Start-Process -FilePath $OutFile -ArgumentList @('/SP-','/VERYSILENT', '/SUPPRESSMSGBOXES', '/NOCANCEL', '/NORESTART', '/CLOSEAPPLICATIONS', '/RESTARTAPPLICATIONS', '/LOADINF=`"$InfFile`"') -NoNewWindow -Wait -PassThru
            
            } Else {
            
                Start-Process -FilePath $OutFile -ArgumentList @('/SP-','/VERYSILENT', '/SUPPRESSMSGBOXES', '/NOCANCEL', '/NORESTART', '/CLOSEAPPLICATIONS', '/RESTARTAPPLICATIONS') -NoNewWindow -Wait -PassThru
            
            }  # End If Else
            
        }  # End If Else
 
    } Else {
 
        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate hash of newly downloaded file for Git for Windows"
 
    }  # End If Else
 
}  # End Function Install-GitForWindows
