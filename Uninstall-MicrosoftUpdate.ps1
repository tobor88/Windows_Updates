#Requires -Version 2
#Requires -RunAsAdministrator
Function Uninstall-MicrosoftUpdate {
<#
.SYNOPSIS
Uninstalls one or more Windows updates.

.DESCRIPTION
Accepts update objects (e.g., the output of `Find‑Microsoftupdate -ShowInstalled`) or a list of KB identifiers.
The cmdlet removes each update that supports the “uninstall” operation.


.PARAMETER Update
One or more Microsoft.Update.Update objects to remove (pipeline‑compatible).

.PARAMETER KBNumber
One or more KB identifiers (e.g. "KB5006670").


.EXAMPLE
Uninstall-MicrosoftUpdate -KBNumber "KB5006670"

.EXAMPLE
PS> (Find-MicrosoftUpdate -ShowInstalled | Where-Object -FilterScript { $_.Title -match 'Security' } | Sort-Object -Property LastDeploymentChangeTime -Descending)[0] | Uninstall-MicrosoftUpdate
# This example finds install Microsoft Updates and uninstalls them


.NOTES
Last Updated: 9/1/2025
Author: Robert H. Osborne
Contact: rosborne@osbornepro.com


.LINK
https://osbornepro.com
#>
[CmdletBinding(
    ConfirmImpact="Medium",
    SupportsShouldProcess=$True,
    DefaultParameterSetName="ByObject"
)]
    param (
        [Parameter(
            ParameterSetName='ByObject',
            Mandatory=$True,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyValue = $False
        )]  # End Parameter
        [Microsoft.Update.Update[]]$Update,

        [Parameter(
            ParameterSetName='ByKb',
        )]  # End Parameter
        [ValidatePattern('^KB\d{6,18}$')]
        [String[]]$KBNumber
    )  # End para,

BEGIN {

    $InfoPref = $InformationPreference
    $InformationPreference = "Continue"
    $ToRemove = @()
    
} PROCESS {

    If ($PSCmdlet.ParameterSetName -eq 'ByObject') {
        $ToRemove += $Update
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByKb') {
        # Resolve KB numbers to installed update objects
        $Installed = Find-Microsoftupdate -ShowInstalled
        ForEach ($KB in $KBNumber) {
            $Matched = $Installed | Where-Object -FilterScript { $_.KBArticleIDs -contains $KB }
            If ($Matched) {
                $ToRemove += $Matched
            } Else {
                Write-Warning -Message "KB $($KB) not found among installed updates."
            }  # End If Else
        }  # End ForEach
    }  # End If ElseIf
        
} END {

    If ($ToRemove.Count -eq 0) {
        
        Write-Information -MessageData "No updates selected for removal."
        Return
        
    }  # End If

    $Session = New-Object -ComObject Microsoft.Update.Session
    $Uninstaller = $Session.CreateUpdateInstaller()
    $Uninstaller.IsForced = $True     # Force removal when possible
    $Uninstaller.RebootBehavior = 2   # Never auto‑reboot
            
    ForEach ($Upd in $ToRemove) {
    
        If (-not $PSCmdlet.ShouldProcess("$($upd.Title)", "Uninstall")) { Continue }
            $Coll = New-Object -ComObject Microsoft.Update.UpdateColl
            $Coll.Add($upd) | Out-Null
            $Uninstaller.Updates = $coll
            $Result = $uninstaller.Uninstall()
            If ($Result.HResult -eq 0 -and $result.ResultCode -eq 2) {
                Write-Information -MessageData "Successfully removed: $($Upd.Title)"
            } Else {
                Write-Warning -Message "Failed to remove $($Upd.Title). ResultCode=$($Result.ResultCode) HResult=$($Result.HResult)"
            }  # End If Else
        }  # End ForEach
        $InformationPreference = $InfoPref

}  # End B P E
    
}  # End Function Uninstall-MicrosoftUpdate
