# Implementation verification

Frozen after 4.2 on AngelscriptProjectEditor Win64 Development. Binary from `ue.build` RunId `ba09bbfe1fda4452aedffabe1946343d`. NativeEngine was executed twice on that identity.

| Gate | Envelope RunId | Data RunId | Result |
|---|---|---|---|
| `ue.build` AngelscriptProjectEditor Win64 Development Serialize+Wait | — | `ba09bbfe1fda4452aedffabe1946343d` | Succeeded |
| `ue.test` `Angelscript.UnitTest.NativeEngine` Fast TimeoutMs 600000 (1) | `d68ccb7de1f743ebb49024b70ef95c69` | `bf8cfb03ed9a4607b347c40a1442660f` | Succeeded 704/704 (2026-09-05T23:51:55Z) |
| `ue.test` `Angelscript.UnitTest.NativeEngine` Fast TimeoutMs 600000 (2) | `d3dd29da89f84f3bbcc4935ec046fed1` | `6f4ed80cd8fa46369d45f2e6bf6f4049` | Succeeded 704/704 (2026-09-05T23:52:38Z) |
| `ue.test` `Angelscript.UnitTest.Baseline` Fast TimeoutMs 600000 | `07d62ad13a5d4737b0663d5f6a026e1b` | `93bdb999a8174b809010337c778ba330` | Passed 3/3 (2 Succeeded + 1 SucceededWithWarnings, 0 Failed) |
| `openspec.validate` `angelscript/refactor-vm-symbolic-execution --type change --strict --json` | `39bd999b0a7949a1a02539947418f0b7` then `7b07bb6e4faf40bd9809398c3a36194c` after evidence fill | — | valid=true, 0 issues |

Shared NativeEngine proof uses binary from build `ba09bbfe1fda4452aedffabe1946343d`. Earlier task-prefix GREEN RunIds remain the first case-level proofs; both NativeEngine runs re-executed those same public identities on the frozen 4.2 binary.

## Task prefixes

| Task | Prefix | First GREEN | Cases on NativeEngine `6f4ed80cd8fa46369d45f2e6bf6f4049` |
|---|---|---|---|
| 1.1 | VMFingerprints | `da59bd8c7d74404eabd7ec617423bd0c` 12/12 | IndependentPointsAgreeOnKeyWitnessAndHash, GoldenCanonicalBytesFixFieldOrderAndDomains, OneFactChangesAffectDeclaredDomains, MethodReturnChangesSchemaButNotIdentity, FunctionBodyAndSourceLocationDoNotChangeTypeFingerprints, InjectedEqualDigestsWithDifferentWitnessesAreCollisions, UnauthenticatedShellFreezeRejectsFingerprintQuery, BuildingAndIncompleteStatesRejectFingerprints, HandleCycleTerminatesAndValueCyclePublishesNoHash, ConcurrentReadsAgree, RetiredAuthenticDefinitionsRemainInspectable, EnumBaseInterfaceGenericAccessAndListChangeSchema |
| 1.2 | VMNativeLayout | `89929dc636f44653a040e1daf9d93fd3` 4/4 | NativeRecordPreservesHostOffsetsAndPadding, CompositeInlineAndIndirectHaveDistinctLayoutWitnesses, NativeAdmissionRejectsOverflowOverlapPackedAndFrozenMutation, SameKeyDifferentOffsetChangesLayoutHash |
| 1.3 | VMDetachedMetadata | `842b4870fa444d67bed842722e8d4eba` 6/6 | HandBuiltCounterNeedsNoEngineOrNumericIds, OrdinaryFunctionKeyCanAgreeWhenReturnTypeDiffers, ShellFreezeStillRejectsFingerprints, FunctionLeaseRetainsOwnerAfterFixtureRelease, ConcurrentLeaseReleaseFromHeldReference, InvalidSignatureAndFrozenMutationLeaveCountsUnchanged |
| 2.1 | VMByteCodeImage | `efd38d18971e4b34a3bd50d6b0acf614` | RoundTripAndCanonicalOrder, LabelLoopAndFunctionOrder, GoldenHeaderAndRejections, HandleCycleRequirementTerminates |
| 2.2 | VMByteCodeVerifier | `26e8a2acb796478c8aa7ec5710e460b8` | ValidConstantAndLoopPass, RejectsRetiredReservedAndMissingClosure, RejectsOutOfRangeJump |
| 2.3 | VMLinking | `b4598993f5a34862be83805643a489ad` | LinkResolvesOriginalFunctionPointers, MissingDeclarationAndBodyConflictReject |
| 3.1 | VMScalar | `e45b0f60e8014cd0b791a96031e3af29` | ExecuteConstantReturnFortyTwo (42), ExecuteAddSevenAndThirtyFive (7+35=42) |
| 3.2 | VMNativeCalls | `3b91de86ff9f4e2cbdf96b3216c027d9` 10/10 | BindNativeFunctionRequiresRegisteredDeclaration, GenericAddTwentyAndTwentyTwoReturnsFortyTwo, TypedCallerAddTwentyAndTwentyTwoReturnsFortyTwo, MethodReceiverValueSevenPlusFiveReturnsTwelveWithSentinels, BytecodeWritesNativeRecordValueAndPreservesPadding, NullIndirectCompositeThrowsBeforeWrite, UnsupportedThiscallOnFreeFunctionFailsBeforeCallback, UnboundSystemCallRejectsAtLink, NativeSetExceptionReportsVmException, GenericInt64BoolAndOutParameter |
| 3.3 | VMObjects | `054496a7b9b1436fa722caee1636628e` 7/7 | ScriptObjectTypeRegistersAndContextExecutes, PointFieldZeroRoundtrip, HeapAllocConstructorSetsXDestructorFiresOnce, AllocatedObjectReportsTypeAndEngine, CopyPreservesValueWithoutAliasing, DestructScriptAdvancesPastSentinel, NullObjectReferenceThrows |
| 3.4 | VMDispatch | `e844967229ec4e228fa679e53e6424dd` 10/10; adjacent GC-after-release `eb5616c8d5c041e2b9101cef4e1c4d6d` | MethodFunctionExecutesThroughSnapshot, DerivedDispatchThroughBaseChoosesTwo (CALLINTF=2), ExplicitBaseCallRemainsOne (CALL=1), FuncPtrCallPtrReturnsFortyTwo, NullCallPtrThrows, CastDerivedToBaseSucceedsUnrelatedFails, NullCastLeavesNull, BoundCallAndNativeCallReturnFortyTwo, BoundCallUnboundNativeThrows, DelegateCaptureReleasesReceiver |
| 3.5 | VMGC | `8879184379e248eeb670289d93c8096c` 9/9 | EngineGarbageCollectAfterExecution, UnrootedSelfCycleFinalizesOnce, UnrootedTwoNodeCycleFinalizesEachOnce, RootedCycleSurvivesThenDies, WeakRefValidThenInvalidAfterCollection, RefCpyVBalancesAddRefRelease, PreparedContextRootsLiveObject, FullAndIncrementalReachSameDestructorSet, DelegateCaptureCycleIsReclaimed |
| 3.6 | VMContexts | `f8b1fe6ca8aa4d2892f2fa550ba01238` 9/9 | IndependentContextsAndReprepare, IndependentThreadsPreserveResults, SuspendResumeAddsOneThenTwoReturnsThree, NestedNativeToScriptReturnsSeven, NestedInnerAbortRestoresOuter, ReentrantExecuteIsRejected, ThrowExceptionUnwindsOnce, JitEntryAndSaveReturnValueAdvance, ShutdownRejectsPrepareAndKeepsMetadataReadable |
| 4.1 | VMCache | `6678493bc56c4e918a06e0b5de8a0460` 9/9 | EncodedImageExecutesOnFreshEngineAfterProducerRelease, TwoLiveEnginesHaveIndependentSnapshots, NativeAddPortableAcrossFreshEngine, MissingDestinationFunctionRejectsWithoutMutation, MissingNativeBindingOnDestinationRejects, DestinationSchemaChangeRejectsLink, DestinationLayoutChangeRejectsLink, IndirectReferencedTypeMismatchRejects, TamperedBytesRejectDecode |
| 5.1 | VMSourceExpressions | `f8a9e38728074c1c9a41103c1c4e76fd` 7/7 | SourceOnePlusTwoTimesThreeIsSeven, SourceEightMinusThreeMinusOneIsFour, SourcePowerIsLeftAssociatedSixtyFour, SourceBitwiseOrEqualsIsTrue, SourceOnePlusTwoPointFiveIsThreePointFive, SourceAddWithRuntimeParameters, SourceUnaryMinusAndLocalAssignment |
| 5.2 | VMSourceControlFlow | `8748b89630f04b738bd1f6e0f587b8a7` 7/7 | SourceIfElseSelectsBranch, SourceWhileSumOneToTenIsFiftyFive, SourceForSkipTwoBreakFiveGivesEight (0+1+3+4=8), SourceWhileZeroVersusDoOnce (0 vs 1), SourceSwitchFallthroughAndDefault (1→3, 2→2, default→4), SourceLazyAndOrTernarySkipSideEffects, SourceLazyAndSkipsZeroDivisor (flag=0 finishes 0, flag=1 EXCEPTION) |
| 5.3 | VMSourceCalls | `c289d954e91f430fad1509ca0890bdee` 18/18 | SourceLiteralReturnExecutes, SourceCallerReturnsSeven, SourceForwardCalleeAfterCallerReturnsSeven, SourceFactorialZeroOneFive, SourceOverloadsReturnDistinctMarkers, SourceCombineNamedAndDefaultIsThirtyFour, SourcePackMarkPositionalAndNamedReturnTwelve, SourceFillAndBumpYieldFortyTwo, SourceInRefPreservesCallerValue, NativePackMarkTracesReverseFormal, NativeHostAddTwentyAndTwentyTwo, TypedDefaultMarkRunsPerCallSite, NativeSetExceptionReportsVmException, WrongNamedArgumentPublishesNoImage, MissingOverloadPublishesNoImage, OutTemporaryPublishesNoImage, MissingNativeBindingRejectsLink, UnsupportedThiscallBindingRejected |
| 5.4 | VMSourceObjects | `5e167f97180541b4a5bdd80008147bd3` 8/8 | SourceConstructOrdinalsRoundtripAndRejectBadVersion, SourceEmptyDefaultConstructCompletes, SourceFreeFunctionStillExecutes, SourcePairNamedConstructorFormalOrder, SourcePlainCopyReadsNine, SourceReverseDestroyOnReturn, SourceValueFieldWriteThenRead, SourceValueLocalSevenReadsSeven |
| 5.5 | VMSourceIntegration | `798d3e1c1a1c43eab169a20a6a294646` 4/4 | SourceProducedCacheRunsAfterProducerRelease (Value Local(Host::Mark(7)).Read()=7 on dest B; dest interned via 1.3 factories, no dest source compile), SourceMixedLoopObjectExceptionCache (for 1..3 sum=6 then Value.Read; flag=1 EXCEPTION then reprepare 6), MissingDestinationFunctionRejectsSourceCache, PreinstalledBodyRejectsSourceCache |
| 4.2 | NativeEngine + Baseline + validate | this document | VMIntegration 12/12 including mixed image, reserved/pseudo rejection, integer/shift/compare/jump, float/power, memory width, list-init + TrackRef/FinConstruct/CopyScript, Thiscall1, GlobalStoragePgaPshG4Roundtrip (SetG4 then LdGRdR4=42), GetObjMovesHandleThenGetRefReadsFortyTwo (84), JmppIndexOneSkipsNextStore (42), RemainingWidthShiftFloatJumpAliases (ADDIi 40+2=42; JP/JNS/JNP; NEGf/NEGd; DIVu/MODu; BNOT/BOR/BXOR/BSRL/BSRA) |

Detached metadata cases remain Engine-free (`GetEngine` null before registration). VM fixtures own a minimal SDK Engine. ASTCodec including CurrentVersion 8 ran in the same NativeEngine selector.

## 4.2 mixed image oracles

One image, several functions, executed in one Engine/Context:

| Observation | Oracle |
|---|---|
| Native property write | `NativeWrite` sets `Value=7`; Tag=3 and Weight=1.5 padding untouched |
| Virtual dispatch | `DispatchRun` ALLOC Derived + CALLINTF Base.Value returns 2 |
| Cycle collection | `CycleRun` self-REFCPY then FREE; dtor 0 after Execute, 1 after `GarbageCollect(asGC_FULL_CYCLE)` |
| Suspend/resume | `SuspendRun` SUSPENDED then 3 |
| Delegate ownership | `AllocTarget` + `CreateDelegate`; `ReleaseScriptObject` keeps dtor 0; `Delegate->Release` then GC fires dtor 1 |
| Weak state | flag false while live, true after delegate collection |
| Exception | `Throw` returns `asEXECUTION_EXCEPTION` twice after reprepare |

`MixedImageStillReturnsFortyTwo` remains the scalar control (PshC4 42 + RET).

## Opcode mapping

Explicit rejection (`VMIntegration.RejectsRetiredReservedAndPseudoOpcodes` plus 2.2): STR; every reserved ordinal 213–250; pseudo VarDecl/Block/ObjInfo/LINE/LABEL (251–255). Invalid jump: `RejectsOutOfRangeJump`.

Executed operand families with case paths on this binary:

| Family | Opcodes observed in tests | Case owners |
|---|---|---|
| Constants / return | PshC4, PshC8, RET, SetV4, SetV8, SetV1, SetV2, CpyVtoR4, CpyRtoV4, CpyVtoV4, CpyVtoR1, PshV4 | VMScalar, VMNativeCalls, VMIntegration |
| Integer arithmetic / bits / shift | ADDi, SUBi, MULi, DIVi, MODi, BSLL, BAND, NEGi, IncVi, POWi | VMScalar; VMIntegration.IntegerWidthShiftCompareAndJumpFamilies (return 42); FloatDoubleConversionAndPowerFamilies (3+8+5=16) |
| Compare / jump | CMPi, JS, JMP, JLowNZ, JZ, JNZ, TZ | VMIntegration integer family; VMSourceControlFlow lazy/switch; mixed |
| Width / memory | INCi8, LDV, ClrHi, PshRPtr, SwapPtr, PopPtr, PopRPtr, PSF, WRTV4, RDR4, RDSPtr, ADDSi | VMIntegration.MemoryWidthIncAndSwapFamilies (return 9); VMNativeCalls; VMObjects |
| Float / i64 convert | ADDf, fTOi, i64TOi, NEGf, NEGd | VMIntegration.FloatDoubleConversionAndPowerFamilies; RemainingWidthShiftFloatJumpAliases |
| Width aliases / unsigned | ADDIi, BNOT, NOT, BOR, BXOR, BSRL, BSRA, DIVu, MODu, JP, JNS, JNP | VMIntegration.RemainingWidthShiftFloatJumpAliases (return 42) |
| Globals | PGA, PshG4, LDG, CpyGtoV4, CpyVtoG4, SetG4, LdGRdR4 | VMIntegration.GlobalStoragePgaPshG4Roundtrip (bind C++ `int32`, SetG4 42, return 42, Storage=42) |
| GETOBJ family | GETOBJ, GETREF | VMIntegration.GetObjMovesHandleThenGetRefReadsFortyTwo (42+42=84) |
| JMPP | JMPP | VMIntegration.JmppIndexOneSkipsNextStore (index 1 skips the store of 0; return 42) |
| Objects | ALLOC, FREE, LOADOBJ, COPY, DestructScript, PshNull, CHKREF, LoadRObjR, LoadVObjR, ClrVPtr, STOREOBJ, FinConstruct, CopyScript | VMObjects, VMGC, VMDispatch, mixed; VMIntegration CopyScript null throws; ConstructRun ALLOC+FinConstruct+FREE returns 1 |
| List init | AllocMem, SetListSize, SetListType, PshListElmnt | VMIntegration list body writes 42 and reads 42 |
| Ref debug / null | TrackRef, UntrackRef, ValidateRef, ResolveObjectPtr, FreeNullV8, CmpPtrNull | VMIntegration list body (disabled-hook advance) |
| Native / system | CALLSYS, Thiscall1 | VMNativeCalls; VMIntegration.Thiscall1AddsSevenToReceiver (5+7=12) |
| Script / dispatch | CALL, CALLINTF, CALLBND, FuncPtr, CallPtr, Cast, TZ | VMDispatch, mixed DispatchRun |
| GC / handles | REFCPY, RefCpyV | VMGC, mixed CycleRun |
| Context | SUSPEND, ThrowException, JitEntry, SaveReturnValue | VMContexts, mixed SuspendRun/Throw |

Linker lowering for remaining `asBCInfo` operand types is table-driven (`as_bytecode_linker.cpp`); jump patching includes JS/JNS/JP/JNP/JLowZ/JLowNZ. `BindGlobalStorage` records Engine-owned C++ addresses keyed by stable global identity; link rejects unbound global slots with `MissingBinding`.

Explicit rejection remains only STR, reserved 213–250, and pseudo 251–255. Assigned runtime opcodes in the PGA/PshG4, GETOBJ, JMPP, Thiscall1, list-init, FinConstruct/CopyScript/ResolveObjectPtr, TrackRef, and remaining width/shift/float/compare/jump families above have executed cases on this binary. Completeness is not a handler-count claim.

## Source matrix reconciliation

| Matrix row | Executed? | Evidence |
|---|---|---|
| 5.1 1+2*3=7; 8-3-1=4; 2**3**2=64; 1\|2==3; 1+2.5=3.5; runtime params; unary minus | Yes | VMSourceExpressions 7/7 |
| 5.2 if/else 1/2/3; while sum 1..10=55; for skip-2/break-5=8; while-zero vs do-once; switch fallthrough/default | Yes | VMSourceControlFlow 7/7 |
| 5.2 && \|\| ?: skipped side effects; skipped `/0` safe, selected `/0` EXCEPTION | Yes | SourceLazyAndOrTernarySkipSideEffects; SourceLazyAndSkipsZeroDivisor |
| 5.3 Caller 7; factorial 0/1/5; overloads; Combine 34; Pack [2,1]=12; Fill/Bump 42; &in; Host::Add; native exception | Yes | VMSourceCalls 18/18 (`Marker()` typed default, not Host::Mark default) |
| 5.3 Host::Fill/Bump/Peek source syntax; rvalue-to-out; multi-file | No | QualTypeFromHost / ConvertTo; not claimed |
| 5.4 Value Local(7).Read; field write; Pair named `this.a`/`this.b`=12; Empty; Plain copy 9; reverse destroy | Yes | VMSourceObjects 8/8 |
| 5.4 Host::Mark ctor args; for-init continue/break lifetimes; stack-overflow/partial-ctor; reprepare 97; implicit `a=A` without `this.` | No | not claimed |
| 5.5 source cache after producer release; Value/Read + Host::Mark dest 1.3 factories; mixed loop+object+exception; missing dest function; preinstalled body | Yes | VMSourceIntegration 4/4; dest uses 1.3 factories, no source compilation |

## Dormancy

Baseline `93bdb999a8174b809010337c778ba330`: LegacySuiteExcludedByDefault, OptionalIntegrationsDormantByDefault, RuntimeDormantByDefault. No legacy source compile, global UE Engine pool, or JIT backend was activated by NativeEngine or Baseline.

## Intentionally omitted

| Check | Reason |
|---|---|
| Standalone / package | Outside this Change; reconstruction uses editor NativeEngine CQTest |
| JIT backend / StaticJIT | JitEntry is a VM marker only |
| Full UE suite / `ue.suite` All | Impact is SDK VM + canonical emitter, not Bindings/HotReload |
| UE Bindings | Explicitly out of scope |
| Harness Quick / Performance / Integration | No Harness route or protocol change |
| Cache V2 / SaveByteCode restore | Forbidden cache mode; definitions are pre-registered |

## Notes

CreateContext is enabled for the minimal SDK engine. Cache mode remains pre-registered definitions plus encoded image bytes. 4.2 mixed production VM object headers (`as_vm_object.cpp`) were not changed. Linker generic packing and Thiscall1/FinConstruct/CopyScript type-pointer lowering were ordinary defects required to execute the assigned opcode families.
