<#
.SYNOPSIS
  ID-04: the passkey works, so take the Temporary Access Pass away now instead of waiting for it to expire.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId
$user = Get-MgUser -Filter "userPrincipalName eq '$LabNickname@$domain'"
if (-not $user) { "No pilot user."; return }
if (-not @(Get-MgUserAuthenticationFido2Method -UserId $user.Id -All)) {
    'The user has no passkey yet. Keeping the pass, or they cannot sign in at all.'; return
}
$taps = @(Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $user.Id)
foreach ($t in $taps) {
    Remove-MgUserAuthenticationTemporaryAccessPassMethod -UserId $user.Id -TemporaryAccessPassAuthenticationMethodId $t.Id
    "removed Temporary Access Pass $($t.Id)"
}
if (-not $taps) { 'no Temporary Access Pass to remove' }
