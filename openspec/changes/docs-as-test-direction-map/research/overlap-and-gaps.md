# Overlap and gap snapshot (2026-08-18)

Not TestCatalog. Used to justify the eight directions.

## Physical scale

| Tree | cpp | Typical question today (messy) |
|---|---|---|
| AngelScriptSDK | 314 | fork language + SDK APIs |
| Cache | 104 | store/codec **and** some AS roundtrip |
| Coverage | 90 / ~1022 methods | type/API behavior |
| StaticJIT | 89 | packager/ABI **and** ScriptCorpus copies |
| Bindings | 88 | contract **and** leftover matrices |
| Functional | 52 | World stories **and** misfiled Operators/ControlFlow |
| Core | 45 | engine lifecycle / parity |
| Generator | 35 | generated UClass + planner |
| Compiler | 34 | pipeline |
| HotReload | 30 | apply + classify |
| Syntax | 19 / ~581 snippets | form compile **and** packed execute |
| Debugger | 15 | DAP |
| Preprocessor | 18 | `#if` / include |
| RuntimeJIT | 6 | factory/session |
| FunctionLibraries | 18 | mixin contract |
| Dump / FS / GC / Memory / Performance / Validation / Testing / UHT | small | host machinery / reflected suites |

`All` in `TestSuiteDefinitions.ps1` lists Syntax, Bindings, Functional, StaticJIT, Cache, … and **does not** list `Angelscript.TestModule.Coverage`.

## Duplicate clusters (stop feeding)

| Topic | Appears in | Keep feeding | Stop feeding |
|---|---|---|---|
| int / operators | Native Language, Syntax Operators execute, Coverage 01 | Native without UE; Coverage type family; DataDriven generate | New Syntax packed execute |
| if / for / switch | Native, Syntax ControlFlow, Coverage 09, Functional/ControlFlow | Native; Coverage execute; Syntax **negatives** | Functional unless World; new Syntax packed execute |
| TArray / TMap / TSet | Syntax Container, Bindings leftover, Coverage 03 | Bindings smoke; Coverage matrix (`Containers.*`) | Syntax unless unique spelling (`TOptional` forms) |
| FString | Syntax literals, Coverage methods, Bindings | `Language.Literals.FString` forms; Coverage methods | Bindings method tables |
| UFUNCTION | Syntax specifiers, Coverage 07, Bindings | Syntax compile forms; Coverage execute/reflection; Bindings entry | Copying specifier tables into all three |
| DefaultComponent | Syntax 19 methods, Coverage 05, Functional Component | `Feature.DefaultComponent` create; `Feature.Attach` Root/Attach/Override | Coverage duplicating Tick/attach-tree stories as `World.Component` |
| LiteralAsset / `asset … of` | Coverage LiteralAsset, AssetLoading mix | `Feature.Asset` | `Gameplay.Assets` Load* matrices; `World.Asset` |
| Delegates | Syntax DelegateEvent, Coverage 08, Functional Delegate, Bindings | `Feature.Delegates` same split as UFUNCTION | fourth copy |
| Preprocessor | Preprocessor/, Coverage 09, Native Frontend | Preprocessor pipeline; Native tokenizer | Coverage `#include` copies |
| Reload classify | HotReload, Generator ReloadPlanning | Generator planner unit; HotReload apply | DataDriven `vm` profile |
| Same script × JIT/cache | StaticJIT ScriptCorpus, Cache AS strings, future DataDriven | DataDriven profiles | new inline copies |

## Incomplete (real holes)

| Hole | Direction | Recorded where |
|---|---|---|
| Same `.as` × VM/Cache/JIT | `same-as-profile` | `test-as-data-driven-engine-harness` |
| Syntax AS trapped in `TEXT(R"(` | `surface-form` | `research/syntax-refactor-map.md` (harness change) |
| Teaching / `Assert*` scripts | `world-story` | `test-as-script-corpus-and-functional-coverage` |
| Coverage not in named All suite | operations | this change apply |
| Runtime JIT skip-if-no-factory | `same-as-profile` | harness `runtime-jit` |
| Debugger MARK fixtures | `host-machinery` | Decision 16 leftover |
| Bind_*.cpp contract inventory holes | `bind-contract` | bindings layout Stage 2 leftover |
| Native combination catalogs | `native-fork` | `test-as-native-sdk-comprehensive-coverage` (depth still a product risk) |
| Coverage G7 WidgetAnimation / G19 foreach mutation | `behavior-matrix` | `coverage-gaps.md` ceilings — do not treat as missing folders |
| Math / `FMath::` TestCorpus | `bind-contract` / `behavior-matrix` | **blocked** until `improve-as-library-namespace-canonicalization`; then `Gameplay.FMath` + `Gameplay.FVector`… |

## Allowed two-layer pairs

- Bind smoke + Coverage row (same API)
- Syntax negative compile + Coverage execute of the legal form
- HotReload pair + Generator planner unit
- DataDriven `vm` leaf + packager CQTest (different questions)
