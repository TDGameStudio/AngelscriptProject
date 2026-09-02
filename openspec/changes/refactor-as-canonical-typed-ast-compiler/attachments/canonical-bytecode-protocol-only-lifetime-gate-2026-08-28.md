# Canonical Bytecode protocol-only lifetime gate — 2026-08-28

## Decision

CTA-S53 Task 15.7 is complete for the current non-Standalone scope.
Canonical Bytecode now selects normal, transfer and foreach cleanup actions
only from the verifier-authenticated lifetime protocol/shared derived view.
The emitter no longer routes semantic cleanup through compatibility cleanup
statement identities, cleanup expression spelling, dump text, destructor
spelling or a type-family guess.

This is not a product-default cutover. The engine default remains LEGACY
(`ep.canonicalCompilerPipeline = false`), explicit CANONICAL remains
fail-closed, the native AngelScript Parser AST/Builder/Compiler remain
available by design, and Standalone is deferred to a separate future
OpenSpec.

## Implemented boundary

### Shared authenticated exit plans

`as_ast_lifetime.h/.cpp` now derives a backend-facing
`asSASTLifetimeExitPlan` from authenticated protocol records. A plan carries
only:

- the structural statement owner;
- a typed plan kind (`NORMAL`, `TRANSFER` or `FOREACH`);
- the supported exit mask;
- ordered lifetime-view record indices.

Compatibility cleanup statement/expression identities are deliberately not
part of this structure. Exit plans are included in the derived-view
structural hash and reset lifecycle.

Normal block plans contain exact local records in reverse committed order.
Transfer plans contain only live local/foreach records whose activation point
precedes the transfer and whose semantic region is actually exited. Their
order is deterministic: deeper lifetime region first, then later activation,
then later record index. Foreach plans contain the exact iterator record.

### Bytecode consumption

`asCCanonicalFunctionEmitter` builds the lifetime view before emitting the
first function artifact. A missing, forged, wrong-revision or otherwise
invalid protocol therefore fails with
`asAST_VERIFY_INVALID_LIFETIME_PROTOCOL` before the emitter calls
`GetOrAddRelocationFunction()` or publishes detached tables.

The Bytecode emitter now:

- obtains cleanup order through `lifetimeView.FindExitPlan()`;
- resolves each action through `lifetimeView.GetRecord()`;
- dispatches only the protocol's typed `DESTROY_VALUE` or
  `RELEASE_REFERENCE` action;
- emits normal block cleanup through a `NORMAL` plan;
- emits return/break/continue/fallthrough cleanup through a `TRANSFER` plan;
- emits foreach iterator cleanup through a `FOREACH` plan;
- retains the loop stack only for backend-owned labels, common cleanup
  blocks, and fail-closed transfer-coverage validation;
- retains VM slots, active object records, labels, patches and physical
  cleanup state as backend output;
- preserves `asOBJ_INIT` success-before-active behavior: the current object
  becomes live only after its initializer call succeeds.

Compatibility cleanup children remain in the sealed AST as verifier and
differential evidence. For normal blocks the emitter uses authenticated plan
cardinality only to separate authored statements from those trailing
compatibility children; it never reads a compatibility child's identity,
expression, role or spelling to choose an action.

## TDD evidence and issues found

### Normal exit plan

The first source/fixture gate failed before the derived normal plan existed:

- RED build:
  `Saved/Build/cta-s53-15-7-exit-plan-red/20260828_200812_929_9a06859a`

The shared view and scoped tests then passed:

- GREEN build:
  `Saved/Build/cta-s53-15-7-normal-exit-plan-green/20260828_200915_696_4d70262d`
- GREEN rerun:
  `Saved/Tests/cta-s53-15-7-normal-exit-plan-green-rerun/20260828_201316_481_8b152b88`

### Transfer plan

The transfer-plan assertion failed while return cleanup still depended on
compatibility children:

- RED:
  `Saved/Tests/cta-s53-15-7-transfer-plan-red/20260828_201454_318_c70a422f`

After deriving exact live exited records:

- GREEN build:
  `Saved/Build/cta-s53-15-7-transfer-plan-green/20260828_201737_912_61ac6cbb`
- GREEN tests:
  `Saved/Tests/cta-s53-15-7-transfer-plan-green/20260828_201752_012_443e38a2`

### Foreach plan and fixture limitation

The first handcrafted foreach fixture was rejected because its generated
cleanup declaration did not carry the required `GENERATED` trait. That was a
fixture-authoring error rather than a production regression; correcting the
trait exposed the intended missing-plan RED:

- RED:
  `Saved/Tests/cta-s53-15-7-foreach-plan-red-2/20260828_202115_242_fb9a67d0`
- GREEN build:
  `Saved/Build/cta-s53-15-7-exit-plan-green/20260828_202204_817_16b74eac`
- GREEN tests:
  `Saved/Tests/cta-s53-15-7-foreach-plan-green/20260828_202219_289_ee82bc44`

Two initial execution fixtures also failed in `opForBegin()` at the sealed
storage-copy boundary (`asNOT_SUPPORTED`). An iterator with an explicit/user
destructor is not currently a valid sealed-storage-copy foreach iterator.
This is a supported-shape/fixture limitation, not evidence for partial
construction support:

- fixture failure 1:
  `Saved/Tests/cta-s53-15-7-nested-foreach-return-red/20260828_204034_750_d57d54e4`
- fixture failure 2:
  `Saved/Tests/cta-s53-15-7-nested-foreach-return-red-2/20260828_204142_839_186b2fd6`

The final regression therefore uses a generated iterator destructor and user
value destructors, and inspects exact Bytecode call offsets as well as VM
execution.

### Nested foreach return cleanup-order bug

The focused test found a real ordering bug for:

```text
outer local
  foreach iterator
    inner local
      return
```

Before the fix, ordinary transfer records were emitted first and the backend
loop stack emitted the iterator afterward. Recorded Bytecode offsets were:

```text
value destructors:    68, 74, 91
iterator destructor:  77
```

The transfer sequence was therefore `inner -> outer -> iterator`; the
required reverse lifetime order is `inner -> iterator -> outer`.

- exact RED:
  `Saved/Tests/cta-s53-15-7-nested-foreach-return-red-3/20260828_204346_035_28182756`

The fix makes transfer plans include both local and foreach-iterator records.
The shared region-depth ordering now interleaves them correctly, while the
loop stack only verifies coverage and prevents target-loop duplication.

One intermediate build exposed a missing C++ brace around the return switch
case; this was a mechanical compile failure and was fixed before the green
build:

- failed build:
  `Saved/Build/cta-s53-15-7-nested-foreach-return-green-build/20260828_204608_670_04d38b35`
- GREEN build:
  `Saved/Build/cta-s53-15-7-nested-foreach-return-green-build-2/20260828_204626_064_f58cca32`
- exact GREEN (`1/1`):
  `Saved/Tests/cta-s53-15-7-nested-foreach-return-green/20260828_204639_812_11045d4d`

### Source dependency gate

The source gate initially failed while the function emitter still used
compatibility cleanup bindings/children:

- RED build:
  `Saved/Build/cta-s53-15-7-bytecode-source-gate-red-build-2/20260828_202500_126_efe2b54d`
- RED test:
  `Saved/Tests/cta-s53-15-7-bytecode-source-gate-red/20260828_202518_585_54532535`

After migration:

- GREEN build:
  `Saved/Build/cta-s53-15-7-bytecode-protocol-green-build/20260828_202745_321_eec097e4`
- GREEN source gate:
  `Saved/Tests/cta-s53-15-7-bytecode-source-gate-green/20260828_203231_988_993c9536`

`CanonicalBytecodeLifetimeEmitterConsumesOnlyProtocolExitPlans` isolates the
complete Canonical function-emitter source slice and proves it contains
`FindExitPlan`/`GetRecord` while excluding:

- `FindCleanupBinding` / `GetCleanupBinding`;
- compatibility transfer-child traversal;
- `asCASTDump`;
- `scope-exit` / `scope-release` string decoding;
- destructor-name selection.

## Final verification

All final commands were run from the supported `D:\as-cta` worktree. No
Standalone build or test was run.

| Gate | Result | Evidence |
|---|---:|---|
| UE build | PASS | `Saved/Build/cta-s53-15-7-final/20260828_205251_912_2677a8ac` |
| Frontend CanonicalAST | 168/168 PASS | `Saved/Tests/cta-s53-15-7-frontend-final/20260828_205258_822_00f9e30d` |
| SemaAuthority | 401/401 PASS | `Saved/Tests/cta-s53-15-7-sema-authority-final/20260828_205342_197_7a0b906a` |
| ProductionCodeGen | 121/121 PASS | `Saved/Tests/cta-s53-15-7-production-codegen-final/20260828_204722_285_1e7915f7` |
| Canonical verifier | 44/44 PASS | `Saved/Tests/cta-s53-15-7-verifier-final/20260828_204804_849_1b5822a0` |
| CodeGen transaction | 20/20 PASS | `Saved/Tests/cta-s53-15-7-transaction-final/20260828_205211_762_eda0169e` |
| TypedASTJIT regression | 45/45 PASS | `Saved/Tests/cta-s53-15-7-typedastjit-regression/20260828_205433_686_276082e6` |
| Cache ASTBodySidecar | 22/22 PASS | `Saved/Tests/cta-s53-15-7-cache-sidecar-final/20260828_205638_460_89caafe1` |
| Cache SettingsAndShutdown | 7/7 PASS | `Saved/Tests/cta-s53-15-7-cache-default-final/20260828_205712_562_0d6126a6` |
| plugin diff check | PASS | `git -C Plugins/Angelscript diff --check` (line-ending warnings only) |

The earlier first full ProductionCodeGen, verifier and transaction passes are
also retained as provenance:

- `Saved/Tests/cta-s53-15-7-production-codegen-green/20260828_203405_746_fab4f7ea`
- `Saved/Tests/cta-s53-15-7-verifier-green/20260828_203455_502_851793cf`
- `Saved/Tests/cta-s53-15-7-transaction-green/20260828_203537_202_7889d923`

## Explicit non-claims and remaining issues

1. **Task 15.8 remains open.** TypedASTJIT's current `45/45` is a regression
   result only. AOT still has destructor/type/activation reclassification that
   must be replaced with the same authenticated lifetime view and a
   pointer-free stable-key/ABI-key provider summary.
2. **Tasks 15.9 and 15.10 remain open.** Base/member/delegating/complete-object
   committed prefixes and array/aggregate committed cursors are not provided
   by this gate.
3. **Task 15.11 remains open.** `asCBytecodeCodeGen` still uses an
   address-free `asCASTDump` outside the function emitter to compute a debug
   AST digest. It does not select a cleanup action, so it does not violate
   15.7, but 15.11 still requires protocol/identity hashing to be typed and
   structural rather than dump-derived.
4. Compatibility cleanup nodes and named compatibility view bindings remain
   available for verifier/differential evidence. This gate removes them only
   from Bytecode semantic routing; it does not delete the retained native
   AngelScript AST or explicit LEGACY pipeline.
5. Full constructor/destructor body lifecycle generation, globals/imports,
   exception/suspend parity, complete relocation installation, Hot Reload and
   whole-language cutover remain under their existing section 5/7/9/10/13
   umbrella tasks.
6. The product default remains LEGACY. This attachment is not evidence for
   Tasks 10.2/10.7 or a global default flip.
7. Standalone was neither modified nor run. Its adaptation remains deferred
   by the approved scope decision.

## Next gate

Task 15.8 must make TypedASTJIT consume this same authenticated shared view,
copy only pointer-free stable-key/ABI-key lifetime summaries into provider
records, and produce a precise typed per-function fallback for unsupported
native object-frame/exit shapes rather than a partial cleanup plan.
