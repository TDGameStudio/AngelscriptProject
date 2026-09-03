---
issue_id: issue-20260903-111408-change-created-after-implementation-start
status: resolved
source: user
source_ref: "conversation: user asked whether the local refactor had an OpenSpec Change"
affected_tasks: ["1.1", "3.4", "4.3"]
created_at: 2026-09-03T11:14:08+08:00
resolved_at: 2026-09-03T11:43:31+08:00
resolution_ref: "attachments/reviews/review-20260903-113000-exploration-authoring-independent.md; openspec/specs/hardness/core/knowledges/change-registration-checkpoint.md"
---

# Change Created After Implementation Start

## Symptom

The Skill/reference implementation and initial protocol gates existed in the main working tree, but no active OpenSpec Change owned the work. The user asked whether the local refactor had a Change and exposed the missing lifecycle checkpoint before commit.

## Investigation Log

1. The conversation had already completed deep comparison, option selection, a detailed implementation plan, and explicit approval.
2. The coordinator treated that decision-complete handoff plus direct-main authorization as sufficient execution state and began implementation.
3. Initial OpenSpec Skill tests passed; the first Hardness Quick run exposed and repaired an unrelated CRLF-sensitive historical Replan assertion.
4. The user asked whether an active Change existed. Repository status confirmed it did not.
5. Hardness created `hardness/restore-exploration-authoring-contracts` through the project route with run ID `8b08879291f244e6bcd1a6efd5cd4998`, before any commit or archive.
6. Strict validation accepted the recovery record and its canonical Task DAG. OpenSpec Skill and Protocol tests passed, followed by the full PS7 Hardness Quick gate at `5/5`.
7. Self-monitoring then found that the first recovery DAG placed knowledge promotion before independent Review. Applied replan `replan-20260903-112507-order-review-before-knowledge-promotion` preserved all completed work and moved promotion behind Review.
8. Independent fixed-snapshot Review approved all 29 task-owned entries with no Critical, Required, or Advisory finding.
9. The reusable execution checkpoint was promoted to Hardness capability knowledge only after Review; incident chronology remains in this issue.

## Root Cause

The coordinator conflated an accepted decision-complete handoff with a registered OpenSpec Change and did not checkpoint the lifecycle between Explore and Apply. The tracked root README still advertised `openspec-work`, no stage wall, and arbitrary artifact/code order, which contradicted the prepared split lifecycle and made the routing ambiguity durable.

## Disposition

The coordinator created an honest recovery Change, mapped the existing working-tree diff to a canonical Task DAG, repaired every maintained entry point, added an explicit active-Change checkpoint to Hardness, enforced the new issue/INDEX contract, reran all PS7 Skill-only gates, completed independent Review, and promoted only the reusable checkpoint into capability knowledge.

## Evidence

### Failure Evidence (RED)

- Command: `git status --short -- .agents/skills/openspec-explore .agents/skills/hardness .agents/skills/openspec openspec/changes/hardness/restore-exploration-authoring-contracts`
- Run ID: `8b08879291f244e6bcd1a6efd5cd4998`
- Artifact: `change.yaml` records creation at `2026-09-03T03:14:08Z`, after the user detected the already-started working-tree implementation.

### Resolution Evidence (GREEN)

- Command: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
- Artifact: OpenSpec package safety and Skill package tests passed after the active Change and README repairs.
- Command: `pwsh.exe -NoProfile -File .agents/skills/hardness/tests/Protocol.Tests.ps1`
- Artifact: Protocol tests passed with the active issue, exact INDEX registration, strict timestamp/section validation, and immutable archive audit.
- Command: `pwsh.exe -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick`
- Artifact: PS7 Quick reported `5 passed, 0 failed`; Hardness `18547 ms`, gate contract `4863 ms`, Protocol `898 ms`, Workspace `47302 ms`, and OpenSpec Skill `5644 ms`.
- Command: `Invoke-Hardness -Command openspec.validate -ArgumentList @('hardness/restore-exploration-authoring-contracts','--strict','--json')`
- Artifact: strict active validation reported one valid change and zero issues after the applied replan.
- Command: `Get-FileHash -Algorithm SHA256 openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/reviews/review-20260903-113000-exploration-authoring-independent.md`
- SHA-256: `c81e3ffb99dd6bd7c1480f39d4d45191ce9a1b343b2cb7ac44cbeb357f70aad9`; the closed Review approved a 29-entry snapshot with no findings.
- Command: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1; pwsh.exe -NoProfile -File .agents/skills/hardness/tests/Protocol.Tests.ps1`
- Artifact: both post-promotion commands exited `0`; the OpenSpec package/Skill tests and `Protocol.Tests.ps1` accepted the capability knowledge index and resolved active issue.

Archived validation remains a closure task and is not used as issue-resolution evidence.

### Rejected Evidence

The accepted conversation plan was sufficient design input but was rejected as proof of active Change registration or Apply readiness.

### What This Proves

The missing registration was detected before commit, is represented by a canonical active Change and valid Task DAG, and has one resolved material issue preserving the actual recovery chronology. Independent Review approved the repaired contracts, and the reusable checkpoint is promoted without copying incident trivia.

### What This Does Not Prove

It does not prove that implementation originally followed the intended lifecycle, that UE or plugin behavior was tested, or that archived validation has passed before the closure task runs.

## Links

- `openspec/changes/hardness/restore-exploration-authoring-contracts/change.yaml`
- `openspec/changes/hardness/restore-exploration-authoring-contracts/tasks.md`
- `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/replans/replan-20260903-112507-order-review-before-knowledge-promotion.md`
- `openspec/changes/hardness/restore-exploration-authoring-contracts/attachments/reviews/review-20260903-113000-exploration-authoring-independent.md`
- `openspec/specs/hardness/core/knowledges/change-registration-checkpoint.md`
- `.agents/skills/hardness/SKILL.md`
