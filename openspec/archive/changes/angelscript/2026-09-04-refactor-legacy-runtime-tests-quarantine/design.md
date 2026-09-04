## Context

The plugin and host project intentionally continue to load their existing UE modules. The isolation boundary must therefore be inside module startup and test translation units rather than in `.uplugin`/`.uproject` enablement. This keeps the old implementation immediately recoverable for comparison while providing a clean default process state for later lexer and AST work.

The parent repository and the three plugin repositories are independently committed. The parent already contains unrelated work, including a modified generated host JIT artifact, which this change must neither rewrite nor stage.

## Goals / Non-Goals

**Goals:**

- Produce one default-off runtime decision shared by the core plugin, editor integration, TestJIT carrier, host JIT carrier, and optional GameplayTags integration.
- Leave `UAngelscriptSubsystem` present as an empty observable shell.
- Exclude old tests before their includes and static registrations are compiled.
- Establish an enabled-by-default replacement test macro and final Automation namespace in a temporary source directory.
- Make the preserved legacy implementation inert without promising a supported reactivation path during reconstruction.

**Non-Goals:**

- Delete, mechanically rewrite, redesign, or repair legacy runtime/test source beyond the required relocation of old tests beneath their owning `Legacy/` isolation parents.
- Begin lexer, parser, AST, semantic, bytecode, or JIT redesign.
- Change Harness APIs, UE module descriptors, generated JIT artifacts, old suite catalogs, project Skills, `Documents/`, `Wiki/`, or `openspec-old/`.
- Provide or prove a config opt-in path for the dormant legacy implementation.

## Decisions

### Lock one reconstruction decision in the runtime module

`FAngelscriptRuntimeModule::IsLegacyRuntimeEnabled()` is the single shared decision for dependent modules and returns false throughout the reconstruction baseline. It is intentionally not exposed through `UAngelscriptSettings` or project config. This avoids separate switches drifting across plugins and prevents `InitializeAngelscript()` or `EnsurePrimaryEngineInitialized()` from bypassing the disabled process state.

The runtime module retains its existing startup implementation behind the hard gate solely as reference. Shutdown follows an explicit “started” flag so a dormant module does not call cleanup for services it never activated. Any future attempt to reactivate old behavior is new scoped work and must not be inferred from retained source.

### Keep editor settings outside the legacy gate

`FAngelscriptEditorModule` registers the two project settings pages first. If legacy activation is false, it returns before class reload, source navigation, StaticJIT refresh, script-test refresh, post-engine-init hooks, menu/state-dump extensions, directory watchers, debug bridges, and pre-save callbacks. Shutdown always removes settings, but performs legacy cleanup only when legacy startup ran.

### Gate provider and optional-extension registration, not generated code

Both JIT carrier modules remain loadable but register `IAngelscriptJITArtifactProvider` only when the shared runtime decision is enabled. Generated provider sources remain byte-for-byte untouched. The GameplayTags runtime/editor modules similarly skip extension and delegate registration. GAS has no active module-startup work; its existing passive code remains available.

### Separate legacy and replacement compile identities

`UAngelscriptCompileOptions` and `AngelscriptRuntime.Build.cs` publish two booleans:

- `WITH_ANGELSCRIPT_UNITTESTS`, default `0`, owns every preserved legacy test translation unit.
- `WITH_ANGELSCRIPT_TESTS`, default `1`, owns the replacement suite.

The final isolation boundary is structural rather than a preprocessor wrapper. Each old test tree is retained beneath an otherwise empty `Legacy/` parent that contains `.ubtignore`; module implementations, the active `AngelscriptTest/Core/AngelscriptTestModule.h`, `NewVersion`, and generated TestJIT sources remain outside those ignored parents. UE 5.8 UBT stops recursion when it reaches the marked parent, so neither old translation units nor their reflected headers enter active C++ or UHT discovery.

This shape is evidence-driven. UHT rejects `UCLASS`, `USTRUCT`, `UFUNCTION`, and `UPROPERTY` inside custom `#if WITH_ANGELSCRIPT_UNITTESTS` blocks. A `.ubtignore` placed in a directory that directly owns source is also insufficient: normal UBT source enumeration can collect that directory's own `.cpp` files before recursion stops, while UHT excludes its headers, producing an inconsistent compile graph. The marker therefore belongs in a source-free parent above the complete legacy subtree. Source-discovery topology changes are verified once with `-NoUBTMakefiles` before returning to ordinary incremental builds.

Generated legacy TestJIT sources retain references to a narrow set of Runtime test-probe symbols even when their owning tests are disabled. The macro-off Runtime header therefore supplies inert inline compatibility definitions for that already-generated ABI. They preserve buildability without registering a provider, retaining mutable probe state, or rewriting generated artifacts.

The default `AngelscriptTest` build rules also exclude legacy-only CQTest force includes, private/editor dependencies, include paths, and engine-pool headers. Its module implementation remains a small loadable shell and `NewVersion` compiles against only the dependencies required by replacement tests. `WITH_ANGELSCRIPT_UNITTESTS=0` remains the legacy policy gate, but the ignored parent is the hard source-discovery boundary and is intentionally not a supported user toggle. `AngelscriptTestJITProbes.cpp` is not part of the old test corpus: retained generated TestJIT objects link directly to its registration symbols. It therefore stays compiled as passive ABI support while the TestJIT module startup gate prevents provider publication.

### Treat `NewVersion` as a temporary path only

The baseline uses Unreal Automation directly and has no dependency on the old CQTest helpers or test-engine pool. Public tests use `Angelscript.UnitTest.<Area>.<Scenario>` and the parent config exposes an `AngelscriptUnitTest` Automation group. Later source-directory cleanup may rename `NewVersion` without changing public identity or durable specifications.

### Use the Harness `ue.test` Fast profile for focused replacement tests

Replacement tests run through the existing Harness `ue.test` route with `Fast = $true` and the narrowest exact public prefix. This Harness profile selects a command-line `UnrealEditor-Cmd.exe` process with NullRHI, no sound, no splash, no startup packages, no Live Coding, no automatic shader-compiler launch, and no asset-registry cache writes while preserving Harness-owned timeouts, reports, logs, workspace isolation, and exit validation. “Fast” is the public Harness profile name; “headless” describes its no-render execution characteristics, not a separate process or project entry point.

A persistent editor or commandlet daemon could amortize engine startup, but it would not prove this Change's fresh-process startup contract and could leak module or global state between runs. A custom test commandlet would also duplicate Automation discovery/report semantics. This Change therefore measures the ordinary and Fast Harness `ue.test` profiles against the same near-zero-work baseline, records the observed process duration, and adopts the Fast profile as the fastest supported trustworthy path for focused replacement-test feedback. Timing is evidence, not a machine-independent pass/fail budget.

## Risks / Trade-offs

- Relocating roughly one thousand legacy translation units creates a broad but intentionally mechanical rename diff. A deterministic audit verifies that every retained old source is beneath an ignored parent while active module shells, replacement sources, and generated artifacts remain outside it.
- Generated TestJIT objects have static link-time references to their probe-registration implementation even when the provider is dormant. Treating that implementation as a legacy test translation unit would break linking, so isolation is defined by no provider registration rather than removing that passive symbol carrier.
- Compiled plugin code and static metadata still exist. The contract is dormant behavior, not removal from the target or binary-size optimization.
- Retained source may decay while new lower layers are rebuilt because old execution is not a supported path. If old behavior is later reused, a dedicated Change must reassess and verify it rather than flipping config.
- A real editor build is required because the change affects UHT-visible settings, Build.cs definitions, module includes, and whole-file compilation boundaries. One exact Automation prefix is sufficient runtime proof; aggregate suites remain unrelated while the legacy corpus is intentionally absent.
- Even a near-zero-work Automation test pays for a fresh `UnrealEditor-Cmd.exe` process, project/module load, Automation discovery, report export, and shutdown. The Harness Fast profile removes optional startup work but does not turn UE Automation into an in-process C++ micro-test runner.
