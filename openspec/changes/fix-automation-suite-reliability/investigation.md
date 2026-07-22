# Automation Reliability Investigation — 2026-07-22

## Scope

This record covers the failures found after the UHT Runtime-linked function
binding consolidation. It deliberately excludes Wiki changes. The UHT focused
tests are retained as a negative finding: they passed and are not a target of
this change.

## Initial full-suite observation

Command:

```powershell
Tools\RunTestSuite.ps1 -Suite All -LabelPrefix uht-single-module-binding-all-20260722 -TimeoutMs 900000 -ContinueOnFail
```

Reported result: **1565 total, 1543 passed, 22 failed, 0 skipped**.

The failure distribution was:

| Group | Failure count | Observation |
|---|---:|---|
| Editor | 3 | Settings registration and no-engine test-gate assumptions |
| Engine | 7 | Primary-subsystem engine fallback invalidates legacy no-ambient-engine expectations |
| FunctionLibraries | 2 | Exception-stack source-coordinate expectations lag current fixture text |
| StaticJIT | 10 | Nine AOT fixture-cache dependent failures plus one no-current-engine diagnostics assertion |

The runner also reported no matching tests for `AngelScriptSDK` (crash before
report), `ClassGenerator`, `Debugger` (timeout), and `ScriptClass`.

## Confirmed root causes

### AngelScript builder stale pointer

`asCBuilder::BuildCompileCode` deletes enum-value
`sGlobalVariableDescription` instances after removing them from `globVariables`.
It does not remove the same pointers from `globVariableList`. The SDK test's
post-build diagnostic helper enumerates `globVariableList`, causing a dangling
pointer dereference. This is a fork ownership/cleanup defect, not a test-only
assertion mismatch.

### Editor Settings registration timing

`FAngelscriptEditorModule::StartupModule()` uses
`GetModulePtr<ISettingsModule>("Settings")`. At `PostDefault`, Settings is
allowed not to be loaded, so both register calls and the compile-options
`OnModified` binding are silently skipped forever. The module already declares
Settings as a private build dependency; deterministic startup acquisition is the
appropriate repair.

### Ambient engine test model

`FAngelscriptEngine::TryGetCurrentEngine()` first uses the engine context stack
and then falls back to the `UAngelscriptSubsystem` primary engine. Calling
`SnapshotAndClear()` only removes the first source. Tests that intend to assert
the no-engine path must explicitly suppress the resolver for their scope;
tearing down the editor subsystem would be unsafe global test mutation.

### StaticJIT AOT cache

`StaticJITAotFixture.Cache` is ignored and is not currently tracked by the
plugin Git index. Existing runtime AOT tests nevertheless read it from the
test source-tree generated-artifact directory. Its build identifier did not
match the current build, so precompiled-data loading correctly failed and
registration/dispatch tests failed as a consequence.

The existing `as-static-jit-aot-test` shared spec describes this cache as a
local ignored prerequisite. The new design makes that prerequisite
self-provisioning under `Saved/` and keeps committed generated C++ source
verification separate.

### Test suite prefix drift

The suite uses obsolete prefixes:

- `Angelscript.TestModule.ClassGenerator`
- `Angelscript.TestModule.ScriptClass`

Current registrations are under `Angelscript.TestModule.Generator.*`, including
`Generator.ScriptClass.*`. A single Generator group avoids both no-match reports
and duplicated execution.

## Debugger observation

The full suite timed out in Debugger once. Follow-up runs passed:

| Prefix | Result |
|---|---:|
| `Angelscript.TestModule.Debugger.Breakpoint.FAngelscriptDebuggerBreakpointTests.HitLine` | 1 / 1 |
| `Angelscript.TestModule.Debugger.Breakpoint` | 7 / 7 |
| `Angelscript.TestModule.Debugger` | 32 / 32 |

This does not prove the original timeout's cause. Independently, the server's
current receive loop reads a header/payload to completion after only one
`HasPendingData` check. TCP may split either component across reads. Incremental
per-client framing is therefore an objective robustness repair and is specified
without claiming it is the unique root cause of the timeout.

## UHT negative finding

The focused generated Runtime-linked function-binding tests passed 3 / 3, and
the Engine assertion that generated Runtime-linked modules use one named source
file also passed. No UHT generation logic is planned in this OpenSpec.
