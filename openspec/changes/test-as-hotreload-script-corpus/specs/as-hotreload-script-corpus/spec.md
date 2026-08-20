## ADDED Requirements

### Requirement: HotReload pairs live in the test script corpus
Reusable HotReload before/after AngelScript SHALL live as files under `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/HotReload/` and SHALL be loaded through `FAngelscriptTestScriptCorpus`. C++ HotReload tests SHALL NOT own a second copy of a corpus pair body once that pair is extracted. Before and after MAY be identical files for no-change cases.

#### Scenario: No-change pair is files not inline strings
- **WHEN** catalog case `no-change` is loaded
- **THEN** before and after source SHALL come from `Fixtures/HotReload/ChangeClassification/no-change/` files
- **AND** the COMPLEX or helper driver SHALL NOT contain a second copy of that UCLASS body

#### Scenario: Host Script tree is not the HotReload corpus
- **WHEN** a HotReload pair is loaded
- **THEN** lookup SHALL use the Fixtures root
- **AND** it SHALL NOT read host `Script/` or `/Angelscript/Game/` paths

### Requirement: Reload uses one identity and swapped content
Each catalog case SHALL declare a single module name and filename used for both versions. The helper SHALL compile version one then analyze or reload version two with that same identity. The TestCorpus virtual path `/Angelscript/Memory/TestCorpus/HotReload/<caseId>.as` SHALL identify the case in logs and corpus metadata.

#### Scenario: Analyze keeps module identity
- **WHEN** case `no-change` compiles then analyzes
- **THEN** both steps SHALL use catalog `module` `ReloadNoChangeMod` and catalog `filename` `ReloadNoChangeMod.as`
- **AND** only the source text MAY differ (for no-change the text SHALL match)

#### Scenario: Virtual path is the corpus key
- **WHEN** a test logs or looks up case `no-change`
- **THEN** the virtual path SHALL be `/Angelscript/Memory/TestCorpus/HotReload/no-change.as`
- **AND** `Parameters` SHALL NOT contain the before or after source

### Requirement: Catalog declares analyze expectations
An `analyze` catalog case SHALL set expected `EReloadRequirement`, `wantsFull`, and `needsFull`. The driver SHALL call existing `CompileAnnotatedModuleFromMemory` and `AnalyzeReloadFromMemory` and SHALL NOT reimplement ClassGenerator policy.

#### Scenario: Unchanged module stays soft
- **WHEN** `no-change` runs
- **THEN** requirement SHALL be `SoftReload`
- **AND** `wantsFull` and `needsFull` SHALL be false

#### Scenario: Function removal requires full reload
- **WHEN** `function-removed` runs with sources extracted from `FunctionRemovedRequiresFullReload`
- **THEN** the leaf SHALL assert the same requirement flags as that existing `TEST_METHOD`
- **AND** it SHALL NOT invent a new ClassGenerator policy

### Requirement: Functional tests may load the same pairs
HotReload CQTest that spawn actors or tick worlds SHALL be allowed to load `kind: functional` pairs from the corpus without registering a DataDriven engine-profile leaf and without requiring a COMPLEX analyze leaf.

#### Scenario: Property preservation uses corpus files
- **WHEN** the property-preserved functional case runs
- **THEN** v1 and v2 SHALL be read from `Fixtures/HotReload/Functional/property-preserved/`
- **AND** the existing spawn and property helpers SHALL still run
- **AND** the test SHALL NOT be an `Angelscript.TestModule.DataDriven` leaf
