---
replan_id: replan-20260912-073639-current-baseline
status: applied
source: user
source_ref: "2026-09-12 user request to inspect and correct outdated OpenSpec Changes and format"
scope: "angelscript/feature-delegates-ue-interop: current-source record maintenance"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: f1048fb5f53b9cc18820f325eb3b27e6e1f2875a519be8b72562c6b19a25cd1e
result_tasks_sha256: 9803345bc6fa4823f2aff60e5563d913fd6b034340e0926fbafee00d2de08bdf
created_at: 2026-09-12T07:36:39.413519+00:00
resume_task: "1.1"
---

# Applied current-baseline maintenance

## Trigger and Evidence

The language-surface and VM owners are completed archives. The public description no longer advertises escaping closures; named callable/explicit-payload scope is retained. Pending source scopes follow the runtime-owned SDK and six frontend phases. Detailed design and delta authoring remain task 1.1; the record is not promoted to an implemented feature.

## Decision

Update current planning truth against inspected source and completed predecessors. Keep the existing feature scope and planning/implementation phase; retain historical attachments and archive content. Detailed product behavior remains unexecuted.

## Impact

Owned artifacts: `change.yaml`, `proposal.md`, `tasks.md`, `attachments/INDEX.md`, `attachments/data/maintenance-20260912.md`. No implementation or current durable spec is changed.

## Old Task Disposition

Every original task is preserved with its permanent ID and original checkbox. Pending cards are revised in place where their source/proof premise is obsolete. Task 0.1 in the binding Change now owns the bounded current-SDK consumer prerequisite; other feature products retain their owners. No task is cancelled, removed or marked complete.

## Diff Snapshot

- Task `~`: current paths, source premise, document-card metadata and resume context in the affected pending cards.
- Task `+/-`: none. DAG edge `+/-`: none; authoritative frontmatter is byte-equivalent to the validated baseline.
- Session candidate delta before this record: 5 files, +68/-28 lines versus the preserved working snapshot, including pre-existing user edits as baseline.
- Artifact `~`: current proposal/design/spec/task/navigation where listed above; `+`: maintenance evidence and this replan.

Affected `git status --short` before adding this replan:

```text
M openspec/changes/angelscript/feature-delegates-ue-interop/attachments/INDEX.md
 M openspec/changes/angelscript/feature-delegates-ue-interop/change.yaml
 M openspec/changes/angelscript/feature-delegates-ue-interop/proposal.md
 M openspec/changes/angelscript/feature-delegates-ue-interop/tasks.md
?? openspec/changes/angelscript/feature-delegates-ue-interop/attachments/data/maintenance-20260912.md
```

Affected `git diff --stat` (tracked changes, including pre-existing edits):

```text
.../attachments/INDEX.md                           |  6 +++
 .../feature-delegates-ue-interop/change.yaml       |  2 +-
 .../feature-delegates-ue-interop/proposal.md       |  2 +-
 .../feature-delegates-ue-interop/tasks.md          | 58 ++++++++++++----------
 4 files changed, 40 insertions(+), 28 deletions(-)
```

## Preserved Work

Unrelated uncommitted source, deleted migration documents/corpus, the already removed compile-lifecycle active directory, completed active task evidence, and all pre-existing historical attachments are preserved. Candidate writes required the current file bytes to match the captured baseline before replacement.

## References and Result

See `../data/maintenance-20260912.md` for source authorities and proof limits. Harness strict active validation run `f12458c2491b4760a319240252fd62c4` succeeded: 9/9 Changes valid. All 61 PowerShell proving commands parsed without syntax errors; this does not claim their future UE selections executed. Resume `1.1` through the appropriate existing planning/apply route.
