---
replan_id: replan-20260912-073639-current-baseline
status: applied
source: user
source_ref: "2026-09-12 user request to inspect and correct outdated OpenSpec Changes and format"
scope: "angelscript/refactor-testing-unified-framework: current-source record maintenance"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: f36277691543c0bcd9e4f7cc7b842fc22c702b255e774782e5b75fa3f85ae324
result_tasks_sha256: 61adabba8719e628f424e03b012bd4009f840895e1e5ac54f34e90d2e2240269
created_at: 2026-09-12T07:36:39.413519+00:00
resume_task: "1.1"
---

# Applied current-baseline maintenance

## Trigger and Evidence

Five delta files produced 16 strict diagnostics from two-space continuations. Clause ownership is normalized. The installed angelscript-test-guide skill is physically .agents/skills/angelscript-test; future tasks update that owner and its current cqtest.md rather than creating a duplicate skill. Builder/SDK predecessors are archived. The removed parent TestSource/Generation tools are historical algorithm evidence, not live compatibility consumers to recreate; new plugin-owned SourceHistory and bounded catalog fixtures retain their own acceptance. Missing implementation/design details are not filled with invented current APIs.

## Decision

Update current planning truth against inspected source and completed predecessors. Keep the existing feature scope and planning/implementation phase; retain historical attachments and archive content. Detailed product behavior remains unexecuted.

## Impact

Owned artifacts: `design.md`, `tasks.md`, `attachments/INDEX.md`, `specs/angelscript/testing/authoring/spec.md`, `specs/angelscript/testing/baseline/spec.md`, `specs/angelscript/testing/data-driven/spec.md`, `specs/angelscript/testing/source-history/spec.md`, `specs/angelscript/testing/test-code/spec.md`, `attachments/data/maintenance-20260912.md`. No implementation or current durable spec is changed.

## Old Task Disposition

Every original task is preserved with its permanent ID and original checkbox. Pending cards are revised in place where their source/proof premise is obsolete. Task 0.1 in the binding Change now owns the bounded current-SDK consumer prerequisite; other feature products retain their owners. No task is cancelled, removed or marked complete.

## Diff Snapshot

- Task `~`: current paths, source premise, document-card metadata and resume context in the affected pending cards.
- Task `+/-`: none. DAG edge `+/-`: none; authoritative frontmatter is byte-equivalent to the validated baseline.
- Session candidate delta before this record: 9 files, +119/-62 lines versus the preserved working snapshot, including pre-existing user edits as baseline.
- Artifact `~`: current proposal/design/spec/task/navigation where listed above; `+`: maintenance evidence and this replan.

Affected `git status --short` before adding this replan:

```text
M openspec/changes/angelscript/refactor-testing-unified-framework/attachments/INDEX.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/design.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/specs/angelscript/testing/authoring/spec.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/specs/angelscript/testing/baseline/spec.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/specs/angelscript/testing/data-driven/spec.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/specs/angelscript/testing/source-history/spec.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/specs/angelscript/testing/test-code/spec.md
 M openspec/changes/angelscript/refactor-testing-unified-framework/tasks.md
?? openspec/changes/angelscript/refactor-testing-unified-framework/attachments/data/maintenance-20260912.md
```

Affected `git diff --stat` (tracked changes, including pre-existing edits):

```text
.../attachments/INDEX.md                           |  6 ++
 .../refactor-testing-unified-framework/design.md   |  4 +-
 .../specs/angelscript/testing/authoring/spec.md    |  3 +-
 .../specs/angelscript/testing/baseline/spec.md     |  3 +-
 .../specs/angelscript/testing/data-driven/spec.md  |  6 +-
 .../angelscript/testing/source-history/spec.md     |  3 +-
 .../specs/angelscript/testing/test-code/spec.md    |  9 +-
 .../refactor-testing-unified-framework/tasks.md    | 97 +++++++++++++---------
 8 files changed, 80 insertions(+), 51 deletions(-)
```

## Preserved Work

Unrelated uncommitted source, deleted migration documents/corpus, the already removed compile-lifecycle active directory, completed active task evidence, and all pre-existing historical attachments are preserved. Candidate writes required the current file bytes to match the captured baseline before replacement.

## References and Result

See `../data/maintenance-20260912.md` for source authorities and proof limits. Harness strict active validation run `f12458c2491b4760a319240252fd62c4` succeeded: 9/9 Changes valid. All 61 PowerShell proving commands parsed without syntax errors; this does not claim their future UE selections executed. Resume `1.1` through the appropriate existing planning/apply route.
