<#
.SYNOPSIS
This cmdlet is used to repair a failed windows update related to a policy error. 


.DESCRIPTION
Renames the C:\Windows\System32\GroupPolicy\Machine\Registry.pol file and initiates a group policy update to attempt fixing a failed windows update caused by some kind of policy error


.PARAMETER NewName
Define the new file name and location to save the registry.pol file backup as


.EXAMPLE
Clear-GpoRegistrySettings
# This example renames the registry file C:\Windows\System32\GroupPolicy\Machine\Registry.pol to C:\Windows\System32\GroupPolicy\Machine\Registry.old

.EXAMPLE
Clear-GpoRegistrySettings -NewName C:\Windows\System32\GroupPolicy\Machine\Registry.bak
# This example renames the registry file C:\Windows\System32\GroupPolicy\Machine\Registry.pol to C:\Windows\System32\GroupPolicy\Machine\Registry.bak


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
None
#>
Function Clear-GpoRegistrySettings {
    [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(
                Position=0,
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [String]$NewName = "C:\Windows\System32\GroupPolicy\Machine\Registry.old"
        )  # End param
   
    If (Test-Path -Path $RegPolPath -ErrorAction SilentlyContinue) {

        If ($PSCmdlet.ShouldProcess($NewName)) {
       
            Write-Output "[*] $RegPolPath file verified to exist, renaming file"
            Move-Item -Path $RegPolPath -Destination $NewName -Force -Confirm:$False -PassThru
           
            Write-Output "[*] Performing group policy update"
            gpupdate /force

        } Else {
       
            # Rename $RegPolPath to $NewName and performs a group policy update
            Move-Item -Path $RegPolPath -Destination $NewName -Force -Confirm:$False -PassThru -WhatIf

        }  # End If Else

    }  # End If

}  # End Function Clear-GpoRegistrySettings
