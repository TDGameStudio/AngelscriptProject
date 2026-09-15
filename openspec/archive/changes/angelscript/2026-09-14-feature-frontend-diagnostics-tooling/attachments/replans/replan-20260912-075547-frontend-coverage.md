---
replan_id: replan-20260912-075547-frontend-coverage
status: applied
source: user
source_ref: "2026-09-12 user request: 前端诊断与工具支持，现在好像还缺少挺多的吧，你 replan 下看看"
scope: "Current frontend diagnostic ownership, producer coverage, Builder failure export and native tooling prerequisites"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: 7291adf37f4acc1925f321875836e90df8a17c72a5f12b58e3ea2dd434437796
result_tasks_sha256: 9c8df0425a0f4ab8628ad3108688d9cd3172b95bd972591f06571f6e41ff73a8
created_at: 2026-09-12T07:55:47.466428+00:00
resume_task: 1.1
---

## Trigger and Evidence

User explicitly requested replan of this existing Change. Source inspection demonstrated invalid interfaces, missing independently acceptable products and an incomplete failure boundary; this exceeds an ordinary implementation defect. Plugin HEAD is `ad4d4830bb1b43a3439939bf4fc78aa16ae28d9d` plus existing workspace edits. The current migration inventory records per-file SHA-256 and current paths; the earlier September 5 inventory is preserved verbatim as historical evidence.

- `frontend/Basic/as_diagnostics.h/cpp` stores flat records; nonlocated errors and group/policy ownership are proposed work.
- `as_builder.cpp` Record/HasErrors/RefreshCompileOutput creates 5001 wrappers, scans displayed severity and copies flat arrays. ByteCodeEmitted drops structured emission result fields into a fragment-key string.
- `as_compile_output.h` owns descriptors plus diagnostics, not TypeInfo. The old language-service borrowed-result signature could not fulfill its caller-release lifetime promise.
- `as_builder_stages.h` and CompilationSession hold raw dependency pointers; DefinitionSet offers no input lease that tooling could simply retain.
- `as_ast_context.h` has valid VerifyAndSeal, not a partial tooling-read freeze. Sema call resolution mutates formal state; cursor scope/context requires an explicit separate product.

## Decision

Retain accepted diagnostic, four-query and in-process SDK scope. Establish shared immutable diagnostic snapshots, explicit owned definition-input closure, distinct readable-partial AST state, side-effect-free call assessment, isolated cursor preparation and complete Builder/CompileOutput/emission failure export. Keep source-less failure and invalid API request semantics distinct. A checked Format call reports foreign-owner rejection; tests retain/copy valid old payloads and never dereference invalidated views.

No new product-scope decision is required. Existing SDK/CQTest naming conventions supply proposed helper names. No LSP transport/index, new language syntax, VM lowering expansion or TypeInfo ownership reconstruction is added. The inspected emitter budget test is a direct-emitter fixture; plan its real failure through stage ingestion separately from the ordinary Builder path instead of assuming nonexistent Builder emission options.

## Impact

Proposal and design now reflect real ownership and failure boundaries. Tooling and Builder delta specs gain retained attachment, transitive dependency lifetime, exact emission failure and nonpoisoning request scenarios. All original requirements and other four delta files remain intact. Task cards retain accepted details and add Outcome, inspected/prerequisite Interfaces, named source/boundary Cases, scoped Files and one exact proving command.

## Old Task Disposition

- Preserve all original nine IDs unchecked; no completed product work exists to relabel or invalidate.
- ~ 1.1 retains catalog/result/policy and coherent consumer adapters; 1.2 owns rendering. + 1.3 owns positions; + 1.4 owns atomic edits.
- ~ 2.1 retains syntax migration; 2.2 retains semantic causes/recovery/typo suggestions. + 2.3 owns call assessment; + 2.4 owns Builder/CompileOutput/emission integration.
- ~ 3.1 owns analysis lifetime/read freeze/selection; + 3.4 owns isolated cursor preparation. 3.2/3.3 retain actual query outcomes.
- ~ 5.1 consumes the retained result, renderer and edit applier. ~ 4.1 consumes every product and closes actual branch/fix/query evidence.

## Diff Snapshot

Task delta: + 1.3, 1.4, 2.3, 2.4, 3.4; - none; ~ all original nine cards. DAG +: 1.1 -> 1.4, 1.1 -> 2.3, 1.3 -> 1.2, 1.4 -> 4.1, 1.4 -> 5.1, 2.2 -> 2.4, 2.3 -> 2.2, 2.3 -> 3.4, 2.4 -> 3.1, 2.4 -> 5.1, 3.1 -> 3.4, 3.4 -> 3.2. DAG -: 2.2 -> 3.1, 2.2 -> 5.1, 3.1 -> 3.2.

The following Git snapshot includes the earlier uncommitted format/path maintenance; it is not a claim that all shown hunks originated in this replan. This replan's exact modified paths are proposal, design, tasks, INDEX, current inventory, planning-validation, and the Builder/tooling delta specs; new paths are the historical inventory copy and this record.

```text
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/INDEX.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/planning-validation.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/design.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/proposal.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/ast/core/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/bodies/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/builder/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/declarations/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/source-diagnostics/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/tooling/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/tasks.md
?? openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/diagnostic-migration-inventory-20260905.md
?? openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/maintenance-20260912.md
?? openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/replans/replan-20260912-073639-current-baseline.md
```

```text
 .../attachments/INDEX.md                           |  13 +-
 .../data/diagnostic-migration-inventory.md         | 932 ++++++++-------------
 .../attachments/data/planning-validation.md        |   9 +
 .../feature-frontend-diagnostics-tooling/design.md |  35 +-
 .../proposal.md                                    |   7 +-
 .../specs/angelscript/language/ast/core/spec.md    |  15 +-
 .../angelscript/language/frontend/bodies/spec.md   |  14 +-
 .../angelscript/language/frontend/builder/spec.md  |  28 +-
 .../language/frontend/declarations/spec.md         |   9 +-
 .../language/frontend/source-diagnostics/spec.md   |  66 +-
 .../angelscript/language/frontend/tooling/spec.md  |  97 ++-
 .../feature-frontend-diagnostics-tooling/tasks.md  | 752 ++++++++++++++---
 12 files changed, 1186 insertions(+), 791 deletions(-)
```

## Preserved Work

The earlier applied replans remain byte-for-byte immutable. Historical talks/knowledge retain their provenance. The pre-replan inventory is copied verbatim. Original nine task IDs remain pending; no source/test implementation or other Change is changed. No current-spec sync, UE run, archive, commit, push or workspace operation occurred. Local staging validated the candidate graph and cards before tracked publication and guarded against overwriting concurrent edits.

## References and Result

- Strict `openspec.validate angelscript/feature-frontend-diagnostics-tooling --strict --json` through Harness: passed, zero issues; RunId `bda677d0f4d54f2e86d7ed29aebe858d`.
- Harness `task.status` for this Change: succeeded; 14 pending nodes, Ready `1.1` and `1.3`, resume `1.1`; RunId `4e19d42048c141c09c32742507ff3428`.
- Candidate preflight: graph keys/IDs match, no cycles, nine IDs preserved, required card sections/cases/interfaces present, placeholder scan clean, INDEX membership bounded, old applied replans unchanged.
- `git diff --check -- openspec/changes/angelscript/feature-frontend-diagnostics-tooling`: passed. Current inventory links findings to source hashes and task owners; planning-validation records the three authoring checks.
- Product verification is intentionally unexecuted: record-only replan does not prove C++ behavior or branch-matrix completion. Later apply observes grouped RED/GREEN and uses each card's impact-scoped Harness command. Baseline dormancy is an integration control; unrelated Harness aggregate/UE full suites are omitted.
