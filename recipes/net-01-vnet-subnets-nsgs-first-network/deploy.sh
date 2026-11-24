#!/usr/bin/env bash
# NET-01: VNet, subnets and NSGs: the first network. Creates rg-recipe-net-01 and deploys main.bicep into it:
# a VNet with web, app and data subnets, one NSG per subnet, and one small Ubuntu VM per subnet to test the rules.
# Usage: ./deploy.sh [location] [expires-in-days] [vm-size]
set -euo pipefail
location="${1:-swedencentral}"
days="${2:-1}"
vmsize="${3:-Standard_D2als_v6}"
recipe="NET-01"
rg="rg-recipe-net-01"
expires="$(date -u -d "+${days} day" +%F 2>/dev/null || date -u -v+"${days}"d +%F)"
here="$(cd "$(dirname "$0")" && pwd)"

# A throwaway SSH key: Azure requires one for a Linux VM without a password. Nobody signs in with it;
# the tests use Run Command, which needs no inbound port at all.
key="${TMPDIR:-/tmp}/net01-lab"
[ -f "$key.pub" ] || ssh-keygen -t rsa -b 4096 -f "$key" -N "" -q -C net01-lab

az account show --query "{subscription:name}" -o tsv

# A new subscription may not have these providers registered yet. Until Microsoft.Compute is registered,
# every VM family shows a quota of 0 and the deployment fails with QuotaExceeded.
for ns in Microsoft.Network Microsoft.Compute; do
  if [ "$(az provider show -n "$ns" --query registrationState -o tsv)" != "Registered" ]; then
    echo "Registering $ns ..."
    az provider register -n "$ns" --wait
  fi
done
az group create -n "$rg" -l "$location" \
  --tags recipe="$recipe" expires="$expires" source=https://github.com/cloudtales-gr/azure-recipes -o none
az deployment group create -g "$rg" -n net-01 -f "$here/main.bicep" \
  -p location="$location" sshPublicKey="$(cat "$key.pub")" vmSize="$vmsize" \
  --query "properties.outputs.{vnet:vnet.value, web:web.value, app:app.value, data:data.value}" -o table
