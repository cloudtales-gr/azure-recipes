# Shared by the ID-04 scripts: modules, sign-in and the lab names.
$modules = 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Users', 'Microsoft.Graph.Groups',
           'Microsoft.Graph.Identity.SignIns', 'Microsoft.Graph.Identity.DirectoryManagement'
foreach ($m in $modules) {
    if (-not (Get-Module -ListAvailable $m)) { Install-Module $m -Scope CurrentUser -Force -AllowClobber }
}
$LabGroup    = 'sg-passwordless-pilot'
$LabNickname = 'dimitra.kalogirou'

# Microsoft Authenticator passkeys identify themselves with these AAGUIDs (Microsoft Learn)
$AuthenticatorAaguids = @{
    '90a3ccdf-635c-4729-a248-9b709135078f' = 'Microsoft Authenticator (iOS)'
    'de1e552d-db1d-4423-a619-566b625cdc84' = 'Microsoft Authenticator (Android)'
}

function Connect-Lab([string]$TenantId) {
    Connect-MgGraph -TenantId $TenantId -NoWelcome -Scopes 'User.ReadWrite.All', 'Group.ReadWrite.All',
        'Policy.ReadWrite.AuthenticationMethod', 'Policy.Read.All', 'UserAuthenticationMethod.ReadWrite.All',
        'User.DeleteRestore.All', 'Domain.Read.All'
    (Get-MgDomain | Where-Object IsInitial).Id
}
function Get-RandomPassword([int]$Length = 64) {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%*-_=+'
    -join (1..$Length | ForEach-Object { $chars[[Security.Cryptography.RandomNumberGenerator]::GetInt32($chars.Length)] })
}
function Get-MethodName($m) {
    # '#microsoft.graph.fido2AuthenticationMethod' -> 'fido2'
    ($m.AdditionalProperties.'@odata.type' -replace '^#microsoft\.graph\.', '') -replace 'AuthenticationMethod$', ''
}
