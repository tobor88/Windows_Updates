Function Get-KBDownloadLink {
<#
.SYNOPSIS
This cmdlet is used to retrieve from the Microsoft Update Catalog, a download link for the Article ID KB number you specify


.DESCRIPTION
Retrieves the KB Download link from the Microsoft Update Catalog


.PARAMETER ArticleID
Defines the KB identification number you want to retrieve a download link for

.PARAMETER OperatingSystem
Define the Operating System you want a link for

.PARAMETER Architecture
Define the architecture of the system you are going to install the update on. Default value is x64

.PARAMETER VersionInfo
Define the version of Windows 10 or 11 being used 


.EXAMPLE
Get-KBDownloadLink -ArticleId KB5014692
# This obtains the download link for KB5014692 for the OS version and arhcitecture of the machine this command is executed on

.EXAMPLE
Get-KBDownloadLink -ArticleId KB5014692 -Architecture "x64" -OperatingSystem 'Windows Server 2019'
# This obtains the download link for KB5014692 for a 64-bit architecture Windows Server 2019 machine

.EXAMPLE
Get-KBDownloadLink -ArticleId KB5014692 -Architecture "x64" -OperatingSystem 'Windows 10' -VersionInfo '21H1'
# This obtains the download link for KB5014692 for a 64-bit architecture Windows 10 Enterprise version 21H1 machine


.INPUTS
None


.OUTPUTS
System.String[]


.NOTES
Author: Robrt H. Osborne
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
#>
    [CmdletBinding(DefaultParameterSetName="Server")]
        param(
            [Parameter(
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Enter the KB number `nEXAMPLE: KB5014692 `nEXAMPLE: 5014692 "
            )]  # End Parameter
            [Alias("Id","Article","KB")]
            [String]$ArticleId,

            [Parameter(
                Position=1,
                Mandatory=$False,
                ValueFromPipeline=$False
            )]  # End Parameter
            [ValidateSet("Windows Server 2012 R2", "Windows Server 2016", "Windows Server 2019", "Windows Server 2022", "Windows 10", "Windows 11","SQL Server 2014","SQL Server 2016","SQL Server 2017","SQL Server 2019")]
            [String]$OperatingSystem = "$((Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Replace('Microsoft ','').Replace(' Pro','').Replace(' Standard ','').Replace(' Datacenter ',''))",

            [Parameter(
                Position=2,
                Mandatory=$False,
                ValueFromPipeline=$False
            )]  # End Parameter
            [ValidateSet("x64", "x86", "ARM")]
            [String]$Architecture,

            [Parameter(
                ParameterSetName="Windows10",
                Position=3,
                Mandatory=$False,
                ValueFromPipeline=$False
            )]  # End Parameter
            [Alias('Windows10Version','Windows11Version')]
            [String]$VersionInfo
        )  # End param
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12,Tls13'
    $DownloadLink = @()
    $UpdateIdResponse = Invoke-WebRequest -Uri "https://www.catalog.update.microsoft.com/Search.aspx?q=$ArticleId" -Method GET -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:104.0) Gecko/20100101 Firefox/104.0' -ContentType 'text/html; charset=utf-8' -UseBasicParsing
    $DownloadOptions = ($UpdateIdResponse.Links | Where-Object -Property ID -like "*_link")

    If (!($PSBoundParameters.ContainsKey('Architecture') -and $OperatingSystem -notlike "*SQL*")) {

        $Architecture = "x$((Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture.Replace('-bit',''))"

    }  # End If

    If ($PSCmdlet.ParameterSetName -eq "Windows10" -and $OperatingSystem -notlike "*SQL*") {

        If (!($PSBoundParameters.ContainsKey('VersionInfo') -and $OperatingSystem -notlike "*SQL*")) {

            $VersionInfo = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion

        }  # End If

        Write-verbose -Message "$OperatingSystem link being discovered"
        $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($OperatingSystem)*" -and $_.OuterHTML -notlike "*Dynamic*" }
        If ($PSBoundParameters.Contains('Architecture')) {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($Architecture)*" }
        
        }  # End If
        
    } Else {

        Write-verbose -Message "$OperatingSystem link being discovered"
        $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($OperatingSystem)*" -and $_.OuterHTML -notlike "*Dynamic*" } 
        If ($PSBoundParameters.ContainsKey('Architecture') -and $OperatingSystem -notlike "*SQL*") {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($Architecture)*" }
        
        }  # End If
        
    }  # End If Else

    If ($Null -eq $DownloadOptions) {

        Throw "[x] No results were returned using the specified options $OperatingSystem and $Architecture"

    }  # End If

    ForEach ($DownloadOption in $DownloadOptions) {

        $Guid = $DownloadOption.id.Replace("_link","")
        Write-Verbose -Message "Downloading information for $($ArticleID) $($Guid)"
        $Body = @{ UpdateIDs = "[$(@{ Size = 0; UpdateID = $Guid; UidInfo = $Guid } | ConvertTo-Json -Compress)]" }
        $LinksResponse = (Invoke-WebRequest -Uri 'https://catalog.update.microsoft.com/DownloadDialog.aspx' -Method POST -Body $Body -UseBasicParsing -SessionVariable WebSession).Content 
        $DownloadLink += ($LinksResponse.Split("$([Environment]::NewLine)") | Select-String -Pattern 'downloadInformation' | Select-String -Pattern 'url' | Out-String).Trim()
        If ($PSBoundParameters.ContainsKey('Architecture') -and $OperatingSystem -like "*SQL*") {
        
            $DownloadLink = ($DownloadLink | ForEach-Object { $_.Split("$([System.Environment]::NewLine)") } | Where-Object -FilterScript { $_ -like "*$Architecture*" }).Trim().Split("'")[-2]

        } ElseIf ($OperatingSystem -like "*SQL*") {
        
            $DownloadLink = ($DownloadLink | ForEach-Object { $_.Split("'") } | Where-Object -FilterScript { $_ -like "https://*" }).Split("$([System.Environment]::NewLine)")

        } Else {

            $DownloadLink = ($LinksResponse.Split("$([Environment]::NewLine)") | Select-String -Pattern 'downloadInformation' | Select-String -Pattern 'url' | Out-String).Trim().Split("'")[-2]
        
        }  # End If Else

    }  # End ForEach

    Return $DownloadLink 

}  # End Function Get-KBDownloadLink
