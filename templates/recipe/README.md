# {{ID}}: {{TITLE}}

Article: <https://cloudtales.gr/recipes/{{CATEGORY_SLUG}}/{{SLUG}}/>

What this deploys: _one sentence_.

## Run it

```powershell
# PowerShell 7 + Az module (recipe GOV-02 installs both)
./deploy.ps1                      # Sweden Central, resource group rg-recipe-{{ID_LOWER}}, expires tomorrow
./cleanup.ps1                     # deletes the resource group
```

```bash
# Bash + Azure CLI
./deploy.sh
./cleanup.sh
```

| | |
| --- | --- |
| Time | _~20 min_ |
| Lab cost | _~€0.10 if you clean up the same day_ |
| Tested | _Mon YYYY_ |

Every resource sits in one resource group tagged `recipe={{ID}}` and `expires=<date>`; `tools/Remove-ExpiredLabs.ps1` deletes what you forgot.
