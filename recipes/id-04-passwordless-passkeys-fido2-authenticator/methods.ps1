<#
.SYNOPSIS
  ID-04: who signs in with what. Every user's authentication methods, then the pilot user's passkeys and pass. Changes nothing.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId

'--- Every user: registered methods'
Get-MgUser -All -Property Id, UserPrincipalName | Sort-Object UserPrincipalName | ForEach-Object {
    $names = Get-MgUserAuthenticationMethod -UserId $_.Id -All | ForEach-Object { Get-MethodName $_ } | Sort-Object -Unique
    [pscustomobject]@{
        User         = $_.UserPrincipalName
        Passwordless = [bool]($names -match '^(fido2|windowsHelloForBusiness|platformCredential)$')
        Methods      = $names -join ', '
    }
} | Format-Table -AutoSize

$user = Get-MgUser -Filter "userPrincipalName eq '$LabNickname@$domain'"
if (-not $user) { "No pilot user. Run deploy.ps1 first."; return }

'--- Passkeys of ' + $user.UserPrincipalName
$keys = @(Get-MgUserAuthenticationFido2Method -UserId $user.Id -All)
if ($keys) {
    $keys | ForEach-Object {
        [pscustomobject]@{
            Name    = $_.DisplayName
            Model   = $_.Model
            AAGUID  = $_.AaGuid
            Kind    = $AuthenticatorAaguids["$($_.AaGuid)".ToLower()] ?? 'security key or other passkey provider'
            Created = $_.CreatedDateTime.ToLocalTime().ToString('yyyy-MM-dd HH:mm')
        }
    } | Format-Table -AutoSize
} else { '(none yet)' }

'--- Temporary Access Pass of ' + $user.UserPrincipalName
$taps = @(Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $user.Id)
if ($taps) {
    $taps | Select-Object IsUsable, MethodUsabilityReason, IsUsableOnce, LifetimeInMinutes,
        @{ n = 'Created'; e = { $_.CreatedDateTime.ToLocalTime().ToString('HH:mm') } } | Format-Table -AutoSize
} else { '(none)' }
