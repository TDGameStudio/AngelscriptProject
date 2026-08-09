# AGENTS.md

## Project Overview

- This file is guidance for AI agents working in `AngelscriptProject`.
- The primary goal is not to extend a regular game project, but to organize, verify, and solidify `Plugins/Angelscript` as a standalone, reusable Angelscript plugin for Unreal Engine. This repository serves as the host project for plugin development and validation; the real deliverable is the `Angelscript` plugin itself.
- The plugin is **no longer in prototype or foundation-building phase**. It has entered a maturity stage where the core runtime, editor integration, and test infrastructure are established, but external delivery entry points and several key capability closures still need attention.
- Current baseline: `AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` three-UE-module structure is stable, with `121` `Bind_*.cpp` files, `27+` CSV state export tables, `1518+` automation test definitions across `430` test `.cpp` files, `DebugServer V2` protocol, `CodeCoverage`, `StaticJIT`, and `BlueprintImpact Commandlet` all landed. GameplayTags support now lives in the optional `AngelscriptGameplayTags` plugin, while `AngelscriptGAS` depends on it for GAS-facing integration. Only `2` tests remain Disabled (both `#ue57-headless` known limitations).
- The current product version is `Unreal AngelScript 1.0.0`; its source lineage is `AngelScript 2.33.0 WIP + selective 2.38 backports`. Product versions advance independently while the fork continues to absorb selected higher-version improvements. See `Documents/Guides/AngelscriptForkStrategy.md`.
- `Plugins/Angelscript/` is the core workspace. The vast majority of implementation, fixes, cleanup, and tests should land here first. `Source/AngelscriptProject/` retains only the minimal host project content — do not push plugin logic back into the project module unless the task explicitly requires it.

## Project Directory Structure

```
AngelscriptProject/
├── AGENTS.md                                # AI guidance (EN) — this file
├── AGENTS_ZH.md                             # AI guidance (ZH)
├── CLAUDE.md                                # Redirect → AGENTS.md
│
├── Plugins/Angelscript/                     # ★ Core deliverable (1619 files)
│   ├── README.md                            # Plugin README for consumers
│   ├── Angelscript.uplugin
│   └── Source/
│       ├── AngelscriptRuntime/              # Runtime module (209 .cpp)
│       │   ├── Core/                        # Engine core, type system, compilation
│       │   ├── Binds/                       # 121 Bind_*.cpp (engine API bindings)
│       │   ├── ClassGenerator/              # Dynamic class gen, hot reload, versioning
│       │   ├── Debugging/                   # DebugServer V2 (DAP protocol)
│       │   ├── StaticJIT/                   # Static JIT compilation
│       │   ├── Preprocessor/                # Script preprocessor (#include, #if)
│       │   ├── FunctionLibraries/           # 21 mixin helper libraries
│       │   ├── Subsystem/                   # Script subsystem base classes
│       │   ├── Dump/                        # 27+ CSV state export tables
│       │   ├── Extension/CodeCoverage/      # Per-line coverage tracking (engine extension)
│       │   ├── Testing/                     # Runtime-owned AngelScript test framework
│       │   └── ThirdParty/                  # Vendored fork with 2.33 WIP lineage
│       ├── AngelscriptEditor/               # Editor module (49 .cpp)
│       │   ├── HotReload/                   # File watcher & class reinstancing
│       │   ├── CodeGen/                     # Editor-time code gen for IDE
│       │   ├── BlueprintImpact/             # BP change scanner & commandlet
│       │   ├── SourceNavigation/            # Jump-to-source support
│       │   └── ContentBrowser/              # .as files in Content Browser
│       ├── AngelscriptTest/                 # Test module (430 .cpp, 28+ themes)
│       └── AngelscriptUHTTool/              # UHT C# code gen toolchain
│
├── Plugins/AngelscriptGameplayTags/         # Optional GameplayTags extension plugin
│   ├── Source/
│   │   ├── AngelscriptGameplayTags/         # Runtime GameplayTag bindings and replay
│   │   ├── AngelscriptGameplayTagsEditor/   # GameplayTag change listener and reload bridge
│   │   └── AngelscriptGameplayTagsTest/     # GameplayTags-specific automation tests
│
├── Source/                                  # Host project (minimal, 8 files)
├── Script/                                  # AngelScript examples (37 .as)
│   ├── Examples/                            # Core / EnhancedInput / Extended
│   ├── Automation/                          # Script automation entry
│   └── Tests/                               # Script-level tests
│
├── Extensions/                              # Project-owned external development tools
│   └── AngelscriptVSCode/                   # VS Code Language Server / Debug Adapter
│
├── Reference/
│   └── README.md                            # Repo index, pull cmds, priorities
│
├── .agents/skills/
│   └── README.md                            # OpenSpec workflow & skill guide
│
├── openspec/                                # ★ Active change lifecycle (48 files)
│   ├── changes/                             # In-progress & archived changes
│   └── specs/                               # Shared specifications
│
├── Documents/
│   ├── Guides/
│   │   ├── Build.md                         # Build commands & execution
│   │   ├── Test.md                          # Test runner & suite usage
│   │   ├── TestCatalog.md                   # Catalogued baseline (275/275)
│   │   ├── TestConventions.md               # Test naming & org conventions
│   │   ├── TestPerformance.md               # Performance benchmarks
│   │   ├── TestMacroStatus.md               # Macro migration status
│   │   ├── TestFixSummary_20260430.md       # Fix snapshot 2026-04-30
│   │   ├── TechnicalDebtInventory.md        # Tech debt & live suite status
│   │   ├── AngelscriptForkStrategy.md       # Fork strategy (selective)
│   │   ├── ASSDK_Fork_Differences.md        # ASSDK fork differences
│   │   ├── GlobalStateContainmentMatrix.md  # Global state containment
│   │   ├── BindGapAuditMatrix.md            # Binding gap audit
│   │   ├── BlueprintTypeBindingsOptimization.md # BP type binding optimization
│   │   ├── VSCodeAngelscript.md              # Project-owned VS Code extension workflow
│   │   └── UE_Search_Guide.md               # UE knowledge lookup
│   ├── Rules/
│   │   ├── GitCommitRule.md                 # Commit conventions (EN)
│   │   └── ASInlineFormattingRule.md        # Inline AS formatting in C++ tests
│   ├── Plans/                               # ⚠ Legacy only — use openspec/
│   │   ├── Plan_StatusPriorityRoadmap.md    # Historical status snapshot
│   │   ├── Plan_OpportunityIndex.md         # Historical opportunity index
│   │   ├── Archives/                        # Archived Plans
│   │   └── ...                              # 84 legacy Plan_*.md
│   ├── Knowledges/ZH/
│   │   ├── Index.md                         # Index for 32 knowledge articles
│   │   └── ...                              # AS internals, syntax, types...
│   ├── Reports/                             # Generated review reports (505)
│   ├── Hazelight/                           # Hazelight reference notes (3)
│   └── Tools/
│       └── Tool.md                          # Internal tool documentation
│
├── Tools/                                   # Build/test/diagnostic scripts
│   ├── RunBuild.ps1                         # Build entry
│   ├── RunTests.ps1                         # Test entry
│   ├── RunTestSuite.ps1                     # Suite runner
│   ├── Bootstrap/                           # First-time setup
│   ├── Shared/                              # Shared utility modules
│   ├── Diagnostics/                         # Health check & debug
│   └── PullReference/                       # Reference repo pull
│
└── Config/                                  # UE project config (4 .ini)
```

## Architecture Overview

This project is an **Unreal Engine 5.7 plugin** that integrates the AngelScript scripting language as a first-class alternative to Blueprints and C++. Its current product identity is `Unreal AngelScript 1.0.0`. The plugin was originally created by Hazelight Games; the underlying source retains AngelScript 2.33 WIP lineage with selective 2.38 backports, but those upstream numbers are no longer the product version.

### Module Dependency Graph

```
AngelscriptRuntime  (Runtime module, no intra-plugin dependencies)
       │
       ├──► AngelscriptEditor  (Editor module, public dependency on Runtime)
       │
       └──► AngelscriptTest    (Editor module, public dependency on Runtime,
                                private dependency on Editor when bBuildEditor)

AngelscriptGameplayTags  (Runtime module, public dependency on Runtime; optional)
       │
       ├──► AngelscriptGameplayTagsEditor  (Editor module, GameplayTags delegate/reload bridge)
       └──► AngelscriptGameplayTagsTest    (Editor module, GameplayTags-specific tests)

AngelscriptGAS  (Runtime module, public dependency on Runtime + AngelscriptGameplayTags)

AngelscriptUHTTool  (C# UBT plugin, independent — hooks into Unreal Header Tool pipeline)
```

All three UE modules load at `PostDefault` phase. `AngelscriptRuntime` owns the editor/commandlet bootstrap through `UAngelscriptEngineSubsystem`, while `FAngelscriptRuntimeModule::InitializeAngelscript()` remains a compatibility API and routes to that subsystem when `GEngine` is available. `UAngelscriptGameInstanceSubsystem` owns world/game-instance contexts and suppresses the engine-subsystem fallback tick while an active game-instance tick owner exists. The host project module `AngelscriptProject` is intentionally minimal — it exists only to give UE a valid target; all real logic belongs in the plugin.

### Editor Subsystems (AngelscriptEditor)

- **Hot Reload** (`HotReload/`): `DirectoryWatcher` monitors `.as` files; `ClassReloadHelper` handles live reinstancing of modified script classes in the editor.
- **Code Gen** (`CodeGen/`): Editor-time code generation (~84 KB) for IDE support and API stubs.
- **Blueprint Impact** (`BlueprintImpact/`): Scanner and Commandlet that analyze which Blueprints are affected by script changes, enabling targeted recompilation.
- **Source Navigation** (`SourceNavigation/`): Allows jumping from UE editor elements directly to the corresponding `.as` source file and line.
- **Content Browser** (`ContentBrowser/`): Custom data source so `.as` scripts appear in the UE Content Browser.

### UHT Tool (AngelscriptUHTTool)

A C# project (`.ubtplugin.csproj`) that plugs into Unreal Build Tool's pipeline. It reads C++ headers, extracts `UFUNCTION`/`UPROPERTY` metadata, and generates `AS_FunctionBinding_*.cpp` shards selected by `FunctionBindingMethod`. Build artifacts include `AS_FunctionBindingStatistics.json` and per-module CSV breakdowns.

### Runtime AngelScript Test Framework (`AngelscriptRuntime/Testing`)

`AngelscriptRuntime/Testing/` owns the AngelScript language-level test protocol: test discovery, registration, execution, latent/network support, and the UE Automation bridge used to expose AS tests to the host runner. `UnitTest.*` and `IntegrationTest.*` describe AS test functions and runners; they are not C++ unit tests in the `AngelscriptRuntime` module.

### Test Module (AngelscriptTest)

430 test `.cpp` files organized into 28+ thematic directories (Actor, AngelScriptSDK, Bindings, Blueprint, Component, Debugger, Delegate, GC, HotReload, Inheritance, Interface, Networking, Preprocessor, StaticJIT, Subsystem, etc.). This module owns C++ automation tests, CQTest, AngelScript SDK tests, and test fixtures. Tests use the Automation prefix convention `Angelscript.TestModule.<Theme>.*` for integration tests, `Angelscript.CppTests.*` for runtime C++ unit tests, and `Angelscript.Editor.*` for editor tests. Native AngelScript SDK tests are organized across Engine, Frontend, Compiler, Runtime, Module, TypeSystem, Language, Embedding, and Conformance; the latest full active prefix run on 2026-07-31 is `691/691 PASS`, with fourteen discoverable Disabled `#as-v238-backport` future-script methods. See the root testing guides for layering rules.

### Script Examples (`Script/`)

Angelscript `.as` example scripts demonstrating core patterns (actor lifecycle, subsystems, input binding, GAS abilities). Organized under `Script/Examples/Core/`, `Script/Examples/EnhancedInput/`, and `Script/Examples/Extended/`.

### Key Data Flow

1. **Compilation**: `.as` files → Preprocessor → AS Compiler → Bytecode → (optional) StaticJIT → Executable modules
2. **Class Registration**: AS class definitions → ClassGenerator → Live UClass/UStruct with UProperties and UFunctions → Visible to Blueprints and C++
3. **Binding**: C++ types → `Bind_*.cpp` manual bindings + UHT-generated FunctionBinding shards + target-module native function-address features + reflective fallback → Callable from AS scripts
4. **Hot Reload**: File watcher detects changes → Recompile affected modules → ClassReloadHelper reinstances actors in editor

### Standalone compilation and offline UE analysis

- `Plugins/Angelscript/Standalone/` uses CMake to compile the same maintained fork and compiles its private standard-C++ frontend directly into `AngelscriptStandaloneHost`. It neither includes nor links Unreal Engine and does not require a shared Runtime `Language/` layer. UE keeps its original `FAngelscriptPreprocessor` and descriptor graph as the authoritative implementation; the two hosts exchange only the complete offline JSON bundle.
- The `native-runtime` profile compiles and executes bounded native AngelScript. Its standard library is limited to UTF-8 string, array, dictionary, math, print, and assert; default time/memory limits apply and file, network, process, dynamic-library, and arbitrary FFI APIs are absent.
- The `ue-validation` profile is compile/analyze-only. It consumes one complete `default-engine` or explicit project JSON bundle and registers UE declarations through non-executable traps. Its artifacts are not UE-loadable bytecode, and UE execution or UObject/GC/World/ClassGenerator simulation is forbidden.
- The UE-side `AngelscriptOfflineExport` commandlet observes the final initialized engine surface. Manual `Bind_*.cpp`, generated bindings, reflective fallback, and ClassGenerator do not gain standalone branches or exporter macros.
- An explicit project bundle replaces the packaged default completely; v1 performs no merge or cache search and never falls back after an invalid explicit selection. See `Documents/Guides/AngelscriptStandaloneOfflineBundle.md`.
- For UE validation, `--script-root` denotes the project's `Script/` root. Relative logical paths map to `/Angelscript/Game/<logical-path>` for offline stable-module identity so current source exactly replaces its exported script baseline. V1 does not guess arbitrary directories as plugin or memory mounts.

### Binding Path Notes

- `NativeRuntimeLinked` uses UHT-emitted `AS_FunctionBinding_<Module>_*.gen.cpp` shards compiled through dynamically configured `AngelscriptRuntime` dependencies. `NativeModuleFunctionAddress` uses explicit target-module `AS_FunctionBinding_<Module>_NativeModuleFunctionAddress_*.cpp` shards and publishes POD payloads through Core `IModularFeatures`; it is source-engine-only.
- Cross-module emit is intentionally limited to safe signatures. Out params, WorldContext injection, ref returns, static arrays, and `TArray` / `TSet` / `TMap` containers remain fallback/deferred unless a later OpenSpec change extends the marshalling contract.
- RPC/Net UFunctions must continue through `BlueprintCallableReflectiveFallback`; direct raw thunk calls would bypass Unreal's RPC routing.
- Any change to `FAngelscriptNativeModuleFunctionBinding` or `FAngelscriptNativeModuleFunctionBindingView` layout requires bumping `Plugins/Angelscript/Source/AngelscriptUHTTool/native-module-function-binding-layout-version.txt` and keeping the Runtime bridge, generator emit, and tests in sync.

## External Reference Repositories

- See `Reference/README.md` for the full index, pull commands, usage boundaries, and priority guidance.
- AngelscriptWiki theme/document-plugin migration references are pinned beneath `Reference\tiddlywiki-*`: itonnote theme/plugin, TiddlySeq, command palette, preview-glass source, and CodeMirror 6. The selected Markdown More source is separately imported from `cdruan/tw-markdown-more` beneath `Wiki/vendor/tw-markdown-more/` at the commit recorded by `Wiki/external-plugins.json`; it supplies Markdown checklist, admonition, TOC, and example-block rendering and has priority whenever those Wiki surfaces change. `Wiki/vendor/` is the fixed runtime submodule source and normal builds do not update it over the network.
- TW Icons is pinned at `Reference\tw-icons` from `https://github.com/morosanuae/tw-icons.git`, commit `d4a58efeddaa683af69fba1a43717a16e4f0d2ca` (`v1.10`). It is a 56 MiB standalone TiddlyWiki icon catalogue rather than a split plugin source tree. Use it only as a **lowest-priority**, offline catalogue when manually selecting an occasional icon; it is not a runtime dependency, must never be imported wholesale, and each selected icon library needs its own license review because the repository has no repository-level license.
- Kookma TW5 plugin and extension sources are retained beneath `Reference\kookma\`: every reachable upstream is an independent SSH Git clone, while `TW-PluginLibrary` also preserves the packaged catalogue snapshots. They are source references for secondary development of WikiText, macros, components, styles, and authoring workflows; they are not runtime dependencies or normal `Wiki/` build inputs. Before changing AngelScript-native document components, inspect this local source first; product code must be integrated under the TDGameStudio namespace in `Wiki/src/` only after licence and global-template impact review.
- AngelScript code-generator research references are maintained at `Reference\fuzzilli`, `Reference\grammarinator`, `Reference\csmith`, `Reference\yarpgen`, and `Reference\creduce`. Fuzzilli is the primary ASIR / ProgramBuilder architecture reference; Grammarinator is parser-fuzz-only; Csmith and YARPGen inform controlled valid programs and behavioral oracles; C-Reduce informs failing-case reduction. They are offline analysis/design references only, never runtime dependencies or automatic network inputs.

## Local Configuration

- `AgentConfig.ini` in the project root stores machine-specific paths (e.g., engine root). It is excluded via `.gitignore`.
- On first use, run `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` to generate a template, then fill in local paths.
- Engine paths in build and test commands should be read from `AgentConfig.ini` key `Paths.EngineRoot`.

## Build & Validation Principles

- Build instructions: see `Documents/Guides/Build.md`.
- Test instructions: see `Documents/Guides/Test.md`.
- Build and validate Standalone Debug through `Tools\RunTestSuite.ps1 -Suite Standalone`; build the final Win64 ZIP and run Release CTest through the independent `-Suite StandaloneRelease`. Both configurations currently have `19/19` CTests, and their reports/counts remain separate from UE Automation, NativeCore, and catalogued C++ baselines.
- Before release, run `Tools\RunStandaloneExternalSmoke.ps1`; it creates a transient external project with no C++ host module, exports the Project bundle twice for byte determinism, and consumes it with the CLI extracted from the final Release ZIP.
- State dump entry point: `FAngelscriptStateDump::DumpAll()` in `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h`, plus console command `as.DumpEngineState` in `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/`. The dump API also exposes `CaptureSnapshot`, `DiffSnapshots`, `DumpSnapshot`, and `DumpDiff`; `DumpAll()` writes `EngineStateSnapshot.csv` and category snapshot tables, while diff helpers write `StateDiff.csv` and `StateDiffSummary.csv`.
- Preserve the dump architecture as a pure external observer: prefer reading existing public APIs over adding intrusive dump hooks to runtime/editor classes.
- If documentation conflicts with the current plugin-centric goal, update the documentation first, then continue implementation.

## Test Number Baselines

- Current test numbers must distinguish the following independent scopes; future documents and roadmaps must not conflate them:
  - `275/275 PASS`: catalogued C++ baseline (`TestCatalog.md`).
  - `1518+` automation test definitions across `430` test `.cpp` files: source-code scan scale after `test-as-native-sdk-coverage`.
  - `691/691 PASS`: latest active native AngelScript SDK prefix on 2026-07-31 (`Angelscript.TestModule.AngelScriptSDK`), plus fourteen discoverable Disabled `#as-v238-backport` future-script methods.
  - `2396/2396 PASS`: final configured `All` suite across 35 prefixes on 2026-07-28; all reports have zero failures, skips, and timeouts.
  - `19/19 PASS`: independent Standalone CMake/CTest scope; Debug and Release are configurations of the same tests, not additive counts and not replacements for UE Automation numbers.
  - Live full-suite run results: defer to the actual numbers in `TechnicalDebtInventory.md`.
  - Only `2` tests remain Disabled (`#ue57-headless`): `TestEngineHelperTests.cpp:106` and `SourceNavigationTests.cpp:125`.

## Documentation Maintenance Principles

- When plugin boundaries, module responsibilities, build steps, or test entry points change, update related documentation in sync.
- Chinese documentation is updated first in `Agents_ZH.md` or the corresponding Chinese guide; avoid updating only the English version.
- If legacy project information is still valuable, summarize it as migration rules or structural notes rather than keeping it as scattered background remarks.
- When adding new external reference repositories or local reference paths, add "purpose + path + priority" to this file to reduce future lookup cost.

## Git & Commits

- Full commit guide: `Documents/Rules/GitCommitRule.md`.
- Format: `[<Scope>] <Type>: <description>` — Scope is optional (module/feature area), Type is required (`Fix`, `Feat`, `Refactor`, `Docs`, `Test`, `Chore`), description is a concise outcome-focused summary. Example: `[Angelscript] Feat: add FTransform mixin bindings for script access`.
- Do not append tool-generated commit trailers (for example `Made-with: Cursor`) unless explicitly requested.
- The default publish branch is `main`. If a local clone still uses `master`, create or switch to `main` before the first push.
- For first-time GitHub remote setup, use `git remote add origin <your-remote-url>`, then `git push -u origin main` to establish upstream tracking.
- If `origin` already exists but points to another repository, update it with `git remote set-url origin <your-remote-url>` instead of adding a duplicate remote.
- Do not force-push `main` unless the user explicitly requests it.

## Submodule & Worktree

- Default editing location is the current workspace/main checkout. Do **not** create, switch to, or continue work inside a git worktree unless the user explicitly asks to create/use a worktree for that task.
- The plugin directories (`Plugins/Angelscript`, `Plugins/AngelscriptGameplayTags`, `Plugins/AngelscriptGAS`) are **git submodules**, not ordinary directories. `git worktree add` does not initialize them.
- One-shot setup: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\NewWorktree.ps1 -Name <change-name>` creates the parent worktree, initializes/fallbacks all submodules, writes `AgentConfig.ini`, and scaffolds an empty `openspec/changes/<change-name>/` directory in one step.
- `BootstrapWorktree.ps1` remains the entry point for re-initializing an *existing* worktree (e.g. after switching engine root). It is invoked internally by `NewWorktree.ps1`; you only need to call it directly when fixing up a worktree that already exists.
- When the target code lives inside a submodule, it is a dual-repo change: OpenSpec artifacts in the parent, source code in the submodule. Commit submodule first, then update the parent gitlink.
- Full workflow, fallback strategies, scope guards, and troubleshooting: **`Documents/Guides/SubmoduleWorktreeWorkflow.md`**.

## OpenSpec & TODO

- `Documents/Plans/` is **deprecated** — retained for historical reference only. All new planning, design, task tracking, and archive lifecycle uses OpenSpec under `openspec/changes/<change>/`.
- OpenSpec is a lightweight **record**, not a procedural gate. There is a single skill, `openspec-work`, covering the whole lifecycle (explore + record + implement + archive, one flow). The former `openspec-explore`, `openspec-propose`, `openspec-apply-change`, and `openspec-archive-change` are all merged into it; explore/think work uses `superpowers:brainstorming` inside `openspec-work`.
- Use `openspec-work` (or `/opsx:work`, also reachable via `/opsx:propose` / `/opsx:apply`) to create or continue a change. There is no phase wall: you may record intent only and stop, record while implementing, or continue implementing later — editing OpenSpec artifacts and code together, in any order. The initial plan is disposable; overturn and rewrite `tasks.md` as you learn.
- Record depth follows intent. A **plan-only deliverable** (plan now, implement later) is a first-class mode: produce a thorough, ready-to-execute plan (file map, bite-sized tasks, exact verification commands, at `superpowers:writing-plans` quality), then stop without implementing — not a minimal skeleton. The "record + implement now" mode may instead start from a lean record and expand as it goes.
- Keep using Superpowers methods actively (brainstorming, TDD, systematic-debugging, verification-before-completion). What is relaxed is OpenSpec's own ceremony, not the engineering discipline. Verify at key milestones (not every step); verification may itself be an explicit task in `tasks.md`.
- The change directory is **free-form storage**: beyond `proposal/design/specs/tasks`, you may keep background notes, research, performance/benchmark data (`benchmarks/*.csv`), and logs under `openspec/changes/<name>/`. Keep `tasks.md` a clean checklist and put commentary/data in separate files.
- Archiving is an ordinary closing action handled inside `openspec-work` (`/opsx:archive`) via `openspec archive "<name>"` — not a verification gate. Incomplete tasks or a rewritten plan do not block archiving.
- For small, local, low-risk changes that don't affect behavior, architecture, or public APIs, ask the user whether to skip OpenSpec. If the user explicitly requests skipping, record the reason briefly.
- TODOs should be broken down around the plugin goal. When renaming, migrating modules, or adjusting public APIs, identify all affected files and documentation.

## Recently Completed Milestones

- ✅ Test execution infrastructure (unified runner, group taxonomy, structured summaries) — archived
- ✅ Build/test script standardization (shared execution layer, `RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`) — archived
- ✅ Callfunc dead code cleanup — archived
- ✅ Engine state dump system (27 CSV tables, console command, automation regression) — archived
- ✅ Test macro optimization (`BEGIN/END`, `SHARE_CLEAN/SHARE_FRESH`, group closure) — archived
- ✅ Technical debt Phase 0-6 closure — archived
- ✅ UFunction reflective fallback binding — archived
- ✅ UHT tool plugin generated function tables and legacy shard removal — merged to main
- ✅ BlueprintImpact Commandlet and editor integration — merged to main
- ✅ UE 5.7 binding and debugger adaptation (38 + 16 Disabled tests re-enabled) — merged to main
- ✅ Script Subsystem closure (WorldSubsystem/GameInstanceSubsystem from negative to positive tests) — merged to main
- ✅ Network RPC compilation tests (Server/Client/NetMulticast + WithValidation + Unreliable) — merged to main
- ✅ Inactive `WITH_ANGELSCRIPT_HAZE` branch removal, Haze-only RPC syntax cleanup, debugger Haze flag removal, and UE-original actor instigator names — implemented in `refactor-as-audit-remove-with-angelscript-haze`
- ✅ Manual bindings for AActor/AController/APawn/APlayerController + Hazelight-style script examples (27 `.as` examples across Core/EnhancedInput/Extended) — merged to main
- ✅ Editor module layout realignment with runtime feature folders — merged to main
- ✅ TObjectPtr routing, UCurveFloat dual registration and multi-engine enum conflict fixes — merged to main
- ✅ TDGameStudio-owned VS Code Angelscript extension imported with DebugDatabaseSettings wire compatibility coverage — implemented in `fix-vscode-lsp-protocol-compat`
