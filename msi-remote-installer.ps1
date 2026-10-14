<#
.SYNOPSIS
Installs an MSI file on remote computers listed in a CSV file.

.PARAMETER csv
Path to the CSV file. The CSV must contain a ComputerName column.

.PARAMETER msi
Path to the MSI installer, accessible to the remote computers.

.EXAMPLE
.\msi-remote-installer.ps1 -csv "C:\remotelist.csv" -msi "\\server\share\install.msi"
#>
param(
    [string]$csv,
    [string]$msi
)

$computers = Import-Csv -Path $csv | Select-Object -ExpandProperty ComputerName

$scriptBlock = {
	Start-Process -FilePath msiexec -ArgumentList “/i $using:msi /quiet” -Wait
}

foreach ($remoteComputer in $computers) {
	if ([string]::IsNullOrWhiteSpace($csv) -or
    [string]::IsNullOrWhiteSpace($msi)) {
		$scriptName = $MyInvocation.MyCommand.Name
		Write-Host "Usage: .\$scriptName -csv <path-to-csv> -msi <path-to-msi>"
		Write-Host "Example: .\$scriptName -csv 'C:\remotelist.csv' -msi '\\server\share\install.msi'"
		exit 1
	}
	try {
		Invoke-Command -computerName $remoteComputer -ScriptBlock $scriptBlock -Credential (Get-Credential)
	}
	catch {
		Write-Host "Failed to install on $remoteComputer. Error: $($_.Exception.Message)"
	}

	try {
		$installPath = ""
		$shortcutDestination = "C:\Users\Student\Desktop\Lockdown Browser.lnk"

		$WshShell = New-Object -COMObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut($ShortcutDestination)
		$Shortcut.TargetPath = $installPath
		$Shortcut.Save()
	}
	catch {
		Write-Host "Failed to create shortcut on $remoteComputer. Error: $($_.Exception.Message)"
	}

}

# if script does not run
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
