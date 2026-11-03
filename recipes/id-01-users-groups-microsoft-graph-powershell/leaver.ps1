<#
.SYNOPSIS
  ID-01: someone leaves. Disable, sign out everywhere, remove from groups, then delete (30 days to restore).
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId, [Parameter(Mandatory)][string]$Nickname, [switch]$Delete)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId
$user = Get-MgUser -UserId "$Nickname@$domain"

Update-MgUser -UserId $user.Id -AccountEnabled:$false
'1. sign-in disabled'
Revoke-MgUserSignInSession -UserId $user.Id | Out-Null
'2. refresh tokens revoked: every app must sign in again, and cannot'
foreach ($g in Get-MgUserMemberOf -UserId $user.Id -All | Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group' }) {
    Remove-MgGroupMemberByRef -GroupId $g.Id -DirectoryObjectId $user.Id
    "3. removed from $($g.AdditionalProperties.displayName)"
}
if ($Delete) {
    Remove-MgUser -UserId $user.Id
    '4. deleted: in Deleted users for 30 days, then gone'
    Get-MgDirectoryDeletedItemAsUser -All -Property Id, DisplayName, UserPrincipalName, DeletedDateTime | Where-Object Id -eq $user.Id | Format-Table DisplayName, UserPrincipalName, DeletedDateTime
    "   restore with: Restore-MgDirectoryDeletedItem -DirectoryObjectId $($user.Id)"
}
