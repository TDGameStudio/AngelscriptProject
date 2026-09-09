# Recording facade verification

Task: 1.3. The final shared run also refreshes task 1.2 on the recorded Store implementation. Parent base a9afd56e73b9289ed32dee8210d7b96ac0b3b578; plugin base edc13e98d7a63fa22b76620302d1294fe6126641.

## Commands and outcomes

- Builds: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ NoWait = $true; TimeoutMs = 900000 }`.
- RED setup build `cd933a5497eb400c8950c847c83ecf6c`: succeeded, exit 0.
- RED test `4d0187372916472da2b46613e61ef314`: eight discovered and executed failures, exit 255.
- RED command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.Facade.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- First implementation build `d898478d69e645688f9dc93052536f67`: succeeded; shared test `17993dcd2e2b48caa09df6fd038b7ef6`: 14 successes and one failure. NamespaceAndCaseSensitiveTypesDoNotCollide observed two types instead of three. UE FString default map equality/hash ignore case; explicit case-sensitive key functions now preserve AngelScript nominal identity.
- Corrected build `8b1397bc2a62446e9a7b6107bdc6e14e`: succeeded, exit 0.
- GREEN shared test `7f9c842911854ffba95971084dd01150`: all 15 cases succeeded, zero errors/warnings, no unexecuted/in-process cases, exit 0.
- Shared command: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- All asynchronous launches were followed to terminal state through `ue.run.status`.

RED used compilable recording stubs: missing records, invalid recorded handles and zero type count failed the eight scenarios. This does not claim independent RED execution of later assertions blocked by those prerequisites. GREEN executed every assertion, covering native layout, lifecycle/caller variants and auxiliary data, enum values, namespaces, constant values, exposure flags, traits, first-parameter/default declaration text, compile policies, ordered native/JIT recipes, copied descriptor lifetime, stable handles and rejected sealed edits. Query helpers inspect records; engine-object getters return null where their API is nullable. Adapter factories and explicit Engine context services remain owned by the later prepass/integration tasks.

## Case mapping

| Exact scenario | Task | Original RED | Final shared result |
|---|---|---|---|
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.CallerVariantsAndPropertyExposureSurviveRecording` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.FunctionTraitsAndCompilePoliciesAreDetached` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.HandlesSurviveGrowthAndRejectSealedEdits` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespaceAndCaseSensitiveTypesDoNotCollide` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NamespacesEnumsAndConstantsAreRecorded` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.NativeRecipesOwnTheirInputsAndPreserveOrder` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ReferenceAndTemplateDeclarationsRetainUEFacts` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.ValueLifecycleAndMembersNeedNoEngine` | 1.3 | Fail at missing recording entry behavior | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.CompatibleDeclarationsCoalesce` | 1.2 adjacent | Prior Store proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.ConflictingNativeDefinitionReportsBothSources` | 1.2 adjacent | Prior Store proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.EmptyStoreSeals` | 1.2 adjacent | Prior Store proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RecordHandlesSurviveGrowthAndRejectForeignStores` | 1.2 adjacent | Prior Store proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.RepeatedSealPreservesIdentity` | 1.2 adjacent | Prior Store proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.SealedMutationRejected` | 1.2 adjacent | Prior Store proof; regression control here | Success |
| `Angelscript.UnitTest.RuntimeBindings.Recording.Store.StoreOwnsInputLifetime` | 1.2 adjacent | Prior Store proof; regression control here | Success |

## Content identities

| File | RED SHA-256 | Final GREEN SHA-256 |
|---|---|---|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h` | `fe7bbb53e3a2e48d913bc4efbf5f1396ca48a023d4dca010fe6e0eb5f5ce4dff` | `250f59a6099cae20311a6000ff6b6d251b1c87afe8d8a111643c3a17de19c633` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp` | `580d003c816d589a3591453d0ffe08eea15bdfc1bb341c08490c96a20a7409b9` | `b201fc60579247d34a912330397da91ceac10e95474a2fcc7881c330f4491e23` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo.h` | `c582c4f9a4dbf62e2f4230684859266b152653b2b6bd304db689f61be4c206c8` | `c582c4f9a4dbf62e2f4230684859266b152653b2b6bd304db689f61be4c206c8` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.h` | `f418d599acc25e5a0136a8b5aaaed5df49f3b5aae99ff6eda49f7820a8a49630` | `d44b120fe3dfd226704bcd3285c88f3e0a6d57132447db348df7624afbcc7912` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.cpp` | `33cb20cce700099d72496f2858331e8aa6ec932c786aabd043ccea092797e75f` | `6307dd7cc0a8593f248925548823590ef75317789de89d9ea017183a6f610749` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingFacadeTests.cpp` | `0bc3e832b3314f546c13dfb65c9f3b6192946222ddba5223545f9d66d71777c1` | `0bc3e832b3314f546c13dfb65c9f3b6192946222ddba5223545f9d66d71777c1` |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingStoreTests.cpp` | `50d1877da6e1a4dc91a6685535228d799ea1d953b9106638136542e401799346` | `50d1877da6e1a4dc91a6685535228d799ea1d953b9106638136542e401799346` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | `0c428eafed2198cb8ba07aa37a4ac8404457cef0cf8d2629ab622d3154b5d720` | `e297a6a0f472c63a39b082f20ba54b74e26c4cec0c8867fd92d376501eec4031` |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | `6818670d32aa01a41064ac2b90698b91bd532dc2d8905176798b22a4d53b3daa` | `65c5e07788c5e3e02b675172afed08d64c89d1d5d96e43acfa999eb762104382` |

## Reports and scope

- `4d0187372916472da2b46613e61ef314`: `Saved/Harness/Unreal/Runs/4d0187372916472da2b46613e61ef314/AutomationReport/index.json`; SHA-256 `a03f9669e56886709d9c24a6a10d38a5675e9a9e927c7349ff25d948ed74f8e2`.
- `17993dcd2e2b48caa09df6fd038b7ef6`: `Saved/Harness/Unreal/Runs/17993dcd2e2b48caa09df6fd038b7ef6/AutomationReport/index.json`; SHA-256 `6b8f41248a23fb29b4eff18c2dcac3b31a09b234860d4edbb8c7436f65e28161`.
- `7f9c842911854ffba95971084dd01150`: `Saved/Harness/Unreal/Runs/7f9c842911854ffba95971084dd01150/AutomationReport/index.json`; SHA-256 `45a010040d94d55c2816a6cd5ca9de85262cfd53647ef2a9ec53791735c6a728`.
- Full NativeEngine, dormant baseline, legacy suites, packaging and Performance were omitted for this detached authoring outcome. Native metadata installation, Engine construction and startup behavior have not changed; the later integration nodes own their matching proofs.
- Shared Core/Store changes in later nodes require adjacent Recording proof on their final source and binary identities.

