# AGENTS.md


The project remains in its refactor stage. The user explicitly lifted the temporary Skill restriction on 2026-09-04; project Skills are enabled again and remain subject to the workspace, OpenSpec, real-UE verification, and Git boundaries in this file.

 Documents 下面的东西我准备删除的, 相关知识我准备放到spec  以及skill 中的




## Project Overview

- This file is guidance for AI agents working in `AngelscriptProject`.
- The primary goal is not to extend a regular game project, but to organize, verify, and solidify `Plugins/Angelscript` as a standalone, reusable Angelscript plugin for Unreal Engine. This repository serves as the host project for plugin development and validation; the real deliverable is the `Angelscript` plugin itself.
- The plugin is **no longer in prototype or foundation-building phase**. It has entered a maturity stage where the core runtime, editor integration, and test infrastructure are established, but external delivery entry points and several key capability closures still need attention.
- Current baseline: the `AngelscriptRuntime` / `AngelscriptEditor` / `AngelscriptTestJIT` / `AngelscriptTest` four-UE-module structure is stable, with `AngelscriptTestJIT` serving only as the fixed Editor StaticJIT test carrier. The plugin also has `121` `Bind_*.cpp` files, `27+` CSV state export tables, `1518+` automation test definitions across `430` test `.cpp` files, DebugServer V2, CodeCoverage, provider-based StaticJIT, and BlueprintImpact Commandlet. GameplayTags support now lives in the optional `AngelscriptGameplayTags` plugin, while `AngelscriptGAS` depends on it for GAS-facing integration. Only `2` tests remain Disabled (both `#ue57-headless` known limitations).
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
│       ├── AngelscriptTestJIT/              # Editor-only fixed StaticJIT test provider
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
│   │   ├── OpenSpecSystemRefactor.md        # OpenSpec Rust/Web/Skill refactor boundaries
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
│   ├── openspec/                            # Portable Rust OpenSpec CLI (git submodule)
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
       ├──► AngelscriptTestJIT (Editor-only fixed StaticJIT Provider, public Runtime dependency)
       │           │
       │           └──► AngelscriptTest (test-side dependency on TestJIT)
       └──► AngelscriptTest    (public Runtime dependency,
                                private Editor dependency when bBuildEditor)

AngelscriptGameplayTags  (Runtime module, public dependency on Runtime; optional)
       │
       ├──► AngelscriptGameplayTagsEditor  (Editor module, GameplayTags delegate/reload bridge)
       └──► AngelscriptGameplayTagsTest    (Editor module, GameplayTags-specific tests)

AngelscriptGAS  (Runtime module, public dependency on Runtime + AngelscriptGameplayTags)

AngelscriptUHTTool  (C# UBT plugin, independent — hooks into Unreal Header Tool pipeline)
```

All four plugin UE modules load at `PostDefault`. `AngelscriptRuntime` owns the editor/commandlet bootstrap through `UAngelscriptEngineSubsystem`, while `FAngelscriptRuntimeModule::InitializeAngelscript()` remains a compatibility API and routes to that subsystem when `GEngine` is available. `UAngelscriptGameInstanceSubsystem` owns world/game-instance contexts and suppresses the engine-subsystem fallback tick while an active game-instance tick owner exists. The host `AngelscriptProject` module remains intentionally minimal; the optional project `AngelscriptJIT` Runtime/PreDefault module only carries generated StaticJIT provider code.

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

### StaticJIT Provider Data Flow

- StaticJIT emits exactly one `<StableModuleKey>.<TargetProfile>.jit.cpp` for each non-empty AS module. Global functions and class methods from the same AS module share that translation unit; per-function slices and fixed buckets are forbidden.
- The project `AngelscriptJIT` carrier and Editor-only `AngelscriptTestJIT` carrier publish ABI Revision 2 entry tables through `IAngelscriptJITArtifactProvider`; `FAngelscriptJITProviderRegistry` validates and copies them into immutable multi-provider snapshots.
- Each Engine first establishes authoritative current functions through source compilation or Cache V2 restore. `FAngelscriptJITProviderRouter` then matches stable module/function keys, content, target profile, native environment, entry ABI, and stable references. Only an unambiguous exact match publishes a complete VM/Raw/Parms binding; any mismatch falls back only that function to VM.
- A normal `.as` save never generates C++ or triggers Live Coding automatically. The explicit Editor Generate/Refresh action may patch when the source-file set is unchanged; adding or removing an AS module requires a normal full build.
- UE ModuleManager owns provider DLL loading/unloading. Registry owner unregistration prevents future selection, while published bindings retain a code-image lease until the last active reader exits. Never reintroduce `FJITDatabase`, persisted FunctionId/DataGuid, or whole-cache pairing.
- Production content-specific script-to-script direct-call emission is currently disabled. Native binding execution is supported; cross-translation-unit direct calls remain a separate future optimization.
- TypedASTJIT (`typed-ast`) complements rather than removes BytecodeJIT/VM and is not a Runtime JIT. It requires HIR capture before that same generation source compile and consumes only in-memory verified HIR. Ordinary call arguments are reverse formal order; mutation targets are single-evaluation; loop/switch transfers keep explicit phases and targets. Debug-frame position is not debugger/coverage/timeout parity. Direct recursion needs a native frame budget. `bExceptionThrown` is not a complete public exception payload. Cleanup plans are explicit, reverse, and live-only. Current source-level `try`/`catch` remains rejected. Mutable globals and import slots need lifecycle routes. A native-form name does not prove external DLL linkability. There is no production `dual` backend.

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
- Angelsea is retained at `Reference\angelsea` from `https://github.com/asumagic/angelsea.git`, including its pinned MIR, AngelScript, fmt, Catch2, and nanobench submodules. It is a secondary research reference for `asIJITCompilerV2`, AngelScript bytecode-to-C, MIR, lazy/asynchronous JIT, and interpreter fallback. The plugin's StaticJIT, UE integration, and maintained AngelScript fork always take precedence; Angelsea is not a runtime or build dependency.
- Daslang (repository name `daScript`) is retained at `Reference\daScript` from `https://github.com/GaijinEntertainment/daScript.git`. It is a cross-language architecture reference for zero-copy C++ interop, a tree interpreter, AOT-to-C++, LLVM JIT, hot reload, semantic hashing, compile-time macros, and compiler-backed MCP tooling. It is not authoritative for AngelScript semantics, ABI, or this project's StaticJIT, and is never a build dependency.
- Typed/native compiler research snapshots are retained at `Reference\Cython`, `Reference\numba`, `Reference\luau`, and `Reference\llvm-project` from `cython/cython`, `numba/numba`, `luau-lang/luau`, and `llvm/llvm-project`. Use Cython primarily for typed-AST-to-C/C++ Static AOT emission, Numba for bytecode-to-untyped/typed-IR-to-LLVM staging, specialization, and object caching, Luau for bytecode-native code generation, type guards, fallback blocks, VM exits, and x64/A64 code lifecycle, and LLVM 22.1.8 for IR/IRBuilder, Clang AST/CodeGen, and ORC JIT. They are offline research sources rather than plugin dependencies; exact versions, licenses, clone/junction commands, and source entry points are recorded in `Reference/README.md` and `openspec/changes/feature-as-typed-semantic-aot/research/`. The local LLVM source is `D:\LLVM\llvm-project-22.1.8.src`, junctioned to `Reference\llvm-project` and aligned with `Paths.LLVMRoot`.
- GenericMessagePlugin is retained at `Reference\GenericMessagePlugin` from `https://github.com/wangjieest/GenericMessagePlugin.git`. Use it to study a UE key-based message bus spanning C++, Blueprint, AngelScript, and other script backends, including signature collection, type checking, generated AS declarations, K2 nodes, request/response, sticky messages, and call-site tracing. It is a focused secondary message/script-interoperability reference, not plugin code to import directly.
- GenericStorages is retained at `Reference\GenericStorages` from `https://github.com/UnrealBytes/GenericStorages.git`. It is a low-priority utility reference for UE registry/storage/singleton/subsystem templates, editor pickers, platform persistence, permissions/deep links, and S3 helpers; it is neither an AngelScript architecture baseline nor a runtime dependency.
- UECling is retained at `Reference\UECling` from `https://github.com/Evianaive/UECling.git`. It is a low-priority cross-reference for embedding Cling/CppInterOp in Unreal, runtime C++ interpretation, REPL/notebook tooling, Blueprint nodes, and script-generated classes; it is not a runtime or build dependency. Upstream provides no repository-level LICENSE and directly carries LLVM/Clang headers, so any implementation use or redistribution requires a separate provenance and license review.
- Official OpenSpec (Node CLI) is retained at `Reference\openspec` from `https://github.com/Fission-AI/OpenSpec.git`, following `main`. The 2026-08-26 snapshot is `6926ccb18afa4ff621112813e9968334576ee11a` (`@fission-ai/openspec` 1.10.0). It is the latest-CLI behaviour, schema, skill-layout, and Vitest reference for a portable OpenSpec fork; not a plugin runtime or build dependency. Do not confuse it with `Reference\openspec2`, which is a separate internal fork.
- OpenSpec-rs is retained at `Reference\OpenSpec-rs` from `https://github.com/oonid/OpenSpec-rs.git`, following `master`. The 2026-08-26 snapshot is `36efb88d552fe91a8a6e69f2a742abf47d9a1b6c` (v0.3.0, tracking upstream OpenSpec v1.4.1). It is the portable single-binary starting point for continuing Rust OpenSpec work; clone commands, SHAs, and the missing `vendor/OpenSpec` gitlink are recorded in `Reference/README.md`.

## Local Configuration

- `AgentConfig.ini` in each workspace stores machine-local paths and Harness-managed workspace identity. It is excluded via `.gitignore`.
- Initialize or repair it through Harness `workspace.bootstrap`, then set exact non-managed values through `workspace.config.set`. Harness copies shared local settings from the canonical primary checkout and always rebinds `Paths.ProjectFile` to the selected workspace.
- Build and test entry points read `Paths.EngineRoot` and reject a workspace whose managed identity or current PowerShell-session selection does not match the target root.
- The obsolete `References.HazelightAngelscriptEngineRoot` key is invalid. Bootstrap removes it, configuration writes must not recreate it, and execution rejects stale configuration until repaired.
- `AgentConfig.ini`, Git registration, workspace/engine leases, and `Saved/Harness` evidence always retain physical paths. On Windows, UE child processes use a Harness-assigned transient short-drive execution view; it is never persisted into workspace configuration, `PlanOnly` creates no mapping or assignment record, and a real run removes only an exact ownership-verified mapping.

## Build & Validation Principles

- UE 5.8 discovery, builds, Automation, suites, commandlets, processes, progress, and cancellation use the Harness `ue.*` routes. Root `Tools` PowerShell wrappers are not a fallback.
- Legacy root wrappers may be deleted only after the long-worktree default-executor build, Smoke, commandlet, suite, cancellation, and parallel-worktree acceptance gates pass; an unavailable or failed real gate keeps that deletion incomplete without disabling UBA/XGE.
- The current Harness suite catalog is UE Automation only. Standalone Debug/Release, packaging, coverage, release orchestration, CachePackage, external smoke, and the full StaticJIT pipeline remain explicit deferred capabilities until a scoped Change supplies verified routes.
- Standalone CTest results remain an independent scope from UE Automation, NativeCore, and catalogued C++ baselines; do not add Debug and Release counts together.
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

## Harness, Submodule & Worktree

- The project remains in its project-wide refactor, but the user has explicitly restored project Skill use. Every invocation remains governed by the Harness, workspace, submodule, review, and closure contracts in this section.
- Default editing remains in the main checkout. Create or select another Git-registered worktree only when the user explicitly requests it; new worktree branches default to the exact requested name. Every operation uses one explicit or current-directory-discovered `WorkspaceRoot`. Codex `/goal` is external unattended continuation of the same work and is not a repository mode, branch convention, or workspace selector.
- `.agents/skills/harness/SKILL.md` is the prepared project Skill entrypoint. Harness is a lightweight static router, not a daemon, database, Event Store, or custom agent loop. Its prepared surface exposes `workspace.*`, `git.*`, `openspec.*`, `task.status`, `harness.*`, `openspec.maintenance.status`, and the verified `ue.*` Unreal leaf routes.
- The prepared Harness/Workspace harness requires PowerShell 7.0 or later (`Core`) and invokes `pwsh.exe` only. Windows PowerShell 5.1 is not a supported harness host; historical dual-host archives remain evidence, not current policy.
- `Plugins/Angelscript`, `Plugins/AngelscriptGameplayTags`, `Plugins/AngelscriptGAS`, and `Tools/openspec` are **git submodules**, not ordinary directories. A parent worktree must initialize the exact recorded gitlink OIDs; a verified local-object fallback is allowed when an upstream no longer serves an OID.
- Commit and tag `Tools/openspec` first. For each release, the parent history receives only one final accepted package update containing the gitlink, manifest/docs, and bundled `openspec.exe`; candidate executables never receive parent commits.
- Root `Tools` PowerShell entrypoints are legacy deletion candidates and are not the live Harness command surface. `Tools/openspec` is the intentional tracked-source exception; normal OpenSpec runtime calls use `.agents/skills/openspec/bin/openspec.exe`.
- Use Harness `workspace.new` / `workspace.bootstrap` for setup and `workspace.activate` to bind the selected workspace to the current PowerShell process. Unreal routes inherit that exact root; `ue.build` supports controlled `Auto` / `Parallel` / `Serialize` selection across distinct worktrees, while same-workspace execution remains exclusive. Copy `AgentConfig.ini` only after confirming it is ignored, never discard a dirty submodule, and do not scaffold an OpenSpec change as a worktree side effect.
- Work in any selected workspace stops at committed, verified, closure-ready state. Harness does not start Incident or Final Review automatically; when no Review was explicitly requested, verified work may proceed directly to completed closure and archive. `git.commit` performs scoped Git closure; `git.integrate`, non-force `git.push`, and `workspace.remove` are separate operations that run only when the user explicitly requests them. Any explicitly requested Review must be resolved before archive, and cleanup preserves the source branch.
- When code belongs to a submodule, commit the submodule first and the parent gitlink second. Full workflow, fallback strategies, scope guards, and troubleshooting: **`Documents/Guides/SubmoduleWorktreeWorkflow.md`**.

## OpenSpec & TODO

### 2026-08-27 comprehensive-refactor transition

- AngelscriptProject is currently in a **comprehensive refactor**. Existing `openspec/specs/` and active changes come from different eras and mix inconsistent granularity, overlapping capability boundaries, historical goals, current implementation, and future intent that can look like established fact. Do not treat the spec corpus as uniformly authoritative. Implementation decisions must triangulate current code, tests, the latest applicable change, and related documentation.
- Rebaseline before restructuring the spec system. Classify records as current-authoritative, partially valid, future intent, overlapping/conflicting, or historical-only. Prefer marking, migration, and archive over deletion; do not bulk-rewrite, remove, or compile old specs into a new Skill without a scoped change.
- `Tools/openspec` is the tracked portable Rust distribution. Its product direction has two primary surfaces: a Node/npm-free change/spec lifecycle and validation core, plus a local Web preview that reuses the same Rust parsing and validation model. Web V1 is read-only and offline by default and must not establish a second source of truth.
- Project OpenSpec Skills are decoupled from the Rust tool and are versioned, distributed, and maintained independently by projects or users. The Rust CLI does not generate, refresh, or overwrite Skills and does not write into Agent configuration directories such as `.agents/`, `.claude/`, or `.cursor/`. The AngelscriptProject Skill continues to carry AS plugin boundaries, test-layer selection, validation entry points, record conventions, and refactor-era spec-trust rules.
- Extend the spec system by selectively absorbing community mechanisms: project context/rules, replaceable schemas, research/review/test-plan/retrospective artifacts, requirements-to-tasks traceability, and narrowly justified hooks/checks. Record provenance, the adopted subset, rejected parts, and verification for each import; never copy a community schema wholesale by default.
- The stable architecture boundary is recorded in `Documents/Guides/OpenSpecSystemRefactor.md`.

- `Documents/Plans/` is **deprecated** — retained for historical reference only. All new planning, design, task tracking, and archive lifecycle uses OpenSpec under `openspec/changes/<change>/`.
- OpenSpec is used only when the user explicitly names a Change or the accepted work requires one. The portable Rust CLI is a deterministic record primitive; lifecycle policy is split across `openspec-explore`, `openspec-continue-change`, `openspec-update-change`, `openspec-apply-change`, `openspec-verify-change`, `openspec-sync-specs`, and `openspec-archive-change`.
- `tasks.md` is the sole current Task DAG: its top-of-file YAML `task_graph.depends_on` map owns dependency edges for stable `X.Y` IDs, and OpenSpec derives `after` and `ready`. Every Task Card keeps a concise one-line node with an exact verify command or observable outcome plus `Files:`. Add optional Context, Inputs, Produces, Constraints, numbered steps, examples, or other concise Markdown only when useful; these are not parser fields or a rigid template. Do not maintain a second DAG, GraphRevision, snapshot tree, or resume state.
- Before creating an OpenSpec Change for a new feature, architecture refactor, or major behavior change, run deep read-only exploration unless an accepted decision-complete handoff already exists; never invoke `openspec-explore` after the target Change exists. Clear fixes, mechanical documentation, and approved ready plans may skip the pre-creation gate. During a Ready task, keep technical exploration local and escalate only when evidence invalidates current truth.
- For OpenSpec-scoped implementation, an accepted exploration or conversation plan is not execution state. Resolve the canonical active Change and Ready Task DAG in the selected workspace before implementation mutation; if missing registration is discovered later, preserve the work, record the process issue, and recover before commit without fabricating history.
- Investigate, replan, implement, and verify autonomously inside the authorized objective, including during a Codex `/goal` continuation. Diagnose discovered problems directly: repair local defects in the current task, and trigger replan only when evidence invalidates a requirement, design, acceptance condition, task boundary, dependency edge, or completion evidence. Register Review only when the user or an external agent explicitly requests it; optional asynchronous reviewers still require immutable snapshots.
- Change attachments are structured under `attachments/` and loaded through `attachments/INDEX.md` only. `attachments/implementation/` records one material root-cause lifecycle per issue, not routine RED/GREEN cycles or summaries. Review, implementation, talk, replan, knowledge, script, and data records must not duplicate task state.
- Reusable knowledge flows from change evidence to an indexed capability `knowledges/` directory; only stable cross-capability invariants are promoted to project instructions. Archive never promotes knowledge automatically.
- Archive is an explicit closure gate. `completed` requires complete tasks, evidence, spec-sync disposition, resolved material issues, and every explicitly registered Review to be closed or superseded; it does not require a Final Review or a `not required` placeholder. `abandoned` or `superseded` requires a reason and disposition for every incomplete task. The CLI archive remains a pure deterministic move and never merges specs.
- Plan-only remains first-class: produce a ready-to-execute proposal/spec/design/Task DAG and stop. Record depth stays proportional to risk.
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
