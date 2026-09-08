---
replan_id: replan-20260908-021143-addon-distribution-consumers
status: applied
source: implementation
source_ref: task-4.1-CheckRemovedAddons-RED-103-violations
scope: task-4.1-direct-library-distribution-consumers
base_commit: 62d15e1ab9721fd12ad85fec55a2fc5569dd6059
base_tasks_sha256: 9f959b9ff5370fc8dee9b7301b2440ceb92255330141285daf8b9f1d9731b065
result_tasks_sha256: 024dc0d3ac919f3928da28e21aed36c901716bea39fa3e8a31ca9cc8286cd682
created_at: 2026-09-08T02:11:43.920277+08:00
resume_task: 4.1
---

## Trigger and Evidence

The new bounded audit passes its five self-controls and fails the unmodified distribution with 103 violations across 201 retained text files, including ThirdParty/README.md:23-49's imported-package inventory and adaptation claims. This README is outside the originally named package subtree. Preflight also finds SUPPORT_MATRIX.md:10/:15 claims for native library execution, and the packaged Examples/Native/hello.as depends exclusively on array/string plus print/assert. Tests/CMake/RunPackageInspection.cmake:61/:131 requires and executes that example. The latter test file is already owned.

## Decision

Add only these three concrete distribution consumers to pending task 4.1: SUPPORT_MATRIX.md, ThirdParty/README.md and Examples/Native/hello.as. Their removal/update is already required by the accepted library dependency-chain boundary. Keep the Standalone project, host/UE adapters and unrelated tests. No standalone build revival is added.

## Impact

The audit and cleanup now cover shipped claims/example dependencies as well as build/source/test wiring. No language/runtime requirement, proving command or graph edge changes.

## Old Task Disposition

Five completed nodes remain checked. Task 4.1 remains pending under its permanent ID. All eight nodes retain their original edges and proving commands.

## Diff Snapshot

- Task ~: 4.1 Files only; task +/-: none; edge +/-: none.
- Artifact ~: tasks.md and attachments/INDEX.md.
- Base affected status: M openspec/changes/angelscript/refactor-language-surface-ue-focused/tasks.md
- Base diff stat: .../refactor-language-surface-ue-focused/tasks.md  | 44 ++++++++++++++++------;  1 file changed, 33 insertions(+), 11 deletions(-)

## Preserved Work

Reflection GREEN `1efd401079c44a7e97f56bef8b8652a4` remains 8/8. The read-only audit's RED and self-control outcomes precede package or consumer deletion. No implementation changed in this planning update.

## References and Result

Candidate comparison before tracked writes proved identical frontmatter, permanent checkbox identities/history and exact proving commands. Resume task 4.1 after strict validation. The reverse patch preserves uncommitted task text.

- [Current tasks](../../tasks.md)
- [Reverse planning patch](../data/replans/replan-20260908-021143-addon-distribution-consumers-before.patch)
