---
replan_id: replan-20260910-080251-type-plan-review
status: applied
source: review
source_ref: "openspec/changes/angelscript/feature-types-external-ownership/attachments/reviews/review-20260910-080251-type-plan-inline.md"
scope: "Registration closure, failed-query lifetime and acquired output contracts"
base_commit: 0f0cf23ee78e563bf93dcf20b43a55381948273d
base_tasks_sha256: 91203f22cfd99211eb06c615613a447e9933f8bf791ca3566d4d5f18341b22cf
result_tasks_sha256: e5b2e6bb70a42c5aa9db0419d5facbd0f1c7a187056ef53e3e82b284591a5f85
created_at: 2026-09-10T08:06:10+00:00
resume_task: 1.1
---

# Applied review corrections

## Trigger and Evidence

Coordinator reproduced R1-R3 from the immutable review snapshot and its digest. R1 invalidates registration and generation acceptance; R2 exposes an unproved error-path destruction boundary; R3 contradicts output ownership. These affect accepted design/verification contracts and justify a bounded replan. No runtime failure is asserted.

## Decision

Atomically register frozen unclaimed host closure members, retain live dependency IDs and allocate one generation per new Image. Live repeat returns AlreadyRegistered. Invalid/retired/private inputs reject and roll back staged claims/use pins. Keep actual Engine-private rejection in 3.1. Image strongly owns its internal control; reverse references are weak. All temporary graph/control owners survive lock guards on success, rejection, rollback and unwinding. Non-null query output returns InvalidArgument before ID validation without pointer/refcount mutation.

## Impact

Revise SDK design, type-registry delta, tasks and query matrix. Existing host/Engine ownership and binding handoff remain valid. Binding task IDs, contents and DAG are unchanged. No public owner/lease class or new product scope is added.

## Old Task Disposition

All 13 SDK and 24 binding tasks remain unchecked. Refine 2.1, 2.2, 2.4 and 3.1 acceptance in place. No task or DAG edge added/removed; all exact proving commands preserved. Actual private-ownership tests move into their producer group 3.1. Shared closure concurrency and failed-pin cleanup fit the existing GlobalQueries selector.

## Diff Snapshot

Affected-path git status: `?? openspec/changes/angelscript/feature-types-external-ownership/`; dependent index lives in the already-untracked binding Change. git diff --stat is empty for these untracked records.

- Tasks ~ 2.1/2.2/2.4/3.1; tasks +/- none; DAG edges +/- none.
- Artifacts ~ design.md, tasks.md, type-registry delta, query-contract.md, attachment navigation.
- Artifacts + immutable before/after review snapshots, review reports, this applied replan and static validation evidence.

## Preserved Work

All task states, exact proving selectors, unrelated changes, historical snapshots/reviews/replans, allocator bounds, Engine admission, instance GC, binding repairs and required SDK handoff are preserved. Proposal scope remains valid and needs no edit. Candidate Task frontmatter/checklists/commands matched their originals and all 37 commands parsed before canonical application.

## References and Result

Read the indexed initial review for original findings and appended disposition; final review binds a new immutable content snapshot. Resume SDK task 1.1. Binding 0.1 still waits for implemented and verified SDK delivery. Planning verification does not execute the proposed tests.
