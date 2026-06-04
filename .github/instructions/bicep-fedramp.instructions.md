---
applyTo: "**/*.bicep"
---

# FedRAMP Moderate Control Catalog for Bicep

Authoritative control catalog for reviewing Bicep in this repository. It maps
FedRAMP Moderate (NIST SP 800-53 Rev 5) controls to checkable Bicep properties.
When reviewing `*.bicep` changes, enforce every rule below. For each violation,
cite the **control ID**, explain the **risk**, and provide a **Bicep suggestion**
that remediates it. The deterministic gate (PSRule for Azure) remains the
authoritative pass/fail.

## SC-7 — Boundary Protection

No default reachability from the public internet. On `storageAccounts`,
`vaults`, `Sql/servers`, `registries`, and similar data-plane resources:

- `publicNetworkAccess` MUST be `'Disabled'`. Flag `'Enabled'`.
- `networkAcls.defaultAction` MUST be `'Deny'`. Flag `'Allow'`.
- Flag any firewall rule allowing `0.0.0.0/0`, `0.0.0.0`, or `'*'`.
- Prefer a private endpoint. A public-facing resource must document the exception.

## SC-8(1) — Transmission Confidentiality and Integrity

Data in transit must use a current TLS version.

- Storage: `supportsHttpsTrafficOnly` MUST be `true`. Flag `false`.
- Any `minimumTlsVersion` MUST be `'TLS1_2'` or higher. Flag `'TLS1_0'`/`'TLS1_1'`.
- Web/app resources MUST require HTTPS (`httpsOnly: true`).

## SC-28 — Protection of Information at Rest

- Storage: `encryption.requireInfrastructureEncryption` SHOULD be `true`.
- Storage/Key Vault/SQL with sensitive data SHOULD use customer-managed keys
  (`encryption.keySource: 'Microsoft.Keyvault'` with `keyvaultproperties`). If
  only platform-managed keys are used, flag to confirm against data classification.

## SC-12 / SC-13 — Cryptographic Key Management

On `Microsoft.KeyVault/vaults`:

- `enableSoftDelete` MUST be `true`. Flag explicit `false`.
- `enablePurgeProtection` MUST be `true`. Flag `false` or omission.
- `softDeleteRetentionInDays` SHOULD be `>= 90`.

## AC-3 / IA-2 — Access Enforcement / Identification and Authentication

Use strong identity (Entra ID / managed identity + RBAC), not shared keys.

- Storage: `allowSharedKeyAccess` MUST be `false`. Flag `true` or omission.
- Key Vault: `enableRbacAuthorization` MUST be `true`. Flag `false`, and flag any
  `accessPolicies` array (legacy) — recommend RBAC role assignments.
- Resources exposing `disableLocalAuth` MUST set it `true` (App Configuration,
  Service Bus, Event Hubs, Cognitive Services).
- Flag wildcard Key Vault permissions such as `secrets: [ 'all' ]` (see AC-6).

## AC-6 — Least Privilege

- Flag role assignments using `Owner`/`Contributor` at subscription or
  resource-group scope where a narrower built-in role would suffice.
- Flag Key Vault access policies granting `all` permissions.
- Flag `roleDefinitionId` values resolving to privileged roles when only
  data-plane access is needed (prefer `Storage Blob Data Reader`).

## CM-6 — Configuration Settings (least functionality)

- Storage: `allowBlobPublicAccess` MUST be `false`. Flag `true` or omission.
- Storage: `allowCrossTenantReplication` SHOULD be `false`.
- Disable any feature not explicitly required by the workload.

## AU-2 / AU-6 / AU-12 — Audit Events and Generation

- Every data-plane PaaS resource (Storage, Key Vault, SQL, etc.) MUST have a
  `Microsoft.Insights/diagnosticSettings` resource sending logs and metrics to a
  Log Analytics workspace. Flag resources with none.
- Key Vault diagnostic settings MUST include the `AuditEvent` log category.

## Output format

Per finding: cite **[Control ID] title**, the property and its current vs.
required value, then a ```bicep``` suggested fix. Keep each control citation
distinct even when findings share a resource.
