## 1. Baseline and Compile Fallout

- [x] 1.1 <!-- Non-TDD --> Record current rename state: `UAngelscriptSubsystem` inherits `UEngineSubsystem`, old `UAngelscriptEngineSubsystem.*` files are deleted, `UAngelscriptGameInstanceSubsystem.*` still exists; verify with `rg -n "class .*Angelscript.*Subsystem" Plugins\Angelscript\Source\AngelscriptRuntime\Core`.
- [x] 1.2 <!-- Non-TDD --> Build once to capture current IDE rename fallout; verify with `Tools\RunBuild.ps1 -TimeoutMs 1200000 -NoXGE -Label as-subsystem-owner-baseline`.
- [x] 1.3 <!-- Non-TDD --> Fix compile fallout caused by renaming `UAngelscriptEngineSubsystem` to `UAngelscriptSubsystem`.

## 2. Engine-Level Ownership Tests

- [x] 2.1 <!-- TDD --> Update engine subsystem lifecycle tests in `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptEngineSubsystemTests.cpp` to use `UAngelscriptSubsystem` as the engine-level owner; verified with `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.EngineSubsystem" -Label as-subsystem-engine-subsystem-final -TimeoutMs 900000`.
- [x] 2.2 <!-- TDD --> Add or update tests proving `UAngelscriptSubsystem::Get()->GetEngine()` is the preferred subsystem path for the primary engine.
- [x] 2.3 <!-- TDD --> Add or update tests proving `FAngelscriptEngine::TryGetCurrentEngine()` resolves scoped engines first, then `UAngelscriptSubsystem`, then null.
- [x] 2.4 <!-- TDD --> Add or update tests proving `UAngelscriptSubsystem::Tick` is the single engine tick path when the primary engine should tick.

## 3. Runtime Creation Policy

- [x] 3.1 <!-- Non-TDD --> Decide whether `UAngelscriptSubsystem::ShouldCreateSubsystem()` should create in runtime builds, not only editor/commandlet; recorded in `design.md`.
- [x] 3.2 <!-- TDD --> Add a test or test-access case covering the chosen runtime creation policy.
- [x] 3.3 <!-- Non-TDD --> Implement the chosen `ShouldBootstrapAngelscript()` policy in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.cpp`.
- [x] 3.4 <!-- Non-TDD --> Update `FAngelscriptRuntimeModule::InitializeAngelscript()` to route through `UAngelscriptSubsystem` only.

## 4. Delete Native GameInstance Engine Manager

- [x] 4.1 <!-- TDD --> Delete or rewrite `AngelscriptGameInstanceSubsystemRuntimeTests.cpp`; replace native `UAngelscriptGameInstanceSubsystem` ownership assertions with engine-level `UAngelscriptSubsystem` tests.
- [x] 4.2 <!-- Non-TDD --> Delete native game-instance engine manager source files from runtime.
- [x] 4.3 <!-- Non-TDD --> Remove `UAngelscriptGameInstanceSubsystem::HasAnyTickOwner()` gating from `UAngelscriptSubsystem::Tick`.
- [x] 4.4 <!-- Non-TDD --> Remove `UAngelscriptGameInstanceSubsystem::GetCurrent()` from `FAngelscriptEngine::IsInitialized()` and `TryGetCurrentEngine()`; use `UAngelscriptSubsystem` instead.
- [x] 4.5 <!-- Non-TDD --> Remove now-unused friend declarations and includes from `AngelscriptEngine.h`, `AngelscriptEngine.cpp`, and `AngelscriptRuntimeModule.cpp`.
- [x] 4.6 <!-- Non-TDD --> Keep `UScriptGameInstanceSubsystem` and its tests intact; verified with `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.GameInstanceSubsystem" -Label as-script-gameinstance-subsystem-final -TimeoutMs 900000`.

## 5. Binding and Helper Cleanup

- [x] 5.1 <!-- Non-TDD --> Update `AngelscriptSubsystemBindingsTests.cpp`: `UAngelscriptSubsystem` is engine-level; use `UAngelscriptTestGameInstanceSubsystem` as a test-only `UGameInstanceSubsystem` fixture passed to script as `UClass`/`UObject`.
- [x] 5.2 <!-- Non-TDD --> Update shared test acquisition helpers in `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestEngineAcquisition.h` to use `UAngelscriptSubsystem`.
- [x] 5.3 <!-- Non-TDD --> Update `AngelscriptMockDebugServer.h`, `AngelscriptTestEngineHelperTests.cpp`, and isolation tests that mention production game-instance subsystem availability.
- [x] 5.4 <!-- Non-TDD --> Run `rg -n "UAngelscriptGameInstanceSubsystem|AngelscriptGameInstanceSubsystem|HasAnyTickOwner" Plugins\Angelscript\Source` and remove all production/test hits, except the intentionally named test-only fixture `UAngelscriptTestGameInstanceSubsystem`.

## 6. Verification and Commit

- [x] 6.1 <!-- Non-TDD --> Run focused engine subsystem tests with `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.EngineSubsystem" -Label as-subsystem-engine-subsystem-final -TimeoutMs 900000` (`4 passed / 0 failed`).
- [x] 6.2 <!-- Non-TDD --> Run subsystem binding tests with `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.Subsystem" -Label as-subsystem-bindings-final -TimeoutMs 900000` (`3 passed / 0 failed`).
- [x] 6.3 <!-- Non-TDD --> Run plugin build with `Tools\RunBuild.ps1 -TimeoutMs 1200000 -NoXGE -Label as-subsystem-final-build` (exit 0).
- [x] 6.4 <!-- Non-TDD --> Review submodule and root diffs; committed `Plugins/Angelscript` first (`c1a25d5`), then parent gitlink and OpenSpec artifacts (`83c4ba7`).
