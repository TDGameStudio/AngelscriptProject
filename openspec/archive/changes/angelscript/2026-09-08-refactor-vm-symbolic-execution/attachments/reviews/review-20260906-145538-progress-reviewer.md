---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-06T14:55:38+08:00
reviewed_at: 2026-09-06T14:57:55.1167638+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260906-145538-progress
snapshot_sha256: 64b78bd1a835059f7bd728194acfd021b5ef4520ba88512b8cd3d1a676d8e95c
verdict: CHANGES_REQUIRED
---

# Implementation progress External Review

## Assignment and limits

User requested review of implementation progress, not implementation, plan changes or final closure. Inline review of the materialized source/requirements/test snapshot indexed in data/review-20260906-145538-progress-snapshot.md. That manifest binds every reviewed file; live edits after capture do not redefine findings. Source was reviewed tests first, then verifier/executable ownership/linker/Context consumers. Prior review remains historical open input and is not rewritten or resolved here.

Scope concentrates on newly checked tasks 6.1–8.1 and evidence for work in progress 8.2. This is not exhaustive certification of all VM opcodes or frontend code. Existing raw run results are evidence of those executed binaries, not proof that all captured dirty files were in those binaries. No build, UE execution, broad regression or native crash experiment was started by this review.

## Progress that is real

The captured tasks contain 42 nodes: 26 checked, 16 unchecked. Original 19 checked nodes are historical slices with follow-up acceptance ownership; they are not proof that the complete original wording is fulfilled.

- 6.1–6.4: expanded image contracts, deterministic wire records, operand/frame checks and a stack-height CFG pass exist.
- 7.1: separate asCExecutableFunction records own code and optional native descriptors; frozen scriptData mutation was removed from normal lowering.
- 7.2: candidate lowering precedes a locked publication commit; explicit schema/signature/property comparisons and late-failure tests were added.
- 8.1: new native ABI tests cover genuine typed/Generic execution, receiver adjustments and reference effects.
- 8.2 is still unchecked. New dispatch contracts pass, but adjacent existing tests currently fail.
- 8.3–8.6, 9.1–9.3, 10.1–10.5 and 11.1–11.3 remain open. Their planned work is not itself a defect in an explicitly unfinished Change.

## Findings

All paths below are relative to the materialized root. SDK prefix is Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/. Test prefix is Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/.

### P01 — Context does not retain the executable snapshot it dereferences

severity: Required
status: resolved
Location: SDK as_context.cpp:762–768; as_bytecode_linker.cpp:906–910 and 947–950; as_execution_snapshot.cpp:40–52; as_execution_snapshot.h:60–67.
Owner contract: checked task 7.1 explicitly requires Context/call-stack executable references and lifetime until the final runtime lease.

Observation: BindExecutableFor stores a raw published pointer. The publication map also stores raw pointers. Link takes one snapshot reference for its returned result; neither Prepare nor publication acquires a snapshot lease. Snapshot destruction unpublishes then destroys the executable data. Context retains the declaration, which is a different resource.

Source-derived counterexample (not executed): link the valid return-42 fixture; Prepare the Context; release the caller's snapshot reference; Execute or clean/unprepare the Context. The Context's executable pointer now references destroyed storage. Concurrent lookup is also unsafe: FindPublishedExecutable unlocks before a caller can acquire ownership, allowing final Release between lookup and dereference.

Tests: VMExecutableOwnershipTests.cpp:234–254 releases producer metadata/image resources but retains Snapshot until AFTER Context release. All six ownership tests use this safe order, so they do not prove independent Context leases.

Impact: use-after-free on an allowed resource-release ordering and a publication-read/retirement race. Atomic refcount on a snapshot does not help if consumers never acquire it.

Resolution condition: define Engine publication and Context/frame leases explicitly; acquire the owning reference under the publication synchronization boundary, retain it through execution/suspension/cleanup, and release in balanced teardown. Add early caller-snapshot release and synchronized acquire/retire tests. Do not solve this by keeping frozen declarations mutable.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 7.1–7.4/8.7: independent immutable executable/native records, synchronized candidate commit/rollback and Context/frame/snapshot/native/operation ownership. VMExecutableOwnership/AtomicLink/ExecutableLeases/NativeBindingLifetime/RuntimeDrain pass, including nonrecursive missing-code rejection. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### P02 — ActiveScriptData fallback recursively calls itself

severity: Required
status: resolved
Location: SDK as_context.cpp:771–774; caller at 685.
Owner contract: checked 7.1 compatibility Prepare and native/Context reader migration.

Observation: after the executable-data branch, the fallback is `return m_currentFunction ? ActiveScriptData() : nullptr;`. When a current function exists without executable scriptData, it recurses with identical state.

Source-derived counterexample (not executed): Prepare an attached/bound system function directly. Native bindings may exist in nativeInterfaces without a published script body; Prepare sets m_currentFunction then calls ActiveScriptData to size the stack. The fallback cannot terminate. Similar exposure exists on no-code/error cleanup paths. Normal script fixtures all have executable data, masking this branch.

Impact: infinite recursion/stack exhaustion or nontermination instead of supported native Prepare or a typed no-code failure.

Resolution condition: replace self-recursion with the contractually correct nonrecursive absent-code behavior; add direct native Prepare/Execute, missing-code and cleanup coverage.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 7.1–7.4/8.7: independent immutable executable/native records, synchronized candidate commit/rollback and Context/frame/snapshot/native/operation ownership. VMExecutableOwnership/AtomicLink/ExecutableLeases/NativeBindingLifetime/RuntimeDrain pass, including nonrecursive missing-code rejection. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### P03 — Checked flow verification omits dynamic call effects and executable termination

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:248–317, particularly 269–272 and 312–317; as_bytecode_opcode.cpp:93–103.
Owner contract: checked 6.4, which explicitly includes full-signature argument/result modes, stack/register types and complete CFG admission.

Observation: dataflow state is one integer stack height. Unknown/dynamic stack effects (0xFFFF, including calls) are skipped instead of derived from function requirements. No signature argument-width/mode or initialized register state is checked. A final ordinary instruction also exits verification successfully without a return/throw/jump because no successor is enqueued.

Source-derived counterexamples (not executed):
- Take the valid two-argument CALLSYS Add fixture, delete both argument pushes, retain its valid Function requirement and RET. The call does not consume/check its two argument DWORDs in the verifier; the runtime callback may read values never supplied.
- A body containing only PshC4(42), with valid operands/frame, reaches the end of this worklist and is marked validated despite having no terminating control transfer.

Tests: VMFlowVerification has five methods covering PopPtr, unequal heights/backedge, static cleanup and explicit re-verification. It lacks the required wrong-call/return modes, valid signature-sensitive calls and last-instruction fallthrough cases.

Impact: malformed symbolic bytecode is admitted to native/VM execution. This is a correctness boundary even though trusted native callbacks are not a security sandbox.

Resolution condition: derive call effects and result/receiver requirements from authenticated signatures, track required typed initialization state, and validate all possible CFG exits. Add grouped positive and malformed-call/termination tests before treating 6.4 acceptance as proved.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.1–6.13: real callable storage contracts, complete typed argument consumption and opcode-defined operand/frame/CFG admission. VMCallAdmission, VMManualAdmission and the complete VM admission selections pass. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### P04 — Cleanup verification is a flat set check, not path/lifetime validation

severity: Required
status: resolved
Location: SDK as_bytecode_verifier.cpp:129–168; tests VMFlowVerificationTests.cpp:113–170.
Owner contract: checked 6.4 conditional initialization, reverse cleanup and unwind coverage.

Observation: InitializedObjectSlots is converted to a single DeclaredLive set; Destroyed is global to the function's cleanup table. Cleanup.Path and instruction position do not influence that state. TypeSlot checking is bypassed when Requirements is empty.

Source-derived counterexamples (not executed):
- With one initialized object slot, a Normal-only cleanup and a separate Exception-only cleanup at that same slot are rejected as duplicate destruction although their paths are disjoint.
- A cleanup action whose InstructionIndex lies beyond the body is not range checked here.
- The positive guarded-cleanup test actually supplies no guard/dataflow construction and no type requirement, yet receives Succeeded.

Impact: valid disjoint cleanup descriptions can be rejected while invalid cleanup targets/unguarded lifetime claims pass. This cannot prove the task's constructed-only, exactly-once normal/exception guarantees.

Resolution condition: validate target/type references unconditionally, interpret construction and cleanup state per CFG path, merge compatible live states and check normal/exception coverage. Include legitimate disjoint cleanups and malformed target/unconstructed path controls, with runtime destructor traces where relevant.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 6.8/6.12: VMLifetimeAdmission and VMIndexedAdmission reject skipped construction, bypass, repeated destruction and incompatible joins. VMSourceUnwind preserves constructed-only reverse cleanup and return-97 recovery. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

### P05 — Adjacent dispatch regression has two unresolved failures

severity: Required
status: resolved
Location: tests VMDispatchTests.cpp:425 and 510; copied raw run 21854bf8c9e64da9a57535f0fc9d5a61/AutomationReport/index.json.
Owner: in-progress 8.2 and its adjacent compatibility regression. This is not a claim that unchecked 8.2 was marked complete.

Observed execution: VMDispatch prefix reports 14 successful, 2 failed, zero warnings.
- BoundCallUnboundNativeThrows expects link Succeeded, but actual value is 7 (MissingBinding). This may be the intended earlier rejection under the new contract; diagnose and align the old oracle only if requirements confirm it.
- DelegateCaptureReleasesReceiver expects destructor count 1 after releasing one delegate and collecting; actual count is 0. This is a lifetime-oracle failure needing diagnosis, not proof from this review alone of its ultimate cause.

Impact: VMDispatchContracts 6/6 does not establish compatibility of the whole adjacent dispatch group, and no current all-green claim is justified.

Resolution condition: reconcile the missing-binding stage with the accepted contract; diagnose the receiver release failure and preserve independent receiver/lifetime assertions; rerun the complete adjacent dispatch selection and retain exact evidence.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 8.1/8.2, 6.11 and 11.4: VMNativeABI/DispatchContracts/IndirectAdmission and adjacent CallableSDK pass with callback/receiver/value/sentinel/full-signature and cleanup oracles preserved. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Verification story

Copied raw reports checked:

| Group | Run ID | Result |
| --- | --- | --- |
| VMFlowVerification | 8591d2a0148e4d98b21602a299f5e9d3 | 5/5 |
| VMExecutableOwnership | 3135029714f84ac89b373eaf0cdfe254 | 6/6 |
| VMAtomicLink | e37679cfd1c4409c81f08261d32ce204 | 13/13 |
| VMNativeABI | d2c95817809047f0b956788d30b1b6a7 | 7/7 |
| VMDispatchContracts | a8b6f6a72bdc4779bc59d9fcc7f8a9ff | 6/6 |
| VMDispatch (includes Contracts by prefix) | 21854bf8c9e64da9a57535f0fc9d5a61 | 14/16, 2 failures |

Do not add overlapping prefix counts. Historical NativeEngine 704/704 runs predate these changes and remain useful baseline evidence, not fresh full acceptance. P01–P04 are source-inspection findings with concrete unexecuted counterexamples; P05 is directly observed raw automation output, with source/binary digest equivalence not certified.

No Unreal build, Automation, full suite, Quick/Performance/Integration, Standalone or plugin product changes were executed by this review. Existing evidence plus focused source inspection was sufficient to reject full acceptance without expensive duplicate execution.

## Verdict

CHANGES_REQUIRED. There is substantial architecture and test progress, but checked task labels overstate at least verifier and executable lifetime closure. Prioritize the executable lifetime and recursive fallback defects, then complete the verifier's promised dataflow/cleanup proof. Preserve original task/review history; coordinator owns finding triage and any later lifecycle decisions. No code or plan edits are authorized by this report.


## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
