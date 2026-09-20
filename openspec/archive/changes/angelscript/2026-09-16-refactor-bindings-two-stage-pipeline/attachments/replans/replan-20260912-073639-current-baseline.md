---
replan_id: replan-20260912-073639-current-baseline
status: applied
source: user
source_ref: "2026-09-12 user request to inspect and correct outdated OpenSpec Changes and format"
scope: "angelscript/refactor-bindings-two-stage-pipeline: current-source record maintenance"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: eff5314139b55a3d900d2922addf3f2edfa172d4a6e979f4fd26ac5afc9742e4
result_tasks_sha256: 1d0b483625eb7999c0035eaadfef3c6b7b4a78ea4d9f0d5788df97be9e652383
created_at: 2026-09-12T07:36:39.413519+00:00
resume_task: "0.1"
---

# Applied current-baseline maintenance

## Trigger and Evidence

The archived ownership handoff contains deleted Image paths and stale source hashes. Current SDK compile lifecycle removed MetadataImage. Proposal, design, delta behavior and pending cards now require shared records/publication IDs with distinct TypeInfo per Engine. Task 0.1 owns bounded current binding-consumer adaptation and an executed two-Engine proof before baseline measurements; it no longer treats the old handoff verifier as proof of current source. PreparedBindings is a future record/recipe wrapper produced by 2.4, not an existing SDK API. Broken links into the archived ownership predecessor are retargeted; historical applied replans remain immutable.

## Decision

Update current planning truth against inspected source and completed predecessors. Keep the existing feature scope and planning/implementation phase; retain historical attachments and archive content. Detailed product behavior remains unexecuted.

## Impact

Owned artifacts: `design.md`, `proposal.md`, `tasks.md`, `attachments/INDEX.md`, `specs/angelscript/runtime/binding-engine/spec.md`, `attachments/data/maintenance-20260912.md`. No implementation or current durable spec is changed.

## Old Task Disposition

Every original task is preserved with its permanent ID and original checkbox. Pending cards are revised in place where their source/proof premise is obsolete. Task 0.1 in the binding Change now owns the bounded current-SDK consumer prerequisite; other feature products retain their owners. No task is cancelled, removed or marked complete.

## Diff Snapshot

- Task `~`: current paths, source premise, document-card metadata and resume context in the affected pending cards.
- Task `+/-`: none. DAG edge `+/-`: none; authoritative frontmatter is byte-equivalent to the validated baseline.
- Session candidate delta before this record: 6 files, +137/-96 lines versus the preserved working snapshot, including pre-existing user edits as baseline.
- Artifact `~`: current proposal/design/spec/task/navigation where listed above; `+`: maintenance evidence and this replan.

Affected `git status --short` before adding this replan:

```text
M openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
 M openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/design.md
 M openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/proposal.md
 M openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/specs/angelscript/runtime/binding-engine/spec.md
 M openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/tasks.md
?? openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/maintenance-20260912.md
```

Affected `git diff --stat` (tracked changes, including pre-existing edits):

```text
.../attachments/INDEX.md                           | 18 ++--
 .../refactor-bindings-two-stage-pipeline/design.md | 25 +++---
 .../proposal.md                                    | 11 +--
 .../angelscript/runtime/binding-engine/spec.md     |  6 +-
 .../refactor-bindings-two-stage-pipeline/tasks.md  | 97 ++++++++++++----------
 5 files changed, 85 insertions(+), 72 deletions(-)
```

## Preserved Work

Unrelated uncommitted source, deleted migration documents/corpus, the already removed compile-lifecycle active directory, completed active task evidence, and all pre-existing historical attachments are preserved. Candidate writes required the current file bytes to match the captured baseline before replacement.

## References and Result

See `../data/maintenance-20260912.md` for source authorities and proof limits. Harness strict active validation run `f12458c2491b4760a319240252fd62c4` succeeded: 9/9 Changes valid. All 61 PowerShell proving commands parsed without syntax errors; this does not claim their future UE selections executed. Resume `0.1` through the appropriate existing planning/apply route.
