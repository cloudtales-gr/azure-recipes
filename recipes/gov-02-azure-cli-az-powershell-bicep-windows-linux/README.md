# GOV-02: Azure CLI, Az PowerShell and Bicep on Windows and Linux

Article: <https://cloudtales.gr/recipes/governance/gov-02-azure-cli-az-powershell-bicep-windows-linux/>

Installs the toolkit every other recipe uses, then checks it and the sign-in. Nothing is created in Azure.

## Run it

```powershell
# Windows 10/11 or Windows Server 2025
./install-windows.ps1 -WithVSCode
# close every terminal window, open a new one, then
pwsh ./verify.ps1
```

```bash
# Ubuntu 24.04 or WSL, as your normal user (not root)
./install-ubuntu.sh
./verify.sh
```

| | |
| --- | --- |
| Time | ~15 min |
| Cost | €0 (no Azure resources) |
| Tested | Oct 2026 (Windows 11, Ubuntu 24.04 on WSL) |
