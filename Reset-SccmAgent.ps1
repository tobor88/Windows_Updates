<#
.SYNOPSIS
This cmdlet is used to clear the SCCM cache and restart the SCCM service which runs all the Actions in Configuration Manager


.DESCRIPTION
Clear the SCCM cache and restart the CcmExec service


.PARAMETER ServiceName
Define the SCCM service name to restart. Default value is CcmExec

.PARAMETER Path
Define a path to the SCCM Cache parent directory. Default value is C:\Windows\ccmcache


.EXAMPLE
Reset-SccmAgent
# This example restarts the CcmExec service and deletes the cache files in C:\Windows\ccmcache

.EXAMPLE
Reset-SccmAgent -ServiceName -Path C:\Windows\ccmcache
# This example restarts the CcmExec service and deletes the cache files in C:\Windows\ccmcache


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.INPUTS
None


.OUTPUTS
None


.LINK
https://osbornepro.com
https://btpssecpack.osbornepro.com
https://writeups.osbornepro.com
https://github.com/OsbornePro
https://github.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
#>
Function Reset-SccmAgent {
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$False)]  # End Parameter
            [ValidateScript({Get-Service -Name $_})]
            [String]$ServiceName = 'CcmExec',

            [Parameter(
                Position=1,
                Mandatory=$False
                #HelpMessage="Define the SCCM directory containing cache files EXAMPLE: C:\Windows\ccmcache"
            )]  # End Parameter
            [ValidateScript({Test-Path -Path $_})]
            [String]$Path = "C:\Windows\ccmcache"
        )  # End param
   
    Write-Verbose "Restarting the $ServiceName service"
    Restart-Service -Name $ServiceName -Force -Confirm:$False -PassThru

    Try {
       
        Write-Verbose "Deleting the file $Path"
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
       
    } Catch {

        Write-Error $_.Exception.Message

    }  # End Catch

}  # End Reset-SccmAgent
