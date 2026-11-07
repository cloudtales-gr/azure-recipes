<#
.SYNOPSIS
  NET-16: is the Cloud Shell service association link (acisal) still on the container subnet?
  -WatchMinutes 5 repeats the check every 5 minutes until you press Ctrl+C. Changes nothing.
#>
#Requires -Version 7.4
param(
    [string]$ResourceGroup = 'rg-cs-vnet-lab',
    [string]$VnetName      = 'vnet-cs-lab',
    [string]$Subnet        = 'cloudshellsubnet',
    [int]$WatchMinutes     = 0
)
. "$PSScriptRoot/common.ps1"
do {
    $s = Get-SalState $ResourceGroup $VnetName $Subnet
    '{0:HH:mm:ss}  subnet {1}  delegation {2}  acisal present: {3}' -f (Get-Date), $s.state, $s.delegation, [bool]($s.sal -contains 'acisal')
    if ($WatchMinutes -gt 0) { Start-Sleep -Seconds ($WatchMinutes * 60) }
} while ($WatchMinutes -gt 0)
