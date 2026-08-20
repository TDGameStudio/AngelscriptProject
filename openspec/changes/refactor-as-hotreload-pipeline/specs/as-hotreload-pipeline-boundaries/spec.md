## ADDED Requirements

### Requirement: Hot reload has frozen stage ownership
The plugin SHALL treat hot reload as a staged pipeline with Runtime owning compile, classify, and type apply; Editor owning directory watching, object/Blueprint recovery, and Blueprint impact; tests owning evidence only. Runtime SHALL NOT refresh BlueprintActionDatabase or Class Viewer. Editor SHALL NOT reimplement descriptor comparison or `FAngelscriptClassReloadPlanner` policy.

#### Scenario: Watcher does not classify
- **WHEN** DirectoryWatcher queues a modified `.as` path
- **THEN** that path SHALL enter Engine reload file queues
- **AND** the watcher SHALL NOT set `EReloadRequirement`

#### Scenario: ClassGenerator does not recover editor caches
- **WHEN** `PerformSoftReload` or `PerformFullReload` finishes
- **THEN** Runtime SHALL notify via engine-owned reload delegates
- **AND** `FClassReloadHelper` SHALL remain the Editor subscriber that updates objects and editor caches

#### Scenario: Engine-matrix harness is not the HotReload driver
- **WHEN** a catalog lists engine profiles `vm` or `cache-roundtrip`
- **THEN** that catalog SHALL NOT be used as the HotReload classify/reinstance driver
- **AND** HotReload pair tests SHALL live under `Angelscript.TestModule.HotReload`

### Requirement: Two signal sources share one Tick consumer
Editor DirectoryWatcher and standalone `bScriptDevelopmentMode` file-time polling SHALL both feed `FileChangesDetectedForReload` / `FileDeletionsDetectedForReload`. `FAngelscriptEngine::CheckForHotReload` SHALL remain the Tick consumer. A refactor SHALL NOT invent a third compile entry that bypasses `PerformHotReload` for ordinary `.as` saves.

#### Scenario: Editor save still goes through PerformHotReload
- **WHEN** an Editor-watched `.as` save is processed
- **THEN** `PerformHotReload` SHALL run on the game/editor thread via `CheckForHotReload`
- **AND** ClassGenerator Setup SHALL still produce `EReloadRequirement`

#### Scenario: Compile failure keeps old code
- **WHEN** preprocess or compile fails inside `PerformHotReload`
- **THEN** the previously executable module SHALL remain callable
- **AND** diagnostics SHALL be available
- **AND** the pipeline SHALL NOT discard the old type as a success path

### Requirement: Test corpus is a sibling not a ClassGenerator rewrite
Reusable HotReload before/after sources SHALL be introduced by `test-as-hotreload-script-corpus` using `FAngelscriptTestScriptCorpus`. This pipeline change SHALL NOT require rewriting `AngelscriptClassGenerator_Analyze.cpp` to land that corpus.

#### Scenario: Analyze goldens do not need Analyze.cpp edits
- **WHEN** corpus cases `no-change` and `function-removed` run
- **THEN** they SHALL call existing `CompileAnnotatedModuleFromMemory` and `AnalyzeReloadFromMemory`
- **AND** `AngelscriptClassGenerator_Analyze.cpp` SHALL NOT be required to change for those goldens
