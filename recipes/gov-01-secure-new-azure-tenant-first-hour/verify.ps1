<#
.SYNOPSIS
  GOV-01: checks the tenant baseline. One line per check: OK or NO. Changes nothing.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId)
$ErrorActionPreference = 'Continue'
function Show([string]$Name, [string]$Value, [bool]$Ok) {
    '{0} {1,-34} {2}' -f ($(if ($Ok) { 'OK ' } else { 'NO ' })), $Name, $Value
}

Connect-MgGraph -TenantId $TenantId -NoWelcome -Scopes @(
    'User.Read.All', 'Group.Read.All', 'RoleManagement.Read.Directory', 'Policy.Read.All',
    'UserAuthenticationMethod.Read.All', 'Domain.Read.All')

$domain = (Get-MgDomain | Where-Object IsInitial).Id
Show 'Tenant' $domain $true

$sd = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy
Show 'Security defaults' $(if ($sd.IsEnabled) { 'on' } else { 'off' }) $sd.IsEnabled

$globalAdmin = '62e90394-69f5-4237-9190-012177145e10'
$gaIds = @(Get-MgRoleManagementDirectoryRoleAssignment -Filter "roleDefinitionId eq '$globalAdmin'" -All | Select-Object -ExpandProperty PrincipalId)
Show 'Global Administrators' "$($gaIds.Count) (keep it under 5)" ($gaIds.Count -ge 2 -and $gaIds.Count -lt 5)

$group = Get-MgGroup -Filter "displayName eq 'EmergencyAccess'"
$members = if ($group) { @(Get-MgGroupMember -GroupId $group.Id -All) } else { @() }
Show 'EmergencyAccess group' "$($members.Count) members" ($members.Count -ge 2)

foreach ($m in $members) {
    $u = Get-MgUser -UserId $m.Id -Property Id, UserPrincipalName, OnPremisesSyncEnabled, PasswordPolicies, AccountEnabled
    $name = $u.UserPrincipalName.Split('@')[0]
    Show "$name cloud-only, enabled" $u.UserPrincipalName ($u.AccountEnabled -and -not $u.OnPremisesSyncEnabled -and $u.UserPrincipalName -like '*.onmicrosoft.com')
    Show "$name Global Admin (permanent)" '' ($gaIds -contains $u.Id)
    Show "$name password never expires" "$($u.PasswordPolicies)" ("$($u.PasswordPolicies)" -match 'DisablePasswordExpiration')
    $keys = @(Get-MgUserAuthenticationFido2Method -UserId $u.Id -ErrorAction SilentlyContinue)
    Show "$name passkey registered" "$($keys.Count) passkey(s)" ($keys.Count -ge 1)
}

$fido = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'Fido2'
Show 'Passkeys (FIDO2) method' "$($fido.State)" ($fido.State -eq 'enabled')

$auth = Get-MgPolicyAuthorizationPolicy
$perm = $auth.DefaultUserRolePermissions
Show 'Users can register apps' $(if ($perm.AllowedToCreateApps) { 'yes' } else { 'no' }) (-not $perm.AllowedToCreateApps)
Show 'Users can create tenants' $(if ($perm.AllowedToCreateTenants) { 'yes' } else { 'no' }) (-not $perm.AllowedToCreateTenants)
$consent = @($perm.PermissionGrantPoliciesAssigned | Where-Object { $_ -like 'managePermissionGrantsForSelf.*' })
Show 'Users can consent to apps' $(if ($consent) { $consent -join ', ' } else { 'no' }) (-not $consent)
Show 'Who can invite guests' "$($auth.AllowInvitesFrom)" ($auth.AllowInvitesFrom -in 'adminsAndGuestInviters', 'none')
