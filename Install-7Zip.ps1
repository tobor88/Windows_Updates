Function Install-7Zip {
<#
.SYNOPSIS
This cmdlet is used to install/update 7Zip for Windows. It can also be used to simply download the installer
    

.DESCRIPTION
Download the lates 7Zip installed for Windows, verify that hash and install the file
    

.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory
    
.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer
    
.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 7/25/2023 due to 1.3 being so new
    
.EXAMPLE
PS> Install-7Zip
# This example downloads the 7Zip installer and verifies the checksum before installing it


.EXAMPLE
PS> Install-7Zip -OutFile "$env:TEMP\7zip-installer.msi"
# This example downloads the 7Zip installer and installs it
    
.EXAMPLE
PS> Install-7Zip -OutFile "$env:TEMP\7zip-installer.msi" -DownloadOnly
# This example downloads the 7Zip installer
    

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
    [CmdletBinding(DefaultParameterSetName="Installer")]
        param(
            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [ValidateScript({$_ -like "*.exe"})]
            [String]$OutFile = "$env:TEMP\7zip-installer.exe",
    
            [Parameter(
                Mandatory=$False
            )]  # End Parameter
            [ValidateSet('32','64')]
            [String]$Architecture = "64",
    
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
    
    $MainUrl = "https://www.7-zip.org/download.html"
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Obtaining latest version information for 7Zip"
    $Version = ((Invoke-WebRequest -UseBasicParsing -Uri $MainUrl -UserAgent $UserAgent -Method GET -ContentType 'text/html' -Verbos:$False).Links | Where-Object -FilterScript { $_.outerHTML -like "*7z*64.exe`">Download<*" } | Select-Object -First 1 -ExpandProperty href).Split('z')[1].Split('-')[0]
    Switch ($Architecture) {
    
        '32' { $DownloadLink = "https://www.7-zip.org/a/7z$($Version).exe" }
    
        '64' { $DownloadLink = "https://www.7-zip.org/a/7z$($Version)-x64.exe" }
    
    }  # End Switch
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading 7zip"
    Invoke-WebRequest -UseBasicParsing -Uri $DownloadLink -UserAgent $UserAgent -OutFile $OutFile -ContentType 'application/octet-stream' -Verbose:$False -ErrorAction Stop | Out-Null
    
    If ($DownloadOnly.IsPresent -and (Test-Path -Path $OutFile)) {
    
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') File saved to $OutFile"
    
    } Else {
    
        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of 7zip version $Version"
        Start-Process -FilePath $OutFile -ArgumentList @("/S") -NoNewWindow -Wait -PassThru -ErrorAction Stop
    
    }  # End If Else
    
}  # End Function Install-7Zip
