#!/usr/bin/env bash
# GOV-02: checks the toolkit and the sign-in from Bash.
show() { printf '%s %-22s %s\n' "$([[ -n "$2" ]] && echo 'OK ' || echo 'NO ')" "$1" "$2"; }

show "Azure CLI"    "$(az version --query '"azure-cli"' -o tsv 2>/dev/null)"
show "Bicep (az)"   "$(az bicep version 2>/dev/null | sed -n 's/.*version \([0-9.]*\).*/\1/p')"
show "Bicep (PATH)" "$(bicep --version 2>/dev/null | sed -n 's/.*version \([0-9.]*\).*/\1/p')"
# shellcheck disable=SC2016  # $PSVersionTable is PowerShell, not Bash
show "PowerShell"   "$(pwsh -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>/dev/null)"

az account show -o none 2>/dev/null || az login -o none
show "Signed in as" "$(az account show --query user.name -o tsv)"
show "Subscription" "$(az account show --query name -o tsv)"
show "Can read RGs" "$(az group list --query 'length(@)' -o tsv 2>/dev/null) resource groups"
