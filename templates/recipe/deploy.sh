#!/usr/bin/env bash
# {{ID}}: {{TITLE}}. Creates rg-recipe-{{ID_LOWER}} and deploys main.bicep into it.
# Usage: ./deploy.sh [location] [expires-in-days]
set -euo pipefail
location="${1:-swedencentral}"
days="${2:-1}"
recipe="{{ID}}"
rg="rg-recipe-{{ID_LOWER}}"
expires="$(date -u -d "+${days} day" +%F 2>/dev/null || date -u -v+"${days}"d +%F)"
here="$(cd "$(dirname "$0")" && pwd)"

az account show --query "{subscription:name}" -o tsv
az group create -n "$rg" -l "$location" \
  --tags recipe="$recipe" expires="$expires" source=https://github.com/cloudtales-gr/azure-recipes -o none
az deployment group create -g "$rg" -n "$(echo "$recipe" | tr "[:upper:]" "[:lower:]")" -f "$here/main.bicep" -p location="$location" \
  --query properties.outputs -o jsonc
