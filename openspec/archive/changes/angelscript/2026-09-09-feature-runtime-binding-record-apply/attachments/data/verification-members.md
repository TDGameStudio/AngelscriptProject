# Complete member metadata installation verification

Task: 2.4. Parent base a9afd56e73b9289ed32dee8210d7b96ac0b3b578; plugin base edc13e98d7a63fa22b76620302d1294fe6126641.

## Commands and observed outcomes

All builds used `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`. All operations reached terminal managed status with source writers frozen.

- Initial setup f5e1044dbc4d4e1aac57a8257f0b9448 succeeded. Initial RED dd73cb9fb4e841fdb286789d28838c0f executed nine cases: nine expected failures, exit 255. Seven cases failed at missing successful Install; two negative cases failed at missing diagnostic provenance. Later assertions behind failed prerequisites are not claimed as independently observed RED.
- Source inspection established that function definition modifiers must enter the canonical descriptor before interning. The indexed applied replan replan-20260908-092053-binding-definition-modifiers adds only the required parser consumer ownership to this task. Its evidence is source inspection, not a claim that the initial RED reached frozen modifier validation.
- Initial implementation build 325ad228ee8c464992e39f4a1bdc0c8f succeeded. Shared run f00b2fee0218418296be3bbb60651e16 passed 49 cases with zero errors/warnings, exit 0. Later completeness additions mean this is an intermediate result, not the final proof.
- Pure-constant facts were missing from native global metadata. Expanded setup e2de2eaf37af435a910e4798748726f5 succeeded. RED 66304fa1445f4fe49c94a268c9763611 executed ten cases: eight passing controls and two failures, exit 255. The valid const-int fixture lacked its pure-constant flag/value; the invalid mutable fixture was incorrectly accepted. The object-storage branch followed that failing prerequisite and is not independently claimed as RED.
- Global facts implementation build 974859fe73d9425fbd8a89eec0c19751 succeeded. Captured-policy completeness inspection then added shipping, simulated-cooked and force-const inputs plus a four-condition fixture before changing policy conversion.
- Policy setup 28fedfd945a3470b8ba92bd490e905b8 succeeded. RED 3ff9223559714ecea661c43b6de37405 executed eleven cases: ten passing controls and one failure, exit 255. The policy fixture first demonstrated missing force-const facts; later policy assertions were not independently observed RED. Existing binding source also establishes the distinction between Test and Shipping/cooked for Check and Ensure.
- Final implementation build 76e585302b54490ab29edd60349b9e22 succeeded, exit 0.
- Every RED used `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Types.Members.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Final shared GREEN c2a1c66f24404066ae20bbf5f29bdcfd used `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`: 51 successes, zero errors/warnings, exit 0.
- Adjacent 2de108f2dc7343dc881efac3ca73b042 used `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.MetadataImage.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`: 23 successes, zero errors/warnings, exit 0.
- Adjacent c0529ccdad2c4769ac06585017e6a3c8 used `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.GlobalDefinitions.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`: seven successes, zero errors/warnings, exit 0.
- All eleven final source/binary hashes below were checked unchanged after the final adjacent run.

## Result and boundary

Each Install owns a fresh draft/image and its record-to-member correspondence. It completes method/global signatures, defaults, directions, identity modifiers, lifecycle behaviours, checked native property access facts and global declarations. It finalizes and freezes the complete image, authenticates canonical definitions, then registers into the supplied local native Engine. Failure before publication returns no installation. Two Engines retain separate image/type/function objects with equivalent stable identities.

New native fact APIs enforce Building state and ownership. Pure constants require a const primitive or enum; the value lives in image-owned metadata, with executable storage still unbound. The existing non-native CreateGlobalProperty entry retains its const-only contract, proven by GlobalDefinitions. Captured policy distinguishes Test, Shipping, simulated cooked and logging conditions; Check/Ensure retain their existing Test behavior. Configuration-dependent force-const facts are captured explicitly.

The binding declaration parser's new definition-modifier input defaults to None, preserving its existing consumers. RuntimeBindings.Declarations refreshes the eight entry-point cases; the shared script type grammar itself was not changed here. Native targets, hidden first-parameter transport and global storage connection remain task 2.5. Provider-family completion and full Runtime Engine creation remain their separate tasks.

## Exact final case mapping

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
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ConstReferenceMethodAndDefaultAreDetached` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.DefaultExpressionsKeepNestedCommasAndOriginalText` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.EquivalentSpellingSharesIdentityAndRefChangesOverload` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ExplicitVoidAndReferenceDirections` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.InvalidDeclarationsReportOwnedSourceRanges` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.NestedTemplatesAndObjectHandlesResolve` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.PropertyAndStandaloneTypeUseCanonicalTypes` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Declarations.ReturnTypeConflictCannotPublishCallable` | 2.2 — refreshed parser proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.BaseCycleReportsItsDeclarationsAndPublishesNothing` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.ByValueCycleIsRejectedEvenWithExplicitNativeSizes` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.CaseSensitiveNominalsKeepIndependentNativeLayouts` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.DerivedBeforeBaseAndForwardValuePropertyKeepNativeLayout` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.EnumAliasAndInterfaceFactsRoundTrip` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.InvalidAlignmentAndOutOfBoundsOffsetFailWithSource` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MissingNominalReportsTheMemberProviderAndDeclaration` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.MutualObjectHandleReferencesDoNotFormALayoutCycle` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Layouts.UnsealedStoreCannotStartADraft` | 2.3 — refreshed layout proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.CompilePoliciesUseCapturedBuildFacts` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.ConstAndMutableGlobalDeclarationsHaveMetadataWithoutStorage` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.ConstructorsAndDestructorKeepDistinctBehaviourIdentities` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.DefaultsDirectionsAndNativeFunctionTraitsSurviveFreeze` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.FrozenInstallationRejectsLaterMemberMutation` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.IncompatibleDuplicateSignatureFailsBeforeRegistration` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.MethodAndGlobalOverloadsAreVisibleAfterWholeImageInstall` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.MissingParameterTypePublishesNoImageAndReportsMemberSource` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.PropertyAccessAndOffsetsAreCompleteBeforePublication` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.PureConstantRejectsMutableAndObjectStorageBeforePublication` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.RuntimeBindings.Types.Members.SecondEngineOwnsDistinctImageWithEqualStableIdentities` | 2.4 — final member proof | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ActualTypesAndMethodsNeedNoEngineOrNumericIds` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.AdmittedFloatAliasesAndTargetReferencesMatchLayoutQueries` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.AliasCycleIsRejectedWithoutRecursingForever` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ByValueRecursionFailsWithoutPartialLayouts` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ConcurrentExternalReferencesKeepTheFrozenGraphAlive` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ConcurrentFactoriesSerializeOwnershipWithoutAnEngine` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.DefaultArrayAndChildFuncdefRetainSemanticEdges` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.DuplicateIdentityAndNameFailuresDoNotPublishObjects` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.EnumAliasAndFuncdefAreActualOwnedTypes` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FactoryAndBehaviourQueriesUseObjectsBeforeRegistration` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FreezeRequiresCompleteSignaturesAndFinalizedLayouts` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FrozenDependencyLifetimeAndForeignEdgesAreExplicit` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.FrozenImageRejectsNewObjectsAndSemanticEdges` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ImmutableOptionsDoNotFollowCallerOrOtherImageChanges` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.ImportedLayoutAndTargetCompatibilityAreExplicit` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.InheritanceAndInterfacesRemainLocalDefinitionRelations` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.InheritanceCycleIsRejectedBeforeDraftQueries` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.InvalidNativeLayoutDoesNotBecomeAValidFrozenType` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.LayoutUsesTargetPointerSizeAndAlignment` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.MethodLeaseRetainsOwnerSignatureAndNamespace` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.RejectedSignatureDoesNotPublishOwnerOrParameters` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.SignatureQueriesRetainTypesNamesFlagsAndDefaults` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.MetadataImage.TypeLeaseRetainsRecursiveMembersUntilFinalRelease` | 2.4 — shared metadata regression | Success |
| `Angelscript.UnitTest.NativeEngine.GlobalDefinitions.DetachedGlobalMetadataDoesNotAllocateExecutableStorage` | 2.4 — original global-definition contract | Success |
| `Angelscript.UnitTest.NativeEngine.GlobalDefinitions.DuplicateGlobalRegistrationDoesNotPublishNewImage` | 2.4 — original global-definition contract | Success |
| `Angelscript.UnitTest.NativeEngine.GlobalDefinitions.FrozenGlobalMutationIsRejectedByRegistration` | 2.4 — original global-definition contract | Success |
| `Angelscript.UnitTest.NativeEngine.GlobalDefinitions.GlobalExternalReferencesAreConcurrentWithoutGraphCycles` | 2.4 — original global-definition contract | Success |
| `Angelscript.UnitTest.NativeEngine.GlobalDefinitions.GlobalOnlyLeaseRetainsImageAfterProducerAndEngineDestruction` | 2.4 — original global-definition contract | Success |
| `Angelscript.UnitTest.NativeEngine.GlobalDefinitions.MutableGlobalAndVoidTypeAreRejectedWithoutPublication` | 2.4 — original global-definition contract | Success |
| `Angelscript.UnitTest.NativeEngine.GlobalDefinitions.WrongKeyRoleNameNamespaceAndTypeAreRejected` | 2.4 — original global-definition contract | Success |

## Source and binary identity

SHA-256. The initial RED did not separately recapture TypeBindInfo.h; its unchanged pre-policy identity is retained in task 2.3's layout evidence. No initial RED hash is invented here.

| Path | Initial RED | Constant RED | Policy RED | Final GREEN |
|---|---|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h` | 63A0AF7E832C20BC8A4DE57C1B2ED7824460F4DFC98E2C1AEF2BB74417022F8D | 63A0AF7E832C20BC8A4DE57C1B2ED7824460F4DFC98E2C1AEF2BB74417022F8D | 63A0AF7E832C20BC8A4DE57C1B2ED7824460F4DFC98E2C1AEF2BB74417022F8D | 63A0AF7E832C20BC8A4DE57C1B2ED7824460F4DFC98E2C1AEF2BB74417022F8D |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp` | 1606D2D3677AD076AE4E9773A1A83BA7DE97F22B08DA39A849E23DD1CC55A0D5 | BFBDB8BE2C932CA3C55C56E0F165FC98C2F83DBA7CD235C8AD135D28FC07E21E | B66840BCE3F5B3483CD660E43B0F71239FE204A29BC13180F4FD4F2875A53339 | 321C4AD4BDD2044813A2DC48BAFE9877C0CB2DA5F93A3B7B45CB3E6E558F0332 |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMembersTests.cpp` | EF5AC4496119CB7A3F3F3CF0EEC9E09F4B19E0C6BA8AB9EA397BD753F7805E82 | F07BF20414672FDD5C5728BC99DB77FF15AE4D7C3617EC549D5184F7904FCB43 | BFCAEC2BDB09C83DACC3B4F14670DDAA948F12EF60DC2716573988E0B8879D95 | BFCAEC2BDB09C83DACC3B4F14670DDAA948F12EF60DC2716573988E0B8879D95 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.h` | 6082F1956799E2CCC2D0FC824AD76996FC2ABFE1CA82BB1737809A93E214358D | 7F0C6A2E3CB3BE624C998E15BEE82DB1D69F136C436C56C3337C5A565965D2CA | 7F0C6A2E3CB3BE624C998E15BEE82DB1D69F136C436C56C3337C5A565965D2CA | 7F0C6A2E3CB3BE624C998E15BEE82DB1D69F136C436C56C3337C5A565965D2CA |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.cpp` | 109EAECF19586820762A6E272FD34A00C52BFA2E4CF10A6E57CBC213E8D10043 | 3E91D6FA353A1EFBDA0BE0E3D362A5326D56C097FF697A2FC61007E0201EE3F2 | 3E91D6FA353A1EFBDA0BE0E3D362A5326D56C097FF697A2FC61007E0201EE3F2 | 3E91D6FA353A1EFBDA0BE0E3D362A5326D56C097FF697A2FC61007E0201EE3F2 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.h` | 91264E0B5FC570A7E3DADC9B0F796C2059499D51739BFA2EEC9F5D7FE7C3A60C | E0632F1CD2A1333FD006742EECC12092126C7C67C3121D518BF4808C8DCC5897 | 205ACF671BC54D625EEC8D0C3331BE70A884C9F829F6423D801FE06FA49CD439 | 205ACF671BC54D625EEC8D0C3331BE70A884C9F829F6423D801FE06FA49CD439 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp` | 6B1323637F653D05F7284FBFBB634D8CE67D3F8CB3FA2938532530249F3EF602 | EEEE06EAC316FF6EB367CEDDB1B0D37C7557ECC89E5823FD81267050D4B3F861 | AC0F0F21957906A1D7054870CD4812BEB585549F7881758162266B9903C327FA | AC0F0F21957906A1D7054870CD4812BEB585549F7881758162266B9903C327FA |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_property.h` | C4038740C812C3C2FBCEE84D340EFB2DD7ECACF9E3D4E83802B92A37EA245FF5 | E2115E187EFDF6B72AC4EA262612CDB5F94119EB6BF1EC287D6761135E8E14ED | E2115E187EFDF6B72AC4EA262612CDB5F94119EB6BF1EC287D6761135E8E14ED | E2115E187EFDF6B72AC4EA262612CDB5F94119EB6BF1EC287D6761135E8E14ED |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | F2CB4F2FB5CD927DB7DFF697B26765374A6AE438E9CA7ECB333A5F2395B3DF3A | 460F5DEB8CC70272DD5A9190A611AE55311A4CB6D88BDAAF1BA9B3A7A1054AA5 | 9CDD1E3573D644BFC2238C85B4CF123FEF93FD214B4B1EB462C6AAC56FCDB2A0 | B2D6AC3B15DA441910CD6115E7BD58BEEA392D8B4F186BB2371DA027385A38D7 |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | 5845FD12933E3E10CE5824DE0D982C7049E18BBCCF845E564F70E05A8F77D242 | 844510354A524813664D4F126AA4F4D22D598F426A30819EBB392E537F335EE3 | A938858A7BA27B4093D4331FCF73DCC181F970BAED93E4A963A9666C2A9A7535 | A938858A7BA27B4093D4331FCF73DCC181F970BAED93E4A963A9666C2A9A7535 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h` | Not recaptured | Not recaptured | F4FBBE5ED92EFD22C29AB99370C6BFC106599CE6E395BFBA21F49598A10FEF88 | F4FBBE5ED92EFD22C29AB99370C6BFC106599CE6E395BFBA21F49598A10FEF88 |

## Report identity

| Report under Saved/Harness/Unreal/Runs | SHA-256 |
|---|---|
| `dd73cb9fb4e841fdb286789d28838c0f/AutomationReport/index.json` | B0255DF9CAD14661FB75A5B61DB6F28F92BA4AF7CCFF66AB72CF8134104D351A |
| `66304fa1445f4fe49c94a268c9763611/AutomationReport/index.json` | 7E2888FDE5781332267D27AAFE8E2BEEB9330B6AB55D454A314AAADA7023ACA8 |
| `3ff9223559714ecea661c43b6de37405/AutomationReport/index.json` | B708A4F10843C47E6A3314D423F0C5607E95882B50DA175C092863509F11F2B3 |
| `c2a1c66f24404066ae20bbf5f29bdcfd/AutomationReport/index.json` | 3B6619F5F4A4BBD675ADAB08F4D01DA18AD4835F48E97690E83505DE7F5AD511 |
| `2de108f2dc7343dc881efac3ca73b042/AutomationReport/index.json` | 9D8D28F5B89C442A3B00C448C85C954C46D6F064FE96D33E747AE5B847C90217 |
| `c0529ccdad2c4769ac06585017e6a3c8/AutomationReport/index.json` | 0A127B4774B4C193E87241C566212CAED3CFF38C3D49F1E8D8F66F94EE2277A4 |

Full NativeEngine remains task 8.4's completion gate. Baseline remains task 8.3 because default startup was not changed. Harness Quick/Performance/Integration were omitted because no Harness behavior or performance contract changed.

