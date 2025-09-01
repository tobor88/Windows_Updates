#Requires -Version 2
#Requires -RunAsAdministrator
Function Install-MicrosoftUpdate {
<#
.SYNOPSIS
Installs Windows updates. Supply 1 or more KB IDs or it will install all pending updates


.DESCRIPTION
This cmdlet searches for matching updates, downloads any that are not already cached and then installs them.  
This works on PowerShell 2.0+ but requires elevation.


.PARAMETER KBId
One or more KB article identifiers (e.g. KB5006670). 
If this parameter is supplied the function looks up only those updates;
otherwise it falls back to the broader search controlled by the other switches.

.PARAMETER DownloadOnly
This parameter tells the cmdlet to download/stage the updates but does NOT install them.

.PARAMETER IncludeHidden
Include hidden updates in the search (only relevant when -KBId is not supplied).

.PARAMETER ShowInstalled
Return installed updates instead of pending ones (again, only when -KBId is not supplied).

.PARAMETER IncludeDriver
Include driver‑type updates.  When omitted driver updates are filtered out (CategoryID 2).


.EXAMPLE
PS> Install-MicrosoftUpdate -KBId KB5006670,KB5008601
# This example installs the two specified updates.

.EXAMPLE
PS> Install-MicrosoftUpdate -IncludeDriver
# This example installs all pending updates, including drivers.


.NOTES
Last Updated: 9/1/2025
Author: Robert H. Osborne
Contact: rosborne@osbornepro.com


.LINK
https://osbornepro.com
#>
[OutputType([PSCustomObject])]
[CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            ValueFromRemainingArguments = $True
        )]  # End Parameter
        [String[]]$KBId,
        [Switch]$DownloadOnly,
        [Switch]$IncludeHidden,
        [Switch]$ShowInstalled,
        [Switch]$IncludeDriver
    )  # End param
    
    $InfoPref = $InformationPreference
    $InformationPreference = 'Continue'
    Try {
    
        $WuService = Get-Service -Name wuauserv -ErrorAction Stop
        If ($WuService.Status -ne 'Running') {
            Start-Service -Name wuauserv -Confirm:$False -ErrorAction Stop
        }  # End If
        
        If ($KBId) {

            $KbClauses = $KBId | ForEach-Object -Process {
                "KBArticleIDs='$($_)'"
            }  # End ForEach-Object
            $BaseQuery = '(' + ($KbClauses -join ' OR ') + ')'

        } Else {

            If ($ShowInstalled.IsPresent) {
            
                $BaseQuery = "IsInstalled=1 and Type='Software'"
                
            } Else {
            
                $BaseQuery = "IsInstalled=0 and Type='Software'"
                If ($IncludeHidden.IsPresent) { $BaseQuery += " and IsHidden=1" }
                If (-not $IncludeDriver.IsPresent) { $BaseQuery += " and CategoryIDs not contains 2" }
                   
            }  # End If Else
            
        }  # End If Else

        Write-Debug -Message "Windows Update query: $BaseQuery"
        $Searcher = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
        $SearchResult = $Searcher.Search($BaseQuery)
        If ($SearchResult.Updates.Count -eq 0) {
            Write-Information -MessageData "No matching updates were found."
            Return
        }  # End If

        $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
        $SearchResult.Updates | ForEach-Object -Process {
            $UpdatesToInstall.Add($_) | Out-Null
        }  # End ForEach-Object

        $Downloader = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateDownloader()
        $Downloader.Updates = $UpdatesToInstall
        Write-Information "Downloading $($UpdatesToInstall.Count) update(s)…"
        $DownloadResult = $Downloader.Download()
        If ($DownloadResult.ResultCode -ne 2) {   # 2 = Succeeded
            Throw "Download failed (ResultCode=$($DownloadResult.ResultCode))."
        }  # End If
        $RebootRequired = "No"

        If (-not $DownloadOnly.IsPresent) {

            $Installer = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller()
            $Installer.Updates = $UpdatesToInstall
            Write-Information "Installing $($UpdatesToInstall.Count) update(s)…"
            $InstallResult = $Installer.Install()
            If ($InstallResult.ResultCode -ne 2) {
                Throw "Installation failed (ResultCode=$($InstallResult.ResultCode))."
            }  # End If
            $RebootRequired = $InstallResult.RebootRequired
        }  # End If

        $Summary = [PSCustomObject]@{
            TotalUpdates    = $UpdatesToInstall.Count
            InstalledKBs    = ($UpdatesToInstall | ForEach-Object -Process { $_.KBArticleIDs -join ', ' })
            RebootRequired  = $RebootRequired 
            Timestamp       = Get-Date -Format 'MM-dd-yyyy hh:mm:ss'
        }  # End PSCustomObject
        Return $Summary
        
    } Catch {
    
        $HR  = $_.Exception.HResult
        $Msg = $_.Exception.Message
        Throw "Failed to install updates (HRESULT: 0x{0:X8}) – {1}" -f $HR, $Msg)
    
    } Finally {
    
        $InformationPreference = $InfoPref
    
    }  # End Try Catch Finally
    
}  # End Function Install-MicrosoftUpdate
