> Historical pre-native-generation acceptance. The later source/DLL/report identities and 1068/1068 selection are recorded in final-native-binding-acceptance.md; the original evidence below is retained.

# Final VM acceptance reconciliation

Captured 2026-09-08T11:30:42.928801+08:00. Task 11.4 product verification is GREEN; historical Review lifecycle closure follows a new immutable re-evaluation. Earlier reports and failures remain historical evidence.

## Final frozen source and execution

- Build: 18cb75dcb7db4be58f02858803eae4b7, Succeeded.
- Complete NativeEngine: 1eb0149a83f74aebbce0a2562955b788, 1061/1061 Success; zero warnings, failures, skipped or in-process cases. Raw report SHA-256 `8ad902abd8e7af5ae95842f565e99781d8648e87f2f710fa6fb29d1c08352bdf`.
- Separate Baseline: d637b6f4c989452b95eaf85c4bd4c5f8, 3/3 Success on the same binary; 2,436 warning events recorded in LegacySuiteExcludedByDefault (MetaSound test-tag registration). No warnings were suppressed. Raw report SHA-256 `41781a2a755529764de2599269765ece069aa5eddaeb3c9a9effe9471706ee48`.
- Source inventory: `a0d20df5fb82b9f85b3c8fb8d4f1054f4becbbe598cf6b6636bc2e1e0d2d8666`, 2316 source entries. Full source inventory and DLL identities: Saved/vm-acceptance-repaired-identity.json. Writers were frozen through build and both runs.

| Binary | SHA-256 |
|---|---|
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptEditor.dll | 95e4530574581ebd4769f4b765f757c2ab49f68ea0a03020c13bf381d0e91583 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | 43ff94fe096f1701ba56a48ac3f89387d3d3883fe92e26e1a62a3469f671e293 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | 61ceeeb685913e200c27ea21793d56e31d15f58ef7110e5f57aa8f4a76a96db7 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTestJIT.dll | 12ae6b0b9fc7a6492b57bf76a45f674dfd1e1f1fb903e112a1c314193f69a7a7 |

Both tests use current-process Harness `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = <exact prefix>; Fast = $true; NoWait = $true; TimeoutMs = 600000 }`. Prefixes are Angelscript.UnitTest.NativeEngine and Angelscript.UnitTest.Baseline. All final evidence is copied into the immutable Review snapshot with per-file hashes.

## Adjacent producer repair and supplemental controls

Pre-repair full NativeEngine d79c56748ef6470ea491721049f73186 passed 1058/1061 with three CallableSDK assertion failures. Two manual CallPtr sites still used the old one-operand format; their scalar method helper and Invoke RET also predated the authenticated argument/return ABI. Only CallableSDKTests.cpp changed: explicit expected FunctionSlot, a real receiver-free delegate shape, exact argument/return widths, and explicit scalar result register emission. The original callback result 42, incompatible-return replacement rejection and receiver destruction count assertions are preserved. All three execute successfully in the final full run. No production or AST fix was needed for these failures.

VMFlowAdmission additionally executes direct/decoded final JZ/JNZ rejection, valid unconditional backward-edge admission, and decoded result spans of 65 DWORDs in 64/65 DWORD frames plus an oversized full-width case. The backward unconditional loop is verified, not executed indefinitely. These are supplemental GREEN controls for already repaired behavior; no retroactive RED is claimed.

6.13 manual-image history remains in residual-admission-verification.md: six assertion failures/nine controls before repair, 447/447 shared VM and 15/15 stomp afterwards. Final full run includes all 15. Bounded malformed images are rejected before execution; the legal deep-stack case executes three times with a 64-byte initial stack and a minimum 68-DWORD allocation oracle.

## Task selectors represented in the final report

The final report contains 448 VM-prefixed cases, including 112 source-producer cases. The following exact task selectors are matched against individual report identities, not inferred from total counts. Historical grouped RED/GREEN remains in the task-specific earlier evidence.

| Task | Exact selection | Matched Success cases |
|---|---|---|
| 1.1 | Angelscript.UnitTest.NativeEngine.VMFingerprints | 12 |
| 1.2 | Angelscript.UnitTest.NativeEngine.VMNativeLayout | 4 |
| 1.3 | Angelscript.UnitTest.NativeEngine.VMDetachedMetadata | 6 |
| 2.1 | Angelscript.UnitTest.NativeEngine.VMByteCodeImage | 4 |
| 2.2 | Angelscript.UnitTest.NativeEngine.VMByteCodeVerifier | 3 |
| 2.3 | Angelscript.UnitTest.NativeEngine.VMLinking | 2 |
| 3.1 | Angelscript.UnitTest.NativeEngine.VMScalar | 2 |
| 3.2 | Angelscript.UnitTest.NativeEngine.VMNativeCalls | 10 |
| 3.3 | Angelscript.UnitTest.NativeEngine.VMObjects | 7 |
| 3.4 | Angelscript.UnitTest.NativeEngine.VMDispatch | 16 |
| 3.5 | Angelscript.UnitTest.NativeEngine.VMGC | 9 |
| 3.6 | Angelscript.UnitTest.NativeEngine.VMContexts | 9 |
| 4.1 | Angelscript.UnitTest.NativeEngine.VMCache | 23 |
| 4.2 | Angelscript.UnitTest.NativeEngine | 1061 |
| 5.1 | Angelscript.UnitTest.NativeEngine.VMSourceExpressions | 7 |
| 5.2 | Angelscript.UnitTest.NativeEngine.VMSourceControlFlow | 7 |
| 5.3 | Angelscript.UnitTest.NativeEngine.VMSourceCalls | 18 |
| 5.4 | Angelscript.UnitTest.NativeEngine.VMSourceObjects | 8 |
| 5.5 | Angelscript.UnitTest.NativeEngine.VMSourceIntegration | 4 |
| 6.1 | Angelscript.UnitTest.NativeEngine.VMImageContracts | 7 |
| 6.2 | Angelscript.UnitTest.NativeEngine.VMWireFormat | 4 |
| 6.3 | Angelscript.UnitTest.NativeEngine.VMOperandContracts | 8 |
| 6.4 | Angelscript.UnitTest.NativeEngine.VMFlowVerification | 5 |
| 6.5 | Angelscript.UnitTest.NativeEngine.VMFlowPath | 6 |
| 6.6 | Angelscript.UnitTest.NativeEngine.VMFlowAdmission | 8 |
| 7.1 | Angelscript.UnitTest.NativeEngine.VMExecutableOwnership | 6 |
| 7.2 | Angelscript.UnitTest.NativeEngine.VMAtomicLink | 13 |
| 7.3 | Angelscript.UnitTest.NativeEngine.VMExecutableLeases | 3 |
| 8.1 | Angelscript.UnitTest.NativeEngine.VMNativeABI | 7 |
| 8.2 | Angelscript.UnitTest.NativeEngine.VMDispatchContracts | 6 |
| 8.3 | Angelscript.UnitTest.NativeEngine.VMObjectLifetime | 5 |
| 8.4 | Angelscript.UnitTest.NativeEngine.VMRootLifetime | 5 |
| 8.5 | Angelscript.UnitTest.NativeEngine.VMContextBoundaries | 4 |
| 8.6 | Angelscript.UnitTest.NativeEngine.VMShutdownDrain | 7 |
| 9.1 | Angelscript.UnitTest.NativeEngine.VMIntegerOpcodeMatrix | 18 |
| 9.2 | Angelscript.UnitTest.NativeEngine.VMFloatingOpcodeMatrix | 7 |
| 9.3 | Angelscript.UnitTest.NativeEngine.VMResourceOpcodeMatrix | 14 |
| 10.1 | Angelscript.UnitTest.NativeEngine.VMSourceAdmission | 13 |
| 10.2 | Angelscript.UnitTest.NativeEngine.VMSourceNumeric | 13 |
| 10.3 | Angelscript.UnitTest.NativeEngine.VMSourceCallContracts | 14 |
| 10.4 | Angelscript.UnitTest.NativeEngine.VMSourceScopeCleanup | 11 |
| 10.5 | Angelscript.UnitTest.NativeEngine.VMSourceUnwind | 8 |
| 11.1 | Angelscript.UnitTest.NativeEngine.VMCacheContracts | 14 |
| 11.2 | Angelscript.UnitTest.NativeEngine.VMSourceCacheContracts | 9 |
| 11.3 | Angelscript.UnitTest.NativeEngine | 1061 |
| 6.7 | Angelscript.UnitTest.NativeEngine.VMCallAdmission | 12 |
| 6.8 | Angelscript.UnitTest.NativeEngine.VMLifetimeAdmission | 12 |
| 6.9 | Angelscript.UnitTest.NativeEngine.VMFrameAdmission | 13 |
| 6.10 | Angelscript.UnitTest.NativeEngine.VMReturnAdmission | 11 |
| 6.11 | Angelscript.UnitTest.NativeEngine.VMIndirectAdmission | 15 |
| 6.12 | Angelscript.UnitTest.NativeEngine.VMIndexedAdmission | 12 |
| 6.13 | Angelscript.UnitTest.NativeEngine.VMManualAdmission | 15 |
| 11.4 | Angelscript.UnitTest.NativeEngine | 1061 |

## Opcode and source obligations

All 213 assigned opcode rows in opcode-inventory.md map to an individually discovered Success identity in the final report: 212 supported execution dispositions and retired STR rejection. Reserved 213–250 and pseudo 251–255 share the explicit rejection case. The ledger supplies exact variant ownership; the test source supplies emitted paths and independent numeric/state/lifetime oracles. Marker execution does not imply a JIT backend.

The source-execution-matrix.md retains its original planning inputs and exclusions. Its accepted runtime obligations are represented by VMSourceExpressions/Numeric, VMSourceControlFlow/ScopeCleanup, VMSourceCalls/CallContracts, VMSourceObjects/Unwind and VMSourceCacheContracts. VMSourceAdmission covers sealed/mismatched/recovery/unsupported inputs with no partial image. All 112 source-producer identities below executed in the final run; direct VM success is not substituted for them.

## Review finding proof ownership

| Historical findings | Resolving tasks | Final proof groups and independently observed contract |
|---|---|---|
| F01, P03, R01/R02, V01/V02/V04, W01, X01–X04 | 6.1–6.13, 11.4 | VMOperandContracts, VMFlowVerification/Path/Admission, VMCall/Lifetime/Frame/Return/Indirect/Indexed/ManualAdmission: exact kinds, widths, signed frame coordinates, complete signature consumption, both conditional edges, all table edges, atomic rejection and measured stack reservation. |
| P04, R03, V03, W02 | 6.8, 6.12 | VMLifetimeAdmission plus VMSourceUnwind and VMIndexedAdmission: CFG state joins, per-PC initialized locals, safe partial construction and recovery. |
| F02, P01/P02 | 7.1–7.3 | VMExecutableOwnership, VMAtomicLink, VMExecutableLeases: immutable declarations, candidate publication/rollback, retained execution and nonrecursive no-code rejection. |
| F03 | 9.1–9.3 | Complete 213-row ledger mapped to final Success identities with integer/floating/resource execution oracles. |
| F04, P05 | 8.1/8.2, 6.11, 11.4 | VMNativeABI, VMDispatchContracts, VMIndirectAdmission and LanguageSurface.CallableSDK: host value/receiver/sentinel results, full target signatures, valid delegates and cleanup. |
| F05 | 8.3–8.6 | VMObjectLifetime, VMRootLifetime, VMContextBoundaries, VMShutdownDrain: payload ownership, partial construction, root/weak/GC stress, nested failure and deferred shutdown. |
| F06 | 6.1, 11.1/11.2 | VMImageContracts/Fingerprints/CacheContracts/SourceCacheContracts: full witnesses, schema/layout/type-use/host shape mismatches, independent destination storage and atomic rejection. |
| F07 | 10.1/10.2 | VMSourceAdmission/Numeric: exact typed operations, runtime-input float subtraction/multiplication, wide values and explicit unsupported admission. |
| F08 | 10.3–10.5, 11.2, 6.8 | VMSourceCallContracts/ScopeCleanup/Unwind/CacheContracts: formal mapping/side-effect order, lexical exits, constructed-only reverse cleanup, owned observations and return-97 recovery. |
| F09, R04 | 11.3/11.4 | Exact source/DLL/report identity, task selectors, per-opcode and source case mapping, preserved historical failures and honest exclusions. Final task closes only after immutable re-evaluation. |
| F10 | 6.1/6.2, 11.1 | VMWireFormat/VMImageContracts/VMCacheContracts: bounded string reads, independent complete minimal vector, deterministic resources/slot remap and all-section roundtrip. |

## Exact VM and affected adjacent identities

Each entry below is Success in 1eb0149a83f74aebbce0a2562955b788. Prefix Angelscript.UnitTest.NativeEngine. is omitted only for readability.
- LanguageSurface.CallableSDK.BoundNamedCallbackReleasesItsReceiverExactlyOnce
- LanguageSurface.CallableSDK.CallableSignatureLeaseSurvivesProducerRelease
- LanguageSurface.CallableSDK.NamedScriptAndGenericNativeCallbacksExecuteFortyTwoIndirectly
- LanguageSurface.CallableSDK.NominalDelegateAndEventShareOnlyTheirStructuralSignature
- LanguageSurface.CallableSDK.OldNominalFactoryAndChildFactoryAreAbsent
- LanguageSurface.CallableSDK.OldTypeSignatureAndChildQueriesAreAbsent
- LanguageSurface.CallableSDK.ReturnTypeMismatchCannotReplaceTheInstalledCallable
- LanguageSurface.CallableSDK.StringDeclarationRegistrationAndEngineEnumerationAreAbsent
- VMAtomicLink.FailedCandidateRestoresCountsAndSentinels
- VMAtomicLink.FailedFingerprintQueryRejects
- VMAtomicLink.FrozenTamperedMetadataRejects
- VMAtomicLink.InstalledBodyRemainsCallableAfterFailedCandidate
- VMAtomicLink.MissingSiblingLeavesFUnpublishedThenRetrySucceeds
- VMAtomicLink.OffsetOnlyPropertyChangeRejects
- VMAtomicLink.PointeeOnlyChangeRejects
- VMAtomicLink.RetiredAndForeignReject
- VMAtomicLink.ReturnOnlyChangeRejects
- VMAtomicLink.TwoThreadsOnePublicationWinner
- VMAtomicLink.UnboundNativeThenRetryAfterBind
- VMAtomicLink.WitnessCollisionRejectsDigestMatch
- VMAtomicLink.ZeroDigestRequirementRejects
- VMByteCodeImage.GoldenHeaderAndRejections
- VMByteCodeImage.HandleCycleRequirementTerminates
- VMByteCodeImage.LabelLoopAndFunctionOrder
- VMByteCodeImage.RoundTripAndCanonicalOrder
- VMByteCodeVerifier.RejectsOutOfRangeJump
- VMByteCodeVerifier.RejectsRetiredReservedAndMissingClosure
- VMByteCodeVerifier.ValidConstantAndLoopPass
- VMCache.DestinationLayoutChangeRejectsLink
- VMCache.DestinationSchemaChangeRejectsLink
- VMCache.EncodedImageExecutesOnFreshEngineAfterProducerRelease
- VMCache.IndirectReferencedTypeMismatchRejects
- VMCache.MissingDestinationFunctionRejectsWithoutMutation
- VMCache.MissingNativeBindingOnDestinationRejects
- VMCache.NativeAddPortableAcrossFreshEngine
- VMCache.TamperedBytesRejectDecode
- VMCache.TwoLiveEnginesHaveIndependentSnapshots
- VMCacheContracts.ChangedParameterModeRejects
- VMCacheContracts.ChangedReturnSameFunctionKeyRejects
- VMCacheContracts.DecodeDoesNotCreateDefinitionsOnB
- VMCacheContracts.FailedFingerprintQueryRejects
- VMCacheContracts.ForeignAttachedImageRejectsOnSecondEngine
- VMCacheContracts.FuncdefAndMethodSignatureResolveOnB
- VMCacheContracts.InjectedEqualDigestDifferentWitnessRejects
- VMCacheContracts.LateMissingFunctionLeavesInstalledBodyAndSentinel
- VMCacheContracts.MalformedPointerProfileRejects
- VMCacheContracts.MissingTypeRejectsWithoutInstalling
- VMCacheContracts.NamespacedStringAndGenericExecuteOnFreshEngineAfterProducerRelease
- VMCacheContracts.NativeCallbackAndGlobalStorageUseBPointers
- VMCacheContracts.OffsetOnlyNativeLayoutRejects
- VMCacheContracts.VersionOneBytesRejectDecode
- VMCallAdmission.DecodedRealDoubleCallReturnsFortyTwo
- VMCallAdmission.EqualHeightAddressValueMergeRejects
- VMCallAdmission.InvalidCategoryModeAndAggregateWidthRejectDirectAndDecoded
- VMCallAdmission.MixedArgumentsAndReceiverConsumeExactStorage
- VMCallAdmission.RealDoubleAndInt64RejectOneDwordArguments
- VMCallAdmission.RealWideCallsBalanceLoopAndDecode
- VMCallAdmission.ReferenceModesAcceptLocalAddressAndPointerLoad
- VMCallAdmission.ReferenceModesRejectScalarBitsOfPointerWidth
- VMCallAdmission.SwapPtrRequiresTwoCompletePointers
- VMCallAdmission.TamperedReturnStorageRejectsBeforePublication
- VMCallAdmission.TamperedWidthCannotAuthenticateAtTarget
- VMCallAdmission.UnknownZeroAndOversizedStorageReject
- VMContextBoundaries.LineCallbackFiresWhenSetAndSilentWhenCleared
- VMContextBoundaries.NestedNativeToScriptRestoresOuterAndReturnsSeven
- VMContextBoundaries.RecursionHitsStackLimitThenRecoveryNinetySeven
- VMContextBoundaries.TwoThreadsKeepIndependentLineCallbacks
- VMContexts.IndependentContextsAndReprepare
- VMContexts.IndependentThreadsPreserveResults
- VMContexts.JitEntryAndSaveReturnValueAdvance
- VMContexts.NestedInnerAbortRestoresOuter
- VMContexts.NestedNativeToScriptReturnsSeven
- VMContexts.ReentrantExecuteIsRejected
- VMContexts.ShutdownRejectsPrepareAndKeepsMetadataReadable
- VMContexts.SuspendResumeAddsOneThenTwoReturnsThree
- VMContexts.ThrowExceptionUnwindsOnce
- VMDetachedMetadata.ConcurrentLeaseReleaseFromHeldReference
- VMDetachedMetadata.FunctionLeaseRetainsOwnerAfterFixtureRelease
- VMDetachedMetadata.HandBuiltCounterNeedsNoEngineOrNumericIds
- VMDetachedMetadata.InvalidSignatureAndFrozenMutationLeaveCountsUnchanged
- VMDetachedMetadata.OrdinaryFunctionKeyCanAgreeWhenReturnTypeDiffers
- VMDetachedMetadata.ShellFreezeStillRejectsFingerprints
- VMDispatch.BoundCallAndNativeCallReturnFortyTwo
- VMDispatch.BoundCallUnboundNativeThrows
- VMDispatch.CastDerivedToBaseSucceedsUnrelatedFails
- VMDispatch.DelegateCaptureReleasesReceiver
- VMDispatch.DerivedDispatchThroughBaseChoosesTwo
- VMDispatch.ExplicitBaseCallRemainsOne
- VMDispatch.FuncPtrCallPtrReturnsFortyTwo
- VMDispatch.MethodFunctionExecutesThroughSnapshot
- VMDispatch.NullCallPtrThrows
- VMDispatch.NullCastLeavesNull
- VMDispatchContracts.CallBndScriptAndNativeIndependentOracles
- VMDispatchContracts.CallBndUnboundAndWrongSignatureRejectBeforeExecute
- VMDispatchContracts.FuncdefSignatureAcceptsMatchAndRejectsReturnMismatch
- VMDispatchContracts.InterfaceCallSelectsDerivedWhileBaseCallStaysOne
- VMDispatchContracts.InterfaceFactoryRequiresOwnerAndLeavesCountUnchanged
- VMDispatchContracts.TwoDelegatesReleaseEachReceiverOnce
- VMExecutableLeases.ExecuteAfterCallerSnapshotReleaseReturnsFortyTwo
- VMExecutableLeases.MissingPublishedScriptPrepareReturnsNoFunction
- VMExecutableLeases.NativePrepareExecuteAddTwentyAndTwentyTwo
- VMExecutableOwnership.ExecutionSurvivesProducerRelease
- VMExecutableOwnership.FailedCandidateDoesNotInstallAndExistingBodySurvives
- VMExecutableOwnership.ForeignAndUnlinkedPrepareReject
- VMExecutableOwnership.NativeTwentyPlusTwentyTwoLeavesSysFuncIntfUnchanged
- VMExecutableOwnership.ScriptFortyTwoLeavesFrozenDeclarationUnchanged
- VMExecutableOwnership.TwoEnginesKeepIndependentExecutableStorage
- VMFingerprints.BuildingAndIncompleteStatesRejectFingerprints
- VMFingerprints.ConcurrentReadsAgree
- VMFingerprints.EnumBaseInterfaceGenericAccessAndListChangeSchema
- VMFingerprints.FunctionBodyAndSourceLocationDoNotChangeTypeFingerprints
- VMFingerprints.GoldenCanonicalBytesFixFieldOrderAndDomains
- VMFingerprints.HandleCycleTerminatesAndValueCyclePublishesNoHash
- VMFingerprints.IndependentPointsAgreeOnKeyWitnessAndHash
- VMFingerprints.InjectedEqualDigestsWithDifferentWitnessesAreCollisions
- VMFingerprints.MethodReturnChangesSchemaButNotIdentity
- VMFingerprints.OneFactChangesAffectDeclaredDomains
- VMFingerprints.RetiredAuthenticDefinitionsRemainInspectable
- VMFingerprints.UnauthenticatedShellFreezeRejectsFingerprintQuery
- VMFloatingOpcodeMatrix.DoubleArithmetic
- VMFloatingOpcodeMatrix.FloatArithmeticAndImmediate
- VMFloatingOpcodeMatrix.FloatDoubleComparisons
- VMFloatingOpcodeMatrix.IntegerFloatConversions
- VMFloatingOpcodeMatrix.NegIncDecFloatDouble
- VMFloatingOpcodeMatrix.PowerFloatAndDomain
- VMFloatingOpcodeMatrix.WideFloatConversions
- VMFlowAdmission.ExclusiveBranchNormalDestroysSucceedAndSamePathDuplicatesReject
- VMFlowAdmission.FinalConditionalFallthroughRejectsAndFinalJumpSucceeds
- VMFlowAdmission.FinalJnzDecodedFallthroughRejectsAndBackwardJumpPasses
- VMFlowAdmission.InRefCallWithOneDwordPushRejects
- VMFlowAdmission.LiveSlotWithoutNormalCleanupRejects
- VMFlowAdmission.ResultSpanBeyondFrameAndOverflowReject
- VMFlowAdmission.VoidDoubleCallWithOneDwordPushRejects
- VMFlowAdmission.VoidDoubleCallWithPshC8SucceedsAndBalancedLoopSucceeds
- VMFlowPath.BothPathDuplicateDestroyStillRejects
- VMFlowPath.CallSysWithTwoPushesThenReturnSucceeds
- VMFlowPath.CallSysWithoutArgumentPushesRejects
- VMFlowPath.CleanupPastBodyAndMissingTypeReject
- VMFlowPath.DisjointNormalAndExceptionCleanupSucceeds
- VMFlowPath.PshC4WithoutReturnRejectsFallthrough
- VMFlowVerification.DuplicateDestroyAndUnconstructedCleanupReject
- VMFlowVerification.MutationInvalidatesPriorAdmission
- VMFlowVerification.PopPtrWithoutPushUnderflows
- VMFlowVerification.UnequalBranchJoinAndGrowingBackedgeReject
- VMFlowVerification.ValidBalancedLoopAndGuardedCleanupPass
- VMFrameAdmission.ArgumentPastItsLastDwordRejects
- VMFrameAdmission.ConversionOperandsUseTheirOwnStorageWidths
- VMFrameAdmission.FirstAndLastCompleteArgumentsPass
- VMFrameAdmission.FirstAndLastCompleteLocalsPassDirectAndDecoded
- VMFrameAdmission.ManagedPointerSpansCannotOverlap
- VMFrameAdmission.ManagedStorageCannotOwnArgumentZero
- VMFrameAdmission.NoArgumentZeroLocalRejectsDirectAndDecoded
- VMFrameAdmission.PointerLoadRequiresBothDwordsInsideTheFrame
- VMFrameAdmission.ResultSpanMustStayWithinLocalStorage
- VMFrameAdmission.SafeLocalBoundaryExecutionReturnsFortyTwo
- VMFrameAdmission.SignedPositiveEdgeUsesPhysicalStorageDirection
- VMFrameAdmission.WideArgumentCannotCrossItsEnd
- VMFrameAdmission.WideLocalCannotCrossIntoArguments
- VMGC.DelegateCaptureCycleIsReclaimed
- VMGC.EngineGarbageCollectAfterExecution
- VMGC.FullAndIncrementalReachSameDestructorSet
- VMGC.PreparedContextRootsLiveObject
- VMGC.RefCpyVBalancesAddRefRelease
- VMGC.RootedCycleSurvivesThenDies
- VMGC.UnrootedSelfCycleFinalizesOnce
- VMGC.UnrootedTwoNodeCycleFinalizesEachOnce
- VMGC.WeakRefValidThenInvalidAfterCollection
- VMImageContracts.CanonicalContractBytesMatchDocumentedOrder
- VMImageContracts.CompleteClosureCapturesFieldBaseReturnAndParameter
- VMImageContracts.CyclicHandlesTerminate
- VMImageContracts.DuplicateRoleKeyDifferentWitnessRejects
- VMImageContracts.InjectedEqualDigestsDoNotHideWitnessMismatch
- VMImageContracts.SameFunctionKeyDifferentReturnHasDifferentContracts
- VMImageContracts.UnfrozenTypeRejectsFingerprintQuery
- VMIndexedAdmission.CompleteTablePassesDirectAndDecoded
- VMIndexedAdmission.EveryEntryExecutesItsDistinctResult
- VMIndexedAdmission.EveryEntryMustBeFixedWidthJump
- VMIndexedAdmission.LargeRuntimeIndexThrowsAndRecovers
- VMIndexedAdmission.MaximumPlusOneThrowsAndRecovers
- VMIndexedAdmission.NegativeMaximumRejectsDirectAndDecoded
- VMIndexedAdmission.NegativeRuntimeIndexThrowsAndRecovers
- VMIndexedAdmission.NonFirstEntryCannotBypassObjectConstruction
- VMIndexedAdmission.NonFirstEntryStackJoinRejectsDirectAndDecoded
- VMIndexedAdmission.NonFirstEntryUnderflowRejectsDirectAndDecoded
- VMIndexedAdmission.OversizedTableRejectsWithoutArithmeticOverflow
- VMIndexedAdmission.TruncatedTableRejectsDirectAndDecoded
- VMIndirectAdmission.ActualParameterCountRejectsBeforeCallbackAndRecovers
- VMIndirectAdmission.ActualParameterModeRejectsBeforeCallbackAndRecovers
- VMIndirectAdmission.ActualReturnTypeRejectsBeforeCallbackAndRecovers
- VMIndirectAdmission.ActualSameWidthDifferentTypeRejectsBeforeCallbackAndRecovers
- VMIndirectAdmission.ActualWideParameterRejectsBeforeCallbackAndRecovers
- VMIndirectAdmission.DistinctNativeNameWithSameShapeReturnsFortyTwo
- VMIndirectAdmission.DistinctNativeReferenceShapeReturnsFortyTwo
- VMIndirectAdmission.DistinctScriptNameWithSameShapeReturnsFortyTwo
- VMIndirectAdmission.ForgedExpectedWidthRejectsAtTarget
- VMIndirectAdmission.MissingCallSiteSignatureRejectsLegacyEncoding
- VMIndirectAdmission.NullTargetPreservesExceptionAndRecovers
- VMIndirectAdmission.ReferenceRejectsValueBitsAndAcceptsAddressLoops
- VMIndirectAdmission.UnboundReceiverCannotUseReceiverFreeShape
- VMIndirectAdmission.WideArgumentsRejectOneDwordDirectAndDecoded
- VMIndirectAdmission.WideCallLoopsBalanceDirectAndDecoded
- VMIntegerOpcodeMatrix.Bitwise32
- VMIntegerOpcodeMatrix.Bitwise64
- VMIntegerOpcodeMatrix.ComparisonsAndTestFlags
- VMIntegerOpcodeMatrix.ConditionalJumpsTakenAndNotTaken
- VMIntegerOpcodeMatrix.ConstantMovesAndWidths
- VMIntegerOpcodeMatrix.DivModByZeroTypedException
- VMIntegerOpcodeMatrix.GlobalMoves
- VMIntegerOpcodeMatrix.Integer32Arithmetic
- VMIntegerOpcodeMatrix.Integer64Arithmetic
- VMIntegerOpcodeMatrix.IntegerConversions
- VMIntegerOpcodeMatrix.JumpTableEachArmDefaultAndMalformed
- VMIntegerOpcodeMatrix.MemoryWidthsWithSentinels
- VMIntegerOpcodeMatrix.NegIncDec
- VMIntegerOpcodeMatrix.NegativeArgOffsetsVersusPositiveLocals
- VMIntegerOpcodeMatrix.PowerIntegerAndOverflow
- VMIntegerOpcodeMatrix.StackPointerAndVar
- VMIntegerOpcodeMatrix.TerminatingLoopSumOneToTen
- VMIntegerOpcodeMatrix.UnsignedDivMod
- VMIntegration.CopyScriptNullThrowsThenListInitReturnsFortyTwo
- VMIntegration.FloatDoubleConversionAndPowerFamilies
- VMIntegration.GetObjMovesHandleThenGetRefReadsFortyTwo
- VMIntegration.GlobalStoragePgaPshG4Roundtrip
- VMIntegration.IntegerWidthShiftCompareAndJumpFamilies
- VMIntegration.JmppIndexOneSkipsNextStore
- VMIntegration.MemoryWidthIncAndSwapFamilies
- VMIntegration.MixedImageStillReturnsFortyTwo
- VMIntegration.MixedNativeDispatchDelegateSuspendCycleAndException
- VMIntegration.RejectsRetiredReservedAndPseudoOpcodes
- VMIntegration.RemainingWidthShiftFloatJumpAliases
- VMIntegration.Thiscall1AddsSevenToReceiver
- VMLifetimeAdmission.BranchBypassingAllocationBeforeDestroyRejects
- VMLifetimeAdmission.BranchBypassingOnlyNormalCleanupRejects
- VMLifetimeAdmission.CleanupRecordsMustDescribeActualOperations
- VMLifetimeAdmission.CompletedConstructorBeforeDestroyPasses
- VMLifetimeAdmission.ConstructionAndDestructionBalanceLoop
- VMLifetimeAdmission.DestroyRevisitedWithoutReconstructionRejects
- VMLifetimeAdmission.ExceptionExitUsesLiveGuardWithoutNormalDestroy
- VMLifetimeAdmission.ExclusiveBranchesEachConstructAndDestroyPass
- VMLifetimeAdmission.LinearConstructionAndDestructionPassDirectAndDecoded
- VMLifetimeAdmission.MissingInitializationGuardRejects
- VMLifetimeAdmission.ReconstructedInstancesMayEachBeDestroyed
- VMLifetimeAdmission.SkippedConstructorBeforeDestroyRejects
- VMLinking.LinkResolvesOriginalFunctionPointers
- VMLinking.MissingDeclarationAndBodyConflictReject
- VMManualAdmission.ConflictingDuplicateRequirementRejectsEveryAdmission
- VMManualAdmission.DuplicateBodyCannotSelectAnOrderDependentWinner
- VMManualAdmission.IdenticalDuplicateRequirementStillRejectsDirectAdmission
- VMManualAdmission.ImmediateNarrowingRejectsEveryAdmission
- VMManualAdmission.LateInvalidBodyAndForgedValidationPublishNothing
- VMManualAdmission.LegalCounterpartsExecuteThroughDirectAndDecodedAdmission
- VMManualAdmission.MissingFunctionSlotRejectsEveryAdmission
- VMManualAdmission.OversizedFrameCannotWrapRuntimeReservation
- VMManualAdmission.TemporaryStackPeakIsReservedInAdditionToLocals
- VMManualAdmission.UnreachableInvalidBranchStillRejects
- VMManualAdmission.UnreachableInvalidLocalStillRejects
- VMManualAdmission.UnreachableUnknownOpcodeStillRejects
- VMManualAdmission.WrongOperandKindRejectsEveryAdmission
- VMManualAdmission.WrongRoleFunctionSlotRejectsEveryAdmission
- VMManualAdmission.ZeroFunctionIdentityCannotEnterDirectAdmission
- VMNativeABI.InOutInoutAndForwardedReference
- VMNativeABI.MultipleInheritanceAppliesBaseOffset
- VMNativeABI.ObjectFirstAndLastReachReceiver
- VMNativeABI.PaddedReceiverSevenPlusFiveReturnsTwelve
- VMNativeABI.PrimitiveWidthsGenericAndTyped
- VMNativeABI.RejectsMissingCallerUnsupportedNullReceiverAndThrowsOnce
- VMNativeABI.ValueObjectArgumentAndHandleReturn
- VMNativeCalls.BindNativeFunctionRequiresRegisteredDeclaration
- VMNativeCalls.BytecodeWritesNativeRecordValueAndPreservesPadding
- VMNativeCalls.GenericAddTwentyAndTwentyTwoReturnsFortyTwo
- VMNativeCalls.GenericInt64BoolAndOutParameter
- VMNativeCalls.MethodReceiverValueSevenPlusFiveReturnsTwelveWithSentinels
- VMNativeCalls.NativeSetExceptionReportsVmException
- VMNativeCalls.NullIndirectCompositeThrowsBeforeWrite
- VMNativeCalls.TypedCallerAddTwentyAndTwentyTwoReturnsFortyTwo
- VMNativeCalls.UnboundSystemCallRejectsAtLink
- VMNativeCalls.UnsupportedThiscallOnFreeFunctionFailsBeforeCallback
- VMNativeLayout.CompositeInlineAndIndirectHaveDistinctLayoutWitnesses
- VMNativeLayout.NativeAdmissionRejectsOverflowOverlapPackedAndFrozenMutation
- VMNativeLayout.NativeRecordPreservesHostOffsetsAndPadding
- VMNativeLayout.SameKeyDifferentOffsetChangesLayoutHash
- VMObjectLifetime.DestructorFiresThroughNativeBinding
- VMObjectLifetime.HighAlignmentHeaderRecovers
- VMObjectLifetime.NativeHandleIsNotProbedAsSdkHeader
- VMObjectLifetime.ObjectSurvivesCallerSnapshotRelease
- VMObjectLifetime.PartialMemberFailureSkipsWholeObjectDestructor
- VMObjects.AllocatedObjectReportsTypeAndEngine
- VMObjects.CopyPreservesValueWithoutAliasing
- VMObjects.DestructScriptAdvancesPastSentinel
- VMObjects.HeapAllocConstructorSetsXDestructorFiresOnce
- VMObjects.NullObjectReferenceThrows
- VMObjects.PointFieldZeroRoundtrip
- VMObjects.ScriptObjectTypeRegistersAndContextExecutes
- VMOperandContracts.AssignedOpcodesHaveDescriptorsOrStrRejects
- VMOperandContracts.FrameCleanupSourceCapturedAndInvalidResultRegionRejects
- VMOperandContracts.FrameSpanAlignmentCrossingAndZeroSizeRejects
- VMOperandContracts.ImmediateWidthSlotRoleAndStringRejects
- VMOperandContracts.JmpImmediateS32RejectsWrongTagDirectAndDecoded
- VMOperandContracts.ReservedAndPseudoOpcodesReject
- VMOperandContracts.SetV4MinLocalRejectsFrameRangeDirectAndDecoded
- VMOperandContracts.ValidNegativeParameterAndInRangeLocalPass
- VMResourceOpcodeMatrix.CallBndScriptAndNative
- VMResourceOpcodeMatrix.CallSysReturnsFortyTwo
- VMResourceOpcodeMatrix.CastStoreLoadAndCallIntf
- VMResourceOpcodeMatrix.FuncPtrCallPtrAndNull
- VMResourceOpcodeMatrix.GetObjGetRefChkAndAddSi
- VMResourceOpcodeMatrix.GetObjRefReplacesStackWithHandleThenReadsSeventeen
- VMResourceOpcodeMatrix.ListCopyTypeIdAndNullChecks
- VMResourceOpcodeMatrix.LoadThisRReadsReceiverFieldSeventeenAndNullThrows
- VMResourceOpcodeMatrix.NestedCallAndReturn
- VMResourceOpcodeMatrix.NullChecksThrow
- VMResourceOpcodeMatrix.ObjectAllocCopyFreeAndGetRef
- VMResourceOpcodeMatrix.ObserversMarkersSuspendAndThrow
- VMResourceOpcodeMatrix.RetiredAndReservedReject
- VMResourceOpcodeMatrix.Thiscall1AddsSevenToReceiver
- VMReturnAdmission.BodyIncludesHiddenReturnDestination
- VMReturnAdmission.BodyIncludesReferenceStorage
- VMReturnAdmission.BodyParameterSizeMustMatchRealWideRequirement
- VMReturnAdmission.MethodBodyIncludesReceiverStorage
- VMReturnAdmission.RepeatedNestedCallsPreserveResultsArgumentsAndStackPosition
- VMReturnAdmission.ReturnCannotHaveNegativePop
- VMReturnAdmission.ReturnCannotPopFewerArguments
- VMReturnAdmission.ReturnCannotPopMoreArguments
- VMReturnAdmission.ScalarShorthandRejectsWideReturn
- VMReturnAdmission.ScalarShorthandRetainsMethodArgumentPop
- VMReturnAdmission.TargetChecksBodyWithoutInImageRequirement
- VMRootLifetime.ConcurrentAddRefReleaseFinalizesOnce
- VMRootLifetime.FailedConstructorIsNotCollectedAsComplete
- VMRootLifetime.NestedNativeCollectLeavesInnerRootUntilUnwind
- VMRootLifetime.SuspendedCycleSurvivesGcThenAbortFinalizesOnce
- VMRootLifetime.TwoEnginesKeepIndependentRoots
- VMScalar.ExecuteAddSevenAndThirtyFive
- VMScalar.ExecuteConstantReturnFortyTwo
- VMShutdownDrain.BlockedNativeReleasedBySignalWithoutEarlyComplete
- VMShutdownDrain.ConcurrentPrepareVersusShutdownIsCoherent
- VMShutdownDrain.NativeCallbackShutdownReturnsWithoutDeadlock
- VMShutdownDrain.RepeatedShutdownIsIdempotentAndMetadataStaysReadable
- VMShutdownDrain.RetainedObjectDelaysDestroyUntilFinalRelease
- VMShutdownDrain.ShutdownAbortsSuspendedAndReleasesRoot
- VMShutdownDrain.ShutdownRejectsNewLinkAndPrepare
- VMSourceAdmission.AdapterDoesNotMutateFrozenParameterOffsets
- VMSourceAdmission.BodiesOnlySessionReturnsNotReady
- VMSourceAdmission.DiagnosticsSurviveProducerDestruction
- VMSourceAdmission.ForeignEqualKeyDefinitionsReturnInvalidInput
- VMSourceAdmission.NullSessionOrDefinitionsReturnInvalidInput
- VMSourceAdmission.RecoverySessionReturnsInvalidInput
- VMSourceAdmission.ResourceBudgetReturnsResourceLimit
- VMSourceAdmission.UnfrozenDefinitionsReturnNotReady
- VMSourceAdmission.UnsupportedBodyPublishesNoPartialImage
- VMSourceAdmission.UnsupportedTargetReturnsUnsupportedLowering
- VMSourceAdmission.UnverifiedSessionReturnsNotReady
- VMSourceAdmission.ValidEmissionLinksThroughAtomicPublish
- VMSourceAdmission.VerifiedSupportedBodySucceedsEngineFree
- VMSourceCacheContracts.ChangedMethodReturnRejects
- VMSourceCacheContracts.ConflictingBodyLeavesInstalledCallable
- VMSourceCacheContracts.ForeignImageRejects
- VMSourceCacheContracts.IntegerControlStillSeven
- VMSourceCacheContracts.MissingClassRejectsWithoutInstalling
- VMSourceCacheContracts.MissingFreeFunctionRejectsWithoutInstalling
- VMSourceCacheContracts.MissingNativeBindingRejects
- VMSourceCacheContracts.MixedLoopBodyObjectsContinueThrowRecoverOnAAndB
- VMSourceCacheContracts.SourceCacheExecutesOnBAfterProducerRelease
- VMSourceCallContracts.ConstOutRvalueMismatchesReject
- VMSourceCallContracts.ConstructorOrdinalsRoundtripAndRejectCorrupt
- VMSourceCallContracts.ExplicitArgSuppressesTypedDefault
- VMSourceCallContracts.ImplicitThisMemberAccessReturnsSeven
- VMSourceCallContracts.MetadataStringDefaultExplicitSucceeds
- VMSourceCallContracts.MetadataStringDefaultOmitRejectsWithoutImage
- VMSourceCallContracts.NativeFillBumpPeekForwardedRefWritesFortyTwo
- VMSourceCallContracts.NativeFillBumpPeekLocalWritesFortyTwo
- VMSourceCallContracts.NativeFillBumpPeekMemberWritesFortyTwo
- VMSourceCallContracts.PairNamedCtorStoresWithReverseFormalTrace
- VMSourceCallContracts.PositionalNamedReverseFormalTraceTwelve
- VMSourceCallContracts.ScriptFillRunsThenLiteralOutRejects
- VMSourceCallContracts.TwoFilesEitherOrderReturnSevenWithLocations
- VMSourceCallContracts.TypedDefaultHostMarkTwiceIsSixtyEight
- VMSourceCalls.MissingNativeBindingRejectsLink
- VMSourceCalls.MissingOverloadPublishesNoImage
- VMSourceCalls.NativeHostAddTwentyAndTwentyTwo
- VMSourceCalls.NativePackMarkTracesReverseFormal
- VMSourceCalls.NativeSetExceptionReportsVmException
- VMSourceCalls.OutTemporaryPublishesNoImage
- VMSourceCalls.SourceCallerReturnsSeven
- VMSourceCalls.SourceCombineNamedAndDefaultIsThirtyFour
- VMSourceCalls.SourceFactorialZeroOneFive
- VMSourceCalls.SourceFillAndBumpYieldFortyTwo
- VMSourceCalls.SourceForwardCalleeAfterCallerReturnsSeven
- VMSourceCalls.SourceInRefPreservesCallerValue
- VMSourceCalls.SourceLiteralReturnExecutes
- VMSourceCalls.SourceOverloadsReturnDistinctMarkers
- VMSourceCalls.SourcePackMarkPositionalAndNamedReturnTwelve
- VMSourceCalls.TypedDefaultMarkRunsPerCallSite
- VMSourceCalls.UnsupportedThiscallBindingRejected
- VMSourceCalls.WrongNamedArgumentPublishesNoImage
- VMSourceControlFlow.SourceForSkipTwoBreakFiveGivesEight
- VMSourceControlFlow.SourceIfElseSelectsBranch
- VMSourceControlFlow.SourceLazyAndOrTernarySkipSideEffects
- VMSourceControlFlow.SourceLazyAndSkipsZeroDivisor
- VMSourceControlFlow.SourceSwitchFallthroughAndDefault
- VMSourceControlFlow.SourceWhileSumOneToTenIsFiftyFive
- VMSourceControlFlow.SourceWhileZeroVersusDoOnce
- VMSourceExpressions.SourceAddWithRuntimeParameters
- VMSourceExpressions.SourceBitwiseOrEqualsIsTrue
- VMSourceExpressions.SourceEightMinusThreeMinusOneIsFour
- VMSourceExpressions.SourceOnePlusTwoPointFiveIsThreePointFive
- VMSourceExpressions.SourceOnePlusTwoTimesThreeIsSeven
- VMSourceExpressions.SourcePowerIsLeftAssociatedSixtyFour
- VMSourceExpressions.SourceUnaryMinusAndLocalAssignment
- VMSourceIntegration.MissingDestinationFunctionRejectsSourceCache
- VMSourceIntegration.PreinstalledBodyRejectsSourceCache
- VMSourceIntegration.SourceMixedLoopObjectExceptionCache
- VMSourceIntegration.SourceProducedCacheRunsAfterProducerRelease
- VMSourceNumeric.BoolOrPreserved
- VMSourceNumeric.DoubleDivideLiteralEmitsDivd
- VMSourceNumeric.DoubleMultiplyLiteralEmitsMuldNotAddd
- VMSourceNumeric.DoubleOpsThroughParameterLocalCastAndConditional
- VMSourceNumeric.DoubleSubtractLiteralEmitsSubdNotAddd
- VMSourceNumeric.EnumValuePreserved
- VMSourceNumeric.FloatCompareAssignAndNonIntCast
- VMSourceNumeric.FrameAbove64DwordsExecutesWhenBudgetAllows
- VMSourceNumeric.Int64Above32BitsPreserved
- VMSourceNumeric.IntegerControlStillSeven
- VMSourceNumeric.NarrowSignExtension
- VMSourceNumeric.OverBudgetFrameRejectsWithoutImage
- VMSourceNumeric.UnsignedHighBitCompareAndDivide
- VMSourceObjects.SourceConstructOrdinalsRoundtripAndRejectBadVersion
- VMSourceObjects.SourceEmptyDefaultConstructCompletes
- VMSourceObjects.SourceFreeFunctionStillExecutes
- VMSourceObjects.SourcePairNamedConstructorFormalOrder
- VMSourceObjects.SourcePlainCopyReadsNine
- VMSourceObjects.SourceReverseDestroyOnReturn
- VMSourceObjects.SourceValueFieldWriteThenRead
- VMSourceObjects.SourceValueLocalSevenReadsSeven
- VMSourceScopeCleanup.BreakDestroysBodyBeforeInitializer
- VMSourceScopeCleanup.ConditionalReturnsEachDestroyOuterLocalOnce
- VMSourceScopeCleanup.EarlyReturnPreservesValueThroughDestructors
- VMSourceScopeCleanup.ForInitSurvivesContinueBodyDestroyedEachIteration
- VMSourceScopeCleanup.IntegerControlStillSeven
- VMSourceScopeCleanup.NestedForBreakSelectsNearest
- VMSourceScopeCleanup.NestedInnerDestroysBeforeMarkerThenOuter
- VMSourceScopeCleanup.NestedWhileContinueUsesBackedge
- VMSourceScopeCleanup.NoDuplicateDestructionOnNestedScopes
- VMSourceScopeCleanup.SwitchBreakSelectsNearest
- VMSourceScopeCleanup.UntakenConstructionBranchHasNoDestructor
- VMSourceUnwind.BrokenConstructorDestroysCompletedLocalOnly
- VMSourceUnwind.FailedConstructorNeverRunsCompleteDestructor
- VMSourceUnwind.IntegerControlStillSeven
- VMSourceUnwind.NativeFailUnwindsReverseThenRecoveryNinetySeven
- VMSourceUnwind.NestedMemberPartialConstructionOrder
- VMSourceUnwind.SourceRecordsSurviveEncodeDecodeAndProducerRelease
- VMSourceUnwind.StackLimitReportsSourceLocationThenRecovery
- VMSourceUnwind.TwoLocalsDivByZeroUnwindsReverseThenRecoveryNinetySeven
- VMWireFormat.CanonicalOrderRoundtripPreservesContractsFrameAndCleanup
- VMWireFormat.EmptyImageMatchesIndependentGoldenAndRejectsV1
- VMWireFormat.MalformedCountsTargetsAndTrailingBytesReject
- VMWireFormat.StringsPreserveExactUtf8BoundsAndRejectTruncatedMultibyte

## Limits and historical truth

This is the accepted bounded SDK interpreter/source surface, not arbitrary native memory safety, exhaustive fuzzing, all-language code generation, UE reflection integration, Standalone or JIT support. The full NativeEngine run is justified by shared image/verifier/linker/Context contracts and both producers; separate Baseline proves dormancy. Unrelated Quick, Performance, Integration and full UE suites were omitted because no additional affected contract requires them. Earlier crashed/incomplete runs remain failures, never behavioral assertion RED; already-correct controls retain honest baseline GREEN. Historical source-to-binary provenance gaps remain historical, while these final runs bind the current source and DLLs.
