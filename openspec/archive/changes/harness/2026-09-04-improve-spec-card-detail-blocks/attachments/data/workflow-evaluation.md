---
record: harness-workflow-evaluation-v1
result: passed
change: harness/improve-spec-card-detail-blocks
captured_at: 2026-09-04T12:07:20.9243136+08:00
---

# Workflow Evaluation

## Lifecycle exercised

The user correction was admitted into one exact Change and one v2 material issue. The repair used a focused authoring RED/GREEN cycle, complete delta-to-current spec synchronization, Skill validation, strict workflow/spec/Change validation, protocol validation, and the public Harness Quick gate in the selected main workspace.

## Findings and corrections

- The prior Scenario Card contract allowed ordinary Markdown in prose but visibly modeled only five fixed quoted labels. It now gives the Scenario heading ownership of a progressive detail block and explicitly supports prose, ordered or unordered lists, examples, and tables.
- The initial new test contained a PowerShell ordered-hashtable parse mistake. That local test-authoring defect was corrected before RED evidence was accepted; the meaningful pre-implementation failure was the missing `> Details:` contract.
- The first Quick run correctly rejected the issue because its RED section lacked a durable evidence reference. A compact indexed RED attachment was added; the focused Protocol gate and the complete Quick profile then passed.
- Four representative current specs now show both unordered and ordered `Details` lists while retaining every unnamed scenario and all existing detail.

## Verification

- Focused `OpenSpecSkill.Tests.ps1`: passed; package safety and Skill package contracts both passed.
- Focused `Protocol.Tests.ps1`: passed with the indexed v2 issue and durable RED reference.
- System `quick_validate.py`: passed for `openspec`, `openspec-continue-change`, `openspec-update-change`, `openspec-sync-specs`, and `openspec-verify-change`.
- Portable OpenSpec: `angelscript` workflow valid; all 5 current specs valid under strict validation; exact active Change valid under strict validation.
- Harness Quick: 8 passed, 0 failed. The successful rerun included Harness, cutover, gate contract, Protocol, Workspace, GitOperations, OpenSpecSkill, and UnrealIntegration.
- `Tools/openspec` and the packaged executable were not modified; `record-v1` remains the project workflow profile.

## Spec synchronization disposition

The complete modified Core authoring requirement and the four named Scenario Cards are present in their current capability specs. Same-name cards were replaced whole, all unnamed current behavior was preserved, and no delta-operation header entered a current spec.

## Outcome

Scenario authoring now has the same progressive readability the user expected from Task Cards: a compact behavioral spine when simple, or one visible Scenario-owned detail block when richer durable explanation is useful. The block never becomes a second Task DAG or execution record.
