# Actor and component runtime binding verification

Task: 7.3. Verification date: 2026-09-09 (Asia/Shanghai).

## Outcome

The actor, component, scene/mesh customization, world, volume, landscape, and actor-spawn providers now record into a detached Store and install into an explicitly owned Engine. Post-reflection actor/component factories enumerate the retained reflected snapshot rather than ambient UObject iteration. The actor spawn parameter surface avoids unsupported raw pointer and byte-enum property layouts by exposing typed accessors, while retaining its direct `FName` field and flag accessors.

`USceneComponent.Functions` is now a member-only provider and `FScopedMovementUpdate.TypeInfrastructure` owns its value type and lifecycle declaration. This lets the declaration prepass record the type once and the selected surface pass record scene-component methods without replaying a provider identity. Scene transforms and `FName` inputs use borrowed const references at the VM boundary, matching direct context argument ownership.

Compiler-only `__Actor_*` wildcard helpers remain declared and inspectable with `.Callable(false)` while native connection skips their `NotCallable` records. The custom `FunctionCaller` return path now stores implicit Unreal reference objects (`asOBJ_REF`) in `objectRegister`, so object-return APIs such as `GetCurrentWorld()` are observable through `GetReturnObject()`.

## RED and setup evidence

The exact selector was `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.'; Fast = $true; TimeoutMs = 600000 }`.

All six cases were prepared before the actor provider implementation. Early runs exposed setup barriers rather than behavioral RED: duplicate declaration-provider selection, actor/component post-reflection callbacks querying the absent ambient target database, unsupported byte-enum and raw pointer property layouts, an abstract component fixture, compiler-only wildcard declarations entering native linking, and incorrect direct-context ownership for by-value `FName`/`FVector` arguments. The `NotCallable` root cause and resolution are retained separately in `../implementation/issue-20260909-not-callable-native-linking.md`.

After those setup barriers were removed, run `4de3cb545b2243abb1b252ca02c2f44a` was the valid grouped RED: six cases discovered and executed, five successes, one failure, zero warnings. `CurrentWorldUsesExplicitAmbientFixture` demonstrated that the native helper returned the correct `UWorld*` while the custom caller stored an implicit Unreal reference result in `valueRegister`; the other five actor cases were passing controls. Report SHA-256: `686B0BC75AF485E8AF5BF6765AF77C8C6F067FAC799F69EA99FB247A86F808DE`.

## GREEN evidence

Build run `0564a55fe869456eb8f1a1094eaa3e67` succeeded for `AngelscriptProjectEditor Win64 Development`, exit 0.

Exact run `198c7f587e664455b679500577718dbe` passed all six cases with zero warnings/errors, exit 0:

- `Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.Actors.SpawnParameterFieldsAndFlagsRoundTrip`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.Actors.TransientActorAndSceneComponentPreserveTranslation`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.Actors.CurrentWorldUsesExplicitAmbientFixture`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.Actors.UnregisteredComponentNoneTagUsesExistingFalseContract`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.Actors.LocalDestructionDrainsActorAndComponent`
- `Angelscript.UnitTest.RuntimeBindings.Runtime.Actors.Actors.EveryActorComponentWorldAndMeshProviderIsAccounted`

Exact report SHA-256: `4F5F5D97C211E83589615DDDA1154F55EDFD71C3AE4FF945BE895D63274CE6AF`.

Focused shared-call run `ff545bac1b8945229f7070e2972d67a0` passed all 20 `Angelscript.UnitTest.RuntimeBindings.Calls.Native.` cases with zero warnings/errors, exit 0. Report SHA-256: `E508CE573B28B76A83C7B4F63F34447046335B3A4E01BE8A30819634F975E91C`.

Shared run `fd3e2383e6574e87acdab19e70c7a54e` passed all 266 `Angelscript.UnitTest.RuntimeBindings.` cases with zero warnings/errors, exit 0. Shared report SHA-256: `6E3952A07FE525F2F7E87A002136A9C5445B2596102DEF67EFD0486F78D5402D`.

## Final source and binary identity

| Path | SHA-256 |
|---|---|
| `Binds/Bind_AActor.cpp` | `60B0B2A4815544E9397C579A475E654344D74C086D87DB3A0DE7AB9E1D94B780` |
| `Binds/Bind_FActorSpawnParameters.cpp` | `5197B52EA77AAD57BFC5D7332BE5631E94B5277F339734B9A2819B375CE9799D` |
| `Binds/Bind_FActorSpawnParameters.h` | `605B413F51F449BA110C772E82F40CF22352D8337F1228D8238CDEC2BA433D7B` |
| `Binds/Bind_UActorComponent.cpp` | `43C8A6C622CA01A359CE25C04AF3C4DFC806F581AB7966156F9216E54336A7CB` |
| `Binds/Bind_USceneComponent.cpp` | `030655E622C8B7FA0268D4A1A3CC169D40D6F6A90226C143A5BD633DE2DCA066` |
| `Binds/Bind_USceneComponent.h` | `CEC388D1B52C8FA7C937A75F88FCEE10A72867D89399B9A6DD16F2A93AF04397` |
| `Binds/Bind_USceneComponent_Functions.cpp` | `7DC7851828D05C3FEB4EBC97002082371CBD1D5AD4904B62E7F8B1BC89DE34F9` |
| `Binds/Bind_UWorld.cpp` | `80F5127DB3A9CE22D029D0EAB948FF87F85658E262DCD74997B8282B824C6187` |
| `Core/AngelscriptTypeBindInfoApply.cpp` | `D28192136D437C3BEEC29D02AABCAFA52EFB8D7003E9FF4CB0FBAC3EA585E264` |
| `ThirdParty/angelscript/source/as_context.cpp` | `6178E01E459D47E20F7C16D4EBF970A87D2D8B10FE6BD30DC99A691AA407373E` |
| `Bindings/RuntimeBindingActorsTests.cpp` | `0BDA21807EFAADA646133BAE43FF9E7DDE1D610E0295B22E757F2011D054F9D1` |
| `UnrealEditor-AngelscriptRuntime.dll` | `4A8EA527248826169E75386437762898E36DB923760A5E95998D0EAE3FD13219` |
| `UnrealEditor-AngelscriptTest.dll` | `A283B7598CB942C62D2E385A52330BE2B9BBBEEBA641D8A104EF2E085A01CE4E` |

Input/UI, asset/data, serialization, platform, diagnostics, services, finalization, full-factory, NativeEngine, baseline, packaging, performance, JIT, and legacy verification remain owned by later tasks. The complete RuntimeBindings run covers the affected shared recording, installation, native-call, and provider-accounting contracts.
