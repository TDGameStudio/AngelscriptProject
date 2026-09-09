# Native layout installation verification

Task: 2.3. Parent base a9afd56e73b9289ed32dee8210d7b96ac0b3b578; plugin base edc13e98d7a63fa22b76620302d1294fe6126641.

## Commands and outcomes

- Build: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`.
- Setup f12565cff9004b869f097c4c0ffc825c failed on a test record type spelling; a5b94ecfc79a4e539847b5b1f3e2691e failed because a test referenced non-exported cast helpers. Corrected setup 7a2163f128144951945faa25a704dceb succeeded. Neither compile/link failure is behavioral RED.
- Initial eight-case RED 5b85bfd788364d99abba3083473ba348 failed all eight cases, exit 255. Source inspection additionally found case-insensitive metadata name keys. A ninth case was added before implementation; setup fd0fd7a7f8d94666875ec937d9abea05 succeeded and expanded RED 3993f6d01b9f483b8c5286fa93ce84fe failed all nine cases, exit 255.
- RED selection: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Types.Layouts.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- The stub demonstrated missing successful draft construction or missing provenance diagnostics. Assertions behind failed prerequisites are not independently claimed as RED. The case-sensitive collision was identified by code inspection; its initial test also stopped at missing draft construction.
- Implementation build 4f282aa6305f4f118a360f4ff5cb23f0 succeeded, exit 0.
- Shared GREEN: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`. Run 10fcf5cb83fe4279b3a1d641392647cb: 40 successes, zero errors/warnings, exit 0.
- Adjacent: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.MetadataImage.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`. Run 3070586db48e44d1adec0a39451e6660: 23 successes, zero errors/warnings, exit 0. This covers the shared metadata image owner, name-duplication, native layouts and alias/base invariants.
- All runs reached terminal managed status. Source writers were frozen throughout builds and tests.

The successful result owns an unbound Building image and its canonical TypeContext. Nominal shells precede dependency resolution. Explicit native sizes are finalized privately before checked property extents are installed; a separate dependency graph rejects by-value cycles that fixed native sizes alone would hide. Failures publish no draft and retain the responsible declaration/provider for tested errors. Metadata type/global name maps now use case-sensitive key equality and hashing. Template recipes remain the separately scheduled task 5.2.

## Exact case mapping

| Case | Task / reason | Result |
|---|---|---|
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.CallerVariantsAndPropertyExposureSurviveRecording` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.FunctionTraitsAndCompilePoliciesAreDetached` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.HandlesSurviveGrowthAndRejectSealedEdits` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespaceAndCaseSensitiveTypesDoNotCollide` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespacesEnumsAndConstantsAreRecorded` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NativeRecipesOwnTheirInputsAndPreserveOrder` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ReferenceAndTemplateDeclarationsRetainUEFacts` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ValueLifecycleAndMembersNeedNoEngine` | 1.3 — refreshed facade proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.DuplicateIdentityNamesBothSourcesBeforeExecution` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.EmptySealedCollectionProducesAnEmptySealedStore` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.LateProviderInvalidatesCaptureWithProvenance` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.OutOfOrderProvidersPreservePhaseOrderAndContributions` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.RecordingFailureReportsSourceAndPublishesNothing` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.ReusingSnapshotNeverReexecutesProviders` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.TargetConditionsAndEffectivePolicyAreCaptured` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.UnsealedCollectionCannotPublishASnapshot` | 1.4 — refreshed provider proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.CompatibleDeclarationsCoalesce` | 1.2 — refreshed Store proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.ConflictingNativeDefinitionReportsBothSources` | 1.2 — refreshed Store proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.EmptyStoreSeals` | 1.2 — refreshed Store proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RecordHandlesSurviveGrowthAndRejectForeignStores` | 1.2 — refreshed Store proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RepeatedSealPreservesIdentity` | 1.2 — refreshed Store proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.SealedMutationRejected` | 1.2 — refreshed Store proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.StoreOwnsInputLifetime` | 1.2 — refreshed Store proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ConstReferenceMethodAndDefaultAreDetached` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.DefaultExpressionsKeepNestedCommasAndOriginalText` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.EquivalentSpellingSharesIdentityAndRefChangesOverload` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ExplicitVoidAndReferenceDirections` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.InvalidDeclarationsReportOwnedSourceRanges` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.NestedTemplatesAndObjectHandlesResolve` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.PropertyAndStandaloneTypeUseCanonicalTypes` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ReturnTypeConflictCannotPublishCallable` | 2.2 — refreshed consumer proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.BaseCycleReportsItsDeclarationsAndPublishesNothing` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.ByValueCycleIsRejectedEvenWithExplicitNativeSizes` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.CaseSensitiveNominalsKeepIndependentNativeLayouts` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.DerivedBeforeBaseAndForwardValuePropertyKeepNativeLayout` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.EnumAliasAndInterfaceFactsRoundTrip` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.InvalidAlignmentAndOutOfBoundsOffsetFailWithSource` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MissingNominalReportsTheMemberProviderAndDeclaration` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MutualObjectHandleReferencesDoNotFormALayoutCycle` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.UnsealedStoreCannotStartADraft` | 2.3 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ActualTypesAndMethodsNeedNoEngineOrNumericIds` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.AdmittedFloatAliasesAndTargetReferencesMatchLayoutQueries` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.AliasCycleIsRejectedWithoutRecursingForever` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ByValueRecursionFailsWithoutPartialLayouts` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ConcurrentExternalReferencesKeepTheFrozenGraphAlive` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ConcurrentFactoriesSerializeOwnershipWithoutAnEngine` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.DefaultArrayAndChildFuncdefRetainSemanticEdges` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.DuplicateIdentityAndNameFailuresDoNotPublishObjects` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.EnumAliasAndFuncdefAreActualOwnedTypes` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FactoryAndBehaviourQueriesUseObjectsBeforeRegistration` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FreezeRequiresCompleteSignaturesAndFinalizedLayouts` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FrozenDependencyLifetimeAndForeignEdgesAreExplicit` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FrozenImageRejectsNewObjectsAndSemanticEdges` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ImmutableOptionsDoNotFollowCallerOrOtherImageChanges` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ImportedLayoutAndTargetCompatibilityAreExplicit` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.InheritanceAndInterfacesRemainLocalDefinitionRelations` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.InheritanceCycleIsRejectedBeforeDraftQueries` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.InvalidNativeLayoutDoesNotBecomeAValidFrozenType` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.LayoutUsesTargetPointerSizeAndAlignment` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.MethodLeaseRetainsOwnerSignatureAndNamespace` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.RejectedSignatureDoesNotPublishOwnerOrParameters` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.SignatureQueriesRetainTypesNamesFlagsAndDefaults` | 2.3 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.TypeLeaseRetainsRecursiveMembersUntilFinalRelease` | 2.3 — shared metadata regression | Success |

## Source and binary identity

SHA-256 values below identify the tested snapshots. RED header identity for as_metadata_image.h was not separately captured; no RED hash is claimed for it.

| Path | RED SHA-256 | GREEN SHA-256 |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h` | 72205E1D8B1AC2227F3E6588935504BF8FAE70F667BE37141A3BBBA71F0DADFC | 72205E1D8B1AC2227F3E6588935504BF8FAE70F667BE37141A3BBBA71F0DADFC |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.cpp` | F5C41B98767C12A92C5D785DF7D808CEF3A2BB7F61D91333A0AAEDE3C71FC567 | 23A6CE4CDDFC3EF64FBA0A74266C08ECBAAC4BDA0DB6D1F80E4F2211BEDC9798 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDraft.h` | B00E1E82C67CD4F0ECAE26A88C12B0608A8E10F83B72C6627F9D10B994AEC70F | 63FAADC48B6CCBEE89428F5D71B404AB76D0743E928F6E8778C88731A5F6D2C6 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDraft.cpp` | CEB593AA23C4EDD63F02BD0E9D8CA270FFB68134C529CAFC8FBF612F1E82D314 | DD22F7B66CEF6A624F80B320B89EE60FDDB679D657B886A8FC511721D7ADEAB0 |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingLayoutsTests.cpp` | 8C5E6CA555C75A6277D51DBD6323A92130C604368E6559A196568F1FA0FE7A2B | 8C5E6CA555C75A6277D51DBD6323A92130C604368E6559A196568F1FA0FE7A2B |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp` | 34721DF8B4B01C11CE693E2270AF298708008182BC068C4E0B2A1EAA8186DCDF | 6B1323637F653D05F7284FBFBB634D8CE67D3F8CB3FA2938532530249F3EF602 |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | AD079734096753D2DA8F63FD1AB12D8F1AB4A60F254C2A38C878239968EBFA8F | FC762A4E50AECC51A3DCDD4B959ADBCB7113DCB0476DB7F9E1B8ED0A34C600B1 |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | 7AEDC3CEE2D5ECA335B1892CD4389B5032725175B735BA4212468E1EF9723B2A | 2027EFC3D98352E64D544CC9D46C15D45F0621DF7447FED3567A0B4732D1EB82 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.h` | Not captured | 91264E0B5FC570A7E3DADC9B0F796C2059499D51739BFA2EEC9F5D7FE7C3A60C |

## Report identity

| Report under Saved/Harness/Unreal/Runs | SHA-256 |
|---|---|
| `3993f6d01b9f483b8c5286fa93ce84fe/AutomationReport/index.json` | 3EDD62A3CC353B59B21C68168108304ECC7EC4299D66BB7ACD71D0E45A2D6D96 |
| `10fcf5cb83fe4279b3a1d641392647cb/AutomationReport/index.json` | 7CEC9864915A1798FBCA3F2022A84BAF62942962281A7FA54BF67648FA798B72 |
| `3070586db48e44d1adec0a39451e6660/AutomationReport/index.json` | 26EA217B8EFC30B25EC454D3AC6311FAE2D04B7526B391DF77125A9FC7C19757 |

Full NativeEngine is reserved for task 8.4's shared-contract completion gate. Dormant startup is unchanged and its full baseline is task 8.3. Harness Quick/Performance/Integration were omitted because this task changes no Harness behavior or performance contract.

