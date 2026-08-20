# Subject catalog (library + tests)

Companion to `subject-ladder.md`. This is the expanded map: every subject id, which existing C++ to retarget, which questions are in scope, what not to duplicate.

**Axes (unchanged):** subject = AS library slot; question = what the test proves. Do not cartesian. CQTest is the incubator; after a feature is stable, graduate onto the COMPLEX session (catalog and/or `Session.World()` / `Session.Blueprint()`). See `research/framework-lanes.md`.

**Questions in-scope legend:** `F` form (`surface-form`), `B` bind (`bind-contract`), `M` matrix (`behavior-matrix`), `W` world (`world-story`), `R` reload (`reload-generation`), `P` profile (`same-as-profile`). Native-fork is implied for Language only. Host-machinery has no library subject except DAP MARK under `Host`.

---

## 1. Language

Library: `Fixtures/Language/<Theme>/` or `Fixtures/Language/<Theme>/<Child>/`

Parents `Language.Syntax`, `Language.Operators`, `Language.ControlFlow`, `Language.Literals` are folders, not dump leftover ids. New fixtures use a **leaf**. Packed/legacy files that still mix children MAY keep the parent id until extract. Full leaf tables: `subject-ladder.md` § Language band in detail.

### 1a. Syntax leaves (required)

| Id | Library dir | In scope | Today | Stop feeding |
|---|---|---|---|---|
| `Language.Syntax.Comments` | `Syntax/Comments/` | F | Misc `Comments_*` | — |
| `Language.Syntax.Keywords` | `Syntax/Keywords/` | F | Misc `Keywords_*` (`this`/`final`/`override`) | `UCLASS(Abstract)` → `Definitions.UClass`; `const` method → `Language.Const` |
| `Language.Syntax.Class` | `Syntax/Class/` | F | Native SDK Declarations; **not** TypeDeclaration `Class_*` | TypeDeclaration `class AFoo : AActor` / `UCLASS()` → `Definitions.UClass` |
| `Language.Syntax.Struct` | `Syntax/Struct/` | F | TypeDeclaration plain `struct` (no `USTRUCT`) | `USTRUCT()` → `Definitions.UStruct` |
| `Language.Syntax.Enum` | `Syntax/Enum/` | F | TypeDeclaration enum without `UENUM` | `UENUM()` → `Definitions.UEnum` |
| `Language.Syntax.Interface` | `Syntax/Interface/` | F | TypeDeclaration `Interface_Mixed` (`#if 0` / negatives) | `UINTERFACE` → `Definitions.UInterface` |
| `Language.Syntax.Function` | `Syntax/Function/` | F, M | TypeDeclaration `Function_*`; Native SDK Functions | `UFUNCTION()` → `Definitions.UFunction` |
| `Language.Syntax.Variable` | `Syntax/Variable/` | F, M | TypeDeclaration `Variable_*`; Native SDK Variables | `UPROPERTY()` → `Definitions.UProperty` |
| `Language.Syntax.Reference` | `Syntax/Reference/` | F, M | Native SDK References; TypeDeclaration `RefVar` | — |
| `Language.Syntax.Constructor` | `Syntax/Constructor/` | F, M | Native SDK Constructors; plain struct/class ctor | UClass generated ctor → `Definitions.UClass` |
| `Language.Syntax.Destructor` | `Syntax/Destructor/` | F, M | Native SDK Destructors | — |
| `Language.Syntax.Block` | `Syntax/Block/` | F | Misc nested `{ }` | unmatched brace → `EdgeCases` |
| `Language.Syntax.Exceptions` | `Syntax/Exceptions/` | F | Native SDK Exceptions (reject) | — |
| `Language.Syntax.EdgeCases` | `Syntax/EdgeCases/` | F | Misc punctuation leftovers | operator precedence → `Language.Operators.Precedence`; UFunction / Tick |

Do not invent `Language.Syntax.Funcdef` until a test exists. Do not dump Operators or Actor Tick here.

### 1b. Operators / ControlFlow / Literals leaves

| Id | Library dir | In scope | Today | Stop feeding |
|---|---|---|---|---|
| `Language.Operators.Arithmetic` | `Operators/Arithmetic/` | F, M, P | Syntax `Arithmetic_*`; Coverage Int/Float Expression | Third execute copy; new Syntax packed `ExpectGlobalInts` |
| `Language.Operators.Bitwise` | `Operators/Bitwise/` | F, M, P | Syntax `Bitwise_*` | same |
| `Language.Operators.Logical` | `Operators/Logical/` | F, M, P | Syntax `Logical_*` | same |
| `Language.Operators.Comparison` | `Operators/Comparison/` | F, M, P | Syntax `Comparison_*` | same |
| `Language.Operators.Assignment` | `Operators/Assignment/` | F, M, P | Syntax `Assignment_*` | same |
| `Language.Operators.Ternary` | `Operators/Ternary/` | F, M, P | Syntax `Ternary_*` | same |
| `Language.Operators.Overload` | `Operators/Overload/` | F, M | Syntax OperatorOverload | — |
| `Language.Operators.Precedence` | `Operators/Precedence/` | F, M | Syntax Operators `EdgeCases`; Native Expressions precedence | — |
| `Language.ControlFlow.If` | `ControlFlow/If/` | F, M, P | Syntax `IfElse_*`; Coverage Conditional | same as operators |
| `Language.ControlFlow.For` | `ControlFlow/For/` | F, M, P | Syntax `For_*` | same |
| `Language.ControlFlow.While` | `ControlFlow/While/` | F, M, P | Syntax `While_*` | same |
| `Language.ControlFlow.Switch` | `ControlFlow/Switch/` | F, M, P | Syntax `Switch_*` | same |
| `Language.ControlFlow.Jump` | `ControlFlow/Jump/` | F, M, P | Syntax `BreakContinue_*`, `Return_Mixed` | same |
| `Language.ControlFlow.Foreach` | `ControlFlow/Foreach/` | F, M, P | Syntax `Foreach_*`; Native Foreach | same |
| `Language.Literals.Integer` | `Literals/Integer/` | F, M | Coverage Int literal rows | `Language.Int` as a type subject |
| `Language.Literals.Float` | `Literals/Float/` | F, M | Coverage Float literal rows | same |
| `Language.Literals.Bool` | `Literals/Bool/` | F, M | Coverage Bool literal rows | same |
| `Language.Literals.FString` | `Literals/FString/` | F, M | Syntax FString literals; Coverage FString; Functional interpolation | Former id `Language.FString`; method tables stay M on this id |

Packed modules that still mix children MAY keep parent `Language.Operators` / `Language.ControlFlow` until extract.

### 1c. Language siblings (not under Syntax)

| Id | Library dir | In scope | Today | Stop feeding |
|---|---|---|---|---|
| `Language.Access` | `Access/` | F | Syntax AccessSpecifier **visibility** (`public`/`private`/`protected`) | custom `access Name = …` → `Feature.Access` |
| `Language.Casting` | `Casting/` | F, M | Syntax Casting; Coverage TypeConversion; Native Conversions | — |
| `Language.Namespace` | `Namespace/` | F, M | Coverage Namespace; TypeDeclaration `Namespace_Mixed` | Namespaced USTRUCT conflict → `Definitions.UStruct` |
| `Language.Preprocessor` | `Preprocessor/` | F | Coverage Preprocessor **script-facing** rows | Compiler/Preprocessor **row/column** C++ stays host/pipeline |
| `Language.Const` | `Const/` | F, M | Coverage Const; Misc const method | — |

`int` / `float` / `bool` **as types** (property/function positions) stay Coverage 01 under question `M` with subject `Language.Operators.Arithmetic` (or the operator leaf in play) — do not invent `Language.Int`. Generate slices (harness Wave B) are still `Language.Operators.*` products.

---

## 2. Definitions (reflected types, no spawn)

Library: `Fixtures/Definitions/<Name>/`

| Id | Library dir | In scope | Today | Notes |
|---|---|---|---|---|
| `Definitions.UEnum` | `UEnum/` | F, B, M, R, P | Coverage UEnum; Syntax TypeDeclaration enum-with-U | No World |
| `Definitions.UStruct` | `UStruct/` | F, B, M, R, P | Coverage UStruct/UStructMember; Syntax NamespacedUSTRUCTNegative; Bindings UStruct smoke | World only if the struct is exercised on a live UObject (still this id + W) |
| `Definitions.UClass` | `UClass/` | F, B, M, R, P, **W** | Coverage UClass/ClassFeatures/ClassLifecycle (declaration); Syntax TypeDeclaration UCLASS; Generator ScriptClass **shape** | Compile without spawn stays F/M; **instance runtime is W on this same id** |
| `Definitions.UFunction` | `UFunction/` | F, M, R, **W** | Syntax UFunction; Coverage UFunction specifier/dispatch matrices | BlueprintOverride that **runs Tick** → this id + W, not `World.Actor` |
| `Definitions.UProperty` | `UProperty/` | F, M, R, **W** | Syntax UProperty; Coverage UClassProperty; Functional Property **meta** | Live property on a spawned object → this id + W; accessor removal → `Feature.PropertyAccess`; class-body `default` → `Feature.Default` |
| `Definitions.UInterface` | `UInterface/` | F, M, R, **W** | Coverage UInterface; Functional Interface | Native bind is B/M; **instance** is W on this id |
| `Definitions.Meta` | `Meta/` | F, M | Coverage Macros / MetaSpecifier | Not World |

Generator `ASClass` / `ASFunction` / `ASStruct` **C++ object** tests (construction, ProcessEvent, metadata structs) are question `reload-generation` or `host-machinery` on these subjects — they may not need a Fixtures file if the oracle is the generator API, not a script body.

---

## 3. Containers (UE `T*` types)

Library: `Fixtures/Containers/<Name>/`

Not dialect syntax. `TOptional` and pointer handles live here because they are UE templates.

| Id | Library dir | In scope | Today | Notes |
|---|---|---|---|---|
| `Containers.TArray` | `TArray/` | F, B, M, P, **W** | Syntax Container TArray; Coverage TArray; Bindings TArray smoke | Nesting 🚫 stays M negative; **UPROPERTY on spawned object → W on this id** |
| `Containers.TMap` | `TMap/` | F, B, M, P, **W** | Coverage TMap; Bindings Map smoke | same |
| `Containers.TSet` | `TSet/` | F, B, M, P, **W** | Coverage TSet; Bindings Set smoke | same |
| `Containers.TOptional` | `TOptional/` | F, M, **W** | Syntax Container TOptional | Wrapper, still this band |
| `Containers.TSubclassOf` | `TSubclassOf/` | F, B, M, **W** | Syntax SmartPointer; Coverage Handles | Spawn-from-class in World → W |
| `Containers.TWeakObjectPtr` | `TWeakObjectPtr/` | F, B, M, **W** | Coverage WeakReference | Live object → W |
| `Containers.TSoftObjectPtr` | `TSoftObjectPtr/` | F, B, M, **W** | Coverage SoftReference | Live resolve → W |
| `Containers.TObjectPtr` | `TObjectPtr/` | F, B, M, **W** | Coverage Handle / TObjectPtr | Live object → W |

Do not file Delegates, DefaultComponent, or Attach trees here.

---

## 4. Feature (Unreal AngelScript dialect)

Library: `Fixtures/Feature/<Name>/`

Syntax this product added on top of vanilla AngelScript. Not `UCLASS`/`UFUNCTION` macros (those are Definitions). Live create/Tick/attach-tree keeps this Feature id + `world-story`; do not retarget to `World.Actor` / `World.Component`. `asset … of` is Feature, not `Gameplay.Assets`. `RootComponent` / `Attach=` / `OverrideComponent=` are `Feature.Attach`, not `Feature.DefaultComponent`.

| Id | Library dir | In scope | Today | Notes |
|---|---|---|---|---|
| `Feature.Mixin` | `Mixin/` | F, **W** | Syntax Mixin; Coverage Mixin; Functional ActorMixin | Compile-only = F; live mixin Actor = W; `#if 0` not live |
| `Feature.Delegates` | `Delegates/` | F, B, M, R, **W** | Syntax DelegateEvent; Coverage Delegate/Event; Functional Delegate | Broadcast-on-Actor → this id + W |
| `Feature.DefaultComponent` | `DefaultComponent/` | F, M, R, **W** | Syntax DefaultComponent **create** rows; Coverage UClassDefaultComponent create | `UPROPERTY(DefaultComponent)` (+ `ShowOnActor`). Attach tree → `Feature.Attach` |
| `Feature.Attach` | `Attach/` | F, M, R, **W** | Syntax DefaultComponent attach/override rows; Coverage Root/Attach/Socket/Override matrices | `RootComponent`, `Attach=`, `AttachSocket=`, `OverrideComponent=`. Not `World.Component` |
| `Feature.PropertyAccess` | `PropertyAccess/` | F, **W** | Syntax PropertyAccessor; Native Properties | `UPROPERTY()` → `Definitions.UProperty`; live GetX = W |
| `Feature.Inheritance` | `Inheritance/` | F, M, R, **W** | Functional Inheritance; Coverage class features inheritance | Compile override = F/M; Tick/EndPlay order = W on **this id** |
| `Feature.Asset` | `Asset/` | F, M, R | Coverage LiteralAsset | `asset Name of Type { }`. `UDataAsset` subclass → `Definitions.UClass`; `Load*` → `Gameplay.Assets`; no `World.Asset` |
| `Feature.Default` | `Default/` | F, M, **W** | Syntax DefaultStatement **attribute** rows | Function param defaults → `Language.Syntax.Function`; `UPROPERTY()` → `Definitions.UProperty` |
| `Feature.Access` | `Access/` | F | Syntax AccessSpecifier `access` keyword rows | `public` / `private` / `protected` stay `Language.Access` |

Former ids: `Language.Mixin`, `Language.PropertyAccess`, `Composition.Delegates`, `Composition.DefaultComponent`, `Composition.Inheritance`. LiteralAsset used to sit under `Gameplay.Assets`.

---

## 5. World (host objects + runtime overlay)

Library: `Fixtures/World/<Name>/` only when the `.as` **is** a host object. Runtime of other subjects still lives under their own folders; the World **driver** loads those files. `World.Subsystem` is a parent folder. `World.Actor` is one leaf — BeginPlay/Tick/EndPlay are how you test it (`subject-ladder.md` § How to test World.Actor).

`world-story` is the main place to cover **full-name** AngelScript runtime (see `subject-ladder.md` § World-run). Do not collapse those tests into `World.Actor`.

| Id | Library dir | In scope | Today | How to test |
|---|---|---|---|---|
| `World.Actor` | `Actor/` | W, R | Functional Actor Lifecycle / Spawn / Interaction **when the oracle is the Actor** | `FAngelscriptTestWorld`: Spawn → BeginPlay → `DispatchActorTick` × N → DestroyAndDrain. Not `World.Actor.Tick`. Pawn/Character still this id |
| `World.Component` | `Component/` | W, R | Functional Component lifecycle | register / Tick / destroy as the Component host |
| `World.Subsystem.World` | `Subsystem/World/` | W | Functional Subsystem World | `UScriptWorldSubsystem` Initialize/Tick/Deinitialize |
| `World.Subsystem.GameInstance` | `Subsystem/GameInstance/` | W | Functional Subsystem GI | `UScriptGameInstanceSubsystem` |
| `World.Subsystem.LocalPlayer` | `Subsystem/LocalPlayer/` | W | Bindings LocalPlayer (B); live = W | `UScriptLocalPlayerSubsystem` |
| `World.Subsystem.Engine` | `Subsystem/Engine/` | W | Bindings smoke may be B | `UScriptEngineSubsystem` |
| `World.Subsystem.Editor` | `Subsystem/Editor/` | W | Editor module tests | `UScriptEditorSubsystem` |
| `World.Blueprint` | `Blueprint/` | W, R | Functional Blueprint child / Impact | spawn the BP child |
| `World.Widget` | `Widget/` | W or M-ceiling | Functional BindWidget; Coverage Widget (G7) | BindWidget / slate tree |

`World.Subsystem` is a parent folder. Packed Functional `AngelscriptSubsystemTests.cpp` MAY keep id `World.Subsystem` until extract. Attach trees stay `Feature.Attach`. Mixin/Timer/UFunction on a spawned Actor keep those full names — see the retarget table in `subject-ladder.md` § How to test World.Actor.

World **drivers** load `Definitions/UClass/...`, `Feature/DefaultComponent/...`, `Containers/TArray/...` instead of pasting a second class body. Thin `World.Actor` wrappers only for Tick-order counters.

Coverage 10 Component Tick rows should not grow as a substitute for Feature/World `world-story` (G9).

---

## 6. Gameplay (bound gameplay APIs / environment)

Library: `Fixtures/Gameplay/<Name>/` when the AS is reusable; Bindings/FunctionLibraries smokes may stay inline.

Not the GameplayTags plugin (`Optional.GameplayTags`). `World.Widget` is BindWidget; `Gameplay.Widget` is UMG RuntimeApi.

| Id | In scope | Today | Library? |
|---|---|---|---|
| `Gameplay.FMath` | B, M, P — **blocked** | Bindings Math; Coverage MathNamespaceFunctions; FunctionLibraries Math; Syntax MathModule (`Math.*`) | **Do not extract** until `improve-as-library-namespace-canonicalization` archives. Then `FMath::` only; no `Math::` / `MathLibrary::` positives |
| `Gameplay.FVector` | B, M, P | Coverage 02 FVector | Mixin on `FVector`; not `FMath::`. Wait for FMath change if the same cpp still calls `Math::` |
| `Gameplay.FRotator` | B, M, P | Coverage 02 FRotator | same |
| `Gameplay.FQuat` | B, M, P | Coverage 02 FQuat | same |
| `Gameplay.FTransform` | B, M, P | Coverage 02 FTransform | same |
| `Gameplay.FLinearColor` | B, M, P | Coverage 02 FLinearColor | same |
| `Gameplay.FVector2D` | B, M, P | Coverage 02 FVector2D | same |
| `Gameplay.Input` | B, M | Coverage Input; Bindings Input/EnhancedInput; FunctionLibraries Input | Unique mapping scripts yes |
| `Gameplay.Physics` | B, M, W-ceiling | Coverage Physics; Bindings WorldCollision; FunctionLibraries HitResult/WorldCollision | Headless trace = M |
| `Gameplay.Widget` | B, M | Coverage Widget RuntimeApi; FunctionLibraries Widget | Distinct from `World.Widget` BindWidget |
| `Gameplay.Net` | F, M | Coverage Networking; Generator ASClass Replication | Real multi-machine not headless |
| `Gameplay.Assets` | M | Coverage AssetLoading; FunctionLibraries AssetManager | Not LiteralAsset (`Feature.Asset`); not `UDataAsset` subclasses (`Definitions.UClass`) |
| `Gameplay.Timer` | M, W | Coverage Timer; Functional ActorTimer | Timer on Actor → also W |
| `Gameplay.Debug` | M | Coverage Debug/Logging/ErrorHandling | — |
| `Gameplay.CVar` | M | Coverage CVar | — |
| `Gameplay.Anim` | M-ceiling | Coverage AnimInstance; Functional Animation notifies | Asset-free ceiling |
| `Gameplay.Save` | M | Coverage SaveGame | — |
| `Gameplay.Material` | M | Coverage Material; Functional Rendering DynamicMaterial | — |

---

## 7. Optional and host

| Id | Question | Today |
|---|---|---|
| `Optional.GameplayTags` | B, M, W as needed | `AngelscriptGameplayTagsTest` |
| `Optional.GAS` | B, M, W as needed | `AngelscriptGAS` tests |
| `Host` | `host-machinery` | Cache store/codec, StaticJIT packager, RuntimeJIT factory, Core engine, Dump, FileSystem, Debugger DAP MARK, Validation, Performance harness, UHTTool, Generator **planner graph** |

`Host` is not an AS library band. DAP scripts later: `Fixtures/Debugger/` still subject `Host` (do not add `Host.Dap` until the Debugger corpus change).

---

## 8. Existing-folder cheat sheet

### Syntax/ → subject (extract later)

| File | Subject | Question now |
|---|---|---|
| Operators, OperatorOverload | `Language.Operators.*` | F + leftover M |
| ControlFlow | `Language.ControlFlow.*` | F + leftover M |
| Misc `Comments_*` | `Language.Syntax.Comments` | F |
| Misc `Keywords_*` | `Language.Syntax.Keywords` | F |
| Misc nested blocks | `Language.Syntax.Block` | F |
| Misc punctuation leftovers | `Language.Syntax.EdgeCases` | F |
| TypeDeclaration `Class_*` (`AActor` / `UCLASS`) | `Definitions.UClass` | F |
| TypeDeclaration plain `struct` | `Language.Syntax.Struct` | F |
| TypeDeclaration `USTRUCT` | `Definitions.UStruct` | F |
| TypeDeclaration enum without / with `UENUM` | `Language.Syntax.Enum` / `Definitions.UEnum` | F |
| TypeDeclaration `Interface_Mixed` | `Language.Syntax.Interface` | F |
| TypeDeclaration `Namespace_Mixed` | `Language.Namespace` | F |
| TypeDeclaration `Variable_*` | `Language.Syntax.Variable` (ref → `Reference`) | F/M |
| TypeDeclaration `Function_*` | `Language.Syntax.Function` | F |
| AccessSpecifier visibility | `Language.Access` | F |
| AccessSpecifier `access` keyword | `Feature.Access` | F |
| Casting | `Language.Casting` | F |
| FString | `Language.Literals.FString` | F |
| Mixin | `Feature.Mixin` | F |
| PropertyAccessor | `Feature.PropertyAccess` | F |
| Container | `Containers.TArray` | F |
| SmartPointer | `Containers.TSubclassOf` / `TWeakObjectPtr` / `TSoftObjectPtr` | F |
| DelegateEvent | `Feature.Delegates` | F |
| DefaultComponent | `Feature.DefaultComponent` | F |
| DefaultComponent Attach/Root/Override | `Feature.Attach` | F |
| DefaultStatement attribute `default` | `Feature.Default` | F |
| DefaultStatement function param defaults | `Language.Syntax.Function` | F |
| UFunction | `Definitions.UFunction` | F |
| UProperty | `Definitions.UProperty` | F |
| NamespacedUSTRUCTNegative | `Definitions.UStruct` | F |
| TypeDeclaration UCLASS/USTRUCT/UENUM | `Definitions.UClass` / `UStruct` / `UEnum` | F |
| MathModule | `Gameplay.FMath` after FMath canonicalization (`FMath::`) | F — **do not extract now** |

### Functional/ misfiled (not World)

| Dir | Retarget subject | Real question |
|---|---|---|
| Operators | `Language.Operators.*` | M |
| ControlFlow | `Language.ControlFlow.*` | M |
| Types / AutoType / interpolation | `Language.Literals.FString` / `Language.Casting` / `Language.Syntax.Variable` | M |
| Execution / Functions | often `Definitions.UFunction` or `Host` marshalling | M or Host |
| Handles | `Containers.TObjectPtr` | M |
| Property accessor/meta | `Feature.PropertyAccess` / `Definitions.Meta` | F/M |
| Misc | split per file; do not keep as World | — |
| Objects | `Definitions.UClass` or `Containers.TObjectPtr` | M |
| Types ScriptDataAsset | `Definitions.UClass` (`: UDataAsset`) | F/M — not `Feature.Asset` |

### Functional/Actor/ — how to test vs dump

Same spawned Actor. Subject follows the oracle (`subject-ladder.md` § How to test World.Actor).

| File | Keep as `World.Actor` + W | Retarget |
|---|---|---|
| Lifecycle (BeginPlay/Tick/EndPlay/Destroyed/Construction/Spawn) | yes | — |
| SpawnPatterns | yes | — |
| Interaction overlap/damage **as Actor callbacks** | yes | physics API tables → `Gameplay.Physics` |
| Mixin | no | `Feature.Mixin` + W |
| Timer | no | `Gameplay.Timer` + W |
| PropertyInterface UProperty/UFunction | no | `Definitions.UProperty` / `UFunction` + W |
| PropertyInterface interface methods | no | `Definitions.UInterface` + W |
| ScriptOverride inheritance dispatch | no | `Feature.Inheritance` + W |
| Interaction DelegateBroadcast | no | `Feature.Delegates` + W |
| Component Create/Get | no | `World.Component` + W |
| ComponentManagement attach | no | `Feature.Attach` + W |
| Lifecycle DefaultsAndHelperFunction | no | `Feature.Default` + W |

Keep **question** `world-story` (full subject names): Actor/Component/Subsystem/Blueprint/Widget **hosts** stay `World.*`; Inheritance Tick → `Feature.Inheritance`; Interface instance → `Definitions.UInterface`; Animation notifies → `Gameplay.Anim`; Rendering material on actor → `Gameplay.Material`; Upgrade if PIE → host or `World.Actor` as the story. Delegate/Handles on live objects → `Feature.Delegates` / `Containers.TObjectPtr`. Do not keep Operators/ControlFlow as World.

### Coverage/ → already matrices

Keep files; when extracting unique `.as`, drop them under the subject dirs above. Homogeneous int/float/bool expression → generate products (`Language.Operators.*`), Wave B.

### Bindings/ + FunctionLibraries/

Question is almost always `B`. Subject is the API family (`Gameplay.FVector`, `Containers.TArray`, …). **Do not** grow matrices here. **Do not** require a Fixtures file for a one-line bind smoke. Math bind smokes stay with `improve-as-library-namespace-canonicalization` until `FMath::` is the only public name.

---

## 9. Fill order (library then tests)

Do not build the whole tree empty. Extract when a sibling change needs the file.

1. **Language operators + control-flow** packed execute + negatives (Syntax Wave 1 / DataDriven OptionalEmpty already Language-adjacent). Split packed files onto `Language.Operators.*` / `Language.ControlFlow.*` leaves when extracting.
2. **Language.Syntax leaves** from Misc (`Comments` / `Keywords` / `Block` / `EdgeCases`) and TypeDeclaration **non-U** (`Struct` / `Enum` / `Function` / `Variable`). TypeDeclaration `Class_*` (`AActor` / `UCLASS`) goes with Definitions, not `Language.Syntax.Class`.
3. **Definitions UStruct / UClass / UFunction** forms (Syntax U* files are 1:1 snippets — easy library).
4. **Feature** DefaultComponent + Attach (Root/AttachSocket/Override) + Delegates + Mixin + Asset (`asset … of`) + Default + Access (Syntax already 1 method ≈ 1 snippet).
5. **Containers** TArray/TMap when reused across M and P.
6. **World-run of full names** — same library files, question `world-story`. Cover Feature leaves, Containers-on-UObject, Definitions instance, then World hosts. `World.Actor` is tested as spawn → BeginPlay → `DispatchActorTick` → DestroyAndDrain, not as extra child ids. Split packed Subsystem onto `World.Subsystem.*` when extracting. Do not paste new inline class bodies into `Functional/` as `World.Actor`.
7. **Gameplay** only when a unique scenario is reused across M and P (Physics/Timer/Input that need World use W on the Gameplay id). **Skip all Math / `FMath::` / FVector fixture extract** until `improve-as-library-namespace-canonicalization` is archived. Math FunctionLibrary **behavior** (WrapIndex, AngularDistance, …) stays `improve-as-runtime-function-libraries`; do not duplicate it here.

Native SDK stays `native-fork` on Language subjects and is **not** copied into Fixtures.

---

## 10. Complete library tree

Same tree as `subject-ladder.md` **Subject tree**. Folder on the left, subject id on the right. Parents `Language.Operators` / `ControlFlow` / `Syntax` / `Literals` and `World.Subsystem` are folders, not dump leftover ids. `World.Actor` is one leaf; how to test it is `subject-ladder.md` § How to test World.Actor.

```text
TestCorpus
├── Language                        vanilla grammar
│   ├── Operators
│   │   ├── Arithmetic              Language.Operators.Arithmetic
│   │   ├── Bitwise                 Language.Operators.Bitwise
│   │   ├── Logical                 Language.Operators.Logical
│   │   ├── Comparison              Language.Operators.Comparison
│   │   ├── Assignment              Language.Operators.Assignment
│   │   ├── Ternary                 Language.Operators.Ternary
│   │   ├── Overload                Language.Operators.Overload
│   │   └── Precedence              Language.Operators.Precedence
│   ├── ControlFlow
│   │   ├── If                      Language.ControlFlow.If
│   │   ├── For                     Language.ControlFlow.For
│   │   ├── While                   Language.ControlFlow.While
│   │   ├── Switch                  Language.ControlFlow.Switch
│   │   ├── Jump                    Language.ControlFlow.Jump
│   │   └── Foreach                 Language.ControlFlow.Foreach
│   ├── Syntax                      declaration grammar; not a dump
│   │   ├── Comments                Language.Syntax.Comments
│   │   ├── Keywords                Language.Syntax.Keywords
│   │   ├── Class                   Language.Syntax.Class          # not UCLASS
│   │   ├── Struct                  Language.Syntax.Struct         # not USTRUCT
│   │   ├── Enum                    Language.Syntax.Enum           # not UENUM
│   │   ├── Interface               Language.Syntax.Interface      # not UINTERFACE
│   │   ├── Function                Language.Syntax.Function       # not UFUNCTION
│   │   ├── Variable                Language.Syntax.Variable
│   │   ├── Reference               Language.Syntax.Reference
│   │   ├── Constructor             Language.Syntax.Constructor
│   │   ├── Destructor              Language.Syntax.Destructor
│   │   ├── Block                   Language.Syntax.Block
│   │   ├── Exceptions              Language.Syntax.Exceptions
│   │   └── EdgeCases               Language.Syntax.EdgeCases
│   ├── Literals
│   │   ├── Integer                 Language.Literals.Integer
│   │   ├── Float                   Language.Literals.Float
│   │   ├── Bool                    Language.Literals.Bool
│   │   └── FString                 Language.Literals.FString
│   ├── Access                      Language.Access
│   ├── Casting                     Language.Casting
│   ├── Namespace                   Language.Namespace
│   ├── Preprocessor                Language.Preprocessor
│   └── Const                       Language.Const
├── Definitions                     U* reflection; compile without spawn
│   ├── UEnum                       Definitions.UEnum
│   ├── UStruct                     Definitions.UStruct
│   ├── UClass                      Definitions.UClass
│   ├── UFunction                   Definitions.UFunction
│   ├── UProperty                   Definitions.UProperty
│   ├── UInterface                  Definitions.UInterface
│   └── Meta                        Definitions.Meta
├── Containers                      UE T* types
│   ├── TArray                      Containers.TArray
│   ├── TMap                        Containers.TMap
│   ├── TSet                        Containers.TSet
│   ├── TOptional                   Containers.TOptional
│   ├── TSubclassOf                 Containers.TSubclassOf
│   ├── TWeakObjectPtr              Containers.TWeakObjectPtr
│   ├── TSoftObjectPtr              Containers.TSoftObjectPtr
│   └── TObjectPtr                  Containers.TObjectPtr
├── Feature                         Unreal AngelScript dialect
│   ├── Mixin                       Feature.Mixin
│   ├── Delegates                   Feature.Delegates
│   ├── DefaultComponent            Feature.DefaultComponent       # create
│   ├── Attach                      Feature.Attach                 # Root / Attach / Override
│   ├── PropertyAccess              Feature.PropertyAccess
│   ├── Inheritance                 Feature.Inheritance
│   ├── Asset                       Feature.Asset                  # asset Name of Type
│   ├── Default                     Feature.Default                # default statements
│   └── Access                      Feature.Access                 # access Name = ...
├── World                           host objects only; not every spawn
│   ├── Actor                       World.Actor                    # lifecycle in a real World
│   ├── Component                   World.Component
│   ├── Subsystem                   parent; not a dump leftover
│   │   ├── World                   World.Subsystem.World
│   │   ├── GameInstance            World.Subsystem.GameInstance
│   │   ├── LocalPlayer             World.Subsystem.LocalPlayer
│   │   ├── Engine                  World.Subsystem.Engine
│   │   └── Editor                  World.Subsystem.Editor
│   ├── Blueprint                   World.Blueprint
│   └── Widget                      World.Widget                   # BindWidget
├── Gameplay                        engine gameplay APIs
│   ├── FMath                       Gameplay.FMath                 # BLOCKED
│   ├── FVector                     Gameplay.FVector
│   ├── FRotator                    Gameplay.FRotator
│   ├── FQuat                       Gameplay.FQuat
│   ├── FTransform                  Gameplay.FTransform
│   ├── FLinearColor                Gameplay.FLinearColor
│   ├── FVector2D                   Gameplay.FVector2D
│   ├── Input                       Gameplay.Input
│   ├── Physics                     Gameplay.Physics
│   ├── Widget                      Gameplay.Widget                # UMG RuntimeApi
│   ├── Net                         Gameplay.Net
│   ├── Assets                      Gameplay.Assets
│   ├── Timer                       Gameplay.Timer
│   ├── Debug                       Gameplay.Debug
│   ├── CVar                        Gameplay.CVar
│   ├── Anim                        Gameplay.Anim
│   ├── Save                        Gameplay.Save
│   └── Material                    Gameplay.Material
├── Optional
│   ├── GameplayTags                Optional.GameplayTags          # not Gameplay.Tags
│   └── GAS                         Optional.GAS
├── HotReload                       pairs; catalog names a theme
└── Debugger                        later MARK; question Host

Script/<Theme>/                         teaching; /Angelscript/Game/ -- not TestCorpus
```
