# Hazelight Upstream Inventory

## Audit Range

- Repository: `Hazelight/UnrealEngine-Angelscript`
- Branch: `angelscript-master`
- Intended base marker: `472bb2fab5a0bc76d0a86a1dd80750a4118b8418`
- Reviewed head: `138a7e186082b639375b95545e0177b18f13c4be`
- Core path: `Engine/Plugins/Angelscript`
- Core commits after marker: 34
- Complete related-path union after marker: 39
- Previous `Count 20` output: preview only; it did not cover this complete range

## Authors And UE-Follow Signals

- Author counts: Lucas 25; Dean Marsinelli 3; 류기보 2; Dan Bradshaw, Filip Bergqvist, Josh Wood, KirstenWF, Nango, Paul Greveson, Szymon Zak, Tianlan Zhou, and Turhan Yağız Merpez 1 each.
- UE-following signals: `9a366282fa72`, `4efb6a2c01e9`, and `b233a0a85ad4`.

## Core Plugin Commits

| SHA | Date | Upstream change | Local classification | Action |
| --- | --- | --- | --- | --- |
| `7270607d98aa` | 2026-07-07 | Fix `FString::TrimQuotes` binding for StaticJIT | Adopt now | Replace trivial member bind with lambda and test |
| `39daec6b4540` | 2026-07-02 | Fix macOS editor build include | Reference only | Verify after platform build support |
| `83a3e539d43a` | 2026-07-01 | Stop `UObjectTickable` immediately on destruction | Adopt now | Add tick shutdown and regression test |
| `5022c3a07a1f` | 2026-07-01 | Determine `CreateWidget` output from `WidgetType` | Adopt now | Add metadata and signature test |
| `98626b3dd747` | 2026-06-29 | Remove floating `Pow` overflow checks | Needs OpenSpec | Preserve current behavior in first batch |
| `ff265bb18dbb` | 2026-06-24 | Fix `FCollisionResponseContainer` constructor | Already absorbed | No code change |
| `309e7001ab12` | 2026-06-23 | Fix `FBox3f::opAssign` binding | Reference only | Local binding omits the method; investigate separately |
| `b448dd3defca` | 2026-06-23 | Fix latent and EnhancedInput nativization | Adopt now | Apply the latent fix and local no-native-form lambda equivalent |
| `9a366282fa72` | 2026-06-18 | Additional UE 5.8 fixes | UE-follow / review | Keep local equivalents and inspect residuals |
| `4efb6a2c01e9` | 2026-06-17 | UE 5.8 compatibility fixes | UE-follow / review | Do not wholesale cherry-pick |
| `f0f383f5cb22` | 2026-06-17 | Share StaticJIT VMEntry thunks | Needs OpenSpec | Separate StaticJIT architecture work |
| `4065a84c1bb7` | 2026-06-17 | Debounce duplicate HotReload notifications | Needs OpenSpec | Separate HotReload behavior change |
| `5aa00922b79a` | 2026-06-17 | Preserve editable `FInstancedStruct` data on HotReload | Reference only | Requires engine-side changes |
| `b2ba331a586f` | 2026-06-17 | Remove outdated class bind flags check | Reference only | Fork compatibility decision required |
| `ad68224f577e` | 2026-06-17 | Inherit Placeable state unless overridden | Needs OpenSpec | Script-visible class generation behavior |
| `9b6eab4f34e2` | 2026-06-17 | Add `bAllowShrinking` to TArray swap removals | Needs OpenSpec | Public binding API change |
| `88aecc9afd5b` | 2026-06-17 | Move FTransform binds for unnormalized rotation errors | Review | Compare local math binding behavior |
| `67ef4b518acc` | 2026-06-17 | Fix BlueprintType classes with NotBlueprintType parents | Needs OpenSpec | Script/Blueprint reflection behavior |
| `06339d7b2bb0` | 2026-06-15 | Stabilize bind database for deterministic patches | Needs OpenSpec | Runtime binding identity behavior |
| `4b3da3a51cea` | 2026-06-03 | Bind `FAssetData` comparisons | Review | Check local asset binding coverage |
| `dc2113bff6b8` | 2026-05-27 | Add AS test asserts for uint32 and FGameplayTag | Review | Compare local test helpers |
| `d23704e93569` | 2026-05-13 | Respect simulate-cooked for editor-only binds | Needs OpenSpec | Cooked/editor behavior change |
| `f08aaefc16f5` | 2026-05-13 | Correct editor-only struct classification | Needs OpenSpec | Cooked/editor behavior change |
| `b5524b5c96b3` | 2026-05-13 | Small fixes to example script files | Reference only | Example maintenance only |
| `b111be76600b` | 2026-05-13 | Add `FAssetData.IsBlueprintChildOf` bind | Review | Check local binding gap |
| `948a7c470e09` | 2026-05-13 | Clean up `ShouldBindEngineType` | Reference only | Compare local binding policy |
| `6948712ac8cd` | 2026-05-13 | Fix null class handling in attached actor bind | Adopt candidate | Add focused binding regression if local gap exists |
| `c6ca75eaa675` | 2026-05-13 | Bind modifying `FRuntimeFloatCurve` keys | Review | Check local curve binding coverage |
| `c15b41c7ca7b` | 2026-05-13 | Add dynamic registration to editor menu extension | Needs OpenSpec | Editor lifecycle behavior |
| `89419d7df9f8` | 2026-05-13 | Work around TMap default-value parsing | Needs OpenSpec | Preprocessor/compiler behavior |
| `43f3892e8e41` | 2026-05-13 | Mark invalid cooked `UASClass` methods editor-only | Needs OpenSpec | Cooked runtime behavior |
| `ed6d9c453f96` | 2026-05-13 | Fix source navigation script typename selection | Review | Compare local source navigation split |
| `767ec06038f0` | 2026-05-13 | Improve StaticJIT numeric comparison generation | Needs OpenSpec | StaticJIT behavior and generated code |
| `3ab2bf192f96` | 2026-05-13 | Fix negated preprocessor macro error handling | Needs OpenSpec | Compiler/preprocessor behavior |
| `3bdda958bc18` | 2026-05-13 | Fix debugger display of null `TSoftObjectPtr` | Review | Compare local debugger behavior |

## Related Paths And Signals

| SHA | Path group | Classification | Action |
| --- | --- | --- | --- |
| `138a7e186082` | UHT `UhtProperty.cs` | Reference only | Engine-side property cache; local plugin uses a sidecar replacement |
| `67b7a88d912f` | `Engine/Plugins/AngelscriptGAS` | Out of scope | Record only; no core plugin merge |
| `900146faa5e9` | `Script-Examples` | Reference only | Comment-only example maintenance |
| `b5524b5c96b3` | `Script-Examples` | Reference only | Small example script maintenance |
| `b233a0a85ad4` | UE release merge/UHT | UE-follow | Record as merge signal, not plugin feature |

## Pow Decision Record

The local integer overflow path remains exception-based. The local interpreter floating paths currently raise `Overflow in exponent operation` for `HUGE_VAL`; StaticJIT already emits direct `Math::Pow` without that check. Hazelight removes only floating compile-time and interpreter checks, so floating overflow becomes `+inf` or the platform overflow result. This is deferred because it changes the existing `AngelscriptSDK` test contract.

## Verification Evidence

- Editor build: `Tools\RunBuild.ps1 -TimeoutMs 1200000 -NoXGE -Label haze-parity-tick-test-build` succeeded.
- Focused parity run: `Angelscript.TestModule.Bindings.BodyInstance`, `Bindings.UObjectTickable`, `Coverage.FStringMethod`, `Engine.BindConfig`, and `StaticJIT.NativeForms` passed `41/41`.
- AngelScript SDK baseline: `Angelscript.TestModule.AngelScriptSDK` passed `421/421`; `AngelscriptSDKOperatorTests::Pow` preserved the existing `Overflow in exponent operation` expectation.
- EnhancedInput local adaptation: the fork does not define Hazelight's `METHOD_NOJIT`; a lambda binding leaves `FEnhancedInputActionEventBinding::GetHandle` without a StaticJIT native form, verified by `EnhancedInputGetHandleNoJit`.
