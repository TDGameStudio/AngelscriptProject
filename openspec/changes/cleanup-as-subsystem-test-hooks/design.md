## Context

The subsystem consolidation in commit `c1a25d5` copied test override state from the former `UAngelscriptEngineSubsystem` into `UAngelscriptSubsystem`. The old subsystem used editor/commandlet overrides inside `ShouldBootstrapAngelscript()`, but the consolidated subsystem now bootstraps in all supported environments and returns `true` unconditionally. The environment override state therefore has no reader.

Two live test mechanisms remain:

- `InitializeOverrideForTesting` replaces the subsystem primary engine.
- `SubsystemOverrideForTesting` replaces the result of `UAngelscriptSubsystem::Get()`.

They are used by subsystem/runtime-module tests. Scan-free engines remain available through test-owned CQTest fixtures, but the Test module no longer creates one during module startup or asks the production subsystem to adopt it.

## Goals / Non-Goals

**Goals:**

- Remove all `WITH_DEV_AUTOMATION_TESTS` code from `UAngelscriptSubsystem`.
- Keep production subsystem behavior unchanged: adopt an ambient engine when present, otherwise initialize the owned engine.
- Keep scan-free engine creation available to individual CQTest fixtures without changing production startup.
- Test subsystem behavior through production entry points instead of test-only mutators.
- Remove stale startup environment tests and replace implementation-hook assertions with externally observable lifecycle assertions.

**Non-Goals:**

- Do not remove test hooks from `FAngelscriptRuntimeModule` in this change.
- Do not redesign `FAngelscriptEngineContextStack` or the broader test engine pool.
- Do not change `ModuleDirectory`, `Core`, `Testing`, or ThirdParty Include Paths.
- Do not change script compilation, binding, hot reload, debugger, or runtime semantics.

## Decisions

### Decision 1: CQTest fixtures own scan-free engines

When an individual test needs to avoid disk script scanning, its CQTest fixture creates a scan-free engine and an `FAngelscriptEngineScope` for the test lifetime. The production subsystem is not replaced, pre-seeded, or made aware of this fixture.

This preserves the optimization at the correct test boundary without a process-level startup switch.

### Decision 2: Subsystem tests use ambient engines and the real subsystem locator

Transient subsystem tests may call `EnsurePrimaryEngineInitialized()` with an ambient test engine active and inspect the public `GetEngine()` result. Tests of `UAngelscriptSubsystem::Get()` and fallback precedence use the real `GEngine` subsystem instead of replacing the locator.

### Decision 3: Remove tests of dead implementation seams

The editor/commandlet startup override test is removed because the production rule is now unconditional subsystem creation. A compile-time regression check ensures the subsystem public surface does not reintroduce the removed test-only methods.

### Decision 4: No replacement Factory or Locator is introduced

The existing production extension points are sufficient: ambient engine scope for engine selection and `GEngine->GetEngineSubsystem` for subsystem location. Adding another factory/locator would recreate the same test seam under a new name.

### Decision 5: No process-level scan-free startup hook

`AngelscriptTestModule::StartupModule` only handles TestEnginePool prewarming. It does not create a scan-free engine, register an `OnPostEngineInit` cleanup callback, or create a raw-pointer lifetime relationship with `UAngelscriptSubsystem`.

## Risks / Trade-offs

- **[Risk] Removing startup scan-free mode increases test startup cost** → retain `CreateScriptScanFreeFullEngineForTesting` and use it only in fixtures that need no-disk initialization.
- **[Risk] Runtime-module tests currently depend on suppressing or replacing subsystem lookup** → rewrite them to use the real subsystem or module-level override paths; remove tests that only prove the deleted mock behavior.
- **[Risk] Actual engine subsystem state may make tests order-sensitive** → snapshot and restore explicit engine contexts, avoid deinitializing the real subsystem, and use transient subsystems only for public lifecycle tests.

## Migration Plan

1. Add a compile-time regression assertion that fails while `UAngelscriptSubsystem` exposes test-only methods.
2. Remove dead startup-environment override state and all live test hooks from the subsystem header and implementation.
3. Keep scan-free engine ownership inside individual CQTest fixtures rather than TestModule startup.
4. Rewrite subsystem tests around ambient engine adoption and the real subsystem locator.
5. Remove subsystem override usage from runtime-module tests while preserving their production behavior assertions.
6. Run the Editor build and the `Angelscript.TestModule.Engine.EngineSubsystem` / `Angelscript.TestModule.Engine.RuntimeModule` focused prefixes.

## Resolved Questions

- The process-level scan-free startup hook was removed; individual CQTest fixtures remain free to create scan-free engines with local RAII ownership.
