# MSI Remote Installer

`msi-remote-installer.ps1` is a powershell script that reads host names from a CSV file and runs an MSI
installation command on each host using PowerShell remoting.

## Requirements

- PowerShell remoting enabled and reachable on each target host.
- Credentials with permission to install software on the target computers.
- A CSV file with a `ComputerName` column.
- An MSI path that the script can access

## Usage

If PowerShell's execution policy prevents running the script, allow scripts for the current PowerShell process:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This setting applies only to the current PowerShell window.

Command Syntax:

```powershell
.\msi-remote-installer.ps1 -csv <csv-path> -msi <msi-path>
```

example csv:

```csv
ComputerName
PC-001
PC-002
```

The script prompts for credentials when it connects to each computer.

Replace `$installPath` with path of installed program
