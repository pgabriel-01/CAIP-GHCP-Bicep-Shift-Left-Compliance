# FedRAMP Moderate Control Catalog

This is the human-readable companion to
[`.github/instructions/bicep-fedramp.instructions.md`](../.github/instructions/bicep-fedramp.instructions.md).
Each row corresponds to a planted violation in `infra/` and its compliant value in
`infra-remediated/`.

| # | Control | Control name | Bicep property | Non-compliant (demo) | Compliant |
|---|---------|--------------|----------------|----------------------|-----------|
| 1 | **SC-8(1)** | Transmission Confidentiality & Integrity | `supportsHttpsTrafficOnly` | `false` | `true` |
| 2 | **SC-8(1)** | Transmission Confidentiality & Integrity | `minimumTlsVersion` | `'TLS1_0'` | `'TLS1_2'` |
| 3 | **CM-6** | Configuration Settings | `allowBlobPublicAccess` | `true` | `false` |
| 4 | **IA-2 / AC-3** | Identification & Auth / Access Enforcement | `allowSharedKeyAccess` | `true` | `false` |
| 5 | **SC-7** | Boundary Protection | `publicNetworkAccess` | `'Enabled'` | `'Disabled'` |
| 6 | **SC-7** | Boundary Protection | `networkAcls.defaultAction` | `'Allow'` | `'Deny'` |
| 7 | **SC-28** | Protection of Information at Rest | `requireInfrastructureEncryption` | *(absent)* | `true` |
| 8 | **SC-12** | Cryptographic Key Management | `enableSoftDelete` | `false` | `true` |
| 9 | **SC-12** | Cryptographic Key Management | `enablePurgeProtection` | *(absent)* | `true` |
| 10 | **AC-3 / IA-2** | Access Enforcement | `enableRbacAuthorization` | `false` + access policy | `true` |
| 11 | **AC-6** | Least Privilege | KV access policy permissions | `[ 'all' ]` | RBAC role assignment |
| 12 | **AU-2 / AU-12** | Audit Events / Generation | `diagnosticSettings` | *(absent)* | sends to Log Analytics |

## Why these controls

Each maps cleanly to a single, well-understood Bicep property, so the reasoning
behind a finding lands on something concrete and checkable. Together they span the
major control families — boundary protection, cryptography in transit, cryptography
at rest, identity, least privilege, and audit — demonstrating breadth without
requiring an exhaustive baseline.

## Caveats

- These mappings are **organizational interpretations** of the FedRAMP Moderate
  baseline, encoded as policy. They are intentionally stricter than the minimum in
  places (for example, requiring infrastructure encryption).
- A real authorization package maps controls to **System Security Plan** narratives
  and evidence, not just resource properties. This catalog covers the **technical
  control** slice only.
- The authoritative pass/fail is the deterministic gate (PSRule / Azure Policy),
  **not** Copilot.
