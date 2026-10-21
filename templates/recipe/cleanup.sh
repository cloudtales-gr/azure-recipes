#!/usr/bin/env bash
# {{ID}}: deletes everything the recipe created (one resource group).
set -euo pipefail
az group delete -n "rg-recipe-{{ID_LOWER}}" --yes
