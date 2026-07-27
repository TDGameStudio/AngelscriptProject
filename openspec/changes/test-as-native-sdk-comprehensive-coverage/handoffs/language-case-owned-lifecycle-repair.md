# Language case-owned raw SDK lifecycle repair

Date: 2026-07-27

## Scope

This coherent task 4.5 batch handles exactly the 43 `Language` files
classified as `ChangeRequiredClassOwnedMutableOrUnjustified` in
`handoffs/fixture-and-large-file-quality-review.csv`.

The batch is limited to lifecycle ownership:

- no responsibility or large-file split was performed, including the
  separately tracked large-file candidates;
- no product marker, case ID, generated AngelScript source, assertion
  predicate, or expected result was changed;
- no product code, catalog, task list, proposal, design, or specification was
  changed;
- no build or automation test was run.

All 43 files were pre-existing untracked work in the shared plugin worktree.
Edits were applied to the existing file contents without replacing files or
reverting concurrent work.

## Lifecycle repair

All class-owned `FNativeTestEngine` instances and their CQTest `BEFORE_ALL`,
`BEFORE_EACH`, and `AFTER_ALL` hooks were removed.

Every one of the 50 `TEST_METHOD` cases now owns its raw engine and installs a
multiline Destroy guard immediately after Create:

```cpp
AngelscriptNativeTestSupport::FNativeTestEngine Engine;
Engine.Create(*TestRunner);
ON_SCOPE_EXIT
{
	Engine.Destroy();
};
```

Files whose established fixture name was `NativeEngine` retain that local
name. The guard is declared before engine pointers, modules, contexts, script
objects, and other dependent resources, so reverse C++ destruction order
releases the dependencies before destroying the engine. Early returns are
covered.

Final lifecycle accounting:

- target files: 43;
- test methods: 50;
- case-owned engine declarations: 50;
- engine Create calls: 50;
- immediate multiline engine Destroy guards: 50;
- remaining class-owned engines or CQTest lifecycle hooks: 0;
- raw context Create calls across the target files: 37;
- matching named-context Release calls: 37.

### Case-owned context conversion

`Language/Operators/AngelscriptNativePowerOperatorTests.cpp` previously owned
one class-static `SharedContext` together with the class-static engine. Its
three product methods now each:

1. create their case-owned engine and install its Destroy guard;
2. create a case-owned context from that engine;
3. reject a null engine/context with the existing test error path;
4. install a multiline context Release guard before running the product.

The context guard is declared after the engine guard, so it executes first.
The three products continue to pass their engine and context explicitly to
the existing generator and execution helpers.

### Native callback observers

Two files require a static observer pointer because the raw SDK registration
uses a non-capturing native callback:

- `Language/ControlFlow/AngelscriptNativeBranchConditionDepthTests.cpp`;
- `Language/ControlFlow/AngelscriptNativeLoopConditionTransferDepthTests.cpp`.

Those observers were retained as justified callback bridges. Each unique
owner method now resets its observer to null on entry and has a method-level
exit guard that resets it again. The existing per-generated-cell guards also
continue to clear the active stack-local counter.

### Explicit helper dependencies

Helpers were preserved rather than duplicated, but implicit fixture access
was removed:

- Numeric-boundary conversion helpers now receive
  `FAutomationTestBase&` and the case-owned `FNativeTestEngine&`; source
  printing, diagnostic logging, reset, compilation, and execution use those
  explicit parameters.
- Declaration import binding now receives `FAutomationTestBase&` explicitly
  instead of reaching through the test class to `TestRunner`.
- The four indirect-call scenario helpers now receive both
  `FAutomationTestBase&` and the case-owned engine; all source printing,
  diagnostics, and execution calls use the explicit test parameter.
- The power-result verification helper now logs through its existing explicit
  `FAutomationTestBase& Test` parameter.

A target-file scan confirms no helper region before the first `TEST_METHOD`
still accesses `TestRunner` implicitly.

## Per-file accounting

| File | Methods | Engine Create | Engine Destroy |
| --- | ---: | ---: | ---: |
| `Language/ControlFlow/AngelscriptNativeBranchConditionDepthTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeConditionTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeControlFlowLifetimeDepthTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeForClauseTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeLoopConditionTransferDepthTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeLoopDepthTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeNestedTargetTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeStatementTransferTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeSwitchPlacementTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeSwitchTests.cpp` | 1 | 1 | 1 |
| `Language/ControlFlow/AngelscriptNativeTransferValidityTests.cpp` | 1 | 1 | 1 |
| `Language/Conversions/AngelscriptNativeBoolConversionTests.cpp` | 1 | 1 | 1 |
| `Language/Conversions/AngelscriptNativeConversionFailureTests.cpp` | 1 | 1 | 1 |
| `Language/Conversions/AngelscriptNativeConversionResolutionTests.cpp` | 1 | 1 | 1 |
| `Language/Conversions/AngelscriptNativeEnumAliasConversionTests.cpp` | 1 | 1 | 1 |
| `Language/Conversions/AngelscriptNativeNumericBoundaryConversionTests.cpp` | 3 | 3 | 3 |
| `Language/Conversions/AngelscriptNativeNumericConversionTests.cpp` | 1 | 1 | 1 |
| `Language/Conversions/AngelscriptNativeObjectCastTests.cpp` | 1 | 1 | 1 |
| `Language/Conversions/AngelscriptNativeValueObjectConversionTests.cpp` | 1 | 1 | 1 |
| `Language/Declarations/AngelscriptNativeDeclarationCollisionTests.cpp` | 1 | 1 | 1 |
| `Language/Declarations/AngelscriptNativeDeclarationFailureRecoveryTests.cpp` | 1 | 1 | 1 |
| `Language/Declarations/AngelscriptNativeDeclarationPublicationTests.cpp` | 1 | 1 | 1 |
| `Language/Exceptions/AngelscriptNativeExceptionHandlingRejectionTests.cpp` | 1 | 1 | 1 |
| `Language/Exceptions/AngelscriptNativeExceptionMetadataTests.cpp` | 1 | 1 | 1 |
| `Language/Exceptions/AngelscriptNativeExceptionOriginTests.cpp` | 1 | 1 | 1 |
| `Language/Exceptions/AngelscriptNativeExceptionRecoveryTests.cpp` | 1 | 1 | 1 |
| `Language/Foreach/AngelscriptNativeForeachIterationTests.cpp` | 1 | 1 | 1 |
| `Language/Foreach/AngelscriptNativeForeachProtocolTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionArgumentSourceTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionArityTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionArityTypeStressTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionDefaultArgumentTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionDirectionDefaultTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionIndirectCallTests.cpp` | 4 | 4 | 4 |
| `Language/Functions/AngelscriptNativeFunctionOverloadResolutionTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionParameterDirectionTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionParameterPositionTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionRecursionTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionReturnTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionSignatureShapeTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionTypedDefaultArgumentTests.cpp` | 1 | 1 | 1 |
| `Language/Functions/AngelscriptNativeFunctionValueLifecycleTests.cpp` | 1 | 1 | 1 |
| `Language/Operators/AngelscriptNativePowerOperatorTests.cpp` | 3 | 3 | 3 |
| **Total** | **50** | **50** | **50** |

## File-scoped static verification

Per instruction, no global script that rewrites catalog or audit CSV output was
run during shared editing. Verification was read-only and limited to the 43
target files:

1. Dedicated lifecycle and helper reconciliation: PASS
   - 43 files and 50 methods discovered from the quality CSV;
   - 50 local engine declarations;
   - 50 immediate multiline engine guards;
   - 50/50 engine Create/Destroy;
   - 37/37 context Create/Release;
   - zero class-owned engine/context fixtures or lifecycle hooks;
   - zero helper regions with implicit `TestRunner` access.
2. Targeted native SDK boundary scan: PASS
   - the six boundary rule patterns used by the OpenSpec audit were evaluated
     against only these files;
   - violations: 0.
3. Targeted inline AngelScript formatting scan: PASS
   - only these files were evaluated using the audit's raw-string and escaped
     newline rules plus the registered exception catalog;
   - raw sources: 1;
   - escaped-newline sources: 0;
   - violations: 0.
4. Scoped whitespace validation: PASS
   - all 43 files were pre-existing untracked paths, so each was checked with
     the equivalent `git diff --no-index --check`;
   - whitespace violations: 0.
5. One-line scope-exit scan: PASS
   - `ON_SCOPE_EXIT { ... }` occurrences: 0.

Build and runtime test status: **not run by instruction**.
