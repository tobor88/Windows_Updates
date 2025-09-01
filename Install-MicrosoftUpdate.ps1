#Requires -Version 2
#Requires -RunAsAdministrator
function Install-Microsoftupdate {
<#
.SYNOPSIS
Downloads and installs pending Microsoft Windows updates.


.DESCRIPTION
Uses `Find‑Microsoftupdate` internally, then downloads, installs and writes a concise text report.
The `-IncludeDriver` switch lets you specify whether driver updates are included in the operation.


.PARAMETER LogPath
Folder where the plain‑text log file will be written. 
Default: "C:\Windows\Temp\<computername>".

.PARAMETER IncludeHidden
Include hidden updates (passed through to `Find‑Microsoftupdate`).

.PARAMETER IncludeDriver
Include driver‑type updates in the search/install process.


.EXAMPLE
PS> Install-Microsoftupdate -LogPath "D:\WinUpdates" -IncludeDriver
# This example finds Microsoft updates and driver updates discovered in the Microsoft catalog and installs them logging results to the D:\WindUpdates directory


.NOTES
Last Updated: 9/1/2025
Author: Robert H. Osborne
Contact: rosborne@osbornepro.com


.LINK
https://osbornepro.com
#>
[OutputType()]
[CmdletBinding()]
    param (
        [Parameter(
            Position=0,
            Mandatory=$False
        )]  # End Parameter
        [String]$LogPath = "C:\Windows\Temp\$($env:COMPUTERNAME)",
        
        [Switch]$IncludeHidden,
        [Switch]$IncludeDriver
    )  # End param

    # --------------------------------------------------------------
    # 1.) Discover pending updates (re‑use Find‑Microsoftupdate)
    # --------------------------------------------------------------
    $Updates = Find-Microsoftupdate -IncludeHidden:$IncludeHidden -IncludeDriver:$IncludeDriver
    If (-not $Updates -or $Updates.Count -eq 0) {
    
        Write-Information -MessageData "$($env:COMPUTERNAME) is already up‑to‑date."
        Return
        
    }  # End If

    # --------------------------------------------------------------
    # 2.) Prepare logging
    # --------------------------------------------------------------
    $Today         = Get-Date
    $FormattedDate = $Today.ToString('MM-dd-yyyy')
    $LogFolder     = Join-Path -Path $LogPath -ChildPath $env:COMPUTERNAME
    $ReportFile    = Join-Path -Path $LogFolder -ChildPath "$($FormattedDate)_$($env:COMPUTERNAME)_Update_Report.log"
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    If (Test-Path -Path $ReportFile) {
        Rename-Item -Path $ReportFile -NewName ("$ReportFile.old") -Force
    }  # End If

    @"
#===================================================================#
#                           Update Report                           #
#===================================================================#
Computer Hostname      : $env:COMPUTERNAME
Computer Domain        : $((Get-CimInstance -ClassName Win32_ComputerSystem).Domain)
Creation Date          : $Today
Report Directory       : $LogFolder
Executing User         : $env:USERNAME
Executing Users Domain : $env:USERDOMAIN
Working Directory      : $PWD
PS Version             : $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Path)

---------------------------------------------------------------------
AVAILABLE UPDATES
---------------------------------------------------------------------
"@ | Set-Content -Path $ReportFile -Encoding UTF8

    # --------------------------------------------------------------
    # 3.) Download each update
    # --------------------------------------------------------------
    $Session    = New-Object -ComObject Microsoft.Update.Session
    $Downloader = $Session.CreateUpdateDownloader()
    $DownloadColl = New-Object -ComObject Microsoft.Update.UpdateColl

    ForEach ($Upd in $Updates) {
        $DownloadColl.Add($Upd) | Out-Null
        Add-Content -Path $ReportFile -Value "$($Updates.IndexOf($Upd)+1). Downloading: $($Upd.Title)"
    }  # End ForEach

    $Downloader.Updates = $DownloadColl
    $DLResult = $Downloader.Download()

    If ($DLResult.HResult -ne 0 -or $DLResult.ResultCode -ne 2) {
        Write-Warning -Message "One or more downloads failed – see the log for details."
    }  # End If

    # --------------------------------------------------------------
    # 4.) Install the downloaded updates
    # --------------------------------------------------------------
    $Installer = $Session.CreateUpdateInstaller()
    $Installer.Updates = $DownloadColl
    $InstResult = $Installer.Install()

    # --------------------------------------------------------------
    # 5.) Final report
    # --------------------------------------------------------------
    Add-Content -Path $ReportFile -Value @"
---------------------------------------------------------------------
UPDATE INSTALLATION
---------------------------------------------------------------------
Result Code : $($InstResult.ResultCode)
HResult     : $($InstResult.HResult)
"@

    # Summary object returned to the pipeline
    [PSCustomObject]@{
        ComputerName   = $env:COMPUTERNAME
        Date           = $FormattedDate
        UpdatesFound   = $Updates.Count
        DownloadResult = $DLResult.ResultCode
        InstallResult  = $InstResult.ResultCode
        LogFile        = $ReportFile
    }
}
