<#
.SYNOPSIS
  GOV-01: the first hour of a new Microsoft Entra / Azure tenant, in one idempotent script.
  - security defaults on (MFA for everyone, legacy authentication blocked)
  - two cloud-only emergency access ("break-glass") accounts, permanent Global Administrator,
    in an EmergencyAccess group (for Conditional Access exclusions later)
  - passkeys (FIDO2) enabled as an authentication method, for the break-glass accounts
  - users cannot register apps, create tenants or consent to apps; only admins invite guests
.NOTES
  Run in PowerShell 7 (Windows or Linux) as a Global Administrator of the NEW tenant.
  Safe to run again: it only changes what is not already in place.
#>
#Requires -Version 7.4
param(
    [Parameter(Mandatory)]
    [string]$TenantId,               # the new tenant: its ID or <name>.onmicrosoft.com
    [ValidateRange(2, 4)]
    [int]$BreakGlassCount = 2
)
$ErrorActionPreference = 'Stop'

$modules = 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Users', 'Microsoft.Graph.Groups',
           'Microsoft.Graph.Identity.SignIns', 'Microsoft.Graph.Identity.Governance',
           'Microsoft.Graph.Identity.DirectoryManagement'
foreach ($m in $modules) {
    if (-not (Get-Module -ListAvailable $m)) { Install-Module $m -Scope CurrentUser -Force -AllowClobber }
}

Connect-MgGraph -TenantId $TenantId -NoWelcome -Scopes @(
    'User.ReadWrite.All', 'Group.ReadWrite.All', 'RoleManagement.ReadWrite.Directory',
    'Policy.ReadWrite.Authorization', 'Policy.ReadWrite.AuthenticationMethod',
    'Policy.ReadWrite.SecurityDefaults', 'Policy.Read.All', 'Domain.Read.All')

$domain = (Get-MgDomain | Where-Object IsInitial).Id
"Tenant: $domain"

function Get-RandomPassword([int]$Length = 40) {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%*-_=+'
    -join (1..$Length | ForEach-Object { $chars[[Security.Cryptography.RandomNumberGenerator]::GetInt32($chars.Length)] })
}

# 1. Security defaults
$sd = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy
if (-not $sd.IsEnabled) {
    Update-MgPolicyIdentitySecurityDefaultEnforcementPolicy -IsEnabled:$true
    'Security defaults: turned ON'
} else { 'Security defaults: already on' }

# 2. Break-glass accounts, their group and permanent Global Administrator
$globalAdmin = '62e90394-69f5-4237-9190-012177145e10'   # built-in role template ID, same in every tenant
$group = Get-MgGroup -Filter "displayName eq 'EmergencyAccess'"
if (-not $group) {
    $group = New-MgGroup -DisplayName 'EmergencyAccess' -MailEnabled:$false -MailNickname 'EmergencyAccess' -SecurityEnabled `
        -Description 'Break-glass accounts. Exclude this group from every Conditional Access policy that blocks or restricts sign-in.'
    'Group EmergencyAccess: created'
}

$newSecrets = @()
foreach ($i in 1..$BreakGlassCount) {
    $nick = 'breakglass{0:d2}' -f $i
    $upn  = "$nick@$domain"
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    if (-not $user) {
        $pw = Get-RandomPassword
        $user = New-MgUser -DisplayName "Emergency access $i" -UserPrincipalName $upn -MailNickname $nick `
            -AccountEnabled -UsageLocation 'GR' -PasswordPolicies 'DisablePasswordExpiration' `
            -PasswordProfile @{ Password = $pw; ForceChangePasswordNextSignIn = $false }
        $newSecrets += [pscustomobject]@{ Account = $upn; Password = $pw }
        "${upn}: created"
    }
    if (-not (Get-MgGroupMember -GroupId $group.Id -All | Where-Object Id -eq $user.Id)) {
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
    }
    $assigned = Get-MgRoleManagementDirectoryRoleAssignment -Filter "principalId eq '$($user.Id)' and roleDefinitionId eq '$globalAdmin'"
    if (-not $assigned) {
        New-MgRoleManagementDirectoryRoleAssignment -PrincipalId $user.Id -RoleDefinitionId $globalAdmin -DirectoryScopeId '/' | Out-Null
        "${upn}: Global Administrator (permanent)"
    }
}

# 3. Passkeys (FIDO2) as an authentication method, for everyone (break-glass accounts register one next)
$fido = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'Fido2'
if ($fido.State -ne 'enabled') {
    Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'Fido2' -BodyParameter @{
        '@odata.type' = '#microsoft.graph.fido2AuthenticationMethodConfiguration'
        state         = 'enabled'
    }
    'Passkeys (FIDO2): enabled'
} else { 'Passkeys (FIDO2): already enabled' }

# 4. What ordinary users may do
Update-MgPolicyAuthorizationPolicy -BodyParameter @{
    allowInvitesFrom           = 'adminsAndGuestInviters'
    defaultUserRolePermissions = @{
        allowedToCreateApps             = $false
        allowedToCreateTenants          = $false
        permissionGrantPoliciesAssigned = @()      # empty = users cannot consent to apps; admins decide
    }
}
'User settings: no app registrations, no new tenants, no user consent, guests invited by admins only'

if ($newSecrets) {
    ''
    'Store these now in a password manager or a sealed envelope in a safe. They are shown only once:'
    $newSecrets | Format-Table -AutoSize
    'Next: register a passkey for each account (see README), then run ./verify.ps1'
}
