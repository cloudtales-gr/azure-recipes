# Shared by the NET-16 scripts. Azure CLI, signed in (az login) to the subscription the lab uses.
function Invoke-Az {
    # az errors do not stop PowerShell on their own
    az @args
    if ($LASTEXITCODE -ne 0) { throw "az $($args[0..2] -join ' ') failed" }
}

function Get-SalState([string]$ResourceGroup, [string]$VnetName, [string]$Subnet) {
    az network vnet subnet show -g $ResourceGroup --vnet-name $VnetName -n $Subnet `
        --query "{state:provisioningState, delegation:delegations[0].serviceName, sal:serviceAssociationLinks[].name}" -o json |
        ConvertFrom-Json
}
