---
replan_id: replan-20260912-073639-current-baseline
status: applied
source: user
source_ref: "2026-09-12 user request to inspect and correct outdated OpenSpec Changes and format"
scope: "angelscript/feature-memory-gc-observability: current-source record maintenance"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: 2300330017e30dfa084eb2e292a5b74206f3d86a535c740d96d63e3a6753029c
result_tasks_sha256: 8255cfbe8c2f9bbc2bae471f7e3439b450086086879ae9f50041ff3a040fa051
created_at: 2026-09-12T07:36:39.413519+00:00
resume_task: "1.1"
---

# Applied current-baseline maintenance

## Trigger and Evidence

The September 6 collector-instrumentation target conflicts with the accepted pending native-GC removal. The proposal and planning node now target final release, retained cycles and shutdown drain, with UE GC/schema/tombstone observations separate. Native collector metrics become unavailable after removal. The collector still exists today: this update neither claims deletion nor runs instrumentation. Historical research and metrics matrices are retained verbatim and are superseded where they prescribe native collector probes.

## Decision

Update current planning truth against inspected source and completed predecessors. Keep the existing feature scope and planning/implementation phase; retain historical attachments and archive content. Detailed product behavior remains unexecuted.

## Impact

Owned artifacts: `proposal.md`, `tasks.md`, `attachments/INDEX.md`, `attachments/data/maintenance-20260912.md`. No implementation or current durable spec is changed.

## Old Task Disposition

Every original task is preserved with its permanent ID and original checkbox. Pending cards are revised in place where their source/proof premise is obsolete. Task 0.1 in the binding Change now owns the bounded current-SDK consumer prerequisite; other feature products retain their owners. No task is cancelled, removed or marked complete.

## Diff Snapshot

- Task `~`: current paths, source premise, document-card metadata and resume context in the affected pending cards.
- Task `+/-`: none. DAG edge `+/-`: none; authoritative frontmatter is byte-equivalent to the validated baseline.
- Session candidate delta before this record: 4 files, +60/-20 lines versus the preserved working snapshot, including pre-existing user edits as baseline.
- Artifact `~`: current proposal/design/spec/task/navigation where listed above; `+`: maintenance evidence and this replan.

Affected `git status --short` before adding this replan:

```text
M openspec/changes/angelscript/feature-memory-gc-observability/attachments/INDEX.md
 M openspec/changes/angelscript/feature-memory-gc-observability/proposal.md
 M openspec/changes/angelscript/feature-memory-gc-observability/tasks.md
?? openspec/changes/angelscript/feature-memory-gc-observability/attachments/data/maintenance-20260912.md
```

Affected `git diff --stat` (tracked changes, including pre-existing edits):

```text
.../attachments/INDEX.md                           | 10 ++++++++--
 .../feature-memory-gc-observability/proposal.md    | 22 +++++++++++-----------
 .../feature-memory-gc-observability/tasks.md       | 20 +++++++++++++-------
 3 files changed, 32 insertions(+), 20 deletions(-)
```

## Preserved Work

Unrelated uncommitted source, deleted migration documents/corpus, the already removed compile-lifecycle active directory, completed active task evidence, and all pre-existing historical attachments are preserved. Candidate writes required the current file bytes to match the captured baseline before replacement.

## References and Result

See `../data/maintenance-20260912.md` for source authorities and proof limits. Harness strict active validation run `f12458c2491b4760a319240252fd62c4` succeeded: 9/9 Changes valid. All 61 PowerShell proving commands parsed without syntax errors; this does not claim their future UE selections executed. Resume `1.1` through the appropriate existing planning/apply route.
