# FedRAMP Moderate Control Catalog (slide-ready)

This is the human-readable companion to
[`.github/instructions/bicep-fedramp.instructions.md`](../.github/instructions/bicep-fedramp.instructions.md).
Use it as a slide or handout. Each row is a planted violation in the demo.

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

These map cleanly to a single, well-understood Bicep property each, so the audience
can see the AI's reasoning land on something concrete and checkable. They also span
the major control families — boundary, crypto-in-transit, crypto-at-rest, identity,
least privilege, and audit — which demonstrates breadth without overwhelming a
one-hour session.

## Honest caveats to state out loud

- These mappings are **organizational interpretations** of the FedRAMP Moderate
  baseline, encoded as policy. They are intentionally stricter than the minimum in
  places (e.g. requiring infrastructure encryption).
- A real ATO package maps controls to **System Security Plan** narratives and
  evidence, not just resource properties. This demo covers the **technical
  control** slice only.
- The authoritative pass/fail is the deterministic gate (PSRule / Azure Policy),
  **not** Copilot.
