# GOV-01: Secure a new Azure tenant in the first hour

Article: <https://cloudtales.gr/recipes/governance/gov-01-secure-new-azure-tenant-first-hour/>

The first hour of a new Microsoft Entra / Azure tenant: security defaults on, two break-glass accounts with
passkeys, and ordinary users stopped from registering apps, creating tenants or consenting to apps.
Everything is Microsoft Graph, so the scripts are PowerShell 7 only; on Linux run them with `pwsh` (see GOV-02).

## Run it

1. Create the tenant: Azure portal > Microsoft Entra ID > Overview > Manage tenants > Create > Microsoft Entra ID.
2. As its Global Administrator:

   ```powershell
   pwsh ./harden.ps1 -TenantId <name>.onmicrosoft.com
   ```

   Store the two passwords it prints. They are shown once.
3. For each break-glass account, in a private browser window: <https://aka.ms/mysecurityinfo>, sign in,
   **Add sign-in method > Passkey**. A FIDO2 security key is best; keep it in a safe, not on a key ring.
4. Check everything:

   ```powershell
   pwsh ./verify.ps1 -TenantId <name>.onmicrosoft.com
   ```

| | |
| --- | --- |
| Time | ~45 min |
| Cost | €0 (Microsoft Entra ID Free, no Azure resources) |
| Tested | Nov 2026 |

Keep the tenant: the ID-xx recipes build on it.
