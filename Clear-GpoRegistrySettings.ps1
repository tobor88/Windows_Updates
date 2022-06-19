<#
.SYNOPSIS
This cmdlet is used to rebuild the registry.pol machine group policy settings


.DESCRIPTION
Rename the registry.pol file to rebuild a local machines group policy settings


.PARAMETER NewName
Define a location to save the backup of the registry.pol file using this value

.PARAMETER SkipGpUpdate
Tell the cmdlet to not execute a gpupdate after renaming the registry.pol machine group policy file


.EXAMPLE
Clear-GpoRegistrySettings
# This example renames C:\Windows\System32\GroupPolicy\Machine\Registry.pol to C:\Windows\System32\GroupPolicy\Machine\Registry.old and runs a gpupdate

.EXAMPLE
Clear-GpoRegistrySettings -NewName C:\Windows\System32\GroupPolicy\Machine\Registry.old
# This example renames C:\Windows\System32\GroupPolicy\Machine\Registry.pol to C:\Windows\System32\GroupPolicy\Machine\Registry.old and runs a gpupdate

.EXAMPLE
Clear-GpoRegistrySettings -SkipGpUpdate
# This example renames C:\Windows\System32\GroupPolicy\Machine\Registry.pol to C:\Windows\System32\GroupPolicy\Machine\Registry.old and does not run a gpupdate


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
Function Clear-GpoRegistrySettings {
    [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(
                Position=0,
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [String]$NewName = "C:\Windows\System32\GroupPolicy\Machine\Registry.old",

            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$SkipGpUpdate
        )  # End param
   
    $RegPolPath = "C:\Windows\System32\GroupPolicy\Machine\Registry.pol"
    If (Test-Path -Path $RegPolPath -ErrorAction SilentlyContinue) {

        If ($PSCmdlet.ShouldProcess($NewName)) {
       
            Write-Output "[*] $RegPolPath file verified to exist, renaming file"
            Move-Item -Path $RegPolPath -Destination $NewName -Force -Confirm:$False -PassThru -ErrorVariable $MoveFailed
           
            If ($MoveFailed) {

                Write-Ouput "[x] Failed to rename Registry.pol file to $NewName"

            }  # End If

            If (Test-ComputerSecureChannel) {

                If (!($SkipGpUpdate.IsPresent)) {

                    Write-Output "[*] Performing group policy update"
                    gpupdate /force

                }  # End If

            } Else {
           
                Throw "[x] $env:COMPUTERNAME : Domain trust failed, group policy update can not be performed"

            }  # End If Else


        } Else {
       
            # Rename $RegPolPath to $NewName and performs a group policy update
            Move-Item -Path $RegPolPath -Destination $NewName -Force -Confirm:$False -PassThru -WhatIf

        }  # End If Else

    } Else {
   
        Write-Error "[x] $RegPolPath file does NOT exist!"

    }  # End If Else

}  # End Function Clear-GpoRegistrySettings
