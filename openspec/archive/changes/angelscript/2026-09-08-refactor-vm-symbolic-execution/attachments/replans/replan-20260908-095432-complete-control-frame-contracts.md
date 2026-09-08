---
replan_id: replan-20260908-095432-complete-control-frame-contracts
status: applied
source: review
source_ref: reviews/review-20260908-094616-vm-control-contracts-reviewer.md
scope: original-F01-complete-frame-and-control-contracts
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 9b2a908fee824d8c9cbdc1ef4b03cc796d3c3908533da604bf011e0f6bcca195
result_tasks_sha256: a7c9ad97a4e56b1de6d9cb7f75f37a41dfd3c54c1616a6c58b1c2e0547a7d0f9
created_at: 2026-09-08T09:54:32.645615+08:00
resume_task: 6.9
---

## Trigger and Evidence

Immutable snapshot 928178234f4369841827cb8e427176ae76324f6dbe42d2b30aa17c2fa5bb93a5 confirms four original F01 resolution conditions still missing: physical frame direction, body/RET authentication, indirect call ABI and all indexed CFG edges. Review X01-X04 provides concrete source-derived counterexamples; no new malformed program is claimed executed. Current 381/381 VM and 8/8 stomp lifetime proof remains valid for its stated cases.

## Decision

Add four bounded follow-ups with independent proving prefixes: 6.9 physical frame spans (X04), 6.10 body/return ABI (X01), 6.11 explicit indirect contracts (X02), 6.12 complete indexed table edges/runtime bounds (X03). The earliest ready owner is 6.9. Final 11.4 requires all four and still owns V02/V04 supplementary decode controls, full NativeEngine/Baseline acceptance and historical Review reconciliation.

## Impact

Requirements remain unchanged. Design clarifies one actual frame coordinate, per-PC cached indirect contracts and indexed bounds, and exact return pops. No implicit scope includes Standalone, dormant source, JIT or delegate source authoring. Flat VM test ownership permits only necessary contract fixture migration with preserved independent outcome oracles.

## Old Task Disposition

All 47 completed tasks stay checked. Original 11.4 remains pending and cannot complete until the four new prerequisites are proven. No task is removed or reopened.

## Diff Snapshot

- Task +: 6.9, 6.10, 6.11, 6.12. Task ~: 11.4 prerequisites and review map; current-position text refreshed.
- Edges +: 6.9 after 6.8; 6.10 after 6.9; 6.11 after 6.7/6.10; 6.12 after 6.8/6.9; 11.4 additionally after all four. No edges removed.
- Artifacts ~: tasks.md, design.md, INDEX; new applied Replan. Before plan 47/48, candidate 47/52.
- Existing owned plugin diff at preflight: 21 tracked files, 586 insertions/229 deletions, plus two new admission test files; unrelated parent AGENTS/README/Reference/generated/PullReference/harness-web changes preserved. No implementation changes in this planning step.

## Preserved Work

6.7 and 6.8 retain exact RED/GREEN and final binary inventories in residual-admission-verification.md. The borrowed-constructor issue is resolved by the final stomp and shared VM runs. Historical Review observations are not rewritten.

## References and Result

Candidate validated before tracked writes: 52 unique task IDs, exact graph membership, all dependencies resolve, acyclic; 47 completed/5 pending. Strict portable CLI validation and derived task.status follow. Resume 6.9 grouped RED before implementation.
