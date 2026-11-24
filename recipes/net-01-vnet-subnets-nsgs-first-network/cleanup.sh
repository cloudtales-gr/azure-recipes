#!/usr/bin/env bash
# NET-01: deletes everything the recipe created (one resource group) and the throwaway SSH key.
set -euo pipefail
az group delete -n "rg-recipe-net-01" --yes
rm -f "${TMPDIR:-/tmp}"/net01-lab "${TMPDIR:-/tmp}"/net01-lab.pub
