// =============================================================================
// COMPLIANT REFERENCE — key vault meeting FedRAMP Moderate.
// Each setting is annotated with the control it satisfies.
// =============================================================================

@description('Azure region for the key vault.')
param location string

@description('Globally unique key vault name.')
param keyVaultName string

@description('Entra ID tenant ID.')
param tenantId string

@description('Log Analytics workspace resource ID for diagnostics (AU-2/AU-12).')
param logAnalyticsWorkspaceId string

@description('Resource tags.')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: true                  // SC-12
    softDeleteRetentionInDays: 90           // SC-12
    enablePurgeProtection: true             // SC-12
    enableRbacAuthorization: true           // AC-3 / IA-2 (RBAC, no access policies)
    publicNetworkAccess: 'Disabled'         // SC-7
    networkAcls: {
      defaultAction: 'Deny'                 // SC-7
      bypass: 'AzureServices'
    }
  }
}

// AU-2 / AU-12: AuditEvent logs flow to Log Analytics.
resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-law'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
