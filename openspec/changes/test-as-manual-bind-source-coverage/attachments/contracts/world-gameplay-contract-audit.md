# World / Gameplay Contract V2 exhaustive audit

> Read-only pre-edit contract map. The exhaustive per-source and per-callable mapping is in `world-gameplay-contract-audit.json`; this report does not claim UE compilation or runner execution.

## Outcome

- Mapped all **385** source files and **1839** callable definitions: **123** World files, **262** Gameplay files, and **3** nested lambdas.
- **12** declarative/negative source files intentionally contain no callable body; they remain mapped at file level through CaseId, exact declarations/types, fixture, diagnostic or C++-injected runner contract, and cleanup evidence.
- Designed owner-qualified mappings for **931** legacy/opaque names. **407** callbacks/operators/reflected surfaces keep exact names with a non-empty reason.
- Classified **853** declarations as `reviewed-exact` and **986** as `blocking-review-required`; a blocking declaration is a hard pre-edit gate, not an execution claim.
- At source granularity, **102** files are `reviewed-exact` and **283** files remain `blocking-review-required` because at least one callable or high-risk shorthand still needs exact raw-type/lifecycle resolution.
- Incorporated **75** detailed high-risk lifecycle/identity files: 54 World and 21 Gameplay.
- High-risk detail provides exact planned declarations for **60** files. **10** detailed directives contain shorthand ellipses and therefore remain blocking until expanded against source/C++ evidence. **49** in-scope DefaultComponent files carry the non-null identity correction.
- Input corpus SHA-256: `1c410dc6627c63ca8290878d21a2446cf90c8fb2161be8cbcb2374a65ad5e9ea`. Inventory SHA-256: `3e8da3b5b0c3d1158736043912e2a6f93d5f7ce31bfd13c0cd43cb31a7d1dde5`. High-risk audit SHA-256: `a1543090f6da12078102f53e92d1709338caff10fdaf62b693adc24d240fee32`. JSON SHA-256: `80270a4f52a8b54d326a70cd0f1e6ff5f986e53f691c34688aad6a648677704d`.

## High-risk baseline reconciliation

The high-risk report summary says World has `53` Critical/High files, while its detailed tables resolve to `54` unique World paths. This audit retains every detailed row and records the one-file summary/detail mismatch instead of dropping a lifecycle rule. Gameplay agrees at `21` files.

Required corrections carried into each affected file include:

- every DefaultComponent pseudo-default is replaced by a non-null exact type/identity/owner/Outer/world/registration/attachment precondition plus a separate raw behavior snapshot;
- actor/component lifecycle, native events, RepNotify, Blueprint events, timers, and delegates are dispatched by the engine/native publisher/TimerManager, never by the observation wrapper;
- timer cases use configure → pre-deadline snapshot → real TimerManager advance → raw state snapshot → clear-handle cleanup phases;
- delegate cases use bind → real broadcast → raw payload/count snapshot → explicit unbind/destruction phases;
- NewObject/component and Blueprint/CDO cases preserve exact identity, class, Outer/owner, name/flags, world, registration, and instance-kind distinctions;
- no compile or execution PASS is inferred from the source-only audit.

## Defect inventory

- Compound boolean wrappers: `405`.
- Hard-coded zero-argument callables requiring review: `614`.
- Current Expected*/bExpect* argument defects: `3`; proposed declarations retain `0`.
- Shallow null/empty-handle observations: `78`.
- Direct lifecycle/timer/delegate/RepNotify dispatch defects: `37`.

## Deterministic disjoint implementation batches

### WG01-critical-destruction-timers

- Scope: `2` files / `9` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/World/Actor/Test_TimerActorDestroyStopsCallbacks.as`
  - `TestSource/World/Component/Test_TimerDestroyedComponentStopsCallbacks.as`

### WG02-default-component-identity

- Scope: `48` files / `200` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/Gameplay/Material/Test_ScriptCompilesDynamicMaterialAPI.as`
  - `TestSource/World/Component/Test_BoxComponent.as`
  - `TestSource/World/Component/Test_CameraComponent.as`
  - `TestSource/World/Component/Test_CapsuleComponent.as`
  - `TestSource/World/Component/Test_CharacterMovementComponent.as`
  - `TestSource/World/Component/Test_ComponentActivation.as`
  - `TestSource/World/Component/Test_ComponentCollisionEventDispatch.as`
  - `TestSource/World/Component/Test_ComponentDestruction.as`
  - `TestSource/World/Component/Test_ComponentDestructionCallbacksAndState.as`
  - `TestSource/World/Component/Test_ComponentFinding.as`
  - `TestSource/World/Component/Test_ComponentFindingByClassAndTag.as`
  - `TestSource/World/Component/Test_ComponentRuntimeTickIntervalControl.as`
  - `TestSource/World/Component/Test_ComponentTags.as`
  - `TestSource/World/Component/Test_ComponentTickConfigurationAndPrerequisites.as`
  - `TestSource/World/Component/Test_ComponentTickDispatchIsExact.as`
  - `TestSource/World/Component/Test_CustomScriptComponent.as`
  - `TestSource/World/Component/Test_CustomScriptSceneComponent.as`
  - `TestSource/World/Component/Test_DestroyComponentUnregistersRuntimeComponent.as`
  - `TestSource/World/Component/Test_EventBuiltInActorAndComponentInstances.as`
  - `TestSource/World/Component/Test_FourLevelAttachChainResolves.as`
  - `TestSource/World/Component/Test_GetAllComponents.as`
  - `TestSource/World/Component/Test_GetComponent.as`
  - `TestSource/World/Component/Test_GetOrCreateComponent.as`
  - `TestSource/World/Component/Test_HasBegunPlayTransitionsInWorld.as`
  - `TestSource/World/Component/Test_InterfaceComponentAndInput.as`
  - `TestSource/World/Component/Test_MultipleShapeComponents.as`
  - `TestSource/World/Component/Test_NameAndClassFilteringAreStrict.as`
  - `TestSource/World/Component/Test_PrimitiveCollisionChannelMatrixReadback.as`
  - `TestSource/World/Component/Test_PrimitiveCollisionConfigurationReadback.as`
  - `TestSource/World/Component/Test_PrimitiveCollisionEvents.as`
  - `TestSource/World/Component/Test_PrimitiveCollisionResponse.as`
  - `TestSource/World/Component/Test_PrimitiveHiddenInGame.as`
  - `TestSource/World/Component/Test_PrimitiveHitEvents.as`
  - `TestSource/World/Component/Test_PrimitivePhysics.as`
  - `TestSource/World/Component/Test_PrimitivePhysicsStateReadback.as`
  - `TestSource/World/Component/Test_PrimitiveRendering.as`
  - `TestSource/World/Component/Test_PrimitiveTraceObjectQueryReadback.as`
  - `TestSource/World/Component/Test_ReturnComponentsToCpp.as`
  - `TestSource/World/Component/Test_SceneComponentCompleteTransform.as`
  - `TestSource/World/Component/Test_SceneComponentHierarchy.as`
  - `TestSource/World/Component/Test_SceneComponentRelativeTransform.as`
  - `TestSource/World/Component/Test_SceneComponentTags.as`
  - `TestSource/World/Component/Test_SceneComponentWorldTransform.as`
  - `TestSource/World/Component/Test_SpecialComponentOperations.as`
  - `TestSource/World/Component/Test_SphereComponent.as`
  - `TestSource/World/Component/Test_SpringArmComponent.as`
  - `TestSource/World/Component/Test_StaticMeshComponent.as`
  - `TestSource/World/Component/Test_TimerComponentCallbacksRunOnOwnerWorld.as`

### WG03-real-delegate-broadcast-cleanup

- Scope: `8` files / `51` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/Gameplay/Input/Test_EnhancedInputTriggerEventReflectionPreservation.as`
  - `TestSource/Gameplay/Physics/Test_CollisionEvents.as`
  - `TestSource/Gameplay/Physics/Test_EventCollision.as`
  - `TestSource/Gameplay/Widget/Test_AdditionalWidgetDynamicEventsInvokeScriptHandlers.as`
  - `TestSource/Gameplay/Widget/Test_EventWidgetEventInstances.as`
  - `TestSource/Gameplay/Widget/Test_WidgetDynamicEventsInvokeScriptHandlers.as`
  - `TestSource/World/Actor/Test_ActorCollisionEvents.as`
  - `TestSource/World/Component/Test_EnhancedInputComponentBindingEventsAndRemoval.as`

### WG04-real-timer-manager-phases

- Scope: `27` files / `108` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/Gameplay/Timer/Test_EventTimer.as`
  - `TestSource/Gameplay/Timer/Test_LatentMovementFunctionsRemainCompileBoundaries.as`
  - `TestSource/Gameplay/Timer/Test_MultipleTimers.as`
  - `TestSource/Gameplay/Timer/Test_SystemDelay.as`
  - `TestSource/Gameplay/Timer/Test_SystemDelayCompilesWithoutDeterministicLatentAdvance.as`
  - `TestSource/Gameplay/Timer/Test_TimerBasicUsage.as`
  - `TestSource/Gameplay/Timer/Test_TimerClearAndInvalidate.as`
  - `TestSource/Gameplay/Timer/Test_TimerClearThenReuseHandleVariable.as`
  - `TestSource/Gameplay/Timer/Test_TimerDelayExecution.as`
  - `TestSource/Gameplay/Timer/Test_TimerDynamicFunctionNameReflectionLifecycle.as`
  - `TestSource/Gameplay/Timer/Test_TimerFirstDelay.as`
  - `TestSource/Gameplay/Timer/Test_TimerHandleInvalidationAndSupportedQueries.as`
  - `TestSource/Gameplay/Timer/Test_TimerHandlePauseUnpauseAndClear.as`
  - `TestSource/Gameplay/Timer/Test_TimerImmediateExecution.as`
  - `TestSource/Gameplay/Timer/Test_TimerInvalidHandleQueriesStayDeterministic.as`
  - `TestSource/Gameplay/Timer/Test_TimerLambdaCapture.as`
  - `TestSource/Gameplay/Timer/Test_TimerManagement.as`
  - `TestSource/Gameplay/Timer/Test_TimerRemainingAndElapsed.as`
  - `TestSource/Gameplay/Timer/Test_TimerRepeatedFunctionNameReplacesExistingTimer.as`
  - `TestSource/Gameplay/Timer/Test_TimerUiCountdownAndAiStatePatterns.as`
  - `TestSource/Gameplay/Timer/Test_TimerUseCaseBuffDuration.as`
  - `TestSource/Gameplay/Timer/Test_TimerUseCasePeriodicCheck.as`
  - `TestSource/Gameplay/Timer/Test_TimerUseCaseSkillCooldown.as`
  - `TestSource/Gameplay/Timer/Test_TimerWithParameters.as`
  - `TestSource/World/Actor/Test_PauseUnpauseAndClearTransitionsAreObservable.as`
  - `TestSource/World/Actor/Test_TimerDelayedSpawnUseCaseRunsFromWorldTimer.as`
  - `TestSource/World/Component/Test_TimerCompileStableActorAndComponentCallSites.as`

### WG05-world-component-remaining

- Scope: `22` files / `65` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/World/Component/Test_ActorOwner.as`
  - `TestSource/World/Component/Test_AdvancedInputComponentBindingCollections.as`
  - `TestSource/World/Component/Test_AudioComponentDeclarationAndControls.as`
  - `TestSource/World/Component/Test_AudioComponentFadeAndFilterControls.as`
  - `TestSource/World/Component/Test_AudioComponentRoutingAndReflectionSurface.as`
  - `TestSource/World/Component/Test_BeginPlay.as`
  - `TestSource/World/Component/Test_ComponentActorMultiAndDynamicLifecycleOrdering.as`
  - `TestSource/World/Component/Test_ComponentBasicDeclaration.as`
  - `TestSource/World/Component/Test_ComponentLifecycle.as`
  - `TestSource/World/Component/Test_ComponentLifecycleOrdering.as`
  - `TestSource/World/Component/Test_ComponentManualNewObjectRegistration.as`
  - `TestSource/World/Component/Test_ComponentQueryEntrypointSmoke.as`
  - `TestSource/World/Component/Test_ComponentRegistrationAndActivation.as`
  - `TestSource/World/Component/Test_ComponentSpecialTypeDeclarations.as`
  - `TestSource/World/Component/Test_ComponentTickControl.as`
  - `TestSource/World/Component/Test_CreateComponent.as`
  - `TestSource/World/Component/Test_EndPlayReceivesDestroyedReason.as`
  - `TestSource/World/Component/Test_InputComponentFinding.as`
  - `TestSource/World/Component/Test_MemberObjectActorComponentReferences.as`
  - `TestSource/World/Component/Test_ReceiveEndPlay.as`
  - `TestSource/World/Component/Test_StaticTypedAccessorsCreateGetAndReuse.as`
  - `TestSource/World/Component/Test_Tick.as`

### WG06-world-actor-blueprint-subsystem-widget

- Scope: `47` files / `85` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/World/Actor/Test_ActorAuthorityQueryBranchesExecuteHeadless.as`
  - `TestSource/World/Actor/Test_ActorBeginOverlap.as`
  - `TestSource/World/Actor/Test_ActorEndOverlap.as`
  - `TestSource/World/Actor/Test_ActorNetworkRolePropertiesUnsupported_01.as`
  - `TestSource/World/Actor/Test_ActorNetworkRolePropertiesUnsupported_02.as`
  - `TestSource/World/Actor/Test_ActorNetworkRoleQueriesAreVisible.as`
  - `TestSource/World/Actor/Test_ActorOverlapGeneratedByMovement.as`
  - `TestSource/World/Actor/Test_ActorReplicationDefaults.as`
  - `TestSource/World/Actor/Test_AnyDamage.as`
  - `TestSource/World/Actor/Test_BeginPlay.as`
  - `TestSource/World/Actor/Test_BeginPlayIdempotent.as`
  - `TestSource/World/Actor/Test_CharacterMovementModeQueryStates.as`
  - `TestSource/World/Actor/Test_CharacterMovementVelocityQuery.as`
  - `TestSource/World/Actor/Test_ConstructionScript.as`
  - `TestSource/World/Actor/Test_CrossCall.as`
  - `TestSource/World/Actor/Test_DefaultValues.as`
  - `TestSource/World/Actor/Test_DestroyLifecycleOrder.as`
  - `TestSource/World/Actor/Test_FactoriesAndTransformMutators.as`
  - `TestSource/World/Actor/Test_HandleDestroyActorInvalidatesReference.as`
  - `TestSource/World/Actor/Test_InterfaceBoundMethods.as`
  - `TestSource/World/Actor/Test_InterfaceSpawnAndQuery.as`
  - `TestSource/World/Actor/Test_MultiSpawn.as`
  - `TestSource/World/Actor/Test_MultipleSpawnSyntaxesProduceValidActors.as`
  - `TestSource/World/Actor/Test_OldInstigatorAliasNamesAreRejected_01.as`
  - `TestSource/World/Actor/Test_OldInstigatorAliasNamesAreRejected_02.as`
  - `TestSource/World/Actor/Test_PawnControllerAndLocalControlQueries.as`
  - `TestSource/World/Actor/Test_PointDamage.as`
  - `TestSource/World/Actor/Test_RadialDamage.as`
  - `TestSource/World/Actor/Test_ReceiveDestroyed.as`
  - `TestSource/World/Actor/Test_ReceiveEndPlay.as`
  - `TestSource/World/Actor/Test_ReceiveEndPlayReason.as`
  - `TestSource/World/Actor/Test_Reset.as`
  - `TestSource/World/Actor/Test_SpawnActorInvalidClassThrowsException.as`
  - `TestSource/World/Actor/Test_SpawnParametersDriveTransformTypedAndDeferredSpawns.as`
  - `TestSource/World/Actor/Test_Tick.as`
  - `TestSource/World/Actor/Test_TickRegisteredDispatch.as`
  - `TestSource/World/Blueprint/Test_ChangedScriptFilter_01.as`
  - `TestSource/World/Blueprint/Test_ChangedScriptFilter_02.as`
  - `TestSource/World/Blueprint/Test_DefaultPreservation.as`
  - `TestSource/World/Blueprint/Test_DiskBackedAssetScan.as`
  - `TestSource/World/Blueprint/Test_RecreateDoesNotLeakState.as`
  - `TestSource/World/Blueprint/Test_ScriptParentMatch.as`
  - `TestSource/World/Subsystem/GameInstance/Test_Lifecycle.as`
  - `TestSource/World/Subsystem/World/Test_ActorAccess.as`
  - `TestSource/World/Subsystem/World/Test_Lifecycle.as`
  - `TestSource/World/Subsystem/World/Test_Tick.as`
  - `TestSource/World/Widget/Test_WidgetClassAndBindWidgetReflection.as`

### WG07-gameplay-engine-object-surfaces

- Scope: `33` files / `107` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/Gameplay/Anim/Test_EventRepNotifyExecutesStateChange.as`
  - `TestSource/Gameplay/Physics/Test_Accessors.as`
  - `TestSource/Gameplay/Physics/Test_CollisionChannelMatrix.as`
  - `TestSource/Gameplay/Physics/Test_CollisionChannelsAndResponses.as`
  - `TestSource/Gameplay/Physics/Test_CollisionObjectQueryInitTypes.as`
  - `TestSource/Gameplay/Physics/Test_CollisionProfilesAndEnabledModes.as`
  - `TestSource/Gameplay/Physics/Test_CollisionQueryParameterContainers.as`
  - `TestSource/Gameplay/Physics/Test_CollisionResponseContainerOperations.as`
  - `TestSource/Gameplay/Physics/Test_HitResultExtendedAccessors.as`
  - `TestSource/Gameplay/Physics/Test_HitResultFields.as`
  - `TestSource/Gameplay/Physics/Test_OverlapDetection.as`
  - `TestSource/Gameplay/Physics/Test_PhysicsForces.as`
  - `TestSource/Gameplay/Physics/Test_PhysicsMaterialHitResultReference.as`
  - `TestSource/Gameplay/Physics/Test_PhysicsSimulation.as`
  - `TestSource/Gameplay/Physics/Test_PhysicsVelocity.as`
  - `TestSource/Gameplay/Physics/Test_TraceFunctionLibraryEntrypointSmoke.as`
  - `TestSource/Gameplay/Physics/Test_TraceObjectProfileAndSweepVariants.as`
  - `TestSource/Gameplay/Physics/Test_TraceOperations.as`
  - `TestSource/Gameplay/Widget/Test_BorderAndMarginStateRoundTrips.as`
  - `TestSource/Gameplay/Widget/Test_ButtonStyleRoundTrip.as`
  - `TestSource/Gameplay/Widget/Test_ComboPanelSizeBoxAndBrushStateRoundTrips.as`
  - `TestSource/Gameplay/Widget/Test_CommonControlPropertyMethods.as`
  - `TestSource/Gameplay/Widget/Test_ContainerLayoutOperations.as`
  - `TestSource/Gameplay/Widget/Test_CreateWidgetAndViewportSurface_01.as`
  - `TestSource/Gameplay/Widget/Test_CreateWidgetAndViewportSurface_02.as`
  - `TestSource/Gameplay/Widget/Test_GetWidgetFromNameUnsupportedBoundary.as`
  - `TestSource/Gameplay/Widget/Test_ImageResourceBrushRoundTrip.as`
  - `TestSource/Gameplay/Widget/Test_OverlayLayerOrderOperations.as`
  - `TestSource/Gameplay/Widget/Test_SlateStyleValueTypes.as`
  - `TestSource/Gameplay/Widget/Test_TextBlockTextAndColorRoundTrip.as`
  - `TestSource/Gameplay/Widget/Test_WidgetTreeRuntimeOperations_01.as`
  - `TestSource/Gameplay/Widget/Test_WidgetTreeRuntimeOperations_02.as`
  - `TestSource/Gameplay/Widget/Test_WidgetVisibilityEnabledAndFocusQueries.as`

### WG08-gameplay-value-math

- Scope: `103` files / `859` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/Gameplay/FLinearColor/Test_FLinearColorAdvancedMethods.as`
  - `TestSource/Gameplay/FLinearColor/Test_FLinearColorClassMemberExecution.as`
  - `TestSource/Gameplay/FLinearColor/Test_FLinearColorContainerProperties.as`
  - `TestSource/Gameplay/FLinearColor/Test_FLinearColorDeclarationDefaults.as`
  - `TestSource/Gameplay/FLinearColor/Test_FLinearColorWriteRoundTrip.as`
  - `TestSource/Gameplay/FLinearColor/Test_FunctionDefaultParameters.as`
  - `TestSource/Gameplay/FLinearColor/Test_FunctionParametersIn.as`
  - `TestSource/Gameplay/FLinearColor/Test_FunctionParametersInOut.as`
  - `TestSource/Gameplay/FLinearColor/Test_FunctionParametersOut.as`
  - `TestSource/Gameplay/FLinearColor/Test_FunctionParametersValue.as`
  - `TestSource/Gameplay/FLinearColor/Test_FunctionReturnValues.as`
  - `TestSource/Gameplay/FLinearColor/Test_LinearColorArithmeticOperators.as`
  - `TestSource/Gameplay/FLinearColor/Test_LinearColorComparisonOperators.as`
  - `TestSource/Gameplay/FLinearColor/Test_LinearColorConstruction.as`
  - `TestSource/Gameplay/FLinearColor/Test_LinearColorMemberAccess.as`
  - `TestSource/Gameplay/FLinearColor/Test_LinearColorMethods.as`
  - `TestSource/Gameplay/FLinearColor/Test_LinearColorUnsupportedMethods.as`
  - `TestSource/Gameplay/FLinearColor/Test_RuntimeCurveLinearColorAddDefaultKey.as`
  - `TestSource/Gameplay/FRotator/Test_FRotatorContainerProperties.as`
  - `TestSource/Gameplay/FRotator/Test_FRotatorDeclarationDefaults.as`
  - `TestSource/Gameplay/FRotator/Test_FRotatorWriteRoundTrip.as`
  - `TestSource/Gameplay/FRotator/Test_FunctionDefaultParameters.as`
  - `TestSource/Gameplay/FRotator/Test_FunctionParametersIn.as`
  - `TestSource/Gameplay/FRotator/Test_FunctionParametersInOut.as`
  - `TestSource/Gameplay/FRotator/Test_FunctionParametersOut.as`
  - `TestSource/Gameplay/FRotator/Test_FunctionParametersValue.as`
  - `TestSource/Gameplay/FRotator/Test_FunctionReturnValues.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorArithmeticOperators.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorComparisonOperators.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorConstruction.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorConversionMethods.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorDeclarationsAndConfirmedMethods.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorMemberAccess.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorNormalizationMethods.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorStaticMethods.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorUnsupportedOperators.as`
  - `TestSource/Gameplay/FRotator/Test_RotatorUnsupportedStaticMethods.as`
  - `TestSource/Gameplay/FTransform/Test_FTransformConstruction.as`
  - `TestSource/Gameplay/FTransform/Test_FTransformContainerProperties.as`
  - `TestSource/Gameplay/FTransform/Test_FTransformDeclarationDefaults.as`
  - `TestSource/Gameplay/FTransform/Test_FTransformMemberAccess.as`
  - `TestSource/Gameplay/FTransform/Test_FTransformOperations.as`
  - `TestSource/Gameplay/FTransform/Test_FTransformWriteRoundTrip.as`
  - `TestSource/Gameplay/FTransform/Test_FunctionDefaultParameters.as`
  - `TestSource/Gameplay/FTransform/Test_FunctionParametersIn.as`
  - `TestSource/Gameplay/FTransform/Test_FunctionParametersInOut.as`
  - `TestSource/Gameplay/FTransform/Test_FunctionParametersOut.as`
  - `TestSource/Gameplay/FTransform/Test_FunctionParametersValue.as`
  - `TestSource/Gameplay/FTransform/Test_FunctionReturnValues.as`
  - `TestSource/Gameplay/FTransform/Test_RenderTransformNullGuard.as`
  - `TestSource/Gameplay/FTransform/Test_TransformAdvancedMethodsAndMutators.as`
  - `TestSource/Gameplay/FTransform/Test_TransformComparison.as`
  - `TestSource/Gameplay/FTransform/Test_TransformComposition.as`
  - `TestSource/Gameplay/FTransform/Test_TransformConstruction.as`
  - `TestSource/Gameplay/FTransform/Test_TransformInterpolation_01.as`
  - `TestSource/Gameplay/FTransform/Test_TransformInterpolation_02.as`
  - `TestSource/Gameplay/FTransform/Test_TransformInverse.as`
  - `TestSource/Gameplay/FTransform/Test_TransformMemberAccess_01.as`
  - `TestSource/Gameplay/FTransform/Test_TransformMemberAccess_02.as`
  - `TestSource/Gameplay/FTransform/Test_TransformPositionAndVector.as`
  - `TestSource/Gameplay/FVector/Test_DefaultFVectorPropertyApplied.as`
  - `TestSource/Gameplay/FVector/Test_FVectorArithmeticOperators.as`
  - `TestSource/Gameplay/FVector/Test_FVectorComparisonOperators.as`
  - `TestSource/Gameplay/FVector/Test_FVectorConstruction_01.as`
  - `TestSource/Gameplay/FVector/Test_FVectorConstruction_02.as`
  - `TestSource/Gameplay/FVector/Test_FVectorContainerProperties.as`
  - `TestSource/Gameplay/FVector/Test_FVectorDeclarationDefaults.as`
  - `TestSource/Gameplay/FVector/Test_FVectorDeclarationsAndIndexAccess.as`
  - `TestSource/Gameplay/FVector/Test_FVectorDotAndCross_01.as`
  - `TestSource/Gameplay/FVector/Test_FVectorDotAndCross_02.as`
  - `TestSource/Gameplay/FVector/Test_FVectorExtendedOperatorsAndMethods.as`
  - `TestSource/Gameplay/FVector/Test_FVectorMemberAccess.as`
  - `TestSource/Gameplay/FVector/Test_FVectorMethods_01.as`
  - `TestSource/Gameplay/FVector/Test_FVectorMethods_02.as`
  - `TestSource/Gameplay/FVector/Test_FVectorScriptMemberAndLocalUsage.as`
  - `TestSource/Gameplay/FVector/Test_FVectorWriteRoundTrip.as`
  - `TestSource/Gameplay/FVector/Test_FunctionDefaultParameters.as`
  - `TestSource/Gameplay/FVector/Test_FunctionParametersInOut.as`
  - `TestSource/Gameplay/FVector/Test_FunctionParametersIn_01.as`
  - `TestSource/Gameplay/FVector/Test_FunctionParametersIn_02.as`
  - `TestSource/Gameplay/FVector/Test_FunctionParametersOut.as`
  - `TestSource/Gameplay/FVector/Test_FunctionParametersValue_01.as`
  - `TestSource/Gameplay/FVector/Test_FunctionParametersValue_02.as`
  - `TestSource/Gameplay/FVector/Test_FunctionReturnValues.as`
  - `TestSource/Gameplay/FVector/Test_Vector4IntPointIntVectorExpressions.as`
  - `TestSource/Gameplay/FVector2D/Test_FVector2DContainerProperties.as`
  - `TestSource/Gameplay/FVector2D/Test_FVector2DDeclarationDefaults.as`
  - `TestSource/Gameplay/FVector2D/Test_FVector2DWriteRoundTrip.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionDefaultParameters.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionParametersInOut.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionParametersIn_01.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionParametersIn_02.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionParametersOut.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionParametersValue_01.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionParametersValue_02.as`
  - `TestSource/Gameplay/FVector2D/Test_FunctionReturnValues.as`
  - `TestSource/Gameplay/FVector2D/Test_Vector2DArithmeticOperators.as`
  - `TestSource/Gameplay/FVector2D/Test_Vector2DComparisonOperators.as`
  - `TestSource/Gameplay/FVector2D/Test_Vector2DConstruction_01.as`
  - `TestSource/Gameplay/FVector2D/Test_Vector2DConstruction_02.as`
  - `TestSource/Gameplay/FVector2D/Test_Vector2DDotProduct_01.as`
  - `TestSource/Gameplay/FVector2D/Test_Vector2DDotProduct_02.as`
  - `TestSource/Gameplay/FVector2D/Test_Vector2DMemberAccess.as`

### WG09-gameplay-remaining

- Scope: `95` files / `355` current callables.
- Entry: review every blocking declaration and all high-risk directives before any file in this batch is edited.
- Exit: 1:1 callable reconciliation, no direct engine/timer/delegate callback test entry, exact typed raw observations, adjacent comments, cleanup, and focused runner evidence.
- Files:

  - `TestSource/Gameplay/Assets/Test_NullAndInvalidCallbackGuards.as`
  - `TestSource/Gameplay/CVar/Test_CVarSafeAccessAndExistingVariable.as`
  - `TestSource/Gameplay/Debug/Test_CallstackAndThrowBindings.as`
  - `TestSource/Gameplay/Debug/Test_ConditionalLogFunctionsGateOutput.as`
  - `TestSource/Gameplay/Debug/Test_ConditionalLogging.as`
  - `TestSource/Gameplay/Debug/Test_ConsoleProfilerAndDebuggerControlsFailToCompile_01.as`
  - `TestSource/Gameplay/Debug/Test_ConsoleProfilerAndDebuggerControlsFailToCompile_02.as`
  - `TestSource/Gameplay/Debug/Test_ConsoleProfilerAndDebuggerControlsFailToCompile_03.as`
  - `TestSource/Gameplay/Debug/Test_ContextRichLogging.as`
  - `TestSource/Gameplay/Debug/Test_CpuProfilerScopedEventIsScriptFacing.as`
  - `TestSource/Gameplay/Debug/Test_DebugBreakBindingCanBeDisabledForAutomation.as`
  - `TestSource/Gameplay/Debug/Test_DebugErrorHandlingPatterns.as`
  - `TestSource/Gameplay/Debug/Test_DebuggerClientOnlyFeaturesFailToCompile_01.as`
  - `TestSource/Gameplay/Debug/Test_DebuggerClientOnlyFeaturesFailToCompile_02.as`
  - `TestSource/Gameplay/Debug/Test_DebuggerClientOnlyFeaturesFailToCompile_03.as`
  - `TestSource/Gameplay/Debug/Test_DebuggerClientOnlyFeaturesFailToCompile_04.as`
  - `TestSource/Gameplay/Debug/Test_DebuggerClientOnlyFeaturesFailToCompile_05.as`
  - `TestSource/Gameplay/Debug/Test_DebuggerClientOnlyFeaturesFailToCompile_06.as`
  - `TestSource/Gameplay/Debug/Test_DebuggingWorkflowPatternsUseCallableScriptHelpers.as`
  - `TestSource/Gameplay/Debug/Test_DrawDebugStringFromObject.as`
  - `TestSource/Gameplay/Debug/Test_DrawDebugStringParameters.as`
  - `TestSource/Gameplay/Debug/Test_EnsureAndCheckBindings.as`
  - `TestSource/Gameplay/Debug/Test_FormattedDebugLoggingSurfaceIncludesValuesAndContext.as`
  - `TestSource/Gameplay/Debug/Test_FunctionEntryExitLogging.as`
  - `TestSource/Gameplay/Debug/Test_GuardedNegativeBoundariesPreserveFallbacks.as`
  - `TestSource/Gameplay/Debug/Test_LogCategories.as`
  - `TestSource/Gameplay/Debug/Test_LogFormatting.as`
  - `TestSource/Gameplay/Debug/Test_LogSeverityHelpersEmitExpectedVerbosity.as`
  - `TestSource/Gameplay/Debug/Test_LogVerbosityFunctionsEmitExpectedCategories.as`
  - `TestSource/Gameplay/Debug/Test_NativeLogVerbosityEnumsRemainCompileTimeBoundary_01.as`
  - `TestSource/Gameplay/Debug/Test_NativeLogVerbosityEnumsRemainCompileTimeBoundary_02.as`
  - `TestSource/Gameplay/Debug/Test_NativeLogVerbosityEnumsRemainCompileTimeBoundary_03.as`
  - `TestSource/Gameplay/Debug/Test_NegativeCompileBoundaries_01.as`
  - `TestSource/Gameplay/Debug/Test_NegativeCompileBoundaries_02.as`
  - `TestSource/Gameplay/Debug/Test_NegativeCompileBoundaries_03.as`
  - `TestSource/Gameplay/Debug/Test_NegativeRuntimeAndCompileBoundaries.as`
  - `TestSource/Gameplay/Debug/Test_NullBoundsEarlyReturnAndRetry.as`
  - `TestSource/Gameplay/Debug/Test_ObjectInspectionHelpersExposeNamesAndOuter.as`
  - `TestSource/Gameplay/Debug/Test_PerformanceConsciousLogging.as`
  - `TestSource/Gameplay/Debug/Test_PrintFunctions.as`
  - `TestSource/Gameplay/Debug/Test_ProfilerDebugPatternsUseScopedEventsCountersAndScratchMemory.as`
  - `TestSource/Gameplay/Debug/Test_ReturnPatternsAndOutResults.as`
  - `TestSource/Gameplay/Debug/Test_StatAndShowCommandNamesDispatchThroughRegisteredConsoleCommand.as`
  - `TestSource/Gameplay/Debug/Test_ThrowIfReportsScriptException.as`
  - `TestSource/Gameplay/Debug/Test_UnsupportedDrawDebugShapeParametersFailToCompile_01.as`
  - `TestSource/Gameplay/Debug/Test_UnsupportedDrawDebugShapeParametersFailToCompile_02.as`
  - `TestSource/Gameplay/Debug/Test_UnsupportedDrawDebugShapeParametersFailToCompile_03.as`
  - `TestSource/Gameplay/Debug/Test_UnsupportedDrawDebugShapeParametersFailToCompile_04.as`
  - `TestSource/Gameplay/Debug/Test_UnsupportedDrawDebugShapeParametersFailToCompile_05.as`
  - `TestSource/Gameplay/Debug/Test_UnsupportedDrawDebugShapeParametersFailToCompile_06.as`
  - `TestSource/Gameplay/Debug/Test_UnsupportedDrawDebugShapeParametersFailToCompile_07.as`
  - `TestSource/Gameplay/FQuat/Test_QuatAdvancedOperatorsAndMethods.as`
  - `TestSource/Gameplay/FQuat/Test_QuatConstruction.as`
  - `TestSource/Gameplay/FQuat/Test_QuatConversionMethods.as`
  - `TestSource/Gameplay/FQuat/Test_QuatInverseAndNormalize.as`
  - `TestSource/Gameplay/FQuat/Test_QuatMemberAccess.as`
  - `TestSource/Gameplay/FQuat/Test_QuatMultiplicationOperator.as`
  - `TestSource/Gameplay/FQuat/Test_QuatRotateVector.as`
  - `TestSource/Gameplay/FQuat/Test_QuatStaticMethods.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_01.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_02.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_03.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_04.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_05.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_06.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_07.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputAndDeviceBoundaryInventory_08.as`
  - `TestSource/Gameplay/Input/Test_EnhancedInputModifiersAndTriggers.as`
  - `TestSource/Gameplay/Input/Test_InputModeControl.as`
  - `TestSource/Gameplay/Input/Test_InputModeSwitchingUnsupportedBoundary_01.as`
  - `TestSource/Gameplay/Input/Test_InputModeSwitchingUnsupportedBoundary_02.as`
  - `TestSource/Gameplay/Input/Test_InputModeSwitchingUnsupportedBoundary_03.as`
  - `TestSource/Gameplay/Input/Test_InputStateQuery.as`
  - `TestSource/Gameplay/Net/Test_ClientDeclarationCompiles.as`
  - `TestSource/Gameplay/Net/Test_ComplexReplicatedTypes.as`
  - `TestSource/Gameplay/Net/Test_GameModeGameStateAndPlayerStateStaticSurface.as`
  - `TestSource/Gameplay/Net/Test_MixedDeclarationsCompile.as`
  - `TestSource/Gameplay/Net/Test_MultipleRPCsInSingleClass.as`
  - `TestSource/Gameplay/Net/Test_NetworkConsoleAndClientTravelBoundaries_01.as`
  - `TestSource/Gameplay/Net/Test_NetworkConsoleAndClientTravelBoundaries_02.as`
  - `TestSource/Gameplay/Net/Test_NetworkConsoleAndClientTravelBoundaries_03.as`
  - `TestSource/Gameplay/Net/Test_NetworkDebugLoggingPatterns.as`
  - `TestSource/Gameplay/Net/Test_NetworkRoleAndModeEnums.as`
  - `TestSource/Gameplay/Net/Test_PlayerControllerConnectionSurfaceCompiles.as`
  - `TestSource/Gameplay/Net/Test_PropertyReplicationConditionRoundTrip.as`
  - `TestSource/Gameplay/Net/Test_RPCReliabilityVariations.as`
  - `TestSource/Gameplay/Net/Test_RPCWithParameters.as`
  - `TestSource/Gameplay/Net/Test_ReplicatedPropertiesAndLifetimeList.as`
  - `TestSource/Gameplay/Net/Test_ReplicatedPropertiesWithDefaults.as`
  - `TestSource/Gameplay/Net/Test_ServerDeclarationCompiles.as`
  - `TestSource/Gameplay/Net/Test_UnknownReplicationConditionReportsDiagnostic.as`
  - `TestSource/Gameplay/Net/Test_UnreliableDeclarationCompiles.as`
  - `TestSource/Gameplay/Net/Test_WithValidationDeclarationCompiles.as`
  - `TestSource/Gameplay/Net/Test_WorldGameStateAndServerTravelSurface.as`
  - `TestSource/Gameplay/Net/Test_WorldNetModeQueryIsVisible.as`

## Validation

| Check | Result |
| --- | --- |
| Files mapped | `385/385` |
| Callable mappings | `1839/1839`; missing `0` |
| Declarative files with no callable body | `12` mapped at file level |
| Duplicate current owner-qualified identities | `0` |
| Duplicate proposed owner-qualified identities | `0` |
| Forbidden replacement names | `0` |
| Proposed Expected*/bExpect* arguments | `0` |
| Missing adjacent English comments | `0` |
| Deterministic batch coverage | `PASS` |
| Overall audit validator | `PASS` |

## Machine-readable contract record

For every callable, `world-gameplay-contract-audit.json` records source line, kind, namespace/type/outer-callable owner, current exact declaration and identity, stable CaseId/subcase, semantic replacement or required-name reason, exact proposed declaration, adjacent English comment facts, typed inputs, raw return, explicit writebacks, exception vectors, fixture phases, cleanup/isolation, runner status, body hash, direct calls, defects, and high-risk replacement directive. Source edits may consume only `reviewed-exact` rows; every `blocking-review-required` row must first be resolved against its source, C++ oracle, and high-risk overlay.
