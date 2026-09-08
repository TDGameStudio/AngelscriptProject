---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-08T11:31:17.029902+08:00
reviewed_at: 2026-09-08T11:35:16.596293+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260908-113117-vm-final-acceptance
snapshot_sha256: 510392c18ab2c7bb24e04cbc68c8115b2d1caf5b1c8a0d949f72d3ca2a83c2b1
verdict: CHANGES_REQUIRED
---

## Assignment and inspected evidence

Continuing user-requested final acceptance reconciliation of the fixed snapshot. Tests were read first: frame/return/indirect/indexed/manual/flow admission; executable lease and ownership; native ABI and object lifetime controls. Then verifier, linker/publication, executable snapshot and Context call paths were inspected. The supplied complete NativeEngine 1eb0149a83f74aebbce0a2562955b788 is 1061/1061 Success, zero warnings; Baseline d637b6f4c989452b95eaf85c4bd4c5f8 is 3/3 Success with 2,436 retained MetaSound warnings. No broad run was repeated during review.

Use R for Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source, T for Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine and C for this Change, all inside the assigned immutable copy.

## Y01 — Native rebinding deletes the descriptor still used by an active call

severity: Required
status: resolved
**Locations:** R/as_bytecode_linker.cpp:939, :956–971, :1045–1053; R/as_context.cpp:6090–6168; R/as_execution_snapshot.h:35–38; T/VM/VMExecutableOwnershipTests.cpp:88; C/design.md:231; original F02 resolution condition.

**Original observation:** BindNativeFunction deletes an existing nativeInterfaces descriptor before allocating its replacement, then writes the raw-pointer map without a binding publication lock or shutdown/generation check. ResolveSystemInterface returns a borrowed pointer. CallGeneric caches that pointer before entering host code, invokes the host callback, and then reads sysFunc->cleanArgs after it returns. A callback can synchronously call BindNativeFunction on its own declaration; that deletes the descriptor whose cleanup data the outer call still needs. Concurrent rebinding also races readers. Allocation failure after deletion loses the previous binding. This is separate from the repaired executable-body publication and Context snapshot leases.

**Reproduction/evidence:** the use-after-release path is established by the exact source chain above, not by an executed crash. Existing NativeTwentyPlusTwentyTwoLeavesSysFuncIntfUnchanged proves semantic metadata separation but only binds once. NativePrepareExecuteAddTwentyAndTwentyTwo and the final NativeEngine report likewise supply no active-rebinding lifetime oracle. A safe new assertion can retain the originally acquired binding across a successful replacement and check its original callback/cleanup identity before attempting nested execution; do not use a crash as behavioral RED.

**Impact:** accepted host rebinding can corrupt in-flight cleanup even though a previously linked image and its Context snapshot remain alive. The accepted design explicitly requires native rebinding to follow immutable candidate/commit lifetime rules, so complete F02 closure is not yet justified by 1061 GREEN identities.

**Resolution condition:** prepare and validate a replacement descriptor privately, then publish it atomically only while its owning Engine is live. Preserve the previous binding on any failure. Every active native call/cleanup must own the exact descriptor it began with across reentrant and concurrent replacement; new calls may observe the successfully published replacement. Metadata parameters/signatures stay frozen. Add real tests for original-versus-replacement callbacks and independent parameter cleanup, failed replacement preserving prior execution, concurrent readers/publication and shutdown rejection. Retain grouped assertion RED/GREEN and memory-checking execution where useful, then rerun affected shared native/source consumers and final acceptance with fresh provenance.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Task 7.4: privately prepared shared native generations publish atomically; active/reentrant consumers retain old descriptors and cleanup until final release, invalid replacements preserve 41 and new generations return 42. All seven VMNativeBindingLifetime cases pass; original grouped RED/Stomp proof remains indexed. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Reconciliation and verdict

X01–X04 and the recent W01/W02 paths now have substantive repaired code and direct/decoded test oracles: exact argument/RET widths, signed physical frame spans, per-PC indirect signatures, complete indexed successors/runtime bounds, and path-sensitive construction state. The supplemental 6.13 cases reject duplicate identities, malformed dead tails and forged validation atomically, and independently check a 68-DWORD minimum before deep-stack execution. V02/V04 decoded final-edge/result-span controls are present. These results remain credited.

F02 retains the concrete Y01 native rebinding residual. Earlier F/P/R/V/W/X reports must not all be closed solely from the new aggregate. Remaining historical proof is retained as supplied evidence; a new final snapshot after this repair must complete its re-evaluation. This report does not allege an AST architecture defect, claim unsupported source forms, or infer Standalone/JIT/UE reflection support. Verdict: CHANGES_REQUIRED because Y01 is open.

## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
