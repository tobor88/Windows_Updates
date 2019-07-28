<#
.Synopsis
	Update-Windows is a cmdlet created to update Windows when updates are available. This cmdlet also creates logs of update attempts
	System Administrators will be alerted if updates fail. 

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

Function Update-Windows
{
	[CmdletBinding()]
		param ()
	
	$ErrorActionPreference = "SilentlyContinue"
		
	If ($Error)
	{

		$Error.Clear()
			
	} # End If
        
    $SmtpServer = "smtp2go.com"
    $EmailAddress = "AdminEmail@osbornepro.com"
	$Today = Get-Date
	$FormattedDate = Get-Date -Format MM.dd.yyyy
	$ComputerName = $env:COMPUTERNAME

	$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
	$UpdateSearch = New-Object -ComObject Microsoft.Update.Searcher
	$Session = New-Object -ComObject Microsoft.Update.Session
		
	Write-Host "`n`t Initialising and Checking for Applicable Updates. Please wait ..." -ForeGroundColor "Yellow"
		
	$Result = $UpdateSearch.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
		
	If ($Result.Updates.Count -EQ 0)
	{
			
		Write-Host "`t$ComputerName is currently up to date." -ForegroundColor "Green"
		
	} # End if
		
	Else
	{
			
		$ReportFile = "C:\Windows\Temp\$ComputerName\$ComputerName`_Report_$FormattedDate.txt"
		
		If (Test-Path $ReportFile)
		{
				
			Rename-Item -Path $ReportFile -NewName ("$ReportFile.old") -Force

			Write-Verbose "Update attempt was run already today. Previous attempt saved as a .txt.old file. New File is located at the following location. `nLOCATION:$ReportFile"
				
		} # End If
			
		Elseif (!(Test-Path "C:\Windows\Temp\$ComputerName"))
		{
				
			New-Item -Path "C:\Windows\Temp\$ComputerName" -ItemType Directory -Force | Out-Null

			Write-Verbose "Logging folder previously did not exist and was created at the below location. `nLOCATION: C:\Windows\Temp\$ComputerName"
				
		} # End Elseif
			
		New-Item $ReportFile -Type File -Force -Value "#===================================================================#`n#                            Update Report                          #`n#===================================================================#" | Out-Null
			
		Add-Content $ReportFile "`n`nComputer Hostname : $ComputerName`r`n"
		Add-Content $ReportFile "Creation Date     : $Today`r"
		Add-Content $ReportFile "Report Directory  : C:\Windows\Temp\$ComputerName`r`n"		
		Add-Content $ReportFile "---------------------------------------------------------------------`nAVAILABLE UPDATES`n---------------------------------------------------------------------`r"
		
		Write-Host "`t Preparing List of Applicable Updates For $ComputerName..." -ForeGroundColor "Yellow"

		For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++)
		{
			$DisplayCount = $Counter + 1
				
			$Update = $Result.Updates.Item($Counter)
				
			$UpdateTitle = $Update.Title
				
			Add-Content $ReportFile "$DisplayCount.) $UpdateTitle"
				
		} # End For
			
		$Counter = 0			
		$DisplayCount = 0
			
		Write-Host "`t Initialising Download of Applicable Updates ..." -ForegroundColor "Yellow"
		
		Add-Content $ReportFile "`n---------------------------------------------------------------------`nINITIALISING UPDATE DOWNLOADS`n---------------------------------------------------------------------`n"
			
		$Downloader = $Session.CreateUpdateDownloader()
			
		$UpdatesList = $Result.Updates
			
		For ($Counter = 0; $Counter -LT $Result.Updates.Count; $Counter++)
		{
				
			$UpdateCollection.Add($UpdatesList.Item($Counter)) | Out-Null
				
			$ShowThis = $UpdatesList.Item($Counter).Title
				
			$DisplayCount = $Counter + 1
				
			Add-Content $ReportFile "$DisplayCount.) Downloading Update: $ShowThis `r"
				
			$Downloader.Updates = $UpdateCollection
				
			$Track = $Downloader.Download()
				
			If (($Track.HResunoteplt -EQ 0) -AND ($Track.ResultCode -EQ 2))
			{
					
				Add-Content $ReportFile "`tDownload Status: SUCCESS"
					
			} # End If
				
			Else
			{
				$FailError = $Error[0]

				Add-Content $ReportFile "`tDownload Status: FAILED With Error `n`t`t $FailError"
				
				$Error.Clear()
					
				Add-content $ReportFile "`r"
				
			} # End Else	
				
		} # End For
			
		$Counter = 0
		$DisplayCount = 0
			
		Write-Host "`tStarting Installation of Downloaded Updates ..." -ForegroundColor "Yellow"
			
		Add-Content $ReportFile "---------------------------------------------------------------------`nUPDATE INSTALLATION`n---------------------------------------------------------------------`n"
			
		$Installer = New-Object -ComObject Microsoft.Update.Installer
		
		For ($Counter = 0; $Counter -LT $UpdateCollection.Count; $Counter++)
		{
				
			$Track = $Null
				
			$DisplayCount = $Counter + 1
				
			$WriteThis = $UpdateCollection.Item($Counter).Title
				
			Add-Content $ReportFile "$DisplayCount.) Installing Update: $WriteThis `r"
				
			$Installer.Updates = $UpdateCollection
				
			Try
			{
					
				$Track = $Installer.Install()
					
				Add-Content $ReportFile "    - Update Installation Status: SUCCESS`n"
					
			} # End Try
			Catch
			{
					
				[System.Exception]
				
				$InstallError = $Error[0]

				Add-Content $ReportFile "    - Update Installation Status: FAILED With Error `n`t`t$InstallError"
				
				$Error.Clear()
				
				Add-content $ReportFile "`r"
					
			} # End Catch	
				
		} # End For
			
		Add-content $ReportFile "#===================================================================#`n#                         END OF REPORT                             #`n#===================================================================#"
			
		If ($InstallError)
		{

			Send-MailMessage -To $EmailAddress -From $EmailAddress -SmtpServer $SmtpServer -Subject "Windows Update Installation Failure: $ComputerName" -Body $InstallError -Priority High
		
			Import-Module -Function "Repair-UpdateFailure"

			Repair-UpdateFailure

		} # End If

	} # End Else

} # End Function