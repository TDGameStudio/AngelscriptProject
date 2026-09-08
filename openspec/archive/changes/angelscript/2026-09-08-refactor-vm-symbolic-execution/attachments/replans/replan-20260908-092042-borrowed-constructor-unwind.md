---
replan_id: replan-20260908-092042-borrowed-constructor-unwind
status: applied
source: verification
source_ref: cb61a0dc77104497861eaeca5a9702c8
scope: borrowed-constructor-ownership-in-verified-unwind
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: fdb9c483259f1f19d8ddc70f272093a0976f214ec36171c43de5f7a858d5209d
result_tasks_sha256: e19ecac71ead7deb47a2d8df57b0b411452e793c8eb6375793361780df1b1bea
created_at: 2026-09-08T09:20:42.520308+08:00
resume_task: 6.8
---

## Trigger and Evidence

Shared VM run 60116d7161cb4574a3364f4d8a9fa83c failed SourceMixedLoopObjectExceptionCache at LinkByteCodeImage and later crashed in the allocator. Single mixed-cache reproduction a83a07af1c3c447b8c202f0707978d45 failed the same admission. Unwind-only 83f9d5ff694045d891a3b320fbe8afb3 also crashed. With -stompmalloc, exact BrokenConstructorDestroysCompletedLocalOnly run cb61a0dc77104497861eaeca5a9702c8 crashes in FMallocStomp::Free from asCContext::CleanStackFrame during Execute.

## Decision

The prior no-Context-change handoff is invalid. Add as_context.cpp to 6.8 to preserve borrowed this/reference arguments and aliases during fallback cleanup. Keep the verifier's constructed-only state, caller ownership of unconstructed allocation and exact destructor/recovery contracts. Correct source return cleanup within existing emitter ownership so one branch cannot consume lexical state needed by another.

## Impact

No requirement is weakened. This is necessary runtime consumption of the verified lifetime boundary, not a new general memory sandbox. Add exact source lifetime regression controls and repeat the same stomp reproduction plus affected VM source/shutdown tests.

## Old Task Disposition

All 46 checked nodes remain checked; 6.8 and 11.4 remain pending. No IDs or edges change.

## Diff Snapshot

Task ~: 6.8 adds one exact Context path and producer/consumer handoff detail. Task +/- and Edge +/-: none. Artifacts ~: design, tasks, INDEX; new Replan and material issue. Existing source diff remains scoped to 6.7/6.8; unrelated host modifications are preserved.

## Preserved Work

Twelve direct/decoded lifetime cases passed aa5ad449c1dc4eee881506deb5137861. Adjacent crashes are not GREEN and have no complete Automation report. Six migrated fixture public identities/oracles remain intact.

## References and Result

See implementation/issue-20260908-092042-borrowed-constructor-unwind.md. Candidate retains the exact DAG and proving selector; explicit required adjacent cases supplement it. Strict validation follows; resume grouped source regression tests before production repair.
