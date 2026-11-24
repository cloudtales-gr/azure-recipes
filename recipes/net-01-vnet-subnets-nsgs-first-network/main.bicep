// NET-01: VNet, subnets and NSGs: the first network
// Three tiers (web, app, data), one NSG per subnet, and one small Linux VM per subnet to prove the rules.
// Deployed by deploy.ps1 / deploy.sh into rg-recipe-net-01. No public IPs: the VMs are reached with Run Command.
targetScope = 'resourceGroup'

@description('Region for every resource in the recipe.')
param location string = resourceGroup().location

@description('SSH public key for the lab VMs. The deploy scripts generate a throwaway one; nobody signs in with it.')
param sshPublicKey string

@description('Admin user on the lab VMs (SSH key only, no password).')
param adminUsername string = 'azureuser'

@description('VM size for the three test VMs. D2als_v6: 2 vCPU, 4 GiB, about USD 0.09 an hour each. New subscriptions usually get 10 vCPUs of Dalsv6 quota; B-series v2 often starts at 0.')
param vmSize string = 'Standard_D2als_v6'

var tiers = [
  { name: 'web', prefix: '10.10.1.0/24', ip: '10.10.1.4', port: 80 }
  { name: 'app',  prefix: '10.10.2.0/24', ip: '10.10.2.4', port: 8080 }
  { name: 'data', prefix: '10.10.3.0/24', ip: '10.10.3.4', port: 5432 }
]

// Who may reach each tier. Everything else from inside the VNet hits DenyVnetInbound (priority 4000).
var allowRules = {
  web: [
    { name: 'AllowHttpsFromInternet', priority: 100, source: 'Internet', port: '443' }
    { name: 'AllowHttpFromInternet', priority: 110, source: 'Internet', port: '80' }
  ]
  app: [
    { name: 'AllowAppFromWeb', priority: 100, source: '10.10.1.0/24', port: '8080' }
  ]
  data: [
    { name: 'AllowPostgresFromApp', priority: 100, source: '10.10.2.0/24', port: '5432' }
  ]
}

resource nsgs 'Microsoft.Network/networkSecurityGroups@2024-05-01' = [for t in tiers: {
  name: 'nsg-${t.name}'
  location: location
  properties: {
    securityRules: concat(map(allowRules[t.name], r => {
      name: r.name
      properties: {
        priority: r.priority
        direction: 'Inbound'
        access: 'Allow'
        protocol: 'Tcp'
        sourceAddressPrefix: r.source
        sourcePortRange: '*'
        destinationAddressPrefix: t.prefix
        destinationPortRange: r.port
      }
    }), [
      {
        // The default rule AllowVnetInBound (65000) lets every subnet reach every other one. This one wins first.
        name: 'DenyVnetInbound'
        properties: {
          priority: 4000
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ])
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-net01'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.10.0.0/16'] }
    subnets: [for (t, i) in tiers: {
      name: 'snet-${t.name}'
      properties: {
        addressPrefix: t.prefix
        networkSecurityGroup: { id: nsgs[i].id }
        defaultOutboundAccess: false    // private subnet: no implicit internet access (NET-05 adds a NAT gateway)
      }
    }]
  }
}

resource nics 'Microsoft.Network/networkInterfaces@2024-05-01' = [for (t, i) in tiers: {
  name: 'nic-${t.name}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: vnet.properties.subnets[i].id }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: t.ip
        }
      }
    ]
  }
}]

// Each VM runs one tiny TCP listener on its tier's port, so a blocked test means the NSG, not a missing service.
var cloudInit = '''#cloud-config
write_files:
  - path: /etc/systemd/system/lab-listener.service
    content: |
      [Unit]
      Description=NET-01 test listener
      [Service]
      ExecStart=/usr/bin/python3 -m http.server PORT --directory /tmp
      Restart=always
      [Install]
      WantedBy=multi-user.target
runcmd:
  - systemctl daemon-reload
  - systemctl enable --now lab-listener.service
'''

resource vms 'Microsoft.Compute/virtualMachines@2024-07-01' = [for (t, i) in tiers: {
  name: 'vm-${t.name}'
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: { secureBootEnabled: true, vTpmEnabled: true }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
    }
    osProfile: {
      computerName: 'vm-${t.name}'
      adminUsername: adminUsername
      customData: base64(replace(cloudInit, 'PORT', string(t.port)))
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            { path: '/home/${adminUsername}/.ssh/authorized_keys', keyData: sshPublicKey }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [ { id: nics[i].id, properties: { deleteOption: 'Delete' } } ]
    }
  }
}]

output vnet string = vnet.name
output web string = '${tiers[0].ip}:${tiers[0].port}'
output app string = '${tiers[1].ip}:${tiers[1].port}'
output data string = '${tiers[2].ip}:${tiers[2].port}'
