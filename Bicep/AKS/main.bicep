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

module aksmultiregion './aks-multi-region.bicep' = {
  name: 'aks-multi-region'
  params: {
    location1: location1
    location2: location2
    cluster1: cluster1
    vnet1: vnet1
    subnet1: subnet1
    cluster2: cluster2
    vnet2: vnet2
    subnet2: subnet2
    appGWSubName: appGWSubName
    appGWVnetName: appGWVnetName
    aksNodeCount: aksNodeCount
    aksNodeSize: aksNodeSize
    appGatewayName: appGatewayName
    publicIpName: publicIpName
    publicIpAllocationMethod: publicIpAllocationMethod
    aksClusterFQDN1: aksClusterFQDN1
    aksClusterFQDN2: aksClusterFQDN2
    clientId: clientId
    clientSecret: clientSecret
    roleDefId: roleDefId
    roleDefId2: roleDefId2
    principalType: principalType
    appName: appName
    storageAccountName: storageAccountName
  }
}
