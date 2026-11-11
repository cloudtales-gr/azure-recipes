# ID-04: Passwordless with passkeys (FIDO2 and Microsoft Authenticator)

Article: <https://cloudtales.gr/recipes/identity/id-04-passwordless-passkeys-fido2-authenticator/>

A pilot user who never gets a password: a Temporary Access Pass for the first sign-in, a passkey in Microsoft
Authenticator (or a FIDO2 security key) registered with it, and the pass removed once the passkey works.
Everything is Microsoft Graph, so the scripts are PowerShell 7 only; on Linux run them with `pwsh` (see GOV-02).

## Run it

```powershell
pwsh ./deploy.ps1 -TenantId <name>.onmicrosoft.com      # group, user, policies, a one-hour pass
```

1. In a private browser window: <https://aka.ms/mysecurityinfo>, sign in as `dimitra.kalogirou@<domain>` with the pass,
   **Add sign-in method > Passkey in Microsoft Authenticator** (or **Security key**).
2. Sign out, sign in again with the passkey: **Sign-in options > Face, fingerprint, PIN or security key**.

```powershell
pwsh ./methods.ps1    -TenantId <name>.onmicrosoft.com   # every user's methods, the pilot's passkeys and pass
pwsh ./remove-tap.ps1 -TenantId <name>.onmicrosoft.com   # the passkey works: remove the pass
pwsh ./verify.ps1     -TenantId <name>.onmicrosoft.com   # OK / NO per check
pwsh ./cleanup.ps1    -TenantId <name>.onmicrosoft.com   # user, group, pass policy off
```

| | |
| --- | --- |
| Time | ~30 min |
| Cost | €0 (Microsoft Entra ID Free, no Azure resources) |
| Needs | a phone with Microsoft Authenticator (Android 14+ or iOS 17+), or a FIDO2 security key |
