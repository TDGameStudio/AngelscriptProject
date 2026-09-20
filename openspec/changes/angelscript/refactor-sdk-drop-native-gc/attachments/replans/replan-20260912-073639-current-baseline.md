---
replan_id: replan-20260912-073639-current-baseline
status: applied
source: user
source_ref: "2026-09-12 user request to inspect and correct outdated OpenSpec Changes and format"
scope: "angelscript/refactor-sdk-drop-native-gc: current-source record maintenance"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: 2a7bf604a47a5c2376df15af5b69cc7b2a750e50ee470359eb62c4baae27205a
result_tasks_sha256: c915ca07959d775691430cc401f5551854a0a4e899e86abe71f2d3c389c44802
created_at: 2026-09-12T07:36:39.413519+00:00
resume_task: "1.1"
---

# Applied current-baseline maintenance

## Trigger and Evidence

SDK scopes use Source/AngelscriptRuntime/angelscript; dormant host files use AngelscriptLSP without renaming the Standalone product. as_gc files are marked as deletions. Current as_scriptengine.h declares vmObjectLeases as a scalar count, not an enumerable drain list: task 2.1 must establish and prove object membership and exactly-once shutdown cleanup within its accepted lifetime scope. Ownership predecessors are archived, so their task records are not future rewrite targets. A real replacement host-schema seam is still required before 3.1 can claim host execution.

## Decision

Update current planning truth against inspected source and completed predecessors. Keep the existing feature scope and planning/implementation phase; retain historical attachments and archive content. Detailed product behavior remains unexecuted.

## Impact

Owned artifacts: `design.md`, `tasks.md`, `attachments/INDEX.md`, `attachments/data/maintenance-20260912.md`. No implementation or current durable spec is changed.

## Old Task Disposition

Every original task is preserved with its permanent ID and original checkbox. Pending cards are revised in place where their source/proof premise is obsolete. Task 0.1 in the binding Change now owns the bounded current-SDK consumer prerequisite; other feature products retain their owners. No task is cancelled, removed or marked complete.

## Diff Snapshot

- Task `~`: current paths, source premise, document-card metadata and resume context in the affected pending cards.
- Task `+/-`: none. DAG edge `+/-`: none; authoritative frontmatter is byte-equivalent to the validated baseline.
- Session candidate delta before this record: 4 files, +58/-22 lines versus the preserved working snapshot, including pre-existing user edits as baseline.
- Artifact `~`: current proposal/design/spec/task/navigation where listed above; `+`: maintenance evidence and this replan.

Affected `git status --short` before adding this replan:

```text
M openspec/changes/angelscript/refactor-sdk-drop-native-gc/attachments/INDEX.md
 M openspec/changes/angelscript/refactor-sdk-drop-native-gc/design.md
 M openspec/changes/angelscript/refactor-sdk-drop-native-gc/tasks.md
?? openspec/changes/angelscript/refactor-sdk-drop-native-gc/attachments/data/
```

Affected `git diff --stat` (tracked changes, including pre-existing edits):

```text
.../attachments/INDEX.md                           | 10 ++++--
 .../refactor-sdk-drop-native-gc/design.md          |  6 ++--
 .../refactor-sdk-drop-native-gc/tasks.md           | 38 ++++++++++++----------
 3 files changed, 31 insertions(+), 23 deletions(-)
```

## Preserved Work

Unrelated uncommitted source, deleted migration documents/corpus, the already removed compile-lifecycle active directory, completed active task evidence, and all pre-existing historical attachments are preserved. Candidate writes required the current file bytes to match the captured baseline before replacement.

## References and Result

See `../data/maintenance-20260912.md` for source authorities and proof limits. Harness strict active validation run `f12458c2491b4760a319240252fd62c4` succeeded: 9/9 Changes valid. All 61 PowerShell proving commands parsed without syntax errors; this does not claim their future UE selections executed. Resume `1.1` through the appropriate existing planning/apply route.
