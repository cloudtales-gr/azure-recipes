<#
.SYNOPSIS
  {{ID}}: {{TITLE}}. Creates rg-recipe-{{ID_LOWER}} and deploys main.bicep into it.
.PARAMETER Location
  Azure region (default: swedencentral).
.PARAMETER ExpiresInDays
  Written to the resource group's "expires" tag; tools/Remove-ExpiredLabs.ps1 deletes it after that date.
#>
[CmdletBinding()]
param(
    [string]$Location = 'swedencentral',
    [int]$ExpiresInDays = 1
)
$ErrorActionPreference = 'Stop'
$recipe = '{{ID}}'
$rg = 'rg-recipe-{{ID_LOWER}}'
$tags = @{
    recipe  = $recipe
    expires = (Get-Date).ToUniversalTime().AddDays($ExpiresInDays).ToString('yyyy-MM-dd')
    source  = 'https://github.com/cloudtales-gr/azure-recipes'
}

if (-not (Get-AzContext)) { Connect-AzAccount | Out-Null }
Write-Host "Subscription: $((Get-AzContext).Subscription.Name)"

New-AzResourceGroup -Name $rg -Location $Location -Tag $tags -Force | Out-Null
$deployment = New-AzResourceGroupDeployment -ResourceGroupName $rg -Name $recipe.ToLower() `
    -TemplateFile (Join-Path $PSScriptRoot 'main.bicep') -location $Location
$deployment.Outputs.GetEnumerator() | ForEach-Object { '{0,-20} {1}' -f $_.Key, $_.Value.Value }
