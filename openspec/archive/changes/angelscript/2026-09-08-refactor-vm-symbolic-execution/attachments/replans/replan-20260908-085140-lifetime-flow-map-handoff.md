---
replan_id: replan-20260908-085140-lifetime-flow-map-handoff
status: applied
source: implementation
source_ref: 6.8-producer-linker-preflight
scope: verified-lifetime-state-handoff-and-guarded-fixture-ownership
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 812d79d5919f380264e8c5d9fb16a75836d040f46b35a025c0d2665380987bdd
result_tasks_sha256: 835b190a0b0c0042291554ea50b4a222e4633c3d95385fec6d9561d71fde6e7e
created_at: 2026-09-08T08:51:40.185875+08:00
resume_task: 6.8
---

## Trigger and Evidence

The lifetime owner needs 6.7's new local-address stack provenance to identify actual ALLOC and constructor receiver slots. This is a real interface prerequisite absent from the original 6.8 edge list. Context DetermineLiveObjects computes live state from PC-ordered objVariableInfo; simply accepting more branch-specific markers would leave the linker encoding wrong. VMFlowVerificationTests.cpp:121-154 also has a bare Both cleanup on a JZ with no allocation/free, requiring fixture ownership.

## Decision

Add 6.7 as prerequisite to 6.8, own the exact existing guarded fixture, and make the verifier return optional proven object states for linker encoding. Preserve actual Context cleanup machinery: linker emits state differences in physical PC order so the runtime observes the verifier's compatible CFG state at each instruction. Authenticate constructor identity through callable traits and GetMetadataDeclarationKind.

## Impact

Requirements remain constructed-only, exactly-once cleanup and valid exceptional recovery. Tests cover branch bypass, joins, reconstruction loops and source traces. No new runtime service or per-opcode metadata lookup is introduced.

## Old Task Disposition

46 completed nodes preserved. 6.8 stays pending and Ready because 6.7 is already complete; 11.4 remains blocked until 6.8.

## Diff Snapshot

- Task ~: 6.8 interface handoff and one exact fixture path.
- Edge +: 6.8 depends on 6.7; all existing edges retained.
- Artifacts ~: design.md, tasks.md, INDEX; this new immutable record.

## Preserved Work

6.7 has 367/367 VM GREEN, including all twelve new admission cases. No source mutation occurs in this planning step.

## References and Result

Candidate adds an edge only to completed earlier owner 6.7 and preserves all 48 IDs/checkboxes. Strict and derived TaskPlan validation follow. Resume 6.8 grouped RED.
