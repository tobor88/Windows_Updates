Write-Output "[*] Stopping services that use the directories we need renamed"
Stop-Service -Name cryptsvc,wuauserv,bits,msiserver -Force -Confirm:$False

Write-Output "[*] Renaming C:\Windows\SoftwareDistribution to SoftwareDistribution.bak"
If (Test-Path -Path "C:\Windows\SoftwareDistribution.bak") {

    Remove-Item -Path "C:\Windows\SoftwareDistribution.bak" -Force

}  # End If
Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "C:\Windows\SoftwareDistribution.bak"

Write-Output "[*] Renaming C:\Windows\System32\catroot2 to catroot2.bak"
If (Test-Path -Path "C:\Windows\System32\catroot2.bak") {

    Remove-Item -Path "C:\Windows\System32\catroot2.bak" -Force

}  # End If
Rename-Item -Path "C:\Windows\System32\catroot2" -NewName "C:\Windows\System32\catroot2.bak"

Write-Output "[*] A restart is required to load the changes. Update Windows After the restart"
Restart-Computer -Confirm
