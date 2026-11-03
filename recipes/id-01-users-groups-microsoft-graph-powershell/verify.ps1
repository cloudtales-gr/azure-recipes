<#
.SYNOPSIS
  ID-01: checks users and groups. One line per check: OK or NO. Changes nothing.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId, [string]$CsvPath = "$PSScriptRoot/users.csv")
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot/common.ps1"
function Show([string]$Name, [string]$Value, [bool]$Ok) { '{0} {1,-30} {2}' -f ($(if ($Ok) { 'OK ' } else { 'NO ' })), $Name, $Value }
$domain = Connect-Lab $TenantId
$rows = @(Import-Csv $CsvPath)

$found = @(foreach ($r in $rows) { Get-MgUser -Filter "userPrincipalName eq '$($r.Nickname)@$domain'" -Property Id, Department, UsageLocation })
Show 'Users from the CSV' "$($found.Count) of $($rows.Count)" ($found.Count -eq $rows.Count)
Show 'Department and usage location' '' (-not ($found | Where-Object { -not $_.Department -or $_.UsageLocation -ne 'GR' }))

foreach ($dept in ($rows.Department | Sort-Object -Unique)) {
    $g = Get-MgGroup -Filter "displayName eq 'sg-$($dept.ToLower())'"
    $n = if ($g) { @(Get-MgGroupMember -GroupId $g.Id -All).Count } else { 0 }
    $want = @($rows | Where-Object Department -eq $dept).Count
    Show "sg-$($dept.ToLower())" "$n members" ($n -eq $want)
}
$all = Get-MgGroup -Filter "displayName eq 'sg-all-staff'"
$direct = if ($all) { @(Get-MgGroupMember -GroupId $all.Id -All).Count } else { 0 }
$trans  = if ($all) { @(Get-MgGroupTransitiveMember -GroupId $all.Id -All | Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user' }).Count } else { 0 }
Show 'sg-all-staff direct members' "$direct groups" ($direct -eq @($rows.Department | Sort-Object -Unique).Count)
Show 'sg-all-staff transitive users' "$trans users" ($trans -eq $rows.Count)
$it = Get-MgGroup -Filter "displayName eq 'sg-it'"
$owners = if ($it) { @(Get-MgGroupOwner -GroupId $it.Id -All).AdditionalProperties.userPrincipalName } else { @() }
Show 'sg-it owner' ($owners -join ', ') ([bool]$owners)
