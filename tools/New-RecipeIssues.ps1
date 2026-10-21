<#
.SYNOPSIS
  Turns catalog.json into the backlog: one GitHub Issue per recipe (labels per category, "wave-1" for the
  first wave) and, with -Project, a GitHub Project board that holds them all. Safe to run again: recipes
  that already have an issue are skipped.
.NOTES
  Needs the GitHub CLI, signed in with the project scope:  gh auth refresh -s project
.EXAMPLE
  ./tools/New-RecipeIssues.ps1 -WhatIf          # show what would be created
  ./tools/New-RecipeIssues.ps1 -Project         # issues + the "Azure Recipes" board
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$Repo = 'cloudtales-gr/azure-recipes',
    [switch]$Project,
    [string]$ProjectTitle = 'Azure Recipes'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$catalog = Get-Content (Join-Path $root 'catalog.json') -Raw | ConvertFrom-Json
$owner = $Repo.Split('/')[0]

gh auth status *> $null
if ($LASTEXITCODE -ne 0) { throw 'Sign in first: gh auth login' }

# Labels: one per category (colour by group), plus "recipe" and "wave-1"; --force updates existing ones
$palette = @('1D76DB', '0E8A16', '5319E7', 'B60205', 'D93F0B', 'FBCA04', '006B75', 'C5DEF5', 'BFD4F2', 'E99695')
$i = 0
foreach ($c in $catalog.categories) {
    if ($PSCmdlet.ShouldProcess($c.code, 'label')) {
        gh label create $c.code -R $Repo --color $palette[$i % $palette.Count] --description $c.name --force | Out-Null
    }
    $i++
}
if ($PSCmdlet.ShouldProcess('recipe, wave-1', 'labels')) {
    gh label create recipe -R $Repo --color 'C4262C' --description 'A CloudTales Azure recipe' --force | Out-Null
    gh label create wave-1 -R $Repo --color '000000' --description 'First 12 weeks' --force | Out-Null
}

# Board
$projectNumber = $null
if ($Project) {
    $projects = gh project list --owner $owner --format json --limit 100 | ConvertFrom-Json
    $projectNumber = ($projects.projects | Where-Object title -eq $ProjectTitle | Select-Object -First 1).number
    if (-not $projectNumber -and $PSCmdlet.ShouldProcess($ProjectTitle, 'create project')) {
        $projectNumber = (gh project create --owner $owner --title $ProjectTitle --format json | ConvertFrom-Json).number
        gh project link $projectNumber --owner $owner --repo $Repo | Out-Null
        Write-Host "Created project #$projectNumber '$ProjectTitle'"
    }
}

# Issues: the first wave in its weekly order, then everything else in catalog order
$existing = @{}
(gh issue list -R $Repo --label recipe --state all --limit 1000 --json title,url | ConvertFrom-Json) | ForEach-Object {
    if ($_.title -match '^\[([A-Z]+-\d+)\]') { $existing[$Matches[1]] = $_.url }
}
$ordered = @($catalog.recipes | Where-Object wave -eq 1 | Sort-Object week) + @($catalog.recipes | Where-Object { -not $_.wave })

$created = 0
foreach ($r in $ordered) {
    if ($existing.ContainsKey($r.id)) { continue }
    $cat = $catalog.categories | Where-Object code -eq $r.category
    $labels = @('recipe', $r.category) + $(if ($r.wave -eq 1) { 'wave-1' } else { @() })
    $body = @"
**$($r.id)** · $($cat.name)$(if ($r.wave -eq 1) { " · wave 1, week $($r.week)" })

- Article (when published): https://cloudtales.gr/recipes/$($cat.slug)/$($r.slug)/
- Code: ``recipes/$($r.slug)/`` (start it with ``./tools/New-Recipe.ps1 -Id $($r.id)``)

- [ ] Lab run in ``rg-recipe-$($r.id.ToLower())``: command output and 2-3 screenshots saved
- [ ] Code in ``recipes/$($r.slug)/`` (deploy, cleanup, README), CI green
- [ ] Article draft on the site (``draft: true``)
- [ ] Real output pasted, time, cost and "Tested" filled in
- [ ] Previewed on localhost, dated, ``draft: false``, pushed
- [ ] Shared on LinkedIn and X
"@
    if ($PSCmdlet.ShouldProcess("[$($r.id)] $($r.title)", 'create issue')) {
        $url = gh issue create -R $Repo --title "[$($r.id)] $($r.title)" --body $body --label ($labels -join ',')
        if ($projectNumber) { gh project item-add $projectNumber --owner $owner --url $url | Out-Null }
        Write-Host "$($r.id)  $url"
        $created++
        Start-Sleep -Milliseconds 1500   # stays under GitHub's content-creation rate limit
    }
}
Write-Host "$created issue(s) created; $($existing.Count) already existed."
