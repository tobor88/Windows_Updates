<#
.SYNOPSIS
This cmdlet is for uninstalling a Windows Update.
This can remove multiple hot fixes and it can remove hot fixes from an array of remote computers.


.DESCRIPTION
Cmdlet that is used to remove a speficied Windows Update or Updatesfrom a local computer or a remote host or hosts. 
A list of computer names can be piped to this function by property name.


.PARAMETERS HotFixID 
Specifies the hotfix IDs that this cmdlet gets.

.PARAMETER ComputerName
Specifies a remote computer. The default is the local computer.

.PARAMETER Restart
Indicates you wish to perform a restart after removing the update.

.EXAMPLE
Remove-WindowsUpdate -HotFixID "4556799"
# This examples uninstalls 4556799 from the local computer if it is installed.

.EXAMPLE
Remove-WindowsUpdate "KB4556799"
# This examples also uninstalls HotFix KB4556799 from the local computer.

.EXAMPLE 3
Remove-WindowsUpdate -HotFixID "KB4556799" -ComputerName 10.10.10.120 -Restart
# This examples uninstalls HotFix KB4556799 from a remote computer at 10.10.10.120 and if a restart is needed allows it to restart.

EXAMPLE
Remove-WindowsUpdate "KB4556799" 10.10.10.120
# This examples also uninstalls HotFix KB4556799 from a remote computer at 10.10.10.120.


.NOTES
Author: Robrt H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.INPUTS
System.String
You can pipe computer names to this cmdlet..
In Windows PowerShell 2.0, the ComputerName parameter takes input from the pipeline only by property name. 
In Windows PowerShell 3.0, the ComputerName parameter takes input from the pipeline by value.


.OUTPUTS
None, System.Management.Automation.RemotingJob
This cmdlet returns a job object, if you specify the AsJob parameter. Otherwise, it does not generate any output.


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
Function Remove-WindowsUpdate {
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory=$True,
                Position=0,
                ValueFromPipeline=$False,
                HelpMessage="Enter the Windows Update KB number(s) you wish to uninstall. Separate multiple values with a comma.`nExample: KB4556799','KB4556798' (4556799 is also acceptable) `n")]  # End Paramater
            [String[]]$HotFixID,

            [Parameter(
                Mandatory=$False,
                Position=1,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage="Enter the name or names of the remote compute you wish to uninstall. Separate multiple values with a comma. `nExample: 'Comp1.domain.com','Comp2','10.10.10.123'`n")]  # End Paramater
            [ValidateNotNullOrEmpty()]
            [String[]]$ComputerName,
    
            [Parameter(
                Mandatory=$False,
                ValueFromPipeline=$False)]
             [ValidateNotNull()]
             [System.Management.Automation.PSCredential]
             [System.Management.Automation.Credential()]
             $Credential = [System.Management.Automation.PSCredential]::Empty,

            [Parameter(
                Mandatory=$False)]
            [Switch][Bool]$Restart
        )  # End param

BEGIN {

    If ($ComputerName) {

        For ($i = 0; $i -lt $ComputerName.Count ; $i++) {

            ForEach ($Computer in $ComputerName) {

                Write-Verbose "[*] Testing specified $Computer is reachable"
                If (Test-Connection -ComputerName $Computer -Quiet -ErrorAction Inquire) {

                    Write-Verbose "[*] $Computer is reachable"
                    If ($Null -eq $Cred) {

                        $Cred = Get-Credential -Message "Administrator Credentials are required to execute commands on remote hosts" -Username ($env:USERNAME + "@" + $env:USERDNSDOMAIN)

                    }  # End If
                    
                    New-Variable -Name "Session$i" -Value (New-PsSession -HiComputerName $Computer -Credential $Cred -Name $Computer -EnableNetworkAccess -Port 5985)

                }  # End If

            }  # End ForEach

        }  # End For

    }  # End If

}  # End BEGIN
PROCESS {

    If ($ComputerName) {
    
        For ($n = 0; $n -lt $ComputerName.Count; $n++) {

            ForEach ($C in $ComputerName) {

                Write-Verbose "[*] Starting connection to $C"
                Invoke-Command -Session (Get-Variable -Name "Session$n").Value -ArgumentList $HotFixID -ScriptBlock {
                    param([array]$HotFixID)
                    
                    Write-Output "[*] $env:COMPUTERNAME: Getting list of installed patches"
                    $PatchList = Get-CimInstance -ClassName "Win32_QuickFixEngineering" -Namespace "root\cimv2"

                    ForEach ($HotFix in $HotFixID) {

                        $Patch = $PatchList | Where-Object { $_.HotFixID -like "$HotFix" }
                        Write-Output "[*] $Patch will be removed from $env:COMPUTERNAME"

                        If (!($Patch)) {

                            Write-Output "[!] $env:COMPUTERNAME: The Windows Update KB number you defined is not installed on $env:COMPUTERNAME. Below is a table of installed patches: "
                            Remove-Variable -Name "Patch"

                            $PatchList

                        }  # End If
                        Else {

                            Write-Output "[*] $env:COMPUTERNAME: $HotFix is installed on $env:COMPUTERNAME, continuing uninstallation"
                            $KBNumber = $Patch.HotfixId.Replace("KB", "") | Out-String

                            If ($Restart.IsPresent) {

                                Write-Output "[*] $env:COMPUTERNAME: Restart switch parameter is defined. You will be prompted to restart."
                                cmd /c wusa /uninstall /kb:$KBNumber /promptrestart /log

                            }  # End If
                            Else {

                                cmd /c echo y | wusa /uninstall /kb:$KBNumber /norestart /log

                            }  # End Else

                            While (@(Get-Process wusa -ErrorAction SilentlyContinue).Count -ne 0) {

                                Start-Sleep -Seconds 10
                                Write-Output "[*] $env:COMPUTERNAME: Waiting for update removal to finish. Please wait..."

                            }  # End While

                        }  # End Else

                    }  # End ForEach

                }  # End Invoke-Command

                Write-Output "[*] Finished removing updates from $C"

            }  # End ForEach

        }  # End For

    }  # End If
    Else {

        Write-Verbose "[*] $env:COMPUTERNAME: Getting list of installed patches"
        $PatchList = Get-CimInstance -ClassName "Win32_QuickFixEngineering" -Namespace "root\cimv2"

        ForEach ($HotFix in $HotFixID) {

            $Patch = $PatchList | Where-Object { $_.HotFixID -like "$HotFix" }
            If (!($Patch)) {

                Write-Output "[!] $env:COMPUTERNAME: The Windows Update KB number you defined is not installed on $env:COMPUTERNAME. Below is a table of installed patches: "
                Remove-Variable -Name "Patch"

                $PatchList

            }  # End If
            Else {

                $KBNumber = $Patch.HotfixId.Replace("KB", "") | Out-String
                If ($Restart.IsPresent) {

                    Write-Output "[*] $env:COMPUTERNAME: Restart switch parameter is defined. You will be prompted to restart."
                    cmd /c wusa /uninstall /kb:$KBNumber /promptrestart /log

                }  # End If
                Else {

                    cmd /c wusa /uninstall /kb:$KBNumber /norestart /log

                }  # End Else

                While (@(Get-Process wusa -ErrorAction SilentlyContinue).Count -ne 0) {

                    Start-Sleep -Seconds 10
                    Write-Output "[*] Waiting for update removal to finish. Please wait..."

                }  # End While

                Write-Output "[*] Update removal has completed"

            }  # End Else

        }  # End ForEach

    }  # End Else

}  # End PROCESS
END {

    If (Get-PsSession) {

        Write-Verbose "[*] Closing connection to remote computers."
        Remove-PsSession *

    }  # End If

}  # End END

}  # End Function Remove-WindowsUpdate
