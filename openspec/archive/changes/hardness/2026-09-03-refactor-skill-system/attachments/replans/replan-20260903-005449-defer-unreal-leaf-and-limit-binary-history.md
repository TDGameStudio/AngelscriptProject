---
replan_id: replan-20260903-005449-defer-unreal-leaf-and-limit-binary-history
status: applied
source: user
source_ref: "Pause unreal-engine-develop during the large project refactor, finish the Hardness core, and avoid repeated openspec.exe commits"
scope: hardness-core-delivery-with-unreal-leaf-extracted
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: a4f94de420e8e06ce452adbec862479f1827b0e2b6f6e4a2ef7efcd481789255
result_tasks_sha256: 2d215a5be6ecaa4bb492c1ed586d5c2ee37bcfcdd5f623ddb558328a747e97bd
created_at: 2026-09-03T00:54:49.5677584+08:00
resume_task: "2.5"
---

# Replan — Defer the Unreal leaf and limit binary history

## Trigger and Evidence

The user explicitly paused `unreal-engine-develop` because the project is undergoing a large refactor and requested that its work move to a later dedicated change. The mixed Harness/UE review and the in-progress scheduling repair showed that the leaf still had material execution semantics to settle. The user also required the parent repository not to accumulate repeated `openspec.exe` snapshots because each binary consumes Git history permanently.

## Decision

- Deliver only the Hardness core: Workspace, OpenSpec routes, Task Graph status, Review/Replan/closure protocols, and retained two-host performance evidence.
- Publish no placeholder UE, execution, JIT, Coverage, Standalone, engine, or toolchain route. Installation health reports only leaves delivered by this snapshot.
- Preserve the complete UE prototype, tests, public wrapper migration, and dependent guides in named stash object `a5c22b287fff34e9af1bf07e1d28c73e97862a31`. Do not merge or review that WIP as part of this change.
- Preserve the original mixed review as historical evidence and supersede it for this delivery. A new fixed-snapshot review covers only Hardness/Workspace core behavior.
- Commit the final validated OpenSpec 0.8.1 Release EXE to the parent exactly once. Earlier candidate releases remain immutable source commits/tags and review records, not parent binary commits.

## Impact

Task `2.3` remains completed as historical prototype work, but its implementation is extracted from the delivery. Task `2.5` now decouples and verifies the Hardness core, Task `2.4` reviews the core fixed snapshot, Task `3.2` excludes UE wrappers and guides, and Task `4.1` runs no UE gate. The 18 stable task IDs and completed checkbox states remain intact; only the affected descriptions, files, verification scope, and `2.5` predecessor change.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1-1.7, 2.1-2.2, 2.6, 3.1 | done | preserved | Their OpenSpec, Workspace, protocol, Task Graph, and package evidence remains in scope |
| 2.3 | done | preserved as historical prototype; output extracted | Completed work remains recoverable, but the current delivery no longer claims the UE leaf |
| 2.5 | Ready | replaced in place | It now removes the unfinished leaf dependency and verifies the core two-host matrix |
| 2.7 | blocked | preserved | Hardness performance evidence remains required after the core decoupling |
| 2.4 | blocked | narrowed | The fixed review covers Hardness/Workspace core rather than the extracted UE surface |
| 3.2 | blocked | narrowed | UE wrapper and guide migration is no longer a current integration responsibility |
| 4.1 | blocked | narrowed | No UE build, suite, PlanOnly, Editor, Smoke, or Standalone validation belongs to this change |
| 4.2 | blocked | preserved | Durable spec sync, closure, archive audit, and explicitly authorized integration remain required |

## Diff Snapshot

```text
delivery subtraction: .agents/skills/unreal-engine-develop/**, 12 Tools/Run*.ps1 wrappers, Documents/Guides/Build.md, Documents/Guides/Test.md, Documents/Tools/Tool.md
recoverable WIP: stash@{0} / a5c22b287fff34e9af1bf07e1d28c73e97862a31, 46 files, +6930/-4025
core changes: Hardness route/health/test contraction; proposal/design/spec/task scope update; performance evidence retained
graph: 2.5 predecessor changes from 2.3 to 2.2; every other edge and all 18 stable IDs remain
binary history: one final parent openspec.exe replacement; no candidate EXE commits
```

## Preserved Work

OpenSpec 0.8.1 source/tag/package/review evidence, Workspace safety, Goal/Current routing, Task Graph parser and status route, Review/Replan protocols, all completed task states, historical reviews/replans, and the user's explicit later-integration authorization remain valid. No plugin C++, UE module, or primary-checkout content is modified by this scope cut.

## References and Result

- `attachments/implementation/deferred-unreal-engine-develop-wip.md`
- `attachments/reviews/review-20260902-harness-ue-final.md`
- `attachments/replans/replan-20260902-235253-add-retained-hardness-performance-evidence.md`
- The task hash advances from `a4f94de420e8e06ce452adbec862479f1827b0e2b6f6e4a2ef7efcd481789255` to `2d215a5be6ecaa4bb492c1ed586d5c2ee37bcfcdd5f623ddb558328a747e97bd`.
