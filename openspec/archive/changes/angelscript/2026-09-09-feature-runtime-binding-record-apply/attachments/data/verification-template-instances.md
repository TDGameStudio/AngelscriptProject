# Template-instance identity and operations verification

Task: 5.2. Parent base `a9afd56e73b9289ed32dee8210d7b96ac0b3b578`; plugin base `edc13e98d7a63fa22b76620302d1294fe6126641`.

## Commands and outcomes

- Build: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; NoWait = $true; TimeoutMs = 900000 }`.
- Exact tests: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Containers.Instances.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Behavioral RED `a7d86679056046f7b2a349f226c54aa9`: eight discovered cases, eight expected failures, zero warnings and eight errors, exit 255. Each case reached the absent template-materialization stub; this was a complete valid Automation report. Earlier run `544404d9e60849cc9dc35ba54ed52c37` used an invalid unbound fixture function and is setup evidence only.
- Initial implementation build `69e7d071f467499e804993fb686e2361` reached the affected Runtime module and failed on four local API-shape mismatches. Indexed `asCArray` access, the object alignment field, pointer-sized user-data storage and const bridging corrected those compilation defects. Build `035760d2b51c4718978e42f401f46469` succeeded.
- Intermediate exact runs `340fc1a5b19e438eb21599fbb06f5cf2`, `311cd0412bca40a2bf520ed35e69abd0` and `d65b7c3a28054e7ebe6163dbbdd7f8ad` localized two fixture assertions and one real composition defect. Concrete existing UObject identities replaced abstract object construction; nested primitive metadata is asserted through its type ID. Late dependent images now retain and reuse reachable prior specializations rather than publishing a duplicate stable key.
- Final build `defeb629ebd842e3b22c29625e7d31a7` succeeded.
- Exact GREEN `0eeed046e4d64a1a84220361ceafad60`: eight successes, zero warnings/errors, exit 0, complete valid report.
- Adjacent selection: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.'; Fast = $true; TimeoutMs = 600000; NoWait = $true }`.
- Adjacent run `d52a60a834e0414eabe87874fd67b3c2`: 160 discovered and complete, 154 successes with zero warnings; its only six failures are the already observed task 4.5 Bounds RED cases, all stopping at that task's not-yet-implemented `TArray<FVector>` member surface. All eight task 5.2 cases and every previously completed task remained successful on the same final binary.
- All managed operations reached terminal status through `ue.run.status`; no source writes occurred during builds or tests.

The implementation records explicit Array, Map, Set and Optional template-container kinds plus native element equality/hash/lifetime recipes. Each installation creates its own specialization operations and attaches them to that owner's types. The declaration template image freezes before the primary image; initial uses live in the primary image, and post-freeze uses live in complete dependent images. Prior dependent images become dependencies so nested or repeated canonical specializations remain single-owner identities without frozen-image mutation.

## Exact cases

| Case | Proof | GREEN |
|---|---|---|
| `ArrayPrimitiveStringAndNestedArgumentsAreCanonical` | `TArray<int>`, `TArray<FString>` and `TArray<TArray<int>>` retain distinct canonical argument graphs | Success |
| `RepeatedUseSharesOnlyWithinOneOwner` | Repeated lookup returns one type and operations object per owner; another owner has distinct mutable state | Success |
| `MissingCopyRequirementNamesElementAndProvider` | Missing element copy rejects with `FNoCopy` and `TemplateFixture` provenance | Success |
| `MissingHashRequirementNamesMapKeyAndProvider` | Missing key hash rejects with `FNoHash` and `TemplateFixture` provenance | Success |
| `InitialUseIsMaterializedBeforePrimaryImageFreezes` | A property type is owned by the primary image and visible through the attached Engine | Success |
| `LateInstanceAddsDependentImageWithoutChangingPrimaryImage` | Late materialization attaches one dependent image while the primary image remains attached | Success |
| `CountedArrayCopyAndDestructionUseElementRecipesExactlyOnce` | Two elements copy twice and the two arrays destroy four element instances | Success |
| `ObjectHandleArrayEnumeratesEachLiveReference` | Two live UObject identities are each enumerated from array storage | Success |

## Final identities

| Path | SHA-256 |
|---|---|
| `Core/AngelscriptTypeBindInfo.h` | `91be1010fe04d1026a687c35a1a8e21b4e51d5de44ca7d0ce4da8a7c5ae47850` |
| `Core/AngelscriptBinds.h` | `2458d00eb5d04c11709231c92c33ddf28160186f63c543ccec3899de0f909b4b` |
| `Core/AngelscriptBinds.cpp` | `2e350f0a82645c14107b7bc1eb1bf38b61e3e8181e6ac480566dd6f84c631f4` |
| `Core/AngelscriptTypeBindInfoDraft.h` | `7db867f887ff172adb895beadf130621936342a1d2ae56528b9cc98ab647c145` |
| `Core/AngelscriptTypeBindInfoDraft.cpp` | `da836596e7298b1c2f8001032002b5e324c6429e75d02bf9dfaaaa3ee8b5ffd7` |
| `Core/AngelscriptTypeBindInfoApply.h` | `0b519a7ebeb778a520eb0ff8a7641c9916118ba113cd6c510e24606f222a98ec` |
| `Core/AngelscriptTypeBindInfoApply.cpp` | `2d94ecd237dd5f76f182048cdd1eabf351bb8bbe4d92aa04d35c6d4d0d1e3c7c` |
| `Binds/Bind_TArray.cpp` | `16e00a3d2a7cdd446aeecddb0c840e88639358f163384900a9acb1de6305edb3` |
| `Binds/Bind_TMap.cpp` | `96e106e7e286f6d2644510907708add98ac6b3d9e6655f2d1ec3d5b1bcc0d625` |
| `Binds/Bind_TSet.cpp` | `2b7c1c8f1ac855576666240cc6413a7587226540328c08d0d43eb4da0aabdb40` |
| `Binds/Bind_TOptional.cpp` | `5198e4794c565dadf15ae22fa382fe3a556f8e6d417c753d9cb9b30006730377` |
| `RuntimeBindingInstancesTests.cpp` | `3011e8208f5fb458b966facecd0eb92fae7ef1fa7354e5b6f1ee1f8892c98c20` |
| `UnrealEditor-AngelscriptRuntime.dll` | `d2384924cb4e28130b73328a6005be09af74b006267cd476795717b590202656` |
| `UnrealEditor-AngelscriptTest.dll` | `8fe04a6e0c9b44893c7b9d9cabd3055c17e51f505aef3a39b92d70bb00b8a198` |

RED report `Saved/Harness/Unreal/Runs/a7d86679056046f7b2a349f226c54aa9/AutomationReport/index.json`: `c66284d8adf7f9b5d7bec98e7e420320c528e6fc4fe4daa6ab4a8fb64edfa90e`.

Exact GREEN report `Saved/Harness/Unreal/Runs/0eeed046e4d64a1a84220361ceafad60/AutomationReport/index.json`: `77cb54b55ad7149d35da321a4dd8a28b723dc23cba1fdd96ac548b8f9f06b137`.

Adjacent report `Saved/Harness/Unreal/Runs/d52a60a834e0414eabe87874fd67b3c2/AutomationReport/index.json`: `fe5460ef1aac606c783fb23ceb03431313f9ec8a37657a3b3a450ad4ff2bf9da`.

Complete container member surfaces, full Runtime accounting, startup, packaging, legacy suites, Performance and the full NativeEngine suite are omitted because later DAG nodes own them. The adjacent RuntimeBindings run establishes that only task 4.5's deliberately pending Bounds feature remains RED.
