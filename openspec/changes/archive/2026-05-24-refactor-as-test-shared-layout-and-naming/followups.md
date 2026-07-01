# Follow-up Cleanup Checklist

This change (`refactor-as-test-shared-layout-and-naming`) completed the header split, new naming family, C++ aliasable compatibility layer, scattered-helper TODO markers, and Phase 5 deletion of `FBindingsCoverageProfile`. The repository is now in a stable intermediate state where the old and new APIs coexist.

The following items were intentionally deferred from this change and should be handled by independent user-driven follow-up changes. Each item includes its trigger condition, impact area, recommended cadence, and final goal.

## 1. Gradual Bindings/*.cpp call-site migration

**Trigger**: this change has landed; the canonical `Execute*` family + `FAngelscriptTestExecutor` are available; old `ExpectGlobal*` / `FASGlobalFunctionInvoker` / old `Execute*Function*` entries remain permanently compatible through inline aliases.

**Cleanup target**: 71 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/*.cpp` files and ~200+ call sites.

**Recommended cadence**: process 1-3 files per follow-up change, grouped by theme (for example, Math first, then Iterator). At the end of each commit, run `RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.<Theme>."`.

**Final goal**: all call sites use the new names. This gates #4 (compatibility-layer deletion); **all** call sites must be migrated before #4 can proceed.

## 2. Consolidate file-private `Execute*Function*` helpers in Bindings/*.cpp

**Trigger**: Phase 1.9 of this change added `// TODO(refactor-as-test-shared-layout-and-naming)` markers to every file containing private helpers.

**Cleanup target**:

- `AngelscriptMathBindingsTests.cpp` / `AngelscriptMathOrientationBindingsTests.cpp` / `AngelscriptScriptFunctionLibraryTests.cpp`: private `ExecuteValueFunction<T>` helpers (one similar helper per file).
- `AngelscriptCurveFloatBindingsTests.cpp` or similar files: private `ExecuteIntFunctionWithAddressArg`.
- `AngelscriptWorldFunctionBindingsTests.cpp` or similar files: private `ExecuteIntFunction` / `ExecuteFunctionExpectingException`.
- Any other scattered helpers found by `rg "static (bool|template) .*Execute\w+Function" Plugins\Angelscript\Source\AngelscriptTest\Bindings`.

**Recommended cadence**: combine this with #1 call-site migration. When processing one file, either move its private helper into `AngelscriptTestExecute.h` or delete it if the canonical family already covers that signature.

**Final goal**: no `static` or anonymous-namespace `Execute*Function*` helper remains under `Bindings/*.cpp`; every helper is either consolidated into the canonical `AngelscriptTestExecute.h` family or replaced by a new `Execute*` name.

## 3. AS script namespace rewrite (`SetIter_SumElements` → `SetIter::SumElements`)

**Trigger**: this change has landed and the C++ naming family is stable.

**Risk**: AS does not allow the same function name to exist both inside and outside a namespace, so **there is no compatibility period**. Mistakes in 1500+ string literals are not caught by C++ compilation and require test execution to detect.

**Cleanup target**:

- `FunctionDecl` string literals in 71 `Bindings/*.cpp` files.
- Function definitions and calls inside AS source multi-line strings (`R"AS(...)AS"`).
- `AddExpectedError` strings containing AS module/function names.

**Recommended cadence**:

1. First follow-up: complete a pilot on 1-2 simple files such as Iterator, record failure modes (typos, namespace nesting limits, forward declaration issues), and produce an "AS namespace rewrite SOP."
2. Later follow-ups: process one theme at a time (about 3-5 files), and run all tests for that theme at the end of each commit.
3. Final follow-up: run `rg -n "[A-Z]\w+_\w+\(" Plugins\Angelscript\Source\AngelscriptTest\Bindings` to confirm no underscore-grouped AS functions remain.

**Final goal**: all AS script functions use namespace grouping; underscore grouping is gone.

## 4. Delete the compatibility layer (old-symbol inline aliases / forwarding headers)

**Trigger**: #1 / #2 / #3 are complete, and `rg -n "ExpectGlobal|FASGlobalFunctionInvoker|ExecuteIntFunction|\.Call\(\)|\.CallAndReturn|\.ReadReturnStruct" Plugins\Angelscript\Source\AngelscriptTest` only hits inline alias implementations in `Shared/AngelscriptTestExecute.h`. `FBindingsCoverageProfile` was already deleted in Phase 5 of this change and is not a prerequisite anymore.

**Cleanup target**:

- `using FASGlobalFunctionInvoker = ...` alias block in `Shared/AngelscriptTestExecute.h`.
- Inline compatibility wrappers for `ExpectGlobal*` / `ExecuteIntFunction*` / `ExpectBindingCompileFailure` in `Shared/AngelscriptTestExecute.h`.
- `.Call` / `.CallAndReturn<T>` / `.ReadReturnStruct<T>` forwarding members in `Shared/AngelscriptTestExecute.h`.
- Delete `Shared/AngelscriptGlobalFunctionInvoker.h`.
- Delete `Shared/AngelscriptBindingsAssertions.h`.
- Also inspect the `refactor-angelscript-test-helper-api` capability for scenarios that still reference old header paths. If that capability still lists `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` as public helper entries, first open a modified-capability change to make `AngelscriptTestExecute.h` the recommended entry, then delete the old headers.

**Recommended cadence**: one small follow-up change. Run `RunBuild.ps1` and the full `RunTestSuite.ps1` before and after the commit.

**Final goal**: `AngelscriptTestExecute.h` is the only execution entry point; no alias or forwarding header remains.

## 5. Documentation sync

**Trigger**: can be done at any time after this change lands; it does not strongly depend on #1-#4.

**Cleanup target**:

- `.agents/skills/_angelscript-test-guide/SKILL.md`: update the helper recommendation table, replacing `FASGlobalFunctionInvoker` / `ExpectGlobal*` with `FAngelscriptTestExecutor` / `ExecuteAndExpect*`; add `Execute*` / `Compile*` naming-family notes.
- `Documents/Guides/TestConventions.md`: update the recommended entry point; state that new code must use the canonical `Execute*` family and old names are only inline-alias compatibility; point to `Shared/README.md` and this `followups.md` for progressive cleanup.
- `Documents/Guides/TestCatalog.md`: check whether baseline numbering needs an update. It should not, because this change does not add or remove tests.

**Recommended cadence**: one lightweight follow-up change.

## 6. Evaluate further umbrella-header slimming

**Trigger**: can be evaluated independently at any time after this change lands.

**Evaluation points**:

- The current umbrella `AngelscriptTestUtilities.h` is now a ~40-line include aggregate, but it still forwards `Shared/AngelscriptTestEngineCleanup.h` (with its `WITH_EDITOR` block). Any TU including `Shared/AngelscriptTestUtilities.h` still gets editor-header dependencies transitively.
- Evaluate whether it is worth splitting the umbrella into light / full layers, such as keeping Cleanup out of `AngelscriptTestUtilities.h` and adding `AngelscriptTestUtilitiesFull.h` for consumers that need cleanup.

**Cleanup target if approved**:

- Split the umbrella into light / full layers.
- Audit each test TU to determine whether it actually needs Cleanup; switch consumers that do not need it to the light umbrella.

**Recommended cadence**: separate OpenSpec change, based on whether compile-time benefit justifies the split.

**Final goal**: minimize transitive editor-header dependencies for test TUs.

---

## Recommended follow-up slicing order

```text
follow-up A: #5 documentation sync (lightweight, can happen immediately)
follow-up B: #1 + #2 (call-site migration + scattered helper consolidation, sliced by theme over multiple follow-ups)
follow-up C: #3 AS namespace rewrite (pilot first, then theme slices over multiple follow-ups)
follow-up D: #4 compatibility-layer deletion (single change, depends on A-C)
follow-up E: #6 umbrella-slimming evaluation (independent change)
```
