# Applied Registry replan validation

This is planning validation only. Product code, UE installation and current specs were not edited. No UE build, Automation, performance or race test ran; all future product tasks remain unchecked.

## Actual checks

| Change | Strict validation run | Result | Tasks | Complete | Structurally Ready |
| --- | --- | --- | --- | --- | --- |
| angelscript/feature-types-external-ownership | `d51314fe511f4cf5a49f7061ae1418d1` | passed | 13 | 0 | 1.1 |
| angelscript/refactor-bindings-two-stage-pipeline | `084160a83582463cb3256bb72be6b329` | passed | 24 | 0 | 0.1 |

- Candidate task IDs/dependencies/acyclicity/completion preservation were checked before canonical writes. After application, Harness task.status parsed both canonical graphs successfully.
- All 37 task proving commands have exactly one direct Verification command, a Files section and zero PowerShell syntax errors. Syntax validation does not prove future APIs or tests exist.
- New SDK tasks 2.3 and 2.4 provide independently selected Allocation and GlobalQueries proofs. Existing admission/execution/lifetime tasks prove the consuming Engine behavior; final regression runs include all these groups.
- Both attachment indexes were checked for exactly one link per existing attachment, valid targets and the 120-line bound.
- Every earlier review source/spec/design/task pin matches the assigned snapshot; only INDEX differs because the review was indexed after snapshot assignment. Original report body and snapshot manifest remain intact; lifecycle supersession and appended dispositions are explicit.
- Replan result_tasks_sha256 matches each current tasks.md. All unowned files captured in the two Change directories and the parent/plugin tracked diff digests are unchanged.

## Test design added or strengthened

| Group | Independent oracle |
| --- | --- |
| Allocation.Parallel | 8 workers x 128 bundles; exactly 2048 unique type sequences, 3072 unique FunctionIds, 1024 unique generations |
| Allocation.LastBundle | Two competing reservations, exactly one success, checked type/function/generation limits, stable exhausted state |
| GlobalQueries.ConcurrentPublish | 128 pre-frozen original graphs, 8 publishers, exact pointer round-trips, independent type/function counts |
| GlobalQueries.Atomic | Before commit no entries; successful commit exposes initialized whole batch; rejected batch exposes none |
| GlobalQueries.RetireRace / NoCycle | Deterministically force each ordering; valid retained graph or unavailable; final destruction once; no retained Engine/callback deadlock |
| Admission.GlobalPrivate / NoReuse | Shared external identity, distinct private identities, foreign rejection, no reuse after owner teardown |
| Execution.Admission | Global acquisition succeeds; foreign Engine allocation/Prepare/link reject with zero callback entry; owner executes result 42 |
| Lifetime.GlobalRetire | Stop new global acquisition before draining admitted execution; existing graph leases remain readable; other Engine survives |

Workers record results for assertions on the test thread. Tests use barriers/events, bounded completion and unconditional worker cleanup, not sleeps or unbounded joins. Exhaustion seams cannot reset the real Registry. New groups use literal Automation identities, and final reports must prove complete discovery. Existing heavier NativeEngine/RuntimeBindings final regressions remain justified by the shared SDK contract; unrelated Harness suites are not added.

## Changed artifact sizes

Both Change directories are untracked at the baseline commit, so git diff --stat cannot describe their text changes. The following counts compare exact pre-replan bytes retained during this operation with applied files; they are not a source-code diff.

| Path | Added lines | Removed lines |
| --- | --- | --- |
| `openspec/changes/angelscript/feature-types-external-ownership/proposal.md` | 11 | 9 |
| `openspec/changes/angelscript/feature-types-external-ownership/design.md` | 62 | 32 |
| `openspec/changes/angelscript/feature-types-external-ownership/tasks.md` | 172 | 84 |
| `openspec/changes/angelscript/feature-types-external-ownership/attachments/INDEX.md` | 6 | 3 |
| `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/binding-engine/spec.md` | 1 | 1 |
| `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/bytecode/spec.md` | 4 | 4 |
| `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/type-registry/spec.md` | 78 | 20 |
| `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/runtime/vm/spec.md` | 3 | 3 |
| `openspec/changes/angelscript/feature-types-external-ownership/specs/angelscript/language/types/definitions/spec.md` | 7 | 7 |
| `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/proposal.md` | 3 | 1 |
| `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/design.md` | 6 | 4 |
| `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/tasks.md` | 8 | 8 |
| `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md` | 3 | 1 |
| `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/specs/angelscript/bindings/runtime/spec.md` | 1 | 1 |
| `openspec/changes/angelscript/feature-types-external-ownership/attachments/data/query-contract.md` | 22 | 4 |
| `openspec/changes/angelscript/feature-types-external-ownership/attachments/talks/talk-20260910-064731-ue-component-id-assessment.md` | 81 | 0 |
| `openspec/changes/angelscript/feature-types-external-ownership/attachments/reviews/review-20260910-141459-process-typeids.md` | 6 | 1 |
| `openspec/changes/angelscript/feature-types-external-ownership/attachments/replans/replan-20260910-064731-process-type-id-registry.md` | 51 | 0 |
| `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/replans/replan-20260910-064731-process-type-id-registry.md` | 51 | 0 |
