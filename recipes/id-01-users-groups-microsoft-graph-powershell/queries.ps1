<#
.SYNOPSIS
  ID-01: the everyday questions, answered with Graph. Read-only.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId)
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId

'--- 1. Who works in Finance? (a simple filter)'
try { Get-MgUser -Filter "department eq 'Finance'" -Property DisplayName, JobTitle, Department | Format-Table DisplayName, JobTitle }
catch { "ERROR: $($_.Exception.Message)" }

'--- 2. The same with an advanced query (ConsistencyLevel eventual + count)'
Get-MgUser -Filter "department eq 'Finance'" -ConsistencyLevel eventual -CountVariable n -Property DisplayName, JobTitle |
    Format-Table DisplayName, JobTitle
"count: $n"

'--- 3. Search by name, without and with ConsistencyLevel'
try { Get-MgUser -Search '"displayName:ann"' | Format-Table DisplayName }
catch { "ERROR: $($_.Exception.Message)" }
Get-MgUser -Search '"displayName:ann"' -ConsistencyLevel eventual | Format-Table DisplayName, UserPrincipalName

'--- 4. Direct vs transitive members of sg-all-staff'
$all = Get-MgGroup -Filter "displayName eq 'sg-all-staff'"
"direct:     " + ((Get-MgGroupMember -GroupId $all.Id -All).AdditionalProperties.displayName -join ', ')
$users = Get-MgGroupTransitiveMember -GroupId $all.Id -All | Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.user' }
"transitive: $($users.Count) users"

'--- 5. Every user and the groups they belong to, to CSV'
$report = foreach ($u in Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, Department, AccountEnabled) {
    $groups = (Get-MgUserTransitiveMemberOf -UserId $u.Id -All).AdditionalProperties.displayName -join '; '
    [pscustomobject]@{ User = $u.UserPrincipalName; Department = $u.Department; Enabled = $u.AccountEnabled; Groups = $groups }
}
$report | Format-Table -AutoSize
$report | Export-Csv "$PSScriptRoot/users-and-groups.csv" -NoTypeInformation -Encoding utf8
"saved users-and-groups.csv"
