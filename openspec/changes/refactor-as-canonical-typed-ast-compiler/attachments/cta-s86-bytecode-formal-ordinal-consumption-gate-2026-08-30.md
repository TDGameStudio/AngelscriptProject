# CTA-S86 Canonical Bytecode formal-ordinal consumption gate — 2026-08-30

## Status

This non-Standalone slice closes the reviewed Canonical Bytecode/VM parameter
consumer defect left explicit by CTA-S85. CTA-S85 published and authenticated
`ParamDecl.formalIndex`; CTA-S86 makes Bytecode CodeGen consume that exact
relation for Runtime signature lookup/materialization and callee-entry stack
binding instead of rebuilding ABI order from declaration-child position.

Formal OpenSpec progress remains **102/136 = 75.0%**. Tasks 7.2 and 7.4 are
umbrella rows and the production Sema consumer audit found additional
child-position consumers that still require a separate TDD slice. The current
engineering estimate therefore remains about **93%** for the requested
non-Standalone architecture and about **78%** for a safe product-default
CANONICAL switch. The default remains LEGACY. The native AngelScript parser AST
remains available; HIR remains absent. Standalone was neither changed nor run.

## Defect

`asCBytecodeCodeGen::BindParameters` previously associated incoming Runtime
parameter slot N with the nth `DECL_PARAM` child. Two same-typed parameters
made that a silent identity bug:

```text
sealed relation
  First.formalIndex  = 0
  Second.formalIndex = 1

adversarial structural children
  [Second, First]

Runtime inputs
  slot 0 = 4
  slot 1 = 2

old entry binding
  Second DeclId -> slot 0
  First  DeclId -> slot 1

First * 10 + Second = 24   // wrong, no type mismatch
```

The same convention existed in positional signature consumers used by
registered globals/methods/constructors/list factories, prepared and automatic
imports, current-module lookup, generated setter binding, Runtime function
signature materialization and detached import creation.

## Frozen consumption rule

1. Declaration children remain structural/traversal/ownership order. They are
   not a Runtime ABI table.
2. Every positional parameter consumer obtains the count through
   `GetFormalDeclCount(owner)` and slot N through
   `GetFormalDecl(owner, N)`.
3. A missing, duplicate or otherwise non-exact formal slot fails closed. No
   consumer falls back to child position, parameter name or diagnostic text.
4. Callee entry binds exact ParamDecl IDs to Runtime input slots in formal
   order. Function-owned ordinary `VarDecl` locals remain a separate structural
   traversal, and lambda captures remain a separate capture relation.
5. Call-site expression evaluation continues to follow sealed call-record
   storage order. `callArguments[].formalIndex` places already-evaluated values
   into invocation slots; formal order must not replace evaluation order.
6. Runtime `parameterTypes[N]`, `inOutFlags[N]` and parameter-name arrays are
   positional ABI metadata only after their Canonical source has been joined by
   exact formal ordinal.

## TDD evidence

The regression method
`PreparedBytecodeParametersUseSealedFormalOrdinalRelation` was added to
`AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` before production
consumers changed. It builds:

```angelscript
int EncodeFormals(int First, int Second)
{
    return First * 10 + Second;
}
```

After Sema/layout establishes `formalIndex` 0 and 1, the fixture swaps only the
two same-typed ParamDecl child positions, seals the still-valid graph, generates
the prepared module, invokes the VM with `4, 2`, and requires `42`.

- RED build: PASS —
  `Saved/Build/cta-s86-bytecode-formal-ordinal-red-build/20260830_101928_904_c86e5a22`;
- intended semantic RED: **0/1**, only the expected result assertion failed —
  `Saved/Tests/cta-s86-bytecode-formal-ordinal-red/20260830_101951_795_33379d40`;
- GREEN build: PASS —
  `Saved/Build/cta-s86-bytecode-formal-ordinal-green-build/20260830_102216_754_3373f6a1`;
- focused GREEN: **1/1 PASS** —
  `Saved/Tests/cta-s86-bytecode-formal-ordinal-green/20260830_102229_382_437a6c3f`.

The old implementation returned `24`; the exact formal relation returns `42`.

## Migrated consumers

All of the following positional consumers in `as_bytecode_codegen.cpp` now use
the exact formal relation:

- registered global function lookup;
- prepared explicit-import and automatic-import lookup;
- declaration-only automatic imported script global lookup;
- current-module script global lookup;
- registered method, constructor/factory and list-factory lookup;
- zero-argument constructor classification;
- generated setter value-formal binding;
- VM callee-entry `BindParameters`;
- direct-call sealed-formal inventory;
- Runtime function signature and parameter-name materialization;
- detached import signature creation.

The `BindParameters` split is intentional:

```text
exact formal loop -> incoming Runtime parameter slots
structural child loop -> function-owned ordinary VarDecl locals only
capture relation -> lambda hidden captures
```

A final source scan found no remaining common `DECL_PARAM` child-position loop
in this file. A separate read-only audit independently classified every
remaining ParamDecl reference and found no current Bytecode production path
that derives an ABI slot from child order.

## Regression evidence

| Gate | Result |
| --- | --- |
| UE 5.8 Editor build | PASS — `Saved/Build/cta-s86-bytecode-formal-ordinal-green-build/20260830_102216_754_3373f6a1` |
| Exact reordered same-type VM execution | **1/1 PASS** — `Saved/Tests/cta-s86-bytecode-formal-ordinal-green/20260830_102229_382_437a6c3f` |
| Complete ProductionCodeGen class | **137/137 PASS** — `Saved/Tests/cta-s86-production-codegen-green/20260830_102357_435_49193af5` |
| Canonical CodeGen transaction/rollback class | **21/21 PASS** — `Saved/Tests/cta-s86-codegen-transaction-green/20260830_102431_917_b2715503` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **706/706 PASS**, zero failures/skips — `Saved/Tests/cta-s86-compiler-typedjit-nativebridge-full-green/20260830_102505_293_4b52705d` |

The broad count increased from 705 to 706 only because CTA-S86 adds one test.
HTTP connectivity warnings in existing provider reload tests did not fail or
skip tests and are unrelated to this relation.

## Independent audit and non-claims

The wider Runtime/cache/TypedASTJIT audit found no additional in-scope
production blocker outside Bytecode and Sema. Runtime type bridge, Sidecar V10,
Cache capture/restore, public immutable view and TypedASTJIT call/root consumers
are formalIndex-safe. It did identify missing negative evidence for malformed
ParamDecl ordinals and Sidecar V10 declaration-ordinal corruption; these are
test-hardening items recorded in
`reviews/formal-ordinal-production-consumer-audit-2026-08-30.md`.

CTA-S86 does not close production Sema child-order consumers. The separate
audit found confirmed risks in call-plan construction, generated-call fallback,
override/interface matching, lambda/funcdef compatibility and contextualization,
constructor/operator conversion, setter formal selection and native/external
signature projection. Those are the next CTA-S87 TDD scope; they are not hidden
inside this Bytecode slice.

Two Runtime shell paths still publish null `defaultArgs` entries while
materializing synthesized/detached signatures. Existing sealed default-call
execution does not rebuild defaults there, so this is not the reorder defect.
Whether those shells promise presentation metadata needs a separate contract
test before changing ownership or copying default-expression state.

This slice does not switch the product default, archive the change, remove the
explicit LEGACY route, remove the native parser AST, restore HIR, claim complete
7.2/7.4 coverage, run the final All matrix or claim Standalone parity.
