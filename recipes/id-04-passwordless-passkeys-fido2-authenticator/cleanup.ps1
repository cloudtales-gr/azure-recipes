<#
.SYNOPSIS
  ID-04: deletes the pilot user (and purges it) and the pilot group, and turns Temporary Access Pass off again.
  Passkeys (FIDO2) stay on: GOV-01's break-glass accounts sign in with them.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId, [switch]$KeepTapPolicy)
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId

$user = Get-MgUser -Filter "userPrincipalName eq '$LabNickname@$domain'"
if ($user) {
    Remove-MgUser -UserId $user.Id
    Remove-MgDirectoryDeletedItem -DirectoryObjectId $user.Id -ErrorAction SilentlyContinue
    "removed and purged $LabNickname@$domain"
}
$group = Get-MgGroup -Filter "displayName eq '$LabGroup'"
if ($group) {
    Remove-MgGroup -GroupId $group.Id
    Remove-MgDirectoryDeletedItem -DirectoryObjectId $group.Id -ErrorAction SilentlyContinue
    "removed $LabGroup"
}
if (-not $KeepTapPolicy) {
    Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'TemporaryAccessPass' -BodyParameter @{
        '@odata.type' = '#microsoft.graph.temporaryAccessPassAuthenticationMethodConfiguration'
        state         = 'disabled'
    }
    'policy Temporary Access Pass: disabled'
}
'The passkey in Microsoft Authenticator stays on the phone: delete the account there by hand.'
