// =============================================================================
// DEMO ASSET — DELIBERATELY NON-COMPLIANT
// This template contains planted FedRAMP Moderate (NIST 800-53) violations.
// It exists so GitHub Copilot Code Review can identify, explain, and remediate
// them in the pull request. DO NOT DEPLOY.
// The compliant reference lives in ../infra-remediated/.
// =============================================================================

targetScope = 'resourceGroup'

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Short name used to derive resource names.')
param workloadName string = 'fedrampdemo'

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: take('st${workloadName}${uniqueString(resourceGroup().id)}', 24)
  }
}

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    keyVaultName: take('kv-${workloadName}-${uniqueString(resourceGroup().id)}', 24)
    tenantId: subscription().tenantId
  }
}

output storageAccountName string = storage.outputs.storageAccountName
output keyVaultName string = keyvault.outputs.keyVaultName
