# Host declaration parsing verification

Task: 2.2. Parent base a9afd56e73b9289ed32dee8210d7b96ac0b3b578; plugin base edc13e98d7a63fa22b76620302d1294fe6126641.

## Commands and outcomes

- Build command: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`.
- Initial setup build c94abace54384103aca3ee43bd2fd2b9 failed because a test assertion macro cannot return from a non-void helper. This was a setup failure, not RED. Corrected setup build 32061cf0437f4eb09416fb4f9f4aa11c succeeded.
- RED test 082d2c1e72b5481da6ea91e2a549e1e0 executed all eight cases; eight expected failures, exit 255. The parser skeleton returned false and no diagnostic. Seven scenarios exposed missing successful parsing; the invalid-declarations scenario exposed missing diagnostic output. Negative assertions behind a failed prerequisite are not separately claimed as observed RED.
- Implementation build 97db991f4fec4c3b98b03bce4b71f0e6 failed on a token enum spelling; corrected build ffe0dbb663fe4b6d813e3b4d3dd140f1 succeeded.
- RED/GREEN command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Types.Declarations.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- GREEN bdc91282837444e79d6b6530d7e102f8: eight successes, zero errors/warnings, exit 0.
- Adjacent command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Declarations'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Adjacent regression 071f71c218a54482a1534bf38186f17d: 67 successes, zero errors/warnings, exit 0. Existing script declarations use the extracted type grammar, including qualification and compound closing angle handling.
- All asynchronous runs were observed through terminal ue.run.status. No source writes occurred during build or test execution.

The parser owns its UTF-8 source snapshot, produces source-ranged diagnostics, resolves nominal keys through an explicit caller lookup and authenticates them in TypeContext. Callable identity includes canonical parameter types/directions and const method identity; defaults and parameter names remain separate authored facts. Failure retains only source context in the output and does not publish partial callable/type results. No Engine or script body is required. Default expression text is retained, not evaluated by this task.

## Exact case mapping

| Case | Task / reason | Result |
|---|---|---|
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ConstReferenceMethodAndDefaultAreDetached` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.DefaultExpressionsKeepNestedCommasAndOriginalText` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.EquivalentSpellingSharesIdentityAndRefChangesOverload` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ExplicitVoidAndReferenceDirections` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.InvalidDeclarationsReportOwnedSourceRanges` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.NestedTemplatesAndObjectHandlesResolve` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.PropertyAndStandaloneTypeUseCanonicalTypes` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ReturnTypeConflictCannotPublishCallable` | 2.2 — observed RED then GREEN | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsAccess.ConversionDeclarationsRejectParametersAndVoidDestinations` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsAccess.ForwardPolicyUseResolvesAfterTheDeclarationBarrier` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsAccess.MalformedPolicyRecoversTheFollowingOrdinaryDeclaration` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsAccess.MissingDuplicateAndForeignPoliciesCannotBecomeResolvedDefinitions` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsAccess.PolicyDeclarationAndUseAreNotGlobalLanguageConstructs` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsAccess.PolicyKeepsOrderedSubjectsAndExactAuthoredModifierRanges` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsCollection.AllSourcesCollectBeforeTheBarrier` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsCollection.CollectionBarrierIsOneWay` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsCollection.FunctionBodiesRemainDeferredRanges` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsCollection.ParserBoundaryUsesOnlySema` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsCollection.ParserCreatesConcreteDeclarationsThroughSema` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsCollection.TypedAnnotationsArePreservedWithoutReflectionExecution` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsExpandedLanguage.EnumArithmeticReferencesAndImplicitSequenceUseTypedExpressions` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsExpandedLanguage.EnumInitializersRemainDeferredUntilResolution` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsExpandedLanguage.EnumOverflowAndInvalidExpressionPreventResolution` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsExpandedLanguage.MaintainedMethodSuffixesRemainTypedDefinitionFacts` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsExpandedLanguage.RemovedPropertySyntaxDoesNotPublishFunctionsOrEatLaterDeclarations` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsExpandedLanguage.ScopedEnumReferenceRetainsNominalTypeBeforeIntegralConversion` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.AllSixAnnotationKindsAttachToTheirDeclaredTargets` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.AnnotationTargetValidationDistinguishesClassStructEnumAndCallable` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CallableAndRecordShareOneNominalNameDomain` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CallableDeclarationsCanReferenceLaterCallableTypes` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CallableForwardTypesResolveToQualifiedSignatureWithoutEngine` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CallableGlobalQualificationBypassesInnerShadow` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CallableLookupDoesNotLeakAnUnrelatedNamespaceType` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CallableTraversalIncludesParametersWithoutGeneratedChildren` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CallableTypeSyntaxRetainsQualificationModifiersAndExactLocations` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.CollectedHostOutputPrecedesResolvedSignaturesAndOwnsSyntax` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.DelegateAndEventAreCallableTypesNotFunctionsOrGeneratedRecords` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.FailedCollectedHostOutputIsEmpty` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.InvalidCallableParametersNeverPublishAPartialSignature` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.MalformedAnnotationPayloadAndDanglingAnnotationAreErrors` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.MalformedCallableRecoversAfterTrailingCommaAndIllegalBody` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.NestedAnnotationPayloadRemainsATreeWithAuthoredRanges` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.RemovedAssetConsumesNestedInitializerWithoutCreatingSemanticEntities` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.RemovedImportDiagnosesItsAuthoredRangeAndRecovers` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.RemovedSpellingsRemainLegalAsOrdinaryIdentifiers` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.RemovedSyntaxInsideTriviaStringsAndInactiveBranchesIsNotDiagnosed` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.ReopenedNamespaceRetainsDistinctOccurrencesAndSharedMemberScope` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.UDelegateIsNotAnAnnotationAlias` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsLanguageForms.UnnamedCallableParametersPreserveOrderedTypes` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsMaintainedSyntax.CallableDefaultOwnsAnAnalyzedExpression` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsMaintainedSyntax.ConstructorDestructorAndMethodModifiersRemainDistinctTypedFacts` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsMaintainedSyntax.DefaultInitializerRangeExcludesDelimitersAndKeepsNestedCommas` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsMaintainedSyntax.NestedGenericClosersAndArrayDimensionsRetainTypedSourceTrees` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsMaintainedSyntax.PrimitiveAliasRetainsAuthoredTargetAndCanonicalAliasedType` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsMaintainedSyntax.RequiredParameterAfterDefaultIsRejectedAndLaterDeclarationSurvives` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsMaintainedSyntax.VoidParameterSpellingMeansAnEmptySignature` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsResolution.DuplicatePrimaryIsChosenByStableSourceOrder` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsResolution.LaterFileTypesResolveAfterTheBarrier` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsResolution.MalformedDeclarationRecoversToLaterValidDeclaration` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsResolution.OverloadSetsUseStableSignatureOrder` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsResolution.ReversedSourceInputProducesTheSameStableProjection` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsResolution.WorkerCountDoesNotChangeResolution` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.CallableNominalAndSignatureHaveDistinctRegistryRoles` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.ConstAndHandleQualifiersRemainCanonicalTypeEdges` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.ConstMethodQualificationChangesFunctionNotSignatureType` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.EquivalentNamesAndSourceMovesReuseFunctionIdentity` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.FloatAliasUsesContextOptionsWhileSizedSpellingsStayFixed` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.HostDeclarationCoordinatesSurviveSourceMoves` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.NestedNominalOwnersDistinguishSameMethodNames` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.OrdinaryDeclarationsRetainStructuredQualifiedTypeLocations` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.ParameterNamesAndBuiltinAliasesDoNotInventOverloads` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.PassingModesCreateDistinctOverloadsAndCallableTypeUses` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.RegistryCollisionPreventsFrontendPublication` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.ReturnTypeOnlyOverloadIsRejected` | 2.2 — existing shared grammar consumer | Success |
| `Angelscript.UnitTest.NativeEngine.DeclarationsStableIdentity.SharedTypeContextRetainsIdentityAfterSessionDestruction` | 2.2 — existing shared grammar consumer | Success |

## Source and binary identity

| Path | RED SHA-256 | GREEN SHA-256 |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.h` | `6082f1956799e2ccc2d0fc824ad76996fc2abfe1ca82bb1737809a93e214358d` | `6082f1956799e2ccc2d0fc824ad76996fc2abfe1ca82bb1737809a93e214358d` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.cpp` | `d7ffb52605d7af3ea8aade30d80b2000fa10c54fd3b9f8a343e0970952cfae82` | `109eaecf19586820762a6e272fd34a00c52bfa2e4cf10a6e57cbc213e8d10043` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_syntax_parser.h` | Existing frontend or extracted after RED | `b3feeac68e900b99e32369f64201e876f0ddf5dfe6c545a067539aa41b6dd3c2` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_syntax_parser.cpp` | Existing frontend or extracted after RED | `1a82cb4d400ec37d5fa565f2678f36464963d926431d8d8aef570d61688b5f37` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp` | Existing frontend or extracted after RED | `a8716c4ee0d5f2b0a2035a57f3831846af96d5f3b9f0d8cedf093f265a5739b4` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDeclarationsTests.cpp` | `cfb5a60635e8cf847b1dc7f54d2d459ecb9fb76444b7246f4b02ab23d137658e` | `cfb5a60635e8cf847b1dc7f54d2d459ecb9fb76444b7246f4b02ab23d137658e` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | `d53a1013d02b6dfd9686b716b28ac2a062524eb19f14a8c3dae4574e50bbbea1` | `8808276ece359b624d1bdff2321da1d648d03cc37791bc5a2b1b70047e01884b` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | `5b997113fc63090649a3880fecc5c8399d4561bc8b15c2083b71f1fb4df8e73d` | `5b997113fc63090649a3880fecc5c8399d4561bc8b15c2083b71f1fb4df8e73d` |

## Reports and scope

- `Saved/Harness/Unreal/Runs/082d2c1e72b5481da6ea91e2a549e1e0/AutomationReport/index.json`; SHA-256 `de1773b9ce106ee3068b43f297121a7ce3c40d78d54637beed6d13849a5b90a0`.
- `Saved/Harness/Unreal/Runs/bdc91282837444e79d6b6530d7e102f8/AutomationReport/index.json`; SHA-256 `3e0f60a72618171bd10ce90b39bf0da117f85c4de52394ab591ee8ae30e06a6a`.
- `Saved/Harness/Unreal/Runs/071f71c218a54482a1534bf38186f17d/AutomationReport/index.json`; SHA-256 `8657415895d06596b98fc00d05e48144adaf7894e617a12d1f616800ad52072c`.

Full NativeEngine, dormant startup, packaging, legacy suites and Performance are omitted for this task: the change is confined to detached declaration parsing and shared frontend type grammar. The focused existing declaration suite covers the changed consumer; final full NativeEngine verification remains task 8.4. Recording code is unchanged by 2.2.
