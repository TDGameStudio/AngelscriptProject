# AGENTS.md

## Purpose

- This file is guidance for AI agents working in `AngelscriptProject`.
- The primary goal is not to extend a regular game project, but to organize, verify, and solidify `Plugins/Angelscript` as a standalone, reusable Angelscript plugin for Unreal Engine.
- This repository serves as the host project for plugin development and validation; the real deliverable is the `Angelscript` plugin itself.

## Current Project Phase

- The plugin is **no longer in prototype or foundation-building phase**. It has entered a maturity stage where the core runtime, editor integration, and test infrastructure are established, but external delivery entry points and several key capability closures still need attention.
- Current baseline: `AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` three-UE-module structure is stable, with `124` `Bind_*.cpp` files, `27+` CSV state export tables, `417+` automation test definitions across `429` test `.cpp` files (387 Test + 32 Editor + 10 Runtime), `DebugServer V2` protocol, `CodeCoverage`, `StaticJIT`, and `BlueprintImpact Commandlet` all landed. Editor and commandlet startup initialization is owned by the native runtime `UAngelscriptEngineSubsystem`. Only `2` tests remain Disabled (both `#ue57-headless` known limitations).
- AngelScript base version is `2.33 + selective 2.38 compatibility`; the fork has diverged too far for a wholesale upgrade — the strategy is to selectively absorb improvements from higher versions. See `Documents/Guides/AngelscriptForkStrategy.md`.
- Current priority order: **known blockers & delivery baseline → onboarding assets & workflow entry points → feature parity & validation closure → AS 2.38 selective migration & long-term architecture**. See `Documents/Plans/Plan_StatusPriorityRoadmap.md` for details.

## Current Project Positioning

- `Plugins/Angelscript/` is the core workspace. The vast majority of implementation, fixes, cleanup, and tests should land here first.
- `Source/AngelscriptProject/` retains only the minimal host project content. Do not push plugin logic back into the project module unless the task explicitly requires it.

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

AngelscriptUHTTool  (C# UBT plugin, independent — hooks into Unreal Header Tool pipeline)
```

All three UE modules load at `PostDefault` phase. `AngelscriptRuntime` owns the editor/commandlet bootstrap through `UAngelscriptEngineSubsystem`, while `FAngelscriptRuntimeModule::InitializeAngelscript()` remains a compatibility API and routes to that subsystem when `GEngine` is available. `UAngelscriptGameInstanceSubsystem` owns world/game-instance contexts and suppresses the engine-subsystem fallback tick while an active game-instance tick owner exists. The host project module `AngelscriptProject` is intentionally minimal — it exists only to give UE a valid target; all real logic belongs in the plugin.

### Core Subsystems (AngelscriptRuntime)

- **Engine Core** (`Core/`): `AngelscriptEngine` is the central singleton (~184 KB) managing script compilation, module building, type registration, and the 4-stage compilation flow (parse → preprocess → compile → link). `UAngelscriptEngineSubsystem` performs Editor/Commandlet bootstrap and fallback ticking when no game-instance subsystem owns ticking. `AngelscriptType` handles AS↔UE type mapping. `AngelscriptBinds` provides the registration framework that all `Bind_*.cpp` files use.
- **Bindings** (`Binds/`): ~151 `Bind_*.cpp` files that expose UE types (math, actor, component, physics, UI/UMG, delegates, containers, JSON, GAS, EnhancedInput, etc.) to AngelScript. Includes a `BlueprintCallableReflectiveFallback` path for UFunctions without explicit bindings.
- **Class Generator** (`ClassGenerator/`): Converts AngelScript class definitions into live `UClass`/`UStruct` objects at runtime. `ASClass` (~97 KB) and `AngelscriptClassGenerator` (~202 KB) handle property layout, function stubs, hot-reload version chaining, and Blueprint-visible metadata.
- **Preprocessor** (`Preprocessor/`): Full preprocessor (~134 KB) handling `#include`, `#if`, conditional compilation, and comment-format documentation extraction before scripts reach the AS compiler.
- **Static JIT** (`StaticJIT/`): Compiles AS bytecode into optimized native-like execution. `AngelscriptBytecodes` (~200 KB) handles bytecode analysis; `AngelscriptStaticJIT` (~117 KB) does the actual code generation; `PrecompiledData` (~93 KB) manages serialization of precompiled modules.
- **Debug Server** (`Debugging/`): DAP-compatible debug server (~96 KB) supporting breakpoints, stepping, variable inspection, and call stack navigation over a TCP socket.
- **Script Base Classes** (`BaseClasses/`): `ScriptWorldSubsystem`, `ScriptGameInstanceSubsystem`, `ScriptEngineSubsystem`, `ScriptLocalPlayerSubsystem` — UE subsystem base classes designed for script inheritance.
- **Function Libraries** (`FunctionLibraries/`): 21+ mixin libraries adding helper methods to math types, actors, components, GameplayTags, widgets, etc.
- **Dump Infrastructure** (`Dump/`): 27+ CSV table exporters that observe runtime state (registered types, bindings, functions, enums) through public APIs. Pure external observer — never mutates runtime state.
- **Code Coverage** (`CodeCoverage/`): Per-line coverage tracking and HTML/JSON report generation for AngelScript code.
- **GAS Integration** (`Core/GAS/`): 18 files providing scripted base classes and utility libraries for Gameplay Ability System.
- **Third-party AS engine** (`ThirdParty/angelscript/`): The vendored AngelScript 2.33 source with local patches. Not upgradable wholesale — selective backports only.

### Editor Subsystems (AngelscriptEditor)

- **Hot Reload** (`HotReload/`): `DirectoryWatcher` monitors `.as` files; `ClassReloadHelper` handles live reinstancing of modified script classes in the editor.
- **Code Gen** (`CodeGen/`): Editor-time code generation (~84 KB) for IDE support and API stubs.
- **Blueprint Impact** (`BlueprintImpact/`): Scanner and Commandlet that analyze which Blueprints are affected by script changes, enabling targeted recompilation.
- **Source Navigation** (`SourceNavigation/`): Allows jumping from UE editor elements directly to the corresponding `.as` source file and line.
- **Content Browser** (`ContentBrowser/`): Custom data source so `.as` scripts appear in the UE Content Browser.

### UHT Tool (AngelscriptUHTTool)

A C# project (`.ubtplugin.csproj`) that plugs into Unreal Build Tool's pipeline. It reads C++ headers, extracts `UFUNCTION`/`UPROPERTY` metadata, and generates `AS_FunctionTable_*.cpp` shards with direct-bind or stub entries. Build artifacts include `AS_FunctionTable_Summary.json` and per-module CSV breakdowns.

### Test Module (AngelscriptTest)

429 test `.cpp` files organized into 28+ thematic directories (Actor, Bindings, Blueprint, Component, Debugger, Delegate, GC, HotReload, Inheritance, Interface, Networking, Preprocessor, StaticJIT, Subsystem, etc.). Tests use the Automation prefix convention `Angelscript.TestModule.<Theme>.*` for integration tests, `Angelscript.CppTests.*` for runtime C++ unit tests, and `Angelscript.Editor.*` for editor tests. See `Plugins/Angelscript/AGENTS.md` for layering rules.

### Script Examples (`Script/`)

Angelscript `.as` example scripts demonstrating core patterns (actor lifecycle, subsystems, input binding, GAS abilities). Organized under `Script/Examples/Core/`, `Script/Examples/EnhancedInput/`, and `Script/Examples/Extended/`.

### Key Data Flow

1. **Compilation**: `.as` files → Preprocessor → AS Compiler → Bytecode → (optional) StaticJIT → Executable modules
2. **Class Registration**: AS class definitions → ClassGenerator → Live UClass/UStruct with UProperties and UFunctions → Visible to Blueprints and C++
3. **Binding**: C++ types → `Bind_*.cpp` manual bindings + UHT-generated function tables + reflective fallback → Callable from AS scripts
4. **Hot Reload**: File watcher detects changes → Recompile affected modules → ClassReloadHelper reinstances actors in editor

## Key Paths

- `Plugins/Angelscript/Source/AngelscriptRuntime/`: Runtime module — plugin core capabilities land here first.
  - `Core/`: Engine core, binding manager, type system.
    - `Core/GAS/`: GAS (Gameplay Ability System) scripted base classes, components, and utility libraries (18 files).
    - `Core/Commandlets/`: Tool-class Commandlet entry points (4 files).
  - `ClassGenerator/`: Dynamic class generation, hot reload, version chaining.
  - `Binds/`: 124 `Bind_*.cpp` files covering engine API bindings.
  - `Debugging/`: DebugServer V2 protocol.
  - `StaticJIT/`: Static JIT compilation support.
  - `Dump/`: 27+ CSV state export tables; pure external observer architecture.
  - `CodeCoverage/`: Code coverage tracking.
  - `FunctionLibraries/`: 21+ script helper function libraries.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/`: Runtime CSV state dump/export infrastructure. Keep dump logic here as a pure external observer over existing runtime/public APIs.
- `Plugins/Angelscript/Source/AngelscriptEditor/`: Editor-related support (menu extensions, hot-reload UI, BlueprintImpact Commandlet).
- `Plugins/Angelscript/Source/AngelscriptTest/`: Plugin tests and validation (organized by theme: Actor/Bindings/Blueprint/Component/Debugger/HotReload/Subsystem etc.).
- `Plugins/Angelscript/Source/AngelscriptTest/Dump/`: Test-module console command and automation coverage for dump flows.
- `Plugins/Angelscript/Source/AngelscriptUHTTool/`: UHT code generation toolchain.
- `Documents/Guides/`: Build, test, and lookup guides (13 documents).
- `Documents/Rules/`: Git commit and other rule documents.
- `Documents/Plans/`: Multi-phase task plan documents (50 execution Plans + 1 status overview + 1 index + 7 archived).
- `Documents/Plans/Archives/`: Archive directory and summaries for completed or closed plans.
- `Documents/Knowledges/`: 33+ architectural knowledge base documents.
- `Tools/`: Local helper scripts — root runners (`RunBuild.ps1`, `RunTests.ps1`, `RunTestSuite.ps1`, `RunAutomationTests.ps1`/`.bat`, `GetAutomationReportSummary.ps1`), `Tools\Shared\UnrealCommandUtils.ps1`, and centralized tests under `Tools\Tests\`; grouped entry points under `Tools\Bootstrap\` (e.g. `BootstrapWorktree.bat`, `GenerateAgentConfigTemplate.bat`), `Tools\PullReference\PullReference.bat`, `Tools\Diagnostics\`, `Tools\Review\`, and `Tools\ReferenceComparison\`.
- `Script/`: Angelscript example scripts.
- `Reference/`: External reference repositories (not committed, local comparison use only).

## External Reference Repositories

- External reference repositories are not part of this project's committed content. They are used only for comparison, migration analysis, and architectural reference.
- This section keeps an index only; detailed descriptions, usage boundaries, and priority guidance are maintained in `Reference/README.md`.

| Name | Entry & Notes |
| --- | --- |
| AngelScript v2.38.0 | Pull with `Tools\PullReference\PullReference.bat angelscript`; defaults to `Reference\angelscript-v2.38.0`. See `Reference/README.md` |
| Hazelight Angelscript | Obtained via `AgentConfig.ini` key `References.HazelightAngelscriptEngineRoot`. See `Reference/README.md` |
| Hazelight Docs | Pull with `Tools\PullReference\PullReference.bat hazelightdocs`; defaults to `Reference\Docs-UnrealEngine-Angelscript`; use it for the public documentation site source and content structure. See `Reference/README.md` |
| Hazelight VS Code Angelscript | Pull with `Tools\PullReference\PullReference.bat hazelightvscode`; defaults to `Reference\vscode-unreal-angelscript`; use it to compare VS Code Language Server, Debug Adapter, diagnostics, and breakpoint workflows. See `Reference/README.md` |
| UnrealCSharp | Pull with `Tools\PullReference\PullReference.bat unrealcsharp`; defaults to `Reference\UnrealCSharp`. See `Reference/README.md` |
| Tencent UnLua | Pull with `Tools\PullReference\PullReference.bat unlua`; defaults to `Reference\UnLua`; use it to compare Lua reflection exposure, event overrides, and sample organization. See `Reference/README.md` |
| Tencent puerts | Pull with `Tools\PullReference\PullReference.bat puerts`; defaults to `Reference\puerts`; use it to compare TypeScript/JavaScript runtime integration and declaration generation. See `Reference/README.md` |
| Tencent sluaunreal | Pull with `Tools\PullReference\PullReference.bat sluaunreal`; defaults to `Reference\sluaunreal`; use it to compare Lua static export, performance trade-offs, and hot-update workflow. See `Reference/README.md` |

- When adding new reference repositories, update `Reference/README.md` first, then add an index entry here.

## Local Configuration

- `AgentConfig.ini` in the project root stores machine-specific paths (e.g., engine root). It is excluded via `.gitignore`.
- On first use, run `Tools\Bootstrap\GenerateAgentConfigTemplate.bat` to generate a template, then fill in local paths.
- Engine paths in build and test commands should be read from `AgentConfig.ini` key `Paths.EngineRoot`.

## Build & Validation Principles

- Build instructions: see `Documents/Guides/Build.md`.
- Test instructions: see `Documents/Guides/Test.md`.
- State dump entry point: `FAngelscriptStateDump::DumpAll()` in `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.h`, plus console command `as.DumpEngineState` in `Plugins/Angelscript/Source/AngelscriptTest/Dump/`.
- Preserve the dump architecture as a pure external observer: prefer reading existing public APIs over adding intrusive dump hooks to runtime/editor classes.
- If documentation conflicts with the current plugin-centric goal, update the documentation first, then continue implementation.

## Common Commands Quick Reference

All commands require `AgentConfig.ini` in project root. If missing, bootstrap first:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Bootstrap\powershell\BootstrapWorktree.ps1
```

### Build

```powershell
# Standard build (concurrent-safe, reads AgentConfig.ini automatically)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label agent-build -TimeoutMs 180000

# Build without XGE (when distributed build slots are contested)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label noxge -TimeoutMs 180000 -NoXGE

# Build with engine-level serialization (only when writing shared engine outputs)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label engine-write -TimeoutMs 180000 -SerializeByEngine
```

### Test — Single Prefix

```powershell
# Run tests by name prefix (most common single-test entry)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings -TimeoutMs 600000
```

### Test — By Group

```powershell
# Quick smoke
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 600000

# Runtime unit (no world)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Group AngelscriptRuntimeUnit -Label runtime-unit -TimeoutMs 600000
```

### Test — By Named Suite

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000

# List all available suites
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -ListSuites
```

### Diagnostics

```powershell
# Get resolved command templates (build + test) from current config
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\powershell\ResolveAgentCommandTemplates.ps1

# Check for stale UBT processes
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\Diagnostics\powershell\Get-UbtProcess.ps1
```

Build output goes to `Saved/Build/<Label>/<RunId>/`; test output goes to `Saved/Tests/<Label>/<RunId>/`. Never use `-UniqueBuildEnvironment`. Never hand-write `Build.bat`, `RunUBT.bat`, or `dotnet UnrealBuildTool.dll` commands.

## Test Number Baselines

- Current test numbers must distinguish three separate scopes; future documents and roadmaps must not conflate them:
  - `275/275 PASS`: catalogued C++ baseline (`TestCatalog.md`).
  - `417+` automation test definitions across `429` test `.cpp` files: source-code scan scale (as of `bf99c93`, 2026-04-23).
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
- The canonical GitHub remote for this repository is `origin -> git@github.com:UnrealEngine-Angelscript-ZH/AngelscriptProject.git`.
- The default publish branch is `main`. If a local clone still uses `master`, create or switch to `main` before the first push.
- For first-time GitHub remote setup, prefer `git remote add origin git@github.com:UnrealEngine-Angelscript-ZH/AngelscriptProject.git`, then `git push -u origin main` to establish upstream tracking.
- If `origin` already exists but points to another repository, update it with `git remote set-url origin git@github.com:UnrealEngine-Angelscript-ZH/AngelscriptProject.git` instead of adding a duplicate remote.
- Do not force-push `main` unless the user explicitly requests it.

## Plans & TODO

- Tasks requiring multi-phase execution should have a Plan document under `Documents/Plans/`. Writing rules are defined in `Documents/Plans/Plan.md`.
- Completed or closed plans move from `Documents/Plans/` to `Documents/Plans/Archives/`; each archived plan must include archive status, archive date, closure rationale, and a short result summary, with indexes updated in sync.
- TODOs should be broken down around the plugin goal. Avoid lumping legacy project issues into one large task.
- When renaming, migrating modules, or adjusting public APIs, identify all affected files and documentation.
- Tests under `Plugins/Angelscript/Source/AngelscriptTest/` should be organized by concrete theme (for example `Actor`, `Blueprint`, `Interface`, `HotReload`, `Shared`) rather than accumulated under a broad catch-all functional bucket.
- Current active Plan priority and execution order are managed centrally by `Documents/Plans/Plan_StatusPriorityRoadmap.md`.
- The overview and routing of all thematic Plans are maintained in `Documents/Plans/Plan_OpportunityIndex.md`.

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

## Document Navigation

| Document | Purpose |
| --- | --- |
| `AGENTS_ZH.md` | Chinese version of this guide |
| `Plugins/Angelscript/AGENTS.md` | Plugin-internal test layering and naming conventions |
| `Reference/README.md` | External reference repository index and details |
| `Documents/Plans/Plan_StatusPriorityRoadmap.md` | Current completion status, Hazelight gap, and priority overview |
| `Documents/Plans/Plan_OpportunityIndex.md` | Panoramic index of all executable directions |
| `Documents/Guides/Build.md` | Build and command execution guide |
| `Documents/Guides/Test.md` | Test guide |
| `Documents/Guides/TestCatalog.md` | Catalogued test baseline inventory |
| `Documents/Guides/TestConventions.md` | Test naming and organization conventions |
| `Documents/Guides/TechnicalDebtInventory.md` | Technical debt and live suite status |
| `Documents/Guides/AngelscriptForkStrategy.md` | AngelScript fork evolution strategy (selective absorption, not wholesale upgrade) |
| `Documents/Guides/BindGapAuditMatrix.md` | Binding gap audit matrix |
| `Documents/Guides/UE_Search_Guide.md` | UE knowledge lookup guide |
| `Documents/Rules/GitCommitRule.md` | English commit conventions |
| `Documents/Plans/Plan.md` | Plan document writing rules |
| `Documents/Plans/Archives/README.md` | Archived plan index and summaries |
| `Documents/Tools/Tool.md` | Internal tool documentation |
