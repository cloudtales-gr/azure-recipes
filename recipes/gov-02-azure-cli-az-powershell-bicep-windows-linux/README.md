# GOV-02: Azure CLI, Az PowerShell and Bicep on Windows and Linux

Article: <https://cloudtales.gr/recipes/governance/gov-02-azure-cli-az-powershell-bicep-windows-linux/>

Installs the toolkit every other recipe uses, then checks it and the sign-in. Nothing is created in Azure.

## Run it

```powershell
# Windows 10/11 or Windows Server 2025
./install-windows.ps1 -WithVSCode
# open a new terminal, then
pwsh ./verify.ps1
```

```bash
# Ubuntu 24.04 or WSL
./install-ubuntu.sh
./verify.sh
```

| | |
| --- | --- |
| Time | ~15 min |
| Cost | €0 (no Azure resources) |
| Tested | _Nov 2026_ |
