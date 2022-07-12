<#
.SYNOPSIS
This cmdlet is used to retrieve a list of updates that are missing from a device


.DESCRIPTION
Get all missing or all SCCM approved updates that are missing from device(s) that are remote or local


.PARAMETER CompuerName
Define the remote device(s) you want to return missing update information on

.PARAMETER UseSSL
Create CIM sessions using WinRM over HTTPS

.PARAMETER CompliantOnly
Used to return only SCCM approved updates that are missing from a device

.PARAMETER Credential
Enter credentials to remotely establish connections with remote machines using WinRM CIM Sessions


.EXAMPLE
Get-MissingDeviceUpdate
# Get all missing updates on the local device

.EXAMPLE 
Get-MissingDeviceUpdate -CompliantOnly
# Get all SCCM approved missing updates

.EXAMPLE
Get-MissingDeviceUpdate -ComputerName "dc01.domain.com","dhcp.domain.com","fs01.domain.com" -UseSSL -CompliantOnly -Credential $LiveCred
# Get all SCCM Approved missing updates on those remote devices using WinRM over HTTPS to build your CIM sessions


.INPUTS
System.String, System.Array


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
Function Get-MissingDeviceUpdate {
    [CmdletBinding(DefaultParameterSetName="Local")]
        param(
            [Parameter(
                ParameterSetName="Remote",
                Position=0,
                Mandatory=$False,
                ValueFromPipelineByPropertyName=$True,
                ValueFromPipeline=$True)]  # End Parameter
            [String[]]$ComputerName = "$env:COMPUTERNAME.$((Get-CimInstance -ClassName Win32_ComputerSystem).Domain)",

            [Parameter(
                ParameterSetName="Remote",
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$UseSSL,

            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$CompliantOnly,

            [ValidateNotNull()]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            [Parameter(
                Mandatory=$True,
                ParameterSetName="Remote")]
            $Credential = [System.Management.Automation.PSCredential]::Empty
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
       
       
        Write-Verbose "Creating CIM Sessions to $ComputerName"
        $CIMSession = New-CimSession -ComputerName $ComputerName -SessionOption (New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -UseSsl:$ConfirmSSL) -Credential $Credential -ErrorAction SilentlyContinue

        $CIMConnections = (Get-CimSession).ComputerName
        ForEach ($C in $ComputerName) {

            If ($C -notin $CIMConnections) {

                $NotReachable += $C 

            }  # End If

        }  # End ForEach

        Write-Verbose "Getting all missing updates from $ComputerName"
        If ($CompliantOnly.IsPresent) {

            $CCMUpdates = Get-CimInstance -CimSession $CIMSession -NameSpace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdate" -Filter "ComplianceState=0" -ErrorAction Continue
       
        } Else {

            $CCMUpdates = Get-CimInstance -CimSession $CIMSession -Namespace 'Root\CCM\SoftwareUpdates\UpdatesStore' -ClassName CCM_UpdateStatus  -ErrorAction Continue | Where-Object -FilterScript { $_.Status -eq "Missing" }
       
        }  # End If Else

        If ($Null -eq $CCMUpdates) {

            Write-Output "[*] All updates are installed on $ComputerName"

        } Else {
       
            If ($CompliantOnly.IsPresent) {
       
                $Return += $CCMUpdates | ForEach-Object {
       
                    New-Object -TypeName PSCustomObject -Property @{
                        ExecutingDevice=$env:COMPUTERNAME;
                        ComputerName=$_.PSComputerName;
                        PercentComplete=$_.PercentComplete;
                        ComplianceState=$_.ComplianceState;
                        Deadline=$_.Deadline;
                        Article=$_.ArticleID;
                        ErrorCode=$_.ErrorCode;
                        Update=$_.Name;
                    }  # End New-Object -Property

                }  # End ForEach-Object

            } Else {

                $Return += $CCMUpdates | ForEach-Object {
       
                    New-Object -TypeName PSCustomObject -Property @{
                        RunningDevice=$env:COMPUTERNAME;
                        ComputerName=$_.PSComputerName;
                        Status=$_.Status;
                        Article=$_.Article;
                        Title=$_.Title;
                    }  # End New-Object -Property

                }  # End ForEach-Object
       
            }  # End If Else

        }  # End If Else

        If ($CIMSession) {

            Write-Verbose "Closing CIM Sessions"
            Remove-CimSession -CimSession $CIMSession -Confirm:$False -ErrorAction SilentlyContinue | Out-Null

        }  # End If

    } Else {

        Write-Verbose "Getting all missing updates from $ComputerName"
        If ($CompliantOnly.IsPresent) {

            $CCMUpdates = Get-CimInstance -NameSpace "Root\CCM\ClientSDK" -ClassName "CCM_SoftwareUpdate" -Filter "ComplianceState=0" -ErrorAction Continue

        } Else {

            $CCMUpdates = Get-CimInstance -Namespace 'Root\CCM\SoftwareUpdates\UpdatesStore' -ClassName CCM_UpdateStatus -ErrorAction Continue | Where-Object -FilterScript { $_.Status -eq "Missing" }
       
        }  # End If Else

        If ($Null -eq $CCMUpdates) {

            Write-Output "[*] All updates are installed on $ComputerName"

        } Else {
       
            If ($CompliantOnly.IsPresent) {
       
                $Return += $CCMUpdates | ForEach-Object {
       
                    New-Object -TypeName PSCustomObject -Property @{
                        ExecutingDevice=$env:COMPUTERNAME;
                        ComputerName=$_.PSComputerName;
                        PercentComplete=$_.PercentComplete;
                        ComplianceState=$_.ComplianceState;
                        Deadline=$_.Deadline;
                        Article=$_.ArticleID;
                        ErrorCode=$_.ErrorCode;
                        Update=$_.Name;
                    }  # End New-Object -Property

                }  # End ForEach-Object

            } Else {

                $Return += $CCMUpdates | ForEach-Object {
       
                    New-Object -TypeName PSCustomObject -Property @{
                        RunningDevice=$env:COMPUTERNAME;
                        ComputerName=$_.PSComputerName;
                        Status=$_.Status;
                        Article=$_.Article;
                        Title=$_.Title;
                    }  # End New-Object -Property

                }  # End ForEach-Object
       
            }  # End If Else

        }  # End If Else

        If ($CIMSession) {

            Write-Verbose "Closing CIM Sessions"
            Remove-CimSession -CimSession $CIMSession -Confirm:$False -ErrorAction SilentlyContinue | Out-Null

        }  # End If

    }  # End If Else

} END {

    If ($NotReachable) {

        $NotReachable | ForEach-Object {
       
            $Return += New-Object -TypeName PSCustomObject -Property @{
                RunningDevice=$env:COMPUTERNAME;
                ComputerName=$_;
                Status="No CIM Session could be created";
                Article="NA";
                Title="NA";
            }  # End New-Object -Property
                   
        }  # End ForEach-Object

    }  # End If

    If ($Null -ne $Return) {

        Return $Return
        
    }  # End If

}  # End B P E

}  # End Function Get-MissingDeviceUpdate
