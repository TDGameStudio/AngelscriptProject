---
replan_id: replan-20260908-113716-native-binding-generations
status: applied
source: review
source_ref: review-20260908-113117-vm-final-acceptance-reviewer.md#Y01
scope: native-binding-generation-lifetime
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: e67439b374a1841481367c02d2d5bf394383e5e492c5ae3565cbcb2d3f6f1450
result_tasks_sha256: 3e2fe059bd1163cd553c0b92ae03aea06b13f355b76a00ed54307cdc68f6c06d
created_at: 2026-09-08T11:37:16.456969+08:00
resume_task: 7.4
---

## Trigger and Evidence

Immutable Review Y01 demonstrates native rebinding deletes the descriptor that CallGeneric reads after host callback return. It also removes the old binding before allocation succeeds and lacks synchronized live-Engine publication. Accepted design.md already requires immutable native candidate/commit lifetime; the 52 completed tasks do not close that original F02 clause. Final NativeEngine 1061/1061 and Baseline 3/3 are valid for their supplied cases but omit active native rebinding.

## Decision and Impact

Add 7.4 after 7.3/8.6 and make 11.4 depend on it. Use owned immutable descriptor generations, atomic replacement and real retained/reentrant/concurrent/retirement cases. Preserve supported rebinding rather than silently banning an accepted operation. Exact owners include linker, native descriptor consumers, executable and Engine lifetime, and one new test file. No source grammar, AST or new runtime capability is added.

## Old Task Disposition

All 52 checked tasks stay checked. 11.4 remains pending; current product success is retained as pre-Y01 repair evidence. No task identity or completed evidence is removed. The new final report stays CHANGES_REQUIRED/open until its original finding is repaired and re-evaluated.

## Candidate Validation and Resume

Before tracked writes: 54 unique IDs, exact graph membership, resolved dependencies, acyclic graph and 52 completed nodes. New 7.4 is Ready. Strict Change and task.status follow before implementing. The requirements/design are valid; only missing task ownership and final acceptance prerequisite change.
