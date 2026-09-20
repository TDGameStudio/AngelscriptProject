# UE DECLARE_* callable macros on the replacement host

Settled 2026-09-18: keep this Change; drop language keywords `delegate` and `event` as a transitional reject (token deletion is a later Change); the script declaration surface is one declaration-form table for the six UE `DECLARE_*` families (60 spellings); Bind/Execute/Broadcast run on the replacement host; later payload, native `TDelegate`, Blueprint, and cook nodes stay in this Change.

## Call chains

```
DECLARE_DELEGATE_* / DECLARE_DYNAMIC_* source
→ FAngelscriptPreprocessor::Preprocess
    // No ProcessDelegates wrapper struct. No C-macro expansion of DECLARE_*.
    // Newlines increment LineNumber and do not split a Global chunk.
→ asCParser declaration-form table + existing type parser
    // Longest-prefix family + suffix arity. 31 Event/TS/Sparse/Derived diagnostics.
→ asCSema asCCallableTypeDecl (asECallableFlavor + single vs multicast)
→ FAngelscriptDescriptorConsumer → FAngelscriptDelegateDesc
    // Flavor and Signature copied from the declaration. Function stays null.
→ FAngelscriptEngine::CompileModules(Initial)
→ 1.4 definition-graph CallPtr return 42
→ Bind named free/member + Execute / Broadcast
```

Later nodes reuse the same host, they do not restore `WITH_ANGELSCRIPT_UNITTESTS` or `Bind_Delegates` as the callable model:

```
FAngelscriptDelegateDesc (bIsDynamic)
→ ClassGen Analyze / FullReload uses Desc.Signature
    // Not GetMethodByName(Execute|Broadcast).
→ UDelegateFunction + FDelegateProperty   // 3.2, dynamic only
→ BindDynamic / AddDynamic + Blueprint listener / script UFUNCTION         // 3.3
→ editor load + cooked fixture                                             // 4.1
```

Measured at: 38e1b7a4fe9bbc540106f28d7858ccd5d899868f (workspace dirty). ClassGen still reconstructs signatures from generated Execute/Broadcast on the old path. Descriptor projection already emits `FAngelscriptDelegateDesc` from `asCCallableTypeDecl` without Flavor. Neither is proven for `DECLARE_*` on `CompileModules` after keyword removal.

## Declaration-form table

One parser entry matches a `DECLARE_*` identifier in a declaration context. Family is the longest supported prefix. Suffix is the arity token (`""` … `_NineParams`). Parameter layout is ordinary unnamed types or dynamic type/name pairs. Nested `<>` commas stay inside the existing type parser. The 60-row matrix below is the expectation oracle, not 60 parsers.

| spelling | flavor | cast | return | arity | name-position | param-shape |
|---|---|---|---|---:|---|---|
| `DECLARE_DELEGATE` | ordinary | single | void | 0 | name-first | unnamed-types |
| `DECLARE_DELEGATE_OneParam` | ordinary | single | void | 1 | name-first | unnamed-types |
| `DECLARE_DELEGATE_TwoParams` | ordinary | single | void | 2 | name-first | unnamed-types |
| `DECLARE_DELEGATE_ThreeParams` | ordinary | single | void | 3 | name-first | unnamed-types |
| `DECLARE_DELEGATE_FourParams` | ordinary | single | void | 4 | name-first | unnamed-types |
| `DECLARE_DELEGATE_FiveParams` | ordinary | single | void | 5 | name-first | unnamed-types |
| `DECLARE_DELEGATE_SixParams` | ordinary | single | void | 6 | name-first | unnamed-types |
| `DECLARE_DELEGATE_SevenParams` | ordinary | single | void | 7 | name-first | unnamed-types |
| `DECLARE_DELEGATE_EightParams` | ordinary | single | void | 8 | name-first | unnamed-types |
| `DECLARE_DELEGATE_NineParams` | ordinary | single | void | 9 | name-first | unnamed-types |
| `DECLARE_DELEGATE_RetVal` | ordinary | single | retval | 0 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_OneParam` | ordinary | single | retval | 1 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_TwoParams` | ordinary | single | retval | 2 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_ThreeParams` | ordinary | single | retval | 3 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_FourParams` | ordinary | single | retval | 4 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_FiveParams` | ordinary | single | retval | 5 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_SixParams` | ordinary | single | retval | 6 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_SevenParams` | ordinary | single | retval | 7 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_EightParams` | ordinary | single | retval | 8 | name-after-return | unnamed-types |
| `DECLARE_DELEGATE_RetVal_NineParams` | ordinary | single | retval | 9 | name-after-return | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE` | ordinary | multi | void | 0 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_OneParam` | ordinary | multi | void | 1 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_TwoParams` | ordinary | multi | void | 2 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_ThreeParams` | ordinary | multi | void | 3 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_FourParams` | ordinary | multi | void | 4 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_FiveParams` | ordinary | multi | void | 5 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_SixParams` | ordinary | multi | void | 6 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_SevenParams` | ordinary | multi | void | 7 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_EightParams` | ordinary | multi | void | 8 | name-first | unnamed-types |
| `DECLARE_MULTICAST_DELEGATE_NineParams` | ordinary | multi | void | 9 | name-first | unnamed-types |
| `DECLARE_DYNAMIC_DELEGATE` | dynamic | single | void | 0 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_OneParam` | dynamic | single | void | 1 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_TwoParams` | dynamic | single | void | 2 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_ThreeParams` | dynamic | single | void | 3 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_FourParams` | dynamic | single | void | 4 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_FiveParams` | dynamic | single | void | 5 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_SixParams` | dynamic | single | void | 6 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_SevenParams` | dynamic | single | void | 7 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_EightParams` | dynamic | single | void | 8 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_NineParams` | dynamic | single | void | 9 | name-first | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal` | dynamic | single | retval | 0 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_OneParam` | dynamic | single | retval | 1 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_TwoParams` | dynamic | single | retval | 2 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_ThreeParams` | dynamic | single | retval | 3 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_FourParams` | dynamic | single | retval | 4 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_FiveParams` | dynamic | single | retval | 5 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_SixParams` | dynamic | single | retval | 6 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_SevenParams` | dynamic | single | retval | 7 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_EightParams` | dynamic | single | retval | 8 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_DELEGATE_RetVal_NineParams` | dynamic | single | retval | 9 | name-after-return | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE` | dynamic | multi | void | 0 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam` | dynamic | multi | void | 1 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams` | dynamic | multi | void | 2 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_ThreeParams` | dynamic | multi | void | 3 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_FourParams` | dynamic | multi | void | 4 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_FiveParams` | dynamic | multi | void | 5 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_SixParams` | dynamic | multi | void | 6 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_SevenParams` | dynamic | multi | void | 7 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_EightParams` | dynamic | multi | void | 8 | name-first | named-pairs |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_NineParams` | dynamic | multi | void | 9 | name-first | named-pairs |

Unsupported families stay off this table and diagnose `unsupported-delegate-declaration-form`: `DECLARE_EVENT`, `DECLARE_DERIVED_EVENT`, `DECLARE_TS_MULTICAST_DELEGATE`, `DECLARE_DYNAMIC_MULTICAST_SPARSE_DELEGATE` (31 spellings).

## Settled decisions

| ID | Decision |
|---|---|
| Q1 | Keep `angelscript/feature-delegates-ue-interop` and replan in place. |
| Q2 | Remove `delegate` / `event` as valid callable introducers. Language matches UE C++ `DECLARE_*`. |
| Q3 | Macro work includes Bind/Execute (and Broadcast for multicast), not parse-only. |
| Q5 then user | This Change owns the full six-family 0–9-parameter table (60 spellings). |
| Q6 | Keep tasks 2.2, 2.3, 3.1, 3.2, 3.3, 4.1. They stay pending until their prerequisites complete. |
| Q7 | Task 1.4: definition-graph/Builder CallPtr returns 42 before DECLARE Execute. |
| Q8 | First-wave proofs own Diagnostics, Preprocess, Register, and Invoke as separate commands. |
| Q9 | Reshape 1.2/1.4 so those stages are not packed into mixed cards. |
| Q10 | One declaration-form table plus a 60-row expectation matrix. |
| Q11 | Keywords are fully deprecated this Change: reject only. Delete `KwDelegate` / `KwEvent` in a later Change. |
| deferred 31 | Event/TS/Sparse/Derived stay unsupported diagnostics. |

Lexer keeps `delegate` / `event` tokens only so Parser can emit a removed-syntax diagnostic. Preprocessor `DetectClasses` / `ProcessDelegates` must not rewrite those tokens into `_FScriptDelegate` wrapper structs.

## Naming assumed

Convention `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>` from `ClassGenUClassReload`:

| Task | TEST_CLASS | Prefix |
|---|---|---|
| 1.2 | `DelegateDeclarations` | `Angelscript.UnitTest.NativeEngine.Sema.DelegateDeclarations` |
| 1.3 | `DelegateBinding` | `Angelscript.UnitTest.NativeEngine.Sema.DelegateBinding` |
| 1.4 | `DelegateCallRetVal` | `Angelscript.UnitTest.NativeEngine.Compile.DelegateCallRetVal` |
| 1.5 | `DelegateDiagnostics` | `Angelscript.UnitTest.NativeEngine.Sema.DelegateDiagnostics` |
| 1.6 | `DelegatePreprocess` | `Angelscript.UnitTest.NativeEngine.Compile.DelegatePreprocess` |
| 1.7 | `DelegateRegister` | `Angelscript.UnitTest.NativeEngine.Definitions.DelegateRegister` |
| 2.1 | `DelegateExecute` | `Angelscript.UnitTest.NativeEngine.Compile.DelegateExecute` |
| 2.2 | `DelegatePayloads` | `Angelscript.UnitTest.NativeEngine.Compile.DelegatePayloads` |
| 2.3 | `DelegateMulticast` | `Angelscript.UnitTest.NativeEngine.Compile.DelegateMulticast` |
| 3.1 | `DelegateNativeInterop` | `Angelscript.UnitTest.NativeEngine.Compile.DelegateNativeInterop` |
| 3.2 | `DelegateReflection` | `Angelscript.UnitTest.NativeEngine.Compile.DelegateReflection` |
| 3.3 | `DelegateDynamicInterop` | `Angelscript.UnitTest.NativeEngine.Compile.DelegateDynamicInterop` |
| 4.1 | `DelegateLifecycle` | `Angelscript.UnitTest.NativeEngine.Compile.DelegateLifecycle` |

`asECallableFlavor` is `Ordinary` or `Dynamic` on `asCCallableTypeDecl`. `FAngelscriptDelegateDesc` stores `bIsDynamic` beside `bIsMulticast`. Script Bind/Execute/Broadcast spellings recorded by 1.1: `Bind`, `BindUFunction` (3.3), `Add`, `Remove`, `RemoveAll`, `Clear`, `Broadcast`, `Execute`, `ExecuteIfBound`, `IsBound`, `FDelegateHandle`.

Removed-keyword diagnostic: `asEDeclarationDiagnostic::RemovedDelegateEventKeyword` = 3244, catalog reason `removed-delegate-event-keyword`. Unsupported-family diagnostic: `asEDeclarationDiagnostic::UnsupportedDelegateDeclarationForm` = 3245, catalog reason `unsupported-delegate-declaration-form`. 4.1 cook route: `ue.commandlet` `Commandlet=Cook` `ExtraArguments=@('-TargetPlatform=Windows')`. See `attachments/data/planning-contracts.md`.

## Out of first Ready product work

Lambda / anonymous functions, `NewVersion/` test roots, Language folder execute, `WITH_ANGELSCRIPT_UNITTESTS`, `PerformHotReload` watch / PIE, CacheV2, restoring preprocessor wrapper generation, and deleting `KwDelegate` / `KwEvent` stay out. Language bags `Language/Delegate/Declare` and `Language/Event/Declare` are catalog/spec work, not the proving command.
