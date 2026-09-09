# Task 3.2 — explicit binding Engine creation and cleanup

A sealed snapshot creates a private binding-only FAngelscriptEngine with its own native Engine, TypeDB, BindState, installed image and owned Contexts. Factory failures report Recording, Types, Members, Native or Engine stage and unwind through the same cleanup path. Context accessors return borrowed pointers; Shutdown releases them, drains native state, releases installation/database state and detaches owner lookup. Default cache/source/config-service/debug/coverage startup remains dormant. The full Runtime overload deliberately reports incomplete Recording until task 8.2 replaces that interim contract and its test.

## Verification

Exact task command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Engine.Creation.'; Fast = $true; TimeoutMs = 600000 }`.

Actual shared GREEN selector: `Angelscript.UnitTest.RuntimeBindings.` with the same parameters and `NoWait = $true`. Builds used `ue.build`, `NoWait = $true`, `TimeoutMs = 900000`; all routes imported Harness directly in the selected workspace PowerShell process. Sources stayed frozen from successful build through both final runs.

| Stage | Managed run | Result |
|---|---|---|
| Final RED setup | 11e879eba7e144668cd2c79ed9320298 | Build succeeded |
| Group RED | 673cfe5c4b0a44a59e45c6b4dbcd6a67 | Exit 255; all 9 creation cases failed against factory skeleton |
| Implementation build | b1c1b4db5b0c4b8584808e51ba6e46ba | Exit 6; asIScriptEngine pointer required explicit derived conversion |
| Corrected build | e68a2e2b354f45abb255420e70678dd0 | Succeeded, exit 0 |
| Shared GREEN | 2e46ae2a5b74405aa554443b5947c02e | Succeeded, exit 0; all 80 cases Success, zero errors/warnings |
| Adjacent startup baseline | 332708730e8947d3a2dc19b9ed601ab4 | Succeeded, exit 0; 3 cases Success, zero errors; one case has discovery warnings |

Earlier setup build 8eb1f7a8f3d842e1b493b0aa1e8822ef failed due to private test access and was fixed using existing public accessors. Build 0272bce0108545e98e2c28eec1364125 and RED ea7acf05c4434fe58aae1f26362f3925 covered the initial 8 cases before the type-stage ninth case was added. Setup compilation failures are not RED proof.

The baseline discovery case invokes test discovery for legacy-prefix absence and collects 2,436 MetaSound automation-tag registration warnings. It is a reported Success with warnings, not warning-free evidence. The other two baseline cases have zero warnings. No failed, in-process or not-run cases remain. NativeEngine VM/ABI/image/global suites are not repeated: task 3.2 changes the Runtime owner and stage reporting, and task 2.5 already proved those native contracts; no ThirdParty source changed here. Full UE suites, Harness Quick/Performance/Integration and full scripts are outside this bounded impact.

## Case-level results


Run 673cfe5c4b0a44a59e45c6b4dbcd6a67; report SHA-256 71541AED3357D959C126FFF247D69CCED6B9EBACE597B2F3A130C1A83F5C1EFF.

| Case | State | Errors | Warnings |
|---|---|---|---|
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.ExplicitCreationKeepsDefaultRuntimeDormant | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.ExplicitShutdownIsIdempotentAndStopsContextCreation | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.ExplicitSnapshotCreatesCallableOwner | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.FullRuntimeOverloadReportsIncompleteRecordingPipeline | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.InvalidNativeLayoutReportsTypeStageAndReleasesSnapshot | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.MissingNativeTargetReportsSourceAndStageWithoutOwner | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.RepeatedDestructionReleasesActualContextsEngineAndImage | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.UnresolvedTypeFailsBeforeCallablePublication | Fail | 1 | 0 |
| Angelscript.UnitTest.RuntimeBindings.Engine.Creation.UnsealedSnapshotFailsAtRecordingStage | Fail | 1 | 0 |

Run 2e46ae2a5b74405aa554443b5947c02e; report SHA-256 4D620DB684D957F689F312CE63DFA1619E8E1222327E93D15DDA8B3093BD3565.

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

Run 332708730e8947d3a2dc19b9ed601ab4; report SHA-256 73FD6BB7DE20190E7C8D4FA5BE61344764E94C6D6AB07714AB15EE2220A2EC87.

| Case | State | Errors | Warnings |
|---|---|---|---|
| Angelscript.UnitTest.Baseline.LegacySuiteExcludedByDefault | Success | 0 | 2436 |
| Angelscript.UnitTest.Baseline.OptionalIntegrationsDormantByDefault | Success | 0 | 0 |
| Angelscript.UnitTest.Baseline.RuntimeDormantByDefault | Success | 0 | 0 |

## Source and binary identities


Observed RED SHA-256:

| Path | Hash |
|---|---|
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h | 61BB518E34AB333921B1D5AAC028E1D72E16D463361EA5A6AA48B7E9E68FE35B |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp | A4F3D26B72B77E1655659BA131AF836AC83A02BF8F561B4D641F79C3EB69BB33 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h | 3DCFA3554A4819A1C7D6429460DBE3AA387FEFDC7744DAD6253ACB91DC1CD0BC |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h | D106FD1E0F0F5CBBDF5B860B4142BFF2A9CE1AA8465C5D90AAE1A17A1B6FE735 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp | 4B58C0076A37C5EA7911F416FC8634B6B9B77D6C0C8E72D09BE05A692D3908E1 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h | 87E103A94C034FCC375C738AA0310AADE20B164CC0268AEB4AA82F944E437DF9 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingCreationTests.cpp | A6B82F1A61C43F9F1C66A105E4485FAC69BE0F205F52D1AA177FA2C887E72327 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | 96723E2D8E5928E03182A40EBC7E680BD0892DF51AA13B80AA9067BB37CA10C4 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | 85EA792C8494D1C700C209B1A9934E0DF986DB199CDA73BC6051CFEF09C72845 |

Final GREEN and baseline SHA-256:

| Path | Hash |
|---|---|
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h | 721258FCF930D741E38054C11E9377653007F7F9EEFDB8841672B561AEF054C3 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp | C6CF67F49FF3A73B7422D25EBB3E85B415DA599224B49733586A213FF385710B |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h | 3DCFA3554A4819A1C7D6429460DBE3AA387FEFDC7744DAD6253ACB91DC1CD0BC |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h | CF5B4AB64FD606418A099125A1662E8A0A0551C3587B890A0E4AE2A2B9A0F58D |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp | 245111809623591EE9C9507D3947C1E5D55EBBA33EB3219AA602AAB075B2B109 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h | 87E103A94C034FCC375C738AA0310AADE20B164CC0268AEB4AA82F944E437DF9 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingCreationTests.cpp | A6B82F1A61C43F9F1C66A105E4485FAC69BE0F205F52D1AA177FA2C887E72327 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll | 5D39F5A276887300CBB12F2E1AA1DBA8A1F00AF32610EBB3EBF41FF5287061D8 |
| Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll | D3430D0F6F42B1791C0BD9A14397FA13119BD98FE170CAC6029345352E83549A |
