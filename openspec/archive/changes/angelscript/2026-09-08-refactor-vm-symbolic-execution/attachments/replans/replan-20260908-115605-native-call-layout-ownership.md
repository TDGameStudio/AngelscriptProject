---
replan_id: replan-20260908-115605-native-call-layout-ownership
status: applied
source: verification
source_ref: 7.4-shared-VM-1544c10106e24887a5f5c6ff2581f22b
scope: exact-generic-runtime-call-layout-consumer
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 3e2fe059bd1163cd553c0b92ae03aea06b13f355b76a00ed54307cdc68f6c06d
result_tasks_sha256: c238ce078456f7be2db69df4b832ddda787e49c2e5456d2af0315655c6978691
created_at: 2026-09-08T11:56:05.193413+08:00
resume_task: 7.4
---

## Trigger and Evidence

Shared VM discovered 455 cases, 370 Success and 85 assertion failures. Six native binding generation cases pass; the transferred-value cleanup case and other parameterized native consumers reject binding. Parameter offsets were not prepared before metadata freeze: the old binding and lowering paths lazily mutated declarations. Generic reads those declaration offsets directly. Removing mutation exposes the missing runtime layout handoff. The accepted design already owns parameter offsets in executable sidecars and forbids declaration mutation.

## Decision and Impact

Add only as_generic.* to 7.4 Files. Prepare runtime call layouts from immutable signatures into native/executable records and Context/Generic call storage. Migrate actual parameter and argument-size consumers and remove lazy declaration writes from lowering. Do not move VM layout calculation into semantic metadata Freeze. Existing 85 failures supply grouped behavioral evidence; preserve the six passing generation controls and add declaration-layout immutability observations to the parameterized case. Requirements, DAG, selector and all other owners remain unchanged.

## Old Task Disposition and Preserved Work

52 checked nodes remain checked; 7.4 and 11.4 retain their identities and dependencies. Candidate machine graph is byte-identical to the previously validated 54-node graph. Strict validation and task.status precede code changes.

## Diff Snapshot

Task ~7.4 Files only; edges +0/-0; artifacts ~tasks.md and INDEX plus this applied record. Affected pre-change Git status: (clean). Diff stat: (none). No code changed during this replan.

## References and Result

Design section Executable sidecars and atomic publication; raw report 1544c10106e24887a5f5c6ff2581f22b; native-binding-generations replan; original F02/Y01. Resume 7.4.
