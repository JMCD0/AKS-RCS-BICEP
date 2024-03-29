using './main.bicep'

param location1 = 'uksouth '
param location2 = 'northeurope'
param cluster1 = 'AKS-Cluster-01'
param vnet1 = 'vNet-01'
param subnet1 = 'Sub-01'
param cluster2 = 'AKS-Cluster-02'
param vnet2 = 'vNet-02'
param subnet2 = 'Sub-02'
param appGWVnetName = 'AppGW-vNet'
param appGWSubName = 'AppGW-Sub'
param aksNodeCount = 1
param aksNodeSize = 'Standard_D2s_v3'
param appGatewayName = 'AKS-AppGW'
param publicIpName = 'AppGw-IP'
param publicIpAllocationMethod = 'Static'
param aksClusterFQDN1 = 'aks-cluster1-region1'
param aksClusterFQDN2 = 'aks-cluster2-region2'
param clientId = ''
param clientSecret = ''
param principalType = 'ServicePrincipal'
param roleDefId = '/providers/Microsoft.Authorization/roleDefinitions/fd036e6b-1266-47a0-b0bb-a05d04831731'
param roleDefId2 = '/providers/Microsoft.Authorization/roleDefinitions/641177b8-a67a-45b9-a033-47bc880bb21e'
param appName = 'AKS-RCS-PS1'
param storageAccountName = 'aksrcssa'
