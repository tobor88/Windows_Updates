<#
.SYNOPSIS
This cmdlet is used to return the error code that caused a windows update to fail. It also saves Windows Update logs to the executers desktop


.DESCRIPTION
Export the Windows Update logs to your desktop and return the error code that contains information on the failed update


.PARAMETER Path
Define the log file or directory containing log files to search for error codes in. Accepts wildcard values

.PARAMETER Date
Define the date to use when searching a collection of C:\Windows\CCM\Log files for SCCM error codes. This parameter can not be used in conjunction with -Path and is for searching SCCM logs

.PARAMETER All
Return every error code found in the log files instead of the latest unique values only


.EXAMPLE
Get-WindowsUpdateErrorCode
# Generates a Windows Update log file and saves it to the running users desktop and returns the error code for the failed updates

.EXAMPLE
Get-WindowsUpdateErrorCode -Path C:\Windows\Temp\Custom.log -All
# Searches the log file Custom.log for error codes and returns everyone one of them

.EXAMPLE
Get-WindowsUpdateErrorCode -Date (Get-Date).AddDays(-3)
# Searches all log files in C:\Windows\CCM\Log that have the date from 3 days ago in the log files name


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://github.com/tobor88
https://github.com/osbornepro
https://gitlab.com/tobor88
https://osbornepro.com
https://writeups.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.credly.com/users/roberthosborne/badges
https://www.linkedin.com/in/roberthosborne/


.INPUTS
None


.OUTPUTS
System.String
#>
Function Get-WindowsUpdateErrorCode {
    [CmdletBinding()]
        param(
            [Parameter(
                ParameterSetName="File",
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$True,
                HelpMessage="Define the path to log files. Wildcards are accepted EXAMPLE: C:\Windows\CCM\Logs\*202205*.log")]  # End Parameter
            [SupportsWildcards()]
            [String]$Path,

            [Parameter(
                ParameterSetName="SCCM",
                Position=0,
                Mandatory=$False,
                ValueFromPipeline=$False
                #HelpMessage="Enter the date of the log files you are checking for errors on. `nEXAMPLE: Get-Date -Date 6/14/2022 `nEXAMPLE: (Get-Date).AddDays(-7)"
            )]  # End Parameter
            [DateTime]$Date = (Get-Date),

            [Parameter(
                Mandatory=$False)]
            [Switch][Bool]$All
        )  # End param

    If ($PSCmdlet.ParameterSetName -eq "SCCM") {

        $Month = $Date.Month.ToString("00")
        $Year = $Date.Year.ToString("0000")
        $Day = $Date.Day.ToString("00")

        $Path = "C:\Windows\CCM\Logs\*$($Year)$($Month)$($Day)*.log"

    }  # End If

    If (Test-Path -Path $Path -ErrorAction SilentlyContinue) {

        Write-Verbose "Successfully created Windows Update log file"
        [regex]$Pattern = '0x8(.*){5,20}'

        $Results = Select-String -Pattern $Pattern -Path $Path -AllMatches | Where-Object -FilterScript { $_ -notlike "*HRESULT = `"0x00000000`";*" -and $_ -notlike "*0x0,*"} | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }
        $CodeFilter = @()
        ForEach ($Line in $Results) {

            $Code = Try { (($Line | Out-String).Substring(0,10) | Select-String -Pattern $Pattern | Out-String).Trim() } Catch { Continue }

            If ($All.IsPresent) {
           
                $TimeFilter = Try { ($Line | Out-String).Split("=")[1].Split(" ")[0].Replace('"','').Split(".")[0] } Catch { "Error" }
                $DateFilter = Try { ($Line | Out-String).Split("=")[2].Split(" ")[0].Replace('"','') } Catch { Continue }
                $ComponentFilter = Try { ($Line | Out-String).Split("=")[3].Split(" ")[0].Replace('"','') } Catch { Continue }
                If ($ComponentFilter) { Try { $Description = Get-ComponentDescription -Name $ComponentFilter } Catch { $Description = "No translation available. Update Get-ComponentDescription" } }

                $CodeFilter += New-Object -TypeName PSCustomObject -Property @{ErrorCode=$Code;Date=$DateFilter;Time=$TimeFilter;Log=$ComponentFilter;LogDesc=$Description}

            } ElseIf ($Code -notin $CodeFilter.ErrorCode) {

                $Line = (($Results | Select-String -Pattern $Code)[-1] | Out-String).Trim()
                $TimeFilter = Try { ($Line | Out-String).Split("=")[1].Split(" ")[0].Replace('"','').Split(".")[0] } Catch { "Error" }
                $DateFilter = Try { ($Line | Out-String).Split("=")[2].Split(" ")[0].Replace('"','') } Catch { Continue }
                $ComponentFilter = Try { ($Line | Out-String).Split("=")[3].Split(" ")[0].Replace('"','') } Catch { Continue }
                If ($ComponentFilter) { Try { $Description = Get-ComponentDescription -Name $ComponentFilter } Catch { $Description = "No translation available. Update Get-ComponentDescription" } }

                $CodeFilter += New-Object -TypeName PSCustomObject -Property @{ErrorCode=$Code;Date=$DateFilter;Time=$TimeFilter;Log=$ComponentFilter;LogDesc=$Description}

            }  # End If ElseIf

        }  # End ForEach

        If (-Not $All.IsPresent) {
       
            Write-Verbose "Selecting unique error codes"
            $Results = $CodeFilter | Sort-Object -Unique -Property ErrorCode

        } Else {

            Write-Verbose "Selecting all error codes"
            $Results = $CodeFilter

        }  # End If Else

        If (!$Results) {

            Write-Output "[*] SUCCESS! No Windows Update errors on $($Date.ToShortDateString())"

        } Else {
           
            If ($Null -ne $CodeFilter) {

                Return $Results

            } Else {

                Write-Output "[i] No error codes found in the windows update logs"
               
            }  # End If Else

        }  # End If Else

    } Else {

        Write-Error "[x] No log files in the location specified: $Path"
   
    }  # End If Else

}  # End Function Get-WindowsUpdateErrorCode
