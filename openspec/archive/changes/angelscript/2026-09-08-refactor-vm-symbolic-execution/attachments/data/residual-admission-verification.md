# Residual admission verification

This supplements historical acceptance; it does not overwrite the 909-case or later language-surface reports. The user requested re-evaluation and completion of the VM Review. Current owners are 6.7, 6.8 and 11.4.

## 6.7 real callable contracts

The immutable residual Review found that real `AddFunctionRequirement` omitted auxiliary TypeUse width records supplied by the old synthetic test. New fixtures create detached function metadata and use that actual producer. Minimal storage-field declarations initially had no behavior and existed only to compile the negative tests.

| Stage | Harness RunId | Actual result |
|---|---|---|
| Initial RED build | `beb8ef2306dd46288e73d823a85e5097` | Failed C3861 in existing `as_frontend_sema_initializer.cpp`; missing explicit `as_ast_cast.h` include. Build failure, not behavioral RED. |
| Compile prerequisite repair | `eece56558a9a4a80a116452675b3da03` | Succeeded, 11 actions. One explicit include; no call admission behavior implemented yet. |
| VMCallAdmission RED | `b965abdd3e4d4c30a35e5c27f1798403` | All seven identities discovered and executed: five failed and two succeeded. UE returned 255 with five reported test failures. |

Exact proving selector: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VMCallAdmission'; Fast = $true; TimeoutMs = 600000 }`. Execution used the same parameters with `NoWait = $true` and subsequent `ue.run.status`; source writers were frozen through build and Automation.

Prefix below is `Angelscript.UnitTest.NativeEngine.VMCallAdmission.`.

| Public scenario | Observed RED/control |
|---|---|
| RealDoubleAndInt64RejectOneDwordArguments | Failed on first (double) iteration: expected StackUnderflow, actual Succeeded at line 75. The later int64 iteration was not claimed as independently observed RED. |
| RealWideCallsBalanceLoopAndDecode | Failed on first double loop: expected Succeeded, actual InvalidJump at line 90. Decode and later int64 controls had not yet run. |
| ReferenceModesRejectScalarBitsOfPointerWidth | Failed on first in-reference iteration: expected InvalidOperand, actual Succeeded at line 109. Later modes were not claimed as observed RED. |
| UnknownZeroAndOversizedStorageReject | Failed on width zero: expected InvalidOperand, actual Succeeded at line 145. Oversized iteration was not reached. |
| TamperedWidthCannotAuthenticateAtTarget | Failed: target link returned Succeeded for a forged one-DWORD double contract at line 169. The malformed image was not executed. |
| ReferenceModesAcceptLocalAddressAndPointerLoad | Success; all three modes and both PSF/PshVPtr controls ran. |
| DecodedRealDoubleCallReturnsFortyTwo | Success; actual generic native callback doubled exactly representable 21.0 to 42.0. This is a preserved positive execution control, not RED. |

Implementation introduces explicit DWORD storage/category fields produced from `asCDataType`, complete contract witness and wire v3 preservation, target metadata comparison, checked stack consumption and abstract value/address categories. The prior `NativeOffset` fallback is removed. Existing manual structural fixtures explicitly declare their contract and no longer manufacture auxiliary TypeUse width records.

First GREEN: build `e75f740720934690898252aa086d4750`, focused run `0980c96744584159a0ada119b46cd8d9`, seven of seven Success. All loop iterations and decode controls completed. A subsequent shared `Angelscript.UnitTest.NativeEngine.VM` run `a3966f3b048140ca9542c169b27f5665` executed 362 cases: 357 Success, five Fail. Three were independent wire fixtures still declaring v2. `VMIntegerOpcodeMatrix.StackPointerAndVar` exposed an overbroad new RDSPtr category rejection of its existing guarded null runtime path. `VMIntegration.MemoryWidthIncAndSwapFamilies` exposed its old malformed three-DWORD input to a four-DWORD SwapPtr. These were repaired locally: retain runtime null semantics, update independent wire header to v3 and reject both older versions, and supply two actual addresses with balanced pops while preserving the result-nine oracle. No existing scenario was removed.

Final group GREEN: build `05694606bdc14f0ca54592cfbd97b6aa` (nine actions) and shared VM run `f1fd365d2e1545febf66855f9047622c` executed 367 unique identities, all Success, zero failures/skips/in-process cases. The same supported selector with `NoWait = $true` supplied the exact VMCallAdmission proving prefix and affected shared consumers without redundant launches. All twelve VMCallAdmission cases passed, including the original seven above plus:

- EqualHeightAddressValueMergeRejects: equal-height PSF/PshC8 branches reject direct and decoded images.
- MixedArgumentsAndReceiverConsumeExactStorage: real method with double, inout-reference and receiver balances; scalar receiver rejects.
- InvalidCategoryModeAndAggregateWidthRejectDirectAndDecoded: missing category, unknown mode and summed-width overflow reject without a decoded image.
- TamperedReturnStorageRejectsBeforePublication: internally coherent decoded bytes with a forged return contract fail target authentication with SchemaMismatch and no declaration mutation.
- SwapPtrRequiresTwoCompletePointers: explicit three-DWORD input rejects at instruction two.

These five later cases are post-change boundary/regression controls, not independently observed preimplementation RED. The feature group's five actually observed failures remain the stated RED evidence. The shared run also includes all native ABI, dispatch, opcode matrix, wire/image contract, source numeric/call/scope/unwind and cache groups. It does not substitute for the later final NativeEngine plus Baseline acceptance.

The final group identity is SHA-256 `1f4a58d2458a69eedd2f372fdc7b7e889d22c1ee08cec1beafa46a9d49058d00` for the canonical JSON inventory of 2,310 source entries under plugin/host Source; entries contain sorted workspace-relative path and byte SHA-256. Raw per-file inventory and four plugin DLL hashes are in `Saved/vm-call-final-identity.json`. All writes were frozen during the build and shared run. Task 6.7 is complete; Review lifecycle stays open until final immutable-snapshot reconciliation.

## 6.8 frame-owned lifetime admission

Build `6ffd60833d9041839b12de0dbe55c001` succeeded (ten actions) with the new direct-image fixture and the previous lifetime implementation. RED run `5a828153369842ca947fc5442600ac69` selected `Angelscript.UnitTest.NativeEngine.VMLifetimeAdmission` with Fast, NoWait and TimeoutMs 600000. It executed all twelve public scenarios: nine failed as expected, three succeeded. No runtime Engine is needed by these structural fixtures; the type and optional constructor are actual detached metadata definitions.

| Scenario under VMLifetimeAdmission | Observed RED/control |
|---|---|
| BranchBypassingAllocationBeforeDestroyRejects | Expected InvalidFrame; incorrectly admitted. Decode control follows after repair. |
| BranchBypassingOnlyNormalCleanupRejects | Expected InvalidFrame; incorrectly admitted. |
| CleanupRecordsMustDescribeActualOperations | Normal marker moved to RET was incorrectly admitted. The later Exception-marker mutation was not reached in RED. |
| DestroyRevisitedWithoutReconstructionRejects | Expected InvalidFrame; incorrectly admitted the repeated FREE backedge. |
| MissingInitializationGuardRejects | Expected InvalidFrame; incorrectly admitted allocation followed by unguarded destruction. |
| SkippedConstructorBeforeDestroyRejects | Expected InvalidFrame; incorrectly admitted the branch bypassing the real constructor. |
| ReconstructedInstancesMayEachBeDestroyed | Expected Succeeded; rejected the second legitimate initialization. |
| ExclusiveBranchesEachConstructAndDestroyPass | Expected Succeeded; rejected mutually exclusive initialization records. |
| ExceptionExitUsesLiveGuardWithoutNormalDestroy | Expected Succeeded; rejected a function whose reachable exit is exceptional. |
| LinearConstructionAndDestructionPassDirectAndDecoded | Success, positive direct/decode control. |
| ConstructionAndDestructionBalanceLoop | Success, positive reconstruction-loop control. |
| CompletedConstructorBeforeDestroyPasses | Success, positive real-constructor control. |

The revised analysis owns the object slots explicitly declared in a frame's cleanup contract. A declaration names managed storage and does not establish entry liveness. Raw VM values whose ownership is external to that frame remain governed by their runtime bindings; this structural verifier does not claim a general memory-safety sandbox. Optional verified incoming lifetime maps allow the linker to produce the existing PC-indexed cleanup metadata consistently across branches and loops. No 6.8 GREEN or closure is claimed until actual verification completes.


First lifetime GREEN: build `7bbf5d6531c5438ea3f8cdaa76ec3e8b`, focused run `aa5ad449c1dc4eee881506deb5137861`: all twelve VMLifetimeAdmission scenarios above Success, zero warnings. The verifier propagates Uninitialized/Allocated/Constructed through reachable edges, authenticates constructor identity and operation/slot/type records, and publishes lifetime maps only after complete verification. The linker encodes proven incoming constructed-state differences in physical PC order. The historical Both path ordinal remains reserved and explicitly rejects ambiguous combined init/uninit records.

Six existing fixture migrations retain public identities and independent outcomes. VMFlowPath.DisjointNormalAndExceptionCleanupSucceeds now uses real PSF/ALLOC/FREE/RET. VMFlowVerification.ValidBalancedLoopAndGuardedCleanupPass allocates before a balanced loop and frees on exit. VMFlowAdmission.ExclusiveBranchNormalDestroysSucceedAndSamePathDuplicatesReject allocates once and frees on each exclusive branch. VMOperandContracts.FrameCleanupSourceCapturedAndInvalidResultRegionRejects retains frame/parameter/result/source assertions with an actual object slot and two records. VMWireFormat.CanonicalOrderRoundtripPreservesContractsFrameAndCleanup retains byte equality between reversed string insertion orders, witness tampering and source/result preservation, with distinct ALLOC/FREE records; its former Both-at-RET success is replaced by a RET-marker rejection. VMShutdownDrain.ShutdownAbortsSuspendedAndReleasesRoot records its existing ALLOC and FREE and preserves its exact shutdown destructor count.

Fixture build `b3fa2569a5d542169527304a01fa0a9b` failed because a generated test edit referenced the Second builder before its declaration; removing the duplicate misplaced block repaired that local compile error. Build `ef572f02dec1467dbbb1c718f8e61a6d` passed. Shared VM run `60116d7161cb4574a3364f4d8a9fa83c` failed: SourceMixedLoopObjectExceptionCache rejected at linking, and a later heap crash prevented a complete report. Exact mixed-cache run `a83a07af1c3c447b8c202f0707978d45` reproduced admission failure; unwind-only `83f9d5ff694045d891a3b320fbe8afb3` reproduced heap corruption. Exact BrokenConstructorDestroysCompletedLocalOnly with `ExtraArguments = @('-stompmalloc')`, run `cb61a0dc77104497861eaeca5a9702c8`, failed in Free from CleanStackFrame during Execute. These failures are retained, not counted as GREEN.

The source return producer consumed lexical ownership needed by sibling returns; it now emits destruction without popping the lexical live set. Correct constructed-state timing exposed a borrowed-receiver bug in Context fallback scanning: it released constructor this before the caller could retire the pending allocation. The indexed applied replan adds exact Context ownership. The first repair passed all 112 `Angelscript.UnitTest.NativeEngine.VMSource` cases in run `7ad6823f37824b779eb9fbacefb5b0d5` on build `9231915654f2429faf572931224db2a9`. Added ConditionalReturnsEachDestroyOuterLocalOnce and FailedConstructorNeverRunsCompleteDestructor are post-change boundary controls; the earlier actual mixed-cache/stomp failures are the feature RED. A stricter unwind run `c15916ececc2493a829927f6490ffdab` then caught an offset-zero out-of-bounds read in the same fallback scan. No final 6.8 completion is claimed until the corrected scan also passes the memory-checking reproduction and adjacent VM cases.


Final 6.8 verification: build `85253bd4e50f49ad8785de7730e280b8` succeeded. Memory-checking source unwind run `2084fffa9dc645ddb261a9ec51ca3143`, exact selector `Angelscript.UnitTest.NativeEngine.VMSourceUnwind` with Fast, NoWait, TimeoutMs 600000 and `ExtraArguments = @('-stompmalloc')`, executed all eight cases Success. Seven were warning-free; BrokenConstructorDestroysCompletedLocalOnly carried one engine `LogHttp` network-probe timeout warning for generate_204. There were no allocator faults, failed, not-run or in-process cases. The complete-destructor exclusion, reverse local/member cleanup, source observations, stack-limit recovery and Recovery=97 assertions all completed.

Shared final VM run `7e2826123d8f48a79cef82f34b6636c2` used `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM'; Fast = $true; TimeoutMs = 600000; NoWait = $true }` and terminal status inspection. All **381 unique cases Success**, zero warnings/failures/skips/in-process cases. This includes all twelve VMLifetimeAdmission identities, all twelve VMCallAdmission controls, all six migrated fixture scenarios, 112 VMSource cases including the two new post-change controls, and shutdown/raw drain/native/dispatch/cache/opcode matrices. Each required assertion ran; the wider selection is justified by the shared verifier/linker/Context producer-consumer boundary, not task count.

Exact final 6.8 source inventory SHA-256: `e4548d7701bb7bec5d71a600edcfbba2582572f3ab573d30277e595a30744c0f` (2,311 sorted plugin/host Source entries); four plugin DLL byte hashes are retained in `Saved/lifetime-final-identity.json`. Source writers stayed frozen through build, stomp and shared VM execution. The indexed borrowed-constructor issue is resolved by these exact runs. Task 6.8 completes; older Review text and verdicts still await 11.4's full resolution-condition audit. No Quick, Performance, Standalone, JIT or unrelated UE suites were selected because their contracts were not affected.


## 6.9 Physical frame access direction

Grouped assertion RED `0081bd3a5a7e4dfa90cb5e126ab878b8`: 12 failed / one valid-argument control passed, built by `6be2fc32d6284b16b53cbea30bf26e07`. Offsets now match Frame - Offset storage: locals 1..FrameSize, arguments 0..-(ParameterSize-1), a multi-DWORD access proceeds toward decreasing offsets and cannot cross zero. Pointer loads/stores use the complete pointer span; conversions and shifts use each operand's actual width. Managed pointer storage is local and non-overlapping. Source emission declares a valid positive result span.

Initial post-fix shared VM run `f7cff4d4bfbf46df86dd3d2d8531c240` passed all 13 new cases and all source cases, but 11 historical fixtures still used the previous frame convention. Their coordinates and boundary oracles were migrated within 6.9 Files ownership. Final build `85fa422e564c49ddae091cdb4f683a4a` succeeded. Shared proving run `dd837bd7d7c34a98bdad136fd6222eba` used `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM'; Fast = $true; NoWait = $true; TimeoutMs = 600000 }`, 394/394 Success including 112 source cases. Additional exact VMFrameAdmission run `73256ab57caf468188783b15fd67a09a` used the same parameters plus `ExtraArguments = @('-stompmalloc')`, 13/13 Success. Invalid frames are only verified/decoded; SafeLocalBoundaryExecutionReturnsFortyTwo actually executes valid boundary accesses and asserts 42 under the allocator.

All exact 6.9 identities (same prefix Angelscript.UnitTest.NativeEngine.VMFrameAdmission):
- ArgumentPastItsLastDwordRejects: Success
- ConversionOperandsUseTheirOwnStorageWidths: Success
- FirstAndLastCompleteArgumentsPass: Success
- FirstAndLastCompleteLocalsPassDirectAndDecoded: Success
- ManagedPointerSpansCannotOverlap: Success
- ManagedStorageCannotOwnArgumentZero: Success
- NoArgumentZeroLocalRejectsDirectAndDecoded: Success
- PointerLoadRequiresBothDwordsInsideTheFrame: Success
- ResultSpanMustStayWithinLocalStorage: Success
- SafeLocalBoundaryExecutionReturnsFortyTwo: Success
- SignedPositiveEdgeUsesPhysicalStorageDirection: Success
- WideArgumentCannotCrossItsEnd: Success
- WideLocalCannotCrossIntoArguments: Success

Actual warning counts: shared=0; stomp=1. Both reports have no failed/skipped/in-process cases. Frozen source inventory SHA-256 d1484021c52e3d64f5754edb47e5ea09a0a3af4f526e8a05e54ab4bdb1bb4ddf (2,312 entries); four DLL hashes in Saved/frame-final-identity.json. Quick/Performance/Standalone/JIT and unrelated UE suites omitted because the shared VM consumer run covers this impact.


## 6.10 Body and return ABI

Grouped RED `5b8885457b29454c9adbe9c6bee7017c` on build `fa678490557245a0ae4a670a0df30cc2`: ten assertion failures and one valid repeated-nested-call control. Body parameter storage now matches its in-image callable where present and is always checked against real target metadata before publication. Reachable RET pop must equal the body storage and be nonnegative/representable. Shorthand PshC4/RET retains the original RET and requires a compatible one-DWORD scalar return. Receiver, wide/reference input and hidden return-destination storage are included. CallableTraits bit 64 records DoesReturnOnStack and is authenticated in the builder/linker witness contract, with the hidden address consumed by call analysis. The current unreleased wire version remains v3.

The initial shared run `29f85aa125734c638ca3ed04d7c56af1` passed all eleven new cases and the source producer but exposed 28 historical positive fixtures with fabricated zero/body argument counts. Their exact method/parameter ABI was migrated within 6.10 Files, preserving all result/callback/lifetime assertions; positive helpers use actual declaration storage, while the independent new malformed/valid count oracles remain literal. Follow-on `7e43dd1686e9424393d4664e927f18c2` was 403/405 and identified two missed receiver counts in the canonical-byte-order and LoadThisR fixtures. Those were repaired.

Final build `eec12e0cd4394e839abaddd3361b32c8` succeeded. Shared proving `b6b922745c5d47beafadd203d2d8c594` used `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM'; Fast = $true; NoWait = $true; TimeoutMs = 600000 }`: 405/405 Success. Additional exact VMReturnAdmission run `2545dc3198d24fce848f1bf52842e71d` used the same parameters plus `ExtraArguments = @('-stompmalloc')`: 11/11 Success. The valid repeated nested execution returns 32 three times, records literal callback arguments [10,20,10,20,10,20], and observes the same stack address at all six host calls. Malformed bodies are never executed.

Task-specific public identities under Angelscript.UnitTest.NativeEngine.VMReturnAdmission:
- BodyIncludesHiddenReturnDestination: Success
- BodyIncludesReferenceStorage: Success
- BodyParameterSizeMustMatchRealWideRequirement: Success
- MethodBodyIncludesReceiverStorage: Success
- RepeatedNestedCallsPreserveResultsArgumentsAndStackPosition: Success
- ReturnCannotHaveNegativePop: Success
- ReturnCannotPopFewerArguments: Success
- ReturnCannotPopMoreArguments: Success
- ScalarShorthandRejectsWideReturn: Success
- ScalarShorthandRetainsMethodArgumentPop: Success
- TargetChecksBodyWithoutInImageRequirement: Success

Actual warning counts: shared=0; stomp=1. Neither report has failed, skipped or in-process cases. Frozen inventory SHA-256 fe79c17e52d8e5acbe2e5dc7771074041862ec0bea955980e69be59e1e8082fe (2,313 entries); four DLL byte hashes retained in Saved/return-final-identity.json. Quick, Performance, Standalone, JIT and unrelated UE suites omitted because shared VM execution covers the impacted contract and producers. X01 can be re-evaluated against these sources and tests in 11.4; no historical review verdict is rewritten here.


## 6.11 Indirect call-site admission and runtime dispatch

Grouped RED d8ba404496e142ab9dfac94ce6cbcc5c observed twelve assertion failures on test build 200eb053a545440a9665756aec2cced6. The old one-operand form was accepted while the expected-signature form rejected. Wide underflow and positive address/wide-loop oracles also failed as expected. Runtime negative cases stopped at the new-format admission assertion, so no mismatched target ran before the guard existed. An earlier CQTest if/else macro compile error (build 5273d40e1b2c4fc3a5b17c7ccee76d50) was corrected with braces; it is not behavioral RED.

CallPtr now has symbolic operands [Local, FunctionSlot]. The second operand names an authenticated declaration for the expected shape and participates in the existing direct-call storage analysis. Lowering retains the one-DWORD physical instruction and stores the expected declaration by physical PC in the generation-owned executable. Before dispatch, Context compares actual parameter and return types, modes, hidden return storage and effective receiver. Bound delegates supply their receiver internally and use a receiver-free shape. Constructor status and unbound receiver qualification are preserved. Names are not compared and no stable-key lookup is added per instruction. Signature mismatch raises exactly `Indirect call signature mismatch` before invoking the target; argument cleanup uses the expected call-site declaration. Existing null exception behavior is retained. Five existing CallPtr producers in dispatch, dispatch contracts and the resource matrix now supply explicit expected declarations, including independent receiver-free declarations for bound delegates. No source delegate feature was added.

Initial shared GREEN 1b7aa7daf8da4369b55b49d3a2e26bf2 on build 7cd874b58d9f46bfa6ed5b8dc0d5253b passed 417/417. Three post-repair controls added distinct script targets, same-width/different-type mismatch and missing receiver rejection; they are additional GREEN controls, not retrospectively claimed RED. Final build edd0330bbd094cc2bbc9a0ecd15fa6c4 succeeded. Exact VMIndirectAdmission stomp run 9c5480ef1b204996a851c34da33bfb3c passed 15/15 using `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VMIndirectAdmission'; Fast = $true; NoWait = $true; TimeoutMs = 600000; ExtraArguments = @('-stompmalloc') }`. Final shared proving d0c0dc3c7c084bb4ae2642d679819ab7 passed 420/420 using the same route with prefix Angelscript.UnitTest.NativeEngine.VM and without ExtraArguments. Runtime scenarios repeat three times; compatible distinct native/script targets return 42, incompatible targets invoke zero callbacks, and each subsequent Recovery returns 97.

Exact task identities under Angelscript.UnitTest.NativeEngine.VMIndirectAdmission:
- ActualParameterCountRejectsBeforeCallbackAndRecovers: Success
- ActualParameterModeRejectsBeforeCallbackAndRecovers: Success
- ActualReturnTypeRejectsBeforeCallbackAndRecovers: Success
- ActualSameWidthDifferentTypeRejectsBeforeCallbackAndRecovers: Success
- ActualWideParameterRejectsBeforeCallbackAndRecovers: Success
- DistinctNativeNameWithSameShapeReturnsFortyTwo: Success
- DistinctNativeReferenceShapeReturnsFortyTwo: Success
- DistinctScriptNameWithSameShapeReturnsFortyTwo: Success
- ForgedExpectedWidthRejectsAtTarget: Success
- MissingCallSiteSignatureRejectsLegacyEncoding: Success
- NullTargetPreservesExceptionAndRecovers: Success
- ReferenceRejectsValueBitsAndAcceptsAddressLoops: Success
- UnboundReceiverCannotUseReceiverFreeShape: Success
- WideArgumentsRejectOneDwordDirectAndDecoded: Success
- WideCallLoopsBalanceDirectAndDecoded: Success

Actual warnings: shared=0; stomp=1. No failed, skipped or in-process cases. Source writers remained frozen through both final runs. Source inventory SHA-256 62e2127e229dea8f289a66c42e8a888d6550530384017a94aa8ee768b1e06856 (2314 entries), retained in Saved/indirect-final-identity.json. DLL SHA-256:
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptEditor.dll: 1aa1a7a9141c8989be18a6e87d2251748ab26c564ba814185d8486216e25767a
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll: 27835990ef41315a2596efbc6233c736eb6cc3ac17394353d114ec7dc36a1eb7
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll: d86ce98fe9008a03503c13d085d3801753f51e0518a4b194e916326df933cb5b
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTestJIT.dll: e7e76a10b58b2c3a7eea9ea3a81bec34e2d1a3e2cbd998fd457f2b73ad338a53

The unreleased wire-v3 format now requires both CallPtr operands; the complete operand codec preserves the signature slot, and older incomplete encodings reject. Unrelated Quick/Performance/Standalone/JIT suites omitted because the shared VM selection covers affected consumers. X02 is ready for immutable-snapshot re-evaluation under 11.4; historical Review verdicts remain unchanged here.


## 6.12 Complete indexed CFG and guarded dispatch

First RED 13ddbd1b20994faa93da0966c487776c on build 1ebb463f34c540919787af069a13aab0 had nine expected failures, two valid controls and one accidentally passing negative fixture: the lifetime test had omitted its frame-owned object slot. Correcting that fixture with a declared positive slot and a corresponding valid both-entries-construct control produced the actual group RED 1e6ecb9a98744e41aa02feb1d9755232 on build c743c2d15f64420f93d9d90e0431966a: ten assertion failures and two valid controls. Invalid runtime indices stopped at a companion malformed-table admission assertion before any unguarded execution.

Verifier now bounds the complete max+1 table with full-width arithmetic, requires every entry to be a two-DWORD JMP, and enqueues every entry into the common CFG stack/lifetime analysis. Linker caches the admitted maximum by physical PC in the generation-owned executable and checks lowered entry widths. Runtime checks negative, max+1 and large indices before computing a dispatch address and raises exactly `Indexed jump index out of range`. The existing VMIntegration.JmppIndexOneSkipsNextStore producer previously used a SetV4 as a table entry with maximum zero while executing index one; it now uses two explicit JMP entries and preserves its public identity and independent return-42 oracle. VMIntegerOpcodeMatrix.JumpTableEachArmDefaultAndMalformed remains unchanged and executes all 10/20/30 arms plus default 40 and malformed rejection.

Final build 8eaa425a4ac54977bb3c06c4ebd6cc5d succeeded. Shared proving ce1f9e9161ac4188ae5410c427152626 passed 432/432 with `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM'; Fast = $true; NoWait = $true; TimeoutMs = 600000 }`. Additional exact stomp 1c7eb8cebc554f4e9557905bb4b8fa82 passed 12/12 with prefix Angelscript.UnitTest.NativeEngine.VMIndexedAdmission and ExtraArguments @('-stompmalloc'). Both valid entries return their literal 11/22 values; invalid indices -1, 2 and MAX_int32 raise the stable exception, and every repeated invocation is followed by Recovery returning 97 in the same Context. The non-first lifetime bypass rejects direct/decode while its repaired two-construct-entry control passes.

Exact public cases under Angelscript.UnitTest.NativeEngine.VMIndexedAdmission:
- CompleteTablePassesDirectAndDecoded: Success
- EveryEntryExecutesItsDistinctResult: Success
- EveryEntryMustBeFixedWidthJump: Success
- LargeRuntimeIndexThrowsAndRecovers: Success
- MaximumPlusOneThrowsAndRecovers: Success
- NegativeMaximumRejectsDirectAndDecoded: Success
- NegativeRuntimeIndexThrowsAndRecovers: Success
- NonFirstEntryCannotBypassObjectConstruction: Success
- NonFirstEntryStackJoinRejectsDirectAndDecoded: Success
- NonFirstEntryUnderflowRejectsDirectAndDecoded: Success
- OversizedTableRejectsWithoutArithmeticOverflow: Success
- TruncatedTableRejectsDirectAndDecoded: Success

Actual warnings: shared=0; stomp=1. No failed, skipped or in-process cases. Frozen source inventory de8beb3c681575dfe365aaf9dde1a18f54b82df80e4633b084cdc641fc492cf8 (2315 entries) and four DLL hashes are retained in Saved/indexed-final-identity.json. DLL SHA-256:
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptEditor.dll: 95e4530574581ebd4769f4b765f757c2ab49f68ea0a03020c13bf381d0e91583
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll: e08d814e89ece66221b91ed29eabe38748c2555dc942a71777305ebc137b7560
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll: 0cd1b2020693a6d798a606760968fd1f6f597487eda29645b1bb848ed879145b
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTestJIT.dll: 12ae6b0b9fc7a6492b57bf76a45f674dfd1e1f1fb903e112a1c314193f69a7a7

Shared VM covers the changed control/frame consumers and source producer; unrelated Quick/Performance/Standalone/JIT gates omitted. X03 is ready for final immutable-snapshot re-evaluation. The user separately requested additional manually authored mutation/atomic-admission testing on 2026-09-08; that is follow-up scope, not evidence against these completed cases.


## 6.13 User-requested manual image mutation and allocation tests

The user requested more manual-bytecode tests on 2026-09-08 10:56:57 +08:00. Applied replan-20260908-110251-manual-image-admission-tests preserves completed work and gives this bounded F01/F02/F10 admission group an explicit owner. Fifteen scenarios use real detached metadata and source-free authored images. Negative tests first verify the unmodified counterpart, then change one contract and exercise direct verification, encode/decode rejection and target linking with a forged bValidated flag. Failed candidates publish neither the early legal nor late illegal function; an existing Recovery executable retains pointer identity and returns 97, with zero callbacks and unchanged [91,17,92] host sentinels. Invalid images are never executed.

Initial run 5279c90df7364a87b2b52c3a3ae0ef1a on build 2a52ca2c8d4846a79bb65875aec16705 had six failing scenarios, but the first also triggered CQTest's unsupported StableKey diagnostic conversion. The key-equality assertion was changed to IsTrue; that framework event is not product RED. Clean group RED 3bbe0f867fb54226b6419fe69b4efaf6 on build a0ad34f9e7b446228df132e9f39a4ba9 has six actual assertion failures and nine passing controls:

- Duplicate bodies, in both conflicting payload orders, were accepted instead of rejected.
- Identical and conflicting duplicate requirement identities were accepted by direct verification despite codec duplicate rejection.
- Frame declarations 0x7fffffff, 0x80000000 and 0xffffffff were accepted despite runtime reservation arithmetic and signed local-coordinate limits.
- An all-zero function identity bypassed the authoring entry's identity constraint.
- A legal four-DWORD local frame with 32 QWORD pushes reserved only 16 DWORDs, below its independent minimum of 68. The allocation-bound assertion stopped before unsafe execution.

Verifier now rejects duplicate (role,key) requirement identities, duplicate body keys and empty body keys, and caps local frame declarations at the positive signed-16-bit coordinate maximum 32767. The existing legal last-local 32767 control remains part of the shared VM run. CFG analysis records its maximum reachable temporary/argument stack extent. Linker reserves max(FrameSize,2) plus that measured peak using full-width arithmetic, with a checked runtime representation bound. The peak is derived again for direct or decoded images, not taken from a caller-trusted cached field. No wire revision or source syntax is added. The legal deep-stack control now starts with a 64-byte initial Context stack and executes three times, each returning 42.

Final build 7b5080dd9fee4567994b7c2880ece3c6 succeeded. Shared VM proving 387fe0df53fb44e4b9a039337d5e8bc0 passed 447/447 using `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM'; Fast = $true; NoWait = $true; TimeoutMs = 600000 }`. Additional exact manual stomp ba68a6fef14c4081891849b0ca680d11 passed 15/15 with TestPrefix Angelscript.UnitTest.NativeEngine.VMManualAdmission and ExtraArguments @('-stompmalloc').

Exact task identities under Angelscript.UnitTest.NativeEngine.VMManualAdmission:
- ConflictingDuplicateRequirementRejectsEveryAdmission: Success
- DuplicateBodyCannotSelectAnOrderDependentWinner: Success
- IdenticalDuplicateRequirementStillRejectsDirectAdmission: Success
- ImmediateNarrowingRejectsEveryAdmission: Success
- LateInvalidBodyAndForgedValidationPublishNothing: Success
- LegalCounterpartsExecuteThroughDirectAndDecodedAdmission: Success
- MissingFunctionSlotRejectsEveryAdmission: Success
- OversizedFrameCannotWrapRuntimeReservation: Success
- TemporaryStackPeakIsReservedInAdditionToLocals: Success
- UnreachableInvalidBranchStillRejects: Success
- UnreachableInvalidLocalStillRejects: Success
- UnreachableUnknownOpcodeStillRejects: Success
- WrongOperandKindRejectsEveryAdmission: Success
- WrongRoleFunctionSlotRejectsEveryAdmission: Success
- ZeroFunctionIdentityCannotEnterDirectAdmission: Success

Actual warnings: shared=0; stomp=1. No failed, skipped or in-process cases. Frozen source inventory ffc152188409e2ec25640fbe2fee91fa317d5b25a645bb59c78133993db1223d (2316 entries) and four DLL hashes retained in Saved/manual-final-identity.json. DLL SHA-256:
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptEditor.dll: 95e4530574581ebd4769f4b765f757c2ab49f68ea0a03020c13bf381d0e91583
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll: 43ff94fe096f1701ba56a48ac3f89387d3d3883fe92e26e1a62a3469f671e293
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll: 2dee8000e0fe4b157eb1e7ed190371667b8c1cf03025b195954d07c67db8bd41
- Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTestJIT.dll: 12ae6b0b9fc7a6492b57bf76a45f674dfd1e1f1fb903e112a1c314193f69a7a7

Unrelated Quick/Performance/Standalone/JIT gates omitted; shared VM covers the changed admission/allocation contract and both producers. This is bounded mutation coverage, not a claim of exhaustive fuzzing or an arbitrary-bytecode sandbox. Final 11.4 still owns complete NativeEngine/Baseline and immutable Review reconciliation.
