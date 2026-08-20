# What `FBridge` is (script-suite COMPLEX adapter)

Short record for `test-as-data-driven-engine-harness`. This is the in-repo precedent people mean by “跟 FBridge 一样”. It is **not** the data-driven harness.

## The class

`FAngelscriptScriptTestAutomation::FBridge` lives in

`Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptScriptTestAutomation.cpp`

It is a private handwritten subclass of `FAutomationTestBase` constructed with `bInComplexTask = true`. `FAngelscriptScriptTestAutomation` owns one never-recreated bridge per Automation flag mask.

It already does UE COMPLEX leaf expansion for **reflected script suites**:

1. `GetTests` reads an immutable `FAngelscriptScriptTestRegistry` snapshot and emits one leaf per `UAngelscriptTestSuite` method.
2. `OutTestCommands` is a parseable script-test id (a key), not a packed blob.
3. `RunTest(Parameters)` parses that key and calls `FAngelscriptScriptTestRunner::Run`.
4. `GetTestSourceFileName` / `GetTestSourceFileLine` resolve to the suite `.as` method, not the C++ bridge.

Beautified root: `Angelscript.ScriptTests`.

## What “same as FBridge” means

Copy **this mechanism** into a **second** COMPLEX class under `AngelscriptTest/DataDriven/`:

- handwritten `FAutomationTestBase`, not `IMPLEMENT_COMPLEX_AUTOMATION_TEST`
- `GetTests` from a snapshot
- `Parameters` as a lookup key
- jump-to-source from the complete test name

Do **not** reuse `FBridge`, do **not** register DataDriven leaves under `Angelscript.ScriptTests`, and do **not** execute `UAngelscriptTestSuite` methods from the matrix harness.

## Sibling, not the same bridge

| | `FBridge` (exists) | DataDriven Automation (this change) |
|---|---|---|
| Expands | reflected `UAngelscriptTestSuite` methods | `Fixtures` + `cases.json` `(case, profile)` |
| Prefix | `Angelscript.ScriptTests.*` | `Angelscript.TestModule.DataDriven.*` |
| Engine | production-like compiled module graph | shared or isolated; Cache / JIT owned by the profile |
| Command | script-test id | `theme/caseId@profileId` |
| Owner | `AngelscriptRuntime/Testing` | `AngelscriptTest/DataDriven` |

Script functional tests keep `FBridge`. Engine-config matrix tests get the new bridge. `as-script-test-suite-runner` stays a sibling capability.
