# Subject ladder (AS library)

Subject ids and folders use **Unreal PascalCase**. Most bands are `Band.Theme` (`Definitions.UClass`, `World.Actor`, `Containers.TArray`, `Feature.DefaultComponent`, `Gameplay.FVector`). Language nests a third segment when the theme has children (`Language.Syntax.Comments`, `Language.Operators.Arithmetic`, `Language.Literals.FString`). They match UE type prefixes (`U`/`A`/`F`/`T`) where a type exists. Question ids stay kebab-case (`surface-form`, `world-story`) — those are test questions, not types.

Expanded cheat sheet: `subject-catalog.md`.

Do not cartesian every subject against all eight questions.

## Overview

```text
  identity = ( subject , question )
             PascalCase   kebab-case
             library .as  what the test proves

  +-----------+-------------+------------+-----------+------------+
  | Language  | Definitions | Containers |  Feature  |  Gameplay  |
  | grammar   | U* reflect  | UE T*      | dialect   | game APIs  |
  +-----------+-------------+------------+-----------+------------+
        |            |            |            |            |
        +------------+-----+------+------------+------------+
                           |
                           v
              world-story  (FAngelscriptTestWorld)
              KEEP THE FULL SUBJECT NAME
                           |
                           v
              World/ = host objects only
              Actor | Component | Subsystem.* | Blueprint | Widget

  Optional/GameplayTags|GAS     (plugins, not Gameplay.Tags)
  HotReload/                    (before/after pairs)
  Debugger/                     (later MARK; question Host)
  Script/                       (teaching; /Angelscript/Game/ — not TestCorpus)
```

Questions (not folders):

```text
  native-fork        fork, no UE types
  surface-form       does this spelling compile / fail
  bind-contract      is the bind/UHT/mixin entry wired
  behavior-matrix    values / edges / combinations
  world-story        this subject RUNS in a real World
  reload-generation  script shape / generated UClass
  same-as-profile    same .as on VM / Cache / JIT
  host-machinery     cache, JIT ABI, dump, DAP, engine
```

Do not dump every spawn into `World.Actor`. `Gameplay.FMath` is blocked until FMath canonicalization archives.

## Runners (incubator vs COMPLEX framework)

The ladder is the **library**. The lasting runner is a plugin COMPLEX **session** with tools. CQTest is incubator only — not a ninth identity.

```text
  Fixtures/   subject tree   (.as once)
       │
       ▼
  FAngelscriptTestScriptCorpus
       │
       ├── Incubator  CQTest          WIP: TEST_METHOD + ASTEST_AS
       │
       └── House      COMPLEX session
           tools: Engine | Corpus | World | Blueprint
           catalog enumerator: cases.json × profiles
           C++-on-session: unique World/Blueprint until a catalog kind exists
```

| Question | After graduation |
|---|---|
| `native-fork` | Native / CTest |
| `surface-form` | Catalog `compile` (+ profiles when Cache/JIT matter) |
| `bind-contract` | C++ smoke; `.as` in `Fixtures/` |
| `behavior-matrix` | Catalog `vm` / generate products |
| `world-story` | **Session.World()** wrapping `FAngelscriptTestWorld` |
| `reload-generation` | Sibling enumerator on the same session tools |
| `same-as-profile` | Catalog `profiles[]` |
| `host-machinery` | C++ if no AS; DAP later as a session tool |

The framework SHALL NOT include CQTest headers. World is a **tool**, not an engine profile. Detail: `research/framework-lanes.md`, `test-as-data-driven-engine-harness/research/complex-framework.md`.

## Subject tree

Physical: `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/`
Virtual: `/Angelscript/Memory/TestCorpus/<path>.as`
Id = dotted path. Parents `Language.Operators` / `ControlFlow` / `Syntax` / `Literals` and `World.Subsystem` are folders, not dump leftover ids. `World.Actor` is one leaf; BeginPlay/Tick/EndPlay are how you test it, not child ids.

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

`world-story` loads a leaf above in `FAngelscriptTestWorld` and **keeps that leaf id**. `World.*` is only when the oracle is the host lifecycle.

`class AFoo : AActor { UFUNCTION() void F(); }` with **no spawn** is `Definitions.UClass`, not `World.Actor`.

Spawning that same class to prove **Tick/BeginPlay/EndPlay as the story** is `World.Actor` + `world-story`. Pawn/Character/Controller are still `World.Actor` when the story is that lifecycle.

Spawning it to prove **TArray / DefaultComponent / Attach tree / mixin / UFunction on a live instance** keeps that subject's **full name** + `world-story`. Do not collapse those runs into `World.Actor` just because a World exists.

`"hello" + 1` is `Language.Operators.Arithmetic` + `surface-form`. `int AddInt() { return 1+2; }` is the same leaf + `behavior-matrix`. A packed module that still mixes `+` and `&` MAY keep parent `Language.Operators` until extract.

Host `Script/` MAY reuse the same PascalCase theme names. Do not serve teaching files from TestCorpus.

## Ladder

| Band | Subject ids | What the `.as` is | Default questions | Needs World? |
|---|---|---|---|---|
| Language | `Language.Operators.*`, `Language.ControlFlow.*`, `Language.Syntax.*`, `Language.Literals.*`, plus `Language.Access`, `Language.Casting`, `Language.Namespace`, `Language.Preprocessor`, `Language.Const` | vanilla grammar | `native-fork`, `surface-form`, `behavior-matrix`, `same-as-profile`; **W** only if the construct must run inside Tick/BeginPlay | Rare |
| Definitions | `Definitions.UEnum`, `Definitions.UStruct`, `Definitions.UClass`, `Definitions.UFunction`, `Definitions.UProperty`, `Definitions.UInterface`, `Definitions.Meta` | reflected types | `surface-form`, `bind-contract`, `behavior-matrix`, `reload-generation`; **W required** for UClass/UFunction/UInterface **instance** runtime | UClass/UFunction/UInterface yes; UEnum/Meta no |
| Containers | `Containers.TArray` … `Containers.TObjectPtr` | UE `T*` types | `surface-form`, `bind-contract`, `behavior-matrix`; **W required** when the type lives on a UObject | Yes as UPROPERTY / live handle |
| Feature | `Feature.Mixin`, `Feature.Delegates`, `Feature.DefaultComponent`, `Feature.Attach`, `Feature.PropertyAccess`, `Feature.Inheritance`, `Feature.Asset`, `Feature.Default`, `Feature.Access` | Unreal AngelScript dialect | `surface-form`, `behavior-matrix`, `reload-generation`; **W** when the oracle needs a live Actor/CDO readback | Asset/Default/Access often headless |
| World | `World.Actor`, `World.Component`, `World.Subsystem.*`, `World.Blueprint`, `World.Widget` | World **host objects** (not a dump for every spawn) | `world-story`, `reload-generation` | **Yes** — this band *is* the host |
| Gameplay | `Gameplay.FMath` (**blocked**), `Gameplay.FVector`, `Gameplay.FRotator`, `Gameplay.FQuat`, `Gameplay.FTransform`, `Gameplay.FLinearColor`, `Gameplay.FVector2D`, `Gameplay.Input`, `Gameplay.Physics`, `Gameplay.Widget`, `Gameplay.Net`, `Gameplay.Assets`, `Gameplay.Timer`, `Gameplay.Debug`, `Gameplay.CVar`, `Gameplay.Anim`, `Gameplay.Save`, `Gameplay.Material` | gameplay APIs (not `Optional.GameplayTags`) | `bind-contract`, `behavior-matrix` or `world-story` | Often headless |
| Optional | `Optional.GameplayTags`, `Optional.GAS` | optional plugins | reuse questions | Varies |
| Host | `Host` | no reusable AS, or DAP MARK | `host-machinery` | n/a |

## World-run: full names (the main runtime coverage)

`world-story` is how most AngelScript **runtime** is proven: a real `FAngelscriptTestWorld`, spawn, Tick, attach, destroy. It is **not** a fifth World folder and **not** a dump into `World.Actor`.

Keep the library subject’s **full PascalCase name**. The World C++ driver (`Functional/` / `UAngelscriptTestSuite`) is only the question owner.

| Runtime to prove in World | Subject (full name) | Question |
|---|---|---|
| Actor BeginPlay / Tick / EndPlay / Destroyed / Construction / Spawn **as the story** | `World.Actor` | `world-story` |
| Component register / Tick / destroy **as the Component host** | `World.Component` | `world-story` |
| `UScriptWorldSubsystem` Initialize / Tick / Deinitialize | `World.Subsystem.World` | `world-story` |
| `UScriptGameInstanceSubsystem` | `World.Subsystem.GameInstance` | `world-story` |
| `UScriptLocalPlayerSubsystem` | `World.Subsystem.LocalPlayer` | `world-story` |
| `UScriptEngineSubsystem` | `World.Subsystem.Engine` | `world-story` |
| `UScriptEditorSubsystem` | `World.Subsystem.Editor` | `world-story` |
| AS parent + BP child instance | `World.Blueprint` | `world-story` |
| BindWidget host | `World.Widget` | `world-story` |
| Generated `UCLASS` methods on a spawned instance | `Definitions.UClass` | `world-story` |
| `UFUNCTION` / `BlueprintOverride` that runs on Tick | `Definitions.UFunction` | `world-story` |
| `UINTERFACE` on a live instance | `Definitions.UInterface` | `world-story` |
| `TArray` / `TMap` / `TSet` / `TOptional` as UPROPERTY on a spawned object | `Containers.TArray` (etc.) | `world-story` |
| `TObjectPtr` / `TWeakObjectPtr` / `TSoftObjectPtr` / `TSubclassOf` to live objects | matching `Containers.*` | `world-story` |
| mixin on a live Actor | `Feature.Mixin` | `world-story` |
| delegate / event broadcast on a spawned object | `Feature.Delegates` | `world-story` |
| DefaultComponent **created** / ticking | `Feature.DefaultComponent` | `world-story` |
| Root / Attach / AttachSocket / OverrideComponent **tree** after spawn | `Feature.Attach` | `world-story` |
| GetX/SetX on a live instance | `Feature.PropertyAccess` | `world-story` |
| inheritance Tick / EndPlay **order** | `Feature.Inheritance` | `world-story` |
| `asset Name of Type { }` getter used on a spawned object | `Feature.Asset` | `world-story` |
| class-body `default` values read on a spawned instance | `Feature.Default` | `world-story` |
| custom `access` enforced on a live instance | `Feature.Access` | `world-story` |
| Timer / Physics / Input / Net that need a World | matching `Gameplay.*` | `world-story` |
| GAS / GameplayTags on a live Actor | `Optional.GAS` / `Optional.GameplayTags` | `world-story` |

**Do not** require World for: `Language.Syntax.Comments`, Preprocessor forms, `Definitions.UEnum` / `Meta`, `Feature.Asset` / `Feature.Default` / `Feature.Access` compile-only, native-fork. Operators / control-flow **inside Tick** MAY use that Language leaf + `world-story`; headless Coverage execute stays `behavior-matrix`.

One `.as` file under the subject tree; the World driver loads it. Do not paste a second class body into `Functional/` and call it `World.Actor`.

## How to test World.Actor

This is the **question** for an Actor in a real World, not more subject ids. BeginPlay / Tick / EndPlay are oracles. Do **not** invent `World.Actor.Tick` or `World.Actor.Pawn`.

**Identity:** `(World.Actor, world-story)`  
**Driver:** COMPLEX `Session.World()` wrapping `FAngelscriptTestWorld` (CQTest only while incubating). Do not prove this with a Syntax compile of `class AFoo : AActor`. Do not encode Tick as an engine profile.

```text
SpawnActorOfClass          → UserConstructionScript
W.BeginPlay                → BeginPlay (once; harness is idempotent)
W.DispatchActorTick × N    → Tick count == N   (do not use World.Tick for exact counts)
W.DestroyAndDrain          → EndPlay + Destroyed, then read counters
```

| Oracle (what you assert) | Question | Today |
|---|---|---|
| UserConstructionScript on spawn | `world-story` | Functional Actor Lifecycle `ConstructionScript` |
| BeginPlay once / idempotent | `world-story` | `BeginPlay`, `BeginPlayIdempotent` |
| Tick ran N times | `world-story` | `Tick`, `TickRunsNTimes` |
| EndPlay reason / Destroyed / **order** | `world-story` | `DestroyLifecycleOrder`, `ReceiveEndPlay*` |
| Spawn / spawn params produce a live instance | `world-story` | SpawnPatterns |
| Actor events as the story (overlap, damage, multi-spawn) | `world-story` | Interaction (when the oracle is the Actor callback) |
| Same `.as` instance after reload | `reload-generation` | HotReload actor pair |
| Same `.as` on VM / Cache / JIT | `same-as-profile` | DataDriven; not a second Functional copy |

Pawn / Character / PlayerController / GameMode still use **`World.Actor` + `world-story`** when the story is spawn/Tick/EndPlay. Enhanced Input tables are `Gameplay.Input`. CharacterMovement tables are `Gameplay.Physics`. Possess as a **bind smoke** is `bind-contract`.

**Not `World.Actor`** — today’s `Functional/Actor/` dump. Spawned Actor is only the vehicle:

| Today | Real subject | Question |
|---|---|---|
| Mixin `SetActorQuat` / location helpers | `Feature.Mixin` | `world-story` |
| Timer pause / clear | `Gameplay.Timer` | `world-story` |
| UProperty / UFunction on a live actor | `Definitions.UProperty` / `Definitions.UFunction` | `world-story` |
| Interface methods on a live actor | `Definitions.UInterface` | `world-story` |
| Parent/child BlueprintEvent override | `Feature.Inheritance` | `world-story` |
| Delegate broadcast on an actor | `Feature.Delegates` | `world-story` |
| `default` values read after spawn | `Feature.Default` | `world-story` |
| Create/Get/GetOrCreate Component | `World.Component` | `world-story` |
| Root / Attach / socket after spawn | `Feature.Attach` | `world-story` |
| Overlap as physics API, not Actor callback | `Gameplay.Physics` | `world-story` |

Other World hosts use the same pattern (one subject, `world-story`, `FAngelscriptTestWorld` or the matching subsystem context). `World.Subsystem` is a parent folder (`World` / `GameInstance` / `LocalPlayer` / `Engine` / `Editor`). `World.Component` is the Component **as host**. `World.Widget` is BindWidget. `World.Blueprint` is AS parent + BP child instance.

## World band (host ids)

| Subject id | What the `.as` is | How to test |
|---|---|---|
| `World.Actor` | Actor in a World as the story | section above |
| `World.Component` | Component as the host | register / Tick / destroy; not Attach tree |
| `World.Subsystem.World` | `: UScriptWorldSubsystem` | Initialize / Tick / Deinitialize |
| `World.Subsystem.GameInstance` | `: UScriptGameInstanceSubsystem` | same, GameInstance context |
| `World.Subsystem.LocalPlayer` | `: UScriptLocalPlayerSubsystem` | live host; Get() smoke is `bind-contract` |
| `World.Subsystem.Engine` | `: UScriptEngineSubsystem` | Initialize / Deinitialize |
| `World.Subsystem.Editor` | `: UScriptEditorSubsystem` | Editor tests |
| `World.Blueprint` | AS parent + BP child instance | spawn the child |
| `World.Widget` | BindWidget host | widget tree; UMG RuntimeApi → `Gameplay.Widget` |

Packed Functional `AngelscriptSubsystemTests.cpp` MAY keep parent id `World.Subsystem` until extract.

## Gameplay.FMath is blocked

Do **not** invent `Gameplay.Math` as a dump for `Math::` / `MathLibrary::` / FVector mixins.

Active sibling `improve-as-library-namespace-canonicalization` makes **`FMath::` the only public namespace** (breaking: no `Math::` / `MathLibrary::` aliases). Until that change is archived:

- Do not extract Math fixtures into TestCorpus.
- Do not add positive `Math::` or `MathLibrary::` library files.
- Do not apply Math rows of this map into `TestConventions` / examples as if `Math::` were current.
- Bindings/Coverage/FunctionLibraries Math tests stay with that FMath change (and `improve-as-runtime-function-libraries` Math **behavior**). This map does not steal those files.

After FMath archives, the subject id is `Gameplay.FMath` for `FMath::` namespace functions. Mixin methods on math structs are `Gameplay.FVector` / `FRotator` / `FQuat` / `FTransform` / `FLinearColor` / `FVector2D`, not `Gameplay.FMath`. Syntax `MathModule` (`Math.*` compile) retargets to `Gameplay.FMath` **after** the snippets call `FMath::`.

`Gameplay` is the band for engine gameplay APIs (Input, Physics, `FMath::`, math structs). GameplayTags and GAS stay `Optional.GameplayTags` / `Optional.GAS` — do not invent `Gameplay.Tags`.

## Language band in detail

`Language/` is vanilla grammar. It never owns `UCLASS`/`USTRUCT`/`UFUNCTION`/`UENUM`/`UINTERFACE`, DefaultComponent create, Attach trees, mixin, `asset … of`, class-body `default`, custom `access`, or GetX/SetX. Those are Definitions / Feature even if today’s C++ file is named `Syntax/`. `TArray` / `TObjectPtr` are `Containers`. Spawn/Tick of those subjects is still their full name + `world-story`, not a Language dump.

**Scaffold vs subject:** wrapping a keyword in `class AFoo : AActor` so `this` compiles does **not** move the test to `Definitions.UClass`. The subject is the thing the oracle is about (`this` → `Language.Syntax.Keywords`). A snippet whose oracle is “`UCLASS(Abstract)` is legal” is `Definitions.UClass`.

### Language.Syntax.* (required leaves)

`Language.Syntax` is a parent folder only. Do not add new fixtures directly under `Syntax/` and do not use `Language.Syntax` as a leftover dump for operators, UFunction, or Actor Tick.

| Subject id | What the `.as` is | Today | Not this id |
|---|---|---|---|
| `Language.Syntax.Comments` | `//`, `/* */`, inline | Misc `Comments_*` | — |
| `Language.Syntax.Keywords` | `this`, `final`, `override`, `abstract`, `shared`; rejected `Super::` | Misc `Keywords_*` | `const` method → `Language.Const`; `UCLASS(Abstract)` → `Definitions.UClass` |
| `Language.Syntax.Class` | plain `class Foo { }` **without** `UCLASS` / required `AActor` | Native SDK Declarations; **not** TypeDeclaration `Class_*` (those inherit `AActor`) | `UCLASS()` or `class AFoo : AActor` as a UE type → `Definitions.UClass` |
| `Language.Syntax.Struct` | plain `struct FFoo { int X; }` **without** `USTRUCT` | TypeDeclaration `StructP_Basic` / methods / ctor | `USTRUCT()` → `Definitions.UStruct` |
| `Language.Syntax.Enum` | plain `enum` / `enum class` **without** `UENUM` | TypeDeclaration Enum non-U rows | `UENUM()` → `Definitions.UEnum` |
| `Language.Syntax.Interface` | `interface` keyword (this fork mostly negatives / `#if 0`) | TypeDeclaration `Interface_Mixed` | `UINTERFACE` / `Implements` on a UClass → `Definitions.UInterface` |
| `Language.Syntax.Function` | global/local function form, arity, default args, empty body | TypeDeclaration `Function_*`; Native SDK Functions; Misc empty func | `UFUNCTION()` → `Definitions.UFunction` |
| `Language.Syntax.Variable` | locals, `auto`, init, name rules | TypeDeclaration `Variable_*`; Native SDK Variables | `UPROPERTY()` → `Definitions.UProperty`; `int&` form → `Language.Syntax.Reference` |
| `Language.Syntax.Reference` | `int&`, `in` / `out` / `inout` | Native SDK References; TypeDeclaration `RefVar` | — |
| `Language.Syntax.Constructor` | ctor declaration / overload / visibility on a **plain** type | Native SDK Constructors; TypeDeclaration struct/class ctor **without** U* | UClass ctor as generated type → `Definitions.UClass` |
| `Language.Syntax.Destructor` | destructor declaration / exit | Native SDK Destructors | — |
| `Language.Syntax.Block` | nested `{ }`, empty compound statement | Misc nested blocks | unmatched brace → `Language.Syntax.EdgeCases` |
| `Language.Syntax.Exceptions` | `try` / `catch` (fork rejects) | Native SDK Exceptions | — |
| `Language.Syntax.EdgeCases` | leftover punctuation only: missing `;`, unmatched `(`/`{`, stray tokens | Misc `EdgeCases_Negative`; **not** operator precedence | long `1+2+3` chain → `Language.Operators.Precedence` |

Do **not** invent `Language.Syntax.Funcdef` / `Typedef` until a real test exists. Native SDK `Properties/` is `Feature.PropertyAccess` (dialect GetX/SetX / rejected `property`) or `Definitions.UProperty`, not a Syntax dump. Native SDK `Inheritance/` of a plain `class B : A` is `Language.Syntax.Class`; UClass override graphs are `Feature.Inheritance`.

Default question for Syntax leaves: `surface-form`. Packed execute that only proves a declaration still compiles-and-returns (TypeDeclaration `Variable_Positive`) is `behavior-matrix` on the same leaf — do not add a new Syntax `ExpectGlobalInts` method for it.

### TypeDeclaration routing (today’s file is mixed)

`AngelscriptSyntaxTypeDeclarationTests.cpp` is **not** one subject. Split by oracle:

| Method / snippet | Subject |
|---|---|
| `Class_Positive` / `Class_Negative` (`: AActor`, `UCLASS()`, `UCLASS(Abstract)`) | `Definitions.UClass` |
| `StructP_USTRUCT` | `Definitions.UStruct` |
| `StructP_Basic` / methods / defaults / plain ctor | `Language.Syntax.Struct` |
| Enum with `UENUM` | `Definitions.UEnum` |
| Enum without `UENUM` | `Language.Syntax.Enum` |
| `Interface_Mixed` | `Language.Syntax.Interface` |
| `Namespace_Mixed` | `Language.Namespace` (sibling, not under Syntax) |
| `Variable_*` | `Language.Syntax.Variable` (ref row → `Language.Syntax.Reference`; const row may share `Language.Const`) |
| `Function_*` without `UFUNCTION` | `Language.Syntax.Function` |

### Language.Operators.* (preferred leaves)

Syntax `AngelscriptSyntaxOperatorsTests.cpp` already uses these method names. Prefer the leaf when extracting; a packed module that mixes `+` and `&` MAY keep parent `Language.Operators` until split.

| Subject id | Today |
|---|---|
| `Language.Operators.Arithmetic` | `Arithmetic_*`; Coverage Int/Float Expression |
| `Language.Operators.Bitwise` | `Bitwise_*` |
| `Language.Operators.Logical` | `Logical_*` |
| `Language.Operators.Comparison` | `Comparison_*` |
| `Language.Operators.Assignment` | `Assignment_*` |
| `Language.Operators.Ternary` | `Ternary_*` |
| `Language.Operators.Overload` | `AngelscriptSyntaxOperatorOverloadTests.cpp` |
| `Language.Operators.Precedence` | Operators `EdgeCases` (parens, chain, mix); Native SDK Expressions precedence |

Illegal operand (`"hello" + 1`) is `surface-form` on the matching leaf (usually Arithmetic). Packed execute is `behavior-matrix` or `same-as-profile`. Do not file under `Definitions.UClass` or `World.Actor`. Functional/`Operators/` (misfiled) retargets here.

### Language.ControlFlow.* (preferred leaves)

| Subject id | Today |
|---|---|
| `Language.ControlFlow.If` | Syntax `IfElse_*`; Coverage Conditional |
| `Language.ControlFlow.For` | Syntax `For_*`; Native SDK ForClause |
| `Language.ControlFlow.While` | Syntax `While_*` (do-while here) |
| `Language.ControlFlow.Switch` | Syntax `Switch_*`; Native SDK Switch* |
| `Language.ControlFlow.Jump` | Syntax `BreakContinue_*`, `Return_Mixed` |
| `Language.ControlFlow.Foreach` | Syntax `Foreach_*`; Native SDK Foreach/ |

Coverage 09 and Functional/`ControlFlow/` retarget to these leaves. Same form vs execute split as Operators.

### Language.Literals.* (required for new string/number form tests)

Former id `Language.FString` is now `Language.Literals.FString`. Do not invent `Language.Int` as a type subject.

| Subject id | Meaning | Today |
|---|---|---|
| `Language.Literals.Integer` | integer literal forms (`0x`, suffixes) | Coverage Int Expression literal rows |
| `Language.Literals.Float` | float literal forms | Coverage Float Expression literal rows |
| `Language.Literals.Bool` | `true` / `false` as literals | Coverage Bool Expression literal rows |
| `Language.Literals.FString` | FString / f-string **forms**; method tables stay matrix on this same id | Syntax FString `Literals_*`; Coverage FString; Functional interpolation |

`int` / `float` / `bool` **in property/function positions** stay Coverage generate products under `Language.Operators.Arithmetic` (or the operator leaf in play), question `behavior-matrix`.

### Language siblings (not under Syntax)

These already have dedicated files. Do not fold them into `Language.Syntax.*`.

| Subject id | Meaning | Today |
|---|---|---|
| `Language.Access` | `public` / `private` / `protected` | Syntax AccessSpecifier visibility rows. Custom `access Name = …` → `Feature.Access` |
| `Language.Casting` | Cast, implicit/explicit, nullptr | Syntax Casting; Coverage TypeConversion; Native SDK Conversions |
| `Language.Namespace` | `namespace`, `using` | Coverage Namespace; TypeDeclaration `Namespace_Mixed` |
| `Language.Preprocessor` | script-facing `#if` | Coverage Preprocessor **script-facing** rows (row/column C++ stays host) |
| `Language.Const` | `const` values / methods | Coverage Const; Misc `const` method |

Namespaced `USTRUCT` conflict → `Definitions.UStruct`. Mixin, GetX/SetX, `asset … of`, class-body `default`, custom `access`, DefaultComponent create, and Attach trees are `Feature`, not Language.

### Native SDK `AngelScriptSDK/Language/` → subject

Question is `native-fork` on these ids (no UE types).

| Native SDK dir | Subject |
|---|---|
| Operators | `Language.Operators.*` |
| ControlFlow, Foreach | `Language.ControlFlow.*` |
| Expressions | `Language.Operators.Precedence` / `Language.Literals.*` |
| Conversions | `Language.Casting` |
| Declarations | `Language.Syntax.Class` / `Struct` / `Enum` |
| Functions | `Language.Syntax.Function` |
| Variables | `Language.Syntax.Variable` |
| References | `Language.Syntax.Reference` |
| Constructors | `Language.Syntax.Constructor` |
| Destructors | `Language.Syntax.Destructor` |
| Exceptions | `Language.Syntax.Exceptions` |
| Inheritance (plain `class B : A`) | `Language.Syntax.Class` |
| Properties | `Feature.PropertyAccess` |
| Interactions | keep `native-fork`; do not invent a Syntax dump |

## Containers band

UE `T*` types used in script. Not dialect syntax. `TOptional` and the pointer family are filed here because they are template types, not because they are “arrays”.

| Subject id | Meaning | Today |
|---|---|---|
| `Containers.TArray` | `TArray` | Syntax Container; Coverage TArray; Bindings smoke |
| `Containers.TMap` | `TMap` | Coverage TMap; Bindings |
| `Containers.TSet` | `TSet` | Coverage TSet; Bindings |
| `Containers.TOptional` | `TOptional` | Syntax Container TOptional |
| `Containers.TSubclassOf` | `TSubclassOf` | Syntax SmartPointer; Coverage Handles |
| `Containers.TWeakObjectPtr` | `TWeakObjectPtr` | Coverage WeakReference |
| `Containers.TSoftObjectPtr` | `TSoftObjectPtr` | Coverage SoftReference |
| `Containers.TObjectPtr` | `TObjectPtr` | Coverage Handle |

Do not put Delegates, DefaultComponent, or Attach trees here.

## Feature band

Unreal AngelScript **dialect**: syntax this product added on top of vanilla AngelScript and on top of `UCLASS`/`UFUNCTION` macros. Compile forms are `surface-form`. Live runtime of a leaf keeps **the same full name** + `world-story`. `Feature.Asset` / `Feature.Default` / `Feature.Access` usually do not need a World.

| Subject id | Meaning | Today | Not this id |
|---|---|---|---|
| `Feature.Mixin` | `mixin` declaration | Syntax Mixin; Coverage Mixin; Functional ActorMixin if compile-only | `#if 0` as live fixtures |
| `Feature.Delegates` | delegate / event / multicast **forms** | Syntax DelegateEvent; Coverage Delegate/Event; Functional Delegate if no World | Live broadcast → **same id** + `world-story`, not `World.Actor` |
| `Feature.DefaultComponent` | `UPROPERTY(DefaultComponent)` **create** (`ShowOnActor` stays here) | Syntax DefaultComponent create rows; Coverage UClassDefaultComponent create | Attach tree → `Feature.Attach`; host Tick of a Component as such → `World.Component` |
| `Feature.Attach` | component **organization**: `RootComponent`, `Attach=`, `AttachSocket=`, `OverrideComponent=` | Syntax DefaultComponent attach/override rows; Coverage Root/Attach/Socket/Override matrices | `DefaultComponent` create-only → `Feature.DefaultComponent`; `SetupAttachment` as Component host story → `World.Component` |
| `Feature.PropertyAccess` | GetX/SetX; rejected `property` | Syntax PropertyAccessor; Native SDK Properties | `UPROPERTY()` meta → `Definitions.UProperty`; live GetX → same id + `world-story` |
| `Feature.Inheritance` | UClass override / chain **without Tick** | Functional Inheritance compile; Coverage class features inheritance | Plain `class B : A` → `Language.Syntax.Class`; Tick/EndPlay order → **same id** + `world-story`, not `World.Actor` |
| `Feature.Asset` | `asset Name of Type { }` literal-asset **spelling** | Coverage LiteralAsset | `class UFoo : UDataAsset` → `Definitions.UClass`; AssetManager `Load*` → `Gameplay.Assets`; do **not** invent `World.Asset` |
| `Feature.Default` | class-body `default` statements (`ProcessDefaults` / `__InitDefaults`) | Syntax DefaultStatement **attribute** rows | `UPROPERTY()` meta → `Definitions.UProperty`; function **parameter** defaults → `Language.Syntax.Function` |
| `Feature.Access` | custom `access Name = private, UFoo;` / `access:Name` | Syntax AccessSpecifier rows that use the `access` keyword | `public` / `private` / `protected` → `Language.Access` |

`UFUNCTION` specifiers including `BlueprintOverride` stay `Definitions.UFunction`. `BindWidget` is `World.Widget`. `UserConstructionScript` as the story is `World.Actor`. f-string is `Language.Literals.FString`. Feature is the extra dialect, not every UE macro.

## Two ways (same file, two questions)

| Kind | Example | Subject | Question |
|---|---|---|---|
| Definition | `class AFoo : AActor { UFUNCTION() void F(); }` never spawned | `Definitions.UClass` | `surface-form` / `behavior-matrix` |
| UClass runtime | same class spawned, methods run | `Definitions.UClass` | `world-story` |
| Actor lifecycle story | same spawn, oracle is BeginPlay/Tick/EndPlay **order** | `World.Actor` | `world-story` |
| Mixin helper on that Actor | same spawn, oracle is `SetActorQuat` | `Feature.Mixin` | `world-story` |
| Keyword on an AActor wrapper | `this.X = Val` | `Language.Syntax.Keywords` | `surface-form` |
| Plain struct | `struct FFoo { int X; }` | `Language.Syntax.Struct` | `surface-form` |
| Illegal op | `"hello" + 1` | `Language.Operators.Arithmetic` | `surface-form` |
| Packed execute | `int AddInt() { return 1+2; }` | `Language.Operators.Arithmetic` | `behavior-matrix` or `same-as-profile` |
| DefaultComponent create | `UPROPERTY(DefaultComponent) USceneComponent Root;` never spawned | `Feature.DefaultComponent` | `surface-form` |
| DefaultComponent live | same field created / ticking | `Feature.DefaultComponent` | `world-story` |
| Attach tree form | `Attach=Mesh`, `RootComponent`, `OverrideComponent=Mesh` | `Feature.Attach` | `surface-form` |
| Attach tree live | spawn, then parent/socket/override matches | `Feature.Attach` | `world-story` |
| Literal asset form | `asset MyFoo of UBar { }` | `Feature.Asset` | `surface-form` / `behavior-matrix` |
| `default` on a class | `default Health = 100;` | `Feature.Default` | `surface-form` |
| custom `access` rule | `access HealthAccess = private, UHealth;` | `Feature.Access` | `surface-form` |
| TArray form | `TArray<int> Xs;` | `Containers.TArray` | `surface-form` / `behavior-matrix` |
| TArray on spawned Actor | `UPROPERTY() TArray<int> Xs` mutated in Tick | `Containers.TArray` | `world-story` |

## Coverage 18 domains → subjects

| Coverage matrix | Subject |
|---|---|
| 01 expressions | `Language.Operators.*` / `Language.Literals.*` |
| 02 math structs | `Gameplay.FVector` / `FRotator` / `FQuat` / `FTransform` / … (not `Gameplay.FMath`) |
| 09 control flow / namespace / mixin / conversion | `Language.ControlFlow.*`, `Language.Namespace`, `Feature.Mixin`, `Language.Casting` |
| 05–07 UClass / UStruct / UEnum / UFunction / UInterface | `Definitions.*` |
| 03–04 containers / handles | `Containers.TArray` … `Containers.TObjectPtr` |
| 08 delegates | `Feature.Delegates` |
| 10 components | `Feature.DefaultComponent` create; `Feature.Attach` for Root/Attach/Socket/Override; `World.Component` when the story is the Component host |
| LiteralAsset | `Feature.Asset` (not `Gameplay.Assets`) |
| 11–18 gameplay APIs | `Gameplay.*` (not `Optional.GameplayTags`; not LiteralAsset) |
