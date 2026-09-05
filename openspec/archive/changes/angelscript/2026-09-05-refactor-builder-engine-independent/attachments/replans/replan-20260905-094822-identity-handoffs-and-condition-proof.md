---
replan_id: replan-20260905-094822-identity-handoffs-and-condition-proof
status: applied
source: dependency
source_ref: tasks 2.1 and 3.1 direct-consumer inventory
scope: identity consumer ownership and conditional-grammar verification
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: c039d3edf165bcfa3a417cf17e31559c37da83458723b87e956cd8026a068cc6
result_tasks_sha256: 47ba4ccdb6930a16ff5c7c099063727de37cc93bcd0a38be76901414ac5923e2
created_at: 2026-09-05T09:48:22+08:00
resume_task: "2.1"
---

## Trigger and Evidence

Direct source inspection found that migrating the public identity values necessarily changes frontend as_decl.h, as_type.*, as_ast_projection.cpp, as_compilation_session.cpp, as_frontend_sema.cpp, as_dependency_graph.cpp and as_descriptor_consumer.cpp, plus root as_runtime_type_binding.*. The original 3.1 file boundary did not represent these consumers and would overlap concurrent Parser/session work. Current as_preprocessor.cpp EvaluateCondition only accepts one flag or one negation; no original node independently proved the accepted 0/1, defined, boolean operator and parentheses extension.

## Decision

Keep the accepted behaviour unchanged. Task 3.1 supplies the fixed-key registry ABI and its semantic tests. New 3.3 completes old-consumer migration after declaration syntax 2.2 and stable registry 3.1. Detached metadata 3.2 may then proceed against the tested ABI without waiting on AST consumer migration. New 2.3 owns the missing condition grammar proof after retained-body work 2.1. Actual Parser/Sema header paths are included in their existing owner boundaries.

## Impact

- Add 2.3 for conditional-expression semantics and focused PreprocessorConditions tests.
- Narrow 3.1 to the new fixed-key/registry interface; move old consumer migration to 3.3.
- Add 3.3 with the complete direct-consumer file boundary and a NativeEngine regression justified by shared identity/projection changes.
- Require 2.3 and 3.3 before complete Builder integration 4.1.
- Do not change any language decision, registration/lifetime rule or exclusion.

## Old Task Disposition

- 1.1: preserved; its accepted contracts and validated initial records remain complete.
- 2.1, 2.2, 3.2, 5.1, 5.2, 6.1, 7.1, 7.2: preserved.
- 3.1: preserved for stable-key core; its former consumer-migration work is superseded by new 3.3.
- 4.1: preserved with additional direct prerequisites.

## Diff Snapshot

- Git status before replan: new untracked Change directory; plugin submodule contains dirty user baseline plus this Change's new tests and 2.1 edits. No unrelated root path is edited.
- Task additions: +2.3, +3.3.
- Task updates: ~3.1 interface boundary, ~4.1 prerequisites, exact header path corrections for 2.1/2.2.
- DAG additions: 2.3 <- 2.1; 3.3 <- 2.2,3.1; 4.1 <- 2.3,3.3.
- Artifact changes: ~design.md migration sequencing; ~tasks.md; ~attachments/INDEX.md; +this applied record.
- Parent git diff stat for the plugin gitlink was empty because the submodule HEAD did not change.

## Preserved Work

RED evidence is unchanged: Bodies f7c179af64b94d908fa3bf1adb22cb7f (15 pass, 4 fail), StableIdentity 1f8e5c1c9b21498187b0016b9933cce4 (0 pass, 1 fail), ReflectionDescriptors 7f645d4765d3405e9d04b065fcfcb808 (9 pass, 2 fail). The corrected direct Attr include and current retained-token fixes are preserved. All existing user changes remain untouched.

## References and Result

The candidate adjacency was checked for known IDs, cardinality and cycles before writing. Strict OpenSpec validation and task.status confirm the applied graph. The sole execution truth remains tasks.md; this record is immutable history.
