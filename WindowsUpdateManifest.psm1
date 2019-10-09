<#
.Synopsis
	Update-Windows is a cmdlet created to update Windows when updates are available. This cmdlet also creates logs of update attempts
	System Administrators will be alerted if updates fail. This cmdlet creates a CSV file to be uploaded into a SQL database.
	Originally I had this function upload the csv contents into a SQL database. To better coform to PowerShell scripting guidelines I am changing this behavior.

.DESCRIPTION
    This cmdlet updates windows, logs results, and alerts administrators of failures.

.NOTES
    Author: Rob Osborne
    Alias: tobor
	Contact: rosborne@osbornepro.com
	https://roberthosborne.com

.EXAMPLE
   Update-Windows

.EXAMPLE
   Update-Windows -Verbose
#>
Function Update-Windows {
	[CmdletBinding()]
		param () # End param

	$ErrorActionPreference = "SilentlyContinue"
	$Today = Get-Date
	$FormattedDate = Get-Date -Format MM.dd.yyyy
	$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
	$UpdateSearch = New-Object -ComObject Microsoft.Update.Searcher
	$Session = New-Object -ComObject Microsoft.Update.Session

	If ($Error)
	{

		$Error.Clear()

	} # End If

	Write-Verbose "`n`tInitialising and Checking for Applicable Updates. Please wait ..."

	$Result = $UpdateSearch.Search("IsInstalled=0 and Type='Software' and IsHidden=0")

	If ($Result.Updates.Count -EQ 0)
	{

		Write-Verbose "`t$env:COMPUTERNAME is currently up to date."

	} # End if
	Else
	{

		$ReportFile = "C:\Windows\Temp\$env:COMPUTERNAME\$env:COMPUTERNAME`_Report_$FormattedDate.txt"

		If (Test-Path -Path $ReportFile)
		{

			Write-Verbose "Update attempt was run already today. Previous attempt saved as a .txt.old file. New File is located at the following location. `nLOCATION:$ReportFile"
			Rename-Item -Path $ReportFile -NewName ("$ReportFile.old") -Force

		} # End If
		Elseif (!(Test-Path -Path "C:\Windows\Temp\$env:COMPUTERNAME"))
		{

			Write-Verbose "Logging folder previously did not exist and is being created at the below location. `nLOCATION: C:\Windows\Temp\$env:COMPUTERNAME"
			New-Item -Path "C:\Windows\Temp\$env:COMPUTERNAME" -ItemType Directory -Force | Out-Null

		} # End Elseif

		New-Item -Path $ReportFile -Type 'File' -Force -Value "#===================================================================#`n#                            Update Report                           #`n#===================================================================#" | Out-Null

		Add-Content -Path $ReportFile -Value "`n`nComputer Hostname : $env:COMPUTERNAME`r`nCreation Date     : $Today`rReport Directory  : C:\Windows\Temp\$env:COMPUTERNAME`r`n"
		Add-Content -Path $ReportFile -Value "---------------------------------------------------------------------`nAVAILABLE UPDATES`n---------------------------------------------------------------------`r"

		Write-Verbose "`t Preparing List of Applicable Updates For $env:COMPUTERNAME..." 

		For ($Counter = 0; $Counter -lt $Result.Updates.Count; $Counter++)
		{

			$DisplayCount = $Counter + 1
			$Update = $Result.Updates.Item($Counter)
			$UpdateTitle = $Update.Title

			Add-Content -Path $ReportFile -Value "$DisplayCount.) $UpdateTitle"

			$UpdateResultInfo = New-Object -TypeName System.Management.Automation.PSCustomObject -Property @{
				UpdateTitle = $UpdateTitle
				Hostname    = $env:COMPUTERNAME
				Date	    = $FormattedDate } # End Property

			New-Variable -Name UpdateResultInfo$Counter -Value $UpdateResultInfo

		} # End For

		$Counter = 0
		$DisplayCount = 0

		Write-Verbose "`t Initialising Download of Applicable Updates ..."

		Add-Content -Path $ReportFile -Value "`n---------------------------------------------------------------------`nINITIALISING UPDATE DOWNLOADS`n---------------------------------------------------------------------`n"

		$Downloader = $Session.CreateUpdateDownloader()
		$UpdatesList = $Result.Updates

		For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++)
		{

			$UpdateCollection.Add($UpdatesList.Item($Counter)) | Out-Null
			$ShowThis = $UpdatesList.Item($Counter).Title
			$DisplayCount = $Counter + 1

			Add-Content -Path $ReportFile -Value "$DisplayCount.) Downloading Update: $ShowThis `r"

			$Downloader.Updates = $UpdateCollection
			$Track = $Downloader.Download()

			If (($Track.HResult -EQ 0) -AND ($Track.ResultCode -EQ 2))
			{

				Add-Content -Path $ReportFile -Value "`tDownload Status: SUCCESS"

				If ($ShowThis -like ((Get-Variable -Name UpdateResultInfo($Counter)).Title))
				{

					Add-Member -InputObject (Get-Variable -Name UpdateResultInfo($Counter)) -NotePropertyName "DownloadStatus" -NotePropertyValue 'Successfully Downloaded'

				} # End If

			} # End If

			Else
			{

				$FailError = $Error[0]

				Add-Content -Path $ReportFile -Value "`tDownload Status: FAILED With Error `n`t`t $FailError"

				If ($ShowThis -like ((Get-Variable -Name UpdateResultInfo($Counter)).Title))
				{

					Add-Member -InputObject (Get-Variable -Name UpdateResultInfo($Counter)) -NotePropertyName "DownloadStatus" -NotePropertyValue $FailError

				} # End If

				$Error.Clear()

				Add-content -Path $ReportFile -Value "`r"

			} # End Else

		} # End For

		$Counter = 0
		$DisplayCount = 0

		Write-Verbose "`tStarting Installation of Downloaded Updates ..."
		Add-Content -Path $ReportFile -Value "---------------------------------------------------------------------`nUPDATE INSTALLATION`n---------------------------------------------------------------------`n"

		$Installer = New-Object -ComObject Microsoft.Update.Installer

		For ($Counter = 0; $Counter -lt $UpdateCollection.Count; $Counter++)
		{

			$Track = $Null
			$DisplayCount = $Counter + 1
			$WriteThis = $UpdateCollection.Item($Counter).Title

			Add-Content -Path $ReportFile -Value "$DisplayCount.) Installing Update: $WriteThis `r"

			$Installer.Updates = $UpdateCollection

			Try
			{

				$Track = $Installer.Install()

				Add-Content -Path $ReportFile -Value "    - Update Installation Status: SUCCESS`n"

				If ($WriteThis -like ((Get-Variable -Name UpdateResultInfo($Counter)).Title))
				{

					Add-Member -InputObject (Get-Variable -Name UpdateResultInfo($Counter)) -NotePropertyName "InstallStatus" -NotePropertyValue 'Successfully Installed'

				} # End If

			} # End Try
			Catch
			{

				[System.Exception]

				$InstallError = $Error[0]

				Add-Content -Path $ReportFile -Value "    - Update Installation Status: FAILED With Error `n`t`t$InstallError`r"

				If ($WriteThis -like ((Get-Variable -Name UpdateResultInfo($Counter)).Title))
				{

					Add-Member -InputObject (Get-Variable -Name UpdateResultInfo($Counter)) -NotePropertyName "InstallStatus" -NotePropertyValue $InstallError

				} # End If

				$Error.Clear()

			} # End Catch

		} # End For

		Add-Content -Path $ReportFile -Value "#===================================================================#`n#                         END OF REPORT                             #`n#===================================================================#"

		$Obj = New-Object -TypeName PSCustomObject -Properties @{
					UpdateTitle=$UpdateResultInfo.UpdateTitle
					HostName=$UpdateResultInfo.HostName
					Date=$UpdateResultInfo.Date
					DownloadStatus=$UpdateResultInfo.DownloadStatus
					InstallStatus=$UpdateResultInfo.InstallStatus
		} # End Properties

		Write-Output $Obj 

    } # End Else

} # End Funtion Update-Windows

#================================================================================================================================================================================#
<#
.SYNOPSIS
    This used to create the SQL database and schema if it does not exist.

.DESCRIPTION
    Create a SQL database to store windows update information. Columns create are UpdateTitle, Hostname, Date, DownloadStatus, InstallStatus, and DateAdded

.NOTES
    Author: Rob Osborne
    Alias: tobor
	Contact: rosborne@osbornepro.com
	https://roberthosborne.com

.EXAMPLE
    New-WindowsUpdateSqlTable -ServerInstance 'Server01\DbName' -Database 'DbName' -Verbose
#>
Function New-WindowsUpdateSqlTable {
    [CmdletBinding()]
        param(
			[Parameter(Mandatory=$True,
				Position=0,
				ValueFromPipeline=$False,
				ValueFromPipelineByPropertyName=$False,
				HelpMessage="Enter the SQL Server Name and Instance. Example: Server01\DBName ")]
			[string]$ServerInstance,

			[Parameter(Mandatory=$True,
				Position=1,
				ValueFromPipeline=$False,
				ValueFromPipelineByPropertyName=$False,
				HelpMessage="Enter the SQL Server Name and Instance. Example: Server01\DBName ")]
			[string]$Database) # End Parameter

	Write-Verbose "Connectin to SQL server $ServerInstance"

    $Connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    $Connection.ConnectionString = $WindowsUpdateSQLConnection
    $Connection.Open()

    $SQL = @"
        IF NOT EXISTS { SELECT * FROM sysobjects WHERE name='WindowsUpdate' AND xtype='U')
            CREATE TABLE WindowsUpdate (
                UpdateTitle VARCHAR (250),
                HostName VARCHAR (64),
                Date DATETIME2,
                DownloadStatus VARCHAR (250),
                InstallStatus VARCHAR (250)
            )
"@

	Write-Verbose "Issuing SQL Commands for the $Database database."
    $Command = New-Object -TypeName System.Data.SqlClient.SqlCommand
    $Command.Connection = $Connection
    $Command.CommandText = $SQL
    $Command.ExecuteNonQuery() | Out-Null

   $Connection.Close

} # End Function New-WindowsUpdateSqlTable

#====================================================================================================================================================#
<#
.SYNOPSIS
    This is used to export data from the Windows Update module to the SQL database.

.DESCRIPTION
    Takes objects created from Update-Windows and uploads them to SQL database

.NOTES
    Author: Rob Osborne
    Alias: tobor
	Contact: rosborne@osbornepro.com
	https://roberthosborne.com

.EXAMPLE Export-DataToSql -UpdateResults -Verbose
#>
Function Export-DataToSql {
    [CmdletBinding()]
        param(
			[Parameter(Mandatory=$True,
				Position=0,
				ValueFromPipeline=$False,
				ValueFromPipelineByPropertyName=$False,
				HelpMessage="Enter the SQL Server Name and Instance. Example: Server01\DBName ")]
			[string]$ServerInstance,

			[Parameter(Mandatory=$True,
				Position=1,
				ValueFromPipeline=$False,
				ValueFromPipelineByPropertyName=$False,
				HelpMessage="Enter the SQL Server Name and Instance. Example: Server01\DBName ")]
			[string]$Database) # End Parameter

    BEGIN
    {

        New-WindowsUpdateSqlTable -ServerInstance $ServerInstance -Database $Database -Verbose

        $Connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = $WindowsUpdateSqlConnection
        $Connection.Open()

        $Command = New-Object -TypeName System.Data.SqlClient.SqlCommand
        $Command.Connection = $Connection

    } # End BEGIN

    PROCESS
    {

		$Checks = 0

		If ($Checks -eq 0)
		{

			$Checks++
			$Properties = $UpdateResultInfo[0] | Get-Member -MemberType 'Properties' | Select-Object -ExpandProperty 'Name'

			If ( ($Properties -Contains 'UpdateTitle') -and ($Properties -Contains 'HostName') -and ($Properties -Contains 'Date') -and ($Properties -Contains 'DownloadStatus') -and ($Properties -Contains 'InstallStatus') )
			{

				Write-Verbose "Input object passed the property check."

			} # End If
			Else
			{

				Write-Error "Illegal input object. Failed property checks."

				Break

			} # End Else

		} # End If

    } # End PROCESS

    END 
    {

        ForEach ($Object in $UpdateResultInfo)
        {

            If ($Object.UpdateTitle -eq $Null) { $Object = 'NA' } # End If
            If ($Object.HostName -eq $Null) { $Object = $env:COMPUTERNAME } # End If
            If ($Object.Date -eq $Null) { $Object = Get-Date } # End If
            If ($Object.DownloadStatus -eq $Null) { $Object = 'NA' } # End If
            If ($Object.InstallStatus -eq $Null) { $Object = 'NA' } # End If


        } # End ForEach
    
        $Sql = @"
            INSERT INTO Updates (UpdateTitle, Hostname, Date, DownloadStatus, InstallStatus)
            VALUES('$(UpdateResultInfo.UpdateTitle)',
                $(UpdateResultInfo.HostName)',
                $(UpdateResultInfo.Date)',
                $(UpdateResultInfo.DownloadStatus)',
                $(UpdateResultInfo.InstallStatus)')
"@

        $Command.CommandText = $Sql

        Write-Verbose "EXECUTING QUERY `n $Sql"

        $Command.ExecuteNonQuery() | Out-Null

        $Connection.Close()

    } # End END

} # End Function Export-DataToSql

# $WindowsUpdateSqlConnection = "Server=$Instance;Database=$DbName;Trusted_Connection=True;"
# Export-ModuleMember -Function Update-Windows
# Export-ModuleMember -Variable $WindowsUpdateSqlConnection

# Create Module Manifest 
# New-ModuleManifest -Path C:\Users\rob.osborne\Documents\WindowsUpdateModuleManifest.psd1 -Author 'Rob Osborne' -CompanyName 'OsbornePro' -RootModule 'C:\Users\rob.osborne\Documents\WindowsUpdateManifest.psm1' -ModuleVersion '1.0' -Description 'Functions used for the Windows Update Application' -PowerShellVersion '3.0' -FunctionsToExport 'Update-Windows', 'New-WindowsUpdateSqlTable', 'Export-DataToSql' -ProcessorArchitecture None
