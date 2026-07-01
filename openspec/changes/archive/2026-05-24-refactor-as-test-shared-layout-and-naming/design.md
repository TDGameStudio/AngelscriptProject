## Context

`Plugins/Angelscript/Source/AngelscriptTest/Shared/` had 47 files with nine responsibility clusters mixed together. `AngelscriptTestUtilities.h` was a 1093-line "god header" that inlined seven responsibility areas in one file: engine acquisition, Cleanup, memory probes, shared reset, module compilation, AS execution, and fixtures. It also leaked `BlueprintActionDatabase.h`, `K2Node_GetSubsystem.h`, and the three AS SDK headers through the umbrella include into 400+ test TUs.

At the same time, "call an AS function" was spread across `Shared/AngelscriptBindingsAssertions.h` (378 lines, nine `Expect*` helpers), `Shared/AngelscriptGlobalFunctionInvoker.h` (408 lines, fluent `FASGlobalFunctionInvoker`), `AngelscriptTestUtilities.h` lines 873-1015 (`ExecuteIntFunction*` / `ExecuteInt64Function`), and 4-5 file-private helpers in `Bindings/*.cpp` such as Math / Orientation / Curve / WorldFunc `ExecuteValueFunction` / `ExecuteIntFunctionWithAddressArg` / `ExecuteFunctionExpectingException`. That left **at least seven parallel entry points**. Their naming families (`Expect*` / `Execute*Function*` / `.Call()` / `.CallAndReturn`) did not align with each other, UE style, or the underlying AS `asIScriptContext::Execute()` API.

This change is the expanded and renamed form of the original `refactor-as-test-utilities-header-split`. The original proposal promised "zero public symbol renames", but doing rename + header split + naming normalization + scattered-helper consolidation in one step would have required renaming ~200+ call sites across 71 `Bindings/*.cpp` files, which was too risky. The AS namespace rewrite also has no compatibility path because AS does not allow the same function name to exist both inside and outside a namespace. The core pivot was: **maximize C++ aliasable compatibility and defer every non-aliasable breaking step to follow-up changes**.

## Goals / Non-Goals

**Goals:**

1. Split the 1093-line `AngelscriptTestUtilities.h` into six themed headers + one `.cpp`, shrinking the umbrella to a ~40-line pure include aggregate.
2. Consolidate every "AS function execution" entry into one file, `Shared/AngelscriptTestExecute.h`, containing the low-level `FAngelscriptTestExecutor`, the `Execute*` free-function family, a separate `Compile*` family, and all old-symbol inline aliases / old-header forwarders.
3. Establish the `Execute`-rooted naming-family contract with token order `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect|(empty)][Near|AtLeast|(empty)][<Type>|<T>]` (enforced by spec).
4. Delete `FBindingsCoverageProfile` and `AngelscriptBindingsCoverage.h`, so the Bindings Coverage naming context no longer pollutes the generic `Execute*` API. `Execute*` receives only a normal case label, and module scope receives an explicit module name.
5. Constrain editor-header dependencies (`BlueprintActionDatabase` / `K2Node_*`) to `AngelscriptTestEngineCleanup.h`.
6. Retire four pure forwarding aliases (`GetSharedTestEngine` / `GetResetSharedTestEngine` / `AcquireFreshSharedCloneEngine` / `ResetSharedInitializedTestEngine`) and replace about ~46 call sites.
7. Ensure every old call site, including external plugin call sites such as `AngelscriptGAS`, continues compiling after this change with zero source modifications.

**Non-Goals:**

- Do not bulk-rename the 71 `Bindings/*.cpp` files and ~200+ call sites. Only the example `AngelscriptBindingsExampleSection.h` is updated as the official new-name demonstration.
- Do not delete old symbols / old headers / inline aliases / forwarding headers; deletion is deferred to follow-up.
- Do not introduce a new Profile / NamingContext abstraction to replace `FBindingsCoverageProfile`; CQTest already provides identity through Automation path + `TEST_METHOD` name.
- Do not rewrite AS script string-literal namespaces (`SetIter_SumElements` → `SetIter::SumElements`, 1500+ sites). AS does not support same-name functions inside and outside a namespace, so there is no compatibility window.
- Do not consolidate file-private `Execute*Function*` helpers in `Bindings/*.cpp`; only add `// TODO` markers and migrate them gradually in follow-up work.
- Do not touch `MockDebugServer`, `TestEnginePool`, `Debugger*` suites, `TestEngineHelper`, `TestLegacyHelpers.h`, `TestMacros.h`, `TestEngine.h/.cpp`, or `ReflectiveAccess.h`; they are unrelated to this target.
- Do not sync `Documents/Guides/TestConventions.md` and `.agents/skills/_angelscript-test-guide/SKILL.md`; open a follow-up for that.
- Do not modify the external consumption contract of the existing `angelscript-test-helper-api` capability.

## Decisions

### D1: Merge header split + naming normalization into one change, replacing "zero renames" with "permanent alias compatibility"

The original proposal's "zero public symbol renames" rule existed to keep 400+ test TUs unchanged. But the repository also had at least seven parallel AS-execution entry points across 71 `Bindings/*.cpp` files. Splitting the work would have meant first landing the header split, then later renaming one of the freshly-created six headers (`AngelscriptTestExecution.h`) to `AngelscriptTestExecute.h` and merging the scattered entry points. That extra round trip had no value.

This change combines the work while maximizing compatibility:

- The sixth themed header lands directly as `AngelscriptTestExecute.h`, aligned with the final naming family.
- The canonical `Execute*` family is added and required for new code by spec.
- Every old symbol and old header remains as an inline alias / forwarding header until follow-up cleanup.

Alternatives:

- Keep the zero-rename rule and avoid a new naming family: rejected, because it wastes the `FASGlobalFunctionInvoker` renaming opportunity and leaves the naming mess in place.
- Rename everything and update ~200+ call sites across 71 `Bindings/*.cpp` files immediately: rejected as too risky and contrary to OpenSpec incremental-change discipline.
- Only split headers without introducing the naming family: rejected, because it misses the chance to land the sixth themed header under its final name.

### D2: Naming-family root verb = `Execute`

Candidate roots were `Execute`, `Invoke`, `Run`, and `Call`. `Execute` was chosen because:

1. The AS low-level API is `asIScriptContext::Execute()`, so the family matches the mechanism.
2. The repository already had an `Execute*Function*` convention (`Utilities.h` lines 873-1015 plus 4-5 scattered helpers in `Bindings/*.cpp`), and this change promotes that convention into a standard.
3. `Invoke` / `Call` are too generic for "function call" and do not bind the name to AS execution semantics.
4. `Run` implies a longer-lived operation such as `RunSession`, which does not fit a single function call.

Alternatives:

- Use `Invoke` as root: initially preferred by the user, then rejected in favor of `Execute` because it matches the low-level API and repository convention.
- Keep both `Expect*` and `Execute*` roots: rejected because it preserves the naming split.

### D3: Token order `Execute[AndGet|AndExpect|AndValidate|BatchAndExpect][Near|AtLeast][<Type>]`

Token semantics are strictly separated:

- Bare `Execute`: execute only, no return extraction.
- `AndGet`: extract return value without assertion.
- `AndExpect`: extract return value and assert equality.
- `AndValidate`: extract return value and validate with custom logic.
- `BatchAndExpect`: execute the same function N times.

Modifier placement:

- `Near` / `AtLeast` sits next to `Expect` because it modifies assertion semantics: `ExecuteAndExpectNearFloat` / `ExecuteAndExpectIntAtLeast`.
- `Batch` sits next to `Execute` because it modifies execution behavior: `ExecuteBatchAndExpectInt`.

Type suffixes come last: `Int` / `Bool` / `Float` / `Double` / `<T>`. They are omitted when unambiguous, such as member `ExecuteAndGet<T>`.

Alternatives:

- `AndGet` vs `AndExtract`, `AndAssert` vs `AndExpect`, `Near` vs `Approx`, `Batch` vs `Many`, `AtLeast` vs `GreaterOrEqual`: adopted the shorter terms that fit common UE usage.
- Plural suffix `ExpectInts` for batch execution: rejected because plural suffixes are harder to scan and inconsistent with the singular form; use `ExecuteBatchAndExpectInt`.
- Overload `ExecuteAndExpect<T>` for validator lambdas: rejected because lambda overload resolution is ambiguous and IDE hints become noisy; split it into `ExecuteAndValidate<T>`.

### D4: executor class name = `FAngelscriptTestExecutor`

Options:

- `FAngelscriptExecutor`: shortest and pairs naturally with `FAngelscriptEngine`, but lacks the `Test` qualifier.
- **`FAngelscriptTestExecutor`**: adopted because it clearly marks the type as test-only.
- `FAngelscriptGlobalFunctionExecutor`: preserves the original `FASGlobalFunctionInvoker` "GlobalFunction" meaning but is too long.

Reasons for `FAngelscriptTestExecutor`:

1. It pairs naturally with `AngelscriptTestExecute.h`.
2. It includes the `Test` qualifier, avoiding collision with any future runtime `FAngelscriptExecutor`.
3. Its length is acceptable, comparable to `FAngelscriptTestEngine`.

### D5: Compile-side helpers become a separate `Compile*` family

`ExpectBindingCompileFailure` fails during AS compilation and never reaches the Execute step. Calling it `ExecuteAndExpectCompileFailure` would be semantically wrong. A separate `Compile*` family, currently only `CompileAndExpectFailure`, keeps the meaning clear.

Alternatives:

- Fold it into the `Execute*` family: rejected as inaccurate.
- Use a `Validate*` / `Verify*` family: rejected as unrelated to the `Execute*` / `Compile*` split.

### D6: Compatibility covers only C++-aliasable dimensions; everything else is follow-up

C++-aliasable dimensions:

| Dimension | Compatibility Mechanism | Implemented Here |
|------|---------|----------------|
| `ExpectGlobalInt` and similar free functions | `inline` forwarding functions | ✓ |
| `FASGlobalFunctionInvoker` class name | `using FASGlobalFunctionInvoker = FAngelscriptTestExecutor;` | ✓ |
| `.Call` / `.CallAndReturn<T>` / `.ReadReturnStruct<T>` member methods | inline forwarding methods | ✓ |
| Old `AngelscriptGlobalFunctionInvoker.h` / `AngelscriptBindingsAssertions.h` headers | forwarding `#include` | ✓ |

Non-aliasable C++ / AS dimensions, deferred to follow-up:

| Dimension | Why It Cannot Be Aliased | Deferred To |
|------|------------------|----------|
| AS script namespace rewrite | AS does not allow same-name functions both inside and outside a namespace | `followups.md` |
| ~200+ call-site renames in 71 `Bindings/*.cpp` files | Risk isolation only | `followups.md` |
| File-private `Execute*Function*` helper consolidation in `Bindings/*.cpp` | File-private helpers can be handled independently | `followups.md` (this change only adds `// TODO` markers) |

### D7: Delete `FBindingsCoverageProfile` and keep Bindings naming context out of the generic execution layer

Direct inspection showed that the original Phase 5 plan was based on a false premise: `FBindingsCoverageProfile` did not contain business abbreviation fields such as `BodyInst` / `MsgDlg` / `MathOrient`. It only had five abstract slots:

```cpp
struct FBindingsCoverageProfile
{
    const TCHAR* Theme;
    const TCHAR* Variant;
    const TCHAR* ModulePrefix;
    const TCHAR* CasePrefix;
    const TCHAR* LogCategory;
};
```

Those slots existed to build module names and log labels for the Bindings Coverage Section pattern. They are not generic information needed to execute an AS function. Passing the profile into `AngelscriptTest::ExecuteAndExpectInt` and similar functions makes the generic execution layer depend on Bindings-specific concepts.

Phase 5 uses deletion:

- `AngelscriptTest::Execute*` / `Compile*` receives normal `CaseLabel` only, no longer `FBindingsCoverageProfile`, and does not call `FormatCaseLabel(Profile, ...)`.
- `FCoverageModuleScope` receives explicit `ModuleName` + `Source` and only owns AS module lifetime RAII.
- Delete `AngelscriptBindingsCoverage.h` and `FBindingsCoverageProfile`. Bindings tests that need module names use explicit full-word module names such as `ASBodyInstance_Latent` or file-private full-word helpers, not a shared non-generic Profile abstraction.
- CQTest already provides test identity through `TEST_CLASS_WITH_FLAGS(..., "Angelscript.TestModule.Bindings.BodyInstance", ...)` and `TEST_METHOD(...)`; Profile no longer repeats it.

Alternatives:

- Keep Profile and change it to a `ForSubject()` factory: more cohesive than the original, but still forces test authors to learn a Bindings-specific context; the user explicitly judged that abstraction non-generic. Rejected.
- Create a module-wide `FAngelscriptTestNamingContext`: rejected because it would recouple CQTest identity, module lifecycle, and assertion labels into a new large context.
- Keep writing five-field Profile instances in every test file: rejected as repetitive, abbreviation-prone, and synchronization-prone.

### D8: Keep scattered helpers in place and add `// TODO` markers

File-private helpers in `Bindings/*.cpp`, such as `ExecuteValueFunction` / `ExecuteIntFunctionWithAddressArg`, are `static` or anonymous-namespace helpers with no external dependencies. This change does not consolidate them because:

- Moving them into `Execute.h` would create many same-name conflicts; each file's `ExecuteValueFunction<T>` template specialization, default arguments, and Profile references differ.
- Consolidation would require deleting the original helper and immediately fixing the call sites affected by signature changes, violating the compatibility promise to avoid call-site churn.
- A `// TODO(refactor-as-test-shared-layout-and-naming): migrate <helper-list> to Shared/AngelscriptTestExecute.h` marker gives follow-up work a concrete migration list.

### D9: Do not bulk-replace call sites or delete the compatibility layer in this change

Replacing ~200+ call sites across 71 `Bindings/*.cpp` files, then deleting aliases and forwarding headers, is high-volume work. It is better to let the user drive it gradually:

- The user can rename one file at a time (Math / Orientation / Iterator / ...), validating build + tests each time.
- After this change, the repository is in a stable intermediate state: old and new APIs coexist, all old call sites compile, and new code must use `Execute*`.
- Once all call sites are migrated in follow-up changes, the final follow-up can delete the compatibility layer.

### D10: Do not rewrite AS script namespaces in this change

AS does not allow same-name functions to coexist inside and outside a namespace, so there is no compatibility window. Rewriting 1500+ string literals is also risky because typo failures are hard to spot and C++ compilation cannot validate AS strings. The entire phase is deferred to an independent follow-up change with its own risk assessment and pilot cadence.

## Risks / Trade-offs

- **[`FAngelscriptTestExecutor` member ambiguity with old `FASGlobalFunctionInvoker`]** → Mitigation: old member methods are inline forwarders, and new members are not overloaded against old names; `Execute` ≠ `Call`, `ExecuteAndGet` ≠ `CallAndReturn`, and `ExecuteAndExtractStruct` ≠ `ReadReturnStruct`.
- **[New code accidentally depends on forwarding headers]** → Mitigation: the spec scenario forbids new code from including old forwarding headers; `Shared/README.md` marks both forwarding headers as legacy; follow-up work owns their deletion schedule.
- **[Scattered helpers look too similar to the canonical `Execute*` family]** → Mitigation: scattered helpers remain `static` and file-scoped, IDE navigation points to the local helper, file-top `// TODO` markers direct readers to the canonical `Execute.h` family, and the spec forbids new parallel `Expect*` / `Invoke*` / `Call*` families.
- **[More repeated module-name strings after Profile deletion]** → Mitigation: keep only necessary module-name strings, write them as full words, and allow file-private `Make<Subject>ModuleName(SectionName)` helpers in multi-section files without adding that helper to the shared API.
- **[External plugins such as GAS depend on the four retired aliases]** → Mitigation: the original proposal audited those four aliases as `AngelscriptTest`-module-only; this change follows that audit and runs a Phase 1 `rg` cross-check for external dependencies.

## Migration Plan

Lock the work into five sequential phases:

1. **Phase 1**: split six themed headers (including the sixth header directly named `AngelscriptTestExecute.h` and containing only Utilities.h lines 873-1015), retire four aliases, converge Cleanup dependencies, add `Shared/README.md`, and add scattered-helper TODO markers.
2. **Phase 2**: merge `AngelscriptGlobalFunctionInvoker.h` + `AngelscriptBindingsAssertions.h` into `AngelscriptTestExecute.h`; convert the old two headers into forwarders; do not touch call sites.
3. **Phase 3**: add the new `Execute*` naming family and old-symbol inline aliases to `AngelscriptTestExecute.h`; rename the executor class to `FAngelscriptTestExecutor`.
4. **Phase 4**: migrate the `AngelscriptBindingsExampleSection.h` example to new names (the only call-site rename in this change); create `followups.md` for deferred cleanup.
5. **Phase 5**: delete `FBindingsCoverageProfile` and decouple the generic `Execute*` API from Bindings module naming.

Verification at the end of each phase:

- Full `Tools\RunBuild.ps1` build passes.
- Full `Tools\RunTestSuite.ps1` automation suite does not regress (`275/275` C++ + `301/301` ASSDK + existing Bindings suite).
- After Phase 2 / 3, `rg` confirms old headers are only forwarding usages.

### Rollback

Each phase can be rolled back independently with a single git commit revert. Before follow-up changes start, the whole change leaves the repository in a stable old+new coexistence state.

## Open Questions

- **OQ1**: Should `FCoverageModuleScope` section strings align with `TEST_METHOD` names, or should a macro such as `ASTEST_BINDINGS_SECTION(Profile, Source)` build them automatically?
  This is not tightly coupled to the naming family and can be discussed independently. Current preference: keep the current behavior and avoid a macro to reduce learning cost. If future section strings and method names drift enough to hurt diagnostics, open a follow-up macro design.

## Shared/ Directory Three-State Comparison

### A. Current State (before this change, 47 files)

| Cluster | Key Files | Lines | Touched by This Change |
|----|---------|------|------------------|
| God header | `AngelscriptTestUtilities.h` | 1093 | **Split** |
| Bindings tools | `AngelscriptBindingsAssertions.h` / `BindingsCoverage.h` / `BindingsModuleBuilder.h` / `BindingsExampleSection.h` / `GlobalFunctionInvoker.h` | 1058 | **Partially merged** |
| Reflective access | `AngelscriptReflectiveAccess.h` | 979 | No |
| Debugger suite | 10 `Debugger*` / `MockDebugServer*` files | ~3088 | No |
| Test engine core | `TestEngine.{h,cpp}` / `TestEngineHelper.{h,cpp}` / `TestEnginePool.h` | 1208 | No |
| Macros / fixtures / world | `TestMacros.h` / `TestWorld.h` / `FunctionalTestUtils.h` / `TestLegacyHelpers.h` | 380 | No |
| Native interfaces | 5 `Native*` files | 477 | No |
| Learning / probes / collision / performance | `LearningTrace.*` / `ConstructionContextProbe.*` / `CollisionTestHelpers.h` / `PerformanceTestUtils.h` | ~655 | No |
| Infra self-tests | 7 `*Tests.cpp` files | ~1683 | Follow renames |

There are also 4-5 file-private `Execute*Function*` helpers scattered through `Bindings/*.cpp` (Math / Orientation / Curve / WorldFunc).

### B. Internal Cut Lines in `AngelscriptTestUtilities.h` (1093 actual lines)

| Segment | Lines | Main Symbols | Phase 1 Destination |
|----|------|---------|--------------|
| 1 | 32-247 | `CreateBareScriptEngine` / `CreateIsolated*` / `GetOrCreateSharedCloneEngine` | `AngelscriptTestEngineAcquisition.h/.cpp` |
| 2 | 250-407 | `CleanupDetachedASTypesForGarbageCollection` + `WITH_EDITOR` block | `AngelscriptTestEngineCleanup.h` |
| 3 | 409-466 | `SampleBindFreeMem` / `AcquireTransientFullTestEngineWithProbe` | `AngelscriptTestMemoryProbe.h` |
| 4 | 468-689 | `ResetSharedCloneEngine` / `LogSharedEngineDebugState` | Merged into Acquisition because it shares the same shared-engine semantics |
| 5 | 693-870 | `BuildModule` / `GetFunctionByDecl` / `FScopedAutomaticImportsOverride` | `AngelscriptTestModuleBuilder.h` |
| 6 | 873-1015 | `ExecuteIntFunction` / `ExecuteIntFunctionExpectingScriptException` / `ExecuteInt64Function` | **Directly into `AngelscriptTestExecute.h`** |
| 7 | 1016+ | `FAngelscriptTestFixture` | `AngelscriptTestFixture.h` |

### C. After Phase 1

```text
Shared/
  AngelscriptTestUtilities.h                   ~40   (umbrella)
  AngelscriptTestEngineAcquisition.h/.cpp     ~430   NEW (includes old Utilities.h segments 1+4)
  AngelscriptTestEngineCleanup.h              ~170   NEW (BP DB dependency converges here)
  AngelscriptTestMemoryProbe.h                 ~60   NEW
  AngelscriptTestModuleBuilder.h              ~180   NEW
  AngelscriptTestFixture.h                     ~90   NEW
  AngelscriptTestExecute.h                    ~150   NEW (only segment 873-1015)
  README.md                                          NEW
  (Bindings cluster unchanged; the other 8 clusters unchanged)
```

At this point `AngelscriptTestExecute.h` contains only the content moved from Utilities.h lines 873-1015, and symbol names remain unchanged.

### D. Final State (this change complete, stable old+new coexistence)

```text
Shared/
  AngelscriptTestUtilities.h                   ~40   umbrella
  AngelscriptTestEngineAcquisition.h/.cpp     ~430
  AngelscriptTestEngineCleanup.h              ~170
  AngelscriptTestMemoryProbe.h                 ~60
  AngelscriptTestModuleBuilder.h              ~180
  AngelscriptTestFixture.h                     ~90
  AngelscriptTestExecute.h                   ~1100   <- new AS function execution entry (including permanent compatibility layer)
        New API (primary, mandatory for new code):
        - FAngelscriptTestExecutor class
        - ResolveFunctionByDecl / ResolveFunctionByName
        - .Execute() / .ExecuteAndGet<T>() / .ExecuteAndExtractStruct<T>()
        - ExecuteAndExpectInt / Bool / Double
        - ExecuteAndExpectNearFloat / NearDouble
        - ExecuteAndExpectIntAtLeast
        - ExecuteBatchAndExpectInt
        - ExecuteAndValidate<T>
        - ExecuteAndExpectException
        - CompileAndExpectFailure (separate Compile* family)
        Compatibility aliases (permanently retained, forbidden for new code):
        - using FASGlobalFunctionInvoker = FAngelscriptTestExecutor
        - .Call → .Execute / .CallAndReturn<T> → .ExecuteAndGet<T> / .ReadReturnStruct<T> → .ExecuteAndExtractStruct<T>
        - inline ExpectGlobalInt/Bool/Double/IntAtLeast/Ints/ReturnBool/ReturnFloat/ReturnCustom<T>
        - inline ExpectBindingCompileFailure
        - inline ExecuteIntFunction / ExecuteIntFunctionExpectingScriptException / ExecuteInt64Function

  AngelscriptGlobalFunctionInvoker.h           ~3    <- permanent forward: #include "AngelscriptTestExecute.h"
  AngelscriptBindingsAssertions.h              ~3    <- permanent forward: #include "AngelscriptTestExecute.h"
  AngelscriptBindingsCoverage.h                      <- deleted (Profile abstraction no longer retained)
  AngelscriptBindingsModuleBuilder.h           88    (ModuleScope, unchanged)
  AngelscriptBindingsExampleSection.h          80    (Phase 4 uses new names as official example)
  (other 8 clusters unchanged)

Bindings/*.cpp (71 files, all unchanged):
  - old call sites (ExpectGlobalInt / FASGlobalFunctionInvoker / old Execute*Function*) continue compiling
  - private helpers (Math/Orientation and similar ExecuteValueFunction helpers) remain in place
  - file-top // TODO(refactor-as-test-shared-layout-and-naming) markers point to followups.md
```

**Phase 5 deleted `AngelscriptBindingsCoverage.h`** (`FBindingsCoverageProfile` and helpers). All other old symbols, old forwarding headers, and scattered helpers remain and are cleaned up gradually by follow-up changes.

## Implementation Record (Phases 1-5, completed May 2026)

| Phase | Submodule commit (Angelscript) | Parent gitlink | Verification |
|-------|-------------------------------|----------------|--------------|
| 1 | `621cb1b` split + `06702b1` alias retirement | `055e5fd`, `c91d516` | Fast suite 1834/1834 |
| 2 | `4f88c8d` merge Invoker + Assertions into Execute.h | `e1f6e8b` | Fast suite 1834/1834 |
| 3 | `2b0f7ee` `FAngelscriptTestExecutor` + `Execute*` family | `a32b229` | Fast suite 1834/1834 |
| 4 | `2357a29` example section migration | `da6d137` | Fast suite 1834/1834; SharedExample PASS |
| 5 | `8ca8191` delete Profile; 125 files migrated | *(parent commit)* | Build OK; Bindings 260/260; Fast suite 1834/1834 (manual shard agg.) |

**Phase 5 migration notes:**

- ~117 Bindings/Syntax/Compiler/Functional/Interface test files: removed `FBindingsCoverageProfile` parameter from `ExpectGlobal*` / `Execute*` call sites; `FCoverageModuleScope` now takes explicit full-word `ModuleName`.
- `AngelscriptGAS` test module (3 files): same Profile removal pattern.
- Post-migration fixes: `AddExpectedError` strings must match `FCoverageModuleScope` module names — corrected `ASAssetReg_` → `ASAssetRegistry_` (AssetRegistry) and `ASTemplateCQ_` → `ASTemplate_` (Template CQTest `NegativePath`).
- `TESTING_GUIDE.md` / `TESTING_GUIDE_ZH.md`: updated `FCoverageModuleScope` examples.
- Known infra: `RunTestSuiteFast.ps1` aggregator may throw `ConvertTo-AngelscriptWorkerPlanJson` after all shards pass; manual `[done]` line aggregation remains authoritative.

### E. File Count Ledger (final state)

| | Before | Final | Δ |
|--|------|------|---|
| `Shared/` total file count | 47 | 54 | **+7** |
| Main "AS function execution" entries | ≥7 | 1 (including 6 inline compatibility aliases) | **-6** |
| Compile-time call-site errors | 0 | **0** (compatibility layer covers old code) | 0 |

The value density of this change is: **Execute.h becomes the mandatory new-code entry**, while old entries are downgraded to compatibility aliases awaiting follow-up cleanup.

## Why AS namespace rewrite was deferred

AS syntax allows namespaces, such as `namespace SetIter { void SumElements() {} }`, but it **does not allow** coexistence with a global function `void SetIter_SumElements() {}`:

- If both exist, the AS compiler reports a name collision because namespace qualifiers do not participate in mangling.
- If only the namespace version remains, every call site, including C++ test string literals such as `"SetIter_SumElements"`, must change to `"SetIter::SumElements"`.
- String-literal rename mistakes are not caught by C++ compilation and require a 100% test run to detect.

Therefore the AS namespace rewrite has **no C++-style inline alias compatibility mechanism**. The 1500+ affected string literals are spread across:

- `FunctionDecl` strings in 71 `Bindings/*.cpp` files.
- Function definitions and calls inside AS source literals (`R"AS(...)AS"` multi-line strings).
- Error-message strings in `AddExpectedError`.

Doing this inside the current change would mean:

- ≥4500 string literal replacements, because each namespace switch affects definitions, calls, and error messages.
- One mistake causes a test regression that is hard to locate.
- A forced full-suite verification, preventing incremental shipping.

Benefits of deferring it to an independent follow-up:

- It gets a dedicated risk assessment and pilot cadence, starting with 1-2 files to confirm runtime behavior.
- It is decoupled from the C++ naming-family work in this change.
- If AS syntax boundaries appear during implementation, such as namespace nesting or forward declarations, the plan can adapt independently.
