Function Get-UpdateHistory {
<#
.SYNOPSIS
This cmdlet is used to return information on the history of Windows Updates


.DESCRIPTION
Return a list of installed updates on local or remote devices


.PARAMETER ComputerName	
Define computer(s) to remotely return the Windows Update history of


.EXAMPLE
"DC01.domain.com","DHCP.domain.com" | Get-WUHistory
# Return information on Windows Update history for remote devices

	
.EXAMPLE  
Get-WUHistory
# Return information on Windows Updates that were installed and how


.NOTES
Author: Robert Osborne
Contact: rosborne@advisor360.com, rosborne@vinebrooktech.com

		
.LINK
https://vinebrooktech.com


.INPUTS
System.String[]


.OUTPUTS
PSCustonObject	
#>
[OutputType('PSWindowsUpdate.WUHistory')]
[CmdletBinding(
    SupportsShouldProcess=$True,
    ConfirmImpact="Low")]
	    param(
		    [Parameter(
                Position=0,
                Mandatory=$False,
                ValueFromPipeline=$True,
			    ValueFromPipelineByPropertyName=$True)]  # End Parameter
            [ValidateScript({Test-Connection -CompuerName $env:COMPUTERNAME -Count 2 -BufferSize 32 -Quiet})]
		    [String[]]$ComputerName = $env:COMPUTERNAME
	)  # End param

BEGIN {

    $UpdateCollection = @()

} PROCESS {
		
    ForEach ($Computer in $ComputerName) {

        Write-Verbose "Building Windows Update history list"
		
        If ($PSCmdlet.ShouldProcess($Computer,"Get updates history")) {
				
            Write-Verbose -Message "Getting updates history for $Computer"
            If ($Computer -like $env:COMPUTERNAME) {

                Write-Verbose -Message "Creating Microsoft.Update.Session object for local device $Computer"
                $Session = New-Object -ComObject Microsoft.Update.Session

            } Else {

                Write-Verbose -Message "Creating update session for remote device $Computer"
                $Session =  [Activator]::CreateInstance([Type]::GetTypeFromProgID("Microsoft.Update.Session",$Computer))

            }  # End If Else

            Write-Verbose -Message "Creating update searcher for $Computer"
            $Searcher = $Session.CreateUpdateSearcher()
            $TotalHistoryCount = $Searcher.GetTotalHistoryCount()

            If($TotalHistoryCount -gt 0) {

				$History = $Searcher.QueryHistory(0, $TotalHistoryCount)
				$NumberOfUpdate = 1
				Foreach($H in $History) {

                    Write-Verbose -Message "Searching $($NumberOfUpdate)/$($TotalHistoryCount) $($H.Title) `nUPDATE: $($H.Title)"

					$Matches = $Null
					$H.Title -match "KB(\d+)" | Out-Null
							
					If($Matches -eq $Null) {

						Add-Member -InputObject $H -MemberType NoteProperty -Name KB -Value ""

					} Else {
							
						Add-Member -InputObject $H -MemberType NoteProperty -Name KB -Value ($matches[0])

					}  # End If Else
							
					Add-Member -InputObject $H -MemberType NoteProperty -Name ComputerName -Value $Computer
                    Switch ($H.ResultCode) {

                        '1' { $Result = "In Progress" }

                        '2' { $Result = "Succeeded" }

                        '3' { $Result = "Succeeded with Errors" }

                        '4' { $Result = "Failed" }

                        '5' { $Result = "Aborted" }

                    }  # End Switch
                    Add-Member -InputObject $H -MemberType NoteProperty -Name Result -Value $Result
							
					$H.PSTypeNames.Clear()
					$H.PSTypeNames.Add('PSWindowsUpdate.WUHistory')
						
					$UpdateCollection += $H
					$NumberOfUpdate++

				}  # End Foreach

			} Else {

				Write-Warning "Update history was likely cleared. No results could be returned"

			}  # End If Else

		}  # End If

	}  # End Foreach

} END {

    Return $UpdateCollection

}  # End BPE
	
}  # End Function Get-UpdateHistory
