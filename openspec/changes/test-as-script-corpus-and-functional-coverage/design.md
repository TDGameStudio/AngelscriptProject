## Context

The host project currently has three different script roles mixed together:

- `Script/Examples/**` contains a small set of reader-facing samples, but the directory is intentionally skipped when development scripts are excluded and its examples are not a broad project-level validation corpus.
- `Script/Game/Example_Actor.as` is a cooked fixture with a real content dependency and cannot be treated as a disposable example.
- `Script/Tests/**` contains 9 current files: one reflected script-suite demonstration, one path-loaded hot-reload fixture, one optional-plugin legacy fixture, and six shallow files that do not teach or validate their named subject.

The plugin test module has substantially richer evidence: 204 manual binding source files matching `Bind_*.cpp`, 18 established Coverage domains, 87 Bindings `.cpp` files, 52 Functional `.cpp` files, 18 FunctionLibraries `.cpp` files, and 19 Syntax `.cpp` files at the 2026-08-11 planning baseline. Of the 204 binding files, 127 already contain API-table-like comments, 59 register global functions, 57 participate in namespace registration, and 94 register methods; those categories overlap. The Runtime function-library surface includes Actor, Component, Math/value types, FrameTime, HitResult, World/Collision, Input, Curve, SoftReference, Subsystem, AssetManager, Widget, LevelStreaming, Gameplay, and Script helpers. The 204 files are normalized into logical provider families during audit rather than treated as 204 required examples. Those tests are authoritative implementation evidence, but their inline snippets are optimized for narrow regression isolation and are often unsuitable as teaching material.

The existing reflected script-test framework already supplies independent Automation leaves, fixture lifecycle, assertions, expected-log matching, optional World creation, object/actor/component spawning, direct and World ticking, deterministic time advancement, latent commands, and cleanup. The change therefore needs a content and coverage architecture, not a second test framework.

## Goals / Non-Goals

**Goals:**

- Build a theme-organized, realistic AS corpus whose functions and classes demonstrate why and how an API is used.
- Build a separate, high-coverage AS functional-test corpus using the existing reflected suite framework.
- Make API-heavy corpus files useful as source-local indexes by deriving AS-facing usage tables from real bind and function-library evidence.
- Give UE Blueprint libraries, Runtime function/mixin libraries, and AS-specific binding semantics their own discoverable corpus/test themes while keeping domain examples as the primary gameplay-oriented learning path.
- Provide a reproducible crosswalk from every manual binding file and every Bindings/FunctionLibraries test source to the corpus/test scenario that owns its user-visible behavior.
- Audit the manual binding and test surfaces into user capabilities, closing AS-test gaps and C++ behavior-test gaps in their proper layers.
- Make World, UObject, Actor, Component, subsystem, timer, logging, native interop, and network requirements explicit before implementation.
- Keep the record executable in independent waves with exact paths, prefixes, and verification commands.

**Non-Goals:**

- Mirror every existing C++ test method into a separate `.as` leaf.
- Turn regression snippets, parser probes, or arbitrary return constants into reader-facing examples.
- Add a code generator for examples or tests.
- Add a separately maintained JSON corpus manifest in v1.
- Mirror each `Bind_*.cpp`, Bindings C++ test, or FunctionLibraries C++ test into a one-to-one `.as` file.
- Add or modify StaticJIT, AOT, precompiled-data, generated JIT source, or JIT diagnostic behavior.
- Add new production Runtime bindings merely because an audit finds a missing API; such rows remain explicit gaps for another change.
- Cover the optional GameplayTags or GAS plugins.
- Move plugin behavior into the host project module.

## Decisions

### Separate the corpus from script functional tests

Reader-facing material lives beneath `Script/<Theme>/`. Executable script tests live beneath `Script/Tests/<Theme>/`. They use the same topic names for navigation, evidence mapping, and Automation prefix filtering, but there is no one-example/one-test rule.

Corpus code may be reused by a test when that is the natural public usage path. Tests may also call the public AS/UE surface directly when reuse would force the example to expose artificial hooks. Corpus code never derives from `UAngelscriptTestSuite`, calls `FAngelscriptTest`, or depends on `AngelscriptTest` test-only types.

This separation is preferred over executable examples as the only source because teaching code and exhaustive boundary tests have different readability, setup, and failure-reporting needs. It is preferred over mirrored example/test pairs because mirrored bodies drift and encourage low-value duplication.

### Use stable root themes and five implementation waves

The planned root themes are:

| Wave | Corpus and test themes | Primary responsibility |
|---|---|---|
| 1 | `Language`, `Math`, `Containers`, `Text`, `Reflection` | Core language, common values, binding usage, reflected declarations |
| 2 | `Objects`, `Interop`, `Inheritance`, `Interface`, `Delegates` | UObject/reference semantics, OO dispatch, native/AS marshalling |
| 3 | `Actor`, `Component`, `World`, `Subsystems`, `Timers` | World-backed gameplay lifecycle and scheduling |
| 4 | `Input`, `Collision`, `UI`, `Animation`, `Assets`, `Diagnostics` | Engine feature systems and environment-bound surfaces |
| 5 | `Networking` plus matrix/catalogue closure | Real network behavior and final cross-theme reconciliation |

Root themes are intentionally normal project scripts rather than descendants of `Examples`, so they participate in the host validation project's normal script compilation. `Script/Game/Example_Actor.as` retains its cooked fixture role and is never moved by the corpus migration.

`BlueprintLibraries` and `Bindings` are cross-cutting tracks rather than a sixth and seventh implementation wave. Their cases are implemented after the provider/test audit and alongside the domain wave that supplies their behavior evidence. `BlueprintLibraries` explains coherent library workflows; `Bindings` explains AS publication/call semantics. Both link to domain examples instead of copying their complete bodies.

The revised matrices name 181 unique corpus targets and 194 unique themed test targets, for 375 theme files. See `size-estimate.md` for the wave/track split, line/test-leaf estimate, final-tree estimate, and controls that prevent this large plan from degrading into generated placeholders.

### Make README the human catalogue and source comments the local card

`Script/README.md` is the single catalogue. Each row records theme, file, purpose, principal symbols, prerequisites, expected result, related AS test prefix, and local bind/test evidence. `Script/Tests/README.md` documents authoring, World selection, logging, flags, cleanup, and run commands.

Every corpus `.as` file begins with a compact source card:

```text
Purpose: <the concrete problem solved>
Demonstrates: <AS-facing APIs and behavior>
Prerequisites: <None or exact asset/world/editor/network need>
Expected result: <observable return, state, event, or log>
```

No JSON manifest is maintained in v1 because there is no checked-in consumer for it. If a future exporter, search tool, Wiki importer, or AI indexing job needs structured data, it generates that data from the catalogue and source cards rather than creating a second hand-maintained authority.

### Put verified AS API usage tables in API-dense corpus files

Files that teach an API family rather than a single language construct include a Markdown-style table inside their leading block comment:

```text
AS API | Purpose | Important parameters / effects | Used by | Limits | Evidence
```

The table is required for Math/FMath, math value types, TArray/TMap/TSet, FString/FName/FText, UObject/reference wrappers, Actor, Component, World, Subsystem, Timer, Input, Collision, UI, Animation, Assets, Networking, and Interop files. A small syntax-only file may omit it when no meaningful API family is indexed.

Each row is verified in this order:

1. Inspect the actual `Bind_*.cpp`, generated/reflected source, or public function-library declaration that publishes the operation.
2. Confirm the AS-facing spelling and signature in existing Bindings/FunctionLibraries tests or generated AS API evidence.
3. Confirm semantics and limitations in Coverage/Functional tests.
4. Point `Used by` at a real function or class in the same corpus file.
5. Cite the publishing `Bind_*.cpp`, reflected/function-library declaration, and representative Bindings/FunctionLibraries behavior test in `Evidence`.

The table records the script form, not the C++ registration callback or native method name. Unsupported, reflective-only, editor-only, asset-bound, and network-bound surfaces are labelled explicitly. A function is never listed merely because a similarly named Unreal C++ method exists.

This source-adjacent table is preferred over a generated API dump because it indexes the curated subset taught by that file and can explain purpose, effects, and limitations. The full binding inventory remains available through code, dumps, and the OpenSpec matrices.

### Treat Blueprint and Runtime function libraries as user-facing capabilities

`Script/BlueprintLibraries/` owns cohesive workflows whose main teaching value is discovering and combining static, namespaced, or receiver-mixin library calls. Its initial matrix covers Math/orientation, Gameplay actor queries and World actions, SaveGame, System logging and timing, World collision, Widget creation, AssetManager, AssetRegistry, DataTable, Input, Curves, SoftReferences, Subsystems, Script helpers, Actor/Component mixins, HitResult, and LevelStreaming.

The corpus records the AS form after `ScriptName`, `ScriptMixin`, WorldContext removal, overload selection, and generated/reflected publication. It never teaches `UKismet*` or native wrapper names when the script surface is `Math::`, `Gameplay::`, `System::`, a receiver method, or another published alias. Library workflows cross-link their domain files, but their executable bodies must still demonstrate a distinct end-to-end use rather than serve as a second API dump.

### Give binding semantics a focused learning surface without mirroring C++ files

`Script/Bindings/` owns user-visible mechanics that otherwise remain hidden in registration code: global/namespace calls, member/property calls, `ScriptName` aliases, mixin receivers, construction/assignment, operators, primitive conversions, container/iterator forms, object handles, out/inout/reference behavior, WorldContext injection, reflective callable fallback, delegate calls, formatting contributions, diagnostics/deprecations, and public behavior across supported call routes.

`binding-library-crosswalk.md` is the plan-time schema for mapping all 204 binding files, all 87 Bindings test sources, and all 18 FunctionLibraries test sources. Split `_Type`/`_Functions` files and multiple registration shards normalize to one logical provider family. A family may map to an existing domain file, a BlueprintLibraries/Bindings case, or an explicit internal/unsupported/environment-bound disposition; it does not receive a file merely to satisfy a count.

### Require scenario semantics rather than compile-shaped examples

Corpus functions and classes use outcome-oriented names and data. Examples include an inventory index for container operations, a camera-orientation calculation for vector/rotator/quaternion use, a component health-state lifecycle, or a subsystem-backed session state. Forbidden patterns include `FPhase2*`, `FixtureValue`, generic `Step()` methods, and functions whose only effect is returning an unexplained constant.

Each corpus file focuses on one capability or a naturally cohesive workflow. It may contain multiple helper functions when they form one use case, but it must not become an indiscriminate API dump. The API table provides breadth; the executable body demonstrates the important combinations.

### Use a normalized user-capability matrix rather than raw test counts

The change stores a main matrix index plus twelve thematic matrices. A row is a user-observable scenario and records:

- stable scenario ID and purpose;
- AS-facing operation;
- planned corpus and AS-test targets;
- bind/test evidence;
- World, object, asset, network, native-fixture, and logging needs;
- disposition: `Covered`, `CorpusGap`, `ScriptTestGap`, `CxxBehaviorGap`, `NeedsNativeFixture`, `Unsupported`, `EnvironmentBound`, or `OutOfScope`.

Every manual bind provider is mapped to one or more rows or to a recorded internal/non-corpus disposition. Every Bindings and FunctionLibraries C++ test source is mapped as AS-spelling/contract/behavior evidence or as internal-only evidence. Existing C++ methods are not automatically backlog items. Completion requires no unexplained gap for a stable core user capability, not a numerical one-to-one mapping with the 1022-method Coverage baseline or the source-file counts.

### Route C++ coverage gaps by behavior layer

When the audit shows that the C++ test module itself lacks behavior evidence, later implementation routes the test as follows:

| Missing evidence | Destination |
|---|---|
| AS-visible bind exists, has correct declaration, and reaches the native path | `Bindings/` contract smoke |
| Values, type matrices, container semantics, boundaries, exceptions | `Coverage/` and its matrix |
| UObject, GC, Actor, Component, World, interface, subsystem lifecycle | Existing Functional/theme directory |
| Function-library or mixin behavior | `FunctionLibraries/` |
| Syntax, compiler, preprocessor, or diagnostic contract | `Syntax/`, `Compiler/`, or `Preprocessor/` |
| Pure ASSDK behavior without UE | `AngelScriptSDK/` |

New C++ test registrations use `WITH_ANGELSCRIPT_UNITTESTS`, `TEST_CLASS_WITH_FLAGS`, class-level engine setup/reset, `ASTEST_AS`, matcher assertions, scenario names, and existing test harnesses. A new binding capability is not added by this change; a missing production surface is recorded for a focused binding change.

### Use the reflected AS test framework and create World only when behavior requires it

Pure language, Math, container, string, name, text, reflection-shape, and deterministic interop tests run without a World. UObject tests use `FAngelscriptTest::SpawnObject` when an Outer or tracked lifetime is required.

World-backed tests explicitly select the smallest necessary fixture:

- `CreateTestWorld(false)` for Actor/Component/World behavior that does not need a GameInstance.
- `CreateTestWorld(true)` for GameInstance and subsystem context.
- `SpawnActor`, `SpawnComponent`, and `BeginPlay` for owned lifecycle setup.
- `TickActor` and `TickComponent` when exact callback counts are the oracle.
- `TickWorld` or `AdvanceTime` for timers, scheduling, subsystem ticking, and World-driven behavior.
- `DestroyActor` and `DestroyTestWorld` when destruction or cleanup is part of the behavior being asserted.

Framework cleanup remains the terminal safety net on success, assertion failure, exception, timeout, cancellation, and reload. Tests still perform explicit teardown when teardown state is part of the scenario.

Networking is never simulated by a local World. Server/client/multicast, role, validation, and replication scenarios use the project's real network-capable harness or remain `EnvironmentBound` with an exact reason.

### Treat logging as evidence context, not the test oracle

Corpus examples log only meaningful inputs, state transitions, and final outcomes. `Print` is reserved for examples whose purpose is on-screen feedback. Tests use assertions for pass/fail and add logs only where a multi-step lifecycle, native boundary, or environment-dependent operation benefits from a diagnostic breadcrumb.

Expected errors are registered before the triggering operation with `ExpectError` or `ExpectErrorRegex`. Logs never hide failures, replace state assertions, or flood one message per loop iteration. Complex logs use a stable `[ScriptCorpus.<Theme>.<Scenario>]` prefix.

### Use small test-only native interop types

Later implementation adds test-only support in `AngelscriptTest`, not Runtime:

- `FAngelscriptScriptInteropRecord`: reflected ID, label, and position fields for struct and container marshalling.
- `UAngelscriptScriptInteropTestObject`: observable properties and instance UFUNCTION paths for scalars, strings/names, math values, enums, objects, out/inout mutation, and side-effect counters.
- `UAngelscriptScriptInteropTestLibrary`: static UFUNCTION paths for struct/container round trips and bounded WorldContext behavior.
- A dynamic delegate carrying the record payload for native-to-AS and AS-to-native callback verification.

Test AS must execute the parameter path and assert field values, identities, mutations, delegate payloads, and side effects. Reflection metadata or compilation alone is insufficient. These types remain compilable support when test registration is disabled and are never corpus dependencies.

### Add explicit corpus validation and suite integration

A C++ Automation validation prefix, `Angelscript.TestModule.Validation.ScriptCorpus`, enforces catalogue/file correspondence, required source-card fields, forbidden placeholders, and separation from test-only APIs. It also audits that required API-table files contain the expected columns; semantic correctness remains a review plus behavior-test responsibility rather than a brittle source-string assertion for every API row.

The validator also requires BlueprintLibraries/Bindings files to provide an `Evidence` column and verifies that the later generated crosswalk has no duplicate or missing source paths.

`Tools/Shared/TestSuiteDefinitions.ps1` gains a `ScriptCorpus` suite containing:

- `Angelscript.ScriptTests.Tests`
- `Angelscript.TestModule.Validation.ScriptCorpus`

The script-test root is also added to `All`. Theme paths under `Script/Tests/<Theme>` naturally produce filterable module prefixes such as `Angelscript.ScriptTests.Tests.Math` and `Angelscript.ScriptTests.Tests.Actor`.

## Risks / Trade-offs

- **Corpus files become shallow API catalogues instead of useful programs** → Keep API breadth in the verified comment table and require each executable body to implement a concrete workflow with observable output.
- **Bind-derived tables drift from the real AS surface** → Require bind/function-library evidence, AS-facing signature confirmation, a related test prefix, and corpus validation for table presence; never infer from native UE names alone.
- **BlueprintLibraries duplicates domain examples** → Require a distinct library-composition workflow, cross-link the domain owner, and reject copied bodies or a second exhaustive API list.
- **Bindings files expose implementation details instead of AS usage** → Permit provider/test filenames only in evidence cells and explanatory comments; keep executable syntax and public symbols strictly AS-facing.
- **README and files drift** → Add bidirectional catalogue validation and update the catalogue in the same task as each theme wave.
- **Root theme scripts affect normal project compilation or cooking** → Treat this as intentional for the host validation project, keep examples dependency-light, and preserve the special `Script/Game` cooked fixture separately.
- **AS tests duplicate C++ Coverage without adding signal** → Normalize by user scenario and use C++ tests as evidence; add AS leaves only when they validate the real project script path or teach a stable behavior.
- **The audit expands into new production binding work** → Record missing public capabilities as explicit gaps and open a focused change instead of modifying Runtime under this test/corpus change.
- **World tests become slow or flaky** → Default to pure tests, create the smallest World variant, use direct tick for exact counts, use deterministic time, and isolate networking in its own wave.
- **Logs become a substitute for assertions** → Require an assertion oracle for every AS test and restrict logs to diagnosis and instructional state transitions.
- **One broad OpenSpec becomes difficult to implement** → Keep five independently verifiable waves, theme prefixes, matrix rows, and per-wave documentation updates; tasks may be rewritten as evidence is learned without changing the capability contracts.

## Migration Plan

1. Build the normalized capability matrices and `binding-library-crosswalk.md` data from current scripts, all 204 binding files, all 87 Bindings test files, all 18 FunctionLibraries test files, and the other owner tests without changing source.
2. Add corpus/test authoring documentation and failing validation coverage before reorganizing scripts.
3. Apply the decision-complete dispositions in `example-migration-map.md` to all 27 current `Script/Examples/**` files and all 9 current `Script/Tests/*.as` files; never move `Script/Game/Example_Actor.as`.
4. Implement Waves 1-4 plus the cross-cutting BlueprintLibraries/Bindings tracks with corpus, AS tests, necessary C++ behavior tests, README entries, evidence-bearing API tables, and focused verification in the same theme task.
5. Implement real Networking coverage as Wave 5, then reconcile every matrix row and manual provider disposition.
6. Replace or remove obsolete placeholder root test fixtures only after source-loading/hot-reload consumers have migrated to meaningful themed files. Keep `Test_ReflectedScriptSuites.as` as the framework reference and record the optional GameplayTags fixture as outside this core change.
7. Run the `ScriptCorpus` suite, affected C++ prefixes, a build, and `All`; store final counts and environment-bound exceptions in the change record before archive.

Rollback is path-scoped: revert the current theme wave, restore its prior example/test files and README entries, and leave completed earlier waves intact. No runtime data migration, serialized asset migration, or public API compatibility layer is required.

## Open Questions

None for the plan-only record. Exact corpus function signatures and native fixture overloads are derived from the audited AS-facing surface within their assigned matrix rows and must not be invented from Unreal C++ APIs during implementation.
