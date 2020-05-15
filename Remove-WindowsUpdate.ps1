<#
.NAME
    Remove-WindowsUpdate


.SYNOPSIS
    This cmdlet is for uninstalling a Windows Update. This can remove multiple hot fixes
    and it can remove hot fixes from an array of remote computers.


.DESCRIPTION
    Remove-WindowsUpdate is a cmdlet that is used to remove a speficied Windows Update or Updates
    from a local computer or a remote host or hosts. A list of computer names can be piped to this
    function by property name.


.SYNTAX
    Remove-WindowsUpdate [-HotFixID] <String[]> [<CommonParameters>]


.PARAMETERS
    -HotFixID <String[]>
        Specifies the hotfix IDs that this cmdlet gets.

        Required?                    true
        Position?                    0
        Default value                None
        Accept pipeline input?       False
        Accept wildcard characters?  false

    -ComputerName <String[]>
        Specifies a remote computer. The default is the local computer.

        Type the NetBIOS name, an Internet Protocol (IP) address, or a fully qualified domain name (FQDN) of a remote
        computer.

        Required?                    false
        Position?                    1
        Default value                None
        Accept pipeline input?       true (By Property Name)
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).


.EXAMPLE
    -------------------------- EXAMPLE 1 --------------------------
    Remove-WindowsUpdate -HotFixID "4556799"
    This examples uninstalls 4556799 from the local computer if it is installed.

    -------------------------- EXAMPLE 2 --------------------------
    Remove-WindowsUpdate "KB4556799"
    This examples also uninstalls HotFix KB4556799 from the local computer.

    -------------------------- EXAMPLE 3 --------------------------
    Remove-WindowsUpdate -KB "KB4556799" -ComputerName 10.10.10.120
    This examples uninstalls HotFix KB4556799 from a remote computer at 10.10.10.120.

    -------------------------- EXAMPLE 4 --------------------------
    Remove-WindowsUpdate -ID "KB4556799" 10.10.10.120
    This examples also uninstalls HotFix KB4556799 from a remote computer at 10.10.10.120.


.NOTES
    Author: Rob Osborne
    Alias: tobor
    Contact: rosborne@osbornepro.com


.INPUTS
    System.String
        You can pipe computer names to this cmdlet..

        In Windows PowerShell 2.0, the ComputerName parameter takes input from the pipeline only by property name. In
        Windows PowerShell 3.0, the ComputerName parameter takes input from the pipeline by value.


.OUTPUTS
    None, System.Management.Automation.RemotingJob
        This cmdlet returns a job object, if you specify the AsJob parameter. Otherwise, it does not generate any
        output.


.LINK
    https://github.com/tobor88
    https://www.powershellgallery.com/profiles/tobor
    https://roberthosborne.com

#>
Function Remove-WindowsUpdate {
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory=$True,
                Position=0,
                ValueFromPipeline=$False,
                HelpMessage="Enter the Windows Update KB number(s) you wish to uninstall. Separate multiple values with a comma.`nExample: KB4556799','KB4556798' (4556799 is also acceptable) `n")]  # End Paramater
            [Alias("KB","ID")]
            [String[]]$HotFixID,

            [Parameter(
                Mandatory=$False,
                Position=1,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage="Enter the name or names of the remote compute you wish to uninstall. Separate multiple values with a comma. `nExample: 'Comp1.domain.com','Comp2','10.10.10.123'`n")]  # End Paramater
            [ValidateNotNullOrEmpty()]
            [String[]]$ComputerName
            )  # End param

BEGIN
{

    If ($ComputerName)
    {

        For ($i = 0; $i -lt $ComputerName.Count ; $i++)
        {

            ForEach ($Computer in $ComputerName)
            {

                Write-Verbose "[*] Testing specified $Computer is reachable"

                If (Test-Connection -ComputerName $Computer -Quiet -ErrorAction Inquire)
                {

                    Write-Verbose "$Computer is reachable"
                    Try
                    {

                        If ($Null -eq $Cred)
                        {

                            $Cred = Get-Credential -Message "Administrator Credentials are required to execute commands on remote hosts" -Username ($env:USERNAME + "@" + ((Get-WmiObject Win32_ComputerSystem).Domain))

                        }  # End If

                        New-Variable -Name "Session$i" -Value (New-PsSession -ComputerName $Computer -Credential $Cred -Name $Computer -EnableNetworkAccess -Port 5986 -UseSSL)

                    }  # End Try
                    Catch
                    {

                        Write-Verbose "[*] Skipping certificate validation checks to create an encrypted session with the remote host."

                        New-Variable -Name "Session$i" -Value (New-PsSession -ComputerName $Computer -Credential $Cred -EnableNetworkAccess -Port 5986 -UseSSL -SessionOption (New-PsSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck))

                    }  # End Catch

                }  # End If

            }  # End ForEach

        }  # End For

    }  # End If

}  # End BEGIN
PROCESS
{

    If ($ComputerName)
    {
        For ($n = 0; $n -lt $ComputerName.Count; $n++)
        {

            ForEach ($C in $ComputerName)
            {

                Write-Verbose "Begining removal of update(s) from $C"

                Invoke-Command -Session (Get-Variable -Name "Session$n").Value -ScriptBlock {

                    Write-Verbose "Getting list of installed patches"

                    $PatchList = Get-CimInstance -ClassName "Win32_QuickFixEngineering" -Namespace "root\cimv2"

                    ForEach ($HotFix in $HotFixID)
                    {

                        If (!($PatchList | Where-Object { $_.HotFixID -like $HotFix } ))
                        {

                            Write-Output "The Windows Update KB number you defined is not installed on $C. Below is a table of installed patches: "

                            $PatchList

                        }  # End If
                        Else
                        {

                            $KBNumber = $Hotfix.Replace("KB", "");
                            $RemovalCommand = 'Start-Process -FilePath "C:\Windows\System32\cmd.exe" -Verb RunAs -ArgumentList {/c wusa.exe /uninstall /kb:$HotFix /quiet /log /norestart}'

                            Write-Verbose ("Removing update with command: " + $RemovalCommand);

                            Invoke-Expression -Command $RemovalCommand;

                            While (@(Get-Process wusa -ErrorAction SilentlyContinue).Count -ne 0)
                            {

                                Start-Sleep -Seconds 1

                                Write-Host "Waiting for update removal to finish ..."

                            }  # End While

                        }  # End Else

                    }  # End ForEach

                }  # End Invoke-Command

                Write-Verbose "Finished removing updates from $C"

            }  # End ForEach

        }  # End For

    }  # End If
    Else
    {

        Write-Verbose "Getting list of installed patches on $env:COMPUTERNAME"

        $PatchList = Get-CimInstance -ClassName "Win32_QuickFixEngineering" -Namespace "root\cimv2"

        ForEach ($HotFix in $HotFixID)
        {

            If (!($PatchList | Where-Object { $_.HotFixID -like $HotFix } ))
            {

                Write-Output "The Windows Update KB number you defined is not installed on $env:COMPUTERNAME. Below is a table of installed patches: "

                $PatchList

            }  # End If
            Else
            {

                $KBNumber = $Hotfix.Replace("KB", "");
                $RemovalCommand = "wusa.exe /uninstall /kb:$HotFix /quiet /log /norestart";

                Write-Verbose ("Removing update with command: " + $RemovalCommand);

                Invoke-Expression -Command "$RemovalCommand";

                While (@(Get-Process wusa -ErrorAction SilentlyContinue).Count -ne 0)
                {

                    Start-Sleep -Seconds 1

                    Write-Output "Waiting for update removal to finish ..."

                }  # End While

            }  # End Else

        }  # End ForEach

    }  # End Else

}  # End PROCESS
END
{

    If (Get-PsSession | Out-Null)
    {

        Write-Verbose "[*] Closing connection to remote computers."

        Remove-PsSession -Name *

    }  # End If

}  # End END

}  # End Function Remove-WindowsUpdate
