<#
.SYNOPSIS
  NET-16 step 1: providers, resource group, an empty VNet, and the values the two quickstart templates ask for.
#>
#Requires -Version 7.4
param(
    [string]$ResourceGroup = 'rg-cs-vnet-lab',
    [string]$Location      = 'northeurope',
    [string]$VnetName      = 'vnet-cs-lab'
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"

foreach ($p in 'Microsoft.CloudShell', 'Microsoft.ContainerInstance', 'Microsoft.Relay') {
    if ((az provider show -n $p --query registrationState -o tsv) -ne 'Registered') {
        "registering $p"
        Invoke-Az provider register -n $p --wait
    } else { "registered  $p" }
}

Invoke-Az group create -n $ResourceGroup -l $Location -o none
Invoke-Az network vnet create -g $ResourceGroup -n $VnetName -l $Location --address-prefixes 10.0.0.0/16 -o none
"vnet        $VnetName (10.0.0.0/16, no subnets: the template creates them)"

$aci = az ad sp list --display-name 'Azure Container Instance' --query '[0].id' -o tsv
if (-not $aci) { throw "Service principal 'Azure Container Instance' not found. Is Microsoft.ContainerInstance registered?" }

''
'For the "Azure Cloud Shell - VNet" template:'
[ordered]@{
    'Resource group'                 = $ResourceGroup
    'Region'                         = $Location
    'Existing VNET Name'             = $VnetName
    'Relay Namespace Name'           = '<globally unique, e.g. arn-cs-lab-<initials>>'
    'Nsg Name'                       = 'nsg-cs-lab'
    'Azure Container Instance OID'   = $aci
    'Container Subnet Address Prefix'= '10.0.1.0/24'
    'Relay Subnet Address Prefix'    = '10.0.2.0/24'
    'Storage Subnet Address Prefix'  = '10.0.3.0/24'
} | Format-Table -HideTableHeaders
