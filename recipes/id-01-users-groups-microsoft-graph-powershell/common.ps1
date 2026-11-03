# Shared by the ID-01 scripts: modules and sign-in.
$modules = 'Microsoft.Graph.Authentication', 'Microsoft.Graph.Users', 'Microsoft.Graph.Users.Actions',
           'Microsoft.Graph.Groups', 'Microsoft.Graph.Identity.DirectoryManagement'
foreach ($m in $modules) {
    if (-not (Get-Module -ListAvailable $m)) { Install-Module $m -Scope CurrentUser -Force -AllowClobber }
}
function Connect-Lab([string]$TenantId) {
    Connect-MgGraph -TenantId $TenantId -NoWelcome -Scopes 'User.ReadWrite.All', 'Group.ReadWrite.All', 'User.RevokeSessions.All', 'User.DeleteRestore.All', 'Domain.Read.All'
    (Get-MgDomain | Where-Object IsInitial).Id
}
function Get-RandomPassword([int]$Length = 20) {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%*-_=+'
    -join (1..$Length | ForEach-Object { $chars[[Security.Cryptography.RandomNumberGenerator]::GetInt32($chars.Length)] })
}
