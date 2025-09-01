#Requires -Version 2.0
#Requires -RunAsAdministrator
Function Test-MicrosoftUpdateAccess {
<#
.SYNOPSIS
Test to determine if Install-MicrosoftUpdate witll work


.DESCRIPTION
This cmdlet determines whether Microsoft Updates can be used to install updates or if SCCM restrcits this


.EXAMPLE
PS> Test-MicrosoftUpdateAccess
# This example determinnes whether Install-MicrosoftUpdate cmdlet will work


.NOTES
Last Updated: 9/1/2025
Author: Robert H. Osborne
Contact: rosborne@osbornepro.com


.LINK
https://osbornepro.com
#>
[OutputType([PSCustomObject])]
[CmdletBinding()]
    param()

    Try {

        $InfoPref = $InformationPreference
        $InformationPreference = "Continue"
        $RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
        $UseWsus = $Null
        $WsusUrl = $Null
    
        If (Test-Path -Path $RegPath) {
            $UseWsus = Get-ItemProperty -Path $RegPath -Name UseWUServer -ErrorAction SilentlyContinue | Select-Object -ExpandProperty UseWUServer -ErrorAction SilentlyContinue
            $WsusUrl = Get-ItemProperty -Path $RegPath -Name WUServer -ErrorAction SilentlyContinue | Select-Object -ExpandProperty WUServer -ErrorAction SilentlyContinue
        }  # End If
    
        Try {
    
            $SvcMgr = New-Object -ComObject Microsoft.Update.ServiceManager
            $Services = @()
            ForEach ($Svc in $SvcMgr.Services) {
                $Services += [PSCustomObject]@{
                    Name = $Svc.Name
                    ID   = $Svc.ID
                    Uri  = $Svc.Uri
                }  # End PSCustomObject
            }  # End ForEach
    
        } Catch {
    
            Throw "Unable to create Microsoft.Update.ServiceManager COM object. $($Error[0].Exception.Message)"
    
        }  # End Try Catch
    
        $CanReachMicrosoft = $False
        $Reason = 'NA'
        If ($UseWsus -eq 1 -and $wsusUrl) {
    
            $Reason = "Group Policy forces WSUS/SCCM server '$WsusUrl'."
    
        } Else {
    
            $HasMicrosoftService = $Services | Where-Object -FilterScript { $_.Name -eq 'Microsoft Update' }
            $HasWsusService = $Services | Where-Object -FilterScript { $_.Name -match 'WSUS|SCCM' }
    
            If ($HasMicrosoftService) {
                If ($HasWsusService) {
    
                    $CanReachMicrosoft = $True
                    $Reason = "Both Microsoft Update and a WSUS/SCCM service are registered."
    
                } Else {
    
                    $CanReachMicrosoft = $True
                    $Reason = "Only Microsoft Update service is registered."
                }  # End If Else
    
            } Else {
    
                $Reason = "Microsoft Update service not present in the COM service list."
    
            }  # End If Else
    
        }  # End If Else
    
        If ($CanReachMicrosoft) {
            Write-Information -MessageData "SUCCESS - This computer CAN download updates directly from the Microsoft Update catalog."
            Write-Information -MessageData "Reason: $Reason"
        } Else {
            Write-Information -MessageData "ISSUES - Updates are restricted to the WSUS/SCCM server ONLY."
            Write-Information -MessageData "Reason: $Reason"
        }  # End If Else
    
        [PSCustomObject]@{
            CanDownloadFromMicrosoft = $CanReachMicrosoft
            Reason                  = $Reason
            WsusEnforced            = ($UseWsus -eq 1)
            WsusUrl                 = $WsusUrl
            RegisteredServices      = $Services
        }  # End PSCustomObject
    
    } Finally {
        $InformationPreference = $InfoPref
    }  # End Try Finally
    
}  # End Function Test-MicrosoftUpdateAccess
