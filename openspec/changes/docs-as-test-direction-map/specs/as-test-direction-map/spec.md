## ADDED Requirements

### Requirement: New tests name one subject and one question
A new or refactored automation test SHALL name exactly one subject id from `research/subject-ladder.md` and exactly one question id from this set before a physical folder is chosen: `native-fork`, `surface-form`, `bind-contract`, `behavior-matrix`, `world-story`, `reload-generation`, `same-as-profile`, `host-machinery`. Subject ids SHALL use Unreal PascalCase `Band.Theme` matching the Fixtures folder names (`Definitions.UClass`, `World.Actor`, `Containers.TArray`, `Feature.DefaultComponent`), or `Band.Theme.Child` when `research/subject-ladder.md` nests a leaf (`Language.Syntax.Comments`, `Language.Operators.Arithmetic`, `Language.Literals.FString`, `World.Subsystem.World`). `Language.Syntax`, `Language.Operators`, `Language.ControlFlow`, `Language.Literals`, and `World.Subsystem` SHALL be treated as parent folders; a new fixture SHALL use a child leaf unless a packed legacy file still mixes children. `World.Actor` SHALL remain a single leaf; BeginPlay, Tick, and EndPlay SHALL be oracles of question `world-story`, not child subject ids. The `.as` library file SHALL be stored under the subject tree. The C++ or COMPLEX driver SHALL be the owner of that question in `design.md`. Optional-plugin tests SHALL use subject ids `Optional.GameplayTags` or `Optional.GAS` plus one question id and SHALL NOT invent a ninth question id.

#### Scenario: Author picks folder first
- **WHEN** a change adds a test whose only justification is that a neighboring `.cpp` in the same folder looks similar
- **THEN** review SHALL reject it unless the subject id and question id are stated

#### Scenario: Subject id is Unreal PascalCase
- **WHEN** a new library folder or test names a subject
- **THEN** the id SHALL match `Band.Theme` or `Band.Theme.Child` using Unreal PascalCase folders such as `Language.Operators.Arithmetic`, `Language.Syntax.Comments`, `Definitions.UClass`, `World.Actor`, `Containers.TArray`, `Feature.DefaultComponent`
- **AND** it SHALL NOT use lowercase dotted ids such as `language.operators`
- **AND** a new Syntax fixture SHALL NOT use the parent id `Language.Syntax` as a leftover dump
- **AND** a new subsystem fixture SHALL NOT use the parent id `World.Subsystem` as a leftover dump

#### Scenario: Optional plugin
- **WHEN** a GameplayTags or GAS test is added
- **THEN** it SHALL name `Optional.GameplayTags` or `Optional.GAS` plus one of the eight question ids
- **AND** it SHALL NOT be registered under `Angelscript.TestModule.Coverage` solely because Coverage has a similar type name

#### Scenario: UStruct definition test
- **WHEN** a test proves `USTRUCT` member compile or value round-trip without spawning an Actor
- **THEN** its subject SHALL be `Definitions.UStruct`
- **AND** its question SHALL be `surface-form`, `behavior-matrix`, `reload-generation`, or `same-as-profile`
- **AND** it SHALL NOT be filed as `World.Actor`

#### Scenario: Actor host lifecycle
- **WHEN** a test’s oracle is UserConstructionScript, BeginPlay, Tick, EndPlay, Destroyed, or spawn of an Actor **as the story**
- **THEN** its subject SHALL be `World.Actor`
- **AND** its question SHALL be `world-story` (or `reload-generation` when the oracle is instance survival across reload)
- **AND** a compile-only `class AFoo : AActor` snippet SHALL NOT count as that world test
- **AND** it SHALL NOT use `World.Actor.Tick`, `World.Actor.Pawn`, or another lifecycle/class-kind child id
- **AND** exact Tick counts SHALL use `FAngelscriptTestWorld::DispatchActorTick`, not `World.Tick`
- **AND** mixin, timer, UFunction, interface, Attach tree, or TArray proven on that same spawned Actor SHALL keep those library ids

#### Scenario: Subsystem host kind
- **WHEN** a test covers a script subsystem’s Initialize / Tick / Deinitialize as the host
- **THEN** its subject SHALL be `World.Subsystem.World`, `World.Subsystem.GameInstance`, `World.Subsystem.LocalPlayer`, `World.Subsystem.Engine`, or `World.Subsystem.Editor` matching the `UScript*` base
- **AND** `USubsystemLibrary::Get*` smokes SHALL remain `bind-contract`

#### Scenario: World-run keeps the full subject name
- **WHEN** a test spawns or ticks a live instance in order to prove `TArray`, DefaultComponent create, an Attach tree, mixin, delegate broadcast, `UFUNCTION` on an instance, or `UINTERFACE` on an instance
- **THEN** its subject SHALL be that library id (`Containers.TArray`, `Feature.DefaultComponent`, `Feature.Attach`, `Feature.Mixin`, `Feature.Delegates`, `Definitions.UFunction`, `Definitions.UInterface`, …)
- **AND** its question SHALL be `world-story`
- **AND** it SHALL NOT be retargeted to `World.Actor` or `World.Component` merely because a World was created

### Requirement: Direction questions are exclusive
Each question id SHALL answer one question:

- `native-fork`: vendored AngelScript without UE types
- `surface-form`: whether a spelling compiles or fails on `FAngelscriptEngine`, including Unreal dialect forms
- `bind-contract`: whether a bind, UHT, or mixin entry is visible and wired
- `behavior-matrix`: whether an AS-visible type or API behaves across values, edges, and combinations
- `world-story`: this subject running in a real UObject / World / Actor lifecycle (`FAngelscriptTestWorld`); not an automatic rename to `World.Actor`
- `reload-generation`: script-shape change or generated UClass/UStruct outcome
- `same-as-profile`: the same program under named engine profiles (VM, Cache V2, StaticJIT generate, Runtime JIT)
- `host-machinery`: C++ host internals (cache store/codec, JIT packager/Provider/factory, engine lifecycle, dump, DAP, filesystem, validation, performance harness)

#### Scenario: Two questions in one method
- **WHEN** a method both checks that a bind exists and saturates a type matrix
- **THEN** the bind smoke SHALL stay `bind-contract`
- **AND** the matrix SHALL be a separate `behavior-matrix` method or Coverage generate product

### Requirement: AS library is stored by subject
Reusable AngelScript SHALL live under `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/` grouped by the subject bands and directory names in `research/subject-ladder.md` and `research/subject-catalog.md`. Lookup SHALL use `FAngelscriptTestScriptCorpus` virtual paths `/Angelscript/Memory/TestCorpus/<relative>.as`. Host `Script/` teaching files SHALL remain a separate tree and SHALL NOT be served from that corpus. Tests SHALL load the library file for that subject instead of pasting a second copy of the same class body into another C++ theme. Bind-contract smokes MAY stay inline one-liners and SHALL NOT require a Fixtures file.

#### Scenario: Operator tests
- **WHEN** a test covers arithmetic or an illegal operand pairing
- **THEN** its subject SHALL be `Language.Operators.Arithmetic`, or parent `Language.Operators` only while a packed file still mixes operator children
- **AND** an illegal form SHALL use question `surface-form`
- **AND** a packed execute of legal operators SHALL use `behavior-matrix` or `same-as-profile`
- **AND** it SHALL NOT be filed as `Definitions.UClass` or `World.Actor`

#### Scenario: Comment form tests
- **WHEN** a test covers `//` or `/* */` comment forms
- **THEN** its subject SHALL be `Language.Syntax.Comments`
- **AND** its question SHALL be `surface-form`

#### Scenario: Keyword form tests
- **WHEN** a test covers `this`, `final`, or `override`
- **THEN** its subject SHALL be `Language.Syntax.Keywords`
- **AND** wrapping the keyword in `class AFoo : AActor` SHALL NOT move the subject to `Definitions.UClass`

#### Scenario: Plain type declaration tests
- **WHEN** a test covers a plain `class` / `struct` / `enum` / `function` declaration without `UCLASS` / `USTRUCT` / `UENUM` / `UFUNCTION`
- **THEN** its subject SHALL be `Language.Syntax.Class`, `Language.Syntax.Struct`, `Language.Syntax.Enum`, or `Language.Syntax.Function` respectively
- **AND** its question SHALL be `surface-form` unless it executes a value, in which case it SHALL be `behavior-matrix`

#### Scenario: TypeDeclaration UCLASS is not Syntax.Class
- **WHEN** a snippet is `UCLASS()` or `class AFoo : AActor` whose oracle is the reflected type shape
- **THEN** its subject SHALL be `Definitions.UClass`
- **AND** it SHALL NOT be filed as `Language.Syntax.Class` even if the C++ file is `AngelscriptSyntaxTypeDeclarationTests.cpp`

#### Scenario: Container type tests
- **WHEN** a test covers `TArray`, `TMap`, `TSet`, `TOptional`, or a `TObjectPtr` / `TSubclassOf` handle
- **THEN** its subject SHALL be the matching `Containers.*` id
- **AND** it SHALL NOT use a `Composition.*` id
- **AND** it SHALL NOT be filed as `Feature.Delegates` or `Feature.DefaultComponent`

#### Scenario: Dialect feature tests
- **WHEN** a test covers `mixin`, a DefaultComponent **create** spelling, a Root/Attach/AttachSocket/OverrideComponent tree, a delegate/event form, GetX/SetX property access, `asset Name of Type`, a class-body `default` statement, or a custom `access` specifier
- **THEN** its subject SHALL be `Feature.Mixin`, `Feature.DefaultComponent`, `Feature.Attach`, `Feature.Delegates`, `Feature.PropertyAccess`, `Feature.Asset`, `Feature.Default`, or `Feature.Access` respectively
- **AND** it SHALL NOT be filed under `Language` or `Containers`
- **AND** creating or ticking a DefaultComponent instance SHALL keep subject `Feature.DefaultComponent` and use question `world-story` when live
- **AND** proving parent/socket/override after spawn SHALL keep subject `Feature.Attach` and use question `world-story`
- **AND** it SHALL NOT retarget those attach-tree tests to `World.Component` merely because a Component exists
- **AND** `asset Name of Type` SHALL NOT be filed as `Gameplay.Assets` or `World.Asset`
- **AND** `public` / `private` / `protected` SHALL remain `Language.Access`

#### Scenario: One UClass body two questions
- **WHEN** `Fixtures/Definitions/UClass/MyActor.as` exists
- **THEN** a `surface-form` test and a `world-story` test MAY both load that file
- **AND** the `world-story` test SHALL NOT duplicate the UCLASS body as a second inline string

#### Scenario: Shared corpus is not a question
- **WHEN** `FAngelscriptTestScriptCorpus` is used
- **THEN** the caller SHALL still name one subject id and one question id
- **AND** the corpus API SHALL NOT be described as a ninth test suite

### Requirement: Math subjects wait for FMath canonicalization
Reusable Math / `FMath::` / math-struct library files SHALL NOT be extracted onto `Fixtures/Gameplay/` while `improve-as-library-namespace-canonicalization` is still an active change. After that change is archived, `FMath::` namespace functions SHALL use subject `Gameplay.FMath`, and mixin methods on math structs SHALL use `Gameplay.FVector`, `Gameplay.FRotator`, `Gameplay.FQuat`, `Gameplay.FTransform`, `Gameplay.FLinearColor`, or `Gameplay.FVector2D`. New positive fixtures SHALL call `FMath::` and SHALL NOT call `Math::` or `MathLibrary::`. The leftover id `Gameplay.Math` SHALL NOT be used. Math FunctionLibrary behavior defects SHALL remain `improve-as-runtime-function-libraries`.

#### Scenario: Math fixture extract too early
- **WHEN** an author wants to extract Coverage Math, Syntax MathModule, or Bindings Math into TestCorpus
- **THEN** that work SHALL wait until `improve-as-library-namespace-canonicalization` is archived
- **AND** it SHALL NOT add a positive `Math::` or `MathLibrary::` `.as` file
- **AND** it SHALL NOT use subject id `Gameplay.Math`

### Requirement: No cartesian of subject times question
A change SHALL NOT add every question id to every subject. `world-story` SHALL be filled for the runtime subjects listed in `research/subject-ladder.md` section World-run (Feature leaves, Containers on UObject, Definitions UClass/UFunction/UInterface instance, World hosts, Gameplay subjects that need a World). `Language.Syntax.Comments`, preprocessor forms, `Definitions.UEnum`, and `Definitions.Meta` SHALL NOT require `world-story`. World host subjects SHALL not be treated as covered by a Syntax compile of an unspawned `AActor` subclass. Language packed execute SHALL go to `behavior-matrix` or `same-as-profile`, not a new Syntax `ExpectGlobalInts` method.

#### Scenario: New Syntax operator execute
- **WHEN** an author wants another `int AddInt()` packed module under `Syntax/Operators`
- **THEN** that work SHALL be routed to `behavior-matrix` or `same-as-profile`
- **AND** it SHALL NOT land as a new Syntax `TEST_METHOD` whose oracle is `ExpectGlobalInts`

### Requirement: Language execute has one UE owner
`native-fork` SHALL own language execute without UE binds. `behavior-matrix` SHALL own language execute with UE binds for type families and control-flow semantics. `surface-form` SHALL own compile success and compile-failure of forms, including `UFUNCTION` specifiers, DefaultComponent create, Attach trees, and access specifiers. `surface-form` SHALL NOT add new packed execute modules (`ExpectGlobalInts` over many global functions) that duplicate Coverage language or integer-arithmetic rows.

#### Scenario: Pipeline diagnostics
- **WHEN** the oracle is preprocessor or compiler row/column or include-graph behavior
- **THEN** the test SHALL stay `surface-form` under `Preprocessor/` or `Compiler/`
- **AND** it SHALL NOT be copied into Coverage as a matrix row

### Requirement: COMPLEX framework and CQTest incubator
A lasting test SHALL run on the plugin COMPLEX framework (`FAutomationTestBase` with `bInComplexTask`, per-leaf session, tool facades) according to `research/framework-lanes.md` and `test-as-data-driven-engine-harness/research/complex-framework.md`. Authors SHALL NOT name a third identity besides subject and question. The JSON catalog SHALL be one enumerator on that framework, not the whole framework. The framework SHALL NOT include CQTest headers, SHALL NOT use `ASSERT_THAT`, SHALL NOT rewrite CQTest macros to scan JSON, and SHALL NOT reuse `FAngelscriptScriptTestAutomation::FBridge` or prefix `Angelscript.ScriptTests`. Session tools SHALL wrap existing Shared helpers that take `FAutomationTestBase&` (`FAngelscriptTestWorld`, `FAngelscriptTestFixture`, `AngelscriptBlueprintTestUtils`) rather than a second spawn/tick stack. Native SDK SHALL stay outside this framework. Wave A SHALL ship Session + Engine + Corpus + catalog compile/execute. World and Blueprint facades MAY follow as C++ APIs before catalog kinds exist.

#### Scenario: Author picks runners from the question
- **WHEN** an author adds a new automation test
- **THEN** they SHALL name one subject id and one question id
- **AND** they SHALL NOT name a third identity for CQTest versus COMPLEX
- **AND** the COMPLEX registrar SHALL NOT reuse `FAngelscriptScriptTestAutomation::FBridge` or prefix `Angelscript.ScriptTests`

### Requirement: CQTest incubates; COMPLEX session is the house of record
While a feature is still moving, a CQTest `TEST_METHOD` with inline `ASTEST_AS` MAY be the only runner. Once that AngelScript program is the lasting regression, authors SHALL name `(subject, question)`, move the source into `Fixtures/`, and if the oracle is catalog-expressible (`compile`, `executeInt`, `executeBool`, diagnostic substring) SHALL add a catalog case with explicit `profiles[]` (at least `vm`). World or Blueprint oracles SHALL use `Session.World()` / `Session.Blueprint()` after those facades ship, not a leftover CQTest driver. Dual-run is allowed; after both are green the inline CQTest copy SHALL be deleted. This requirement SHALL apply to new work from the day Session + Engine + Corpus ship; it SHALL NOT require migrating the existing 400+ CQTest files in harness Wave A.

#### Scenario: Same program on VM and Cache
- **WHEN** one `.as` must compile and execute on `vm` and `cache-roundtrip`
- **THEN** it SHALL be a DataDriven catalog case with explicit `profiles[]`
- **AND** it SHALL NOT be two CQTest methods that each paste the source

#### Scenario: Actor in a World
- **WHEN** the oracle is BeginPlay / Tick / EndPlay of an Actor and the story is stable
- **THEN** the class body SHALL live in `FAngelscriptTestScriptCorpus`
- **AND** after `Session.World()` ships the driver SHALL be the COMPLEX session wrapping `FAngelscriptTestWorld`
- **AND** it SHALL NOT remain a CQTest `TEST_METHOD` as the house of record
- **AND** it SHALL NOT keep the only copy of that class as inline `ASTEST_AS`
- **AND** it SHALL NOT be encoded as an engine profile (`vm` / `cache-roundtrip`) merely because it spawned

#### Scenario: Stable compile/execute still only in CQTest
- **WHEN** a lasting regression is compile or execute of AngelScript and the catalog enumerator has shipped
- **THEN** the test SHALL be a DataDriven catalog case
- **AND** the CQTest method SHALL NOT remain the source of truth for that `.as`

#### Scenario: WIP probe
- **WHEN** the API is still moving or the case is a throwaway spike
- **THEN** a CQTest `TEST_METHOD` with inline `ASTEST_AS` MAY be the only runner
- **AND** it SHALL graduate before the feature’s test work is called done

#### Scenario: Framework does not depend on CQTest
- **WHEN** the COMPLEX session or catalog driver is compiled
- **THEN** those translation units SHALL NOT include CQTest headers
- **AND** they SHALL assert through `FAutomationTestBase` rather than `ASSERT_THAT`

### Requirement: Forbidden overlap
The following overlaps SHALL NOT be expanded:

- Copying the same AngelScript into StaticJIT ScriptCorpus, Cache compile-string tests, and RuntimeJIT folders instead of listing profiles on one fixture
- Growing Bindings files into type×method matrices that Coverage already owns
- Adding Actor Tick / EndPlay stories to Coverage when Functional already owns that lifecycle seam
- Driving HotReload, DAP, or bind-contract smoke from engine-profile catalog rows
- Driving World stories as `vm` / `cache-roundtrip` / JIT **profiles** (World uses `Session.World()`, not an engine profile)
- Serving host `Script/` teaching files from `FAngelscriptTestScriptCorpus`

Allowed overlap: a `bind-contract` smoke plus a `behavior-matrix` row for the same API; a `surface-form` negative compile plus a Coverage execute of a legal form; HotReload analyze corpus plus Generator planner unit tests; one library file loaded by two questions.

#### Scenario: Same AS on JIT
- **WHEN** a fixture already has a DataDriven `typed-ast-generate` or `runtime-jit` leaf
- **THEN** a new CQTest MUST NOT inline that same source to prove generation or execute

### Requirement: Documented incompletes are the backlog
The map SHALL treat these as incomplete, not as missing folders: same-AS × engine profile (DataDriven), Syntax form extraction onto the subject tree, host `Script/` teaching corpus, Coverage named-suite discoverability, Runtime JIT skip-if-no-factory, Debugger MARK fixtures, Math / `FMath::` TestCorpus extract (blocked on `improve-as-library-namespace-canonicalization`). Coverage G7 and G19 remain the documented behavior-matrix ceilings.

#### Scenario: Coverage suite
- **WHEN** `Tools/Shared/TestSuiteDefinitions.ps1` is updated by this change
- **THEN** it SHALL define a named suite whose Unreal prefix is `Angelscript.TestModule.Coverage`
- **AND** `All` SHALL include that prefix
