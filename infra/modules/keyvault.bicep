// =============================================================================
// DEMO ASSET — DELIBERATELY NON-COMPLIANT key vault.
// Planted FedRAMP Moderate violations (for Copilot Code Review to find):
//   SC-12    enableSoftDelete = false, enablePurgeProtection not set
//   AC-3     enableRbacAuthorization = false + broad legacy access policy
//   AC-6     access policy grants 'all' secret/key permissions
//   SC-7     publicNetworkAccess = Enabled, networkAcls.defaultAction = Allow
//   AU-2     no diagnostic settings (no AuditEvent logs)
// =============================================================================

@description('Azure region for the key vault.')
param location string

@description('Globally unique key vault name.')
param keyVaultName string

@description('Entra ID tenant ID.')
param tenantId string

@description('Object ID granted access via legacy access policy.')
param adminObjectId string = '00000000-0000-0000-0000-000000000000'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    // SC-12: soft delete disabled — deleted secrets are unrecoverable.
    enableSoftDelete: false
    // SC-12: purge protection omitted (defaults off) — permanent deletion possible.
    // AC-3 / IA-2: legacy access-policy model instead of RBAC.
    enableRbacAuthorization: false
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: adminObjectId
        permissions: {
          // AC-6: least privilege violated — full control granted.
          keys: [ 'all' ]
          secrets: [ 'all' ]
          certificates: [ 'all' ]
        }
      }
    ]
    // SC-7: reachable from the public internet, default-allow firewall.
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// AU-2 / AU-12: NOTE — no diagnosticSettings resource defined, so AuditEvent
// logs are not collected.

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
