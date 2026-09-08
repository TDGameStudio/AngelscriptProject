---
replan_id: replan-20260908-110251-manual-image-admission-tests
status: applied
source: user
source_ref: user-request-20260908-105657-manual-bytecode-tests
scope: manual-image-admission-and-allocation-proof
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: ef23a3bef13caccb126e9cea6222569d118a18f1377a899833d66d76e2818b03
result_tasks_sha256: cb0538d1196953a7a194be217f851767afe888ad843950633e4bdf810111bdae
created_at: 2026-09-08T11:02:51.437445+08:00
resume_task: 6.13
---

## Trigger and Evidence

At 2026-09-08 10:56:57 +08:00 the user requested: “可以, 手工构造字节码这块, 你再补充点测试, 看看相关问题”. The existing 6.9–6.12 cases cover identified frame/return/indirect/indexed defects; they do not fully cross-check manually mutated image identity/operand/allocation contracts across direct, codec and atomic linking entries. The final 11.4 Files boundary owns only reconciliation and narrow flow supplements. A separate bounded test/repair owner is needed for the new requested work.

## Decision

Add 6.13 after 6.11/6.12, and make final 11.4 depend on it. Use real manual metadata/images with one-change negative controls, direct/decoded admission comparisons, pre-existing-body preservation and independent temporary-stack allocation bounds. Observe genuine assertions before local fixes; already-valid controls remain GREEN evidence. Invalid bytecode is never executed.

## Impact

Existing F01/F02/F10 requirements are unchanged. No grammar, AST structure, source syntax, dormant runtime, Standalone or JIT feature is added. Exact runtime verifier/image/codec/linker/executable/Context Files allow demonstrated local handoff defects to be repaired. The new test lives only in VMManualAdmissionTests.cpp.

## Old Task Disposition

All 51 completed tasks stay checked. Task 11.4 remains pending with one additional prerequisite. No task is removed or reopened.

## Diff Snapshot

- Task +: 6.13. Task ~: 11.4 dependency and current-position text.
- Edges +: 6.13 after 6.11/6.12; 11.4 after 6.13. No edges removed.
- Artifacts ~: tasks.md and INDEX. New applied Replan; requirements and design remain valid.
- Before: 51/52; candidate: 51/53, 6.13 Ready.
- Affected-path Git status before write:

```text
M openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/INDEX.md
 M openspec/changes/angelscript/refactor-vm-symbolic-execution/design.md
 M openspec/changes/angelscript/refactor-vm-symbolic-execution/tasks.md
```

- Existing affected-path diff summary, including preserved earlier work:

```text
.../attachments/INDEX.md                           | 23 ++++-
 .../refactor-vm-symbolic-execution/design.md       | 26 ++++++
 .../refactor-vm-symbolic-execution/tasks.md        | 98 +++++++++++++++++++++-
 3 files changed, 145 insertions(+), 2 deletions(-)
```

## Preserved Work

Shared VM ce1f9e9161ac4188ae5410c427152626 passed 432/432; stomp indexed group 1c7eb8cebc554f4e9557905bb4b8fa82 passed 12/12 on source inventory de8beb3c681575dfe365aaf9dde1a18f54b82df80e4633b084cdc641fc492cf8. Existing RED/GREEN histories and unrelated dirty paths remain intact. No implementation mutation occurs in this planning operation.

## References and Result

Candidate checked before tracked writes: 53 unique IDs, exact graph membership, resolved dependencies, acyclic graph and 51 checked tasks. Strict portable validation and derived task.status follow. Resume 6.13 test-first implementation; final 11.4 retains complete NativeEngine/Baseline and explicit historical Review re-evaluation.
