# Task 3.3 — independent binding Engine invocation state

One provider capture supplies multiple owners with separate image, type, function, Context and mutable TypeDB state. The new call path resolves its owner from the active Context before considering an ambient scope. Native and generic calls expose the exact acquired binding generation's auxiliary pointer for the invocation duration; a scoped guard restores the previous value on return. The Runtime helper uses this call data for explicit binding owners and preserves dormant legacy metadata access elsewhere. Rebinding A changes subsequent A invocations while its active invocation and B retain their own data.

## Proving commands and outcomes

Exact task command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.'; Fast = $true; TimeoutMs = 600000 }`.

All launches imported Harness directly in the selected workspace PowerShell process. Test runs added NoWait=true; builds used ue.build with NoWait=true and TimeoutMs=900000. Actual shared GREEN selector was Angelscript.UnitTest.RuntimeBindings.; adjacent selectors were Angelscript.UnitTest.NativeEngine.VMNative and Angelscript.UnitTest.Baseline., each Fast=true and TimeoutMs=600000. Source/binary hashes were captured after the final build and rechecked unchanged after all three proving runs.

| Purpose | Managed run | Terminal result |
|---|---|---|
| Initial setup | 20a80a5029064f78a1993b861b8ce7d7 | Build failed, exit 6; fixture used a stable key where AcquireSystemInterface requires a function pointer |
| Corrected setup | 2f97bfe969074f1c99057fa8e8f44879 | Build succeeded, exit 0 |
| Isolation RED | fa5053495ab144c3b7293826e348a0a9 | Failed, exit 255; 5 missing-behavior failures, 4 existing controls passed |
| Implementation build | 502b6c6f1eb24ea19e00c9df401384a8 | Succeeded, exit 0 |
| Shared binding GREEN | 769024453c4c414f92f4bcd07f87f919 | Succeeded, exit 0; all 89 cases Success, zero errors/warnings |
| Adjacent VM native calls | 07cae13cdd024b83bad95e24f1b243e3 | Succeeded, exit 0; all 28 cases Success, zero errors/warnings |
| Adjacent startup baseline | e0e1875a26c34081a912fcecfa1c62a1 | Succeeded, exit 0; all 3 cases Success; one with 2,436 MetaSound discovery warnings |

The four initial passing controls prove existing per-owner metadata, database/adapter mutation, foreign-function rejection and cleanup. The five RED cases distinguish absent invocation owner/auxiliary behavior. Each case below is part of the same bounded outcome; no compile error is counted as RED. The indexed replan-20260908-110000-active-binding-call-context extends task 3.3 ownership to as_context.* without changing requirements, dependencies or prior completed tasks.

The baseline report has succeeded=2 and succeededWithWarnings=1. Its LegacySuiteExcludedByDefault case enumerates Automation tests and collects exactly 2,436 `LogMetaSound: Failed to register automation test tags` warnings; the other baseline cases have none. All three reports have zero failed, in-process and not-run cases. These warnings are retained as observed and are not described as warning-free proof.

Native VM regression is required because both common native invocation paths changed. MetadataImage and GlobalDefinitions were not repeated: their registration paths did not change. Full native suite remains the explicit 8.4 integration gate; full UE suites, full-script execution and Harness Quick/Performance/Integration are not relevant to this bounded invocation change.

## Case-level proof

Run fa5053495ab144c3b7293826e348a0a9; report SHA-256 E893ECCF97503727911419C156D2D5EC4461619112FAF0FD6A1D9A6E9FFFF28D.

| Case | State | Errors | Warnings |
|---|---|---|---|
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.AdaptersAndMutableDatabaseBelongToExactOwner | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.DestroyingOneOwnerLeavesOtherCallableAndReleasesBothImages | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.ForeignFunctionsAreRejectedByBothContexts | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.GenericExecutionOverridesAmbientScopeAndRestoresIt | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.GenericRuntimeHelperReadsTheCapturedAuxiliary | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.NativeAuxiliaryAndOwnerRestoreAfterNestedOtherEngineCall | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.NativeCallbacksResolveTheExecutingOwnerAndAdapter | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.OneCapturedProviderBuildsDistinctOwnerMetadata | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.RebindingOneOwnerKeepsActiveAuxiliaryGenerationAndOtherOwner | Fail | 1 | 0 |

Run 769024453c4c414f92f4bcd07f87f919; report SHA-256 1B7F69BF27078E774B587F483CB1553D6DA7819E5CC36BD1F22CB7AD5C9D53C9.

| Case | State | Errors | Warnings |
|---|---|---|---|
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.CaseSensitiveGlobalNamesKeepDistinctAddresses | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.CaseSensitiveOwnersDispatchDistinctFunctions | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.FirstParameterMetadataUsesInstalledFunctionAndOwner | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ForeignEngineRejectsInstalledIdentity | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.FreeFunctionAddsThroughContext | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GenericAuxiliaryKeepsExecutingGenerationDuringRebind | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GenericCallbackObservesAuxiliary | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.GlobalPropertyConnectsOriginalStorage | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.IncompatibleCallableOwnerRejectsWholeConnection | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MemberAuxiliaryDoesNotReplaceTheReceiver | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MemberFunctionUsesReceiver | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MissingGlobalStorageRejectsFunctionsAndEarlierAddresses | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.MissingTargetRejectsWholeConnection | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ObjectFirstAndObjectLastKeepExplicitArgumentOrder | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.OutAndInOutWriteCallerStorage | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.PureConstantConnectsWithoutExternalStorage | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ReferenceReturnAliasesReceiver | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ValueConstructionCopyAndDestructionBalance | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.ValueReturnPreservesBothFields | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Calls.Native.WrongSignatureRejectsWholeConnection | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.ExplicitCreationKeepsDefaultRuntimeDormant | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.ExplicitShutdownIsIdempotentAndStopsContextCreation | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.ExplicitSnapshotCreatesCallableOwner | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.FullRuntimeOverloadReportsIncompleteRecordingPipeline | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.InvalidNativeLayoutReportsTypeStageAndReleasesSnapshot | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.MissingNativeTargetReportsSourceAndStageWithoutOwner | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.RepeatedDestructionReleasesActualContextsEngineAndImage | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.UnresolvedTypeFailsBeforeCallablePublication | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.UnsealedSnapshotFailsAtRecordingStage | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.AdaptersAndMutableDatabaseBelongToExactOwner | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.DestroyingOneOwnerLeavesOtherCallableAndReleasesBothImages | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.ForeignFunctionsAreRejectedByBothContexts | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.GenericExecutionOverridesAmbientScopeAndRestoresIt | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.GenericRuntimeHelperReadsTheCapturedAuxiliary | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.NativeAuxiliaryAndOwnerRestoreAfterNestedOtherEngineCall | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.NativeCallbacksResolveTheExecutingOwnerAndAdapter | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.OneCapturedProviderBuildsDistinctOwnerMetadata | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.RebindingOneOwnerKeepsActiveAuxiliaryGenerationAndOtherOwner | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.CallerVariantsAndPropertyExposureSurviveRecording | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.FunctionTraitsAndCompilePoliciesAreDetached | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.HandlesSurviveGrowthAndRejectSealedEdits | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespaceAndCaseSensitiveTypesDoNotCollide | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespacesEnumsAndConstantsAreRecorded | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NativeRecipesOwnTheirInputsAndPreserveOrder | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ReferenceAndTemplateDeclarationsRetainUEFacts | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ValueLifecycleAndMembersNeedNoEngine | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.DuplicateIdentityNamesBothSourcesBeforeExecution | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.EmptySealedCollectionProducesAnEmptySealedStore | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.LateProviderInvalidatesCaptureWithProvenance | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.OutOfOrderProvidersPreservePhaseOrderAndContributions | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.RecordingFailureReportsSourceAndPublishesNothing | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.ReusingSnapshotNeverReexecutesProviders | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.TargetConditionsAndEffectivePolicyAreCaptured | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Providers.UnsealedCollectionCannotPublishASnapshot | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.CompatibleDeclarationsCoalesce | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.ConflictingNativeDefinitionReportsBothSources | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.EmptyStoreSeals | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.RecordHandlesSurviveGrowthAndRejectForeignStores | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.RepeatedSealPreservesIdentity | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.SealedMutationRejected | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Recording.Store.StoreOwnsInputLifetime | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ConstReferenceMethodAndDefaultAreDetached | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.DefaultExpressionsKeepNestedCommasAndOriginalText | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.EquivalentSpellingSharesIdentityAndRefChangesOverload | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ExplicitVoidAndReferenceDirections | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.InvalidDeclarationsReportOwnedSourceRanges | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.NestedTemplatesAndObjectHandlesResolve | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.PropertyAndStandaloneTypeUseCanonicalTypes | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ReturnTypeConflictCannotPublishCallable | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.BaseCycleReportsItsDeclarationsAndPublishesNothing | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.ByValueCycleIsRejectedEvenWithExplicitNativeSizes | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.CaseSensitiveNominalsKeepIndependentNativeLayouts | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.DerivedBeforeBaseAndForwardValuePropertyKeepNativeLayout | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.EnumAliasAndInterfaceFactsRoundTrip | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.InvalidAlignmentAndOutOfBoundsOffsetFailWithSource | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MissingNominalReportsTheMemberProviderAndDeclaration | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MutualObjectHandleReferencesDoNotFormALayoutCycle | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Layouts.UnsealedStoreCannotStartADraft | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.CompilePoliciesUseCapturedBuildFacts | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.ConstAndMutableGlobalDeclarationsHaveMetadataWithoutStorage | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.ConstructorsAndDestructorKeepDistinctBehaviourIdentities | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.DefaultsDirectionsAndNativeFunctionTraitsSurviveFreeze | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.FrozenInstallationRejectsLaterMemberMutation | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.IncompatibleDuplicateSignatureFailsBeforeRegistration | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.MethodAndGlobalOverloadsAreVisibleAfterWholeImageInstall | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.MissingParameterTypePublishesNoImageAndReportsMemberSource | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.PropertyAccessAndOffsetsAreCompleteBeforePublication | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.PureConstantRejectsMutableAndObjectStorageBeforePublication | Success | 0 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Types.Members.SecondEngineOwnsDistinctImageWithEqualStableIdentities | Success | 0 | 0 |

Run 07cae13cdd024b83bad95e24f1b243e3; report SHA-256 58A7A99BE831A6C28E238E5707434C1D0E51DBA774CDBE89A7B4EC9BDE8C7116.

| Case | State | Errors | Warnings |
|---|---|---|---|
| Angelscript.UnitTest.NativeEngine.VMNativeABI.InOutInoutAndForwardedReference | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.MultipleInheritanceAppliesBaseOffset | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.ObjectFirstAndLastReachReceiver | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.PaddedReceiverSevenPlusFiveReturnsTwelve | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.PrimitiveWidthsGenericAndTyped | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.RejectsMissingCallerUnsupportedNullReceiverAndThrowsOnce | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeABI.ValueObjectArgumentAndHandleReturn | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.ConcurrentReadersSeeCompleteRetainedGenerations | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.DescriptorLeaseKeepsDeclarationReadableAfterEngineAndProducerRelease | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.InvalidReplacementPreservesInstalledCallback | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.OldGenerationInvokesOriginalAfterReplacementAndExpiresOnRelease | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.ReentrantReplacementCleansTransferredValueExactlyOnce | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.ReentrantReplacementRetainsActiveDescriptorThroughReturn | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeBindingLifetime.RetiredEngineRejectsReplacementBeforeBindingMutation | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.BindNativeFunctionRequiresRegisteredDeclaration | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.BytecodeWritesNativeRecordValueAndPreservesPadding | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.GenericAddTwentyAndTwentyTwoReturnsFortyTwo | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.GenericInt64BoolAndOutParameter | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.MethodReceiverValueSevenPlusFiveReturnsTwelveWithSentinels | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.NativeSetExceptionReportsVmException | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.NullIndirectCompositeThrowsBeforeWrite | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.TypedCallerAddTwentyAndTwentyTwoReturnsFortyTwo | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.UnboundSystemCallRejectsAtLink | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeCalls.UnsupportedThiscallOnFreeFunctionFailsBeforeCallback | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.CompositeInlineAndIndirectHaveDistinctLayoutWitnesses | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.NativeAdmissionRejectsOverflowOverlapPackedAndFrozenMutation | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.NativeRecordPreservesHostOffsetsAndPadding | Success | 0 | 0 |
| Angelscript.UnitTest.NativeEngine.VMNativeLayout.SameKeyDifferentOffsetChangesLayoutHash | Success | 0 | 0 |

Run e0e1875a26c34081a912fcecfa1c62a1; report SHA-256 2C3BAAE22748EA78F8BA7D8454C9C1C364AFC3D001DA5CFBFC20098B614127B6.

| Case | State | Errors | Warnings |
|---|---|---|---|
| Angelscript.UnitTest.Baseline.LegacySuiteExcludedByDefault | Success | 0 | 2436 |
| Angelscript.UnitTest.Baseline.OptionalIntegrationsDormantByDefault | Success | 0 | 0 |
| Angelscript.UnitTest.Baseline.RuntimeDormantByDefault | Success | 0 | 0 |

## Source and binary identity

Observed RED, SHA-256:

| Path | Hash |
|---|---|
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp | C6CF67F49FF3A73B7422D25EBB3E85B415DA599224B49733586A213FF385710B |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp | 7004FFA597DC7CA97943944B4FD38695AD512D962E0C367068273E289E710485 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h | 6A9A45FCE06EA9C1154CC9619F226403E65CD9429EFA6EA23E481F16899C3E73 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp | FBECA0646102D1D7642B08FEB862202BCD18268D60C9C36D359ECEEB364CF110 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.h | 2C686C3B0C0102E936C7CEB500D89E615849AEE6CA087651719280A8890A72C7 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingIsolationTests.cpp | 5DABFD9EC088AFA942B9D068362FB7B306533748DDCC359E64DB41B3B7CB29F0 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | 5D39F5A276887300CBB12F2E1AA1DBA8A1F00AF32610EBB3EBF41FF5287061D8 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | A9B4C286F627C585A39E7A5DDBCBC30DCE16613ADEECB565A6B391FD0A075605 |

Final GREEN and adjacent runs, SHA-256:

| Path | Hash |
|---|---|
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp | 471E282B65B211731FFA336DAF497BE6B0F23ACB5FF6C6D46520413AF5BBC5F1 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp | 7004FFA597DC7CA97943944B4FD38695AD512D962E0C367068273E289E710485 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h | 6A9A45FCE06EA9C1154CC9619F226403E65CD9429EFA6EA23E481F16899C3E73 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp | 5984778969E01F530885D0CEDC485F61097E01784A00233AB1A645D174CF93D8 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.h | 066ECC687D36220AC8203EC7AF4F568A700D514512059594AC03F15FDB3EDCBD |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingIsolationTests.cpp | 5DABFD9EC088AFA942B9D068362FB7B306533748DDCC359E64DB41B3B7CB29F0 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | B426ADA4EF49861114498CC08AF24B6C8A8EA7169104AB0C2A8F4A11497DE056 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | 7FE3B0BA3641B86B1CB06C247A24A9FA156A368AE4EFF31631A38EAE875C4A88 |
