---
replan_id: replan-20260906-115709-source-followup-ownership
status: applied
source: subagent
source_ref: "Source follow-up consistency check of 10.3/10.5 after the user-requested acceptance-gap Replan"
scope: "Exact AST header ownership and executable source default/partial-member oracles"
base_commit: d8343d314f0b948a43a323fc443cf305ff2f5dc3
base_tasks_sha256: 3a477a773f5e81bbfc8ccef9c292d33b971b66e934514405d07c4433dad2e03d
result_tasks_sha256: b6a410c5af79f681373015d23d2a9232dd841f87b5678f2c2494af7f2be5e3a3
created_at: 2026-09-06T11:57:09+08:00
resume_task: "6.1"
---

## Trigger and Evidence

The bounded source consistency check found that task 10.3 permits constructor projection/wire evolution but omitted as_ast_projection.h and as_ast_codec.h from Files. The current headers own the constructor payload and CurrentVersion=8. Task 10.5 also used an undecidable "partially completed arrays where supported" condition without an admitted source-array prerequisite. Original 5.3/design additionally requires rejecting an external default without typed data; that negative needed an explicit follow-up oracle.

These are pending ownership/proof-boundary defects, not product runtime failures. The earlier applied acceptance-gap record remains immutable.

## Decision

Add the two exact AST headers to 10.3. Explicitly test metadata-string-only default omission rejection with no image/publication/callback, paired with success when the same declaration receives an explicit argument. Replace conditional array coverage in 10.5 with precise nested value-member partial construction and destruction order; no new source-array feature is admitted.

## Impact

Only task detail/Files and indexed planning provenance change. Requirement/design contracts, all task IDs/states, incoming edges, verification commands and the user-requested Review remain unchanged.

## Old Task Disposition

Preserve all 19 completed nodes and their evidence. The same 23 follow-ups remain pending. 10.3/10.5 retain their IDs and outcomes with corrected executable ownership/oracles.

## Diff Snapshot

Captured exact affected status:

```text
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/INDEX.md
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/tasks.md
```

git diff --stat is empty for these untracked files, not a content-equality assertion.

- Task + / -: none. Task ~: 10.3 exact header ownership/default rejection; 10.5 explicit partial-member case.
- Edge + / -: none; same acyclic 42-node graph and Ready 6.1.
- Artifact ~: tasks.md and attachments/INDEX.md.
- Artifact +: this applied record; validation evidence records the final saved tasks digest.

## Preserved Work

No product/test source, earlier applied record, Review observation, capability delta or historical task Case/evidence is edited. No runtime test, build, sync, archive or Git publication is performed.

## References and Result

The candidate preserves graph IDs, states, dependencies and verify commands; the original task-body preservation check remains valid. Actual saved hash and final strict/owner checks are recorded in data/acceptance-replan-validation.md. This correction creates no new Review and closes no finding.
