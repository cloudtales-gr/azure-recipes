# ID-01: Users and groups with Microsoft Graph PowerShell

Article: <https://cloudtales.gr/recipes/identity/id-01-users-groups-microsoft-graph-powershell/>

Six users from a CSV, a security group per department, an "All staff" group that nests them, a group owner,
the everyday queries, and a leaver done properly. Microsoft Graph, PowerShell 7 (on Linux: `pwsh`).
Runs in the tenant from [GOV-01](../gov-01-secure-new-azure-tenant-first-hour/).

## Run it

```powershell
pwsh ./deploy.ps1  -TenantId <name>.onmicrosoft.com
pwsh ./queries.ps1 -TenantId <name>.onmicrosoft.com
pwsh ./verify.ps1  -TenantId <name>.onmicrosoft.com
pwsh ./leaver.ps1  -TenantId <name>.onmicrosoft.com -Nickname giorgos.pappas -Delete
pwsh ./cleanup.ps1 -TenantId <name>.onmicrosoft.com
```

| | |
| --- | --- |
| Time | ~30 min |
| Cost | €0 (Microsoft Entra ID Free) |
| Tested | Nov 2026 |
