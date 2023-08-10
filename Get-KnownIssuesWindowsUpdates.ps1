#Requires -Version 3.0
<#
.SYNOPSIS
This script is used to report on Windows Updates that are known to cause issues. It sends an email to the recipient you specify with an HTML file attached.


.DESCRIPTION
Obtain information on updates that are known to have issues when applied. The HTML file that is created offers more functionality than the email becuase email does not execute javascript.


.PARAMETER HtmlFile
Define the location to save the HTML file containing the collected information

.PARAMETER ToEmail
Define the email address(es) to send the report information too

.PARAMETER FromEmail
Define the email address to send an email from

.PARAMETER SmtpServer
Define the SMTP server to send an email from

.PARAMETER EmailCredential
Defeine your credentials used to send an email

.PARAMETER UseSSL
Define whether to use TLS when sending an email

.PARAMETER LogoFilePath
Define the path to a company image to include in the email and report. Roughly 800px by 200px usually looks nice. Max width is 975px

.PARAMETER HtmlBodyBackgroundColor
Define the main HTML body background color

.PARAMETER HtmlBodyTextColor
Define the text color used in paragraphs

.PARAMETER H1BackgroundColor
Define the background color for h1 HTML values

.PARAMETER H1TextColor
Define the text color used in H1 elements

.PARAMETER H1BorderColor
Define the color used in H1 borders

.PARAMETER H2TextColor
Define the background color for h1 HTML values

.PARAMETER H3BackgroundColor
Define the background color for h1 HTML values

.PARAMETER H3BorderColor
Define the border color for h1 HTML values

.PARAMETER H3TextColor
Define the text color of h3 elements

.PARAMETER TableHeaderBackgroundColor
Define the background color of the tables headers

.PARAMETER TableHeaderFadeColor
Define the fade color of the table header

.PARAMETER TableHeaderTextColor
Define the text color of the tables headers

.PARAMETER TableBodyBackgroundColor
Define the background color of the tables data

.PARAMETER TableTextColor
Define the text color in the tables data

.PARAMETER TableBorderColor
Define the border color in the table


.EXAMPLE
PS> .\Get-KnownIssuesWindowsUpdates.ps1 -ToEmail "rosborne@osbornepro.com" -FromEmail "rosborne@osbornepro.com" -SmtpServer mail.smtp2go.com -UseSSL -EmailCredential $LiveCred -LogoFilePath "$env:ONEDRIVE\Pictures\Logos\logo-banner.png" -H1BackgroundColor '#121F48' -H1TextColor '#FFFFFF' -H1BorderColor "Black" -H2TextColor '#AC1F2D' -H3BackgroundColor '#121F48' -H3FadeBackgroundColor '#AC1F2D' -H3BorderColor 'Black' -H3TextColor 'white' -TableHeaderBackgroundColor '#121F48' -TableHeaderFadeColor '#AC1F2D' -TableHeaderTextColor 'white' -TableBorderColor 'Black'
# This example generates a report using national colors of the United States to make a professional looking report that is delivered via email

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


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com

RSS FEEDS APPEAR TO NOT HAVE ANY USEFUL INFORMATION. I LEFT THIS HERE IN CASE IT IS DISCOVERED OTHERWISE
  $MicrosoftUpdateRssFeedUri = "https://support.microsoft.com/en-us/feed/rss/7abe4ae9-060b-5746-376f-232cf5c9946d"
  $WindowsUpdateRssFeedUri = "https://support.microsoft.com/en-us/feed/rss/8006984f-11e7-355b-5a81-fb46edef60fa"
  $MicrosoftUpdatesRssResults = Invoke-RestMethod -Method GET -Uri $MicrosoftUpdateRssFeedUri -UserAgent $UserAgent -ContentType 'application/xml' -Verbose:$False
  $WindowsUpdatesRssResults = Invoke-RestMethod -Method GET -Uri $WindowsUpdateRssFeedUri -UserAgent $UserAgent -ContentType 'application/xml' -Verbose:$False

#>
[CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$HtmlFile = "$env:TEMP\Windows-Patch-Report.html",

        [Parameter(
            Mandatory=$True,
            HelpMessage="Enter the email address(es) to send the information too "
        )]  # End Parameter
        [String[]]$ToEmail,

        [Parameter(
            Mandatory=$True,
            HelpMessage="Enter the email address(es) to send the information from "
        )]  # End Parameter
        [String]$FromEmail,

        [Parameter(
            Mandatory=$True,
            HelpMessage="Enter the SMTP server to send the information from "
        )]  # End Parameter
        [String]$SmtpServer,

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [Switch]$UseSSL,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        $EmailCredential = [System.Management.Automation.PSCredential]::Empty

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [ValidateScript({$_.Extension -like ".png" -or $_.Extension -like ".jpg" -or $_.Extension -like ".jpeg"})]
        [System.IO.FileInfo]$LogoFilePath,

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$HtmlBodyBackgroundColor = '#292929',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$HtmlBodyTextColor = '#ECF9EC',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$H1BackgroundColor = '#259943',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$H1TextColor = '#ECF9EC',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$H1BorderColor = '#666666',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$H2TextColor = '#FF4D04',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$H3BackgroundColor = '#259943',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$H3BorderColor = '#666666',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$H3TextColor = '#ECF9EC',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$TableTextColor = '#1690D0',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$TableHeaderBackgroundColor = '#259943',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$TableHeaderTextColor = '#ECF9EC',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$TableBorderColor = '#259943',

        [Parameter(
            Mandatory=$False
        )]  # End Parameter
        [String]$TableBodyBackgroundColor = '#FF7D15'
    )  # End param

Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Loading custom cmdlets into session"
Function Get-DayOfTheWeeksNumber {
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Define the day of the week you want: `nEXAMPLE: Tuesday")]  # End Parameter
            [ValidateSet('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')]
            [String]$DayOfWeek,
 
            [Parameter(
                Position=1,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Identify  which week of the month you want: `nEXAMPLE: 2")]  # End Parameter
            [ValidateRange(1,6)]
            [Int32]$WhichWeek,
 
            [Parameter(
                Position=2,
                Mandatory=$False,
                ValueFromPipeline=$False,
                HelpMessage="Identify  which week of the month you want: `nEXAMPLE: 2")]  # End Parameter
            [ValidateSet('January','February','March','April','May','June','July','August','September','October','November','December')]
            [String]$Month = $((Get-Culture).DateTimeFormat.GetMonthName((Get-Date).Month)),
 
            [Parameter(
                Position=3,
                Mandatory=$False,
                ValueFromPipeline=$False,
                HelpMessage="Identify  which week of the month you want: `nEXAMPLE: 2")]  # End Parameter
            [ValidateScript({$_ -match '(\d\d\d\d)'})]
            [Int32]$Year = (Get-Date).Year
        )  # End param
 
    $Today = Get-Date -Date "$Month $Year"
    $Subtract = $Today.Day - 1
    [DateTime]$MonthStart = $Today.AddDays(-$Subtract)
    While ($MonthStart.DayOfWeek -ne $DayOfWeek) {
 
        $MonthStart = $MonthStart.AddDays(1)
 
    }  # End While
 
    Return $MonthStart.AddDays(7*($WhichWeek - 1))
 
}  # End Get-DayOfTheWeeksNumber

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
[OutputType([System.String])]
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
            [ValidateSet("Windows Server 2008", "Windows Server 2008 R2", "Windows Server 2012", "Windows Server 2012 R2", "Windows Server 2016", "Windows Server 2019", "Windows Server 2022", "Windows 10", "Windows 11","SQL Server 2014","SQL Server 2016","SQL Server 2017","SQL Server 2019")]
            [String]$OperatingSystem = "$((Get-CimInstance -ClassName Win32_OperatingSystem -Verbose:$False).Caption.Replace('Microsoft ','').Replace(' Pro','').Replace(' Standard ','').Replace(' Datacenter ',''))",

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
    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
    $UpdateIdResponse = Invoke-WebRequest -Uri "https://www.catalog.update.microsoft.com/Search.aspx?q=$ArticleId" -Method GET -UserAgent $UserAgent -ContentType 'text/html; charset=utf-8' -UseBasicParsing -Verbose:$False
    $DownloadOptions = ($UpdateIdResponse.Links | Where-Object -Property ID -like "*_link")

    If (!($PSBoundParameters.ContainsKey('Architecture') -and $OperatingSystem -notlike "*SQL*")) {

        $Architecture = "x$((Get-CimInstance -ClassName Win32_OperatingSystem -Verbose:$False).OSArchitecture.Replace('-bit',''))"

    }  # End If

    If ($PSCmdlet.ParameterSetName -eq "Windows10" -and $OperatingSystem -notlike "*SQL*") {

        If (!($PSBoundParameters.ContainsKey('VersionInfo') -and $OperatingSystem -notlike "*SQL*")) {

            $VersionInfo = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion

        }  # End If

        Write-verbose -Message "$OperatingSystem link being discovered"
        If ($OperatingSystem -like "Windows Server 2022") {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { ($_.OuterHTML -like "*$($OperatingSystem)*" -or $_.OuterHTML -like "*Microsoft server operating system, version *") }
        
        } Else {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($OperatingSystem)*" -and $_.OuterHTML -notlike "*Dynamic*" }
        
        }  # End If Else
        
        If ($PSBoundParameters.Contains('Architecture')) {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($Architecture)*" }
        
        }  # End If
        
    } Else {

        Write-verbose -Message "$OperatingSystem link being discovered"
        If ($OperatingSystem -like "Windows Server 2022") {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { ($_.OuterHTML -like "*$($OperatingSystem)*" -or $_.OuterHTML -like "*Microsoft server operating system, version *") }
        
        } Else {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($OperatingSystem)*" -and $_.OuterHTML -notlike "*Dynamic*" }

        }  # End If Else
        
        If ($PSBoundParameters.ContainsKey('Architecture') -and $OperatingSystem -notlike "*SQL*") {
        
            $DownloadOptions = $DownloadOptions | Where-Object -FilterScript { $_.OuterHTML -like "*$($Architecture)*" }
        
        }  # End If
        
    }  # End If Else

    If ($Null -eq $DownloadOptions) {

        Throw "[x] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') No results were returned using the specified options $OperatingSystem and $Architecture"

    }  # End If

    ForEach ($DownloadOption in $DownloadOptions) {

        $Guid = $DownloadOption.id.Replace("_link","")
        Write-Verbose -Message "Downloading information for $($ArticleID) $($Guid)"
        $Body = @{ UpdateIDs = "[$(@{ Size = 0; UpdateID = $Guid; UidInfo = $Guid } | ConvertTo-Json -Compress)]" }
        $LinksResponse = (Invoke-WebRequest -Uri 'https://catalog.update.microsoft.com/DownloadDialog.aspx' -Method POST -Body $Body -UseBasicParsing -SessionVariable WebSession -Verbose:$False).Content 
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

Function Get-WindowsUpdateIssue {
<#
.SYNOPSIS
This script is used to collect Reddit posts on Windows Updates that caused issues


.DESCRIPTION
Query Reddit for posts related to Windows Updates causing issues


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.INPUTS
None


.OUTPUTS
System.Object[]
#>
[OutputType([System.Object[]])]
[CmdletBinding()]
    param()  # End param

    Write-Debug -Message "[D] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Ensuring the use of TLSv1.2"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

    $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Getting $(Get-Date -UFormat '%B %Y') Windows Updates"
    $MsrcUri = "https://api.msrc.microsoft.com/cvrf/v2.0/updates('$(Get-Date -UFormat %Y-%b)')"
    $MicrosoftSecUpdateLink = (Invoke-RestMethod -UseBasicParsing -Method GET -ContentType 'application/json' -UserAgent $UserAgent -Uri $MsrcUri -Verbose:$False).Value.CvrfUrl

    Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Getting $(Get-Date -UFormat '%B %Y') Windows Update Artilce ID values"
    $MicrosoftSecInfo = Invoke-RestMethod -UseBasicParsing -Method GET -ContentType 'application/json' -UserAgent $UserAgent -Uri $MicrosoftSecUpdateLink -Verbose:$False
    $MicrosoftSecurityKBList = $MicrosoftSecInfo.Vulnerability.Remediations | ForEach-Object { 
        
        If ($_.Url -and $_.Url -like "*/site/Search.aspx?q=KB*") {
            
            $($_.Url.Split('=')[-1])

        }  # End If

    } | Select-Object -Unique

    $PatchTuesday = Get-DayOfTheWeeksNumber -DayOfWeek Tuesday -WhichWeek 2 -Verbose:$False
    $Output = ForEach ($KB in $MicrosoftSecurityKBList) {

        $ReleaseNotesUri = "https://support.microsoft.com/help/$($KB.Replace('KB', ''))"
        $KBReleaseNotes = Invoke-WebRequest -UseBasicParsing -Uri $ReleaseNotesUri -Method GET -UserAgent $UserAgent -ContentType 'text/html; charset=utf-8' -Verbose:$False
        $KnownIssueCheck = $KBReleaseNotes.RawContent.Split("`n") | ForEach-Object { $_ | Select-String -Pattern "Known issues in this update" }
        $UnknownIssueCheck = $KBReleaseNotes.RawContent.Split("`n") | ForEach-Object { $_ | Select-String -Pattern "(We|Microsoft) (is|are) (not currently|currently not) aware of any issues (in|with) this update." }
        If (!($UnknownIssueCheck)) {

            $UnknownIssueCheck = $KBReleaseNotes.RawContent.Split("`n") | ForEach-Object { $_ | Select-String -Pattern "No additional issues were documented for this release" }

        }  # End If

        $OSBuild = ($KBReleaseNotes.Links.outerHTML.Split("`n") | ForEach-Object { $_ | Select-String -Pattern "I think you" } | Out-String | Select-String -Pattern "(\d+)\.(\d+)" -Context 0).Matches.Value
        If (!($OSBuild) -or $OSBuild -like "4.*" -or $OSBuild -like "3.*" -or $OSBuild -like "2.*") {

            Try {
                
                $OS = ($KBReleaseNotes.Links.outerHTML.Split("`n") | ForEach-Object { $_ | Select-String -Pattern "Windows Server (\d+) (.*)" -Context 0}).Matches.Value.Split('<')[0].Split('(')[0].Replace(' update history', '')
            
            } Catch {

                # Gets .NET Framework Operating System Applicability
                Try {

                    $OS = ((($KBReleaseNotes.RawContent.Split("`n") | ForEach-Object { $_ | Select-String -Pattern "$(Get-Date -Date $PatchTuesday -UFormat '%B%e, %Y') (.*) Windows (.*)" -Context 0}).Matches.Value.Split('<')[0] | Out-String | Select-String -Pattern "Windows (.*)" -Context 0).Matches.Value -Split "includes" | Select-Object -First 1).Trim().Replace(' update history', '')
    
                } Catch {

                    $OS = ($KBReleaseNotes.RawContent.Split("`n") | ForEach-Object { $_ | Select-String -Pattern "Windows Server (\d+) (.*)" -Context 0}).Matches.Value.Split('<')[0].Replace(' update history', '').Replace(' - Microsoft Support', '')

                }  # End Try Catch    If (!($OS)) {

            }  # End Try Catch

        }  # End If

        If ($OS) { 
            
            Set-Variable -Name OperatingSystem,OSVersion -Value $OS -Force -WhatIf:$False
        
        } Else {
            
            Switch -Wildcard ($OSBuild) {
                
                "*20348.*" { Set-Variable -Name OperatingSystem,OSVersion -Value "Windows Server 2022" -Force -WhatIf:$False }
                "17763.*" { Set-Variable -Name OperatingSystem,OSVersion -Value "Windows Server 2019, Windows 10 1809" -Force -WhatIf:$False }
                "*14393.*" { Set-Variable -Name OperatingSystem,OSVersion -Value "Windows Server 2016, Windows 10 1607" -Force -WhatIf:$False }
                "*6.3.9600*" { Set-Variable -Name OperatingSystem,OSVersion -Value "Windows Server 2012 R2" -Force -WhatIf:$False }
                "*6.2.9200*" { Set-Variable -Name OperatingSystem,OSVersion -Value "Windows Server 2012" -Force -WhatIf:$False }
                "*6.1.7601*" { Set-Variable -Name OperatingSystem,OSVersion -Value "Windows Server 2008 R2" -Force -WhatIf:$False }
                "*22621.2134*" { $OSVersion = "Windows 11 22H2"; $OperatingSystem = "Windows 11" }
                "*22000.2295*" { $OSVersion = "Windows 11 21H2"; $OperatingSystem = "Windows 11" }
                "*19045.3324*" { $OSVersion = "Windows 10 22H2"; $OperatingSystem = "Windows 10" }
                "*19044.3324*" { $OSVersion = "Windows 10 21H2"; $OperatingSystem = "Windows 10" }
                "*10240.20107*" { $OSVersion = "Windows 10 1507"; $OperatingSystem = "Windows 10" }
                "4.*" { $OSVersion = ".NET Framework $OSBuild" }
                "3.*" { $OSVersion = ".NET Framework $OSBuild" }
                "2.*" { $OSVersion = ".NET Framework $OSBuild" }
                Default { $OSVersion = $OSBuild }

            }  # End Switch

        }  # End If Else

        If ($OperatingSystem -notlike ".NET Framework*") {

            $OperatingSystem = $OperatingSystem.Split(',')[0].Replace(' SP1', '').Replace(' SP2', '').Replace("Windows Server 2008 R2 and Windows Server 2008", "Windows Server 2008 R2").Replace('Windows 11 Version 22H2' ,'Windows 11').Replace('Windows 10 Version 21H2 and Windows 10 Version 22H2', 'Windows 10').Trim()
            $DownloadLink = Get-KBDownloadLink -ArticleId $KB -OperatingSystem $OperatingSystem -Architecture "x64" -Verbose:$False -ErrorAction SilentlyContinue
    
        }  # End If

        $Match = ($KBReleaseNotes.RawContent | Select-String -Pattern '<tbody>(.|\n)*?<\/tbody>').Matches.Value
        $PTags = ($Match | Select-String -Pattern '<p>(.|\n)*?<\/p>' -AllMatches).Matches.Value
        $Issue = $PTags[-2].Replace('<p>', '').Replace('</p>', '').Replace('<br>', ' ')
        $Workaround = $PTags[-1].Replace('<p>', '').Replace('</p>', '').Replace('<br>', ' ')

        New-Object -TypeName PSCustomObject -Property @{
            KB=$KB;
            OperatingSystem=$OSVersion;
            Reference=$ReleaseNotesUri;
            DownloadLink=$(If ($DownloadLink) { $DownloadLink } Else { "NA" });
            KnownIssues=$(If ($KnownIssueCheck -and (!($UnknownIssueCheck))) { "Known Issues with update" } Else { "No known issues" });
            Issue=$($Issue.Replace('<p>', '').Replace('</p>', ''));
            Workaround=$($Workaround.Replace('<p>', '').Replace('</p>', '').Split("`n") | ForEach-Object { If ($_ -notlike "") { $_ } });
        }  # End New-Object -Property

        Remove-Variable -Name DownloadLink,OS,OSVersion,OSBuild,KnownIssueCheck,UnknownIssueCheck,KBReleaseNotes,ReleaseNotesUri -Force -ErrorAction SilentlyContinue -Verbose:$False -WhatIf:$False

    }  # End ForEach

    Return $Output

}  # End Function Get-WindowsUpdateIssue

If ($PSBoundParameters.ContainsKey('LogoFilePath')) {
    
    Try {

        $ImageBase64 = [Convert]::ToBase64String((Get-Content -Path $LogoFilePath -Encoding Byte))

    } Catch {

        $ImageBase64 = [Convert]::ToBase64String((Get-Content -Path $LogoFilePath -AsByteStream))

    }  # End Try Catch

}  # End If

Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Obtaining update information from Microsoft"
$PatchTuesday = Get-DayOfTheWeeksNumber -DayOfWeek Tuesday -WhichWeek 2 -Verbose:$False
$Results = Get-WindowsUpdateIssue -Verbose:$False
$IssueKBs = $Results | Where-Object -Property "KnownIssues" -eq "Known issues with update"
If ($IssueKBs.KB.Count -ge 1) { 
    
    $PlaceHolder = $IssueKBs | Select-Object -First 1 -ExpandProperty KB
    $EmailInfo = $IssueKBs

} Else {
    
    $PlaceHolder = $Results | Select-Object -First 1 -ExpandProperty KB
    $EmailInfo = $Results

}  # End If Else

$RawJson = (($Results | Select-Object -Property 'KB','OperatingSystem','KnownIssues',@{Label='Reference'; Expression={"<a href='$($_.Reference)' target='_blank'>$($_.KB) Release Notes</a>"}},@{Label='DownloadLink'; Expression={If ((!($_.DownloadLink)) -or $_.DownloadLink -ne "NA") { "<a href='$($_.DownloadLink)' target='_blank'>Download $($_.KB)</a>"} Else { $_.DownloadLink }}} | ConvertTo-Json -Depth 3).Replace('\u0000', '')) -Split "`r`n"
$IssueJson = (($Results | Select-Object -Property 'KB','OperatingSystem','Issue','Workaround' | ConvertTo-Json -Depth 3).Replace('\u0000', '')) -Split "`r`n"

If ($RawJson[0] -eq '[') {

    $FormatedJson = .{
        'const response = {
            "kbdata": ['
        $RawJson | Select-Object -Skip 1
    }

    $FormatedJson[-1] = ']};'

} Else {

    $FormatedJson = .{
        'const response = {
            "kbdata": ['
        $RawJson | Select-Object -Skip 1
    }

    $FormatedJson[-1] = ']};' # replace last Line

}  # End If Else


If ($IssueJson[0] -eq '[') {

    $IssueFormatedJson = .{
        'var issuedata = ['
        $IssueJson | Select-Object -Skip 1
    }

    $IssueFormatedJson[-1] = '];'

} Else {

    $IssueFormatedJson = .{
        'var issuedata = {'
        $IssueJson | Select-Object -Skip 1
    }

    $IssueFormatedJson[-1] = '};' # replace last Line

}  # End If Else

$EmailCss = @"
<meta charset="utf-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Pragma">
<meta http-equiv="Expires" content="0">
<meta name="viewport" content="width=device-width, initial-scale=1"/>

<title>Windows Update Known Issues Report</title>

<style type="text/css">
@charset "utf-8";
body {
position: realtive;
margin: auto;
width: 975px;
background-color: $HtmlBodyBackgroundColor;
}

h1 {
font-family: Arial, Helvetica, sans-serif;
background-color: $H1BackgroundColor;
font-size: 28px;
text-align: center;
border-width: 1px;
padding: 8px;
border-style: solid;
border-color: $H1BorderColor;
background: $H1BackgroundColor;
background: linear-gradient($H3FadeBackgroundColor, $H1BackgroundColor);
color: $H1TextColor;
padding: 10px 15px;
vertical-align: middle;
}

h2 {
font-family: Arial, Helvetica, sans-serif;
font-size: 18px;
color: $H2TextColor;
text-align: left;
}

h3 {
font-family: Arial, Helvetica, sans-serif;
font-size: 22px;
text-align: center;
border-width: 1px;
padding: 8px;
border-style: solid;
border-color: $H3BorderColor;
background: $H3BackgroundColor;
background: linear-gradient($H3FadeBackgroundColor, $H3BackgroundColor);
color: $H3TextColor;
padding: 10px 15px;
vertical-align: middle;
}

p {
font-family: Arial, Helvetica, sans-serif;
color: $HtmlBodyTextColor;
padding: 
}

table {
color: $TableTextColor;
font-family: Arial, Helvetica, sans-serif;
font-size:12px;
border-width: 1px;
border-color: $TableBorderColor;
border-collapse: collapse;
position: relative;
margin: auto;
width: 975px;
}

th {
border-width: 1px;
padding: 8px;
border-style: solid;
border-color: $TableBorderColor;
background: $TableHeaderBackgroundColor;
background: linear-gradient($TableHeaderFadeColor, $TableHeaderBackgroundColor);
font-weight: bold;
font-size: 12px;
color: $TableHeaderTextColor;
padding: 10px 15px;
vertical-align: middle;
}

td {
padding: 0.5rem 1rem;
text-align: left;  
border-width: 1px;
border-style: solid;
color: $TableTextColor;
border-color: $TableBorderColor;
background-color: $TableBodyBackgroundColor;
}
</style>
"@

$EmailPostContent = "<br><p><font size='2'><i>This information was generated on $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')</i></font>"
$Css = @"
<meta charset="utf-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Pragma">
<meta http-equiv="Expires" content="0">
<meta name="viewport" content="width=device-width, initial-scale=1"/>

<title>Windows Update Known Issues Report</title>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>

<style type="text/css">
@charset "utf-8";
body {
position: realtive;
margin: auto;
width: 975px;
background-color: $HtmlBodyBackgroundColor;
}

h1 {
font-family: Arial, Helvetica, sans-serif;
background-color: $H1BackgroundColor;
font-size: 28px;
text-align: center;
border-width: 1px;
padding: 8px;
border-style: solid;
border-color: $H1BorderColor;
background: $H1BackgroundColor;
background: linear-gradient(#0B0B0B, $H1BackgroundColor);
color: $H1TextColor;
padding: 10px 15px;
vertical-align: middle;
}

h2 {
font-family: Arial, Helvetica, sans-serif;
font-size: 18px;
color: $H2TextColor;
text-align: left;
}

h3 {
font-family: Arial, Helvetica, sans-serif;
font-size: 22px;
text-align: center;
border-width: 1px;
padding: 8px;
border-style: solid;
border-color: $H3BorderColor;
background: $H3BackgroundColor;
background: linear-gradient(#0B0B0B, $H3BackgroundColor);
color: $H3TextColor;
padding: 10px 15px;
vertical-align: middle;
}

input {
font-family: Arial, Helvetica, sans-serif;
width: 320px;
padding: 2px;
float: left;
font-size: 16px;
}

#searchtext {
font-family: Arial, Helvetica, sans-serif;
font-size: 16px;
padding: 12px 20px 12px 20px;
border: 1px solid #666666;
margin: 12px;
width: 480px;
box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);
}

#searchbtn {
cursor: pointer;
text-align: center;
text-decoration: none;
outline: none;
background-color: #1690D0;
font-size: 16px;
font-weight: bold;
padding: 12px 20px 12px 20px;
border: 1px solid #666666;
margin: 12px;
width: 400px;
display: inline-block;
box-shadow: 0 8px 16px 0 rgba(0,0,0,0.2), 0 6px 20px 0 rgba(0,0,0,0.19);
}

#searchbtn:active {
box-shadow: 0 5px #666;
transform: translateY(4px);
}

#searchbtn:hover {
background-color: #FF7D15;
color: #ECF9EC;
}

#issuetable {
border-collapse: collapse;
}
#resultTable {
border-collapse: collapse;
}

p {
font-family: Arial, Helvetica, sans-serif;
color: $HtmlBodyTextColor;
}

.table-container {
overflow: scroll;
margin: auto;
}

table {
color: $TableTextColor;
font-family: Arial, Helvetica, sans-serif;
font-size:12px;
border-width: 1px;
border-color: $TableBorderColor;
border-collapse: collapse;
position: relative;
margin: auto;
width: 975px;
}

thead tr {
border-bottom: 1px solid #666666;
border-top: 1px solid #666666;
height: 1px; 
}
  
th {
border-width: 1px;
padding: 8px;
border-style: solid;
border-color: $TableBorderColor;
background: $TableHeaderBackgroundColor;
background: linear-gradient($TableHeaderFadeColor, $TableHeaderBackgroundColor);
font-weight: bold;
font-size: 12px;
color: $TableHeaderTextColor;
padding: 10px 15px;
vertical-align: middle;
}

th:not(:first-of-type) {
border-left: 1px solid #666666;
}  

th button {
background: linear-gradient($TableHeaderFadeColor, $TableHeaderBackgroundColor);
font-weight: bold;
border: none;
cursor: pointer;
color: $TableHeaderTextColor;
font: inherit;
height: 100%;
margin: 0;
min-width: max-content;
padding: 0.5rem 1rem;
position: relative;
text-align: left;
}

th button::after {
position: absolute;
right: 0.5rem;
}

th button[data-dir="asc"]::after {
content: url("data:image/svg+xml,%3Csvg xmlns='https://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpolygon points='0, 0 8,0 4,8 8' fill='%23818688'/%3E%3C/svg%3E");
}

th button[data-dir="desc"]::after {
content: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='8' height='8'%3E%3Cpolygon points='4 0,8 8,0 8' fill='%23818688'/%3E%3C/svg%3E");  
}  

td {
padding: 0.5rem 1rem;
text-align: left;  
border-width: 1px;
border-style: solid;
color: $TableTextColor;
border-color: $TableBorderColor;
background-color: $TableBodyBackgroundColor;
}
</style>
"@

$PostContent = @"
<br><p><font size='2'><i>This information was generated on $(Get-Date -Format 'MM/dd/yyyy HH:mm:ss')</i></font>
<script type="text/javascript">
addEventListener("fetch", event => {
    return event.respondWith(handleRequest(event.request))
})
$($IssueFormatedJson)

$($FormatedJson)

const tableContent = document.getElementById("table-content")
const tableButtons = document.querySelectorAll("th button");

const createRow = (obj) => {
  const row = document.createElement("tr");
  const objKeys = Object.keys(obj);
  objKeys.map((key) => {
    const cell = document.createElement("td");
    cell.setAttribute("data-attr", key);
    cell.innerHTML = obj[key];
    row.appendChild(cell);
  });
  return row;
};

const getTableContent = (data) => {
  data.map((obj) => {
    const row = createRow(obj);
    tableContent.appendChild(row);
  });
};

const sortData = (data, param, direction = "asc") => {
  tableContent.innerHTML = '';
  const sortedData =
    direction == "asc"
      ? [...data].sort(function (a, b) {
          if (a[param] < b[param]) {
            return -1;
          }
          if (a[param] > b[param]) {
            return 1;
          }
          return 0;
        })
      : [...data].sort(function (a, b) {
          if (b[param] < a[param]) {
            return -1;
          }
          if (b[param] > a[param]) {
            return 1;
          }
          return 0;
        });

  getTableContent(sortedData);
};

const resetButtons = (event) => {
  [...tableButtons].map((button) => {
    if (button !== event.target) {
      button.removeAttribute("data-dir");
    }
  });
};

window.addEventListener("load", () => {
  getTableContent(response.kbdata);

  [...tableButtons].map((button) => {
    button.addEventListener("click", (e) => {
      resetButtons(e);
      if (e.target.getAttribute("data-dir") == "desc") {
        sortData(response.kbdata, e.target.id, "desc");
        e.target.setAttribute("data-dir", "asc");
      } else {
        sortData(response.kbdata, e.target.id, "asc");
        e.target.setAttribute("data-dir", "desc");
      }
    });
  });
});

function searchTable() {
  // Declare variables
  var input, filter, table, tr, td, i, txtValue;
  input = document.getElementById("searchtext");
  filter = input.value.toUpperCase();
  table = document.getElementById("issuetable");
  tr = table.getElementsByTagName("tr");

  // Loop through all table rows, and hide those who don't match the search query
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[0];
    if (td) {
      txtValue = td.textContent || td.innerText;
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }
  }
}

async function handleRequest(request) {
    return new Response(js, {
        headers: {
            "content-type": "text/javascript",
        },
    })
}

function noRecord(textMessage) {
  document.getElementById("KB").innerHTML = textMessage;
  document.getElementById("OperatingSystem").innerHTML = textMessage;
  document.getElementById("Issue").innerHTML = textMessage;
  document.getElementById("Workaround").innerHTML = textMessage;
}

function GenerateData() {
  var textboxValue = document.getElementById("searchtext").value;
  var foundData = issuedata.find(function (item){
    return item.KB === textboxValue;
  });
  if (typeof foundData === 'undefined') {
    document.getElementById("searchtext").value = '';
    document.getElementById("KB").innerHTML = 'No data found for KB <strong style="color:Red;">' + textboxValue.toLowerCase() + ' </strong>Check your KB against the values in the table';
    noRecord('No Record Found - undefined');
  } 
  else if (typeof foundData === 'null'){
    document.getElementById("searchtext").value = '';
    document.getElementById("KB").innerHTML = 'No data found for KB <strong style="color: Red;">' + textboxValue.toLowerCase() + ' </strong>Check your KB against the values in the table';
    noRecord('No Record Found - null');
  }
  else
  {
    noRecord('Fetching Information... Please wait >>> Error returning issue data');
    document.getElementById("KB").innerHTML = 'Article ID: <strong style="color: #259943;">' + foundData.KB + '</strong>';
    document.getElementById("OperatingSystem").innerHTML = 'OS Affected: <strong style="color: #259943;">' + foundData.OperatingSystem + '</strong>';
    document.getElementById("Issue").innerHTML = 'Issue: <strong style="color: #259943;">' + foundData.Issue + '</strong>';
    document.getElementById("Workaround").innerHTML = 'Workaround: <strong style="color: #259943;">' + foundData.Workaround + '</strong>';
  }
  searchTable();
}
</script>
"@


$MailBody = ($EmailInfo | Select-Object -Property 'KB',@{Label="Operating System"; Expression={$_.OperatingSystem}},@{Label="Known Issues"; Expression={$_.KnownIssues}},'Reference',@{Label="Download Link"; Expression={$_.DownloadLink}} | ConvertTo-Html -Head $EmailCss -PostContent $EmailPostContent -Body @"
<h1>$(Get-Date -Date $PatchTuesday -Uformat '%B %Y') Windows Patch Report</h1>
<center><img src="data:image/$($LogoFilePath.Extension.Replace('.', ''));base64,$ImageBase64" alt="Company Logo" width=800px height=200px></center>

<h2>Overview</h2>
<p>
This report contains information on Windows Updates for <strong>$(Get-Date -Date $PatchTuesday -Uformat '%B%e, %Y')</strong>.<br>
There are a total of <strong>$($IssueKBs.KB.Count)</strong> Windows Updates in the $(Get-Date -Date $PatchTuesday -Uformat '%B %Y') patch releases that have known issues.
Any Windows Patches that have known issues will need to be evaluated and tested to determine the impact they might cause on an environment.<br>
</p>

<h2>Instructions</h2>
<p>
Open the attached HTML file will allow you to sort the columns in the table below. More functionality will be added to this document in the future.
</p>

<h3>$(Get-Date -Date $PatchTuesday -UFormat '%B %Y') Released Windows Updates</h3>
<p>
This table contains a list of KBs released by Microsoft on $(Get-Date -Date $PatchTuesday -Uformat '%B%e, %Y'). The "<strong>Reference</strong>" column contains a link which can be used to read about known issues and other release notes for a released Article ID.
</p>
"@ | Out-String).Replace('<html xmlns="http://www.w3.org/1999/xhtml">','<html lang="en" xmlns="http://www.w3.org/1999/xhtml">')

$IssueKBs = $Results | Where-Object -Property "KnownIssues" -eq "Known issues with update"
If ($IssueKBs.KB.Count -ge 1) { $PlaceHolder = $IssueKBs | Select-Object -First 1 -ExpandProperty KB } Else { $PlaceHolder = $Results | Select-Object -First 1 -ExpandProperty KB }
$Replace = $Results[0] | ConvertTo-Html -Fragment -Property 'KB','OperatingSystem','KnownIssues','Reference','DownloadLink'
$HtmlBody = ($Results[0] | ConvertTo-Html -Head $Css -PostContent $PostContent -Property 'KB','OperatingSystem','KnownIssues','Reference','DownloadLink' -Body @"
<h1>$(Get-Date -Date $PatchTuesday -Uformat '%B%e, %Y') Windows Patch Report</h1>
<center><img src="data:image/$($LogoFilePath.Extension.Replace('.', ''));base64,$ImageBase64" alt="Company Logo" width=800px height=200px></center>
<h2>Overview</h2>
<p>
This report contains information on Windows Updates for <strong>$(Get-Date -Date $PatchTuesday -Uformat '%B%e, %Y')</strong>.<br>
There are a total of <strong>$($IssueKBs.KB.Count)</strong> Windows Updates in the $(Get-Date -Date $PatchTuesday -Uformat '%B %Y') patch releases that have known issues.<br>
Any Windows Patches that have known issues will need to be evaluated and tested to determine the impact they might cause on an environment.<br>
</p>

<h3>Issue and Workaround Search</h3>
<p>
<input type="text" id="searchtext" aria-label="kb-value" class="textbox" value="$($PlaceHolder)" placeholder="Search KB">
<button id="searchbtn" type="button" onclick="GenerateData()"><strong>Search KB Issues</strong></button>
</p>
<div class="IssueResult">
    <table>
        <tr>
            <th class="IssueResult">KB: </th>
            <td class="tddata">
                <div class="tooltip-wrap" id="KB">
                    <div class="tooltip-content">
                        <p>
                        Results will show here
                        </p>
                </div>
            </td>
        </tr>

        <tr>
            <th class="IssueResult">OperatingSystem: </th>
            <td class="tddata">
                <div class="tooltip-wrap" id="OperatingSystem">
                    <div class="tooltip-content">
                </div>
            </td>
        </tr>

        <tr>
            <th class="IssueResult">Issue: </th>
            <td class="tddata">
                <div class="tooltip-wrap" id="Issue">
                    <div class="tooltip-content">
                </div>
            </td>
        </tr>

        <tr>
            <th class="IssueResult">Workaround: </th>
            <td class="tddata">
                <div class="tooltip-wrap" id="Workaround">
                    <div class="tooltip-content">
                </div>
            </td>
        </tr>
    </table>
</div>

<h3>Windows Update Table</h3>
<p>
This table contains a list of KBs released by Microsoft on $(Get-Date -Date $PatchTuesday -Uformat '%B%e, %Y'). The "<strong>Reference</strong>" column contains a link which can be used to read about known issues and other release notes for a released Article ID.
</p>
"@ | Out-String).Replace($Replace[3], "").Replace('<th>KB', '<th><button id="KBButton">KB').Replace('<th>OperatingSystem', '<th><button id="OperatingSystem">Operating System').Replace('<th>KnownIssues', '<th><button id="KnownIssues">Known Issues').Replace('<th>Reference', '<th><button id="Reference">Reference').Replace('<th>DownloadLink', '<th><button id="DownloadLink">Download Link').Replace('</th>', '</button></th>').Replace('<tr><th>', '<thead><tr class="header"><th>').Replace('</th></tr>', '</th></tr></thead><tbody id="table-content"></tbody>').Replace('<html xmlns="http://www.w3.org/1999/xhtml">','<html lang="en" xmlns="http://www.w3.org/1999/xhtml">')
$HtmlBody.Replace('<table>', '<div class="table-container"><table id="issuetable" class="data-table">').Replace('</table>', '</table></div>') | Out-File -Path $HtmlFile -Encoding utf8 -Force -WhatIf:$False -Verbose:$False

Send-MailMessage -To $ToEmail -From $FromEmail -SmtpServer $SmtpServer -Credential $EmailCredential -UseSSL:$UseSSL.IsPresent -Subject "$(Get-Date -Date $PatchTuesday -Uformat '%B%e %Y') Windows Updates Report" -Body $MailBody -BodyAsHTML -DeliveryNotification OnFailure -Attachments $HtmlFile -Verbose:$False
Write-Verbose -Message "[v] $(Get-Date -Format 'MM-dd-yyyy hh:mm:ss') Sent email of the report to $ToEmail"
