---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260903-212650-missing-original-intent-talk
status: resolved
source: user
source_ref: "conversation: user asked whether the earliest Hardness requirements were implemented and why the dogfooding discovery had not entered a tracked lifecycle"
affected_tasks: ["1.1", "1.2", "2.1", "3.1"]
created_at: 2026-09-03T21:26:50+08:00
resolved_at: 2026-09-04T01:45:00+08:00
resolution_ref: ".agents/skills/hardness/tests/Protocol.Tests.ps1 and Hardness.Tests.ps1 (PASS 2026-09-04T01:41+08:00)"
---

# Preserve the Original Hardness User-Intent Baseline

## Symptom

The archived Hardness work contains focused talks for the Task Graph, unified workspace decisions, exploration markers, and Review scheduling, but no single record preserves the original cross-capability user intent that initiated the broader Harness refactor. Settled behavior is distributed across proposals, designs, specifications, tasks, Replans, and non-durable conversation history, making it unnecessarily difficult to distinguish an intentional deferral from an overlooked requirement.

## Investigation Log

1. The archived `refactor-skill-system` Change contains only the Task Graph talk.
2. The archived `refactor-unified-workspace-core` Change contains only the unified workspace talk.
3. The archived `restore-exploration-authoring-contracts` Change contains marker and Review-scheduling talks.
4. Current Hardness policy already requires selective carryover of non-obvious decisions, but that policy was introduced after the earliest implementation began.
5. The user requested a retrospective audit and explicitly required useful self-hosting discoveries to receive tracked ownership rather than survive only in a final response.
6. This successor Change reconstructed one clearly dated intent baseline without modifying the historical archives or claiming a contemporaneous transcript.

## Root Cause

Early Hardness Changes captured individual design corrections but had no checkpoint for an extended, user-led, cross-capability request whose interacting constraints and rejected interpretations would be flattened across canonical artifacts. The later carryover rule covered non-obvious decisions but did not state when one selective intent baseline was warranted or how to avoid a boilerplate talk for every small Change.

## Disposition

Resolved. The reconstructed talk remains an explicitly dated recovery anchor, while Tasks `1.2` and `2.1` added positive and negative protocol coverage plus the selective major-only carryover guidance. Task `3.1` synchronized that contract without turning routine Changes into talk boilerplate.

## Evidence

### Failure Evidence (RED)

- Command: `rg --files openspec/archive/changes/hardness/2026-09-03-refactor-skill-system/attachments/talks openspec/archive/changes/hardness/2026-09-03-refactor-unified-workspace-core/attachments/talks openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/attachments/talks`
- Artifact: `attachments/talks/talk-20260903-212650-original-hardness-user-intent.md` records the bounded reconstruction and exact durable sources that were absent as one coherent historical baseline.
- `openspec/archive/changes/hardness/2026-09-03-refactor-skill-system/attachments/talks/` contains only the Task Graph decision.
- `openspec/archive/changes/hardness/2026-09-03-refactor-unified-workspace-core/attachments/talks/` contains only the unified workspace decision.
- `openspec/archive/changes/hardness/2026-09-03-restore-exploration-authoring-contracts/attachments/talks/` contains only marker and Review-scheduling decisions.
- `openspec/specs/hardness/core/spec.md` contains selective decision carryover, but no original cross-capability baseline or positive/negative checkpoint fixture.

### Resolution Evidence (GREEN)

- Commands: `pwsh.exe -NoLogo -NoProfile -File .agents/skills/hardness/tests/Protocol.Tests.ps1` and `pwsh.exe -NoLogo -NoProfile -File .agents/skills/hardness/tests/Hardness.Tests.ps1`.
- Results: `Protocol.Tests.ps1: PASS` and `Hardness.Tests.ps1: PASS` on 2026-09-04 at approximately 01:41 +08:00.
- Coverage: positive major-intent carryover, negative routine-work behavior, exact INDEX membership, v2 material-issue closure, workflow-evaluation parsing, and frontmatter-only status inspection.
- Integrated gate: `pwsh.exe -NoLogo -NoProfile -File .agents/skills/hardness/scripts/Test-Hardness.ps1 -Profile Quick` completed `7 passed, 0 failed`.

### Rejected Evidence

- The current conversation is rejected as durable, independently replayable project evidence.
- Copying the full transcript or creating a mandatory talk for every Change is rejected because either path would create a second truth source and routine boilerplate.

### What This Proves

The coherent original-intent baseline remains absent from immutable historical archives by design, while this successor now retains an honest reconstruction and a verified selective checkpoint for future major work.

### What This Does Not Prove

It does not prove that every historical user statement was recovered or that a machine can infer semantic intent from conversation. Admission remains bounded agent/user judgment; automated closure validates only admitted tracked artifacts.

## Links

- `openspec/changes/hardness/close-evolution-feedback-loop/attachments/talks/talk-20260903-212650-original-hardness-user-intent.md`
- `openspec/changes/hardness/close-evolution-feedback-loop/tasks.md`
- `openspec/changes/hardness/close-evolution-feedback-loop/specs/hardness/core/spec.md`
- `openspec/specs/hardness/core/spec.md`
