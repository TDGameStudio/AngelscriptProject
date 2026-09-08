---
replan_id: replan-20260908-084348-swap-stack-oracle
status: applied
source: verification
source_ref: a3966f3b048140ca9542c169b27f5665
scope: repair-malformed-existing-SwapPtr-control
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 5a495892c8ec92c267bd25f8adcb2c3006919299e6d221f14536ac99b475b932
result_tasks_sha256: 0d9037612541f59c971520531345792c5268d986dd48283fb8758d78f3ea4ac3
created_at: 2026-09-08T08:43:48.975535+08:00
resume_task: 6.7
---

## Trigger and Evidence

Adjacent VM regression executed 362 cases, 357 Success and five Fail. VMIntegration.MemoryWidthIncAndSwapFamilies failed admission at line 791: its PshV4 (one DWORD) plus PshRPtr (two DWORDs) supplies three DWORDs to SwapPtr, which reads two pointers (four DWORDs). The new stack-width check correctly rejects this existing malformed positive fixture. The independent expected arithmetic result remains nine.

## Decision

Add this exact existing test file to 6.7 ownership and make its swap fixture use two real addresses with balanced pops. Preserve the public scenario and arithmetic oracle. Keep a new explicit undersupplied SwapPtr rejection case in VMCallAdmission. Other adjacent failures are local fixes already in scope: wire golden v3 and RDSPtr guarded runtime-null behavior.

## Impact

Only 6.7 Files changes; no requirement, design, task or edge change. This test is also a final 11.4 file; current repair belongs to the earlier admission owner.

## Old Task Disposition

All 45 checked nodes and three pending nodes preserved.

## Diff Snapshot

- Task ~: 6.7 Files adds VMIntegrationTests.cpp; Task +/- and Edge +/-: none.
- Artifacts ~: tasks.md, INDEX; new Replan. Base task bytes match the previous applied result digest.

## Preserved Work

The seven new call-admission tests passed on build e75f740720934690898252aa086d4750, run 0980c96744584159a0ada119b46cd8d9. The 357 adjacent successes and original hand fixture remain historical evidence; no failure is hidden.

## References and Result

Candidate preserves all IDs, edges, checkbox states and exact proving commands. Strict validation follows. Resume 6.7 and re-execute the same adjacent selection after local repair.
