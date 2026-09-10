---
replan_id: replan-20260910-101633-collision-proof-ownership
status: applied
source: subagent
source_ref: attachments/data/authoring-refinement-before.md
scope: "Task 5.5 World-helper move ownership and adjacent caller regression"
base_commit: 0f0cf23ee78e563bf93dcf20b43a55381948273d
base_tasks_sha256: c860b64e4b9934dcaf708845bccf021962bee2f9ba88903e42c02030d4c0edad
result_tasks_sha256: 5d02f54cecca118489df2981a4583e5d016494c906c1714be99b749088db57cc
created_at: 2026-09-10T10:16:33+08:00
resume_task: "1.1"
---

## Trigger and Evidence

The independent consumer connected 5.5's existing requirement to move World-specific convenience behavior with its actual owner, FAngelscriptTypeBindInfoInstallation::InvokeCollisionLineTraceTestByChannel. Direct inspection confirmed the declaration/definition in Core/AngelscriptTypeBindInfoApply.h/.cpp and callers in RuntimeBindingCollisionTests.cpp. The original Files scope omitted those owners and their prerequisite-moved Framework/Runtime location. Its migration-only proving selector also omitted the existing caller regression.

## Decision

Add the exact old Apply paths, bounded Framework/Runtime glob and existing collision test file to 5.5. Limit their edits to the helper move and necessary call wiring. Add RuntimeBindings.Runtime.Collision to the existing Migration.EngineGameplay selection in one fenced proving command on the same frozen binary. Name the recorded System line-test/line-single targets so a direct UWorld call is not mistaken for installed VM proof.

## Impact

This completes file/proof ownership for an already accepted migration outcome; it adds no product feature, task ID or dependency. The caller regression is impact-related, not an unconditional aggregate gate. Other Actors/InputUI fixture rewrites proposed by the exercise are not adopted: their inputs can be adapted into the new migration fixture without broadening this task to unrelated old-fixture changes.

## Old Task Disposition

All 23 tasks remain preserved and unchecked. Only 5.5's owned paths, proof and explanatory boundary change. No completed work is unchecked and no product run is claimed.

## Diff Snapshot

- Affected status remains `?? openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/`; tracked diff stat is empty for this already-untracked Change.
- Task `~`: 5.5; Task `+/-`: none; DAG edge `+/-`: none.
- Artifacts `~`: tasks.md, INDEX and authoring-refinement.md.
- Artifacts `+`: this replan and preserved before/after consumer outputs.
- The earlier applied replan remains immutable; the hashes here continue its result.

## Preserved Work

All product source, existing current specs, product deltas, other Changes and archives remain untouched. The correction is planning-only and does not start implementation.

## References and Result

The follow-up candidate passed isolated strict Change validation before live application; its multiline 5.5 command also passed PowerShell parsing. Exact-workspace checks and the independent exercise comparison are retained in data/authoring-refinement.md. The consumer documents are evidence, not alternative canonical tasks.
