# NET-01: deletes everything the recipe created (one resource group) and the throwaway SSH key.
$ErrorActionPreference = 'Stop'
Remove-AzResourceGroup -Name 'rg-recipe-net-01' -Force
Remove-Item (Join-Path ([IO.Path]::GetTempPath()) 'net01-lab*') -ErrorAction SilentlyContinue
