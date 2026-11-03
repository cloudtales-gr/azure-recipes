<#
.SYNOPSIS
  ID-01: removes the lab users and groups, and purges them from Deleted users. Leaves the break-glass accounts alone.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId, [string]$CsvPath = "$PSScriptRoot/users.csv")
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId
foreach ($name in 'sg-all-staff', 'sg-finance', 'sg-it', 'sg-sales') {
    $g = Get-MgGroup -Filter "displayName eq '$name'"
    if ($g) { Remove-MgGroup -GroupId $g.Id; Remove-MgDirectoryDeletedItem -DirectoryObjectId $g.Id -ErrorAction SilentlyContinue; "removed $name" }
}
$ids = foreach ($r in Import-Csv $CsvPath) {
    $u = Get-MgUser -Filter "userPrincipalName eq '$($r.Nickname)@$domain'"
    if ($u) { Remove-MgUser -UserId $u.Id; "removed $($r.Nickname)" | Out-Host; $u.Id }
}
# Deleted users stay restorable for 30 days; purge the lab ones now (already-deleted leavers included)
$ids += (Get-MgDirectoryDeletedItemAsUser -All -Property Id, DisplayName, MailNickname | Where-Object { (Import-Csv $CsvPath).Nickname -contains $_.MailNickname }).Id
foreach ($id in $ids | Sort-Object -Unique) {
    Remove-MgDirectoryDeletedItem -DirectoryObjectId $id -ErrorAction SilentlyContinue; "purged $id"
}
