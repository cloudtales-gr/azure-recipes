# NET-16: Cloud Shell in a private VNet: deploy it, tear it down, free a stuck subnet

Article: <https://cloudtales.gr/recipes/networking/net-16-cloud-shell-private-vnet-deploy-teardown/>

Azure Cloud Shell in your own virtual network, with the two Microsoft quickstart templates, and a teardown
that does not leave the VNet stuck. The deploy is in the portal (the templates are Microsoft's); these scripts
do the parts around it. Azure CLI and PowerShell 7; on Linux run them with `pwsh` (see GOV-02).

## Run it

1. `pwsh ./prepare.ps1` registers the providers, creates `rg-cs-vnet-lab` and an empty `vnet-cs-lab` in North Europe,
   and prints the values for the template form, including the Azure Container Instance object ID.
2. Portal: deploy **Azure Cloud Shell - VNet** (`cloud-shell-vnet`), then **Azure Cloud Shell - VNet storage**
   (`cloud-shell-vnet-storage`) into the same resource group.
3. Cloud Shell > Settings > Reset user settings, reopen, **Mount storage account** > **Use an existing private virtual network**.
4. `pwsh ./sal.ps1` shows `acisal present: True` while Cloud Shell uses the subnet.

## Tear it down

1. Close every Cloud Shell session, then Cloud Shell > Settings > **Reset user settings** (every user who connected it).
2. `pwsh ./remove-sal.ps1` once a day until it says `released`. In the lab that took about a day.
3. `pwsh ./cleanup.ps1` deletes the resource group, and refuses while `acisal` is still there.

| | |
| --- | --- |
| Time | ~30 min to deploy; the teardown waits up to a day or two |
| Cost | under €1 for a lab kept for a day (private endpoint, storage, Relay) |
| Files | `prepare.ps1`, `sal.ps1`, `remove-sal.ps1`, `cleanup.ps1`, `common.ps1`, `architecture.svg` |
