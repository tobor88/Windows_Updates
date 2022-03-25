<#
.SYNOPSIS
This cmdlet is used to compile a log file of Windows Update Errors.
You are then prompted to run the Windows Update troubleshooter.
You are prompted to try installing the update again.


.DESCRIPTION
This cmdlet is used to discover why a Windows Update failed and offer a way to fix and install the failed Windows Update.


.EXAMPLE
Get-WindowsUpdateError


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
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
#>
Function Get-WindowsUpdateError {
    [CmdletBinding()]
        param()
    Write-Output "[*] Building update log file, please wait as this may take a up to a minute to complete."
    $Job = Start-Job -ScriptBlock { Get-WindowsUpdateLog -ErrorVariable ErrorVariable }
    $Job | Wait-Job | Remove-Job


    Write-Output "[*] Verifying log was updated today"
    If ($env:OneDrive) {

        $UpdateLog = "$env:OneDrive\Desktop\WindowsUpdate.log"

    } Else {

        $UpdateLog = "$env:USERPROFILE\Desktop\WindowsUpdate.log"

    }  # End If Else


    Write-Output "[*] Verifying update log was last written too today"
    [datetime]$Today = Get-Date
    $FileProperties = Get-ChildItem -Path $UpdateLog
    If ((Test-Path -Path $UpdateLog) -and ($FileProperties.LastWriteTime.ToShortDateString() -eq ($Today).ToShortDateString())) {

        Write-Output "[*] Successfully created Windows Update log file"
        $Pattern = 'ERROR'
        $ErrorLog = $UpdateLog.Replace("WindowsUpdate.log","WindowsError.log")
        Get-Content -Path $UpdateLog | Select-String -Pattern $Pattern | Out-File -FilePath $ErrorLog
        $ErrorLogContents = Get-Content -Path $ErrorLog

        Do {

            $Answer = Read-Host -Prompt "Would you like to view errors from the last 24 hours or the Week? [t/w]"
            If ($Answer -like "t*") {

                $WriteLine = @()
                ForEach ($Line in $ErrorLogContents) {

                    If ($Line -NotLike "*succeeded with errors = 0*" -and $Line -NotLike "*and error 0") {

                        Write-Verbose "Checking for entires in the last 24 hours"
                        Try {

                            [datetime]$CheckDate = ($Line.ToCharArray() | Select-Object -First 19 ) -Join ''
                            If (($Null -ne $CheckDate) -and ($CheckDate -gt $Today.AddHours(-24))) {

                                $WriteLine += $Line

                            }  # End If

                        } Catch {

                            Continue

                        }  # End Try Catch

                    }  # End If

                }  # End ForEach

                If (!$WriteLine) {

                    Write-Host "SUCCESS! No Windows Update errors over the last 24 hours" -ForegroundColor Green

                } Else {

                    $WriteLine
                    $Answer = Read-Host -Prompt "Based on the error messages above, should we run the Windows Update Troubleshooter? [y/N]"
                    If ($Answer -like "y*") {

                        Get-TroubleshootingPack -Path "C:\Windows\Diagnostics\System\WindowsUpdate" | Invoke-TroubleshootingPack -Result "C:\DiagResult"
                        Write-Output "[*] Troubleshooter results saved to C:\DiagResult"

                    }  # End If

                    $RunUpdate = Read-Host -Prompt "Would you like to try updating Windows again now? [y/N]"
                    If ($RunUpdate -like "y*") {

                        Write-Output "[*] Running Windows Update"
                        $Updates = Start-WUScan -SearchCriteria "Type='Software' AND IsInstalled=0"
                        If ($Updates) {

                            Install-WUUpdates -Updates $Updates

                        } Else {

                            Write-Host "Hooray! No more Windows Updates to install" -ForegroundColor Green

                        }  # End Else

                    }  # End If

                }  # End If Else

            } ElseIf ($Answer -like "w*") {

                $WriteLine = @()
                ForEach ($Line in $ErrorLogContents) {

                    If ($Line -NotLike "*succeeded with errors = 0*" -and $Line -NotLike "*and error 0") {

                        Write-Verbose "Checking all the Windows Update error log entries"
                        $WriteLine += $Line

                    }  # End If

                }  # End ForEach

                If (!$WriteLine) {

                    Write-Host "SUCCESS! No Windows Update errors over the last 24 hours" -ForegroundColor Green

                } Else {

                    $WriteLine + "`n"
                    $Answer = Read-Host -Prompt "Based on the error messages above, should we run the Windows Update Troubleshooter? [y/N]"
                    If ($Answer -like "y*") {

                        Get-TroubleshootingPack -Path "C:\Windows\Diagnostics\System\WindowsUpdate" | Invoke-TroubleshootingPack -Result "C:\DiagResult"
                        Write-Output "[*] Troubleshooter results saved to C:\DiagResult"

                    }  # End If

                    $RunUpdate = Read-Host -Prompt "Would you like to try updating Windows again now? [y/N]"
                    If ($RunUpdate -like "y*") {

                        Write-Output "[*] Running Windows Update"
                        $Updates = Start-WUScan -SearchCriteria "Type='Software' AND IsInstalled=0"
                        If ($Updates) {

                            Install-WUUpdates -Updates $Updates

                        } Else {

                            Write-Host "Hooray! No more Windows Updates to install" -ForegroundColor Green

                        }  # End Else


                    }  # End If

                    Write-Output "[*] Script Execution Complete"

                }  # End If Else

            } Else {

                Write-Output "You just had to be difficult :) Lets try again"

            }  # End If ElseIf Else

        } Until ($Answer -like "t*" -or $Answer -like "w*") # End Do Until

    } Else {

        Write-Output "[x] Failed to create Windows Update log file"
        Throw "$ErrorVariable"

    }  # End If Else

}  # End Function
