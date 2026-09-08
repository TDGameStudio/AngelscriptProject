---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-08T08:19:54.814150+08:00
reviewed_at: 2026-09-08T08:21:43.448665+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260908-081954-vm-residuals
snapshot_sha256: fee967996643bab573c3e6ece2a7c197952c9da4898fcf298daac49e2b4fccaf
verdict: CHANGES_REQUIRED
---

# VM residual admission re-evaluation

User requested re-evaluation of refactor-vm-symbolic-execution and repair of remaining problems. This inline tests-first Review reads the 1,061 copied files in the assigned read-only snapshot. Parent commit 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa and plugin commit eba731e6f735ef1d09443370b037d8b5fdd592b1 identify the source baseline. Exclusions: unrelated host changes, dormant legacy runtime, Standalone, JIT, and exhaustive recertification of earlier F/P findings in this bounded residual report. No product code or older Review was modified during review.

SDK paths below are relative to Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/. Test paths are relative to Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/.

## W01 — Real function requirements omit the storage contract used by call verification

severity: Required
status: resolved
Location: as_bytecode_image_builder.cpp:276-347; as_bytecode_verifier.cpp:82-124; VMFlowAdmissionTests.cpp:62-73, 109-169.

Original observation: TypeUseValueDwords searches a TypeUse requirement's NativeOffset, defaulting to one DWORD when absent. AddFunctionRequirement interns parameter keys but never emits these TypeUse requirements. The wide-argument tests manufacture the auxiliary requirement themselves, so their GREEN does not prove the actual metadata producer. Real void(double) plus PshC4/CALLSYS/RET therefore still has the source-derived underflow-admission counterexample from V01. Correct PshC8/call/backedge can still leave a phantom DWORD. Link authentication checks the function type-use keys and passing modes but does not authenticate this auxiliary width. The stack state also records only integer heights, so a raw PshC8 is indistinguishable from a reference argument of the same width. These are static counterexamples; this review did not execute them or claim a crash.

Impact: 6.6's wide-width repair only works for its synthetic fixture contract; accepted real metadata and authenticated call-mode requirements remain unproved.

Resolution condition: carry explicit checked storage/category contracts from real detached function metadata through image construction and codec; authenticate them against target metadata before publication. Verify full-width argument consumption and pointer/value categories with actual producer, valid balanced-loop controls, mismatched/absent/oversized facts and decoded-image controls. Retain current narrow, wide and reference cases with honest fixture provenance. V01 remains open; aggregation cannot discharge it.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.1–6.13: real callable storage contracts, complete typed argument consumption and opcode-defined operand/frame/CFG admission. VMCallAdmission, VMManualAdmission and the complete VM admission selections pass. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## W02 — Cleanup sites still do not establish path-sensitive lifetime state

severity: Required
status: resolved
Location: as_bytecode_verifier.cpp:234-279, 350-476; as_bytecode_emitter_lifetime.cpp:42-92; as_bytecode_linker.cpp:523-546; VMFlowAdmissionTests.cpp:251-316.

Original observation: DeclaredLive is a static set. Verification asks only whether each slot has a normal destroy somewhere, then checks pairwise reachability between destroy sites. No per-instruction constructed/live state is propagated. A RET reachable by a branch bypassing the only normal cleanup is admitted; a branch bypassing an Exception init marker and reaching normal destroy is also admitted. A destroy site revisited through a loop is not compared with itself. Conversely two destroy sites separated by legitimate reconstruction are rejected if one can reach the other.

There is also a concrete representation mismatch: the source emitter uses Exception DestroyObject as an init marker and Normal as an uninit marker; linker produces asOBJ_INIT/asOBJ_UNINIT. The positive exclusive-branch test attaches Normal cleanup to JMP instructions with no FREE and declares local zero already initialized, while DisjointNormalAndExceptionCleanupSucceeds attaches both init/uninit at RET. These fixtures cannot prove that runtime destruction or constructed-only admission follows those declarations.

Impact: V03's constructed-only, exactly-once coverage and compatible-join requirements are still open. The prior repair explicitly excluded skipped construction and cannot satisfy the accepted full CFG contract.

Resolution condition: define and implement one consistent image/emitter/linker lifetime transition contract, follow reachable construction/destruction state and guards through branches/loops, require exit coverage, and tie records to real operations. Add skipped construction, branch bypass, repeat destruction, reconstruction loop, exclusive valid cleanup and decoded-image tests; exercise real source scope/unwind/cache oracles as adjacent consumers. Preserve earlier passing counts as historical evidence.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.8/6.12: VMLifetimeAdmission and VMIndexedAdmission reject skipped construction, bypass, repeated destruction and incompatible joins. VMSourceUnwind preserves constructed-only reverse cleanup and return-97 recovery. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Prior V02 and V04

The new source does fix the final-conditional missing fallthrough: both successors call Enqueue, which rejects Count. FinalConditionalFallthroughRejectsAndFinalJumpSucceeds covers JZ and an unconditional jump. The branch is shared with JNZ; a focused decoded/JNZ boundary control would complete the original requested matrix without a new architecture requirement.

The result span no longer multiplies in uint32 or narrows to uint8. It rejects counts above 32768 and validates the full DWORD range. ResultSpanBeyondFrameAndOverflowReject covers 65 in 64 rejection, 65 in 65 acceptance and 0x40000000 rejection. A decoded-image control remains useful to complete V04's stated resolution condition. Neither repair closes W01/W02.

## Verdict and verification story

CHANGES_REQUIRED. Read tests before their producer, verifier, emitter and linker implementations in the immutable snapshot. Exact previous 7/7 evidence is historical; no build or Automation was rerun during this source review. The language-surface completion's later 968-case report is not used to infer missing admission cases. Earlier F/P/R findings require coordinator reconciliation after repair and fresh acceptance. No claim of general sandbox safety is made or required.

## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
