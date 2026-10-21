// {{ID}}: {{TITLE}}
// Deployed by deploy.ps1 / deploy.sh into rg-recipe-{{ID_LOWER}}. No keys, no secrets: identities and RBAC only.
targetScope = 'resourceGroup'

@description('Region for every resource in the recipe.')
param location string = resourceGroup().location

@description('Short, unique suffix for globally unique names.')
param suffix string = uniqueString(resourceGroup().id)

// Resources go here.

output resourceGroup string = resourceGroup().name
