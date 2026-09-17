# TestSource-old absorption census

Hand-authored Pending files left untouched. Wiped previous absorb: 2822 files. Empty after prologue strip: 0. Name collisions with hand files: 0.

One legacy file becomes one Pending container, except HotReload `Before`/`After`/`Version_N` of the same scenario, which share one file as version tags.

| Theme | Legacy .as | Adapted skipped | Pending containers |
| --- | ---: | ---: | ---: |
| `Bindings` | 580 | 0 | 580 |
| `Containers` | 215 | 0 | 215 |
| `Debugger` | 3 | 0 | 3 |
| `Definitions` | 521 | 0 | 521 |
| `Feature` | 367 | 0 | 367 |
| `Gameplay` | 152 | 0 | 152 |
| `HotReload` | 207 | 0 | 97 |
| `Language` | 624 | 147 | 477 |
| `Math` | 111 | 0 | 111 |
| `Optional` | 116 | 0 | 116 |
| `TestFramework` | 59 | 0 | 59 |
| `World` | 124 | 0 | 124 |
| **total** | **3079** | **147** | **2822** |

## HotReload merges

| Destination | Sources | Legacy paths |
| --- | ---: | --- |
| `HotReload/BlueprintDelegatePropertyReloadsAfterInstanceRuntime.as` | 4 | `HotReload/BlueprintDelegatePropertyReloadsAfterInstanceRuntime/Version_01.as`, `HotReload/BlueprintDelegatePropertyReloadsAfterInstanceRuntime/Version_02.as`, `HotReload/BlueprintDelegatePropertyReloadsAfterInstanceRuntime/Version_03.as`, `HotReload/BlueprintDelegatePropertyReloadsAfterInstanceRuntime/Version_04.as` |
| `HotReload/BlueprintDelegateWorldTickContinuesAfterSoftReload.as` | 2 | `HotReload/BlueprintDelegateWorldTickContinuesAfterSoftReload/Before.as`, `HotReload/BlueprintDelegateWorldTickContinuesAfterSoftReload/After.as` |
| `HotReload/BlueprintEventAddedRequiresFullReload.as` | 2 | `HotReload/BlueprintEventAddedRequiresFullReload/Before.as`, `HotReload/BlueprintEventAddedRequiresFullReload/After.as` |
| `HotReload/BroadcastDelegateSignatureSwap.as` | 2 | `HotReload/BroadcastDelegateSignatureSwap/Before.as`, `HotReload/BroadcastDelegateSignatureSwap/After.as` |
| `HotReload/BroadcastEnumChangeAndFullReload.as` | 2 | `HotReload/BroadcastEnumChangeAndFullReload/Before.as`, `HotReload/BroadcastEnumChangeAndFullReload/After.as` |
| `HotReload/BroadcastEnumChangedOnFullReload.as` | 2 | `HotReload/BroadcastEnumChangedOnFullReload/Before.as`, `HotReload/BroadcastEnumChangedOnFullReload/After.as` |
| `HotReload/BroadcastEnumCreatedOnFirstCompile.as` | 2 | `HotReload/BroadcastEnumCreatedOnFirstCompile/Before.as`, `HotReload/BroadcastEnumCreatedOnFirstCompile/After.as` |
| `HotReload/BroadcastOldAndNewTypes.as` | 2 | `HotReload/BroadcastOldAndNewTypes/Before.as`, `HotReload/BroadcastOldAndNewTypes/After.as` |
| `HotReload/BroadcastsReloadedObjectReplacement.as` | 2 | `HotReload/BroadcastsReloadedObjectReplacement/Before.as`, `HotReload/BroadcastsReloadedObjectReplacement/After.as` |
| `HotReload/CDOAndInstanceConsistency.as` | 4 | `HotReload/CDOAndInstanceConsistency/Version_01.as`, `HotReload/CDOAndInstanceConsistency/Version_02.as`, `HotReload/CDOAndInstanceConsistency/Version_03.as`, `HotReload/CDOAndInstanceConsistency/Version_04.as` |
| `HotReload/ClassAdded.as` | 2 | `HotReload/ClassAdded/Before.as`, `HotReload/ClassAdded/After.as` |
| `HotReload/ClassAndEnumMetadataUpdateAfterFullReload.as` | 2 | `HotReload/ClassAndEnumMetadataUpdateAfterFullReload/Before.as`, `HotReload/ClassAndEnumMetadataUpdateAfterFullReload/After.as` |
| `HotReload/ClassFlagChangeSuggestsFullReload.as` | 2 | `HotReload/ClassFlagChangeSuggestsFullReload/Before.as`, `HotReload/ClassFlagChangeSuggestsFullReload/After.as` |
| `HotReload/ClassMetadataChangeSuggestsFullReload.as` | 2 | `HotReload/ClassMetadataChangeSuggestsFullReload/Before.as`, `HotReload/ClassMetadataChangeSuggestsFullReload/After.as` |
| `HotReload/ClassRemoved.as` | 2 | `HotReload/ClassRemoved/Before.as`, `HotReload/ClassRemoved/After.as` |
| `HotReload/DefaultComponentMetadataAndRuntimeHierarchySurviveSoftReload.as` | 2 | `HotReload/DefaultComponentMetadataAndRuntimeHierarchySurviveSoftReload/Before.as`, `HotReload/DefaultComponentMetadataAndRuntimeHierarchySurviveSoftReload/After.as` |
| `HotReload/DefaultStatementChangeSuggestsFullReload.as` | 2 | `HotReload/DefaultStatementChangeSuggestsFullReload/Before.as`, `HotReload/DefaultStatementChangeSuggestsFullReload/After.as` |
| `HotReload/DelegateAddedSuggestsFullReload.as` | 2 | `HotReload/DelegateAddedSuggestsFullReload/Before.as`, `HotReload/DelegateAddedSuggestsFullReload/After.as` |
| `HotReload/DelegateArgumentAndReturnRoundTripAcrossReloads.as` | 2 | `HotReload/DelegateArgumentAndReturnRoundTripAcrossReloads/Before.as`, `HotReload/DelegateArgumentAndReturnRoundTripAcrossReloads/After.as` |
| `HotReload/DelegateKindChangeRequiresFullReload.as` | 2 | `HotReload/DelegateKindChangeRequiresFullReload/Before.as`, `HotReload/DelegateKindChangeRequiresFullReload/After.as` |
| `HotReload/DelegateReceiverLifecycleBoundaryAcrossReload.as` | 2 | `HotReload/DelegateReceiverLifecycleBoundaryAcrossReload/Before.as`, `HotReload/DelegateReceiverLifecycleBoundaryAcrossReload/After.as` |
| `HotReload/DelegateSignatureChange.as` | 2 | `HotReload/DelegateSignatureChange/Before.as`, `HotReload/DelegateSignatureChange/After.as` |
| `HotReload/DiscardAndRecompile.as` | 2 | `HotReload/DiscardAndRecompile/Before.as`, `HotReload/DiscardAndRecompile/After.as` |
| `HotReload/DiscardModule.as` | 2 | `HotReload/DiscardModule/Before.as`, `HotReload/DiscardModule/After.as` |
| `HotReload/DiscardModuleRemovesGlobalFunctionAvailability.as` | 2 | `HotReload/DiscardModuleRemovesGlobalFunctionAvailability/Before.as`, `HotReload/DiscardModuleRemovesGlobalFunctionAvailability/After.as` |
| `HotReload/DoesNotReplayBeginPlayOnLiveActor.as` | 2 | `HotReload/DoesNotReplayBeginPlayOnLiveActor/Before.as`, `HotReload/DoesNotReplayBeginPlayOnLiveActor/After.as` |
| `HotReload/EditSpecifierReloadKeepsBlueprintChildInstanceAlive.as` | 2 | `HotReload/EditSpecifierReloadKeepsBlueprintChildInstanceAlive/Before.as`, `HotReload/EditSpecifierReloadKeepsBlueprintChildInstanceAlive/After.as` |
| `HotReload/EnumMetadataChangeSuggestsFullReload.as` | 2 | `HotReload/EnumMetadataChangeSuggestsFullReload/Before.as`, `HotReload/EnumMetadataChangeSuggestsFullReload/After.as` |
| `HotReload/EnumReloadMarksBlueprintVariablesAndPinsImpacted.as` | 2 | `HotReload/EnumReloadMarksBlueprintVariablesAndPinsImpacted/Before.as`, `HotReload/EnumReloadMarksBlueprintVariablesAndPinsImpacted/After.as` |
| `HotReload/EnumValueChange.as` | 2 | `HotReload/EnumValueChange/Before.as`, `HotReload/EnumValueChange/After.as` |
| `HotReload/FailedReloadDoesNotBroadcastReloadDelegates.as` | 2 | `HotReload/FailedReloadDoesNotBroadcastReloadDelegates/Before.as`, `HotReload/FailedReloadDoesNotBroadcastReloadDelegates/After.as` |
| `HotReload/FailedReloadKeepsOldClassAndProperties.as` | 2 | `HotReload/FailedReloadKeepsOldClassAndProperties/Before.as`, `HotReload/FailedReloadKeepsOldClassAndProperties/After.as` |
| `HotReload/FullReloadAddsPropertyAndUpdatesDefaults.as` | 2 | `HotReload/FullReloadAddsPropertyAndUpdatesDefaults/Before.as`, `HotReload/FullReloadAddsPropertyAndUpdatesDefaults/After.as` |
| `HotReload/FullReloadKeepsOpenEditorLevelBlueprintRecoverableAfterParentShapeChange.as` | 2 | `HotReload/FullReloadKeepsOpenEditorLevelBlueprintRecoverableAfterParentShapeChange/Before.as`, `HotReload/FullReloadKeepsOpenEditorLevelBlueprintRecoverableAfterParentShapeChange/After.as` |
| `HotReload/FullReloadUpdatesEnumValueAndDefault.as` | 2 | `HotReload/FullReloadUpdatesEnumValueAndDefault/Before.as`, `HotReload/FullReloadUpdatesEnumValueAndDefault/After.as` |
| `HotReload/FunctionAddedSuggestsFullReload.as` | 2 | `HotReload/FunctionAddedSuggestsFullReload/Before.as`, `HotReload/FunctionAddedSuggestsFullReload/After.as` |
| `HotReload/FunctionArgumentNameChangeSuggestsFullReload.as` | 2 | `HotReload/FunctionArgumentNameChangeSuggestsFullReload/Before.as`, `HotReload/FunctionArgumentNameChangeSuggestsFullReload/After.as` |
| `HotReload/FunctionBlueprintSpecifierChangeRequiresFullReload.as` | 2 | `HotReload/FunctionBlueprintSpecifierChangeRequiresFullReload/Before.as`, `HotReload/FunctionBlueprintSpecifierChangeRequiresFullReload/After.as` |
| `HotReload/FunctionDefaultArgumentChangeSuggestsFullReload.as` | 2 | `HotReload/FunctionDefaultArgumentChangeSuggestsFullReload/Before.as`, `HotReload/FunctionDefaultArgumentChangeSuggestsFullReload/After.as` |
| `HotReload/FunctionMetadataAndDefaultsUpdateAfterFullReload.as` | 2 | `HotReload/FunctionMetadataAndDefaultsUpdateAfterFullReload/Before.as`, `HotReload/FunctionMetadataAndDefaultsUpdateAfterFullReload/After.as` |
| `HotReload/FunctionMetadataChangeSuggestsFullReload.as` | 2 | `HotReload/FunctionMetadataChangeSuggestsFullReload/Before.as`, `HotReload/FunctionMetadataChangeSuggestsFullReload/After.as` |
| `HotReload/FunctionRemovedRequiresFullReload.as` | 2 | `HotReload/FunctionRemovedRequiresFullReload/Before.as`, `HotReload/FunctionRemovedRequiresFullReload/After.as` |
| `HotReload/FunctionSignatureChanged.as` | 2 | `HotReload/FunctionSignatureChanged/Before.as`, `HotReload/FunctionSignatureChanged/After.as` |
| `HotReload/GameInstanceSubsystemSoftReloadUpdatesCallableBehavior.as` | 2 | `HotReload/GameInstanceSubsystemSoftReloadUpdatesCallableBehavior/Before.as`, `HotReload/GameInstanceSubsystemSoftReloadUpdatesCallableBehavior/After.as` |
| `HotReload/GlobalDelegateCallerRunsAcrossReloads.as` | 3 | `HotReload/GlobalDelegateCallerRunsAcrossReloads/Version_01.as`, `HotReload/GlobalDelegateCallerRunsAcrossReloads/Version_02.as`, `HotReload/GlobalDelegateCallerRunsAcrossReloads/Version_03.as` |
| `HotReload/InheritanceChainPropertyReloadPropagatesToChild.as` | 2 | `HotReload/InheritanceChainPropertyReloadPropagatesToChild/Before.as`, `HotReload/InheritanceChainPropertyReloadPropagatesToChild/After.as` |
| `HotReload/InvokeContainerSignatureAfterReload.as` | 2 | `HotReload/InvokeContainerSignatureAfterReload/Before.as`, `HotReload/InvokeContainerSignatureAfterReload/After.as` |
| `HotReload/InvokeNativeStructSignatureAfterReload.as` | 2 | `HotReload/InvokeNativeStructSignatureAfterReload/Before.as`, `HotReload/InvokeNativeStructSignatureAfterReload/After.as` |
| `HotReload/InvokePrimitiveSignatureAfterParameterExpansion.as` | 2 | `HotReload/InvokePrimitiveSignatureAfterParameterExpansion/Before.as`, `HotReload/InvokePrimitiveSignatureAfterParameterExpansion/After.as` |
| `HotReload/InvokeReferenceSignatureAfterReload.as` | 2 | `HotReload/InvokeReferenceSignatureAfterReload/Before.as`, `HotReload/InvokeReferenceSignatureAfterReload/After.as` |
| `HotReload/InvokeScriptStructSignatureAfterReload.as` | 2 | `HotReload/InvokeScriptStructSignatureAfterReload/Before.as`, `HotReload/InvokeScriptStructSignatureAfterReload/After.as` |
| `HotReload/ModuleRecordTracking.as` | 2 | `HotReload/ModuleRecordTracking/Before.as`, `HotReload/ModuleRecordTracking/After.as` |
| `HotReload/MultiClassModuleReloadUpdatesChangedClassAndKeepsSiblingQueryable.as` | 2 | `HotReload/MultiClassModuleReloadUpdatesChangedClassAndKeepsSiblingQueryable/Before.as`, `HotReload/MultiClassModuleReloadUpdatesChangedClassAndKeepsSiblingQueryable/After.as` |
| `HotReload/MulticastDelegateRuntimeRunsAcrossReloads.as` | 2 | `HotReload/MulticastDelegateRuntimeRunsAcrossReloads/Before.as`, `HotReload/MulticastDelegateRuntimeRunsAcrossReloads/After.as` |
| `HotReload/MultiplePIESessionsAndReloadsStayConsistent.as` | 4 | `HotReload/MultiplePIESessionsAndReloadsStayConsistent/Version_01.as`, `HotReload/MultiplePIESessionsAndReloadsStayConsistent/Version_02.as`, `HotReload/MultiplePIESessionsAndReloadsStayConsistent/Version_03.as`, `HotReload/MultiplePIESessionsAndReloadsStayConsistent/Version_04.as` |
| `HotReload/MultipleSoftReloadsUpdateRunningBlueprintChildFunction.as` | 4 | `HotReload/MultipleSoftReloadsUpdateRunningBlueprintChildFunction/Version_01.as`, `HotReload/MultipleSoftReloadsUpdateRunningBlueprintChildFunction/Version_02.as`, `HotReload/MultipleSoftReloadsUpdateRunningBlueprintChildFunction/Version_03.as`, `HotReload/MultipleSoftReloadsUpdateRunningBlueprintChildFunction/Version_04.as` |
| `HotReload/NativeInterfaceDispatchUsesReloadedSoftBody.as` | 2 | `HotReload/NativeInterfaceDispatchUsesReloadedSoftBody/Before.as`, `HotReload/NativeInterfaceDispatchUsesReloadedSoftBody/After.as` |
| `HotReload/NegativeDelegateRuntimeErrorsStayExplicitAcrossReloads.as` | 2 | `HotReload/NegativeDelegateRuntimeErrorsStayExplicitAcrossReloads/Before.as`, `HotReload/NegativeDelegateRuntimeErrorsStayExplicitAcrossReloads/After.as` |
| `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions.as` | 7 | `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions/Version_01.as`, `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions/Version_02.as`, `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions/Version_03.as`, `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions/Version_04.as`, `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions/Version_05.as`, `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions/Version_06.as`, `HotReload/PIEReloadMatrixCoversBeforeDuringAfterAndRepeatedSessions/Version_07.as` |
| `HotReload/PostReloadModeFlagMatchesReloadPath.as` | 3 | `HotReload/PostReloadModeFlagMatchesReloadPath/Version_01.as`, `HotReload/PostReloadModeFlagMatchesReloadPath/Version_02.as`, `HotReload/PostReloadModeFlagMatchesReloadPath/Version_03.as` |
| `HotReload/PropertyCountChange.as` | 2 | `HotReload/PropertyCountChange/Before.as`, `HotReload/PropertyCountChange/After.as` |
| `HotReload/PropertyRemovalDropsFieldFromReplacementClass.as` | 2 | `HotReload/PropertyRemovalDropsFieldFromReplacementClass/Before.as`, `HotReload/PropertyRemovalDropsFieldFromReplacementClass/After.as` |
| `HotReload/PropertySpecifierReloadUpdatesFlags.as` | 2 | `HotReload/PropertySpecifierReloadUpdatesFlags/Before.as`, `HotReload/PropertySpecifierReloadUpdatesFlags/After.as` |
| `HotReload/PropertyTypeChangeReplacesFieldType.as` | 2 | `HotReload/PropertyTypeChangeReplacesFieldType/Before.as`, `HotReload/PropertyTypeChangeReplacesFieldType/After.as` |
| `HotReload/ProviderSoftReloadRebindsDeclaredImportConsumer.as` | 3 | `HotReload/ProviderSoftReloadRebindsDeclaredImportConsumer/Version_01.as`, `HotReload/ProviderSoftReloadRebindsDeclaredImportConsumer/Version_02.as`, `HotReload/ProviderSoftReloadRebindsDeclaredImportConsumer/Version_03.as` |
| `HotReload/ProviderStructFullReloadRetargetsConsumerFunctionParameter.as` | 4 | `HotReload/ProviderStructFullReloadRetargetsConsumerFunctionParameter/Version_01.as`, `HotReload/ProviderStructFullReloadRetargetsConsumerFunctionParameter/Version_02.as`, `HotReload/ProviderStructFullReloadRetargetsConsumerFunctionParameter/Version_03.as`, `HotReload/ProviderStructFullReloadRetargetsConsumerFunctionParameter/Version_04.as` |
| `HotReload/ReloadAfterPIEEndsAppliesToNextPIESession.as` | 2 | `HotReload/ReloadAfterPIEEndsAppliesToNextPIESession/Before.as`, `HotReload/ReloadAfterPIEEndsAppliesToNextPIESession/After.as` |
| `HotReload/ReloadBeforePIEStartsUsesReloadedScriptInPIE.as` | 2 | `HotReload/ReloadBeforePIEStartsUsesReloadedScriptInPIE/Before.as`, `HotReload/ReloadBeforePIEStartsUsesReloadedScriptInPIE/After.as` |
| `HotReload/ReplicationMetadataAndLifetimeListUpdateAfterFullReload.as` | 2 | `HotReload/ReplicationMetadataAndLifetimeListUpdateAfterFullReload/Before.as`, `HotReload/ReplicationMetadataAndLifetimeListUpdateAfterFullReload/After.as` |
| `HotReload/RequiredFullReloadDuringPIEKeepsOldCodeActive.as` | 2 | `HotReload/RequiredFullReloadDuringPIEKeepsOldCodeActive/Before.as`, `HotReload/RequiredFullReloadDuringPIEKeepsOldCodeActive/After.as` |
| `HotReload/RpcFlagsAndValidateCacheUpdateAfterFullReload.as` | 2 | `HotReload/RpcFlagsAndValidateCacheUpdateAfterFullReload/Before.as`, `HotReload/RpcFlagsAndValidateCacheUpdateAfterFullReload/After.as` |
| `HotReload/SoftReloadDuringPIEUpdatesLiveLevelScriptBody.as` | 2 | `HotReload/SoftReloadDuringPIEUpdatesLiveLevelScriptBody/Before.as`, `HotReload/SoftReloadDuringPIEUpdatesLiveLevelScriptBody/After.as` |
| `HotReload/SoftReloadDuringTwoPlayerPIEUpdatesServerAndClientLevelScripts.as` | 2 | `HotReload/SoftReloadDuringTwoPlayerPIEUpdatesServerAndClientLevelScripts/Before.as`, `HotReload/SoftReloadDuringTwoPlayerPIEUpdatesServerAndClientLevelScripts/After.as` |
| `HotReload/SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody.as` | 2 | `HotReload/SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody/Before.as`, `HotReload/SoftReloadKeepsBlueprintChildInstanceOnUpdatedParentBody/After.as` |
| `HotReload/SoftReloadKeepsOpenEditorLevelBlueprintParentAndUpdatesBody.as` | 2 | `HotReload/SoftReloadKeepsOpenEditorLevelBlueprintParentAndUpdatesBody/Before.as`, `HotReload/SoftReloadKeepsOpenEditorLevelBlueprintParentAndUpdatesBody/After.as` |
| `HotReload/SoftReloadPreservesNamespaceOverloadDispatch.as` | 2 | `HotReload/SoftReloadPreservesNamespaceOverloadDispatch/Before.as`, `HotReload/SoftReloadPreservesNamespaceOverloadDispatch/After.as` |
| `HotReload/SoftReloadPreservesUnrelatedModuleExecution.as` | 3 | `HotReload/SoftReloadPreservesUnrelatedModuleExecution/Version_01.as`, `HotReload/SoftReloadPreservesUnrelatedModuleExecution/Version_02.as`, `HotReload/SoftReloadPreservesUnrelatedModuleExecution/Version_03.as` |
| `HotReload/SoftReloadRequirement.as` | 2 | `HotReload/SoftReloadRequirement/Before.as`, `HotReload/SoftReloadRequirement/After.as` |
| `HotReload/SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass.as` | 2 | `HotReload/SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass/Before.as`, `HotReload/SoftReloadUpdatesMemberFunctionBodyWithoutReplacingClass/After.as` |
| `HotReload/SoftReloadUpdatesNamespaceFunctionDispatch.as` | 2 | `HotReload/SoftReloadUpdatesNamespaceFunctionDispatch/Before.as`, `HotReload/SoftReloadUpdatesNamespaceFunctionDispatch/After.as` |
| `HotReload/SoftReloadUpdatesNestedNamespaceFunctionDispatch.as` | 2 | `HotReload/SoftReloadUpdatesNestedNamespaceFunctionDispatch/Before.as`, `HotReload/SoftReloadUpdatesNestedNamespaceFunctionDispatch/After.as` |
| `HotReload/StructFullReloadReplacesScriptStructAndKeepsVersionChain.as` | 2 | `HotReload/StructFullReloadReplacesScriptStructAndKeepsVersionChain/Before.as`, `HotReload/StructFullReloadReplacesScriptStructAndKeepsVersionChain/After.as` |
| `HotReload/StructLayoutReloadMarksBlueprintVariablesAndPinsImpacted.as` | 2 | `HotReload/StructLayoutReloadMarksBlueprintVariablesAndPinsImpacted/Before.as`, `HotReload/StructLayoutReloadMarksBlueprintVariablesAndPinsImpacted/After.as` |
| `HotReload/StructPropertyRetargetsToReloadedStruct.as` | 2 | `HotReload/StructPropertyRetargetsToReloadedStruct/Before.as`, `HotReload/StructPropertyRetargetsToReloadedStruct/After.as` |
| `HotReload/StructUFunctionParameterExecutesAfterReload.as` | 2 | `HotReload/StructUFunctionParameterExecutesAfterReload/Before.as`, `HotReload/StructUFunctionParameterExecutesAfterReload/After.as` |
| `HotReload/StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults.as` | 3 | `HotReload/StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults/Version_01.as`, `HotReload/StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults/Version_02.as`, `HotReload/StructuralReloadKeepsExistingAndFreshBlueprintChildDefaults/Version_03.as` |
| `HotReload/SuggestedFullReloadDuringPIESoftAppliesBodyButDefersShape.as` | 2 | `HotReload/SuggestedFullReloadDuringPIESoftAppliesBodyButDefersShape/Before.as`, `HotReload/SuggestedFullReloadDuringPIESoftAppliesBodyButDefersShape/After.as` |
| `HotReload/SuggestedFullReloadDuringTwoPlayerPIEDefersShapeToNextSession.as` | 2 | `HotReload/SuggestedFullReloadDuringTwoPlayerPIEDefersShapeToNextSession/Before.as`, `HotReload/SuggestedFullReloadDuringTwoPlayerPIEDefersShapeToNextSession/After.as` |
| `HotReload/SuperClassChange.as` | 2 | `HotReload/SuperClassChange/Before.as`, `HotReload/SuperClassChange/After.as` |
| `HotReload/WorldSubsystemSoftReloadUpdatesCallableBehavior.as` | 2 | `HotReload/WorldSubsystemSoftReloadUpdatesCallableBehavior/Before.as`, `HotReload/WorldSubsystemSoftReloadUpdatesCallableBehavior/After.as` |
