# Canonical cross-section forward-call gate (2026-08-24)

## Outcome

Canonical source compilation now preserves an unresolved call across script
section boundaries, binds it when a later section publishes the exact
declaration, removes provisional type-dependent lifetime wrappers from the
owned body graph when the final result is primitive/void, and executes the
result through Canonical CodeGen.

This is a bounded Sema/recovery closure. It does not claim that every
declaration is pre-collected before every body, that arbitrary error-dependent
parent expressions are fully reanalysed, or that Tasks 4.2, 5.3, 9.5, 13.2,
or 13.6 are complete.

## Gate card

| Field | Evidence |
| --- | --- |
| Semantic fact | A call in an earlier source section may bind to a function declaration in a later section; its final sealed result type and direct statement ownership must reflect the exact declaration rather than parser-time recovery state. |
| AST-first owner | `FCanonicalASTSemaAuthorityTests.CrossSectionForwardCallResolvesAfterAllDeclarationsAreVisible` |
| Red symptom | The first section emitted `unresolved-callee:AddOne`; after retaining the deferred record, CodeGen then reported an ERROR type user on the provisional `Cleanup` wrapper. |
| Production change | `ResolveDeferredCalls()` keeps unresolved work for later sections, binds the exact declaration and result type, and disconnects ERROR-only `Cleanup` / `MaterializeTemporary` recovery wrappers when the resolved result is primitive/void. `asCASTContext::ReplaceExprUses()` rewrites pre-seal Decl initializer, Stmt expression, Expr child, and receiver ownership edges without deleting arena nodes. |
| AST assertion | The sealed graph contains the exact `AddOne` declaration, a resolved `Call<int>` with one reverse-formal argument, and `Entry`'s `ReturnStmt.expr` points directly to that Call rather than to the provisional Cleanup. |
| Downstream assertion | The same CANONICAL module executes `Entry()` and returns `42`. |
| Compatibility routing | `FBuilderCrossSectionPublicationTests` directly drives private `asCBuilder::Build*` stages, so it now explicitly selects LEGACY. It remains a Builder protocol/section-owner oracle and no longer inherits the production default accidentally. |

## Root cause

The parser invokes `ResolveDeferredCalls()` after every source section. The old
implementation discarded unresolved entries unconditionally, so a later
section could never satisfy an earlier call. Retaining the entry exposed the
second layer: the original ERROR-typed call had already caused return Sema to
create a `Cleanup(ERROR)` node. Updating only the Call's `resolvedDecl` and
type left that wrapper as an owned ERROR type user, so CodeGen correctly
failed closed.

The final ownership shape is:

```text
before later declaration                  after later declaration

ReturnStmt                                ReturnStmt
    |                                         |
Cleanup<ERROR>       -- final bind -->      Call<int> ------> AddOne(int)
    |                                                   arg: IntegerLiteral 41
Call<ERROR, AddOne?>

The old Cleanup node remains arena-owned but is unreachable from declaration,
statement, expression-child, and receiver ownership edges. Its type is made
non-error so whole-arena verification and diagnostics do not mistake recovery
storage for a live unresolved semantic fact.
```

## Verification

- Runtime/Editor build:
  `Saved/Build/cta-cross-section-explicit-routing-build/20260824_124141_210_5ba1271f/RunMetadata.json`
  — exit 0.
- Canonical AST + execution and explicit LEGACY Builder protocol gates:
  `Saved/Tests/cta-cross-section-final-gates/20260824_124159_096_79d8d67f/RunMetadata.json`
  — **2/2 PASS**.
- Complete Compiler prefix after the closure:
  `Saved/Tests/cta-compiler-post-cross-section/20260824_124251_451_d7324c8d/RunMetadata.json`
  — **497/556 PASS**, 59 failures. The previous cross-section failure is gone
  and the new permanent gate increases the inventory from 555 to 556.

The 59 remaining Compiler failures split into 52 historical
`TypedSemanticIR/HIR` tests that still expect HIR capture under the now-default
Canonical pipeline, and seven non-HIR tests: one Builder layout case, four
bytecode generation/optimization-internal cases, and two diagnostic contract
cases. They are follow-up classification/migration work, not evidence that
this cross-section gate remains open.
