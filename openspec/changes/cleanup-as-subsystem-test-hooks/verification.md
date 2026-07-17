# Verification

## TDD Red

- Command label: `subsystem-test-hooks-red`
- Result: expected compile failure.
- Evidence: `Saved/Build/subsystem-test-hooks-red/20260717_162814_069_906ec870/UBT.log` reports `error C2338` with `UAngelscriptSubsystem must not expose automation-only controls.`

## Final Build

- Command: `Tools\RunBuild.ps1 -Label subsystem-test-hooks-final-build -TimeoutMs 1800000 -NoXGE`
- Result: succeeded, exit code `0`.
- Output: `Saved/Build/subsystem-test-hooks-final-build/20260717_170026_506_19b74b19/`
- Existing unrelated deprecation warnings remain in `UnversionedPropertySerializationTest.cpp` and `AngelscriptCoverageWidgetTests.cpp`.

## Automation Tests

- `Angelscript.TestModule.Engine.EngineSubsystem`: `5/5` passed.
  - Report: `Saved/Tests/subsystem-test-hooks-final-engine/20260717_170458_751_10db4dd7/Report/index.json`
- `Angelscript.TestModule.Engine.RuntimeModule`: `4/4` passed.
  - Report: `Saved/Tests/subsystem-test-hooks-final-runtime-module/20260717_170553_302_1eef5fd4/Report/index.json`
- `Angelscript.TestModule.Core`: `52/52` passed.
  - Report: `Saved/Tests/subsystem-test-hooks-final-core/20260717_170640_158_6256f04a/Report/index.json`
- A historical process-level scan-free startup run passed before the startup hook was removed; those reports are retained as historical evidence only.

## Static Checks

- `AngelscriptSubsystem.h/.cpp` contain no `WITH_DEV_AUTOMATION_TESTS`, `ForTesting`, override state, or obsolete `bUsesOverridePrimaryEngine` field.
- No source reference remains to the removed Subsystem setters or `FScopedSuppressProductionAngelscriptSubsystem`; only the compile-time negative API probe names the deleted members.
- Current-state architecture/test documents no longer describe a Subsystem initialize override.

## Non-Blocking Observation

- An extra verbose diagnostic run (`subsystem-test-hooks-final-scanfree-verbose`) exposed an existing `FAngelscriptDebugServer::ProcessMessages()` access violation while multiple test engines were ticking. The normal scan-free run passed `5/5`, and the isolated proof run passed with the startup debug port disabled. This change does not modify the unrelated dirty DebugServer files.

## Final Removal Verification

- Final build: `Tools\RunBuild.ps1 -Label remove-scanfree-startup-final-build -TimeoutMs 1800000 -NoXGE` succeeded.
  - Output: `Saved/Build/remove-scanfree-startup-final-build/20260717_173155_330_80d9b4dc/`
- `Angelscript.TestModule.Engine.EngineSubsystem`: `5/5` passed.
  - Report: `Saved/Tests/remove-scanfree-startup-engine/20260717_173243_559_9efb8692/Report/index.json`
- `Angelscript.TestModule.Engine.RuntimeModule`: `4/4` passed.
  - Report: `Saved/Tests/remove-scanfree-startup-runtime-module/20260717_173349_621_9194daa4/Report/index.json`
- `Angelscript.TestModule.Core`: `52/52` passed.
  - Report: `Saved/Tests/remove-scanfree-startup-core/20260717_173435_595_958d0c9d/Report/index.json`
- No implementation or current architecture-documentation reference remains to the removed startup parameter; the OpenSpec proposal/task entries intentionally record that it was removed. Historical archived records are intentionally preserved.
