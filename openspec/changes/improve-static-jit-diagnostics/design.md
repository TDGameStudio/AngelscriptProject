## Context

The completed `refactor-as-static-jit-test` change added AOT tests that prove generated StaticJIT code can be generated, built into `AngelscriptTest`, registered, attached, and executed. To do that, it introduced narrow runtime helpers on `FAngelscriptEngine`: `LoadPrecompiledDataForTesting`, `CompileLoadedPrecompiledDataForTesting`, and `GetStaticJITFunctionIdForTesting`.

Those helpers are currently used only by StaticJIT AOT tests. The problem is not just the function-id lookup; cache loading and compilation are also StaticJIT AOT fixture operations exposed as Engine test APIs. The desired replacement is a real diagnostics surface: useful for a developer investigating StaticJIT state, available to automation, and absent from Shipping builds.

## Goals / Non-Goals

**Goals:**

- Remove StaticJIT-specific `ForTesting` methods from `FAngelscriptEngine`.
- Provide non-Shipping StaticJIT diagnostics that can load/compile diagnostic precompiled data, resolve function ids, inspect generated registration, and observe generated entry execution.
- Add `as.StaticJIT.DumpDiagnostics` for human troubleshooting.
- Keep AOT tests at `Angelscript.TestModule.StaticJIT.AOT.*` and preserve their current behavioral coverage.

**Non-Goals:**

- Do not clean up every `Test`, `Testing`, or `ForTesting` symbol in the Runtime module.
- Do not redesign StaticJIT global state ownership or `FJITDatabase`.
- Do not change generated AOT fixture semantics except where needed to call renamed diagnostics markers.
- Do not expose diagnostics in Shipping builds.

## Decisions

- Use a dedicated StaticJIT diagnostics surface instead of Engine public methods. `FStaticJITDiagnostics` or an equivalent StaticJIT-owned type will own cache diagnostic operations, function-id lookup, registry checks, and execution counters.
- Gate the surface with `AS_WITH_STATIC_JIT_DIAGNOSTICS`, defaulting to non-Shipping builds. This keeps Development/Debug automation usable while excluding the surface from Shipping.
- Keep access to `FAngelscriptEngine::PrecompiledData` narrow. If diagnostics need private engine state, prefer a specific friend declaration or private StaticJIT helper over replacement public Engine methods.
- Make the console command consume the same diagnostics code as automation. Tests and manual debugging should exercise the same state model.
- Treat the AOT cache load/compile helpers as diagnostics operations, not test helpers. Error messages and API names should describe diagnostic/precompiled-data behavior without `Test` vocabulary.

## Risks / Trade-offs

- **Diagnostic code still lives in Runtime** -> It is justified by a real console command and non-Shipping troubleshooting surface, not only automation.
- **Non-Shipping surface can grow too broad** -> Keep this change limited to StaticJIT AOT cache, registry, function-id, and entry-counter diagnostics.
- **Private engine access may require a friend** -> Use the narrowest possible friend or helper and avoid adding public Engine methods.
- **Console command output can become unstable for tests** -> Prefer testing structured diagnostics helpers directly; console command tests only verify registration and failure-safe execution where practical.
