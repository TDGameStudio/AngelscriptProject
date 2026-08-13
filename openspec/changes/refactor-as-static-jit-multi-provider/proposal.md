## Why

StaticJIT still couples generated Native code to process-local `FunctionId` values, one global registration/activation state, and a legacy JIT callback that must return one VM entry immediately. Static constructors from several translation units or UE modules can append to `FJITDatabase`, but FunctionId collisions overwrite, `FStaticJITCompiledInfo` permits only one active data set, and ownership/unload/generation cannot be separated. That prevents a truly independent test provider, multiple concurrent provider modules, a project-owned JIT module usable by Editor/Game, delayed provider refresh after Live Coding, and safe per-function reuse across source compilation, Cache V2 restore, hot reload, and multiple AngelScript engines.

## What Changes

- **BREAKING** Replace the fork's version-selected JIT callbacks with one lifecycle-aware `asIJITCompiler` contract: function-ready notification, delayed full Binding publication, and exact release on replacement/destruction. Remove `asIJITCompilerV2`, `asIJITCompilerAbstract`, `asEP_JIT_INTERFACE_VERSION`, and old-interface compatibility.
- Reuse the stable artifact identities already delivered by `as-script-artifact-identity`, and extract Cache-named live function route/reference values into neutral `Core/Artifacts` contracts shared by Cache V2 and StaticJIT.
- Replace `FJITDatabase`, single `FStaticJITCompiledInfo::ActiveInfo`, persisted FunctionId registration, and whole-cache `DataGuid` activation with a Runtime-owned multi-provider registry, current provider ABI, and per-`FAngelscriptEngine` immutable route snapshots. Several UE provider modules may coexist; each provider may contain entries from several AngelScript modules.
- Add an Editor-only `AngelscriptTestJIT` UE module that contains only generated JIT code and test-native probes for plugin-owned committed fixtures. It has no project-script input, project naming, Scaffold, `.uproject`, output, or lifecycle relationship. `AngelscriptTest` owns tests and the separate test-only `-run=AngelscriptTestJIT -Mode=Generate|Verify` workflow and depends one-way on `AngelscriptTestJIT`.
- Generate real project code into one fixed Runtime/PreDefault project module named `AngelscriptJIT`, located at `Source/AngelscriptJIT`, so packaged targets register the Provider before the first Runtime Engine compile.
- Provide an `AngelscriptEditor`-owned `-run=AngelscriptJIT -Mode=Scaffold|Generate|Verify` project tool, deterministic one-AS-module-per-`<Module>.jit.cpp` emission for each Editor/Game/Shipping profile, structured `.uproject` registration, and non-overwrite/verification rules.
- Give every registered view a stable `ProviderId` and content-derived `ProviderGeneration`. A newer generation of the same Provider supersedes the older generation; different Providers coexist; two different Providers that exactly claim the same function produce a typed ambiguity and VM fallback rather than load-order override.
- Keep Editor/PIE source compilation, module swap, ClassGenerator, and class hot reload authoritative. Exact stable matches use Native entries; changed, missing, or incompatible functions use the current VM implementation.
- Route hot-reloadable script-to-script calls and `UASFunction` dispatch through the current function Binding so unchanged Native callers and reflected wrappers cannot retain stale content-specific entries.
- Add an explicit Editor Generate/Refresh action. When Live Coding is enabled and the generated module-source set is unchanged, it compiles changed `<Module>.jit.cpp` files, waits for patch completion, validates the expected newer provider generation, and publishes routes at an Engine safe point. Adding or removing an AS module changes the UBT source set and requires a normal full build. Script save alone never starts C++ compilation.
- Keep packaged correctness independent of Native availability: Development/Shipping load the project JIT provider when it matches and otherwise retain VM execution; packaged end users never generate C++.

## Capabilities

### New Capabilities

- `as-jit-lifecycle-interface`: defines the fork's single non-versioned JIT lifecycle, complete VM/Raw/Parms Binding, delayed publication, replacement, teardown, and compiler replacement behavior.
- `as-static-jit-artifact-provider`: defines the external provider ABI, multi-provider registry, multi-AS-module providers, stable-reference slots, per-function exact matching, deterministic conflict handling, per-Engine immutable route snapshots, provider generations, and VM fallback.
- `as-static-jit-editor-routing`: defines Editor/PIE authoritative compilation, current-callee routing, explicit generation, Live Coding refresh, safe publication, and failure behavior.
- `as-static-jit-module-scaffolding`: separates the fixed plugin-test `AngelscriptTestJIT` target from the fixed project `AngelscriptJIT` target, and defines deterministic per-AS-module C++ generation, target profiles, Editor-owned Scaffold/Generate/Verify, and project registration.

### Modified Capabilities

- `as-static-jit-aot-test`: moves generated test code into `AngelscriptTestJIT`, removes the legacy local `.Cache`/DataGuid pair, and proves the same provider against source-compiled and Cache V2-restored engines.
- `static-jit-diagnostics`: replaces FunctionId/global-registry diagnostics with stable provider, Binding, route, reference-slot, generation, generated module-source, and typed fallback diagnostics.
- `uasfunction-dispatch-matrix-and-jit-paths`: requires Editor/PIE wrappers to resolve the current ScriptFunction Binding instead of retaining stale VM/Raw/Parms pointers.

## Impact

- Affects the maintained AngelScript fork API/implementation, `AngelscriptRuntime/StaticJIT`, neutral artifact route values currently under Cache, ClassGenerator/UASFunction dispatch, `AngelscriptEditor` generation and Live Coding integration, and StaticJIT tests.
- Adds `AngelscriptTestJIT` to `Angelscript.uplugin` as Editor/PostDefault and later adds the fixed `AngelscriptJIT` module to the host `.uproject` as Runtime/PreDefault. The two providers may be registered concurrently but have different ProviderIds, source domains, commands, targets, and outputs. Runtime never depends on either module.
- The generated project module depends on `AngelscriptRuntime`; it is separate from Runtime-independent native-module function-address shards.
- Coordinates with `feature-as-typed-semantic-aot`: that change may emit function bodies, while this change owns JIT lifecycle, provider/entry ABI, stable references, module packaging, Editor routing, and Live Coding publication.
- Does not redesign Cache V2 persistence, automatically compile C++ on `.as` save, provide Live Coding on unsupported platforms, or generate Native code on packaged end-user machines.
