<#
.SYNOPSIS
This cmdlet is used to return the error code that caused a windows update to fail. It also saves Windows Update logs to the executers desktop


.DESCRIPTION
Export the Windows Update logs to your desktop and return the error code that contains information on the failed update


.PARAMETER RunWindowsTroubleshooter
Tells the cmdlet to run the Windows Troubleshooter if any error codes are returned

.PARAMETER Force
Tells the cmdlet to run the Windows Troubleshooter even if there are no errors returned


.EXAMPLE
Get-WindowsUpdateErrorCode
# Generates a Windows Update log file and saves it to the running users desktop and returns the error code for the failed updates

.EXAMPLE
Get-WindowsUpdateErrorCode -RunWindowsTroubleshooter
# Generates a Windows Update log file and saves it to the running users desktop and returns the error code for the failed updates. Runs the Windows Troubleshooter.

.EXAMPLE
Get-WindowsUpdateErrorCode -RunWindowsTroubleshooter -Force
# Generates a Windows Update log file and saves it to the running users desktop and returns the error code for the failed updates. Runs the Windows Troubleshooter.


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
Function Get-WindowsUpdateErrorCode {
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch]$RunWindowsTroubleshooter,
            
            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch]$Force
        )  # End param

    Write-Verbose "Building update log file, please wait as this may take a up to a minute to complete."
    $Job = Start-Job -ScriptBlock { Get-WindowsUpdateLog -ErrorVariable ErrorVariable }
    $Job | Wait-Job | Remove-Job

    $UpdateLog = "$env:USERPROFILE\Desktop\WindowsUpdate.log"
    If (Test-Path -Path "$env:OneDrive\Desktop\WindowsUpdate.log" -ErrorAction SilentlyContinue) {

        $UpdateLog = "$env:OneDrive\Desktop\WindowsUpdate.log"
   
    }  # End If

    Write-Verbose "Verifying update log was last written too today"
    [datetime]$Today = Get-Date
    $FileProperties = Get-ChildItem -Path $UpdateLog
    If ((Test-Path -Path $UpdateLog -ErrorAction SilentlyContinue) -and ($FileProperties.LastWriteTime.ToShortDateString() -eq ($Today).ToShortDateString())) {

        Write-Verbose "Successfully created Windows Update log file"
        $Pattern = 'ERROR'
        $ErrorLog = $UpdateLog.Replace("WindowsUpdate.log","WindowsError.log")
        Get-Content -Path $UpdateLog | Select-String -Pattern $Pattern | Out-File -FilePath $ErrorLog
        $ErrorLogContents = Get-Content -Path $ErrorLog

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

            Write-Output "[*] SUCCESS! No Windows Update errors over the last 24 hours"

        } Else {

            [array]$ErrorCodeLine = ($WriteLine | Select-String -Pattern '[0-9]x(.*){8}' | Select-Object -First 1 | Out-String).Trim().Split(":")[-1] -Split " "
            $ErrorCode = ($ErrorCodeLine | Where-Object -FilterScript { $_ -Match '[0-9]x(.*){8}' }).Replace(",","").Trim()

            If ($ErrorCode) {

                If ($RunWindowsTroubleshooter.IsPresent) {

                    Write-Verbose "Switch to run the Windows Troubleshooter is present"
                    Get-TroubleshootingPack -Path "C:\Windows\Diagnostics\System\WindowsUpdate" | Invoke-TroubleshootingPack -Result "C:\DiagResult"
                    Write-Output "[*] Troubleshooting results saved to C:\DiagResult"

                }  # End If
                Return $ErrorCode

            } Else {

                Write-Output "[i] No error codes found in the windows update logs"
                If ($Force.IsPresent) {
                
                    $Answer = "y"
                    
                } Else {
                
                    $Answer = Read-Host -Prompt "Would you like to run the Troubleshooter anyway? [y/N]"
                    
                }  # End If Else
                
                If ($Answer -like "y*") {
                
                    If ($RunWindowsTroubleshooter.IsPresent) {

                        Write-Verbose "Switch to run the Windows Troubleshooter is present"
                        Get-TroubleshootingPack -Path "C:\Windows\Diagnostics\System\WindowsUpdate" | Invoke-TroubleshootingPack -Result "C:\DiagResult"
                        Write-Output "[*] Troubleshooting results saved to C:\DiagResult"

                    }  # End If
                    
                }  # End If

            }  # End If Else

        }  # End If Else

    } Else {
   
        Write-Output "[x] Failed to create Windows Update log file"
        Throw "$ErrorVariable"

    }  # End If Else

}  # End Function Get-WindowsUpdateErrorCode
