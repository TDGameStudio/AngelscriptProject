# Final acceptance verification

Frozen after GETOBJREF/LoadThisR oracles and remaining 8.6 drain cases. Writers of production/tests stopped before this freeze. Binary from `ue.build` RunId `6b7beb6d8de04188b769b3a06160f06f`. NativeEngine was executed twice on that identity. Historical 704/704 and the prior 902/902 freeze `8aee3fc0` are not this proof.

| Gate | RunId | Result |
|---|---|---|
| `ue.build` AngelscriptProjectEditor Win64 Development | `6b7beb6d8de04188b769b3a06160f06f` | Succeeded |
| `ue.test` `Angelscript.UnitTest.NativeEngine` Fast TimeoutMs 600000 (1) | `dfb0594750fd4af89e87b62a31435395` | Succeeded 909/909 |
| `ue.test` `Angelscript.UnitTest.NativeEngine` Fast TimeoutMs 600000 (2) | `07b76d4ef99344ec8a9eb346a7841067` | Succeeded 909/909 |
| `ue.test` `Angelscript.UnitTest.Baseline` Fast TimeoutMs 600000 | `4d823aa0011443ccbc112e63deeb5fe2` | PassedWithWarnings 3/3 (2 Succeeded + 1 SucceededWithWarnings, 2436 LogMetaSound warnings, 0 Failed) |
| Focused 8.6 `VMShutdownDrain` | `660375132bbf4199b18012417c57d463` | Succeeded 7/7 |
| Focused 9.3 `VMResourceOpcodeMatrix` | `7c845e7a1abb432a843082b76f9873bc` | Succeeded 14/14 |
| Adjacent `VMSourceUnwind` | `91feb332ddd143eaacdfd19fd687771c` | Succeeded |
| Adjacent `VMObjectLifetime` | `7ea14e3c8b334ea18e917b2bff7db2ac` | Succeeded |

| `openspec.validate` change `--strict --json` | `8ceadd083df64b5d9a5b498d96f8279e` | valid=true, 0 issues |

## Source and binary identity

| Artifact | SHA-256 |
|---|---|
| Concatenation of relative UTF-8 path + bytes for every `.h/.cpp/.inl` under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source` and `Plugins/Angelscript/Source/AngelscriptTest/NewVersion` (275 files, sorted FullName) | `60655185f21d4910796f9322943ba0a56119936513c3c52096026d594a83759a` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` (16011776 bytes) | `9f2963799b50150c6607243cc0e06d63cffff2cf5f30f63ea3da64edf734831d` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` (6906880 bytes) | `464d1159abd832454eae64ac923c1afd5388e04e03252309f2d57899d6f3f8cc` |

Corroborable copies: scratch `11.3-identity.txt` and `11.3-validate.json` under the implementer scratch directory, plus `attachments/data/11.3-identity.txt` in this Change.

Omitted: `Quick`, `Performance`, `Integration`, full UE suite, Standalone, JIT, UE Bindings. Reason: 11.3 verify is NativeEngine plus separate Baseline; those aggregates are outside the documented impact.

## F01–F10 indexed map (Reviews stay open)

Findings remain **open** on `review-20260906-112533-acceptance-gaps-reviewer.md`. Task GREEN does not close them. This table maps each finding to the freeze RunIds and the public cases that satisfy its original resolution condition.

Prefix `Angelscript.UnitTest.NativeEngine.` is omitted below. Freeze NativeEngine identities: `dfb0594750fd4af89e87b62a31435395` and `07b76d4ef99344ec8a9eb346a7841067`.

| Finding | Owners | Freeze proof | Public cases |
|---|---|---|---|
| F01 verifier operand/frame/CFG/cleanup | 6.3, 6.4, 6.5 | NativeEngine twice | VMOperandContracts.{AssignedOpcodesHaveDescriptorsOrStrRejects,ReservedAndPseudoOpcodesReject,JmpImmediateS32RejectsWrongTagDirectAndDecoded,SetV4MinLocalRejectsFrameRangeDirectAndDecoded,ImmediateWidthSlotRoleAndStringRejects,FrameSpanAlignmentCrossingAndZeroSizeRejects,ValidNegativeParameterAndInRangeLocalPass,FrameCleanupSourceCapturedAndInvalidResultRegionRejects}; VMFlowVerification.{PopPtrWithoutPushUnderflows,UnequalBranchJoinAndGrowingBackedgeReject,ValidBalancedLoopAndGuardedCleanupPass,DuplicateDestroyAndUnconstructedCleanupReject,MutationInvalidatesPriorAdmission}; VMFlowPath.{PshC4WithoutReturnRejectsFallthrough,CallSysWithoutArgumentPushesRejects,CallSysWithTwoPushesThenReturnSucceeds,DisjointNormalAndExceptionCleanupSucceeds,CleanupPastBodyAndMissingTypeReject,BothPathDuplicateDestroyStillRejects} |
| F02 immutable executable / atomic publish | 7.1, 7.2, 7.3 | NativeEngine twice | VMExecutableOwnership.{ScriptFortyTwoLeavesFrozenDeclarationUnchanged,NativeTwentyPlusTwentyTwoLeavesSysFuncIntfUnchanged,ForeignAndUnlinkedPrepareReject,TwoEnginesKeepIndependentExecutableStorage,FailedCandidateDoesNotInstallAndExistingBodySurvives,ExecutionSurvivesProducerRelease}; VMAtomicLink.{MissingSiblingLeavesFUnpublishedThenRetrySucceeds,UnboundNativeThenRetryAfterBind,ZeroDigestRequirementRejects,FailedFingerprintQueryRejects,WitnessCollisionRejectsDigestMatch,ReturnOnlyChangeRejects,OffsetOnlyPropertyChangeRejects,PointeeOnlyChangeRejects,RetiredAndForeignReject,FrozenTamperedMetadataRejects,FailedCandidateRestoresCountsAndSentinels,InstalledBodyRemainsCallableAfterFailedCandidate,TwoThreadsOnePublicationWinner}; VMExecutableLeases.{ExecuteAfterCallerSnapshotReleaseReturnsFortyTwo,NativePrepareExecuteAddTwentyAndTwentyTwo,MissingPublishedScriptPrepareReturnsNoFunction} |
| F03 per-opcode ledger | 9.1, 9.2, 9.3, 11.3 | NativeEngine twice; 9.3 focused `7c845e7a` 14/14 | Every 0–212 row in `opcode-inventory.md` names a public identity. GETOBJREF=`VMResourceOpcodeMatrix.GetObjRefReplacesStackWithHandleThenReadsSeventeen`. LoadThisR=`VMResourceOpcodeMatrix.LoadThisRReadsReceiverFieldSeventeenAndNullThrows`. STR/reserved/pseudo=`VMResourceOpcodeMatrix.RetiredAndReservedReject` |
| F04 native ABI / dispatch | 8.1, 8.2 | NativeEngine twice | VMNativeABI.{PaddedReceiverSevenPlusFiveReturnsTwelve,ObjectFirstAndLastReachReceiver,MultipleInheritanceAppliesBaseOffset,PrimitiveWidthsGenericAndTyped,InOutInoutAndForwardedReference,ValueObjectArgumentAndHandleReturn,RejectsMissingCallerUnsupportedNullReceiverAndThrowsOnce}; VMDispatchContracts.{InterfaceFactoryRequiresOwnerAndLeavesCountUnchanged,InterfaceCallSelectsDerivedWhileBaseCallStaysOne,FuncdefSignatureAcceptsMatchAndRejectsReturnMismatch,CallBndUnboundAndWrongSignatureRejectBeforeExecute,CallBndScriptAndNativeIndependentOracles,TwoDelegatesReleaseEachReceiverOnce} |
| F05 object/GC/Context/shutdown | 8.3, 8.4, 8.5, 8.6 | NativeEngine twice; 8.6 focused `66037513` 7/7 | VMObjectLifetime.{DestructorFiresThroughNativeBinding,HighAlignmentHeaderRecovers,NativeHandleIsNotProbedAsSdkHeader,PartialMemberFailureSkipsWholeObjectDestructor,ObjectSurvivesCallerSnapshotRelease}; VMRootLifetime.{SuspendedCycleSurvivesGcThenAbortFinalizesOnce,ConcurrentAddRefReleaseFinalizesOnce,FailedConstructorIsNotCollectedAsComplete,TwoEnginesKeepIndependentRoots,NestedNativeCollectLeavesInnerRootUntilUnwind}; VMContextBoundaries.{RecursionHitsStackLimitThenRecoveryNinetySeven,LineCallbackFiresWhenSetAndSilentWhenCleared,NestedNativeToScriptRestoresOuterAndReturnsSeven,TwoThreadsKeepIndependentLineCallbacks}; VMShutdownDrain.{NativeCallbackShutdownReturnsWithoutDeadlock,RepeatedShutdownIsIdempotentAndMetadataStaysReadable,ShutdownRejectsNewLinkAndPrepare,ShutdownAbortsSuspendedAndReleasesRoot,RetainedObjectDelaysDestroyUntilFinalRelease,ConcurrentPrepareVersusShutdownIsCoherent,BlockedNativeReleasedBySignalWithoutEarlyComplete} |
| F06 definition-free cache | 6.1, 7.2, 11.1, 11.2 | NativeEngine twice | VMImageContracts (all 7); VMAtomicLink (all 13); VMCacheContracts (all 14); VMSourceCacheContracts (all 9) |
| F07 source admission / typed lowering | 10.1, 10.2, 10.3 | NativeEngine twice | VMSourceAdmission (all 13); VMSourceNumeric (all 13); VMSourceCallContracts (all 14) |
| F08 source cleanup / unwind | 10.3, 10.4, 10.5, 11.2 | NativeEngine twice; unwind `91feb332` | VMSourceCallContracts.ConstructorOrdinalsRoundtripAndRejectCorrupt; VMSourceScopeCleanup (all 10); VMSourceUnwind (all 7); VMSourceCacheContracts.MixedLoopBodyObjectsContinueThrowRecoverOnAAndB |
| F09 completion/provenance | 11.3 | this freeze | This manifest, opcode row identities, NativeEngine 909/909 twice, Baseline warnings preserved, Reviews still CHANGES_REQUIRED |
| F10 bounded wire | 6.2 | NativeEngine twice | VMWireFormat.{EmptyImageMatchesIndependentGoldenAndRejectsV1,StringsPreserveExactUtf8BoundsAndRejectTruncatedMultibyte,MalformedCountsTargetsAndTrailingBytesReject,CanonicalOrderRoundtripPreservesContractsFrameAndCleanup} |

P01–P05 stay open on the progress Review. Owners: 7.3 (P01/P02), 6.5 (P03/P04), 8.3 (P05). Same freeze NativeEngine runs re-executed those public identities.

## Every 6.1–11.2 public case (indexed)

All of the following public identities executed on freeze NativeEngine `dfb05947` and `07b76d4e`. Focused GREEN RunIds remain the first case-level proofs.

### 6.1 VMImageContracts — focused GREEN retained; freeze NativeEngine

CompleteClosureCapturesFieldBaseReturnAndParameter; CyclicHandlesTerminate; SameFunctionKeyDifferentReturnHasDifferentContracts; DuplicateRoleKeyDifferentWitnessRejects; InjectedEqualDigestsDoNotHideWitnessMismatch; UnfrozenTypeRejectsFingerprintQuery; CanonicalContractBytesMatchDocumentedOrder.

### 6.2 VMWireFormat

EmptyImageMatchesIndependentGoldenAndRejectsV1; StringsPreserveExactUtf8BoundsAndRejectTruncatedMultibyte; MalformedCountsTargetsAndTrailingBytesReject; CanonicalOrderRoundtripPreservesContractsFrameAndCleanup.

### 6.3 VMOperandContracts

AssignedOpcodesHaveDescriptorsOrStrRejects; ReservedAndPseudoOpcodesReject; JmpImmediateS32RejectsWrongTagDirectAndDecoded; SetV4MinLocalRejectsFrameRangeDirectAndDecoded; ImmediateWidthSlotRoleAndStringRejects; FrameSpanAlignmentCrossingAndZeroSizeRejects; ValidNegativeParameterAndInRangeLocalPass; FrameCleanupSourceCapturedAndInvalidResultRegionRejects.

### 6.4 VMFlowVerification

PopPtrWithoutPushUnderflows; UnequalBranchJoinAndGrowingBackedgeReject; ValidBalancedLoopAndGuardedCleanupPass; DuplicateDestroyAndUnconstructedCleanupReject; MutationInvalidatesPriorAdmission.

### 6.5 VMFlowPath — focused GREEN `1bec4eda00864c75b33e85233efdf454`

PshC4WithoutReturnRejectsFallthrough; CallSysWithoutArgumentPushesRejects; CallSysWithTwoPushesThenReturnSucceeds; DisjointNormalAndExceptionCleanupSucceeds; CleanupPastBodyAndMissingTypeReject; BothPathDuplicateDestroyStillRejects.

### 7.1 VMExecutableOwnership

ScriptFortyTwoLeavesFrozenDeclarationUnchanged; NativeTwentyPlusTwentyTwoLeavesSysFuncIntfUnchanged; ForeignAndUnlinkedPrepareReject; TwoEnginesKeepIndependentExecutableStorage; FailedCandidateDoesNotInstallAndExistingBodySurvives; ExecutionSurvivesProducerRelease.

### 7.2 VMAtomicLink

MissingSiblingLeavesFUnpublishedThenRetrySucceeds; UnboundNativeThenRetryAfterBind; ZeroDigestRequirementRejects; FailedFingerprintQueryRejects; WitnessCollisionRejectsDigestMatch; ReturnOnlyChangeRejects; OffsetOnlyPropertyChangeRejects; PointeeOnlyChangeRejects; RetiredAndForeignReject; FrozenTamperedMetadataRejects; FailedCandidateRestoresCountsAndSentinels; InstalledBodyRemainsCallableAfterFailedCandidate; TwoThreadsOnePublicationWinner.

### 7.3 VMExecutableLeases — focused GREEN `8ff7688d7e6a464583e00b7ee0e4a70f`

ExecuteAfterCallerSnapshotReleaseReturnsFortyTwo; NativePrepareExecuteAddTwentyAndTwentyTwo; MissingPublishedScriptPrepareReturnsNoFunction.

### 8.1 VMNativeABI

PaddedReceiverSevenPlusFiveReturnsTwelve; ObjectFirstAndLastReachReceiver; MultipleInheritanceAppliesBaseOffset; PrimitiveWidthsGenericAndTyped; InOutInoutAndForwardedReference; ValueObjectArgumentAndHandleReturn; RejectsMissingCallerUnsupportedNullReceiverAndThrowsOnce.

### 8.2 VMDispatchContracts

InterfaceFactoryRequiresOwnerAndLeavesCountUnchanged; InterfaceCallSelectsDerivedWhileBaseCallStaysOne; FuncdefSignatureAcceptsMatchAndRejectsReturnMismatch; CallBndUnboundAndWrongSignatureRejectBeforeExecute; CallBndScriptAndNativeIndependentOracles; TwoDelegatesReleaseEachReceiverOnce.

### 8.3 VMObjectLifetime — focused GREEN `0aa02e24e47b490c930c6730abc4f785`; adjacent this freeze `7ea14e3c`

DestructorFiresThroughNativeBinding; HighAlignmentHeaderRecovers; NativeHandleIsNotProbedAsSdkHeader; PartialMemberFailureSkipsWholeObjectDestructor; ObjectSurvivesCallerSnapshotRelease.

### 8.4 VMRootLifetime — focused GREEN `2443b9077b3241e098a10d9de9c6f7b0`

SuspendedCycleSurvivesGcThenAbortFinalizesOnce; ConcurrentAddRefReleaseFinalizesOnce; FailedConstructorIsNotCollectedAsComplete; TwoEnginesKeepIndependentRoots; NestedNativeCollectLeavesInnerRootUntilUnwind.

### 8.5 VMContextBoundaries — focused GREEN `fc7764a775134525a1078e6d270af079`

RecursionHitsStackLimitThenRecoveryNinetySeven; LineCallbackFiresWhenSetAndSilentWhenCleared; NestedNativeToScriptRestoresOuterAndReturnsSeven; TwoThreadsKeepIndependentLineCallbacks.

### 8.6 VMShutdownDrain — focused GREEN `660375132bbf4199b18012417c57d463` 7/7 (supersedes historical 2/2 `02e18990`)

NativeCallbackShutdownReturnsWithoutDeadlock; RepeatedShutdownIsIdempotentAndMetadataStaysReadable; ShutdownRejectsNewLinkAndPrepare; ShutdownAbortsSuspendedAndReleasesRoot; RetainedObjectDelaysDestroyUntilFinalRelease; ConcurrentPrepareVersusShutdownIsCoherent; BlockedNativeReleasedBySignalWithoutEarlyComplete.

### 9.1 VMIntegerOpcodeMatrix — focused GREEN `4e34f49fa4d74583b52c824cddddff70`

ConstantMovesAndWidths; Integer32Arithmetic; Integer64Arithmetic; UnsignedDivMod; PowerIntegerAndOverflow; Bitwise32; Bitwise64; NegIncDec; IntegerConversions; ComparisonsAndTestFlags; ConditionalJumpsTakenAndNotTaken; TerminatingLoopSumOneToTen; JumpTableEachArmDefaultAndMalformed; StackPointerAndVar; MemoryWidthsWithSentinels; GlobalMoves; NegativeArgOffsetsVersusPositiveLocals; DivModByZeroTypedException.

### 9.2 VMFloatingOpcodeMatrix — focused GREEN `61b28b69f17c49228842418de1c6b1be`

FloatArithmeticAndImmediate; DoubleArithmetic; NegIncDecFloatDouble; FloatDoubleComparisons; IntegerFloatConversions; WideFloatConversions; PowerFloatAndDomain.

### 9.3 VMResourceOpcodeMatrix — focused GREEN `7c845e7a1abb432a843082b76f9873bc` 14/14 (supersedes historical 12/12 `e7f1fe6f`)

RetiredAndReservedReject; NestedCallAndReturn; CallSysReturnsFortyTwo; CallBndScriptAndNative; FuncPtrCallPtrAndNull; ListCopyTypeIdAndNullChecks; ObjectAllocCopyFreeAndGetRef; GetObjGetRefChkAndAddSi; NullChecksThrow; ObserversMarkersSuspendAndThrow; CastStoreLoadAndCallIntf; Thiscall1AddsSevenToReceiver; GetObjRefReplacesStackWithHandleThenReadsSeventeen; LoadThisRReadsReceiverFieldSeventeenAndNullThrows.

### 10.1 VMSourceAdmission — focused GREEN `570c74ef54d94feda947c9d8c913fce2`

NullSessionOrDefinitionsReturnInvalidInput; UnverifiedSessionReturnsNotReady; BodiesOnlySessionReturnsNotReady; RecoverySessionReturnsInvalidInput; UnfrozenDefinitionsReturnNotReady; ForeignEqualKeyDefinitionsReturnInvalidInput; UnsupportedTargetReturnsUnsupportedLowering; ResourceBudgetReturnsResourceLimit; VerifiedSupportedBodySucceedsEngineFree; UnsupportedBodyPublishesNoPartialImage; DiagnosticsSurviveProducerDestruction; AdapterDoesNotMutateFrozenParameterOffsets; ValidEmissionLinksThroughAtomicPublish.

### 10.2 VMSourceNumeric — focused GREEN `70451756de3e42e683957f5c5860b979`

DoubleSubtractLiteralEmitsSubdNotAddd; DoubleMultiplyLiteralEmitsMuldNotAddd; DoubleDivideLiteralEmitsDivd; DoubleOpsThroughParameterLocalCastAndConditional; FloatCompareAssignAndNonIntCast; Int64Above32BitsPreserved; UnsignedHighBitCompareAndDivide; NarrowSignExtension; BoolOrPreserved; EnumValuePreserved; IntegerControlStillSeven; FrameAbove64DwordsExecutesWhenBudgetAllows; OverBudgetFrameRejectsWithoutImage.

### 10.3 VMSourceCallContracts — focused GREEN `cf5f4baee0f043b69bba3d487107ec6c`

ConstOutRvalueMismatchesReject; ConstructorOrdinalsRoundtripAndRejectCorrupt; ExplicitArgSuppressesTypedDefault; ImplicitThisMemberAccessReturnsSeven; MetadataStringDefaultExplicitSucceeds; MetadataStringDefaultOmitRejectsWithoutImage; NativeFillBumpPeekForwardedRefWritesFortyTwo; NativeFillBumpPeekLocalWritesFortyTwo; NativeFillBumpPeekMemberWritesFortyTwo; PairNamedCtorStoresWithReverseFormalTrace; PositionalNamedReverseFormalTraceTwelve; ScriptFillRunsThenLiteralOutRejects; TwoFilesEitherOrderReturnSevenWithLocations; TypedDefaultHostMarkTwiceIsSixtyEight.

### 10.4 VMSourceScopeCleanup — focused GREEN `74581d36a718454baf249f2f2df78f33`

BreakDestroysBodyBeforeInitializer; EarlyReturnPreservesValueThroughDestructors; ForInitSurvivesContinueBodyDestroyedEachIteration; IntegerControlStillSeven; NestedForBreakSelectsNearest; NestedInnerDestroysBeforeMarkerThenOuter; NestedWhileContinueUsesBackedge; NoDuplicateDestructionOnNestedScopes; SwitchBreakSelectsNearest; UntakenConstructionBranchHasNoDestructor.

### 10.5 VMSourceUnwind — focused GREEN `ea87de20a01340499fc7214a156c66b1`; this freeze adjacent `91feb332`

TwoLocalsDivByZeroUnwindsReverseThenRecoveryNinetySeven; NativeFailUnwindsReverseThenRecoveryNinetySeven; BrokenConstructorDestroysCompletedLocalOnly; NestedMemberPartialConstructionOrder; StackLimitReportsSourceLocationThenRecovery; SourceRecordsSurviveEncodeDecodeAndProducerRelease; IntegerControlStillSeven.

### 11.1 VMCacheContracts — focused GREEN `9d531ab6d2164e9397046dd78a9268b3`

NamespacedStringAndGenericExecuteOnFreshEngineAfterProducerRelease; NativeCallbackAndGlobalStorageUseBPointers; FuncdefAndMethodSignatureResolveOnB; MissingTypeRejectsWithoutInstalling; ChangedReturnSameFunctionKeyRejects; ChangedParameterModeRejects; OffsetOnlyNativeLayoutRejects; InjectedEqualDigestDifferentWitnessRejects; FailedFingerprintQueryRejects; ForeignAttachedImageRejectsOnSecondEngine; MalformedPointerProfileRejects; LateMissingFunctionLeavesInstalledBodyAndSentinel; DecodeDoesNotCreateDefinitionsOnB; VersionOneBytesRejectDecode.

### 11.2 VMSourceCacheContracts — focused GREEN `dead4cd3d0644e19ae58c38731b74870`

IntegerControlStillSeven; SourceCacheExecutesOnBAfterProducerRelease; MixedLoopBodyObjectsContinueThrowRecoverOnAAndB; MissingClassRejectsWithoutInstalling; MissingFreeFunctionRejectsWithoutInstalling; ChangedMethodReturnRejects; MissingNativeBindingRejects; ForeignImageRejects; ConflictingBodyLeavesInstalledCallable.

Opcode rows 0–212 plus reserved/pseudo rejection remain owned by 9.1/9.2/9.3 and `VMIntegration` on this 909/909 run. STR is rejected. FormatVersion 2. Cache mode remains pre-registered definitions plus encoded image.

## Review disposition

F01–F10 and P01–P05 stay **open** on the existing External Review files. Task GREEN and this NativeEngine run do not close findings. Re-evaluation requires an explicit user-requested new fixed snapshot. This record is the snapshot those Reviews can be re-run against.

## Honest residuals (not claimed closed)

- `FailedConstructorIsNotCollectedAsComplete` proves Execute does not invoke the destructor. Full-cycle GC of an ALLOC-before-ctor SDK object is not claimed; ALLOC still notifies GC before construction.
- Spec sync, archive, commit, and push are not performed by this node.
- 8.7/9.4 were not added; remaining 8.6/9.3 oracles were implemented in the existing Files without unchecking those nodes.
