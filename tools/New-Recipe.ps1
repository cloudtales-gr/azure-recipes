<#
.SYNOPSIS
  Starts a recipe: copies templates/recipe to recipes/<slug>/ with the catalog's id and title filled in,
  and prints the matching "hugo new" command for the site.
.EXAMPLE
  ./tools/New-Recipe.ps1 -Id NET-03
#>
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Id)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$catalog = Get-Content (Join-Path $root 'catalog.json') -Raw | ConvertFrom-Json
$recipe = $catalog.recipes | Where-Object id -eq $Id.ToUpper()
if (-not $recipe) { throw "No recipe '$Id' in catalog.json." }
$category = $catalog.categories | Where-Object code -eq $recipe.category

$target = Join-Path $root "recipes/$($recipe.slug)"
if (Test-Path $target) { throw "$target already exists." }
Copy-Item (Join-Path $root 'templates/recipe') $target -Recurse

$values = @{
    '{{ID}}'            = $recipe.id
    '{{ID_LOWER}}'      = $recipe.id.ToLower()
    '{{TITLE}}'         = $recipe.title
    '{{SLUG}}'          = $recipe.slug
    '{{CATEGORY_SLUG}}' = $category.slug
}
Get-ChildItem $target -File | ForEach-Object {
    $text = [IO.File]::ReadAllText($_.FullName)
    foreach ($k in $values.Keys) { $text = $text.Replace($k, $values[$k]) }
    [IO.File]::WriteAllText($_.FullName, $text, [Text.UTF8Encoding]::new($false))
}

Write-Host "Created recipes/$($recipe.slug)/"
Write-Host "Site: hugo new content recipes/$($category.slug)/$($recipe.slug)/index.md"
