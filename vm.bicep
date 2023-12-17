// Putting the resource of the storage account because it is referenced 
// when creating the VM

param resourceLocation string ='North Europe'
@secure()
param adminPassword string

resource strg8785353536 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'strg8785353536'
  location: resourceLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource mywinvm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'mywinvm'
  location: resourceLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'mywinvm'
      adminUsername: 'ur2close2me'
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'windowsVM1OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'viknic')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: reference(resourceId('Microsoft.Storage/storageAccounts/', toLower('strg8785353536'))).primaryEndpoints.blob
      }
    }
  }
}
