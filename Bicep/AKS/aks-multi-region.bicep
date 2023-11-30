param location1 string
param location2 string
param cluster1 string
param vnet1 string
param subnet1 string
param cluster2 string
param vnet2 string
param subnet2 string
param appGWVnetName string
param appGWSubName string
param aksNodeCount int
param aksNodeSize string
param appGatewayName string
param publicIpName string
param publicIpAllocationMethod string
param aksClusterFQDN1 string
param aksClusterFQDN2 string
@secure()
param clientId string
@secure()
param clientSecret string
param roleDefId string
param roleDefId2 string
param principalType string
param appName string
param storageAccountName string

// Networking
resource aksVnet1 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet1
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.1.0.0/16' ]
    }
  }
}
resource aksSubnet1 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: subnet1
  parent: aksVnet1
  properties: {
    addressPrefix: '10.1.1.0/24'
  }
}
resource aksVnet2 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnet2
  location: location2
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.2.0.0/16' ]
    }
  }
}
resource aksSubnet2 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: subnet2
  parent: aksVnet2
  properties: {
    addressPrefix: '10.2.1.0/24'
  }
}
resource appGWVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: appGWVnetName
  location: location1
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.2.0.0/16' ]
    }
  }
}
resource appGWSub 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: appGWSubName
  parent: appGWVnet
  properties: {
    addressPrefix: '10.2.1.0/24'
  }
}
// AKS Clusters
resource aksCluster1 'Microsoft.ContainerService/managedClusters@2022-04-01' = {
  dependsOn: [
    aksVnet1
  ]
  name: cluster1
  location: location1
  properties: {
    dnsPrefix: 'mydnsprefix'
    kubernetesVersion: '1.25'
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    servicePrincipalProfile: {
      clientId: clientId
      secret: clientSecret
    }
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: aksNodeCount
        vmSize: aksNodeSize
        mode: 'System'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      podCidr: '10.244.0.0/16'
      serviceCidr: '10.0.0.0/16'
      dockerBridgeCidr: '172.17.0.1/16'
    }
  }
}
resource aksCluster2 'Microsoft.ContainerService/managedClusters@2022-04-01' = {
  dependsOn: [
    aksVnet2
  ]
  name: cluster2
  location: location2
  properties: {
    dnsPrefix: 'mydnsprefix'
    kubernetesVersion: '1.25'
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    servicePrincipalProfile: {
      clientId: clientId
      secret: clientSecret
    }
    agentPoolProfiles: [
      {
        name: 'nodepool2'
        count: aksNodeCount
        vmSize: aksNodeSize
        mode: 'System'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      podCidr: '10.245.0.0/16'
      serviceCidr: '10.0.0.0/16'
      dockerBridgeCidr: '172.18.0.1/16'
    }
  }
}
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('AKSClusterAdminAssignment') 
  properties: {
    principalId: clientId
    principalType: principalType
    roleDefinitionId: roleDefId
  }
}
resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid('AppAssignment') 
  properties: {
    principalId: clientId
    principalType: principalType
    roleDefinitionId: roleDefId2
  }
}
// App Gateway
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: publicIpName
  location: location1
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
}
resource appGateway 'Microsoft.Network/applicationGateways@2021-02-01' = {
  name: appGatewayName
  location: location1
  dependsOn: [
    aksVnet1
  ]
  properties: {
    sku: {
      capacity: 2
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'AKS-AppGW-IpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', appGWVnetName, appGWSubName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'AppGW-FeIP'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', publicIpName)
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'AppGW-FePort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              fqdn: aksClusterFQDN1
            }
            {
              fqdn: aksClusterFQDN2
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings'
        properties: {
          port: 8080
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'AppGW-FeIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'AppGW-FePort')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'backendHttpSettings')
          }
        }
      }
    ]
  }
}
// Functions App
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appName
  location: location1
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.id
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
      ]
    }
  }
}
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appName
  location: location1
  kind: 'FunctionApp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location1
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: storageAccount
  name: 'default'
}
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  parent: blobService
  name: guid('containerName')
  properties: {
    publicAccess: 'None'
  }
}
