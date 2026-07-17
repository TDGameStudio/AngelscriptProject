## 1. Record And Red Test

- [x] 1.1 <!-- TDD --> Add a compile-time regression check in `AngelscriptEngineSubsystemTests.cpp` that rejects `SetInitializeOverrideForTesting`, `SetSubsystemOverrideForTesting`, and startup-environment test methods on `UAngelscriptSubsystem`; run `Tools\RunBuild.ps1 -Label subsystem-test-hooks-red -TimeoutMs 180000` and confirm the expected compile failure.

## 2. Remove Runtime Subsystem Test Hooks

- [x] 2.1 <!-- TDD --> Remove all `WITH_DEV_AUTOMATION_TESTS` declarations, static state, setter/reset methods, alternate initialization/lookup branches, and the obsolete override-state field from `AngelscriptSubsystem.h/.cpp`.
- [x] 2.2 <!-- TDD --> Remove the dead `ShouldBootstrapAngelscript()` wrapper and make `ShouldCreateSubsystem()` express the current unconditional production creation rule directly.

## 3. Move Startup And Tests To Test-Owned State

- [x] 3.1 <!-- TDD --> Remove `UAngelscriptSubsystem::SetInitializeOverrideForTesting` usage from `AngelscriptTestModule.cpp` and move per-test engine ownership to CQTest fixtures.
- [x] 3.2 <!-- TDD --> Rewrite `AngelscriptEngineSubsystemTests.cpp` to test ambient engine adoption, idempotence, release behavior, and real subsystem fallback without test-only subsystem methods.
- [x] 3.3 <!-- TDD --> Rewrite `AngelscriptRuntimeModuleTests.cpp` and affected Core tests to remove subsystem suppression/replacement and subsystem initialize overrides while preserving behavior coverage.

## 4. Verify And Document

- [x] 4.1 Run the final no-XGE Editor build and record the output path.
- [x] 4.2 Run `Angelscript.TestModule.Engine.EngineSubsystem` and record pass/fail counts.
- [x] 4.3 Run `Angelscript.TestModule.Engine.RuntimeModule` and record pass/fail counts.
- [x] 4.4 Run `Angelscript.TestModule.Core` and focused engine tests to cover removed shared suppression helpers.
- [x] 4.5 Update related current-state architecture/test documentation, record verification evidence, and run strict OpenSpec validation.

## 5. Remove Process-Level Scan-Free Startup

- [x] 5.1 <!-- TDD --> Remove `AngelscriptTestUseScanFreeStartupEngine`, its TestModule-owned engine/scope/delegate state, and the startup-only configuration helper.
- [x] 5.2 <!-- Non-TDD --> Rewrite current documentation and OpenSpec records to describe CQTest fixture-owned scan-free engines.
- [x] 5.3 <!-- TDD --> Run the Editor build, `Angelscript.TestModule.Engine.EngineSubsystem`, `Angelscript.TestModule.Engine.RuntimeModule`, and `Angelscript.TestModule.Core`; verify no active source/documentation reference remains to the removed startup option.
