---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-spec-clause-detail-blocks
captured_at: 2026-09-04T12:26:23+08:00
---

# Workflow Evaluation

## Lifecycle

- Clarification: the user's concrete Markdown example corrected ownership from a Scenario-wide tail to individual behavior-clause list items.
- Planning: the empty next Change was retargeted before planning artifacts existed, then one exact corrective proposal, Task DAG, delta set, issue, and attachment index were created.
- RED: the focused authoring test failed because the maintained contract lacked `behavior-clause list item` ownership.
- GREEN: authoring guidance, the template, workflow prompts, five lifecycle Skills, tests, and four current capabilities were updated and synchronized.

## Friction and corrective actions

- The first implementation interpretation used a shared Scenario-owned block even though Task Cards use list-item-local composition. The correction now states and tests immediate indentation beneath each `GIVEN`, `WHEN`, `THEN`, `AND`, or `BUT` item.
- The first protocol pass rejected prose-only RED evidence. The existing issue was corrected to use explicit `Command` and `Artifact` fields; no additional material issue was created for that immediate formatting correction.

## Verification

- `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`: passed.
- `.agents/skills/harness/tests/Protocol.Tests.ps1`: passed.
- `openspec workflow validate angelscript`: passed.
- Strict current specification and exact Change validation: passed.
- Skill Creator validation for `openspec`, `openspec-continue-change`, `openspec-update-change`, `openspec-sync-specs`, and `openspec-verify-change`: passed.
- Harness Quick: `8` passed, `0` failed.
- `Tools/openspec`: intentionally unchanged.

## Ownership and provenance

- The previous archived Change remains immutable; this Change owns the semantic correction.
- No issue was superseded or transferred.
- Raw command output was observed in the active shell; the bounded first RED is retained in `data/clause-detail-red.md`, and this compact evaluation retains the final aggregate.
