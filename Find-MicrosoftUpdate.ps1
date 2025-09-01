Function Find-MicrosoftUpdate {
<#
.SYNOPSIS
Finds available Microsoft Windows updates.


.DESCRIPTION
Queries the Windows Update COM API and returns a collection of update objects.
By default only non‑hidden, non‑driver, not‑installed updates are returned.
Use the switches to change the behaviour.


.PARAMETER IncludeHidden
Include hidden updates in the search.

.PARAMETER ShowInstalled
Return installed updates instead of pending ones.

.PARAMETER IncludeDriver
Include driver‑type updates (Category = "Drivers").


.EXAMPLE
Find-MicrosoftUpdate
# Lists pending non‑driver updates.

.EXAMPLE
Find-MicrosoftUpdate -IncludeDriver
# Lists pending updates **including** drivers.

.EXAMPLE
Find-Microsoftupdate -ShowInstalled -IncludeDriver
# Lists installed driver updates.


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
        [Switch]$IncludeHidden,
        [Switch]$ShowInstalled,
        [Switch]$IncludeDriver
    )  # End param

    $InfoPref = $InformationPreference
    $InformationPreference = "Continue"
    Try {
    
        $RequiredService = Get-Service -Name wuauserv -ErrorAction Stop
        If ($RequiredService.Status -ne "Running") {

            Start-Service -Name wuauserv -Confirm:$False -ErrorAction Stop

        }  # End If

        If ($ShowInstalled) {

            $BaseQuery = "IsInstalled=1 and Type='Software'"

        } Else {

            If ($IncludeHidden) { 

                $BaseQuery = $BaseQuery + " and IsHidden=1"

            }  # End If
            
        }  # End If Else
        
        If (!($IncludeDriver)) {

            # Exclude driver categories – the CategoryID for drivers is 2
            $BaseQuery = "$BaseQuery and CategoryIDs not contains 2"

        }  # End If
  
        Try {
      
            Write-Debug -Message "Search query string: $($BaseQuery)"
            $Searcher = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
            $Result = $Searcher.Search($BaseQuery)
            If ($Result.Updates.Count -eq 0) {

                Write-Information -MessageData "No matching updates were found."
                Return

            }  # End If
            $Result.Updates
          
        } Catch {

            Throw "Failed to query Windows Update: $($Error[0].Exception.Message)"

        }  # End Try Catch

    } Finally {
  
        $InformationPreference = $InfoPref
      
    }  # End Try Finally

}  # End Function Find-MicrosoftUpdate
