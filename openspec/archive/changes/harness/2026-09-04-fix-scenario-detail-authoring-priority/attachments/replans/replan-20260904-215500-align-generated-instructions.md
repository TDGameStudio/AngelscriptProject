---
replan_id: replan-20260904-215500-align-generated-instructions
status: applied
source: verification
source_ref: openspec instructions specs --change harness/fix-scenario-detail-authoring-priority --json
scope: generated Scenario authoring instructions and maintained overview mirrors
base_commit: fa667c79a421679d4739fec2a18d18730c0bfaad
base_tasks_sha256: a10c31aef701882689a0ae1f9944311f612195272f31e1dfb89c25dd6b82a04e
result_tasks_sha256: e707b285aa72dca3a72e894182f79322ba5644fc01c861e2b9f92e5589610de3
created_at: 2026-09-04T21:55:00+08:00
resume_task: 1.2
---

# Trigger and Evidence

After Task 1.1 passed, generated `openspec instructions specs` output still contained the old rule that limited clause-owned detail to complex clauses and made simple-clause compactness the default. The output proved that `openspec/config.yaml`, which was absent from the original task paths, independently contributes rules to the actual authoring prompt. Search also found the same obsolete summary in `.agents/skills/README.md` and `openspec/README.md`.

# Decision

Preserve completed Task 1.1 and add Task 1.2 to align the live configuration and maintained overview mirrors. Expand the owner test to consume these sources and verify generated instructions no longer contain a conflicting rule. Task 2.1 now depends on Task 1.2.

# Impact

The proposal and design name the live configuration source explicitly. No requirement, parser, validator profile, portable executable, or product-code boundary changes.

# Old Task Disposition

- Task 1.1 remains complete; its RED/GREEN evidence and Skill validation remain valid.
- Task 2.1 remains incomplete and is delayed until the generated prompt is internally consistent.
- New Task 1.2 owns the previously omitted sources and direct regression proof.

# Diff Snapshot

- Path status before the Replan: `M .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`; the active Change directory was untracked as one aggregate path.
- Diff stat before the Replan: `OpenSpecSkill.Tests.ps1 | 84 insertions`; active Change files were not represented in Git diff stat because they were new.
- Task `+ 1.2 Align the actual generated-instruction rule and maintained overview mirrors`.
- DAG edge `~ 2.1: [1.1] -> [1.2]`; DAG edge `+ 1.2: [1.1]`.
- Artifacts `~ proposal.md`, `~ design.md`, `~ tasks.md`, `~ attachments/INDEX.md`, and `~ OpenSpecSkill.Tests.ps1`.

# Preserved Work

All Task 1.1 Skill, reference, workflow, template, test, and validation work is retained. The 24-card current-spec enrichment already applied under incomplete Task 2.1 is retained but cannot complete until Task 1.2 and all final checks pass.

# References and Result

- Source evidence: generated `openspec instructions specs` rules and `rg` results for the obsolete complex-only wording.
- Candidate Task DAG validation passed with Task 1.2 Ready and Task 2.1 waiting on it.
- Resume at Task 1.2.
