---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
assigned_at: 2026-09-08T12:17:27.154727+08:00
reviewed_at: 2026-09-08T12:19:05.568777+08:00
closed_at: 2026-09-08T13:17:22.117476+08:00
snapshot_ref: D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/review-20260908-121727-vm-runtime-acceptance
snapshot_sha256: ede968cf51afed3242edf2a252dad3bc6516945a1ca0536d66a5a4ed3abaf8fd
verdict: CHANGES_REQUIRED
---

## Assignment and inspected evidence

Continuing the user's immutable final acceptance reconciliation. The assigned snapshot contains the final native-generation implementation, all NativeEngine tests, requirements, seven original Review reports and supplied raw execution reports. Read tests first: the seven VMNativeBindingLifetime cases, shutdown-drain retained-object/suspended-root cases and object-lifetime fixtures; then allocation/free, destructor dispatch, retirement, Context admission and native publication. Complete NativeEngine ed548793ef89407ba71f7260a2585b9f is 1068/1068 Success with zero warnings. Baseline 7599f99291df434b9ffbef12e9066c3d is 3/3 Success with 2,436 retained MetaSound warnings. Shared VM b8635307b314450a94b7ad8f60dde702 is 455/455; native-generation stomp 43a848e5413640d59b2f378319671f2e is 7/7, including one warning-bearing case. No broad suite was repeated during Review.

R means Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source, T means Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine, and C means this Change, all inside the assigned immutable copy.

## Z01 — Retained SDK objects do not own their runtime or preserve script cleanup through shutdown

severity: Required
status: resolved
**Locations:** R/as_vm_object.h:13–24; R/as_vm_object.cpp:38–79, :94–155; R/as_scriptengine_metadata.cpp:154–198; R/as_scriptengine.cpp:1126–1147; R/as_context.cpp:564–593, :1161; R/as_gc.cpp:103–162; T/VM/VMShutdownDrainTests.cpp:174–268; original F05; C/specs/angelscript/runtime/vm/spec.md (Context control and shutdown retain valid cleanup bindings).

**Original observation:** SDK allocation stores borrowed Type and Engine pointers in the payload header. It takes no type/image or Engine/runtime lease, and free releases no such lease. GC registration adds an object reference and stores another raw type pointer; it is not an ownership substitute for the runtime referenced by the payload. RetireMetadataImages clears published executable bindings/snapshot leases and retires the metadata image even if an object remains externally retained. Native destructor lookup now retains current native descriptors, which fixes the two existing native cleanup counters. Script destruction still creates a fresh ordinary Context and calls Prepare(Function); Prepare and Execute reject a shutting-down Engine, and its published script body has already been removed. Thus a retained script destructor is silently skipped after shutdown even when a test keeps an extra Engine reference to avoid destruction. Releasing the host's actual final Engine/producer owners can additionally leave the header's borrowed pointers dangling.

**Evidence and safe reproduction:** the inspected retained-object fixture installs asFUNC_SYSTEM GenericDrainDestruct and explicitly AddRefs the Engine before ShutDownAndRelease; it never proves that the object owns the Engine or that asFUNC_SCRIPT destruction executes after shutdown. Use the same bounded object setup with a real linked script destructor that invokes a counter callback and RET with the method ABI. Keep an explicit test Engine reference initially so the first RED is a missing destructor counter, not use-after-free. Independently compare Engine ownership before/after allocation (or expose a minimal owned-runtime acquisition seam) and stop before dropping the final host owner if ownership is absent. After ownership is implemented, release producer, caller snapshot and actual host Engine ownership while retaining only the object, then release it and assert exact script/native destructor count and final resource expiry. No crash or dangerous final-owner execution was performed by this Review.

**Impact:** the accepted object/Context shutdown contract remains incomplete despite all 1068 registered cases passing. Retained object cleanup can be omitted or use dead runtime state. Atomic object reference counts alone do not retain the Type, Engine, code or native services those references will later access. Keeping a test-owned Engine reference and using only native destructors cannot discharge original F05.

**Resolution condition:** every SDK payload owns the type/runtime resources needed through final destruction, without introducing permanent Engine/GC/object cycles. Stop new public admissions on shutdown while retained objects and active cleanup retain their required metadata, executable and native bindings. Provide an explicit internal cleanup execution path that can finish valid script destructors while ordinary Prepare/Execute remains rejected; do not temporarily reopen shutdown or restore retired definitions as a supported path. Drain active/reentrant execution, suspended roots and externally retained objects in an ordered manner, then retire/reclaim resources exactly once. Prove script and native destructor effects after producer/snapshot/host-owner release, no extra fixture Engine reference masquerading as ownership, final weak/resource expiry, live root preservation, cycle collection, callback-initiated shutdown, and bounded new-admission rejection. Establish safe grouped assertion RED/GREEN and memory-checking execution, then renew shared native/source and final acceptance evidence.


**Coordinator resolution (2026-09-08T13:17:22.117476+08:00):** resolved. Tasks 8.3–8.7: runtime payloads own Type/Engine resources; active operations retain metadata/code through private script/native cleanup. VMRuntimeDrain proves actual final host/producer/snapshot release, cross-snapshot script destruction, weak expiry, callback-cycle GC, suspended roots, concurrent active continuation and closed public admissions. Twelve cases pass under Stomp, alongside 467 shared VM cases. Re-evaluated against immutable snapshot `b06db25c046b9c0754f3adb8c461a18bff707860af6dc8ca08427ce58041d48f` in [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md), verdict APPROVE. Final full NativeEngine c2ceeb65d57d4f8fb84006dbaa309f41 is 1080/1080; exact source/DLL/report and case mapping is in ../data/final-runtime-drain-acceptance.md. The original observation and historical verdict above are preserved.

## Reconciliation and verdict

Y01 is now substantively repaired: descriptor candidates are prepared privately, publication is synchronized/live-generation checked, calls hold shared generations across reentrant cleanup, invalid replacement leaves the installed callback, and old generations expire after their final consumer. Actual seven-case GREEN and stomp support those conclusions. Parameter layout is now a runtime record; native/Context/Generic consumers no longer require declaration-layout mutation, and lowering's lazy CalculateParameterOffsets write is removed. The native retirement cleanup regression is included in the final 455/1068 runs.

Recent X/W admission repairs and their direct/decoded/manual/source evidence remain credited. The new Required residual concerns the original F05 object/runtime drain clause. The earlier reports cannot all be closed from a case aggregate or the native-only shutdown checks. Historical finding resolution must wait for the actual object/runtime ownership and script-destruction proof. No source frontend, AST architecture, Standalone, JIT or UE reflection expansion is requested by this finding. Verdict: CHANGES_REQUIRED for Z01.

## Coordinator supersession

Superseded 2026-09-08T13:17:22.117476+08:00 by [review-20260908-131251-vm-drain-final-acceptance-reviewer.md](review-20260908-131251-vm-drain-final-acceptance-reviewer.md) because this report describes an earlier immutable implementation. Its CHANGES_REQUIRED verdict and original finding text remain historical truth. Every finding now has a specific appended resolution and the new snapshot re-evaluation is APPROVE.
