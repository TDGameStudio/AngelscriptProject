> Task 8.7 verified on the frozen final source; see Final task 8.7 proof below. Historical iterations and corrections are preserved.

# Runtime ownership and retirement drain verification

Captured 2026-09-08T12:42:38.984979+08:00. Task 8.7 is still pending; the evidence below establishes grouped RED before production changes.

## Observed RED

- Initial fixture build e8faf870437d42b78578cf2bdf3107b7 succeeded. Run 8061704632774d6ca25e6737adf78538 crashed during concurrent shutdown: CALL resolved a removed function ID, then CallScriptFunction dereferenced null at AcquireJITBindingForExecution. Missing report/crash is not behavioral RED.
- A test-only guard queries whether the separate Helper executable survived shutdown and requests a Context exception in the blocked native callback when absent, before dispatch can access the removed function. The test still asserts the actual retention and successful continuation. Final-owner paths independently inspect the Engine reference delta before releasing the host owner. These guards avoid executing a demonstrated invalid pointer path.
- Refined test build 75cd3b8c148149ceb2cb17938ef4f33c succeeded. Run 8f9eea1bc3e6481db0c9a09c4c14bb22 completed all 8 cases: 7 assertion failures, 1 Success control. No crash or missing cases. Raw report SHA-256 ad9b390a9134d7766e4845c1c43ef75b2a50085faa623033c7daf1ca35ffcf11.
- Command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VMRuntimeDrain'; Fast = $true; NoWait = $true; TimeoutMs = 600000 }`.

| Public case | Observed state | Actual report messages |
|---|---|---|
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.CallbackShutdownCollectsUnreachableCycleAfterOuterReturn | Fail | Expected 1 to equal 0. |
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.ConcurrentShutdownRetainsActiveCrossSnapshotContinuation | Fail | Expected condition to be true. |
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.OnlyObjectRetainsNativeCleanupAfterHostAndProducerRelease | Fail | Expected condition to be true. |
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.OnlyObjectRetainsScriptAndCrossSnapshotCleanupThenExpires | Fail | Expected condition to be true. |
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.PayloadAddsAndReleasesItsOwnRuntimeLease | Fail | Expected 3 to equal 2. |
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.PublicAdmissionsStayClosedWhileNativeCleanupRemainsValid | Success |  |
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.RetainedScriptDestructorRunsAfterRetirementRequest | Fail | Expected 1 to equal 0. |
| Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.SuspendedScriptRootUnwindsWithItsCleanupBinding | Fail | Expected 1 to equal 0. |

PublicAdmissionsStayClosedWhileNativeCleanupRemainsValid is an existing-behavior control. The reference-probe assertions deliberately clean up before failing; they do not claim execution of the unsafe final-owner continuation on the old runtime. Independent retained script-destructor, suspended unwind and callback-cycle tests observe real missing cleanup.

## Implementation verification

Pending. No GREEN or final source identity is claimed in this record yet.

### First implementation iteration

Builds 9fc2e39395824a7285170dcddd34aafa and f739e0bd407748eda9ff9a298422f830 failed on DLL linkage declarations for the private cleanup helper. Both the forward and friend declarations now carry the owning runtime API attribute. Build ded2f2b9cb05438fb9881721c5a716a9 succeeded. Exact VMRuntimeDrain run 0509a6676d404959b0547775f05641e8 completed all original eight cases as Success. This is intermediate GREEN, not final acceptance.

Inspection of the same release chain identified a caller-held snapshot retaining a borrowed Engine pointer after final retirement, and the initial shutdown allocation guard also rejected temporary allocations during owned destruction. Three focused cases were added before changing those behaviors. The snapshot test observes detachment and safely clears the stale pointer before releasing the snapshot on RED; it does not dereference the dead Engine. The allocation tests cover native and cross-snapshot script destructors and preserve rejection of ordinary allocation after shutdown. Supplemental RED is pending.

Supplemental build 9fa47ab18a5949ad9f596574bf959c9b succeeded. Run bb8c043935f84e9eaecfbd2af1dbed86 completed 11 cases: the original 8 Success; CallerSnapshotDetachesWhenLastRuntimeObjectDrains failed the detached-pointer assertion, NativeCleanupCanAllocateAndReleaseTemporaryAfterShutdown and ScriptCleanupCanAllocateAndReleaseTemporaryAfterShutdown each observed zero temporary allocations instead of one. No crash occurred. Production was changed only after this observed grouped RED: snapshots clear their atomic publisher during final retirement; object allocation recognizes an already active operation or thread-scoped owning destructor while ordinary post-shutdown allocation remains rejected.

Build 93c2bf38f7ab4656b0d9b8e58c5c8170 succeeded; 907eddaacf8b4e5386bc4ade243f4f6c completed 11/11 Success after snapshot/temporary-allocation repairs. A final admission check identified BindGlobalStorage lacking the shutdown guard while metadata is intentionally retained. The new GlobalStorageCannotBeReboundDuringRetainedObjectDrain test was built by 42b5fac843ce4b1f91062450cd636ec3, then run 6cf551c9d5dd4859a425df5781986078 completed all 12 cases: this one assertion failed (actual Succeeded instead of Retired), 11 controls succeeded. The production guard was added only afterward under the existing metadata registration lock. The existing shutdown fixture also now preserves its first caller-owned snapshot when probing a rejected link, so final release does not lose that owner.

CORRECTION to the preceding GlobalStorage RED interpretation: raw entry filename/line evidence shows both 6cf551c9d5dd4859a425df5781986078 and the post-guard 4f87e4084f0d4610b02dc64473f24868 fail at fixture CreateGlobalProperty (line 179), with InvalidSignature (10), before invoking BindGlobalStorage. Neither proves the missing admission guard. This metadata API accepts only const global declarations. The fixture now authenticates a const Int32 TypeUse and supplies Primitive(ttInt,true). The newly added single-line BindGlobalStorage retirement guard was removed again before the refined run, retaining all other repairs. Saved/runtime-drain-final-identity.json is therefore an intermediate, superseded identity; a later fresh identity is required for final proof.

Refined build b15352801b2d41ce84d917df73fa68d9 succeeded, but 52f1647d08114bdc94e83ab72e4ca4c9 still fails at CreateGlobalProperty (line 183), before the rebind assertion. Directly defining a global before FCase.Start also requires FDetachedDefinitionFixture.BindContext; its usual DefineType/DefineFunction helpers perform that setup implicitly. The test now explicitly binds the identity context before constructing its authenticated global. The production global guard remains absent for the next observation. No behavioral RED is claimed from these fixture failures.

Actual global-rebind behavioral RED: build 2e29f1a4baa34f3eae33a98d3c4c84bb succeeded; f7efe3123e024700a4348a9012f14379 completed 12 cases, 11 Success and the global case failing at line 194, the post-shutdown Status assertion. Raw message: Expected 8 to equal 0 (Retired versus actual Succeeded). The fixture completed metadata creation, registration, original binding and shutdown, captured the replacement result/storage observation and cleaned its object before asserting. The one-line retirement guard was restored only after this actual admission failure.

## Final task 8.7 proof

Recorded 2026-09-08T13:09:34.054999+08:00. This section supersedes intermediate pending/identity statements above; original failures and their explicit corrections remain historical evidence.

- Build f07882afc2674ef7b10b32e2e93f78b4: Succeeded.
- Exact VMRuntimeDrain with Fast and ExtraArguments=@('-stompmalloc'): b4148c96bb2a4f559091818265c3b2ce, 12/12 Success. The Unreal log records Allocator: Stomp. One retained HTTP generate_204 timeout warning occurred during the callback-cycle case; no failure/crash.
- Shared VM Fast: 4d86afaf614c494a8d945050b4e2f2ca, 467/467 Success, zero warnings. This includes all 12 drain cases and adjacent lifetime, GC, Context, native-generation, manual-image and source-producer controls.
- Frozen source SHA-256 `3a9195feac747d5e8f6e7685bb028e3221968d68250a0cb72fc91ce9156b55f0`; 2318 source files and four DLLs authenticated against Saved/runtime-drain-verified-identity.json when writing this evidence.

| Report | SHA-256 |
|---|---|
| b4148c96bb2a4f559091818265c3b2ce | f790cb0e15c56d7e474d556346d336c425bb39c77f5937646179c40b527ef222 |
| 4d86afaf614c494a8d945050b4e2f2ca | 0728c7dddaeed777b235399661c5b72215a4ac0ccd1fbff0a953f6eb4e0e5c14 |

| Binary | SHA-256 |
|---|---|
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptEditor.dll | 2d8aff0477c721d1813592be9bdebdee5fb1fcee0e3b6c43e8ac48dab7b4294f |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | b162cb3f704df54432173a1e9067532faf68c9e986ea8a1c9f873ea1607cb387 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | 975d73d2206db1c92f1238adc7c927e10bf177ea74028edcb78e2ba99b5a0f09 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTestJIT.dll | 3f337d0d6111e3fd60dec1aac3d3c21e04ceefd9cda69fa9fbe0f04e8888419e |

### Exact runtime-drain Success cases

- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.CallbackShutdownCollectsUnreachableCycleAfterOuterReturn
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.CallerSnapshotDetachesWhenLastRuntimeObjectDrains
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.ConcurrentShutdownRetainsActiveCrossSnapshotContinuation
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.GlobalStorageCannotBeReboundDuringRetainedObjectDrain
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.NativeCleanupCanAllocateAndReleaseTemporaryAfterShutdown
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.OnlyObjectRetainsNativeCleanupAfterHostAndProducerRelease
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.OnlyObjectRetainsScriptAndCrossSnapshotCleanupThenExpires
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.PayloadAddsAndReleasesItsOwnRuntimeLease
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.PublicAdmissionsStayClosedWhileNativeCleanupRemainsValid
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.RetainedScriptDestructorRunsAfterRetirementRequest
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.ScriptCleanupCanAllocateAndReleaseTemporaryAfterShutdown
- Angelscript.UnitTest.NativeEngine.VMRuntimeDrain.SuspendedScriptRootUnwindsWithItsCleanupBinding

### Implementation and final ownership boundary

- SDK payload allocation acquires its actual Type/image and Engine lease before publishing the object; final free releases these after destroying the payload. Detached layout-only allocations retain Type without inventing an Engine.
- Retirement closes public admissions immediately. Object, interpreter/Prepare/Unprepare, native cleanup and collector operations retain resources until they finish. A full final drain breaks unreachable Engine/collector/object cycles; the collector retains Engine and metadata through its last use of raw type entries.
- Script destruction uses private per-Context cleanup authority, and native cleanup has a thread-scoped owning Engine. Already admitted work can allocate/release temporary objects after the request; new public Prepare/Execute/allocation remains rejected.
- Final retirement detaches caller-held snapshots through an atomic publisher pointer before releasing Engine publication leases. Global/native binding and metadata/image admission reject replacement during the deferred drain.
- Five old shutdown fixtures now release their explicit keeper Engine owners; the rejected-link fixture also preserves and releases its original snapshot owner. The new final-owner tests release producer, caller snapshot and host Engine ownership and assert destructor counts and final weak metadata expiry.

### Scope

Task 8.7 is complete. Final 11.4 remains pending for renewed complete NativeEngine/Baseline evidence, immutable Review reconciliation, spec synchronization and lifecycle closure. Complete NativeEngine is justified by shared Engine/Context/snapshot/native and both producer paths. Unrelated Quick, Performance, Integration and complete UE suites are omitted: no affected Harness performance or UE integration contract is claimed. Stomp is bounded memory checking, not exhaustive fuzzing or a race-sanitizer claim.
