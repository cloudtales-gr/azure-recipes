<#
.SYNOPSIS
  ID-04: a pilot group, a pilot user nobody knows the password of, Temporary Access Pass for that group,
  passkeys (FIDO2) on, and a one-hour Temporary Access Pass to register the first passkey with.
.NOTES
  PowerShell 7, as a Global Administrator (or Authentication Policy Administrator + User Administrator) of a test tenant.
  Safe to run again: it creates only what is missing, and issues a new pass each time.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId
"Tenant: $domain"

# 1. Pilot group: the policies target this group, not every user
$group = Get-MgGroup -Filter "displayName eq '$LabGroup'"
if (-not $group) {
    $group = New-MgGroup -DisplayName $LabGroup -MailNickname $LabGroup -MailEnabled:$false -SecurityEnabled `
        -Description 'ID-04: users moving to passkeys'
    "group  $LabGroup"
}

# 2. Pilot user, with a long random password that is never shown to anyone
$upn  = "$LabNickname@$domain"
$user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
if (-not $user) {
    $user = New-MgUser -GivenName 'Dimitra' -Surname 'Kalogirou' -DisplayName 'Dimitra Kalogirou' `
        -UserPrincipalName $upn -MailNickname $LabNickname -Department 'Finance' -JobTitle 'Controller' `
        -UsageLocation 'GR' -AccountEnabled `
        -PasswordProfile @{ Password = (Get-RandomPassword); ForceChangePasswordNextSignIn = $false }
    "user   $upn (password: random, 64 characters, not stored anywhere)"
}
if (-not (Get-MgGroupMember -GroupId $group.Id -All | Where-Object Id -eq $user.Id)) {
    New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id
    "member $upn of $LabGroup"
}

# 3. Passkeys (FIDO2): on for everyone (GOV-01 already did this; no AAGUID restrictions)
$fido = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'Fido2'
if ($fido.State -ne 'enabled') {
    Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'Fido2' -BodyParameter @{
        '@odata.type' = '#microsoft.graph.fido2AuthenticationMethodConfiguration'
        state         = 'enabled'
    }
    'policy Passkeys (FIDO2): enabled'
} else { 'policy Passkeys (FIDO2): already enabled' }

# 4. Temporary Access Pass: on for the pilot group only
Update-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'TemporaryAccessPass' -BodyParameter @{
    '@odata.type'            = '#microsoft.graph.temporaryAccessPassAuthenticationMethodConfiguration'
    state                    = 'enabled'
    defaultLifetimeInMinutes = 60
    minimumLifetimeInMinutes = 60
    maximumLifetimeInMinutes = 480
    defaultLength            = 8
    isUsableOnce             = $false
    includeTargets           = @(@{ targetType = 'group'; id = $group.Id; isRegistrationRequired = $false })
}
"policy Temporary Access Pass: enabled for $LabGroup"

# 5. A one-hour pass. The policy needs a moment to see the new member, so retry for up to a minute.
$tap = $null
foreach ($try in 1..6) {
    try {
        $tap = New-MgUserAuthenticationTemporaryAccessPassMethod -UserId $user.Id -BodyParameter @{ lifetimeInMinutes = 60; isUsableOnce = $false }
        break
    } catch {
        if ($try -eq 6) { throw }
        Start-Sleep -Seconds 10
    }
}
''
'Temporary Access Pass (shown once; valid 60 minutes, more than one sign-in):'
$start = ($tap.StartDateTime ?? $tap.CreatedDateTime ?? (Get-Date).ToUniversalTime()).ToLocalTime()
[pscustomobject]@{
    User      = $upn
    Pass      = $tap.TemporaryAccessPass
    ValidFrom = $start.ToString('HH:mm')
    ValidTo   = $start.AddMinutes($tap.LifetimeInMinutes).ToString('HH:mm')
} | Format-List
'Next: a private browser window, https://aka.ms/mysecurityinfo, sign in as the user with the pass,'
'      Add sign-in method > Passkey in Microsoft Authenticator (or Security key).'
