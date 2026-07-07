# as-classgenerator-structure Specification

## Purpose
TBD - created by archiving change refactor-classgenerator-decomposition. Update Purpose after archive.
## Requirements
### Requirement: Generator decomposition preserves runtime behavior

The runtime AS-to-Unreal Generator refactor SHALL be behavior-preserving. `ClassGenerator` is the historical directory/change name, but the architectural responsibility includes generated classes, structs, functions, properties, metadata, default-object state, hot-reload identity, and reinstance behavior. Relocating or extracting code within `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator` MUST NOT change hot-reload requirement rules, generated `UClass`/`UStruct`/`UFunction` reflection shapes, `UASFunction_*` dispatch selection, public plugin APIs, or observable runtime/editor behavior.

#### Scenario: Public surface is unchanged

- **WHEN** the decomposition is reviewed outside the ClassGenerator source files
- **THEN** no public API signature, exported symbol, generated reflection contract, or hot-reload semantic MUST change solely to support the decomposition

#### Scenario: Behavior net stays green

- **WHEN** a decomposition batch is completed
- **THEN** the affected `Angelscript.TestModule.*` themes (at minimum `ClassGenerator`, `HotReload`, `NativeScriptHotReload.Phase2A/2B`, `Inheritance`, `Interface`, `Component`, `Actor`, `Delegate`, `GC`) MUST pass with no new failures relative to the pre-refactor baseline

### Requirement: Characterization tests precede code movement

Characterization tests that pin current ClassGenerator behavior SHALL exist and pass before any file split or large-function extraction is performed. These tests MUST cover representative class generation output, reload-requirement decisions, finalize results, and dispatch-variant call results.

#### Scenario: Tests land before decomposition

- **WHEN** a decomposition batch that moves or extracts ClassGenerator code is started
- **THEN** the characterization tests covering that phase MUST already be committed and green

#### Scenario: New tests follow project test conventions

- **WHEN** a characterization test is added under `AngelscriptTest/ClassGenerator`
- **THEN** it MUST conform to `Documents/UnitTest/UnitTest.md` (the `WITH_ANGELSCRIPT_UNITTESTS` gate, in-class `TEST_CLASS_WITH_FLAGS`/`TEST_METHOD` flow, class-level engine lifecycle, matcher assertions, inline-AS `ASTEST_AS` formatting) and, for hot-reload-related gaps, MUST assert externally observable reload behavior and clean up module/delegate handles per method as required by that document's Hot Reload rules

### Requirement: ClassGenerator is split into cohesive single-responsibility units

The ClassGenerator source SHALL be organized so that each translation unit owns one pipeline phase (driver, analyze, reload-planning, full reload, soft reload, generation, finalize, reinstancing) and so that `UASClass`, the `UASFunction` base, and the `UASFunction_*` dispatch variants live in separate units only after the ClassGenerator phase split is stable. The shared `FAngelscriptClassGenerator` type and its data members SHALL remain declared once in `AngelscriptClassGenerator.h` for this change; a private-header/collaborator extraction is a later refactor, not part of the first phase split.

#### Scenario: No monolithic translation unit remains

- **WHEN** the decomposition is complete
- **THEN** no single ClassGenerator `.cpp` MUST retain all pipeline phases, and the giant functions (`Analyze(class)`, `DoSoftReload`, `DoFullReloadClass`, `PerformReload`) MUST be broken into named steps with preserved control flow

#### Scenario: Dispatch variants are tabulated, not copy-pasted

- **WHEN** the `UASFunction_*` dispatch subclasses are refactored
- **THEN** UHT-facing `UCLASS()` declarations MUST remain explicit committed C++ declarations, while any variant list/macro may generate only non-UHT implementation bodies or checked-in generated source, and the produced classes and dispatch behavior MUST be identical to the pre-refactor set

### Requirement: Decomposition respects other in-flight changes

The refactor SHALL NOT duplicate work owned by `refactor-as-audit-remove-with-angelscript-haze` (haze macro / `WILL-EDIT` removal) or by the deferred de-globalization plan. Global-state call sites (`FAngelscriptEngine::Get()` / `CurrentWorldContext`) MAY be relocated but MUST NOT be rewritten as part of this change.

#### Scenario: Overlap is deferred, not duplicated

- **WHEN** the decomposition encounters haze macros, `WILL-EDIT` markers, or global-state access owned by another change
- **THEN** those MUST be left to the owning change (relocated as-is if unavoidable) and recorded in `decomposition-map.md`

