<#
.SYNOPSIS
This cmdlet is used to return devices and their update deployment results from an SCCM server


.DESCRIPTION
Return information on deployment statuses for devices in an SCCM group


.PARAMETER SiteCode
The SCCM Site code

.PARAMETER SiteServer
Defines the SCCM site server FQDN or hostname

.PARAMETER DeploymentID
Define the deployment by its assignment ID value

.PARAMETER Status
Specify the results you would like to see returned. Can be Success, InProgress, Error, Unknown, or left blank

.PARAMETER UseSSL
Specifies the CIM session that gets created should use SSL

.PARAMETER Credential
Enter your credentials used to connect to the SCCM server when creating the CIM session


.EXAMPLE
Get-SccmSoftwareUpdateStatus -SiteCode ABC -SiteServer sccm.osbornepro.com -DeploymentId 16779910 -UseSSL -Credential (Get-Credential)
# This example creates an SSL protected CIM session to an SCCM server and returns the devices with an Error Status

.EXAMPLE
$DeploymentResults = (Get-CMSoftwareUpdateDeployment | Where-Object -FilterScript { $_.AssignmentName -like "DEV 2022-06-14"}) | ForEach-Object { $_ | Get-CMSoftwareUpdateDeploymentStatus | Where-Object -FilterScript { $_.CollectionName -like "Patch Tuesday" }
FprEach ($D in $DeploymentResults) { Get-SccmSoftwareUpdateStatus -SiteCode 123 -SiteServer sccm.osbornepro.com -UseSSL -DeploymentId $D.AssignmentId -Status Unknown -Credential (Get-Credential) }
# This example gets deployment IDs from SCCM and uses them to return Unknown device status results from the deployment


.INPUTS
System.Int


.OUTPUTS
PSCustomObject


.NOTES
Author: Robrt H. Osborne
Alias: tobor
Contact: rosborne@osbornepro.com


.LINK
https://github.com/tobor88
https://github.com/osbornepro
https://www.powershellgallery.com/profiles/tobor
https://osbornepro.com
https://writeups.osbornepro.com
https://btpssecpack.osbornepro.com
https://www.powershellgallery.com/profiles/tobor
https://www.hackthebox.eu/profile/52286
https://www.linkedin.com/in/roberthosborne/
https://www.credly.com/users/roberthosborne/badges
#>
Function Get-SccmSoftwareUpdateStatus {
    [CmdletBinding()]
        param(
            [Parameter(
                Position=0,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Get you SCCM servers Site Code from your SCCM servers \Monitoring\Overview\System Status\Site Status location. EXAMPLE: ABC")]  # End Parameter
            [String]$SiteCode,

            [Parameter(
                Position=1,
                Mandatory=$True,
                ValueFromPipeline=$False,
                HelpMessage="Enter the FQDN of your SCCM server. `nEXAMPLE: sscm-server01.domain.com")]  # End Parameter
            [String]$SiteServer,
           
            [Parameter(
                Position=2,
                Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage="Define the deployment ID a.k.a Assignment ID to return results in. `,EXAMPLE: 16779910")]  # End Parameter
            [Alias('ID', 'AssignmentID')]
            [Int32]$DeploymentID,
         
            [Parameter(
                Position=3,
                Mandatory=$False,
                ValueFromPipeline=$False)]  # End Parameter
            [ValidateSet('Success', 'InProgress', 'Error', 'Unknown')]
            [String]$Status,

            [Parameter(
                Mandatory=$False)]  # End Parameter
            [Switch][Bool]$UseSSL,

            [ValidateNotNull()]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $Credential = [System.Management.Automation.PSCredential]::Empty
        )  # End param
 
BEGIN {

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $ConfigManagerPath = (Get-Module -Name ConfigurationManager).Path
    If (Test-Path -Path $ConfigManagerPath) {

        Import-Module -Name $ConfigManagerPath
        Set-Location -Path "$env:SMS_ADMIN_UI_PATH\..\"
        New-PSDrive -Name "$($SiteCode)" -PSProvider "CMSite" -Root "$SiteServer" -Description "SCCM Site" | Out-Null
        Set-Location -Path "$($SiteCode):\"

    } Else {

        Throw "[x] ConfigurationManager PowerShell module not available on this device"

    } # End If Else
 
    Switch ($Status) {

        'Success'    { $StatusType = 1 }
        'InProgress' { $StatusType = 2 }
        'Unknown'    { $StatusType = 4 }
        'Error'      { $StatusType = 5 }

    }  # End Switch

    $Confirm = $False
    If ($UseSSL.IsPresent) {

        $Confirm = $True

    }  # End If

    $FilterDate = Get-Date -Date $FilterDate -Format yyyy-MM-dd

} PROCESS {
       
    Write-Verbose "Creating CIM session to $SiteServer"
    $CIMSession = New-CimSession -ComputerName $SiteServer -Credential $Credential -SessionOption (New-CimSessionOption -UseSsl:$Confirm) -ErrorAction Stop

    If ($Status) {

        $Results = Get-CimInstance -CimSession $CIMSession -ClassName SMS_SUMDeploymentAssetDetails -Namespace root\sms\site_$SiteCode -Filter "AssignmentID = $DeploymentID and StatusType = $StatusType"
        $Return = $Results | ForEach-Object {

            New-Object -TypeName PSCustomObject -Property @{
                DeploymentName=$($_.AssignmentName | Select-Object -Unique);
                AssignmentId=$($_.AssignmentId | Select-Object -Unique);
                DeviceName=$($_.DeviceName);
                CollectionName=$($_.CollectionName);
                StatusTime=$(Get-Date -Date ($_.StatusTime));
                Status=$(If ($_.StatusType -eq 1) {'Success'} ElseIf ($_.StatusType -eq 2) {'InProgress'} ElseIf ($_.StatusType -eq 5) {'Error'}  ElseIf ($_.StatusType -eq 4) {'Unknown'})
            }  # End New-Object Properties

        }  # End ForEach-Object

    } Else {  

        $Results = Get-CimInstance -ComputerName $SiteServer -ClassName SMS_SUMDeploymentAssetDetail -Namespace root\sms\site_$SiteCode -Filter "AssignmentID = $DeploymentID"
        $Return = $Results | ForEach-Object {

            New-Object -TypeName PSCustomObject -Property @{
                DeploymentName=$($_.AssignmentName | Select-Object -Unique);
                AssignmentId=$($_.AssignmentId | Select-Object -Unique);
                DeviceName=$_.DeviceName;
                CollectionName=$_.CollectionName;
                StatusTime=$($_.ConvertToDateTime($_.StatusTime));
                Status=$(If ($_.StatusType -eq 1) {'Success'} ElseIf ($_.StatusType -eq 2) {'InProgress'} ElseIf ($_.StatusType -eq 5) {'Error'}  ElseIf ($_.StatusType -eq 4) {'Unknown'})
            }  # End New-Object Properties

        }  # End ForEach-Object

    }  # End If Else
 
    If ($Null -eq $Results) {

        Throw "[x] Deployment ID $($DeploymentID) was not found to exist"
                 
    }  # End If

} END {

    If ($Return) {

        Write-Verbose "Closing CIM Session Connection"
        Remove-CimSession -CimSession $CIMSession -Confirm:$False

        Return $Return

    } Else {
   
        Write-Output "[i] No results returned"

    } # End If Else

}  # End B P E
 
}  # End Get-SccmSoftwareUpdateStatus
