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

if ([string]::IsNullOrWhiteSpace($csv) -or
    [string]::IsNullOrWhiteSpace($msi)) {
		$scriptName = $MyInvocation.MyCommand.Name
		Write-Host "Usage: .\$scriptName -csv <path-to-csv> -msi <path-to-msi>"
		Write-Host "Example: .\$scriptName -csv 'C:\remotelist.csv' -msi '\\server\share\install.msi'"
		exit 1
	}

$computers = Import-Csv -Path $csv | Select-Object -ExpandProperty ComputerName

$scriptBlock = {
	$installerPath = $using:msi
	Start-Process -FilePath msiexec -ArgumentList “/i '"$installerPath"' /quiet /norestart” -Wait -PassThru

	if ($process.ExitCode -notin @(0, 3010)) {
		Write-Host "Installation failed with exit code $($process.ExitCode)"
		return
	}

	$installPath = "" # will update to not be manual
	if (-not (Test-Path -LiteralPath $installPath)) {
        throw "Installed executable not found: $installPath"
    }
	
	$shortcutDestination = "C:\Users\Public\Desktop\Lockdown Browser.lnk"
	$shell = New-Object -COMObject WScript.shell
	$shortcut = $shell.CreateShortcut($ShortcutDestination)
	$shortcut.TargetPath = $installPath
	$shortcut.Save()
}

foreach ($remoteComputer in $computers) {
	try {
		Invoke-Command -computerName $remoteComputer -ScriptBlock $scriptBlock -Credential (Get-Credential)
	}
	catch {
		Write-Host "Failed to install on $remoteComputer. Error: $($_.Exception.Message)"
	}
}
