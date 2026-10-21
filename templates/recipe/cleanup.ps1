# {{ID}}: deletes everything the recipe created (one resource group).
$ErrorActionPreference = 'Stop'
Remove-AzResourceGroup -Name 'rg-recipe-{{ID_LOWER}}' -Force
