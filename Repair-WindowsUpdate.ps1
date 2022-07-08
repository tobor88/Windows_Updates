<#
.SYNOPSIS
This cmdlet is used to perform a typical repair operation for Windows Updates that are stuck in a Retry Fail cycle


.DESCRIPTION
Performs actions that typicall repair Windows Updates that fail to install


.PARAMETER ServiceName
Define the services to stop that allow you to renamed the defined files

.PARAMETER Path
Define the path(s) to directories to rename that will allow windows update to try downloading and installing updates again


.EXAMPLE
Repair-WindowsUpdate -Path "C:\Windows\SoftwareDistribution","C:\Windows\System32\catroot2"
# Stops the services cryptsvc,wuauserv,bits,msiserver and renames the Windows Update directories C:\Windows\SoftwareDistribution and C:\Windows\System32\catroot2 before restarting the computer

.EXAMPLE
Repair-WindowsUpdate
# Stops the services cryptsvc,wuauserv,bits,msiserver and renames the Windows Update directories C:\Windows\SoftwareDistribution and C:\Windows\System32\catroot2 before restarting the computer


.NOTES
Author: Robrt H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.INPUTS
None


.OUTPUTS
None


.LINK
https://github.com/tobor88
https://gitlab.com/tobor88
https://www.powershellgallery.com/profiles/tobor
https://osbornepro.com
https://writeups.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
#>
Function Repair-WindowsUpdate {
    [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(
                Position=0,
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [ValidateScript({Get-Service -Name $_})]
            [String[]]$Services = @("cryptsvc","wuauserv","bits","msiserver"),

            [Parameter(
                Position=1,
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [ValidateScript({Test-Path -Path $_})]
            [String[]]$Path = @("C:\Windows\SoftwareDistribution","C:\Windows\System32\catroot2"),

            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$Restart

        )  # End param
   
    If ($PSCmdlet.ShouldProcess($Path)) {

        Write-Output "[*] Stopping services that use the directories we need renamed"
        Stop-Service -Name $Services -Force -Confirm:$False

        ForEach ($P in $Path) {

            If (Test-Path -Path "$($P).bak") {

                Write-Output "[*] Removing the previously backed up directory $($P).bak"
                Remove-Item -Path "$($P).bak" -Recurse -Force -Confirm:$False

            }  # End If

            Write-Output "[*] Renaming $($P) to $($P).bak"
            Try {
           
                Move-Item -Path $P -Destination "$($P).bak" -Force -Confirm:$False

            } Catch {

                Rename-Item -Path $P -NewName "$($P).bak" -Force -Confirm:$False

            }  # End Catch

            If ($Restart.IsPresent) {

                Write-Output "[*] Restarting device, update Windows After the restart"
                Restart-Computer -Confirm:$False -Force

            } Else {
           
                Write-Output "[!] Machine still requires a restart to finish fixing failed update"

            }  # End If Else

        }  # End ForEach

    } Else {
   
        # The -WhatIf parameter was used. Simulating requested actions.
        Stop-Service -Name $Services -Force -Confirm:$False -WhatIf

        ForEach ($P in $Path) {

            If (Test-Path -Path "$($P).bak") {

                Remove-Item -Path "$($P).bak" -Recurse -Force -WhatIf

            }  # End If

            Move-Item -Path $P -Destination "$($P).bak" -WhatIf

            If ($Restart.IsPresent) {

                Restart-Computer -WhatIf    

            }  # End If

        }  # End ForEach

    }  # End If Else ShouldProcess

}  # End Function Repair-WindowsUpdate
