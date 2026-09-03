---
replan_id: replan-20260903-175249-remove-automatic-final-review
status: applied
source: user
source_ref: "User direction during former Final Review snapshot preparation: skip automatic Final Review; repair or replan discovered problems, otherwise archive directly"
scope: automatic Review scheduling, direct closure policy, and the final Task DAG node
base_commit: 2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27
base_tasks_sha256: f554543d1fbce7ad1abaea42475286532b2bbf27d0386a483ab3da680f882f14
result_tasks_sha256: 7feb95120709a9942932d01a183ddfef48ed45b297a89c5a0660ecf9930034f9
created_at: 2026-09-03T17:52:49+08:00
resume_task: "4.1"
---

# Remove Automatic Final Review

## Trigger and Evidence

While Task 4.1's immutable Final Review snapshot was being prepared, the user explicitly rejected automatic asynchronous Final Review as a normal lifecycle phase. The desired path is to diagnose discovered problems directly, repair locally or replan when canonical planning truth is invalid, and otherwise archive after verification. The snapshot operation had not succeeded: no Review file, synthetic commit, or review ref was created, and the user's four pre-staged TestSource renames remained unchanged.

The existing policy was broader than one task: it mandated impact-driven Incident/Final Review in the Hardness entry, closure and attachment rules, OpenSpec verification/archive leaves, regression tests, current capability spec, knowledge, and project instructions. Leaving those surfaces unchanged would make direct archive impossible and preserve the rejected latency.

## Decision

Hardness never starts Review automatically from impact, diff size, task count, a defect, or a verification result. Verified work with no explicit Review closes and archives directly after tasks, evidence, durable-spec sync, attachments, and material issues are ready. No impact classification, placeholder Review, or `Final Review: not required` record is created.

Review remains available only when the user or an external agent explicitly requests it. Such a Review uses the existing detailed review-v2 lifecycle and immutable snapshot, may run asynchronously as an optional execution choice, and must be resolved or superseded before archive. A finding is triaged first: repair a local defect in the current task; replan only when evidence invalidates planning truth.

## Impact

- Replace the pending automatic Final Review node with one direct-closure policy and verification node.
- Update active truth, live Skills/references, project guidance, regression tests, current `hardness/core`, and capability knowledge together.
- Preserve review-v2 format, detailed reports, immutable snapshots, lifecycle timestamps, and closure checks for explicitly requested Reviews.
- Preserve the completed implementation, PS7 Quick, performance, spec-sync, and timing evidence.

## Old Task Disposition

- `1.1` through `3.2`: preserved complete.
- `3.3`: preserved complete for spec sync and its passing strict/Quick evidence; the former review-snapshot output is superseded before materialization.
- `4.1`: remains pending but is replaced from automatic asynchronous Final Review with direct-closure policy synchronization and focused verification.

## Diff Snapshot

```text
Affected status before policy rewrite: 30 tracked workflow/spec files modified, the active Change untracked, and unrelated user-staged TestSource renames preserved outside scope
Affected diff stat before policy rewrite: 30 files changed, 904 insertions, 596 deletions
Task ~: 3.3 wording retains completed evidence and removes the obsolete Final Review handoff
Task ~: 4.1 replaces automatic Final Review with direct-closure policy synchronization and verification
Edge +/-: none; 1.1 -> {1.2,1.3} -> 2.1 -> 3.1 -> 3.2 -> 3.3 -> 4.1 remains valid
Artifact +: this Replan
Artifact ~: proposal.md, design.md, core delta/current spec and knowledge, workflow evaluation, live Review/closure Skills and references, regression tests, AGENTS.md, openspec/config.yaml, tasks.md, attachments/INDEX.md
Artifact -: no Review file or immutable review snapshot is required or retained
```

## Preserved Work

All unified workspace, AgentConfig v2, Git authority, hooks, OpenSpec maintenance, Task Card, Explore/visual, observation, performance, and durable-spec work remains unchanged. No plugin, Unreal implementation, OpenSpec parser/source/package, integration, push, worktree removal, or unrelated main-workspace content enters scope.

## References and Result

- Result Task DAG SHA-256: `7feb95120709a9942932d01a183ddfef48ed45b297a89c5a0660ecf9930034f9`.
- Resume at Task `4.1`, then use direct completed closure and deterministic archive when its focused gates pass.
