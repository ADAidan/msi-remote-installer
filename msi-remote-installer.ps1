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

	$installPath = "" # will update to not be manual
		$shortcutDestination = "C:\Users\Public\Desktop\Lockdown Browser.lnk"

		$shell = New-Object -COMObject WScript.shell
		$shortcut = $shell.CreateShortcut($ShortcutDestination)
		$shortcut.TargetPath = $installPath
		$shortcut.Save()
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
}
