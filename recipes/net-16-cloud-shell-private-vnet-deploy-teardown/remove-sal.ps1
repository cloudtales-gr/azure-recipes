<#
.SYNOPSIS
  NET-16: asks Azure Container Instances to remove its service association link from the container subnet.
  Succeeds only after Cloud Shell has released its container group; until then ACI answers SubnetInUse.
  Safe to run once a day until it succeeds.
#>
#Requires -Version 7.4
param(
    [string]$ResourceGroup = 'rg-cs-vnet-lab',
    [string]$VnetName      = 'vnet-cs-lab',
    [string]$Subnet        = 'cloudshellsubnet'
)
. "$PSScriptRoot/common.ps1"
$sub = az account show --query id -o tsv
$url = "https://management.azure.com/subscriptions/$sub/resourceGroups/$ResourceGroup/providers/Microsoft.Network/virtualNetworks/$VnetName/subnets/$Subnet/providers/Microsoft.ContainerInstance/serviceAssociationLinks/default?api-version=2018-10-01"

$out = az rest --method delete --url $url 2>&1
if ($LASTEXITCODE -eq 0) {
    'released: ACI accepted the delete'
} else {
    'still in use (try again later):'
    $out | ForEach-Object { "  $_" }
}
$s = Get-SalState $ResourceGroup $VnetName $Subnet
'subnet {0}  acisal present: {1}' -f $s.state, [bool]($s.sal -contains 'acisal')
