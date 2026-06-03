---
applyTo: "**/*.bicep"
---

# FedRAMP Moderate Control Catalog for Bicep

This file is the **authoritative control catalog** for reviewing Bicep in this
repository. It maps FedRAMP Moderate (NIST SP 800-53 Rev 5) controls to concrete,
checkable Bicep properties. When reviewing `*.bicep` changes, enforce every rule
below. For each violation found, cite the **control ID**, explain the **risk**,
and provide a **Bicep code suggestion** that remediates it.

> Authoring note: This catalog encodes organizational policy. It is intentionally
> conservative and may be stricter than the minimum baseline. The deterministic
> gate (PSRule for Azure) remains the authoritative pass/fail.

---

## SC-7 — Boundary Protection

**Intent:** Resources must not be reachable from the public internet by default;
access flows through controlled boundaries (private endpoints, network ACLs).

Check on `Microsoft.Storage/storageAccounts`, `Microsoft.KeyVault/vaults`,
`Microsoft.Sql/servers`, `Microsoft.ContainerRegistry/registries`, and similar
data-plane resources:

- `publicNetworkAccess` MUST be `'Disabled'`. Flag any `'Enabled'`.
- `networkAcls.defaultAction` MUST be `'Deny'`. Flag `'Allow'`.
- Flag any firewall rule allowing `0.0.0.0/0`, `0.0.0.0`, or `'*'`.
- Prefer a private endpoint over public access. If a resource is public-facing by
  design, the PR must document the exception.

## SC-8(1) — Transmission Confidentiality and Integrity

**Intent:** Data in transit must be encrypted with a current TLS version.

- Storage: `supportsHttpsTrafficOnly` MUST be `true`. Flag `false`.
- Any resource exposing `minimumTlsVersion` MUST be `'TLS1_2'` (or higher). Flag
  `'TLS1_0'` and `'TLS1_1'`.
- Web/app resources MUST require HTTPS (`httpsOnly: true`).

## SC-28 — Protection of Information at Rest

**Intent:** Data at rest must be encrypted; for Moderate workloads, prefer
customer-managed keys (CMK) and infrastructure (double) encryption.

- Storage: `encryption.requireInfrastructureEncryption` SHOULD be `true`.
- Storage/Key Vault/SQL handling sensitive data SHOULD use customer-managed keys
  (`encryption.keySource: 'Microsoft.Keyvault'` with a `keyvaultproperties`
  block) rather than relying solely on platform-managed keys. If only
  platform-managed keys are used, note it as a finding to confirm against data
  classification.

## SC-12 / SC-13 — Cryptographic Key Establishment and Management

**Intent:** Key material must be recoverable and protected from accidental or
malicious deletion.

On `Microsoft.KeyVault/vaults`:

- `enableSoftDelete` MUST be `true` (and is required by the platform on current
  API versions — flag explicit `false`).
- `enablePurgeProtection` MUST be `true`. Flag `false` or omission.
- `softDeleteRetentionInDays` SHOULD be `>= 90`.

## AC-3 / IA-2 — Access Enforcement / Identification and Authentication

**Intent:** Use strong identity (Entra ID / managed identity + RBAC) rather than
shared secrets or keys.

- Storage: `allowSharedKeyAccess` MUST be `false`. Shared-key access bypasses
  Entra ID and RBAC. Flag `true` or omission.
- Key Vault: `enableRbacAuthorization` MUST be `true`. Flag `false`, and flag the
  presence of an `accessPolicies` array (legacy model) — recommend migrating to
  RBAC role assignments.
- Resources exposing `disableLocalAuth` MUST set it to `true` (e.g. App
  Configuration, Service Bus, Event Hubs, Cognitive Services).
- Flag wildcard or overly broad Key Vault access policy permissions such as
  `secrets: [ 'all' ]` or `keys: [ 'all' ]` (also see AC-6).

## AC-6 — Least Privilege

**Intent:** Grant the minimum permissions necessary.

- Flag role assignments using `Owner` or `Contributor` at subscription or
  resource-group scope where a narrower built-in role would suffice.
- Flag Key Vault access policies granting `all` permissions.
- Flag `roleDefinitionId` values that resolve to highly privileged roles when the
  workload only needs data-plane access (e.g. prefer `Storage Blob Data Reader`
  over `Contributor`).

## CM-6 — Configuration Settings (least functionality)

**Intent:** Disable insecure default features.

- Storage: `allowBlobPublicAccess` MUST be `false`. Anonymous blob access is a
  common data-exposure vector. Flag `true` or omission.
- Storage: `allowCrossTenantReplication` SHOULD be `false`.
- Disable any feature not explicitly required by the workload.

## AU-2 / AU-6 / AU-12 — Audit Events, Review, and Generation

**Intent:** Security-relevant events must be logged and retained.

- Every data-plane PaaS resource (Storage, Key Vault, SQL, etc.) MUST have a
  `Microsoft.Insights/diagnosticSettings` resource sending logs and metrics to a
  Log Analytics workspace. Flag resources with no diagnostic settings.
- Key Vault diagnostic settings MUST include the `AuditEvent` log category.

---

## Output format for review comments

For each finding, structure the comment as:

> **[Control ID] Short title** — *risk in one sentence.*
> The property `<name>` is set to `<current>`; FedRAMP Moderate requires
> `<required>`.
> ```bicep
> // suggested fix
> ```

Keep findings concrete and actionable. If multiple findings share a resource,
group them but keep each control citation distinct.
