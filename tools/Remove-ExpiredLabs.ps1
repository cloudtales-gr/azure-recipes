<#
.SYNOPSIS
  Deletes recipe lab resource groups whose "expires" tag is in the past. Only touches groups that
  carry a "recipe" tag, so nothing else in the subscription is ever considered.
.EXAMPLE
  ./tools/Remove-ExpiredLabs.ps1 -WhatIf     # list what would go
  ./tools/Remove-ExpiredLabs.ps1            # delete (runs in the background, one job per group)
#>
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
if (-not (Get-AzContext)) { Connect-AzAccount | Out-Null }
$today = (Get-Date).ToUniversalTime().Date

$expired = Get-AzResourceGroup | Where-Object {
    $_.Tags -and $_.Tags.ContainsKey('recipe') -and $_.Tags.ContainsKey('expires') -and
    ([datetime]::ParseExact($_.Tags['expires'], 'yyyy-MM-dd', $null) -lt $today)
}
if (-not $expired) { Write-Host 'No expired recipe labs.'; return }

foreach ($rg in $expired) {
    if ($PSCmdlet.ShouldProcess($rg.ResourceGroupName, "Delete (recipe $($rg.Tags['recipe']), expired $($rg.Tags['expires']))")) {
        Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob | Out-Null
        Write-Host "Deleting $($rg.ResourceGroupName)"
    }
}
