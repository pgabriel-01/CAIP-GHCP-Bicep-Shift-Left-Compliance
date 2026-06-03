# Copilot Repository Instructions

This repository deploys Azure infrastructure using **Bicep** for a workload
targeting the **FedRAMP Moderate** baseline (NIST SP 800-53 Rev 5).

## How you should review changes

When reviewing pull requests that touch infrastructure-as-code:

1. **Treat security and regulatory compliance as a first-class review concern**,
   equal to correctness. Assume every resource must satisfy the FedRAMP Moderate
   baseline unless an explicit, documented exception exists in the PR.
2. For each finding, always provide three things:
   - **What** the misconfiguration is (the specific property and value).
   - **Which control** it maps to (cite the NIST 800-53 control ID and name).
   - **How to fix it** — provide a concrete Bicep code suggestion.
3. **Prefer specificity over breadth.** Cite the exact property (e.g.
   `supportsHttpsTrafficOnly`) and the exact compliant value, not general advice.
4. **Do not claim completeness.** You augment — not replace — the deterministic
   policy gate (PSRule for Azure) and Azure Policy. If you are unsure whether a
   control applies, say so rather than guessing.
5. When you cite a control mapping you are not confident about, **flag it as
   "verify against the control catalog"** rather than asserting it.

The authoritative, detailed control-to-property mapping lives in
[`.github/instructions/bicep-fedramp.instructions.md`](instructions/bicep-fedramp.instructions.md)
and applies to all `**/*.bicep` files.

## Style

- Bicep should use `2022-09-01` or later API versions where practical.
- Favor managed identity and RBAC over keys and access policies.
- Every PaaS data resource should emit diagnostic logs to Log Analytics.
