Function Install-Putty {
<#
.SYNOPSIS
This cmdlet is used to install/update Putty for Windows. It can also be used to simply download the installer


.DESCRIPTION
Download the lates Putty installed for Windows, verify that hash and install the file


.PARAMETER OutFile
Define where to save the installer file. Default location is your Temp directory

.PARAMETER DownloadOnly
Switch parameter to specify you only want to download the installer

.PARAMETER TryTLSv13
Switch parameter that tells PowerShell to try download file using TLSv1.3. This seems to fail as of 3/28/2023 due to 1.3 being so new


.EXAMPLE
Install-Putty
# This example downloads the Signal installer and verifies the checksum before installing it

.EXAMPLE
Install-Putty -OutFile "$env:TEMP\putty-installer.msi"
# This example downloads the Signal installer and verifies the checksum before installing it

.EXAMPLE
Install-Putty -OutFile "$env:TEMP\putty-installer.exe" -DownloadOnly
# This example downloads the Signal installer and verifies the checksum


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://github.com/tobor88
https://gitlab.com/tobor88
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
                ParameterSetName="Installer",
                Position=0,
                Mandatory=$False
            )]  # End Parameter
            [ValidateScript({$_ -like "*.msi"})]
            [String]$OutFile = "$env:TEMP\putty-installer.msi",

            [Parameter(
                ParameterSetName="Portable",
                Position=0,
                Mandatory=$False
            )]  # End Parameter
            [ValidateScript({$_ -like "*.exe"})]
            [String]$FilePath = "$env:TEMP\putty.exe",
 
            [Parameter(
                Position=1,
                Mandatory=$False
            )]  # End Parameter
            [ValidateSet('32','64','arm64')]
            [String]$Architecture = "64",

            [Parameter(
                ParameterSetName="Portable",
                Mandatory=$False
            )]  # End Parameter
            [Switch]$DownloadPortable,

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

    $MainUrl = "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"
    $CheckSumLink = "https://the.earth.li/~sgtatham/putty/latest/sha256sums"
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Obtaining latest version information for Putty"
    $Version = (Invoke-RestMethod -UseBasicParsing -Uri $MainUrl -Method GET -UserAgent $UserAgent -ContentType 'text/html' -Verbose:$False).Split("`n")[2].Split('(')[-1].Split(')')[0]

    Write-Debug -Message "[d] ParameterSetName: $($PSCmdlet.ParameterSetName)"
    Switch ($Architecture) {

        '32' {

            If ($PSCmdlet.ParameterSetName -eq "Portable") {

                $Uri = "https://the.earth.li/~sgtatham/putty/latest/w$($Architecture)/putty.exe"
                $Path = $FilePath

            } Else {

                $Uri = "https://the.earth.li/~sgtatham/putty/latest/w$($Architecture)/putty-$($Version)-installer.msi"
                $Path = $OutFile

            }  # End If Else
            
        } '64' {

            If ($PSCmdlet.ParameterSetName -eq "Portable") {

                $Uri = "https://the.earth.li/~sgtatham/putty/latest/w$($Architecture)/putty.exe"
                $Path = $FilePath

            } Else {

                $Uri = "https://the.earth.li/~sgtatham/putty/latest/w$($Architecture)/putty-$($Architecture)bit-$($Version)-installer.msi"
                $Path = $OutFile

            }  # End If Else

        } 'arm64' {

            If ($PSCmdlet.ParameterSetName -eq "Portable") {

                $Uri = "https://the.earth.li/~sgtatham/putty/latest/wa64/putty.exe"
                $Path = $FilePath

            } Else {

                $Uri = "https://the.earth.li/~sgtatham/putty/latest/wa64/putty-$($Architecture)-$($Version)-installer.msi"
                $Path = $OutFile

            }  # End If Else

        }  # End Switch Options

    }  # End Switch
    
    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Obtaining checksums for Putty"
    $CheckSumList = ((Invoke-RestMethod -UseBasicParsing -Uri $CheckSumLink -Method GET -UserAgent $UserAgent -ContentType 'text/html' -Verbose:$False).Split(' ').Split("`n") | ForEach-Object { If ($_.Length -eq 64) { $_ } }).Trim()

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Downloading Putty"
    Invoke-WebRequest -UseBasicParsing -Uri $Uri -UserAgent $UserAgent -OutFile $Path -ContentType 'application/octet-stream' -Verbose:$False | Out-Null
    $CheckSumValue = (Get-FileHash -Path $Path -Algorithm SHA256 -Verbose:$False).Hash.ToLower()

    If ($CheckSumList -contains $CheckSumValue) {

        Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully verified hash of newly downloaded file for Putty"
        If ($DownloadPortable.IsPresent -and (Test-Path -Path $Path)) {
    
            Write-Output -InputObject "[*] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Successfully downloaded file and verified hash.`n[i] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') File saved to $Path"
    
        } Else {
    
            Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Executing installation of Putty version $Version"
            Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList @("/i", $Path, "/qn", "ALLUSERS=1") -NoNewWindow -Wait -PassThru -ErrorAction Stop
    
        }  # End If Else

    } Else {

        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Failed to validate checksum of the downloaded file $Path"

    }  # End If Else

}  # End Function Install-Putty
