## Context

`AngelscriptTest` has two related but distinct build-hygiene failure modes:

1. Unity chunks can leak file-level helper symbols into later included test files. The archived change `fix-angelscript-test-unity-symbol-scope` addressed that by banning file-level private/support namespace imports and reducing unity symbol pollution.
2. Non-unity or differently grouped unity builds can expose missing direct dependencies. This new failure is the second mode: a test source compiles only when another source file happens to include a helper header or introduce a namespace before it in the generated unity translation unit.

The reported failures are all in test code, not in the runtime plugin surface. They point to missing direct declarations or incomplete SDK type visibility:

- `ExecuteScriptFunction` is declared in `AngelScriptSDK/AngelscriptSDKTestExecutionHelpers.h`.
- `FParserAccessor` is declared under `AngelscriptNativeTestSupport` in `AngelScriptSDK/AngelscriptNativeTestSupport.h`.
- `ASTEST_CREATE_ENGINE` is a macro from `Shared/AngelscriptTestMacros.h`.
- `CreateIsolatedFullEngine` is declared in `Shared/AngelscriptTestEngineAcquisition.h`.
- `CompileScriptModule`, `SpawnScriptActor`, `BeginPlayActor`, and `ReadPropertyValue` are helpers in `AngelscriptFunctionalTestUtils`.
- `asCModule` derives from `asIScriptModule`, but that relationship must be visible at the call site when calling public-interface StaticJIT diagnostics APIs.

## Goals / Non-Goals

**Goals:**

- Make the reported failing test files compile as independent translation units.
- Preserve the previous unity-symbol hygiene guarantees.
- Keep changes limited to explicit include ownership, namespace qualification/import placement, and type-boundary clarity.
- Add a reusable audit path so future helper additions do not reintroduce hidden unity-order dependencies.
- Document exact verification commands and expected failure/pass signals.

**Non-Goals:**

- Do not disable unity build, UBA, or UBT adaptive unity as the fix.
- Do not change runtime Angelscript behavior or public APIs.
- Do not introduce broad umbrella includes to hide missing direct dependencies.
- Do not refactor unrelated tests or change test intent.
- Do not archive or rewrite the earlier `fix-angelscript-test-unity-symbol-scope` history.

## Decisions

### Decision 1: Fix source self-containment, not build configuration

The correct invariant is that each `.cpp` must see declarations for every symbol it uses through its own includes and local namespace choices. Turning off UBA/unity or forcing a particular chunk order would only hide the issue on one machine.

Alternative considered: add `bUseUnity = false` or similar module-level switches for `AngelscriptTest`. That would reduce one class of order-dependent behavior but slow builds and still would not document which helper dependencies each test owns.

### Decision 2: Prefer specific helper includes over umbrella includes

Each failing file should include the header that owns the symbol it uses:

- `AngelscriptGlobalVarTests.cpp` includes `AngelscriptSDKTestExecutionHelpers.h` for `ExecuteScriptFunction`.
- `AngelscriptParserTests.cpp` includes `AngelscriptNativeTestSupport.h` for `FParserAccessor`.
- `AngelscriptStaticJITDiagnosticsTests.cpp` includes `AngelscriptTestMacros.h` for `ASTEST_CREATE_ENGINE`.
- `AngelscriptStaticJITAotGeneration.cpp` includes `AngelscriptTestEngineAcquisition.h` for `CreateIsolatedFullEngine`.
- `AngelscriptHotReloadVersionChainTests.cpp` explicitly qualifies `AngelscriptFunctionalTestUtils` helpers or introduces a narrow function-scope import in the functions that use them.

Alternative considered: include `AngelscriptTestUtilities.h` or `AngelscriptTestMacros.h` broadly in every failing file. That may compile quickly but recreates hidden transitive dependencies and makes future include ownership harder to reason about.

### Decision 3: Keep helper namespace visibility local

For helper namespaces, use one of two forms:

- Explicit qualification, e.g. `AngelscriptFunctionalTestUtils::CompileScriptModule(...)`.
- Function-body `using namespace AngelscriptFunctionalTestUtils;` only inside a test/helper function that uses several names.

Do not add file-level helper namespace imports. This preserves the archived unity-symbol hygiene rule and prevents fixing non-unity failures by reintroducing unity leakage.

### Decision 4: Make SDK internal/public type boundaries explicit

When a test has an internal SDK pointer such as `asCModule*` and calls an API declared against the public interface `asIScriptModule*`, the implementation should ensure the derived/base relationship is visible by including the appropriate SDK internal header at that call site. If compiler visibility is still not enough, the call should cast explicitly to the public interface with the narrowest clear form at the boundary.

This keeps the StaticJIT diagnostics API public-facing while allowing tests that inspect internal AngelScript structures to bridge cleanly.

### Decision 5: Add an audit for self-containment risks

The first implementation should fix the reported files directly. A follow-up audit script can detect likely regressions by scanning test `.cpp` files for:

- Calls to known helper symbols without their owning header in the same file.
- Unqualified helper calls from known helper namespaces without explicit qualification or local import.
- Use of SDK test support namespace symbols without `AngelscriptSDKTestExecutionHelpers.h` or `AngelscriptNativeTestSupport.h`.

This audit should be advisory at first because C++ include ownership can be affected by legitimate local headers. Promote it to fail-on-required only after it has low false positives.

## Risks / Trade-offs

- **Risk:** A direct include creates a cycle in a helper header that was previously masked by unity order.
  **Mitigation:** Use the narrowest owning header first; if a cycle appears, split declarations into a smaller helper header instead of adding an umbrella include.

- **Risk:** Explicit qualification makes some test code noisy.
  **Mitigation:** Use function-body namespace imports when a function uses many helpers, but keep imports out of file scope.

- **Risk:** StaticJIT `asCModule*` conversion may differ by compiler/include order.
  **Mitigation:** Include `source/as_module.h` where internal `asCModule` is used and cast once at the public API boundary if needed.

- **Risk:** Local verification might pass in unity mode but miss a future non-unity-only problem.
  **Mitigation:** Add the direct self-containment audit and run the standard build with `-NoXGE`; if tooling supports it later, add a targeted non-unity compile command through `Tools\RunBuild.ps1` extra args.

## Migration Plan

1. Fix the five reported files with direct includes and local namespace/type-boundary changes.
2. Run a targeted static audit for the reported helper symbols.
3. Run `git -C Plugins/Angelscript diff --check`.
4. Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label nonunity-self-containment -TimeoutMs 600000 -NoXGE`.
5. If the build finds more missing symbols, classify each as missing direct include, missing namespace qualification, or incomplete SDK type visibility, then update `tasks.md` before applying the same pattern.

Rollback is straightforward because all implementation changes should be limited to test source includes/call qualification and OpenSpec records.

## Open Questions

- Should the self-containment audit become a permanent required check after the first implementation, or stay as a diagnostic script until false positives are understood?
- Does `Tools\RunBuild.ps1` currently support a clean, documented way to force a non-unity AngelscriptTest build for verification, or should this change only document normal build plus static audit for now?
