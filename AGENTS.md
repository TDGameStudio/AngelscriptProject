# AGENTS.md

## Purpose

- This file is guidance for AI agents working in `AngelscriptProject`.
- The primary goal is not to extend a regular game project, but to organize, verify, and solidify `Plugins/Angelscript` as a standalone, reusable Angelscript plugin for Unreal Engine.
- This repository serves as the host project for plugin development and validation; the real deliverable is the `Angelscript` plugin itself.

## Current Project Phase

- The plugin is **no longer in prototype or foundation-building phase**. It has entered a maturity stage where the core runtime, editor integration, and test infrastructure are established, but external delivery entry points and several key capability closures still need attention.
- Current baseline: `AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTest` three-module structure is stable, with `124` `Bind_*.cpp` files, `27+` CSV state export tables, `417+` automation test definitions across `429` test `.cpp` files (387 Test + 32 Editor + 10 Runtime), `DebugServer V2` protocol, `CodeCoverage`, `StaticJIT`, and `BlueprintImpact Commandlet` all landed. Only `2` tests remain Disabled (both `#ue57-headless` known limitations).
- AngelScript base version is `2.33 + selective 2.38 compatibility`; the fork has diverged too far for a wholesale upgrade — the strategy is to selectively absorb improvements from higher versions. See `Documents/Guides/AngelscriptForkStrategy.md`.
- Current priority order: **known blockers & delivery baseline → onboarding assets & workflow entry points → feature parity & validation closure → AS 2.38 selective migration & long-term architecture**. See `Documents/Plans/Plan_StatusPriorityRoadmap.md` for details.

## Current Project Positioning

- `Plugins/Angelscript/` is the core workspace. The vast majority of implementation, fixes, cleanup, and tests should land here first.
- `Source/AngelscriptProject/` retains only the minimal host project content. Do not push plugin logic back into the project module unless the task explicitly requires it.

## Key Paths

- `Plugins/Angelscript/Source/AngelscriptRuntime/`: Runtime module — plugin core capabilities land here first.
  - `Core/`: Engine core, binding manager, type system.
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

- Git commit format and examples: see `Documents/Rules/GitCommitRule.md`.
- All future commits must strictly follow the format in `Documents/Rules/GitCommitRule.md` (including `Scope` and `Type` usage where applicable).
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
- Tests under `Plugins/Angelscript/Source/AngelscriptTest/` should be organized by concrete theme (for example `Actor`, `Blueprint`, `Interface`, `HotReload`, `Shared`) rather than accumulated under a broad catch-all `Scenarios` bucket.
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
