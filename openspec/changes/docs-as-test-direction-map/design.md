## Context

Physical `AngelscriptTest/` themes (2026-08-18 counts): Native SDK 314 cpp, Cache 104, Coverage 90, StaticJIT 89, Bindings 88, Functional 52, Core 45, Generator 35, Compiler 34, HotReload 30, Syntax 19, plus Debugger/Preprocessor/RuntimeJIT/Dump/etc. Suites in `TestSuiteDefinitions.ps1` list many of these prefixes but **omit** `Angelscript.TestModule.Coverage` from `All`, even though Coverage is ~1022 methods.

`TestConventions.md` still mixes three different axes in one table: **host** (Runtime C++ / Editor / Native / UE World), **theme folder**, and **Bindings vs Coverage responsibility**. That is why Syntax grew Unreal dialect compile tables, Coverage grew language execute tables, and Bindings still attracts matrices.

Bindings-vs-Coverage is already specified (`refactor-bindings-test-layout`). Native SDK vs `FAngelscriptEngine` is already specified. DataDriven harness specifies the missing engine-profile axis. This design does not replace those records; it is the **author-facing routing layer** they all sit under.

## Goals / Non-Goals

**Goals:**

- Split authoring into two axes: **subject** (the AS library) and **question** (the unit test). The lasting runner is a plugin **COMPLEX framework** (session + tools). CQTest is incubator only (Decision 11–12). See `research/framework-lanes.md` and `test-as-data-driven-engine-harness/research/complex-framework.md`.
- Store reusable `.as` under a subject ladder (language: operators/syntax/control-flow → UENUM/USTRUCT/UCLASS definitions → Actor/Component world → systems). Tests load those files; they do not own a second copy of the class body.
- Keep eight question ids for what we prove. Do not invent a ninth COMPLEX identity or a folder-rename epic. Two runner lanes are enough.
- Stop feeding known duplicates (operator/control-flow execute in Syntax **and** Coverage **and** Native).
- Name the real incompletes so Syntax extraction and DataDriven are not mistaken for “rewrite all tests.”

**Non-Goals:**

- Rename or merge physical directories in this change.
- Delete Syntax packed execute or Coverage language rows in this change (dual-run later, per-theme).
- Put HotReload, Debugger DAP, or World stories onto the DataDriven engine-profile COMPLEX.
- Treat host `Script/` teaching examples as TestCorpus fixtures.
- Cartesian every fixture against every engine profile.
- Reopen Coverage ⬜ hunting; G7/G19 remain the documented ceilings.

## Decisions

### Decision 1 — Two axes: library subject × test question

Authors do **not** pick a C++ folder first. They pick:

1. **Subject** — what the AngelScript is about (operators, syntax, USTRUCT, TArray, mixin, DefaultComponent, Actor, …). This is the **code library** key. Closed subject ids: `research/subject-ladder.md`. Per-folder cheat sheet and fill order: `research/subject-catalog.md`.
2. **Question** — what the test proves (compile form, bind wired, matrix behave, world tick, reload, same program × engine profile, host machinery). Eight ids below.

A unit test’s identity is `(subject, question)`. The physical C++ folder is only the **driver** for that question. The `.as` file lives once under the subject tree.

Worked examples:

| Want | Subject | Question | Driver today |
|---|---|---|---|
| `1 + 2` execute / `"hello" + 1` must fail | `Language.Operators.Arithmetic` | `behavior-matrix` / `surface-form` | Coverage / Syntax |
| if/for/switch forms | `Language.ControlFlow.If` / `For` / `Switch` | `surface-form` or `behavior-matrix` | Syntax negatives / Coverage 09 |
| comments / `this` / plain `struct` without `USTRUCT` | `Language.Syntax.Comments` / `Keywords` / `Struct` | `surface-form` | Syntax Misc / TypeDeclaration |
| `UCLASS()` or `class AFoo : AActor` shape, no spawn | `Definitions.UClass` | `surface-form` | TypeDeclaration `Class_*` |
| `TArray<int>` / `TObjectPtr` | `Containers.TArray` / `Containers.TObjectPtr` | `surface-form` / `behavior-matrix` | Syntax Container / Coverage Handles |
| DefaultComponent create / Attach tree / mixin / GetX / `asset … of` / `default` / custom `access` | `Feature.DefaultComponent` / `Attach` / `Mixin` / `PropertyAccess` / `Asset` / `Default` / `Access` | `surface-form` | Syntax DefaultComponent; Coverage LiteralAsset / Root-Attach matrices |
| `USTRUCT` members compile and round-trip | `Definitions.UStruct` | `behavior-matrix` | Coverage |
| `UCLASS` + `UFUNCTION` specifier is legal / illegal | `Definitions.UClass` | `surface-form` | Syntax |
| Generated `UClass` after a property add | `Definitions.UClass` | `reload-generation` | HotReload / Generator |
| Spawn `AActor` subclass, oracle is BeginPlay / Tick **order** | `World.Actor` | `world-story` | Functional Actor |
| Same class spawned, oracle is UCLASS methods / TArray / DefaultComponent / Attach tree | `Definitions.UClass` / `Containers.TArray` / `Feature.DefaultComponent` / `Feature.Attach` | `world-story` | Functional driver, same library file |
| Same `USTRUCT` module on Cache V2 | `Definitions.UStruct` | `same-as-profile` | DataDriven (planned) |

`class AFoo : AActor { UFUNCTION() void F(); }` with **no spawn** is still `Definitions.UClass`, not `World.Actor`. Spawning it to prove that UClass **runs** stays `Definitions.UClass` + `world-story`. `World.Actor` is only when the oracle is the Actor host lifecycle itself.

### Decision 2 — Eight questions (locked)

| Id | Question | Owner today | Driver |
|---|---|---|---|
| `native-fork` | Does the vendored AngelScript fork parse/compile/execute **without** UE types? | `AngelScriptSDK/` + Standalone CTest | Native engine / CMake |
| `surface-form` | Does this **spelling** compile or fail on `FAngelscriptEngine` (UE dialect included)? | `Syntax/` + `Compiler/` / `Preprocessor/` for pipeline diagnostics | CQTest + Syntax helpers |
| `bind-contract` | Is this bind / UHT / mixin **entry** visible and wired to the intended native path? | `Bindings/` + `FunctionLibraries/` + `UHTTool/` | CQTest smoke |
| `behavior-matrix` | For this AS-visible type or API, do values / edges / combinations **behave**? | `Coverage/` | CQTest matrices; later generate slices via DataDriven |
| `world-story` | Does this **full-name** subject run in a real World / Actor lifecycle? | `Functional/` + host `Script/Tests/` | COMPLEX `Session.World()` after graduation; CQTest until that facade ships |
| `reload-generation` | What happens when script **shape** changes or a UClass is generated? | `HotReload/` + `Generator/` + Editor recovery tests | CQTest + HotReload corpus COMPLEX (sibling) |
| `same-as-profile` | Does **this same program** hold on VM / Cache V2 / StaticJIT generate / Runtime JIT? | `Fixtures/` + DataDriven COMPLEX (planned) | COMPLEX leaves, explicit `profiles[]` |
| `host-machinery` | Does the C++ host (cache codec, JIT ABI, engine lifecycle, dump, DAP, FS) work? | `Cache/` (store), `StaticJIT/` packager, `RuntimeJIT/` factory, `Core/`, `Dump/`, `Debugger/`, `FileSystem/`, `Validation/`, `Performance/` | CQTest; DAP stays session helpers |

Optional plugins (GAS / GameplayTags) are not a ninth direction. They reuse `bind-contract` / `behavior-matrix` / `world-story` inside their own test modules.

### Decision 3 — Language execute has one UE owner

- `native-fork` owns execute **without** UE binds.
- `behavior-matrix` owns execute **with** UE binds for type families and control-flow semantics (`Coverage` 01 / 09).
- `surface-form` owns compile success/fail of **forms**, including UE dialect (`UFUNCTION` specifiers, DefaultComponent create, Attach trees, access specifiers). It MUST NOT add new packed `ExpectGlobalInts` modules that duplicate Coverage `IfBasic` / int arithmetic.
- Existing Syntax Operators / ControlFlow packed execute is **legacy overlap**. Extract to Fixtures, then let `same-as-profile` (`vm`) or Coverage consume the file; do not keep two execute oracles forever.

`Compiler/` / `Preprocessor/` stay in `surface-form` only when the oracle is **pipeline diagnostics** (row/column, include graph). Do not copy those snippets into Coverage.

### Decision 4 — Bindings stay contract; Coverage stays matrix

Unchanged from `responsibility-boundary.md`. If a Bindings file is growing a type×method table, the new rows go to Coverage. FunctionLibraries mixins are `bind-contract`.

### Decision 5 — World vs Coverage

Coverage MAY spawn/compile UObject when the row is a type/API scenario (Widget compile, Input reflection). `world-story` owns **stories**: tick order, EndPlay, attachment graphs, PIE. G9 already recorded this split; do not copy Actor Tick into Coverage.

`Functional/Operators` and `Functional/ControlFlow` are misfiled unless they need World. Treat them as Coverage candidates at apply of a later move, not as a new Syntax theme.

### Decision 6 — Same AS × engine profile is a direction, not a folder of copies

Do not copy OptionalEmpty / Coverage int arithmetic into StaticJIT ScriptCorpus, Cache “compile this string”, and RuntimeJIT folders. One fixture file; DataDriven lists profiles. Packager/Provider/factory CQTest stays `host-machinery`.

### Decision 7 — The AS library is the subject tree; corpus API is the lookup

`FAngelscriptTestScriptCorpus` is how tests **read** library files. It is not a ninth question and not a ninth suite.

Physical library (TestCorpus):

```text
Fixtures/
  Language/Operators|ControlFlow|Syntax|Access|Casting|Literals|Namespace|Preprocessor|Const/
  Definitions/UEnum|UStruct|UClass|UFunction|UProperty|UInterface|Meta/
  Containers/TArray|TMap|TSet|TOptional|TSubclassOf|TWeakObjectPtr|TSoftObjectPtr|TObjectPtr/
  Feature/Mixin|Delegates|DefaultComponent|Attach|PropertyAccess|Inheritance|Asset|Default|Access/
  World/Actor|Component|Subsystem/{World,GameInstance,LocalPlayer,Engine,Editor}|Blueprint|Widget/
  Gameplay/FMath|FVector|FRotator|FQuat|FTransform|FLinearColor|FVector2D|Input|Physics|Widget|Net|Assets|Timer|Debug|CVar|Anim|Save|Material/
  Optional/GameplayTags|GAS/
```

Host `Script/` (`/Angelscript/Game/`) remains teaching + `UAngelscriptTestSuite`. Same subject names are allowed; different tree. Do not serve teaching files from TestCorpus.

Prefer one class body in the library. A `world-story` test loads `Fixtures/Definitions/UClass/MyActor.as` (or `Feature/DefaultComponent/...`, `Containers/TArray/...`) instead of pasting the body again into `Functional/` and calling it `World.Actor`.

### Decision 8 — This change is the map; movers stay sibling changes

| Work | Change |
|---|---|
| Corpus API + engine-profile COMPLEX | `test-as-data-driven-engine-harness` |
| Subject tree under `Fixtures/Definitions|World|...` | same harness + Syntax/HotReload movers; layout in `research/subject-ladder.md` |
| Syntax `TEXT(R"(` → files | future `test-as-syntax-fixture-corpus` (after corpus API) |
| HotReload pairs | `test-as-hotreload-script-corpus` |
| Host teaching scripts | `test-as-script-corpus-and-functional-coverage` |
| Coverage generate slices | harness Wave B |
| Suite discoverability for Coverage | **this** change’s apply tasks |
| Math / `FMath::` library extract | **after** `improve-as-library-namespace-canonicalization` archives; subject `Gameplay.FMath` + `Gameplay.FVector`… — not this change’s apply |

### Decision 9 — Fill cells on purpose, never cartesian

Not every `(subject, question)` exists. Do **not** cartesian bind-contract onto Language comments. **Do** fill `world-story` across the World-run full names in `research/subject-ladder.md` (Feature, Containers-on-UObject, Definitions instance, World hosts). A Syntax compile of `class AFoo : AActor` does not cover that runtime. Language packed execute belongs to `behavior-matrix` / `same-as-profile`, not new Syntax execute methods.

### Decision 10 — COMPLEX framework (session + tools); CQTest is incubator

Authors pick `(subject, question)`. They do **not** pick a third identity. The lasting runner is a handwritten COMPLEX `FAutomationTestBase` plus a per-leaf **session** with tool facades. The JSON catalog is one **enumerator**, not the whole framework.

| Piece | Mechanism | When |
|---|---|---|
| **Incubator** | CQTest `TEST_CLASS` / `TEST_METHOD` | WIP only. |
| **Framework** | `FAngelscriptComplexAutomation` + `FAngelscriptComplexSession` | House of record. Tools wrap Shared helpers (`FAngelscriptTestWorld`, `FAngelscriptTestFixture`, `AngelscriptBlueprintTestUtils`). |
| **Catalog enumerator** | `cases.json` + `GetTests` leaves | `same-as-profile`, compile/execute, later homogeneous world observations. |
| **C++-on-session** | Enumerator key, leaf body calls tools | Unique World/Blueprint stories before a catalog `kind` exists. |

The framework SHALL NOT include CQTest headers or `ASSERT_THAT`. Do not rewrite CQTest macros to scan JSON. Do not migrate the existing 400+ CQTest files in Wave A. Do not reuse `FBridge` / `Angelscript.ScriptTests`. Native SDK stays outside.

Wave A ships Session + Engine + Corpus + catalog compile/execute. World and Blueprint are the next tool facades (C++ API first, JSON kinds later). Detail: `research/framework-lanes.md`, `test-as-data-driven-engine-harness/research/complex-framework.md`.

### Decision 11 — CQTest incubates; COMPLEX session is the house of record

CQTest exists so development can add a one-path probe quickly. That is not the lasting home of a stable AngelScript program.

Once the feature’s behavior is locked:

1. Name `(subject, question)`.
2. Move the `.as` to `Fixtures/`.
3. Catalog-expressible oracles → `cases.json` + explicit `profiles[]`.
4. World / Blueprint oracles → `Session.World()` / `Session.Blueprint()` (C++ leaf or later catalog kind). Do **not** leave a CQTest Tick driver after those facades ship.
5. Dual-run, then delete the inline CQTest copy.

Never this framework: `native-fork`; host machinery with no AS program. DAP is a later session tool, not Wave A.

### Decision 12 — Tools are facades, not a second World stack

Do not reimplement spawn/tick/Blueprint compile. Session tools wrap the existing Shared/Functional helpers that already take `FAutomationTestBase&`. Catalog `kind` values are thin calls into those facades. Adding World JSON observations is optional and comes after the C++ facade golden.

### Alternatives considered

- **Treat Native / CQTest / COMPLEX as the only taxonomy.** Too coarse: Bindings vs Coverage would collapse again. Use those as **lanes**, keep eight **questions**.
- **One JSON COMPLEX for World, DAP, and Bindings on day one.** Rejected: wrong oracle. **A shared session with separate tool modules and enumerators is the chosen shape.**
- **Leave World forever on CQTest.** Overturned by Decision 10–12: wrap `FAngelscriptTestWorld` as `Session.World()`.
- **Stamp one CQTest `TEST_METHOD` per `(fixture, profile)`.** Rejected: adding a profile still recompiles C++; CQTest `GetTests` cannot scan catalogs.
- **Physical merge Syntax into Coverage.** Rejected for Wave 0: 352 Syntax negatives have no diagnostic substring and are form tests, not type-family matrices.

## Risks / Trade-offs

- [Authors ignore the map] → Put the subject ladder plus eight-question table at the top of `TestConventions.md` and `TESTING_GUIDE.md`; require new OpenSpec test changes to name a subject id and a question id.
- [Authors leave stable features as inline CQTest] → Decision 11–12: incubate in CQTest; graduate onto COMPLEX session tools + catalog; World/Blueprint are facades, not leftover CQTest.
- [Legacy overlap remains forever] → Syntax packed execute and Functional Operators get explicit “stop feeding / extract then drop” rows; no silent delete in this change.
- [Coverage in All makes All slower] → Coverage is already a Heavy-sized surface; give it its own named suite **and** an `All` entry so it is discoverable. Parallel All already exists.

## Migration Plan

1. Record this map (this session).
2. Apply: docs + suite only.
3. Sibling changes move AS onto Fixtures along the map; do not wait for a directory rename.

Rollback: revert the docs/suite commit. No production binary impact.

## Open Questions

None for the eight question ids or the subject ladder bands. Optional later: whether Syntax packed-execute files after extraction are consumed only by DataDriven `vm` or also remain a Coverage method. Default: DataDriven `vm` for language-only packed modules; Coverage keeps type-family generate. Do not dual-oracle the same function forever.
