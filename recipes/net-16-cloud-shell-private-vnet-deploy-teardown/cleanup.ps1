<#
.SYNOPSIS
  NET-16: deletes the lab resource group, but only once the acisal link is gone.
  Deleting earlier leaves the VNet in a Failed state that refuses every delete and update until Cloud Shell lets go.
#>
#Requires -Version 7.4
param(
    [string]$ResourceGroup = 'rg-cs-vnet-lab',
    [string]$VnetName      = 'vnet-cs-lab',
    [string]$Subnet        = 'cloudshellsubnet'
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

if ((az group exists -n $ResourceGroup) -ne 'true') { "nothing to do: $ResourceGroup does not exist"; return }
$s = Get-SalState $ResourceGroup $VnetName $Subnet
if ($s.sal -contains 'acisal') {
    'acisal is still on the subnet. Not deleting.'
    '1. Cloud Shell > Settings > Reset user settings (every user who connected it to this VNet)'
    '2. pwsh ./remove-sal.ps1   once a day until it says released'
    return
}
"deleting $ResourceGroup ..."
Invoke-Az group delete -n $ResourceGroup --yes
"exists: $(az group exists -n $ResourceGroup)"
