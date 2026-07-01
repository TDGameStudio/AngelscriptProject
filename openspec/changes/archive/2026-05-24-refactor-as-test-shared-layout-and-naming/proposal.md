## Why

`Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h` had grown into a **1093-line "god header"**. It inlined seven unrelated responsibility areas in one file: production/isolated/transient engine acquisition, UASClass + BP Action DB GC cleanup, memory probes, shared-engine reset + debug logging, module compilation/function lookup, AS function execution/exception assertions, and `FAngelscriptTestFixture`. It also leaked `BlueprintActionDatabase.h`, `K2Node_GetSubsystem.h`, and the three SDK headers into **400+ test `.cpp` files**. At the same time, `Shared/` still contained four pure forwarding aliases (`GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`, about 46 historical call sites).

Separately, the "call an AS function" entry point was fragmented across the 71 `.cpp` files in `AngelscriptTest/Bindings/`: `Shared/AngelscriptBindingsAssertions.h` provided nine one-line `Expect*` assertions, `Shared/AngelscriptGlobalFunctionInvoker.h` provided the low-level fluent `FASGlobalFunctionInvoker`, individual `Bindings/*.cpp` files had another 4-5 private `Execute*Function*` helpers (Math/Orientation/Curve/WorldFunc, etc.), and `AngelscriptTestUtilities.h` carried its own `ExecuteIntFunction*` / `ExecuteInt64Function`. The same intent had at least seven parallel entry points, with naming families (`Expect*` / `Execute*Function*` / `.Call()` / `.CallAndReturn`) that did not align with each other, UE style, or the underlying AS `asIScriptContext::Execute()` API.

This change consolidates that into a pure umbrella header plus six themed headers, and adds a seventh themed header, `AngelscriptTestExecute.h`, as the single execution entry point. It also establishes an `Execute`-rooted naming family contract: `Execute` / `ExecuteAndGet<T>` / `ExecuteAndExpect<Type>` / `ExecuteAndExpectNear<Type>` / `ExecuteBatchAndExpect<Type>` / `ExecuteAndValidate<T>` / `ExecuteAndExpectException` / `CompileAndExpectFailure`. **New code must use the `Execute*` family**. All old symbols / old headers / scattered helpers remain permanently compatible through inline aliases and forwarding headers, so every existing repository call site continues to compile. A follow-up change will progressively rename and clean up legacy call sites.

## What Changes

### Header split (original proposal scope + one themed header rename)

- Split the 1093-line inline implementation in `AngelscriptTestUtilities.h` into **six themed headers + one `.cpp`** (all flat under `Shared/`): `AngelscriptTestEngineAcquisition.h/.cpp`, `AngelscriptTestEngineCleanup.h`, `AngelscriptTestMemoryProbe.h`, `AngelscriptTestModuleBuilder.h`, **`AngelscriptTestExecute.h`** (renamed from the original proposal's `AngelscriptTestExecution.h` to align with the new execution family), and `AngelscriptTestFixture.h`.
- Shrink `AngelscriptTestUtilities.h` into a **~40-line pure umbrella header** that only includes the six new headers plus the existing `AngelscriptTestEngine.h` and `Misc/AutomationTest.h`. It remains the compatibility include entry for 400+ test `.cpp` files and no longer contains function implementations.
- **BREAKING inside the test module only**: retire four pure forwarding aliases (`GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`) and replace their ~46 call sites with `GetOrCreateSharedCloneEngine` / `AcquireCleanSharedCloneEngine` / `ResetSharedCloneEngine`. This does **not** affect external plugins such as `AngelscriptGAS`, because audit showed these aliases were only called inside the `AngelscriptTest` module.
- Constrain `WITH_EDITOR` dependencies on `BlueprintActionDatabase` / `K2Node_*` to a single file, `AngelscriptTestEngineCleanup.h`, so they no longer propagate to every test TU.
- Add `Shared/README.md` as a one-screen navigation index for 47+ files, aligned with the helper recommendation table in `TestConventions.md`.
- Add a ~15-line block comment at the top of each new header explaining responsibility boundaries, dependency headers, and typical callers.

### Single-file Execute consolidation (new expanded responsibility of the seventh themed header)

- **`AngelscriptTestExecute.h` absorbs**:
  - The full old `Shared/AngelscriptGlobalFunctionInvoker.h` content (408 lines): low-level fluent executor + `ResolveFunctionByDecl` / `ResolveFunctionByName`.
  - The full old `Shared/AngelscriptBindingsAssertions.h` content (378 lines): one-line `Expect*` assertion family.
  - The `ExecuteIntFunction` / `ExecuteIntFunctionExpectingScriptException` / `ExecuteInt64Function` block from `AngelscriptTestUtilities.h` lines 873-1015.
- Convert the two old shared headers into permanent forwarding headers: `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` shrink to ~3-line `#include "AngelscriptTestExecute.h"` stubs. Final deletion is deferred to a follow-up change.
- Leave file-private `Execute*Function*` helpers inside `Bindings/*.cpp` unchanged for now. Add `// TODO(refactor-as-test-shared-layout-and-naming): migrate to AngelscriptTestExecute.h` near those helpers, and migrate them file-by-file in follow-up work.

### `Execute*` naming family contract

Create `FAngelscriptTestExecutor` plus an `Execute`-rooted free-function family with token order `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect|(empty)][Near|AtLeast|(empty)][<Type>|<T>]`:

| Old API (permanent inline alias) | New API (canonical entry) |
|---------------------------|-------------------|
| `FASGlobalFunctionInvoker` | `FAngelscriptTestExecutor` |
| `.Call()` | `.Execute()` |
| `.CallAndReturn<T>(Fallback)` | `.ExecuteAndGet<T>(Fallback)` |
| `.ReadReturnStruct<T>(Out)` | `.ExecuteAndExtractStruct<T>(Out)` |
| `ExpectGlobalInt` / `ExpectGlobalBool` / `ExpectGlobalDouble` | `ExecuteAndExpectInt` / `ExecuteAndExpectBool` / `ExecuteAndExpectDouble` |
| `ExpectGlobalReturnFloat` | `ExecuteAndExpectNearFloat` |
| (new) | `ExecuteAndExpectNearDouble` |
| `ExpectGlobalIntAtLeast` | `ExecuteAndExpectIntAtLeast` |
| `ExpectGlobalInts` | `ExecuteBatchAndExpectInt` |
| `ExpectGlobalReturnCustom<T>` | `ExecuteAndValidate<T>(..., Validator)` |
| `ExecuteFunctionExpectingScriptException` / scattered `ExecuteFunctionExpectingException` | `ExecuteAndExpectException` |
| `ExpectBindingCompileFailure` | `CompileAndExpectFailure` (separate `Compile*` family) |

Design principles:

1. Bare `Execute` means execute only, with no return extraction, exactly matching the underlying AS `asIScriptContext::Execute()`.
2. `AndGet` extracts a return without asserting; `AndExpect` extracts and asserts equality; `AndValidate` extracts and uses a custom validator.
3. Modifier placement: `Near` / `AtLeast` sits next to `Expect` because it modifies assertion semantics; `Batch` sits next to `Execute` because it modifies execution behavior.
4. Type suffixes come last (`Int` / `Bool` / `Float` / `Double` / `<T>`), and are omitted when unambiguous (member `ExecuteAndGet<T>`).
5. Do not introduce parallel `Expect*` / `Invoke*` / `Call*` families. Old names exist only as inline aliases for compatibility, and the spec forbids new code from using them.
6. Compile-side helpers are a separate `Compile*` family, currently only `CompileAndExpectFailure`.
7. `ExecuteAndValidate<T>` is deliberately separate from `ExecuteAndExpect<T>` to avoid lambda overload ambiguity.

### Compatibility strategy (core pivot from the original proposal)

- The original proposal promised "zero public symbol renames." This change replaces that with: **add the canonical `Execute*` family while keeping all old symbols permanently compatible through inline aliases and forwarding headers**.
- Any old call site inside `AngelscriptTest` or external plugins such as `AngelscriptGAS` continues compiling after this change with no source edits.
- The only call-site rename performed in this change is `AngelscriptBindingsExampleSection.h` (~80 lines), which becomes the official example for the new naming.
- The 71 `Bindings/*.cpp` files, ~200+ call sites, AS script-string namespace rewrite, final compatibility-layer deletion, and scattered helper consolidation are all deferred to follow-up changes and recorded in `followups.md`.

### Delete `FBindingsCoverageProfile` (redesigned Phase 5)

- Phase 5 no longer extends `FBindingsCoverageProfile`. Direct inspection showed that this struct does not contain business abbreviation fields such as `BodyInst` / `MsgDlg`; it is only a five-slot naming context introduced by the Bindings Coverage pattern (`Theme` / `Variant` / `ModulePrefix` / `CasePrefix` / `LogCategory`).
- That context is not suitable as a dependency of a module-wide test API. Generic `AngelscriptTest::Execute*` only needs `Test` / `Engine` / `Module` / `FunctionDecl` / `CaseLabel`, and should not know about Bindings module prefixes, case prefixes, or log categories.
- Phase 5 deletes `FBindingsCoverageProfile` and `AngelscriptBindingsCoverage.h`, and changes the generic `Execute*` layer to accept normal case labels. Bindings-specific code that needs module naming uses local full-word helpers or explicit module names.
- `FCoverageModuleScope` is reduced to "AS module lifetime RAII": it receives explicit `ModuleName` + `Source`, no longer a Profile. CQTest already provides test identity (Automation path + `TEST_METHOD` name), so Profile no longer repeats that identity.

### Out of scope for this change

- **AS script-side namespace rewrite** (`SetIter_SumElements` → `SetIter::SumElements`, 1500+ string literals): AS does not allow the same function name to exist both inside and outside a namespace, so no compatibility period is possible. This is entirely deferred to an independent follow-up change.
- **Bindings/*.cpp call-site bulk replacement**, **compatibility layer deletion** (old symbols / forwarding headers / inline aliases), and **scattered helper consolidation**: recorded in `followups.md` and handled gradually by follow-up changes.
- **Shared/ subdirectories**: not done; the user explicitly requested keeping the directory flat.
- Do **not** enter `MockDebugServer`, `TestEnginePool`, `TestLegacyHelpers`, `Debugger*` suites, or `TestEngineHelper`. Its `ExecuteIntFunction(Engine*, ModuleName, ...)` overload has a different signature and abstraction layer from the TestUtilities function and is not a duplicate.
- Do **not** migrate `AngelscriptTestLegacyHelpers.h` (11 old `IMPLEMENT_SIMPLE_AUTOMATION_TEST` users). Track this as a separate legacy OpenSpec item.
- Do **not** touch `AngelscriptTestMacros.h`, `AngelscriptTestEngine.h/.cpp`, or `AngelscriptReflectiveAccess.h`; they are unrelated to this goal.
- Do **not** change the external consumption contract already defined by `refactor-angelscript-test-helper-api` (`angelscript-test-helper-api` capability). This change is an **internal** test-module structure reorganization plus a new naming-family contract. The umbrella header path `Shared/AngelscriptTestUtilities.h` remains externally visible with unchanged meaning, and the old `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` paths continue to work through forwarding headers.
- **Documentation sync** (`.agents/skills/_angelscript-test-guide/SKILL.md` and `Documents/Guides/TestConventions.md`) is deferred to a follow-up change.

## Capabilities

### New Capabilities

- `as-test-utilities-header-layout`: defines the "umbrella header + themed small headers" contract under `AngelscriptTest/Shared/`. It covers `AngelscriptTestUtilities.h` compatibility as the aggregate entry, six themed header responsibility boundaries (including `AngelscriptTestExecute.h` as the main AS function-call entry), retired-symbol inventory, `Shared/README.md` navigation-index requirements, editor-header dependency convergence into Cleanup, and permanent forwarding of old `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` during this change (actual deletion deferred to follow-up).
- `as-bindings-test-execute-and-naming`: defines the `Execute*` naming-family contract, including `FAngelscriptTestExecutor` as the only low-level executor class, token-order rules for `Execute*` free functions, the separate `Compile*` family, removal of Bindings Profile coupling, mandatory use of the new naming family in new code, and old symbols as inline-alias compatibility only.

### Modified Capabilities

- None. This change does not modify the external consumption contract of the existing `angelscript-test-helper-api` capability; old header paths are permanently retained through forwarding headers.

## Impact

- **Code (split)**: `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestUtilities.h` is the main split target (1093 lines → ~40 lines); add `AngelscriptTestEngineAcquisition.h/.cpp`, `AngelscriptTestEngineCleanup.h`, `AngelscriptTestMemoryProbe.h`, `AngelscriptTestModuleBuilder.h`, `AngelscriptTestExecute.h`, `AngelscriptTestFixture.h`, and `Shared/README.md`.
- **Code (naming family)**: `Shared/AngelscriptTestExecute.h` contains `FAngelscriptTestExecutor`, the `Execute*` free-function family, and all old-symbol inline aliases (~1100 lines); `Shared/AngelscriptGlobalFunctionInvoker.h` shrinks from 408 lines to a ~3-line forwarder; `Shared/AngelscriptBindingsAssertions.h` shrinks from 378 lines to a ~3-line forwarder; `Shared/AngelscriptBindingsCoverage.h` is deleted and Profile coupling is removed from the generic Execute layer.
- **Code (markers)**: add `// TODO(refactor-as-test-shared-layout-and-naming)` markers to the 4-5 `Bindings/*.cpp` files that contain private `Execute*Function*` helpers (Math / Orientation / Curve / WorldFunc, etc.).
- **Code (call-site rename)**: only the example in `AngelscriptBindingsExampleSection.h` (~80 lines) is converted to the new naming as the official example.
- **API (compatibility)**: all old symbols (`FASGlobalFunctionInvoker` / `.Call` / `.CallAndReturn` / `ExpectGlobal*` / `ExecuteIntFunction*` / `ExpectBindingCompileFailure`) remain available through inline aliases / forwarding headers. The new `Execute*` family + `FAngelscriptTestExecutor` are the required entry for new code.
- **API (breaking)**: only four `AngelscriptTestSupport::` alias functions are removed (`GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`), and their ~46 call sites are replaced inside this change.
- **Dependency graph**: test-module TUs no longer receive `BlueprintActionDatabase.h` / `K2Node_GetSubsystem.h` transitively unless they explicitly include `AngelscriptTestEngineCleanup.h`.
- **Documentation**: `Documents/Guides/TestConventions.md` and `.agents/skills/_angelscript-test-guide/SKILL.md` sync is deferred to follow-up; this change only adds `Shared/README.md`.
- **Build system**: no `Build.cs` changes; `AngelscriptTest.Build.cs` remains as-is.
- **Tests**: no Automation prefixes are affected; no test case is added, removed, or disabled; the `275/275` C++ baseline and `301/301` ASSDK subset do not regress. Phase 5 verification: Bindings **260/260**, Fast suite manual aggregation **1834/1834** (2026-05-24).
- **OpenSpec**: add `as-test-utilities-header-layout` and `as-bindings-test-execute-and-naming`; add `followups.md` for progressive cleanup. Phases 1-5 landed on 2026-05-24; `design.md` §Implementation Record contains phase commits and migration notes.
