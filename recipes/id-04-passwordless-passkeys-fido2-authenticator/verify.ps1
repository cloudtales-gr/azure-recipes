<#
.SYNOPSIS
  ID-04: one line per check, OK or NO. Run after the passkey is registered and remove-tap.ps1 has run. Changes nothing.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId)
$ErrorActionPreference = 'Continue'
. "$PSScriptRoot/common.ps1"
function Show([string]$Name, [string]$Value, [bool]$Ok) { '{0} {1,-34} {2}' -f ($(if ($Ok) { 'OK ' } else { 'NO ' })), $Name, $Value }
$domain = Connect-Lab $TenantId

$fido = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'Fido2'
Show 'Passkeys (FIDO2) policy' $fido.State ($fido.State -eq 'enabled')

$group = Get-MgGroup -Filter "displayName eq '$LabGroup'"
$tapPolicy = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId 'TemporaryAccessPass'
$targets = @($tapPolicy.AdditionalProperties.includeTargets | ForEach-Object { $_.id })
Show 'Temporary Access Pass policy' $tapPolicy.State ($tapPolicy.State -eq 'enabled')
Show 'Temporary Access Pass targets' ($(if ($group -and $targets -contains $group.Id) { $LabGroup } else { $targets -join ', ' })) ([bool]($group -and $targets -contains $group.Id))

$user = Get-MgUser -Filter "userPrincipalName eq '$LabNickname@$domain'"
Show 'Pilot user' "$LabNickname@$domain" ([bool]$user)
if (-not $user) { return }
$member = $group -and (Get-MgGroupMember -GroupId $group.Id -All | Where-Object Id -eq $user.Id)
Show "Member of $LabGroup" '' ([bool]$member)

$keys = @(Get-MgUserAuthenticationFido2Method -UserId $user.Id -All)
Show 'Passkeys registered' "$($keys.Count)" ($keys.Count -ge 1)
$auth = @($keys | Where-Object { $AuthenticatorAaguids.ContainsKey("$($_.AaGuid)".ToLower()) })
Show 'Passkey in Microsoft Authenticator' "$($auth.Count)" ($auth.Count -ge 1)
$taps = @(Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $user.Id)
Show 'No Temporary Access Pass left' "$($taps.Count)" ($taps.Count -eq 0)
