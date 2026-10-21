<#
.SYNOPSIS
  GOV-02: checks the toolkit and the sign-in. Run in PowerShell 7 (pwsh).
#>
$ErrorActionPreference = 'Continue'
function Show([string]$Name, [string]$Value, [bool]$Ok) {
    '{0} {1,-22} {2}' -f ($(if ($Ok) { 'OK ' } else { 'NO ' })), $Name, $Value
}

Show 'PowerShell'   $PSVersionTable.PSVersion.ToString() ($PSVersionTable.PSVersion -ge [version]'7.4')
$az = (az version -o json 2>$null | ConvertFrom-Json).'azure-cli'
Show 'Azure CLI'    $az ([bool]$az)
$bicepCmd = Get-Command bicep -ErrorAction SilentlyContinue
$bicep = if ($bicepCmd) { (& $bicepCmd.Source --version) -replace 'Bicep CLI version ([0-9.]+).*', '$1' }
Show 'Bicep (PATH)' $(if ($bicep) { $bicep } else { 'not on PATH: close every terminal window and reopen' }) ([bool]$bicep)
$azMod = Get-Module -ListAvailable Az.Accounts | Sort-Object Version -Descending | Select-Object -First 1
Show 'Az.Accounts'  "$($azMod.Version)" ([bool]$azMod)

$ctx = Get-AzContext
if (-not $ctx) { Connect-AzAccount | Out-Null; $ctx = Get-AzContext }
Show 'Signed in as'  $ctx.Account.Id ([bool]$ctx)
Show 'Subscription'  "$($ctx.Subscription.Name)" ([bool]$ctx.Subscription)
$rgs = @(Get-AzResourceGroup -ErrorAction SilentlyContinue)
Show 'Can read RGs'  "$($rgs.Count) resource groups" ($?)
