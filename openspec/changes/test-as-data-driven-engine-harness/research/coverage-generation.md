# Coverage as code generation

This is `AngelscriptTest/Coverage/` scenario coverage (CQTest, prefix `Angelscript.TestModule.Coverage.*`, indexed by `openspec/changes/test-coverage/coverage-matrix.md`). It is **not** the Runtime `CodeCoverage` engine extension (`code-coverage-extension`).

Evidence for Decision 10 in `design.md`. Files call themselves **"Übershader-style"** and walk one usage axis against a type family, but the implementation is still hand-unrolled `ASTEST_AS`.

## Answer

Coverage **can** be generated, **only by slice**. It cannot become one generator that emits all 1022 `TEST_METHOD`s.

The files already advertise a product: `int8…uint64` × axis. The missing piece is a C++ table that emits the AngelScript, not a rewrite of Widget/Input/Physics into templates.

## Two Coverage shapes in one directory

`AngelscriptCoverageIntPropertyTests.cpp` header: walks the whole int family per axis through Pattern D (`CompileScriptModule` + `FActorTestSpawner` + `FPropertyBindingPath` / `VerifyByPath`). `IntFamilyDeclarationDefaults` still pastes eight `UPROPERTY` members by hand.

`AngelscriptCoverageIntExpressionTests.cpp` header: same family, Pattern B/F (`BuildModule` + `FASGlobalFunctionInvoker`). `LocalDeclarations` / `ArithmeticOperators` paste `LocalInt8`…`LocalUInt64` by hand.

`AngelscriptCoverageTArrayAdvancedTests.cpp` `TArraySortAndReverse`: unique Actor + `UPROPERTY TArray<int>` + `BeginPlay` Sort. Not a type product.

## Generator templates (Coverage-specific)

Do **not** feed Coverage from SDK tables blindly. Coverage uses `FAngelscriptEngine` + UE binds. SDK `FNativeTypeCase` may supply width names, but Coverage also needs UE property/UFUNCTION templates.

| Template id | Emits | Oracle | First fit |
|---|---|---|---|
| `expression-product` | Module-level global functions per type×op | `executeInt` / `executeBool` (Pattern B) | Int/Float/Bool Expression operators, conversions, local declarations |
| `function-mode-product` | Global functions per type × `value`/`in`/`out`/`inout` | Pattern B | Int/Float/Bool Function parameter modes; math-struct **Function** axis (aligned method names) |
| `uclass-property-family` | One `UCLASS` Actor, `UPROPERTY` per width | **Must** stay Pattern D `VerifyByPath` / `FPropertyBindingPath`. Script getters SHALL NOT replace the C++ property taxonomy check | Int/Float/Bool/FString Property declaration defaults, write round-trip, boundaries |
| `ufunction-width-product` | `UFUNCTION` per width on a script Actor | Pattern C `FFunctionInvoker` | `UFunctionAllIntegerWidthsReflectAndInvoke` |
| `container-element-product` | Same container op with substituted element/key types | Pattern B or D depending on UPROPERTY | `TArrayFString`/`TArrayFVector`/`TMapKeyTypes`/`TSetElementTypes` |
| `compile-fail-product` | Homogeneous illegal declarations | `compile` expect failure + diagnostic substring | Nested-container 🚫 family; bool unsupported `&\|^` if it is one template |

Unique named methods, World/environment, and one-off diagnostics are **not** templates.

## Domain classification (18 matrices)

| Domain | Generate? | Generate | Keep authored |
|---|---|---|---|
| **01 basic types** | **Yes for family × axis** | Int/Float/Bool Property widths; Expression operators/conversions/literals; Function value/in/out/inout; UFUNCTION all-widths | FString **methods** (`Len`, `Find`, `Split`, `Format`); unique 🚫 inventories that are not one template; Bool-in-control-flow **story** |
| **02 math structs** | **Partial** | Shared **Function** parameter-mode / return / UFUNCTION **shape** across FVector…FTransform | Expression/method catalogs (`Dot`, `Cross`, `Normalize`, `RotateVector`) — API-specific oracles |
| **03 containers** | **Partial** | Element/key **type** matrices | `TArray.Sort`, `FindOrAdd`, iterator stories, nested-container **unique** diagnostics (the 🚫 *family* may use `compile-fail-product`) |
| **04 object refs** | Later / hybrid | Handle/weak/soft **type** matrix if it is substitution | GC uniqueness, lifetime |
| **05 UCLASS** | Later / hybrid | Specifier permutation if tabular | Lifecycle, default components |
| **06 USTRUCT** | Later / hybrid | Member-width tables | Unique struct stories |
| **07 macros / enum / UFUNCTION / interface** | Later / hybrid | Flag permutations | Unique meta / interface stories |
| **08 delegates** | Later / hybrid | Signature type matrix | Bind/execute/World stories |
| **09 control flow** | **Mostly authored** | TypeConversion **width** products | `ForBasic`, switch, mixin, preprocessor, namespace |
| **10 components** | **Authored** | — | Scene/Primitive lifecycle |
| **11 timer/async** | **Authored** | — | Latent / timer |
| **12 input** | **Authored** | — | Enhanced Input |
| **13 physics** | **Authored** | — | traces / CMC |
| **14 widget** | **Authored** | — | UMG |
| **15 networking** | **Authored** | — | RPC / replication |
| **16 assets/save** | **Authored** | — | SaveGame / asset literals |
| **17 debug/logging** | **Authored** (error-message **families** may later use compile-fail-product) | — | unique diagnostics |
| **18 misc** | **Authored** | — | CVar / AnimInstance |

## Identity and retirement

`coverage-matrix.md` stays the scenario index. A generated leaf MUST carry the matrix scenario name and the retiring `TEST_METHOD` (for example `ArithmeticOperators`). Do not grow a second undocumented matrix.

Existing Coverage CQTest stays green until a generated slice dual-runs. Only then may that `TEST_METHOD` (or file slice) be removed, and the matrix **Coverage Test Method** column updated to the DataDriven product prefix.

v1 of the harness (`integral-bitwise`) does **not** migrate Coverage. Wave B of this same change starts with IntExpression `expression-product` (Pattern B, existing `executeInt`). Pattern D `uclass-property-family` waits until the harness has spawn + `VerifyByPath` observations.

Do not check in `Fixtures/Generated/int8_*.as`…`uint64_*.as`. Dump numbered source on failure.

Generated Coverage AngelScript is still Layer 1 of the test corpus. It can request derived StaticJIT the same way as `integral-bitwise` (explicit `typed-ast-generate` case, temp `Script/` materialize). See `static-jit-from-test-corpus.md`. Wave B first slice stays `vm` only.
