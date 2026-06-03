# Speaker Notes & Run-of-Show

**Session:** Shift-Left Compliance — Using GitHub Copilot to Review Bicep
Deployments Against Security and Regulatory Controls
**Audience:** Internal Microsoft, senior / topic-fluent
**Duration:** 60 minutes
**Framework:** FedRAMP Moderate (NIST SP 800-53 Rev 5)

---

## The one sentence that anchors everything

> **Copilot is the shift-left _interpretation and remediation_ layer; deterministic
> policy is the _enforcement and attestation_ layer.**

Say this early, repeat it at the end. It is the answer to the hardest Q&A question
(below) and it is what lets you *attest* to the approach.

---

## Run-of-show (60 min)

| Time | Segment | What you do |
|------|---------|-------------|
| 0:00–0:05 | **Hook** | A late compliance finding in prod costs days and credibility. Show the cost-of-late-feedback curve. |
| 0:05–0:15 | **Problem space** | Policy-as-code already *detects*, but developers don't *understand* findings and security teams are the bottleneck. The gap is interpretation + remediation speed, not detection. |
| 0:15–0:22 | **Reference architecture** | Walk the mermaid diagram in the README. Stress: Copilot and PSRule run in parallel; defense-in-depth. |
| 0:22–0:30 | **The attestable artifact** | Open `.github/instructions/bicep-fedramp.instructions.md`. "Compliance encoded once, applied on every PR. The intelligence is *our* curated catalog, not the model's general knowledge." |
| 0:30–0:48 | **Live demo** | The PR walkthrough (script below). |
| 0:48–0:54 | **Limitations** | The honesty slide (below). This *builds* credibility with this audience. |
| 0:54–1:00 | **Close + Q&A** | Restate the anchor sentence. Business outcomes: MTTR, % caught pre-deploy, reviewer time saved. |

---

## Live demo script (the 18 minutes that matter)

**Pre-flight (do this BEFORE the call — see checklist at bottom):**
- Repo pushed to GitHub, Copilot Code Review enabled on the repo.
- A branch `demo/flawed-infra` ready with the `infra/` changes, **not yet** opened
  as a PR. Or have the PR pre-created and just refresh it live.
- Backup recording of a successful Copilot review run, in case live output varies.

**Steps:**
1. **Show the catalog** (`.github/instructions/bicep-fedramp.instructions.md`).
   30 seconds. "This is the policy. Watch it get applied."
2. **Open the PR** that adds `infra/main.bicep`, `infra/modules/storage.bicep`,
   `infra/modules/keyvault.bicep`.
3. **Trigger / show Copilot Code Review.** Walk 3–4 of its inline comments. For
   each, point out the three things you required in the instructions: *what*,
   *which control*, *how to fix*. Best ones to highlight:
   - `supportsHttpsTrafficOnly: false` → SC-8(1)
   - `allowSharedKeyAccess: true` → IA-2
   - `enablePurgeProtection` absent → SC-12
   - missing `diagnosticSettings` → AU-2 (a *good* one because it's an absence, not
     a bad value — shows the model reasoning about what's *missing*).
4. **Apply fixes.** Either accept Copilot's suggestions inline, or copy from
   `infra-remediated/`. Show the diff going green.
5. **Show the deterministic gate.** Point to the PSRule check
   (`.github/workflows/psrule-validate.yml`). "The AI and the audit gate agree —
   but the gate is what actually blocks the merge."
6. **The credibility move:** call out one finding where Copilot was vague, cited a
   slightly-off control, or missed something. Narrate it: "This is why it's a
   reviewer aid, not the gate." Do not skip this — it is the most persuasive 60
   seconds of the talk for a senior audience.

---

## The honesty slide — limitations (state these, don't hide them)

- **Non-determinism** — same input, varying output. Mitigation: deterministic gate
  is authoritative.
- **No completeness guarantee** — Copilot may miss violations. Never the sole
  control.
- **Hallucinated control mappings** — it can cite the wrong NIST control. Mitigation:
  ground it with the curated catalog; the instructions tell it to flag low-confidence
  mappings as "verify against the control catalog."
- **Context-window limits** — large multi-module Bicep may not be fully reviewed in
  one pass.
- **Technical-control slice only** — this addresses resource configuration, not the
  full ATO / System Security Plan narrative + evidence.
- **Data governance** — know your org's Copilot data-handling answer (for an
  internal MS audience: reference the enterprise data protection posture).

---

## Q&A landmines and answers

**Q: Why use a non-deterministic LLM for compliance when Azure Policy / PSRule are
deterministic?**
A: We don't use it *for* compliance enforcement — we use it for interpretation and
remediation *in front of* enforcement. Policy stays the gate. Copilot collapses the
time between "a deterministic tool said no" and "the developer understands why and
has a fix." (This is the anchor sentence.)

**Q: Can this give us an ATO / replace our assessor?**
A: No. It addresses the technical-control configuration slice and accelerates
developer remediation. ATO evidence, SSP narratives, and assessor judgment are
unchanged.

**Q: What stops a developer from merging anyway since Copilot doesn't block?**
A: The deterministic PSRule check is a required status check / branch protection
rule. Copilot informs; the gate enforces.

**Q: How do we keep the catalog correct over time?**
A: It's version-controlled policy-as-text. It changes via PR with review, same as
code. Pair it with PSRule baseline updates.

**Q: Does Copilot send our Bicep to train a model?**
A: Reference the enterprise Copilot data protection terms. Code is not used to train
the foundation models under the business/enterprise agreement. (Confirm current
terms before the talk.)

---

## Pre-call checklist

- [ ] Repo pushed to GitHub; Copilot Code Review enabled on the repo.
- [x] PSRule gate verified locally: **`infra/` = 32 failures**, **`infra-remediated/` = 0 failures**.
      Run it yourself with:
      `pwsh -c "Invoke-PSRule -InputPath ./infra/ -Module PSRule.Rules.Azure -Option ./ps-rule.yaml -Format File -Baseline Azure.Default -Outcome Fail"`
- [ ] Branch / PR staged for the live demo.
- [ ] Backup screen recording of a good Copilot review run.
- [ ] Slides: cost-of-late-feedback, reference architecture (mermaid), control
      catalog table (`docs/control-catalog.md`), honesty slide.
- [ ] Confirm current Copilot enterprise data-handling language.
- [ ] Decide: accept suggestions inline vs. copy from `infra-remediated/`.
