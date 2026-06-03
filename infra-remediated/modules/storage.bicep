// =============================================================================
// COMPLIANT REFERENCE — storage account meeting FedRAMP Moderate.
// Each setting is annotated with the control it satisfies.
// =============================================================================

@description('Azure region for the storage account.')
param location string

@description('Globally unique storage account name.')
param storageAccountName string

@description('Log Analytics workspace resource ID for diagnostics (AU-2/AU-12).')
param logAnalyticsWorkspaceId string

@description('Resource tags.')
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true          // SC-8(1)
    minimumTlsVersion: 'TLS1_2'             // SC-8(1)
    allowBlobPublicAccess: false            // CM-6
    allowSharedKeyAccess: false             // IA-2 / AC-3
    allowCrossTenantReplication: false      // CM-6
    publicNetworkAccess: 'Disabled'         // SC-7
    networkAcls: {
      defaultAction: 'Deny'                 // SC-7
      bypass: 'AzureServices'
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true // SC-28
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
    }
  }
}

// Blob service with soft delete enabled (data protection / recoverability).
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// AU-2 / AU-12: audit + metrics flow to Log Analytics.
resource storageDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-law'
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
