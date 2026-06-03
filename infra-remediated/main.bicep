// =============================================================================
// COMPLIANT REFERENCE — FedRAMP Moderate (NIST 800-53 Rev 5).
// This is what the flawed ../infra/ template looks like after remediation.
// =============================================================================

targetScope = 'resourceGroup'

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Short name used to derive resource names.')
param workloadName string = 'fedrampdemo'

@description('Log Analytics workspace resource ID for diagnostics (AU-2/AU-12).')
param logAnalyticsWorkspaceId string

@description('Resource tags applied to all resources (governance / cost allocation).')
param tags object = {
  workload: 'fedramp-demo'
  dataClassification: 'moderate'
  costCenter: 'caip-demo'
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: take('st${workloadName}${uniqueString(resourceGroup().id)}', 24)
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    keyVaultName: take('kv-${workloadName}-${uniqueString(resourceGroup().id)}', 24)
    tenantId: subscription().tenantId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

output storageAccountName string = storage.outputs.storageAccountName
output keyVaultName string = keyvault.outputs.keyVaultName
