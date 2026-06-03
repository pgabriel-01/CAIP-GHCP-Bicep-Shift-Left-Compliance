// =============================================================================
// DEMO ASSET — DELIBERATELY NON-COMPLIANT storage account.
// Planted FedRAMP Moderate violations (for Copilot Code Review to find):
//   SC-8(1)  supportsHttpsTrafficOnly = false, minimumTlsVersion = TLS1_0
//   SC-7     publicNetworkAccess = Enabled, networkAcls.defaultAction = Allow
//   CM-6     allowBlobPublicAccess = true
//   IA-2     allowSharedKeyAccess = true
//   SC-28    no infrastructure encryption / no customer-managed key
//   AU-2     no diagnostic settings
// =============================================================================

@description('Azure region for the storage account.')
param location string

@description('Globally unique storage account name.')
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    // SC-8(1): transmission confidentiality — HTTPS not enforced.
    supportsHttpsTrafficOnly: false
    // SC-8(1): weak minimum TLS version.
    minimumTlsVersion: 'TLS1_0'
    // CM-6: anonymous blob access permitted.
    allowBlobPublicAccess: true
    // IA-2 / AC-3: shared key access bypasses Entra ID + RBAC.
    allowSharedKeyAccess: true
    // SC-7: open to the public internet with default-allow firewall.
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    // SC-28: platform-managed keys only, no infrastructure encryption.
    encryption: {
      keySource: 'Microsoft.Storage'
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

// AU-2 / AU-12: NOTE — no diagnosticSettings resource is defined for this
// storage account, so no audit logs flow to Log Analytics.

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
