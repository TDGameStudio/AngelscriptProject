---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-06T22:30:32.6643094+08:00
reviewed_at: 2026-09-06T22:31:35.8704430+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260906-223032-final-recheck
snapshot_sha256: 2ae22e4e6c0ddfc8681e66284de43170e4a17ee06a839ce6d0fece8e93a7e9b1
verdict: CHANGES_REQUIRED
---

# Acceptance-progress recheck

## Assignment and verification boundary

Explicit user request to continue reviewing implementation for remaining problems. Inline tests-first External Review. Scope: previous R01–R03 verifier findings, adjacent frame validation, current task/final evidence and the old cache failure. This is not exhaustive certification of every VM/AST/native ABI path.

The materialized snapshot contains maintained SDK source, NativeEngine tests, current Change and four acceptance-run reports. SNAPSHOT.json inside snapshot_ref lists per-file SHA-256; its digest is snapshot_sha256. Source copies were hash checked and made read-only. Historical source/binary pairing is reported by the implementer's acceptance artifact, not independently rebuilt or certified by this review. All source findings refer to copies, not later live edits.

44/44 tasks are checked. Two raw NativeEngine reports genuinely say 909/909. Completion counts do not establish the missing negative verifier contracts.

## Critical comparison with previous review

as_bytecode_verifier.cpp has exactly the same SHA-256 in this snapshot and review-20260906-202149-recheck:

1673fe4f4b87fa9140cfe9d94c6887af782dcefda76a533ca756806dc648998e

The previous R01–R03 implementations therefore did not change. Re-reading the functions confirms the defects rather than merely carrying old findings forward. VMFlowPath still has the same six cases and does not contain wide/reference argument, final conditional false-edge or CFG construction-state regression tests.

SDK path prefix below: Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/.
Tests prefix: Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/.

## Findings

### V01 — Wide/reference call argument accounting remains incorrect (prior R01)

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:83–98 and 313–320.
Contract: 6.4/6.5 full signature-derived call storage and modes.

Observation: parameter count is used as consumed DWORD count. TypeUse/PassingMode do not participate. A double/int64 or Win64 reference occupies two DWORDs, not one. Receiver handling does not repair this.

Unexecuted source-derived counterexample: authenticated void(double) requirement; push only PshC4; CALLSYS; RET. Verifier subtracts one and admits undersupplied storage. Conversely, correctly PshC8/call inside a balanced loop leaves one phantom DWORD in the verifier and can reject the valid backedge. Wrong pointer/value mode is not tracked by the integer height state either.

Impact: malformed calls admitted and valid programs rejected. Six narrow-int call tests are insufficient to discharge this contract.

Resolution: derive actual argument/result/receiver storage and modes from authenticated type contracts; add wide/reference underflow and balanced-call-loop controls. Prior R01 is not resolved by aggregate GREEN.

Repair (coordinator, 2026-09-07T00:10+08:00): 6.6. `CallArgumentDwords` consumes TypeUse `NativeOffset` DWORDs for value parameters and `AS_PTR_SIZE` when PassingMode ≠ 0. GREEN `693d8d93192e4e4cac612c9bfdf86683` VoidDoubleCallWithOneDwordPushRejects, VoidDoubleCallWithPshC8SucceedsAndBalancedLoopSucceeds, InRefCallWithOneDwordPushRejects. status remains open until explicit re-review of this snapshot's successor.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.1–6.13: real callable storage contracts, complete typed argument consumption and opcode-defined operand/frame/CFG admission. VMCallAdmission, VMManualAdmission and the complete VM admission selections pass. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### V02 — Final conditional branch still omits its invalid fallthrough (prior R02)

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:348–360, especially 356.
Contract: 6.5 every reachable CFG successor must be valid.

Observation: a final conditional enqueues its explicit jump target but skips the other edge when Index+1 equals Count. The ordinary fallthrough rejection is in a different else branch.

Unexecuted source-derived counterexample: a body with valid local/flag initialization followed by final JZ to a valid earlier instruction; choose a nonzero condition. Taken target is valid, but not-taken PC moves beyond the body and is not rejected. Balanced stack heights do not detect this.

Resolution: validate both conditional successors, rejecting a missing final fallthrough, with final JZ/JNZ tests and a valid unconditional terminal-jump control.

Repair (coordinator, 2026-09-07T00:10+08:00): 6.6. ConditionalJump always enqueues Index+1; out-of-range fallthrough is InvalidJump. GREEN `693d8d93192e4e4cac612c9bfdf86683` FinalConditionalFallthroughRejectsAndFinalJumpSucceeds. status remains open until explicit re-review.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.6/11.4: both final conditional successors are validated; VMFlowAdmission executes direct/decoded final JZ/JNZ rejection and retains valid terminal/backward jump controls. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### V03 — Cleanup remains path-category partitioning, not CFG state validation (prior R03)

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:177–213 and 292–375.
Contract: 6.4/6.5 initialized/live state, compatible branch merges and cleanup coverage.

Observation: InitializedObjectSlots is trusted as one static set. Normal/Exception sets classify duplicate cleanup entries but are never integrated into the CFG worklist, which holds only stack heights. Construction/destruction/guard transitions are not followed.

Unexecuted source-derived counterexamples: remove all cleanup records for a declared live object and end with RET (no coverage check); bypass construction on one branch before reaching cleanup (no construction-state merge); same-slot normal cleanups in mutually exclusive branches are treated as duplicates regardless of targets.

Impact: verifier cannot prove constructed-only and exactly-once cleanup. Passing source destructor traces prove those source fixtures, not admission safety for hand-authored symbolic images.

Resolution: propagate object/guard state through CFG, validate coverage and compatible joins, and add missing-cleanup, skipped-construction and exclusive-branch controls. Two static sets do not fulfill this requirement.

Repair (coordinator, 2026-09-07T00:10+08:00): 6.6. Every InitializedObjectSlot requires a Normal/Both destroy. Duplicate Normal destroys reject only when they share an instruction index or one CFG-reaches the other. GREEN `693d8d93192e4e4cac612c9bfdf86683` LiveSlotWithoutNormalCleanupRejects, ExclusiveBranchNormalDestroysSucceedAndSamePathDuplicatesReject. Skipped-construction ALLOC dataflow is not claimed. status remains open until explicit re-review.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.8/6.12: VMLifetimeAdmission and VMIndexedAdmission reject skipped construction, bypass, repeated destruction and incompatible joins. VMSourceUnwind preserves constructed-only reverse cleanup and return-97 recovery. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### V04 — Result-region span is truncated before validation (new)

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:141–145 and 23–26.
Contract: checked 6.3 full-width frame/result-region bounds and offset arithmetic.

Observation:
- ResultDwords * 4u is computed in asUINT.
- Byte width is clamped to 255 and passed as uint8.
- FrameAccessValid therefore checks at most ceil(255/4)=64 DWORDs, even when the declared result occupies more.

Concrete source-derived counterexample, not executed against native verifier: valid RET-only body, FrameSize=64, Frame.LocalDwords=64, ParameterSize=Frame.ParameterDwords=0, ResultOffset=0, ResultDwords=65. Declared result needs 260 bytes, but checked width becomes 255 and visits slots 0..63. Verification accepts an out-of-frame 65-DWORD result. With ResultDwords=0x40000000, 32-bit byte multiplication wraps to zero and OccupiedDwords(0) checks only one slot.

Tests: FrameCleanupSourceCapturedAndInvalidResultRegionRejects in VMOperandContractsTests.cpp covers ResultDwords=2 at offset 3 in a four-DWORD frame, not >255-byte spans or multiplication overflow.

Impact: malformed frame descriptors receive successful admission; no crash or downstream memory overwrite was experimentally demonstrated in this review.

Resolution: keep full-width DWORD/span arithmetic with checked overflow and direct region-bound comparisons. Reject unsupported oversized results explicitly rather than narrowing the checked size. Add 64/65-DWORD boundary, large count and overflow controls for direct and decoded images.

Repair (coordinator, 2026-09-07T00:10+08:00): 6.6. Result span uses ResultDwords directly; ResultDwords > 32768 rejects before wrap. GREEN `693d8d93192e4e4cac612c9bfdf86683` ResultSpanBeyondFrameAndOverflowReject. status remains open until explicit re-review.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.9/11.4: VMFrameAdmission and VMFlowAdmission use physical signed frame coordinates and full-width span arithmetic, direct/decoded 64/65-DWORD boundaries and safe memory-checked local-edge execution. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Evidence / progress

| Gate | Raw RunId | Result |
| --- | --- | --- |
| NativeEngine first | dfb0594750fd4af89e87b62a31435395 | 909/909 |
| NativeEngine second | 07b76d4ef99344ec8a9eb346a7841067 | 909/909 |
| Baseline | 4d823aa0011443ccbc112e63deeb5fe2 | 2 Succeeded + 1 SucceededWithWarnings; no failures |
| Freeze build (reported identity) | 6b7beb6d8de04188b769b3a06160f06f | Succeeded |

The supplied acceptance artifact records 2436 LogMetaSound warnings for Baseline and DLL/source hashes. The previous 704/704 and 902/902 runs are not substituted for this evidence; neither are two runs summed into 1818 unique tests.

Prior R04 cache evidence gap has progressed: VMCache.TamperedBytesRejectDecode is Success in the new full report. Its source oracle changed from arbitrary midpoint XOR to Bytes[0]=1, testing version/header rejection. This removes the previously observed failure but is not proof of arbitrary payload integrity; keep the test's interpretation precise.

The acceptance table maps F01 to existing operand/flow tests and says its original resolution conditions are satisfied. V01–V04 show why that claim is stronger than the actual evidence. The acceptance report explicitly maps F/P findings but does not reconcile the latest R01–R03 report. Keep task history intact; do not close review findings based solely on 44/44 or 909/909.

## Verification story and verdict

Tests were inspected before implementation, then old/new verifier hashes and exact branches were checked, and raw acceptance reports examined. V01–V04 are static source findings with concrete unexecuted native counterexamples. No UE build, Automation, Quick/Performance/Integration, Standalone or broad regression was rerun: existing evidence was sufficient for this bounded review. No product code, tests, tasks, specs, prior Review, archive or commit was changed.

CHANGES_REQUIRED. Substantial execution/regression progress is real, including full fresh reports, but three previously reported verifier defects remain unchanged and a further result-span defect exists. Repair and exact negative/positive admission evidence are still required before closure.


## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
