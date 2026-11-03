<#
.SYNOPSIS
  ID-01: users from a CSV, a security group per department, and an "All staff" group that nests them.
  Idempotent: run it again and it only adds what is missing.
#>
#Requires -Version 7.4
param([Parameter(Mandatory)][string]$TenantId, [string]$CsvPath = "$PSScriptRoot/users.csv")
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/common.ps1"
$domain = Connect-Lab $TenantId
"Tenant: $domain"

# 1. Users
$created = @()
foreach ($row in Import-Csv $CsvPath) {
    $upn  = "$($row.Nickname)@$domain"
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    if (-not $user) {
        $pw = Get-RandomPassword
        $user = New-MgUser -GivenName $row.GivenName -Surname $row.Surname -DisplayName "$($row.GivenName) $($row.Surname)" `
            -UserPrincipalName $upn -MailNickname $row.Nickname -Department $row.Department -JobTitle $row.JobTitle `
            -UsageLocation 'GR' -AccountEnabled -PasswordProfile @{ Password = $pw; ForceChangePasswordNextSignIn = $true }
        $created += [pscustomobject]@{ User = $upn; TemporaryPassword = $pw }
        "user  $upn"
    }
}

if ($created) { Start-Sleep -Seconds 15 }   # new users take a moment to show up in list queries

# 2. A security group per department, with the department's users as members
$users = Get-MgUser -All -Property Id, UserPrincipalName, Department, JobTitle, MailNickname | Where-Object Department
$deptGroups = foreach ($dept in ($users.Department | Sort-Object -Unique)) {
    $name  = "sg-$($dept.ToLower())"
    $group = Get-MgGroup -Filter "displayName eq '$name'"
    if (-not $group) {
        $group = New-MgGroup -DisplayName $name -MailNickname $name -MailEnabled:$false -SecurityEnabled -Description "Everyone in $dept"
        "group $name" | Out-Host      # Out-Host: inside "$deptGroups = foreach", plain output would end up in the variable
    }
    $current = @(Get-MgGroupMember -GroupId $group.Id -All).Id
    foreach ($u in $users | Where-Object Department -eq $dept) {
        if ($current -notcontains $u.Id) { New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $u.Id }
    }
    $group
}

# 3. "All staff": the department groups nested inside it, not the users one by one
$all = Get-MgGroup -Filter "displayName eq 'sg-all-staff'"
if (-not $all) {
    $all = New-MgGroup -DisplayName 'sg-all-staff' -MailNickname 'sg-all-staff' -MailEnabled:$false -SecurityEnabled -Description 'Every department group'
    'group sg-all-staff'
}
$current = @(Get-MgGroupMember -GroupId $all.Id -All).Id
foreach ($g in $deptGroups) {
    if ($current -notcontains $g.Id) { New-MgGroupMember -GroupId $all.Id -DirectoryObjectId $g.Id }
}

# 4. The IT lead owns the IT group (owners manage members without an admin role)
$lead = $users | Where-Object JobTitle -eq 'IT Lead' | Select-Object -First 1
$itGroup = $deptGroups | Where-Object DisplayName -eq 'sg-it'
if ($lead -and $itGroup -and -not (Get-MgGroupOwner -GroupId $itGroup.Id -All | Where-Object Id -eq $lead.Id)) {
    New-MgGroupOwnerByRef -GroupId $itGroup.Id -BodyParameter @{ '@odata.id' = "https://graph.microsoft.com/v1.0/users/$($lead.Id)" }
    "owner $($lead.UserPrincipalName) of sg-it"
}

if ($created) {
    ''
    'Temporary passwords (must be changed at first sign-in, and MFA registration follows):'
    $created | Format-Table -AutoSize
}
