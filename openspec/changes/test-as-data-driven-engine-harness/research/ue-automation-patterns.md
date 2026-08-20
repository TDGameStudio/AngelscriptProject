# UE automation patterns (Knot / UE5-main)

Research for `test-as-data-driven-engine-harness`. Sources: Knot knowledgebase `UE5-main` (`d890d83194b04c8aad24d0e904cdb762`) plus this repo's `FAngelscriptScriptTestAutomation`.

A fuller distillation of UE COMPLEX / Spec / Catch2 / CQTest (from the working dump `数据驱动参考.txt`) is `research/ue-data-driven-reference.md`. That attachment is the authority for “what UE data-driven is” and “what we steal from CQTest”. This file stays the shorter Knot + in-repo pattern note.

## COMPLEX / parameterized leaves

`FAutomationTestBase::GenerateTestNames` (Engine `AutomationTest.cpp`) is the data-driven primitive:

1. The test class calls `GetTests(BeautifiedNames, ParameterNames)`.
2. For each index, if `ParameterNames[i]` is non-empty, UE registers:
   - Beautified: `GetBeautifiedTestName() + "." + BeautifiedNames[i]`
   - Complete/test name: `TestName + " " + ParameterNames[i]`
3. `RunTest` receives that parameter string.
4. `GetTestSourceFileName(CompleteName)` may map the parameter back to a data file.

This is how Epic's Python automation test works (`FPythonAutomationTestBase`): it recursively finds `test_*.py`, puts a dotted beautified name in `OutBeautifiedNames`, and the filesystem path in `OutFileNames` (the parameter). Failures then open the `.py` file, not the C++ wrapper.

`IMPLEMENT_COMPLEX_AUTOMATION_TEST` is the historical macro form (`bInComplexTask = true`). Direct `FAutomationTestBase` subclasses with the second constructor argument `true` are equivalent. This repo already does that in `FAngelscriptScriptTestAutomation::FBridge`. Prefer the handwritten subclass: the macro does not make it easy to override `GetTestSourceFileName(const FString& CompleteName)`.

COMPLEX is **one long-lived instance**. Do not store `FAngelscriptEngine*` on that object. Steal CQTest's per-leaf factory: `RunTest` constructs a short-lived session and destroys it before return (`research/ue-data-driven-reference.md`).

`Parameters` is only an `FString`. Use a lookup key (`theme/caseId@profileId`), not a comma-packed observation blob.

## CQTest is not a catalog expander

`CQTest.h` `TTestRunner::GetTests` lists `TEST_METHOD` names collected while the test class is constructed. There is no file-scan or JSON-parameter API. Parameterized CQTest would still be one C++ method per leaf, which is the problem. Rewriting CQTest `GetTests` to scan catalogs is COMPLEX wearing CQTest clothes; do not do that.

CQTest remains the right tool for Bindings, World/HotReload, Debugger, Dump, and latent commands (`FWaitUntil`, `FMapTestSpawner`, PIE network `Then`/`Until`). Those stay out of v1 of this harness. Do not reimplement `TEST_METHOD` / `ASSERT_THAT` on the data-driven base class.

## Skip vs fail

UE AutoRTFM actor-component tests skip with an Info automation event when the runtime is disabled, and still return `true` from `RunTest`. Use the same pattern when a JIT backend or `AS_CAN_GENERATE_JIT` is absent.

## What we copy from our own script-suite bridge

See `research/fbridge-precedent.md`. `FAngelscriptScriptTestAutomation::FBridge` already expands reflected `UAngelscriptTestSuite` methods under `Angelscript.ScriptTests`. Copy only:

- One never-recreated COMPLEX bridge (flag mask identity on the script-suite side; DataDriven may use a single flags mask).
- `GetTests` reads an immutable snapshot.
- Complete name carries a parseable command after the last space.
- `GetTestSourceFileName` / `GetTestSourceFileLine` resolve to the `.as` file.

The data-driven harness SHALL be a **second** COMPLEX class under `Angelscript.TestModule.DataDriven`. It SHALL NOT extend `FBridge`, SHALL NOT use `Angelscript.ScriptTests`, and SHALL NOT execute `UAngelscriptTestSuite` methods. Script suites stay on the compiled project graph; engine-matrix cases construct isolated engines and mounts that graph must not see.
