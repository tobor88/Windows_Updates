Function Invoke-MissingUpdateInstallation {
<#
.SYNOPSIS
This cmdlet is used to install missing Windows and 3rd Party Application updates that are approved in SCCMs Software Center. You can specify a retry count for updates that fail the first time or two. This uses CIM connections to accomplish the task


.DESCRIPTION
This cmdlet can be run locally on a machine to look for and install any approved SCCM server approved updates. This allows you to attempt multiple times to install an update since the first attempt will seomtimes fail


.PARAMETER ComputerName
Define remote computer(s) you wish to install missing updates on

.PARAMETER KBs
Define the specific KBs you wish to install

.PARAMETER Credential
Define the credentials that should be used to remotely connect to devices using CIM sessions with WinRM

.PARAMETER Seconds
Define the number of seconds to wait in between retry attempts

.PARAMETER RetryCount
Define the number of times to retry and installation before giving up on it

.PARAMETER UseSSL
Build CIM Sessions using WinRM over HTTPS


.EXAMPLE
Invoke-MissingUpdateInstallation
# This example attempts to install any missing SCCM approved updates on the local device. It retries failed updates twice with 90 second intervals bewteen attempts

.EXAMPLE
Invoke-MissingUpdateInstallation -ComputerName DC01.domain.com,FS01.domain.com,DHCP.domain.com -UseSSL -Credential $LiveCred -Seconds 45 -RetryCount 1
# This example installs missing updates on the 3 defined remote machines over a WinRM over HTTPS CIM session. If an attempt fails it will wait 45 seconds and retry once more before moving on to the next update check


.INPUTS
System.String ComputerName

.OUTPUTS
PSCustomObject


.NOTES
Author: Robert H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://github.com/tobor88
https://github.com/OsbornePro
https://www.powershellgallery.com/profiles/tobor
https://osbornepro.com
https://writeups.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
#>
    [CmdletBinding(DefaultParameterSetName="Local")]
        param(
            [Parameter(
                ParameterSetName="Remote",
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True)]  # End Parameter
            [Parameter(
                ParameterSetName="Local",
                Position=0,
                Mandatory=$False,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True)]  # End Parameter
            [String[]]$ComputerName = "$env:COMPUTERNAME.$((Get-CimInstance -ClassName Win32_ComputerSystem).Domain)",
 
            [Parameter(
                Mandatory=$False,
                Position=1,
                ValueFromPipeline=$False
            )]  # End Parameter
            [String[]]$KBs,
 
            [ValidateNotNull()]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            [Parameter(ParameterSetName="Remote")]
            $Credential = [System.Management.Automation.PSCredential]::Empty,
 
            [Parameter(
                Mandatory=$False,
                ValueFromPipeline=$False
            )]  # End Parameter
            [Int32]$Seconds = 90,
 
            [Parameter(
                Mandatory=$False,
                ValueFromPipeline=$False
            )]  # End Parameter
            [Int32]$RetryCount = 3,
 
            [Parameter(
                ParameterSetName="Remote",
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$UseSSL
        )  # End param
 
BEGIN {
 
    $Return = @()
    $NotReachable = @()
 
    $ConfirmSSL = $False
    If ($UseSSL.IsPresent) {
 
        $ConfirmSSL = $True
 
    }  # End If
 
} PROCESS {
 
    If ($PSCmdlet.ParameterSetName -eq "Remote") {
 
        Write-Verbose "Builindg CIM Sessions for $ComputerName"
        $CIMSession = New-CimSession -ComputerName $ComputerName -Credential $Credential -SessionOption (New-CIMSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -UseSsl:$ConfirmSSL) -ErrorAction SilentlyContinue
        $CIMConnections = (Get-CimSession).ComputerName
        ForEach ($C in $ComputerName) {
 
            If ($C -notin $CIMConnections) {

                $NotReachable += $C
 
            }  # End If
 
        }  # End ForEach 
 
    }  # End If
 
    Write-Verbose "Getting the missing updates from SCCM clients"
    If ($CIMSession) {
 
        Write-Output "[*] Getting missing updates on $ComputerName"
        [CimInstance[]]$MissingUpdates = Get-CimInstance -CimSession $CIMSession -NameSpace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdate" -Filter "ComplianceState=0" -ErrorAction Stop
 
    } Else {
           
        Write-Output "[*] Getting Missing updates on $env:COMPUTERNAME"
        [CimInstance[]]$MissingUpdates = Get-CimInstance -NameSpace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdate" -Filter "ComplianceState=0"
 
    }  # End If Else
 
 
    If ($Null -eq $MissingUpdates) {
 
        Write-Output "[*] No missing updates found."
 
    } Else {
 
        If ($PSBoundParameters.ContainsKey('KBs')) {
 
            [CimInstance[]]$MissingUpdates = $MissingUpdates | Where-Object -FilterScript { $_.ArticleID -in $KBs.Replace("KB","") }
 
        }  # End If
          
        Write-Output "[*] Installing the below missing updates: `n$($MissingUpdates | Select-Object -ExpandProperty ArticleID -Unique)"
        If ($CIMSession) {

            Invoke-CimMethod -CimSession $CIMSession -Namespace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdatesManager" -MethodName InstallUpdates -Arguments @{ CCMUpdates=[CimInstance[]]$MissingUpdates} -ErrorAction SilentlyContinue | Out-Null
 
        } Else {
 
            Invoke-CimMethod -Namespace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdatesManager" -MethodName InstallUpdates -Arguments @{ CCMUpdates=[CimInstance[]]$MissingUpdates} -ErrorAction SilentlyContinue | Out-Null
 
        }  # End If Else
 
        ForEach ($C in $ComputerName) {
 
            ForEach ($MissingUpdate in $MissingUpdates) {
 
                $State = $MissingUpdate | Select-Object -ExpandProperty EvaluationState
                Switch ($State) {
 
                    '0'  { $JobState = "ciJobStateNone" }
                    '1'  { $JobState = "ciJobStateAvailable" }
                    '2'  { $JobState = "ciJobStateSubmitted" }
                    '3'  { $JobState = "ciJobStateDetecting" }
                    '4'  { $JobState = "ciJobStatePreDownload" }
                    '5'  { $JobState = "ciJobStateDownloading" }
                    '6'  { $JobState = "ciJobStateWaitInstall" }
                    '7'  { $JobState = "ciJobStateInstalling" }
                    '8'  { $JobState = "ciJobStatePendingSoftReboot" }
                    '9'  { $JobState = "ciJobStatePendingHardReboot" }
                    '10' { $JobState = "ciJobStateWaitReboot" }
                    '11' { $JobState = "ciJobStateVerifying" }
                    '12' { $JobState = "ciJobStateInstallComplete" }
                    '13' { $JobState = "ciJobStateError" }
                    '14' { $JobState = "ciJobStateWaitServiceWindow" }
                    '15' { $JobState = "ciJobStateWaitUserLogon" }
                    '16' { $JobState = "ciJobStateWaitUserLogoff" }
                    '17' { $JobState = "ciJobStateWaitJobUserLogon" }
                    '18' { $JobState = "ciJobStateWaitUserReconnect" }
                    '19' { $JobState = "ciJobStatePendingUserLogoff" }
                    '20' { $JobState = "ciJobStatePendingUpdate" }
                    '21' { $JobState = "ciJobStateWaitingRetry" }
                    '22' { $JobState = "ciJobStateWaitPresModeOff" }
                    '23' { $JobState = "ciJobStateWaitForOrchestration" }
                    
                }  # End Switch
 
                $Return += New-Object -TypeName PSCustomObject -Property @{
                    JobState=$JobState;
                    ComputerName=$C;
                    Update=$MissingUpdate.Name;
                    PercentComplete=$MissingUpdate.PercentComplete;
                    ArticleId=$MissingUpdate.ArticleID;
                    ComplianceState=$MissingUpdate.ComplianceState;
                    Deadline=$MissingUpdate.Deadline;
                    UpdateID=$MissingUpdate.UpdateID;
                }  # End New-Object -Property
 
            }  # End ForEach
 
        }  # End ForEach
 
        $NotReachable | ForEach-Object {
        
            $Return += New-Object -TypeName PSCustomObject -Property @{
                JobState="CIM Session could not be created";
                ComputerName=$_;
                Update="CIM Session could not be created";
                PercentComplete="CIM Session could not be created";
                ArticleId="CIM Session could not be created";
                ComplianceState="CIM Session could not be created";
                Deadline="CIM Session could not be created";
                UpdateID="CIM Session could not be created";
            }  # End New-Object -Property
 
        }  # End ForEach
 
        Write-Output "[*] Waiting $Seconds seconds for updates to reach an in progress related status"
        Start-Sleep -Seconds $Seconds
 
        $Result = $True
        $Counter = 0
        While ($Result -eq $True -or $Counter -ne $RetryCount) {
 
            If ($CIMSession) {
 
                $CCMUpdate = Get-CimInstance -CimSession $CIMSession -Namespace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdate" -ErrorAction SilentlyContinue
 
            } Else {
 
                $CCMUpdate = Get-CimInstance -Namespace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdate"
               
            }  # End If Else
 
            [Array]$UniqueStatus = $CCMUpdate | Sort-Object -Property EvalutationState -Unique
            If ([Array]$UniqueStatus.EvaluationState -Contains 13 -or $UniqueStatus -Contains 21) {
        
                $RetryUpdate = $CCMUpdate | Where-Object -FilterScript { $_.EvalutationState -eq 13 -or $_.EvaluationState -eq 21 }
                $RetryCIM = $CIMSession | Where-Object -FilterScript { $_.ComputerName -in $RetryUpdate.ComputerName }
 
                Write-Output "[*] Retrying one last time the installation attempt of the missing updates"
                Invoke-CimMethod -ComputerName $RetryCIM -Namespace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdatesManager" -MethodName InstallUpdates -Arguments @{ CCMUpdates=[CimInstance[]]$MissingUpdates} -ErrorAction SilentlyContinue | Out-Null
           
                Write-Output "[*] Waiting $Seconds Seconds for update to start"
                Start-Sleep -Seconds $Seconds
 
            }  # End If
 
            $Result = If (@($CCMUpdate | Where-Object -FilterScript { $_.EvaluationState -eq 2 -or $_.EvaluationState -eq 3 -or $_.EvaluationState -eq 4 -or $_.EvaluationState -eq 5 -or $_.EvaluationState -eq 6 -or $_.EvaluationState -eq 7 -or $_.EvaluationState -eq 11 }).length -ne 0) {
            
                $True
                
            } Else {
            
                $False
                
            }  # End If Else
 
            Start-Sleep -Seconds 5
            $Counter++
 
        }  # End While
 
        If ($CIMSession) {
 
            Write-Verbose "Closing CIM Sessions"
            Remove-CimSession -CimSession $CIMSession -Confirm:$False -ErrorAction SilentlyContinue
           
        }  # End If
 
    }  # End If Else
 
} END {
 
    Return $Return
 
}  # End B P E
 
}  # End Function Invoke-MissingUpdateInstallation
