---
replan_id: replan-20260902-233654-repair-openspec-081-review-boundaries
status: applied
source: review
source_ref: attachments/reviews/review-20260902-233151-openspec-080.md
scope: openspec-task-graph-input-and-release-review-boundary
base_commit: 4129487f63fab930800a896ae7f932d7bd4e6e70
base_tasks_sha256: 27ed0bf5b2f624723e8be2a3fdeba51336225a0ceb756de2d102492a6bc0c8c4
result_tasks_sha256: 628a14b2077a4671b764e39d1fba2f3284871870141ff769404d47e60d1f2673
created_at: 2026-09-02T23:36:54.6245941+08:00
resume_task: "1.7"
---

# Replan — Repair OpenSpec 0.8.1 review boundaries

## Trigger and Evidence

The independent fixed-snapshot review reproduced two Required defects in the packaged OpenSpec 0.8.0 executable. A valid frontmatter document with one leading UTF-8 BOM was misclassified as legacy and failed with `missing-after`; an unquoted explicit YAML string such as `!!str 1.1` bypassed the promised source-level quoted-ID contract. The review also found an Advisory mismatch between archive-preflight documentation and the deterministic closure/disposition validation already implemented by the CLI.

The source commit, annotated `v0.8.0`, Release EXE, manifest, reproducible-build evidence, and passing tests are internally consistent, so the defects are product-boundary gaps rather than package corruption. Moving or replacing `v0.8.0` would destroy the fixed evidence and is forbidden.

## Decision

- Preserve completed Task `1.6`, source commit `6492eb3`, annotated `v0.8.0`, the distributed 0.8.0 manifest, and its open review as immutable evidence.
- Add Task `1.7` to reproduce both findings with failing parser and CLI tests, accept exactly one leading UTF-8 BOM, enforce lexical quotation rather than deserialized YAML type alone, reconcile archive-preflight documentation, and publish a new deterministic `v0.8.1` snapshot.
- Move Task `1.3` behind `1.7` and review the fixed 0.8.1 snapshot. Do not close or rewrite the 0.8.0 review.
- Update current proposal, design, delta spec, package reference, and downstream bundle version to 0.8.1. Historical reviews, Replans, tags, manifests, and archives remain byte-unchanged.
- Keep Task `2.6` independently Ready because the distributed 0.8.0 parser already supports the valid current frontmatter contract; the 0.8.1 repairs do not change Hardness routing or derived TaskPlan JSON.

## Impact

The DAG grows from 16 to 17 nodes and retains eight completed tasks. Ready work becomes `1.7`, `2.5`, and `2.6`; Task `1.3` is blocked by the new release repair. No completed checkbox is reopened, and no already implemented Hardness or UE work is discarded.

## Old Task Disposition

| Task | Previous state | Disposition | Reason |
|---|---|---|---|
| 1.1, 1.2, 1.4-1.6, 2.1-2.3 | done | preserved unchanged | Their verified outputs remain valid immutable history |
| 1.7 | absent | added and Ready | Own the Required 0.8.0 review repairs and immutable 0.8.1 release |
| 1.3 | pending after 1.6 | dependency changed to 1.7 | The Review Gate must inspect the repaired fixed snapshot |
| 2.5, 2.6 | pending/Ready | preserved Ready | Their UE and Hardness boundaries are independent of the parser repair |
| 2.4, 3.2, 4.1, 4.2 | pending | preserved unchanged | Their dependency boundaries remain true |
| 3.1 | pending | preserved edge; bundle version updated | It must distribute the final reviewed 0.8.1 package |

## Diff Snapshot

```text
affected path/status: 95 worktree entries at trigger; focused current-truth changes under Tools/openspec, OpenSpec package, and this change record
tasks: +1.7; ~1.3 ~3.1; 17 nodes and eight completed checkboxes
edges: +1.6->1.7 +1.7->1.3; -1.6->1.3
review: +review-20260902-233151-openspec-080 (REQUEST_CHANGES, two Required and one Advisory)
artifacts: ~proposal ~design ~delta-spec ~tasks ~INDEX +replan; future ~Tools/openspec ~Skill-package
```

## Preserved Work

All earlier annotated OpenSpec tags, reproducible-build and containment evidence, 0.8.0 parser functionality for valid non-BOM quoted frontmatter, legacy archive compatibility, Hardness `task.status`, active Task Graph migration, completed task states, Workspace/UE work, and every historical attachment remain intact. No patch sidecar is needed because all relevant source and package states are recoverable from Git commits, annotated tags, and manifests.

## References and Result

- `attachments/reviews/review-20260902-233151-openspec-080.md`
- `attachments/replans/replan-20260902-224756-adopt-hardness-frontmatter-task-graph.md`
- Fixed review identity: source `6492eb3f86238d0c445d06d0a980d8630480bfa1`, annotated `v0.8.0`, EXE SHA-256 `7a76b7a030034c4d1252554af6ab8203a891c89ebc44be50e8aa3ced74be2595`.
- Candidate `task.status` validation reports 17 nodes, eight complete, Ready `1.7`/`2.5`/`2.6`, and zero task issues.
- The tasks hash advances from `27ed0bf5b2f624723e8be2a3fdeba51336225a0ceb756de2d102492a6bc0c8c4` to `628a14b2077a4671b764e39d1fba2f3284871870141ff769404d47e60d1f2673`.
