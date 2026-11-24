<#
.SYNOPSIS
  NET-01: VNet, subnets and NSGs: the first network. Creates rg-recipe-net-01 and deploys main.bicep into it:
  a VNet with web, app and data subnets, one NSG per subnet, and one small Ubuntu VM per subnet to test the rules.
.PARAMETER Location
  Azure region (default: swedencentral).
.PARAMETER VmSize
  Size of the three test VMs (default: Standard_D2als_v6). Needs 6 vCPUs of quota in that family.
.PARAMETER ExpiresInDays
  Written to the resource group's "expires" tag; tools/Remove-ExpiredLabs.ps1 deletes it after that date.
#>
[CmdletBinding()]
param(
    [string]$Location = 'swedencentral',
    [int]$ExpiresInDays = 1,
    [string]$VmSize = 'Standard_D2als_v6'
)
$ErrorActionPreference = 'Stop'
$recipe = 'NET-01'
$rg = 'rg-recipe-net-01'
$tags = @{
    recipe  = $recipe
    expires = (Get-Date).ToUniversalTime().AddDays($ExpiresInDays).ToString('yyyy-MM-dd')
    source  = 'https://github.com/cloudtales-gr/azure-recipes'
}

if (-not (Get-AzContext)) { Connect-AzAccount | Out-Null }
Write-Host "Subscription: $((Get-AzContext).Subscription.Name)"

# A new subscription may not have these providers registered yet. Until Microsoft.Compute is registered,
# every VM family shows a quota of 0 and the deployment fails with QuotaExceeded.
foreach ($ns in 'Microsoft.Network', 'Microsoft.Compute') {
    if ((Get-AzResourceProvider -ProviderNamespace $ns)[0].RegistrationState -ne 'Registered') {
        Write-Host "Registering $ns ..."
        Register-AzResourceProvider -ProviderNamespace $ns | Out-Null
        while ((Get-AzResourceProvider -ProviderNamespace $ns)[0].RegistrationState -ne 'Registered') { Start-Sleep 10 }
    }
}

# A throwaway SSH key: Azure requires one for a Linux VM without a password. Nobody signs in with it;
# the tests use Run Command, which needs no inbound port at all.
$key = Join-Path ([IO.Path]::GetTempPath()) 'net01-lab'
if (-not (Test-Path "$key.pub")) { ssh-keygen -t rsa -b 4096 -f $key -N '' -q -C 'net01-lab' }
$publicKey = (Get-Content "$key.pub" -Raw).Trim()

New-AzResourceGroup -Name $rg -Location $Location -Tag $tags -Force | Out-Null
$deployment = New-AzResourceGroupDeployment -ResourceGroupName $rg -Name $recipe.ToLower() `
    -TemplateFile (Join-Path $PSScriptRoot 'main.bicep') -location $Location -sshPublicKey $publicKey -vmSize $VmSize
$deployment.Outputs.GetEnumerator() | ForEach-Object { '{0,-6} {1}' -f $_.Key, $_.Value.Value }
