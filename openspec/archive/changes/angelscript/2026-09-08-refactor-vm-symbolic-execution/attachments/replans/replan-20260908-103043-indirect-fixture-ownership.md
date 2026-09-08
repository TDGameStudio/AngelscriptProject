---
replan_id: replan-20260908-103043-indirect-fixture-ownership
status: applied
source: implementation
source_ref: 6.11-existing-callptr-preflight
scope: exact-delegate-dispatch-fixture
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 22128c10807e437bf27981eb3b0f02c4167b6ac7dc284b5bd5387e9f8c954e32
result_tasks_sha256: 1abf91dfd2a9dd654e3e3583794f718f426962b8e7c3807d2d68fb9d58516c26
created_at: 2026-09-08T10:30:43.357544+08:00
resume_task: 6.11
---

## Trigger and Evidence

VMDispatchContractsTests.cpp:371, TwoDelegatesReleaseEachReceiverOnce, emits the old one-operand CallPtr. Task 6.11 explicitly requires migrating all existing indirect-call fixtures, but its Files line omitted this exact producer. The 6.10 shared run b6b922745c5d47beafadd203d2d8c594 confirms its current passing public identity; it will need a receiver-free expected signature for its bound delegates.

## Decision and Impact

Add only VMDispatchContractsTests.cpp to 6.11 Files. Preserve the exact two receiver identities and one destruction per receiver, with real detached callable metadata for the expected shape. No requirement, runtime boundary, task identity, edge, verification selector or completed task changes.

## Old Task Disposition

Preserve all 49 completed tasks and the three pending nodes. Derived ready state remains 6.11/6.12. This is fixture ownership, not a new feature or permission boundary.

## Validation

Before tracked writes, candidate frontmatter graph and every task checkbox/identity are byte-equivalent after newline normalization, and completed count remains 49. TaskPlan was already validated by the portable CLI at 6.10 completion; exact graph equality preserves its membership and acyclicity. Strict Change validation follows. Resume 6.11 grouped RED before implementation.
