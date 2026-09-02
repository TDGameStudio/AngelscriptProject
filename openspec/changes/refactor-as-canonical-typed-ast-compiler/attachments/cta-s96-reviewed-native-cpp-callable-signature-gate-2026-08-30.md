# CTA-S96 reviewed native C++ callable signature gate — 2026-08-30

## Status

CTA-S96 is implemented and verified for the requested non-Standalone scope.
The previously failing combined Compiler CanonicalAST + StaticJIT generation +
TypedASTJIT + NativeBridge matrix is now **778/778 PASS**, with zero failures
and zero skipped tests.

This slice closes one specific direct-native emission defect. It does not close
the then-remaining derived-funcdef source-formal relation, the residual
TypedASTJIT entry/helper Runtime type-name inference audit, complete unsupported
language/call-family breadth, or the final product-default cutover gates.
CTA-S97 subsequently closes the entry/helper audit and CTA-S98 closes the
derived-funcdef relation; this attachment does not retroactively claim either
later gate as CTA-S96 evidence.

## Original failure

The CTA-S95 combined matrix completed at **777/778 PASS**. Its only failure was:

```text
ReviewedRuntimePrintCallUsesResolvedCanonicalTarget
Canonical call formal type has no reviewed C++ spelling:
  Formal=2 Type=FLinearColor Quals=0
```

The selected call target, Canonical stable target relation, exact Runtime
function coordinate and generation-owned Runtime type-binding authentication
were already correct. The failure occurred later: the TypedASTJIT direct-call
emitter asked a small Canonical/Runtime type-name spelling helper to recover a
C++ formal type. That helper admitted scalar forms and a few managed reference
forms, but not by-value `FLinearColor`.

Adding another `FLinearColor` name branch would have made a diagnostic/runtime
name an ABI authority. That was rejected.

## Authority model

CTA-S96 makes the authority boundary explicit:

- the generated root/helper function signature is frozen by the StaticJIT
  entry plan and authenticated against the exact generation-owned Runtime
  return/formal/receiver coordinates;
- a nested direct native target is described by its reviewed native-call
  descriptor, whose `CppCallableSignature` is the exact public C++ function
  type;
- script calls and current-Engine bound bridge/thunk routes retain their
  Canonical/runtime binding rules;
- a Runtime type name, numeric TypeId, declaration display string or emitted
  dump is not allowed to synthesize the direct target's C++ ABI.

The direct-call data flow is therefore:

```text
reviewed native-call descriptor
  -> bounded structural C++ callable parser
  -> validation result with exact return/formal spellings
  -> call-closure-owned immutable validation result
  -> backend direct-emission plan
  -> Canonical emitter, indexed by sealed call-argument formalIndex
```

## Implementation

`FAngelscriptStaticJITNativeCallValidation` now owns a pointer-free
`FAngelscriptStaticJITNativeCallCppSignature` containing the exact reviewed
return type and formal type spellings.

The native-call descriptor validator parses `CppCallableSignature` before a
descriptor can become direct-callable. The parser is intentionally not a C++
compiler. It accepts one bounded, balanced type-only callable shape and rejects
missing parameter parentheses, unbalanced delimiters, empty parameter slots,
trailing tokens and statement/code injection. Limits are explicit:

- at most 4096 characters;
- at most 64 nested delimiters;
- at most 256 parameters;
- no quotes, line breaks or arbitrary statement punctuation.

The TypedASTJIT backend copies the validated return/formal spellings only for a
direct symbol route. Missing or inconsistent structured data fails only the
affected function before body emission. The emitter then:

- requires exactly one reviewed C++ formal for every sealed call argument;
- selects the target formal by sealed `asSASTCallArgument.formalIndex`;
- preserves the descriptor's exact value/reference/pointer/const spelling;
- never asks the Runtime type name to rediscover the direct target ABI.

No HIR adapter or dump transport was introduced. The original AngelScript
AST/Parser/Builder/Compiler remains available to LEGACY, syntax/recovery,
reference, differential and rollback paths.

## TDD and regression evidence

### Descriptor validation RED

`InvalidDescriptorMatrixFailsClosed` gained malformed callable cases for:

- missing callable parentheses;
- an unbalanced parameter list;
- an empty formal slot;
- a valid-looking signature followed by injected code.

The pre-fix run failed on the first case because the old validator accepted the
string:

```text
Saved/Tests/cta-s96-native-call-signature-validation-red/
  20260830_185749_466_8f802527/Report/index.json
```

The test-only RED build was successful:

```text
Saved/Build/cta-s96-native-call-signature-validation-red-build/
  20260830_185729_628_430cf197/Build.log
```

### Implementation build and focused GREEN

The implementation build succeeded:

```text
Saved/Build/cta-s96-reviewed-native-cpp-signature-green-build/
  20260830_190209_772_5e47efe2/Build.log
```

The whole NativeCallLinkage class plus the original Runtime Print failure is
**9/9 PASS**:

```text
Saved/Tests/cta-s96-reviewed-native-cpp-signature-focused-green/
  20260830_190356_449_82999260/Report/index.json
```

### First combined rerun and stale manual-plan contract

The first 778-item rerun closed the Runtime Print failure but exposed one old
test helper that manually assembled a native emission plan with only
`Symbol/Include`:

```text
Saved/Tests/cta-s96-canonical-generation-typedjit-nativebridge-regression/
  20260830_190447_550_5db6e758/Report/index.json
```

Result: **777/778 PASS**. The only failure was
`ReviewedUEHeaderInlineCallIsFrozenIntoGenerationSnapshot`. Production data was
not missing: the descriptor contained `bool()`, call closure validation had
already produced the exact `bool` return and zero formals, and the production
backend copied them. Only the test's direct emitter invocation still used the
old plan shape.

The test now asserts that exact descriptor/validation contract and copies the
validated signature, without weakening the emitter's fail-closed check.

The test-contract build succeeded:

```text
Saved/Build/cta-s96-reviewed-native-signature-test-contract-green-build/
  20260830_191141_284_01cd77ac/Build.log
```

The exact test is **1/1 PASS**:

```text
Saved/Tests/cta-s96-reviewed-ue-header-inline-contract-green/
  20260830_191201_765_355970a7/Report/index.json
```

### Final combined GREEN

The exact final matrix is:

```text
Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST
+ Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine
+ Angelscript.TestModule.StaticJIT.TypedASTJIT
+ Angelscript.TestModule.StaticJIT.NativeBridge.TypedASTJIT
```

Final result: **778/778 PASS**, zero failures, zero skipped tests:

```text
Saved/Tests/cta-s96-reviewed-native-signature-final-regression/
  20260830_191242_555_6d5a2aed/Report/index.json
```

`git diff --check` reports no whitespace errors. Existing line-ending warnings
for the already-dirty worktree are not CTA-S96 functional failures.

## Remaining non-claims

- Product default remains LEGACY.
- This result is not the final complete AST gate, All suite or default-cutover
  matrix.
- Standalone remains explicitly deferred for this change.
- Direct native target ABI is now descriptor-authoritative, but root/helper
  function signature emission still needs the planned audit that removes any
  remaining live Runtime type-name inference in favour of frozen entry-plan
  data plus exact authentication.
- Derived funcdef metadata copy/reuse and its Runtime fallback consumers were a
  separate source-formal identity closure at this checkpoint; CTA-S98 records
  their later RED/GREEN completion.
- Complete unsupported call/language/provider breadth remains an umbrella-task
  requirement even when each current unsupported function fails closed to VM.
