# Tasks: Refactor AS Execution Context

## 1. Baseline and Boundary Map

- [ ] 1.1 <!-- Non-TDD --> Record current `FAngelscriptEngine::Get()` / `TryGetCurrentEngine()` / `FAngelscriptEngineScope` counts by directory; expected output: notes in this change or design update; verify with `rg -n "FAngelscriptEngine::Get\\(|TryGetCurrentEngine\\(|FAngelscriptEngineScope" Plugins\Angelscript\Source`.
- [ ] 1.2 <!-- Non-TDD --> Classify current engine access call sites by purpose: boundary access, script-engine access, settings access, module/class lookup, hook subscription, service access, and tests; verify with category notes in `design.md`.
- [ ] 1.3 <!-- Non-TDD --> Identify ownership call sites in `AngelscriptRuntimeModule.cpp`, `AngelscriptEngineSubsystem.cpp`, and `AngelscriptGameInstanceSubsystem.cpp`; verify with `rg -n "FAngelscriptEngineContextStack|TryGetCurrentEngine|PrimaryEngine|OwnedEngine" Plugins\Angelscript\Source\AngelscriptRuntime\Core`.

## 2. Execution Context API

- [ ] 2.1 <!-- TDD --> Add focused runtime tests for nested execution scopes restoring the previous context; expected coverage: current engine, world context, and phase restoration; verify with `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Core"`.
- [ ] 2.2 <!-- TDD --> Add focused runtime tests for `TryCurrent()` returning null outside scope and `Current()` producing existing-style diagnostics/check behavior; verify with `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Core"`.
- [ ] 2.3 <!-- Non-TDD --> Implement `FAngelscriptExecutionContext` as a non-owning current call-chain view with engine, script engine, world context, and phase accessors.
- [ ] 2.4 <!-- Non-TDD --> Implement `FAngelscriptExecutionScope` as the RAII push/pop owner for execution context.
- [ ] 2.5 <!-- Non-TDD --> Keep `FAngelscriptEngineScope` as a compatibility wrapper over `FAngelscriptExecutionScope`.

## 3. Compatibility Routing

- [ ] 3.1 <!-- Non-TDD --> Route `FAngelscriptEngine::TryGetCurrentEngine()` through `FAngelscriptExecutionContext` without changing external behavior.
- [ ] 3.2 <!-- Non-TDD --> Route `FAngelscriptEngine::Get()` through `FAngelscriptExecutionContext::Current().Engine()` while preserving existing check/log semantics.
- [ ] 3.3 <!-- Non-TDD --> Move ambient world-context assignment and lookup behind the execution-context implementation while preserving existing public wrappers.
- [ ] 3.4 <!-- Non-TDD --> Build after compatibility routing; verify with `Tools\RunBuild.ps1`.

## 4. Ownership Call-Site Migration

- [ ] 4.1 <!-- Non-TDD --> Migrate `UAngelscriptEngineSubsystem` current-engine push/pop and restore behavior to `FAngelscriptExecutionScope` or the new context stack API.
- [ ] 4.2 <!-- Non-TDD --> Migrate `UAngelscriptGameInstanceSubsystem` current-engine ownership and tick context behavior to the new context model.
- [ ] 4.3 <!-- Non-TDD --> Migrate `FAngelscriptRuntimeModule::InitializeAngelscript()` fallback/override context handling to the new context model.
- [ ] 4.4 <!-- TDD --> Add or update lifecycle tests covering subsystem-owned, game-instance-owned, and test override engine resolution; verify with `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Core"`.

## 5. High-Risk Access Pattern Reduction

- [ ] 5.1 <!-- Non-TDD --> Replace direct `FAngelscriptEngine::Get().Engine` call sites with `GetScriptEngine()` or explicit `asIScriptEngine&` parameters in one low-risk directory.
- [ ] 5.2 <!-- Non-TDD --> Replace direct `FAngelscriptEngine::Get().StaticJIT` access with a narrow static-JIT service accessor or explicit dependency.
- [ ] 5.3 <!-- Non-TDD --> Replace direct `FAngelscriptEngine::Get().DebugServer` access with a debug service accessor or extension-owned entry point.
- [ ] 5.4 <!-- Non-TDD --> Replace direct settings reads in non-boundary helper code with an engine settings view or explicit settings parameter.
- [ ] 5.5 <!-- Non-TDD --> Build after each directory-sized migration batch; verify with `Tools\RunBuild.ps1`.

## 6. Service and Hook Migration Rules

- [ ] 6.1 <!-- Non-TDD --> Document that long-lived hook subscribers should use `IAngelscriptExtension` attach/detach rather than direct `FAngelscriptEngine::Get().GetOnXxx().Add...`.
- [ ] 6.2 <!-- Non-TDD --> Update code coverage and crash snapshot refactor records to reference `as-execution-context` as the access-boundary rationale if those changes remain active.
- [ ] 6.3 <!-- Non-TDD --> Identify debug, StaticJIT, diagnostics, and reload observers that should become engine-attached services; record follow-up tasks rather than migrating all in this change.

## 7. Guardrails and Documentation

- [ ] 7.1 <!-- Non-TDD --> Add a static scan or validation test that rejects new `FAngelscriptEngine::Get().Engine` usage outside an allowlist.
- [ ] 7.2 <!-- Non-TDD --> Add static scans or documented allowlists for `Get().StaticJIT`, `Get().DebugServer`, and `Get().CodeCoverage`.
- [ ] 7.3 <!-- Non-TDD --> Update runtime architecture documentation to define boundary-layer `FAngelscriptExecutionContext::Current()` usage versus explicit dependency passing.
- [ ] 7.4 <!-- Non-TDD --> Update test guide examples only after shared helpers expose `FAngelscriptExecutionScope`.

## 8. Verification and Closure

- [ ] 8.1 <!-- Non-TDD --> Run focused core/lifecycle tests with `Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Core"`.
- [ ] 8.2 <!-- Non-TDD --> Run a plugin build with `Tools\RunBuild.ps1`.
- [ ] 8.3 <!-- Non-TDD --> Run affected suite groups with `Tools\RunTestSuite.ps1` after ownership and high-risk access migrations.
- [ ] 8.4 <!-- Non-TDD --> Recount legacy `FAngelscriptEngine::Get()` patterns and record the before/after numbers in this change.

