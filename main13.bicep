param resourceLocation string ='North Europe'
var vnetname='myvnet1'
var networkaddressPrefix='10.0.0.0/16'



resource myvnet1 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetname
  location: resourceLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkaddressPrefix
      ]
    }
    subnets: [for i in range(1,3):{
        name: 'Subnet${i}'
        properties: {
          addressPrefix: cidrSubnet(networkaddressPrefix,24,i)
        }
      }
    ]
  }
}

resource vikip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'vikip'
  location: resourceLocation
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource viknic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: 'viknic'
  location: resourceLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {            
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'myvnet1', 'Subnet1')
          }
          publicIPAddress: {
            id: vikip.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: mynsg.id
    }
  }
}


resource mynsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'mynsg'
  location: resourceLocation
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP'
        properties: {
          description: 'Allow Remote Desktop'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vault9347q8yh 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: 'vault9347q8yh'
  scope: resourceGroup('c4572d16-bab0-4d1a-b9e2-d8e66864022c', 'keyvault-rg' )
}

module vm './vm.bicep' = {
  name: 'deployVM'
  params: {
    resourceLocation: resourceLocation
    adminPassword: vault9347q8yh.getSecret('vmpasswordsecret')
  }
}

