<#
.SYNOPSIS
  GOV-02 on Windows 10/11 or Windows Server 2025: PowerShell 7, Azure CLI, Bicep and the Az module.
  Run it in Windows PowerShell or PowerShell 7; winget does the installs, so no admin prompt per tool.
.PARAMETER WithVSCode
  Also installs Visual Studio Code with the Bicep and Azure extensions.
#>
[CmdletBinding()]
param([switch]$WithVSCode)
$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget not found. Install "App Installer" from the Microsoft Store, then run this again.'
}

$packages = 'Microsoft.PowerShell', 'Microsoft.AzureCLI', 'Microsoft.Bicep'
if ($WithVSCode) { $packages += 'Microsoft.VisualStudioCode' }
foreach ($id in $packages) {
    Write-Host "== $id"
    winget install --exact --id $id --source winget --accept-package-agreements --accept-source-agreements --silent
}

# The Az module goes into PowerShell 7 (pwsh), the shell every recipe uses
$pwsh = Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe'
Write-Host '== Az PowerShell module (current user, about 80 modules: 5-10 minutes)'
& $pwsh -NoProfile -Command 'Install-PSResource -Name Az -Repository PSGallery -Scope CurrentUser -TrustRepository'

if ($WithVSCode) {
    $code = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'
    if (-not (Test-Path $code)) { $code = Join-Path $env:ProgramFiles 'Microsoft VS Code\bin\code.cmd' }
    foreach ($ext in 'ms-azuretools.vscode-bicep', 'ms-vscode.azurecli', 'ms-vscode.powershell') { & $code --install-extension $ext }
}

Write-Host "`nDone. Close EVERY terminal window (Windows Terminal keeps the old PATH for new tabs), open a new one and run: pwsh ./verify.ps1"
