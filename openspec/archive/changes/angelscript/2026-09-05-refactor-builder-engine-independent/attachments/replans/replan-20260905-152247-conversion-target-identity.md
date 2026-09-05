---
replan_id: replan-20260905-152247-conversion-target-identity
status: applied
source: implementation
source_ref: implementation/issue-20260905-144517-conversion-target-identity.md
scope: destination-aware conversion Function identity and selection
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 7f44b0952184f82b9d9e42d5175c95292ff0b797246fbe1e4cc104f7a36f0b4c
result_tasks_sha256: 4429432b1d24b31e32b958508a4ad6b8e5c702bee6c73571dde4c387b43c24d9
created_at: 2026-09-05T15:22:47+08:00
resume_task: "4.1"
---

## Trigger and Evidence

The indexed issue shows a conflict between the maintained conversion operators and the unconditional return-only conflict wording. Retained `as_builder.cpp:5851` distinguishes opConv/opImplConv/opCast/opImplCast by return destination; ordinary methods still reject return-only differences. Local Clang 22.1.8 `DeclCXX.h` models CXXConversionDecl as a distinct method declaration, not a cast expression.

The preceding grammar batch is now independently verified: build 8b500d0c18be4c968038d2756591cd73, complete NativeEngine df8e2e24acba4e0ebaa17a1412449c2a, 481/481. Those tests do not cover the destination-aware exception.

## Decision

Keep one fixed stable-key family and add a distinct conversion Function kind whose identity includes its canonical destination TypeUse edge. Use the actual resolved return signature for that edge. Preserve ordinary return-only errors, actual definition validation, explicit/implicit availability, receiver qualification and ambiguity diagnostics. Never fabricate parameter/name text or claim VM execution.

## Impact

Only the stable-identity requirement, corresponding design paragraph and remaining 4.1 integration detail change. The proposal's maintained-semantics objective remains valid. The implementation issue stays open until actual identity/selection tests pass.

## Old Task Disposition

All 13 node IDs and every dependency are retained. The eight completed nodes stay checked; destination-aware integration is unfinished work in Ready 4.1, not invalidation of earlier ordinary identity/registration proof. No Review or separate Change is introduced.

## Diff Snapshot

- Affected status: ` m Plugins/Angelscript`; `?? openspec/changes/angelscript/refactor-builder-engine-independent/`.
- Parent tracked diff stat: one dirty plugin gitlink entry, zero changed submodule commits or tracked line edits. The new Change is untracked and its content is captured in the active artifacts rather than a fabricated Git diff.
- Task `~4.1`: conversion handoff plus current partial batch evidence; Task `+/-`: none.
- DAG edge `+/-`: none. The candidate reuses the validated TaskPlan's 13 nodes/edges and preserves all completion state.
- Artifact `~`: stable-identity delta, design, tasks, issue disposition and INDEX; `+`: this applied record.

## Preserved Work

All existing user edits, 481-case green sources, raw run evidence, dormant runtime/test gates, generated artifacts and prior applied replans remain untouched. Implementation resumes only after strict validation and Ready-state confirmation.

## References and Result

See the indexed conversion issue, stable-identity delta and batch evidence. Resume 4.1; sync/closure still wait for complete grammar/host/cutover work and final acceptance.
