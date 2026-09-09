# Provider snapshot verification

Task: 1.4. The final shared run refreshes tasks 1.2 and 1.3 on the same Store/facade source and binary identity. Parent base a9afd56e73b9289ed32dee8210d7b96ac0b3b578; plugin base edc13e98d7a63fa22b76620302d1294fe6126641.

## Commands and outcomes

- Builds: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`.
- RED setup build `1ca3abbaaeb840e499c66be2eaa3a61b`: succeeded, exit 0.
- RED test `bc7faa2e51064a9badb211de4046269a`: seven failures and one passing pre-existing duplicate-collection control; all eight cases executed, exit 255.
- RED command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Providers.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Implementation build `a282b60c54a7403eba971fcd3803032a` and final build `62841cfae6d9494ab0e39278ee1a4088`: both succeeded. The latter includes collection-failure detection immediately after a condition callback as well as after provider execution.
- GREEN shared test `a7c5ce70abe6492187a1a18b1f01f200`: 23 successes, zero case errors/warnings and no unexecuted/in-process cases, exit 0.
- Shared command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- All asynchronous launches were followed through terminal `ue.run.status`.

RED Capture returned false without callbacks or diagnostics. Successful-capture cases failed at that missing entry behavior; failure-path scenarios separately exposed missing callback execution or provenance diagnostics. Duplicate identity rejection was already implemented in collection Finalize and is a labeled control. GREEN proves full assertions, including ordered callback execution, both type contributions, phase/source propagation, eligible versus excluded provider accounting, copied target policy, independent snapshot lifetime and no replay through shared consumers, and rejection of unsealed/late/failed capture. No partial Store is published.

## Case mapping

| Exact scenario | Task | RED classification | Final shared result |
|---|---|---|---|
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.CallerVariantsAndPropertyExposureSurviveRecording` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.FunctionTraitsAndCompilePoliciesAreDetached` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.HandlesSurviveGrowthAndRejectSealedEdits` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespaceAndCaseSensitiveTypesDoNotCollide` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespacesEnumsAndConstantsAreRecorded` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NativeRecipesOwnTheirInputsAndPreserveOrder` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ReferenceAndTemplateDeclarationsRetainUEFacts` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ValueLifecycleAndMembersNeedNoEngine` | 1.3 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.DuplicateIdentityNamesBothSourcesBeforeExecution` | 1.4 | Existing passing control | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.EmptySealedCollectionProducesAnEmptySealedStore` | 1.4 | Observed failure | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.LateProviderInvalidatesCaptureWithProvenance` | 1.4 | Observed failure | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.OutOfOrderProvidersPreservePhaseOrderAndContributions` | 1.4 | Observed failure | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.RecordingFailureReportsSourceAndPublishesNothing` | 1.4 | Observed failure | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.ReusingSnapshotNeverReexecutesProviders` | 1.4 | Observed failure | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.TargetConditionsAndEffectivePolicyAreCaptured` | 1.4 | Observed failure | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Providers.UnsealedCollectionCannotPublishASnapshot` | 1.4 | Observed failure | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.CompatibleDeclarationsCoalesce` | 1.2 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.ConflictingNativeDefinitionReportsBothSources` | 1.2 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.EmptyStoreSeals` | 1.2 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RecordHandlesSurviveGrowthAndRejectForeignStores` | 1.2 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RepeatedSealPreservesIdentity` | 1.2 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.SealedMutationRejected` | 1.2 adjacent | Earlier proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.StoreOwnsInputLifetime` | 1.2 adjacent | Earlier proof; regression control here | Success |

## Content identities

| File | RED SHA-256 | Final GREEN SHA-256 |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` | `32a504ab51eaaa39f245ad85e6b10f1c5f88ee107e051726fd4402e7705f72eb` | `32a504ab51eaaa39f245ad85e6b10f1c5f88ee107e051726fd4402e7705f72eb` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp` | `b201fc60579247d34a912330397da91ceac10e95474a2fcc7881c330f4491e23` | `b201fc60579247d34a912330397da91ceac10e95474a2fcc7881c330f4491e23` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h` | `a3d1db47a010619862ce8501763f6eb0372b13025dbb6c9f8f067f5fb3a65122` | `a3d1db47a010619862ce8501763f6eb0372b13025dbb6c9f8f067f5fb3a65122` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.h` | `ebd196a2dac9183cd5d1214a7193c89d90384d1ac2fae1023a5a108d0b7f660d` | `ebd196a2dac9183cd5d1214a7193c89d90384d1ac2fae1023a5a108d0b7f660d` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.cpp` | `3ef7de90f85c00832d31ca5e71900d05d3611313a03144c73e6657044c8e39fd` | `f5c41b98767c12a92c5d785df7d808cef3a2bb7f61d91333a0aaede3c71fc567` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingFacadeTests.cpp` | `0bc3e832b3314f546c13dfb65c9f3b6192946222ddba5223545f9d66d71777c1` | `0bc3e832b3314f546c13dfb65c9f3b6192946222ddba5223545f9d66d71777c1` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingStoreTests.cpp` | `50d1877da6e1a4dc91a6685535228d799ea1d953b9106638136542e401799346` | `50d1877da6e1a4dc91a6685535228d799ea1d953b9106638136542e401799346` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | `d3d9b26a347ceb0d13a1eaa911ce94017ad1fabea1511ed6730dc2d0338df545` | `5d3718bd257ad9651373f0fa3bb3560399e81ccc090147df62039f59044fdcd5` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | `410f5ab0c7d67df5b7c12a433fcb81b3fb7014aae1938dfaeeb919c11bce6b8b` | `410f5ab0c7d67df5b7c12a433fcb81b3fb7014aae1938dfaeeb919c11bce6b8b` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindsInternal.h` | `33ed4547f7e659adc3ed7dd531268355a96fc58ee271c866e65d0b308e4556f6` | `33ed4547f7e659adc3ed7dd531268355a96fc58ee271c866e65d0b308e4556f6` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.h` | `ddcc011d965b82f61ade50264b574522785f406eb707dbee0abd4695a069adce` | `ddcc011d965b82f61ade50264b574522785f406eb707dbee0abd4695a069adce` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.cpp` | `0084ee3cdc07b87d5e882790692e728a1ef1ae2dd888a3eeddfe961ddee0a713` | `f9120f36bf03b2d280535aabd4254c7eb245a2b9ccf8c15edda8420c92451cfa` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingProvidersTests.cpp` | `82906e6ce70edefaf430d23d410a4d69644ac3ad1cd726bad4274fdfe6bac6b6` | `82906e6ce70edefaf430d23d410a4d69644ac3ad1cd726bad4274fdfe6bac6b6` |

## Reports and scope

- `Saved/Harness/Unreal/Runs/bc7faa2e51064a9badb211de4046269a/AutomationReport/index.json`; SHA-256 `da0e0b2e7a509abfc4931230c5651087c786217473ec581c618bae92868bca7a`.
- `Saved/Harness/Unreal/Runs/a7c5ce70abe6492187a1a18b1f01f200/AutomationReport/index.json`; SHA-256 `e035de65c08092008a9a5d0afbd2c5b904b6cf27d0b992120f2630231b0987ce`.
- Full NativeEngine, dormant baseline, legacy suites, packaging and Performance were omitted: this node adds detached local-collection capture and has no native metadata, VM or default startup consumer. Full Runtime capture/installation remains gated by task 8.2.
- Capture requires the GameThread and a sealed provider collection. Provider modules and reflected objects must outlive all Engines consuming native addresses and UE facts from the snapshot.
- Later changes to shared recording sources require adjacent proof on the final content identity.

