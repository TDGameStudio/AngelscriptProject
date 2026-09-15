---
replan_id: replan-20260912-073639-current-baseline
status: applied
source: user
source_ref: "2026-09-12 user request to inspect and correct outdated OpenSpec Changes and format"
scope: "angelscript/feature-frontend-diagnostics-tooling: current-source record maintenance"
base_commit: afeff74519a0d81e40702f140503cffe911789c6
base_tasks_sha256: 2602d6a3b1663d42b66b9b48fa9d61caafe1ea7dba462cb921a4b02f0e748432
result_tasks_sha256: 7291adf37f4acc1925f321875836e90df8a17c72a5f12b58e3ea2dd434437796
created_at: 2026-09-12T07:36:39.413519+00:00
resume_task: "1.1"
---

# Applied current-baseline maintenance

## Trigger and Evidence

Six delta files produced 124 strict diagnostics from two-space Scenario detail/continuations. Four-space clause ownership is restored without dropping any Scenario. Source scopes follow the six frontend phases, the renamed Builder implementation and the archived isolated lexer test location. Lambda acceptance is removed from semantic-query examples in accordance with the completed language-surface owner. Host-input ownership now follows DefinitionSet/CompileOutput; the September 5 producer inventory requires a fresh source reconciliation before implementation.

## Decision

Update current planning truth against inspected source and completed predecessors. Keep the existing feature scope and planning/implementation phase; retain historical attachments and archive content. Detailed product behavior remains unexecuted.

## Impact

Owned artifacts: `design.md`, `tasks.md`, `attachments/INDEX.md`, `specs/angelscript/language/frontend/bodies/spec.md`, `specs/angelscript/language/frontend/builder/spec.md`, `specs/angelscript/language/frontend/declarations/spec.md`, `specs/angelscript/language/frontend/source-diagnostics/spec.md`, `specs/angelscript/language/frontend/tooling/spec.md`, `specs/angelscript/language/ast/core/spec.md`, `attachments/data/maintenance-20260912.md`. No implementation or current durable spec is changed.

## Old Task Disposition

Every original task is preserved with its permanent ID and original checkbox. Pending cards are revised in place where their source/proof premise is obsolete. Task 0.1 in the binding Change now owns the bounded current-SDK consumer prerequisite; other feature products retain their owners. No task is cancelled, removed or marked complete.

## Diff Snapshot

- Task `~`: current paths, source premise, document-card metadata and resume context in the affected pending cards.
- Task `+/-`: none. DAG edge `+/-`: none; authoritative frontmatter is byte-equivalent to the validated baseline.
- Session candidate delta before this record: 10 files, +216/-140 lines versus the preserved working snapshot, including pre-existing user edits as baseline.
- Artifact `~`: current proposal/design/spec/task/navigation where listed above; `+`: maintenance evidence and this replan.

Affected `git status --short` before adding this replan:

```text
M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/INDEX.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/design.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/ast/core/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/bodies/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/builder/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/declarations/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/source-diagnostics/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/specs/angelscript/language/frontend/tooling/spec.md
 M openspec/changes/angelscript/feature-frontend-diagnostics-tooling/tasks.md
?? openspec/changes/angelscript/feature-frontend-diagnostics-tooling/attachments/data/maintenance-20260912.md
```

Affected `git diff --stat` (tracked changes, including pre-existing edits):

```text
.../attachments/INDEX.md                           |   6 ++
 .../feature-frontend-diagnostics-tooling/design.md |  10 +-
 .../specs/angelscript/language/ast/core/spec.md    |  15 ++-
 .../angelscript/language/frontend/bodies/spec.md   |  14 +--
 .../angelscript/language/frontend/builder/spec.md  |   9 +-
 .../language/frontend/declarations/spec.md         |   9 +-
 .../language/frontend/source-diagnostics/spec.md   |  66 ++++++++-----
 .../angelscript/language/frontend/tooling/spec.md  |  85 +++++++++--------
 .../feature-frontend-diagnostics-tooling/tasks.md  | 106 +++++++++++----------
 9 files changed, 184 insertions(+), 136 deletions(-)
```

## Preserved Work

Unrelated uncommitted source, deleted migration documents/corpus, the already removed compile-lifecycle active directory, completed active task evidence, and all pre-existing historical attachments are preserved. Candidate writes required the current file bytes to match the captured baseline before replacement.

## References and Result

See `../data/maintenance-20260912.md` for source authorities and proof limits. Harness strict active validation run `f12458c2491b4760a319240252fd62c4` succeeded: 9/9 Changes valid. All 61 PowerShell proving commands parsed without syntax errors; this does not claim their future UE selections executed. Resume `1.1` through the appropriate existing planning/apply route.
