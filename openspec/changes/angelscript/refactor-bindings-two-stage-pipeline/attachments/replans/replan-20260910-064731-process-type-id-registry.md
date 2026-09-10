---
replan_id: replan-20260910-064731-process-type-id-registry
status: applied
source: user
source_ref: "User request: use asCTypeIdRegistry, evaluate UE Component ID references, then replan"
scope: "Process ID registry, host inspection, concurrency and SDK prerequisite alignment"
base_commit: 0f0cf23ee78e563bf93dcf20b43a55381948273d
base_tasks_sha256: 2a5f651092987dad8db35ad0534d686ccfdb81022c3d982dceeee50533f5a976
result_tasks_sha256: 7358352bef9500f8a0a79614a59be8fb1eab4481c8c07c93095b1e5348b2e816
created_at: 2026-09-10T06:47:31+00:00
resume_task: 0.1
---

# Applied asCTypeIdRegistry replan

## Trigger and Evidence

The user selected asCTypeIdRegistry and requested a UE Component ID assessment before replanning. The old no-global-directory boundary is replaced by retained host inspection with independent Engine admission. Source pins and review dispositions are in the SDK Change's attachments/talks/talk-20260910-064731-ue-component-id-assessment.md. No product implementation or concurrency test ran.

## Decision

Use one exported process ID service, checked mutex-protected bundled reservations, weak publication directory entries and graph-only retained leases. Keep publication lifetime and Engine execution authority explicit. Borrow UE issuance/registry concepts without slot reuse, rollover or an unsupported lock-free claim.

## Impact

Revise proposal, affected specification cards, design, tasks and query/index navigation. SDK review is superseded with appended dispositions; its original report and snapshot remain historical evidence. The companion Change receives only SDK terminology/contract alignment. Current specs, plugin code, UE installation and unrelated workspace work remain untouched.

## Old Task Disposition

All 24 IDs, unchecked states, edges and proving selectors preserved. Tasks consume the renamed SDK publication and global-inspection contract; no binding-local allocator is introduced.

## Diff Snapshot

Affected baseline status:

```text
?? openspec/changes/angelscript/feature-types-external-ownership/
?? openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/
```

Baseline diff stat: (empty: both Change directories are untracked planning records)

Artifacts ~ proposal/design/tasks and affected delta/query/index text; + source-hashed assessment and applied replan; ~ SDK review lifecycle with original findings retained. No task is marked complete. Candidate graphs were checked for unique IDs, existing dependencies, acyclicity and preserved completion before canonical writes; strict CLI validation follows application.

## Preserved Work

External original-object sharing; Engine-private source types/specializations; VM/native sidecars and cleanup; canonical symbolic bytecode; shared immutable preparation; existing native/delegate/container repairs; bounded current-spec formatting correction; source-bound downstream handoff. No current-spec sync, build, Automation, benchmark, commit or push.

## References and Result

Resume at task 0.1. The binding entry remains blocked on completed source-bound SDK handoff, not merely on this document update. See tasks.md and attachments/INDEX.md; final validation evidence is appended to the indexed replan-validation report after actual checks.
