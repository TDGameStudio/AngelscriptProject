---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "2.1": ["1.3"]
---

## 1. Replacement CQTest boundary

- [x] 1.1 Add the failing NativeEngine CQTest and expose CQTest only through the replacement gate — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestFoundationTests.cpp`

  > Produces: A scenario-oriented CQTest class beneath `Angelscript.UnitTest.NativeEngine.Foundation` that compiles with `WITH_ANGELSCRIPT_TESTS=1` while the legacy gate remains `0`.

  > Constraints: Include CQTest explicitly. Do not move `.ubtignore`, add a force include, expose legacy include paths, start an engine pool, or use `ASTEST_*`.

  1. Add compile-time and runtime assertions that describe the isolated replacement boundary and observe the initial missing-dependency or missing-foundation RED.
  2. Add the minimum editor-only CQTest dependency controlled by the replacement gate.
  3. Rebuild the exact editor target through Harness and require the new translation unit to compile without legacy sources.

- [x] 1.2 Implement the replacement-only fixture surface and rebuild its scenarios — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'native-engine-foundation-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestSupport.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestFoundationTests.cpp`

  > Inputs: The CQTest dependency from Task `1.1` and the real Automation discovery evidence that CQTest inserts its C++ class name between the directory and method components.

  > Produces: Small source/diagnostic fixture primitives that later Changes can extend without constructing a live engine.

  1. Preserve the pre-support Foundation run, then correct the public identity by using `Angelscript.UnitTest.NativeEngine` as the CQTest directory, `Foundation` as the class token, and each `TEST_METHOD` as the scenario token.
  2. Keep support code replacement-local and free of legacy test headers and runtime bootstrap helpers.
  3. Assert the exact `Angelscript.UnitTest.NativeEngine.Foundation.<Scenario>` paths, local ownership, deterministic cleanup, and absence of legacy Automation registrations, then rebuild the exact editor target.

- [x] 1.3 Prove the freshly built foundation and discovery boundary in one Fast run — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Foundation'; Label = 'native-engine-foundation-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestSupport.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestFoundationTests.cpp`

  1. Require the build evidence from Task `1.2` to match the current test-source content.
  2. Run the full Foundation prefix once and require every CQTest scenario to pass without legacy registrations.
  3. Record the managed run ID, pass/fail counts, report path, and process outcome.

## 2. Contract synchronization

- [x] 2.1 Align the testing guide and durable baseline with the verified foundation, then strictly validate both records — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-native-engine-test-foundation','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'NativeEngine foundation Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `.agents/skills/angelscript-test-guide/SKILL.md`, `openspec/changes/angelscript/refactor-native-engine-test-foundation/proposal.md`, `openspec/changes/angelscript/refactor-native-engine-test-foundation/design.md`, `openspec/changes/angelscript/refactor-native-engine-test-foundation/specs/angelscript/testing/baseline/spec.md`, `openspec/changes/angelscript/refactor-native-engine-test-foundation/tasks.md`, `openspec/changes/angelscript/refactor-native-engine-test-foundation/attachments/INDEX.md`, `openspec/specs/angelscript/testing/baseline/spec.md`

  > Constraints: Describe CQTest as the replacement assertion/registration library only. Preserve the legacy isolation reference and do not restore its old execution guidance as a default.

  1. Update the test Skill after the real build and exact-prefix proof establish the new supported pattern.
  2. Semantically merge the delta into the current testing baseline.
  3. Re-run the incremental build and exact Foundation prefix if final content changes the compiled test boundary, then run exact strict Change validation and strict current-spec validation before completing this terminal synchronization task.

  Intentionally omit Harness `Quick`, `Performance`, and `Integration`, full UE suites, Standalone, and legacy tests: the direct editor build and exact Foundation prefix prove the only affected build and discovery boundary.
