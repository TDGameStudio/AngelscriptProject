# AGENTS.md

## Project Overview

- This file is guidance for AI agents working in `AngelscriptProject`.
- The primary goal is not to extend a regular game project, but to organize, verify, and solidify `Plugins/Angelscript` as a standalone, reusable Angelscript plugin for Unreal Engine. This repository serves as the host project for plugin development and validation; the real deliverable is the `Angelscript` plugin itself.
- The plugin is **no longer in prototype or foundation-building phase**. It has entered a maturity stage where the core runtime, editor integration, and test infrastructure are established, but external delivery entry points and several key capability closures still need attention.
- Current baseline: `AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` three-UE-module structure is stable, with `121` `Bind_*.cpp` files, `27+` CSV state export tables, `1518+` automation test definitions across `430` test `.cpp` files, `DebugServer V2` protocol, `CodeCoverage`, `StaticJIT`, and `BlueprintImpact Commandlet` all landed. GameplayTags support now lives in the optional `AngelscriptGameplayTags` plugin, while `AngelscriptGAS` depends on it for GAS-facing integration. Only `2` tests remain Disabled (both `#ue57-headless` known limitations).
- AngelScript base version is `2.33 + selective 2.38 compatibility`; the fork has diverged too far for a wholesale upgrade — the strategy is to selectively absorb improvements from higher versions. See `Documents/Guides/AngelscriptForkStrategy.md`.
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
│       │   ├── CodeCoverage/                # Per-line coverage tracking
│       │   ├── Testing/                     # Runtime test support
│       │   └── ThirdParty/                  # AngelScript 2.33 vendored source
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

This project is an **Unreal Engine 5.7 plugin** that integrates the AngelScript scripting language as a first-class alternative to Blueprints and C++. The plugin was originally created by Hazelight Games; this repository maintains a diverged fork based on AS 2.33 with selective 2.38 backports.

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

A C# project (`.ubtplugin.csproj`) that plugs into Unreal Build Tool's pipeline. It reads C++ headers, extracts `UFUNCTION`/`UPROPERTY` metadata, and generates `AS_FunctionTable_*.cpp` shards with direct-bind or stub entries. Build artifacts include `AS_FunctionTable_Summary.json` and per-module CSV breakdowns.

### Test Module (AngelscriptTest)

430 test `.cpp` files organized into 28+ thematic directories (Actor, AngelScriptSDK, Bindings, Blueprint, Component, Debugger, Delegate, GC, HotReload, Inheritance, Interface, Networking, Preprocessor, StaticJIT, Subsystem, etc.). Tests use the Automation prefix convention `Angelscript.TestModule.<Theme>.*` for integration tests, `Angelscript.CppTests.*` for runtime C++ unit tests, and `Angelscript.Editor.*` for editor tests. Native AngelScript SDK coverage includes a latest verified `Angelscript.TestModule.AngelScriptSDK` run of `301/301 PASS`, including 151 new Tokenizer/Parser/ScriptNode/Bytecode/Reference coverage cases. See the root testing guides for layering rules.

### Script Examples (`Script/`)

Angelscript `.as` example scripts demonstrating core patterns (actor lifecycle, subsystems, input binding, GAS abilities). Organized under `Script/Examples/Core/`, `Script/Examples/EnhancedInput/`, and `Script/Examples/Extended/`.

### Key Data Flow

1. **Compilation**: `.as` files → Preprocessor → AS Compiler → Bytecode → (optional) StaticJIT → Executable modules
2. **Class Registration**: AS class definitions → ClassGenerator → Live UClass/UStruct with UProperties and UFunctions → Visible to Blueprints and C++
3. **Binding**: C++ types → `Bind_*.cpp` manual bindings + UHT-generated function tables + cross-module direct-bind feature tables + reflective fallback → Callable from AS scripts
4. **Hot Reload**: File watcher detects changes → Recompile affected modules → ClassReloadHelper reinstances actors in editor

### Binding Path Notes

- Cross-module direct bind uses UHT-emitted `AS_FunctionTable_<Module>_CrossModule_*.cpp` shards in the target module OutputDirectory and publishes POD payloads through Core `IModularFeatures`; `AngelscriptRuntime` must not add engine-module link dependencies to resolve these entries.
- Cross-module emit is intentionally limited to safe signatures. Out params, WorldContext injection, ref returns, static arrays, and `TArray` / `TSet` / `TMap` containers remain fallback/deferred unless a later OpenSpec change extends the marshalling contract.
- RPC/Net UFunctions must continue through `BlueprintCallableReflectiveFallback`; direct raw thunk calls would bypass Unreal's RPC routing.
- Any change to `FAngelscriptCrossModuleEntry` or `FAngelscriptCrossModuleFeatureReader` layout requires bumping `Plugins/Angelscript/Source/AngelscriptUHTTool/cross-module-layout-version.txt` and keeping runtime header, generator emit, and tests in sync.

## External Reference Repositories

- See `Reference/README.md` for the full index, pull commands, usage boundaries, and priority guidance.

## Local Configuration

- `AgentConfig.ini` in the project root stores machine-specific paths (e.g., engine root). It is excluded via `.gitignore`.
- On first use, run `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` to generate a template, then fill in local paths.
- Engine paths in build and test commands should be read from `AgentConfig.ini` key `Paths.EngineRoot`.

## Build & Validation Principles

- Build instructions: see `Documents/Guides/Build.md`.
- Test instructions: see `Documents/Guides/Test.md`.
- State dump entry point: `FAngelscriptStateDump::DumpAll()` in `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h`, plus console command `as.DumpEngineState` in `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/`.
- Preserve the dump architecture as a pure external observer: prefer reading existing public APIs over adding intrusive dump hooks to runtime/editor classes.
- If documentation conflicts with the current plugin-centric goal, update the documentation first, then continue implementation.

## Test Number Baselines

- Current test numbers must distinguish three separate scopes; future documents and roadmaps must not conflate them:
  - `275/275 PASS`: catalogued C++ baseline (`TestCatalog.md`).
  - `1518+` automation test definitions across `430` test `.cpp` files: source-code scan scale after `test-as-native-sdk-coverage`.
  - `301/301 PASS`: native AngelScript SDK prefix (`Angelscript.TestModule.AngelScriptSDK`), including 151 new Tokenizer/Parser/ScriptNode/Bytecode/Reference coverage cases.
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
- ✅ Manual bindings for AActor/AController/APawn/APlayerController + Hazelight-style script examples (27 `.as` examples across Core/EnhancedInput/Extended) — merged to main
- ✅ Editor module layout realignment with runtime feature folders — merged to main
- ✅ TObjectPtr routing, UCurveFloat dual registration and multi-engine enum conflict fixes — merged to main
