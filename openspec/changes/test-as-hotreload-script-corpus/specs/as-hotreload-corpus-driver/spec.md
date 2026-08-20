## ADDED Requirements

### Requirement: Analyze pairs expand to HotReload Corpus Automation leaves
The Angelscript test module SHALL register a handwritten COMPLEX `FAutomationTestBase` (`bInComplexTask` true) under `AngelscriptTest/HotReload/` that expands each `kind: analyze` catalog case into one leaf under `Angelscript.TestModule.HotReload.Corpus`. The class SHALL NOT be `FAngelscriptDataDrivenAutomation`, SHALL NOT use `IMPLEMENT_COMPLEX_AUTOMATION_TEST`, and SHALL NOT list engine profiles `vm`, `cache-roundtrip`, `typed-ast-generate`, or `runtime-jit`.

#### Scenario: No-change is an independent leaf
- **WHEN** catalogs include `no-change`
- **THEN** enumeration SHALL include `Angelscript.TestModule.HotReload.Corpus.no-change`
- **AND** `OutTestCommands` SHALL be a key such as `HotReload/no-change`
- **AND** the command SHALL NOT contain JSON, `@file`, or packed expected flags

#### Scenario: Unit-test gate omits the bridge
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** the HotReload COMPLEX bridge SHALL NOT register

### Requirement: The HotReload COMPLEX uses a per-leaf session
The registered instance SHALL hold a pair catalog snapshot only and SHALL NOT store `FAngelscriptEngine*` or generated `UClass*` across `RunTest` calls. Each `RunTest` SHALL construct a session that compiles, analyzes, discards the module, and emits `[AS-HR-DRIVER]`.

#### Scenario: Sequential leaves do not leak modules
- **WHEN** `no-change` and `function-removed` run in sequence on the same COMPLEX instance
- **THEN** the second leaf SHALL NOT observe the first case's module as a member on the registered object
- **AND** each leaf SHALL `DiscardModule` its catalog module

#### Scenario: Driver card names the pair
- **WHEN** `no-change` runs
- **THEN** `ExecutionInfo` SHALL contain an Info entry starting with `[AS-HR-DRIVER]`
- **AND** that entry SHALL include `key=HotReload/no-change` and `kind=analyze`
- **AND** failures SHALL repeat the card in the error text

#### Scenario: Failed analyze dumps both sources
- **WHEN** an analyze leaf fails to compile or match expectations
- **THEN** the log SHALL contain `[AS-SOURCE-BEGIN]` dumps for before and after
- **AND** `GetTestSourceFileName` SHALL return the before fixture path

### Requirement: Engine-profile harness does not own HotReload
DataDriven engine-matrix leaves SHALL NOT grow HotReload observation kinds in this change. HotReload corpus leaves SHALL NOT require `profiles` arrays of JIT or cache ids.

#### Scenario: Corpus leaf is not a DataDriven profile
- **WHEN** `no-change` is enumerated
- **THEN** its beautified name SHALL start with `Angelscript.TestModule.HotReload.Corpus`
- **AND** it SHALL NOT start with `Angelscript.TestModule.DataDriven`
- **AND** `RunTest` SHALL NOT invoke the DataDriven `RunCase` engine-profile path

### Requirement: Existing HotReload CQTest remains until dual-run
Wave A SHALL keep `AngelscriptHotReloadChangeClassificationTests` methods for extracted cases until the matching Corpus leaves pass. Wave A SHALL NOT delete PIE, networking, BlueprintImpact, or file-removal tests.

#### Scenario: Classification methods still discover
- **WHEN** prefix `Angelscript.TestModule.HotReload.ChangeClassification` runs after Wave A goldens land
- **THEN** `NoChange`, `SoftReloadRequirement`, and `FunctionRemovedRequiresFullReload` SHALL still be discovered
- **AND** they SHALL still pass
