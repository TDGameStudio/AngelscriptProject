# Canonical sequencing and single-evaluation closure gate (CTA-S177)

## Decision

Task 5.4 is accepted on plugin commit `01c4158`. The supported Canonical source
surface now carries explicit sequencing and single-evaluation structure for
property/index mutation chains, short-circuit logic, conditional value/reference
selection, value temporaries and compiler-generated struct values. Independent
LEGACY and CANONICAL Engines prove the required observable behavior.

This gate closes Task 5.4 only. It does not close structured control Tasks
5.5/5.6, lifetime Tasks 5.7/5.8, broad Sema authority Task 13.2, complete
Bytecode/TypedASTJIT consumers, snapshot publication, default cutover, LEGACY
isolation/deletion, or final regression.

## Requirement-to-evidence map

| Task 5.4 surface | Sealed/production evidence | Execution evidence |
|---|---|---|
| property compound assignment | captured receiver/getter value, updated value and setter write are explicit ordered phases | `IsolatedPropertyCompoundAssignMatchesLegacyCanonicalTrace` |
| property prefix/postfix | exact `Sequence`/`OpaqueValue`/write/yield shape; postfix yields the captured old value | Canonical Sema/Production positive gates; LEGACY rejection is a documented language boundary |
| overloaded/raw index compound assignment | RHS value, receiver, reference-producing index, updated value and write are explicit phases | `IsolatedIndexCompoundAssignMatchesLegacyCanonicalTrace`, including scalar and object-reference RHS cases |
| overloaded index prefix/postfix | receiver and index reference are evaluated once; prefix yields updated value and postfix yields old value | `IsolatedIndexPrefixIncrementMatchesLegacyCanonicalTrace` and `IsolatedIndexPostfixIncrementMatchesLegacyCanonicalTrace` |
| logical short-circuit | selected operand only is evaluated | `IsolatedLogicalShortCircuitMatchesLegacyCanonicalTrace` |
| conditional values/references | selected value/address arm only is evaluated; reference identity is preserved | conditional VM matrix with distinct `Marker=8/9` arm traces and `11/29` reference payloads |
| temporaries | construction/destruction order and value transfer are stable | `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace` |
| compiler-generated values | generated struct/value construction survives Canonical publication and execution | generated-struct Sema/CodeGen/VM fixtures |

SemaAuthority locks the AST relationship before execution evidence is counted.
ProductionCodeGen and the VM matrix then prove that CodeGen consumes the sealed
facts with `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and zero LEGACY compiler
invocations for the Canonical side.

## Authentic RED/GREEN history

### Index compound RHS order

The first authentic differential RED showed Canonical trace `1,2,3` where
LEGACY required RHS-first `3,1,2`:

- RED: `Saved/Tests/cta-s177-rhs-order-red/`
  `20260901_183128_172_881c9764`, **0/1**.
- Production correction: Sema publishes RHS, receiver, index/reference,
  updated-value and write phases as one explicit `Sequence`.

### Index unary single evaluation

The initial overloaded-index unary lowering called `opIndex` three times:

- RED: `Saved/Tests/cta-s177-index-mutation-table/`
  `20260901_185214_703_6ad8520c`, **0/1**.
- GREEN: `Saved/Tests/cta-s177-index-unary-single-eval-green/`
  `20260901_185345_937_147c783f`, **1/1 PASS**.

The final lowering captures the receiver once, captures the reference-producing
index operation once, loads the old scalar once, computes the new value once,
writes through the captured reference once, and yields either the new or old
value according to prefix/postfix semantics.

### Object reference return/address preservation

A later matrix RED crashed when CodeGen treated an object-reference return as
a value instead of preserving its lvalue address:

- RED: `Saved/Tests/cta-s177-index-mutation-final-targeted/`
  `20260901_192552_004_e75509de`, **0/1** with the authentic crash/failure.
- GREEN: `Saved/Tests/cta-s177-index-mutation-reference-return-green/`
  `20260901_192808_257_3bdb61e4`, **1/1 PASS**.

Non-handle reference returns now use the expression's lvalue address. Opaque
reference capture, scalar reference-to-value conversion and reference
conditional lowering use the same address-preserving boundary.

## The `+=` scalar-reference alias case

This was the final correctness issue found by the CodeGen review subagent and
is recorded in detail because a simple order trace did not expose it.

### Trigger

The valid differential fixture keeps the RHS source and the mutation target in
one object but in different fields:

```angelscript
class AliasingT
{
    int SharedRhs = 10;
    int SharedSink = 1;

    int& GetSharedRhs()
    {
        Trace(8);
        return SharedRhs;
    }

    AliasingT MutateAndReturn()
    {
        Trace(9);
        SharedRhs = 20;
        return this;
    }

    int& opIndex(int)
    {
        Trace(2);
        return SharedSink;
    }
}

MutateAndReturn()[0] += GetSharedRhs();
```

AngelScript compound-index semantics evaluate and read the RHS before the
receiver/index chain. Therefore both pipelines must:

1. call and read `GetSharedRhs()` while the value is `10`;
2. call `MutateAndReturn()`, which changes the source storage to `20`;
3. call `opIndex()` once and update `SharedSink` from `1` to `11`;
4. produce the exact side-effect trace `8,9,2`.

### Authentic RED

- Build: `Saved/Build/cta-s177-rhs-ref-alias-valid-red3-build/`
  `20260901_194936_528_9970874d`, PASS.
- Differential test: `Saved/Tests/cta-s177-rhs-ref-alias-valid-red3/`
  `20260901_194959_539_1dab4840`, **0/1 as expected**.
- Exact failure: `CANONICAL scalar-reference RHS must snapshot 10 before
  receiver mutates the shared source; got=21`.

The trace order alone was correct. The wrong result proved that Canonical had
captured the RHS reference address, not the scalar value observed during phase
one. The receiver then changed the referenced storage from `10` to `20`, so the
later addition read `20` and produced `21`.

### Root cause and production fix

Both index-compound branches created an RHS `OpaqueValue` while the RHS still
had scalar-reference type. CodeGen correctly treats a reference-typed
`OpaqueValue` as an address capture, but that representation was wrong for the
compound-assignment semantic phase: the language requires the scalar RHS value
to be frozen before receiver evaluation.

`as_sema_expr.cpp` now applies
`DecayScalarLValueReferenceToRValue(...)` before
`ActOnOpaqueValueExpr(...)` in both the overloaded `opIndex` Call branch and the
raw Index fallback branch. The resulting RHS Opaque has non-reference
primitive/enum type, so CodeGen performs the load in the first Sequence phase
and stores an independent value temporary. Handles and object references are
not indiscriminately decayed.

### GREEN

- Build: `Saved/Build/cta-s177-rhs-ref-alias-green-build/`
  `20260901_195057_398_24dc402e`, PASS.
- Differential test: `Saved/Tests/cta-s177-rhs-ref-alias-green/`
  `20260901_195113_684_2dbd37cd`, **1/1 PASS**.
- Final matrix assertion: `SharedSink == 11`, trace `8,9,2`, each operation
  evaluated once in both independent LEGACY and CANONICAL Engines.

Earlier attempts named `cta-s177-rhs-ref-alias-red2` and the first
`...valid-red`/`...valid-red2` fixtures were diagnostics-only experiments:
mutable globals or invalid return/syntax forms were rejected before the target
semantic path. They are not counted as functional RED evidence. A wrong-prefix
run that matched no tests is likewise excluded.

## Property unary and assignment-expression boundaries

LEGACY currently rejects property-accessor prefix/postfix forms. The final
negative gate builds each source form in its own module so one failure cannot
mask accidental acceptance of another:

- temporary property prefix: `++Make().Value` -> `Reference is temporary`;
- temporary property postfix: `Make().Value++` -> `Reference is temporary`;
- local property postfix: `Object.Value++` ->
  `Property accessors cannot be used in combined read/write operations`.

Each case resets diagnostics, must fail its own `Build()`, must not publish
`Entry()`, and must execute no getter/setter trace. Canonical positive Sema and
ProductionCodeGen tests independently lock the explicit rewrite; the closure
does not claim false LEGACY execution parity for parser/compiler-rejected
source.

Likewise, compound assignment used as a consumed expression is rejected by the
current LEGACY parser. The audit run
`Saved/Tests/cta-s177-consumed-compound-green2/`
`20260901_191502_416_6fd82862` is **0/1 due to the documented parser boundary**
and is not presented as a regression or a passing gate.

## Review findings and disposition

Three subagent findings were resolved before closure:

1. **Major correctness:** scalar-reference RHS aliasing in index `+=` captured
   an address instead of the phase-one value. Fixed and covered by the authentic
   RED/GREEN above.
2. **Major test precision:** three LEGACY property-unary rejection forms shared
   one failed module. Split into independent module builds and diagnostics.
3. **Minor test precision:** conditional reference arms lacked a side-effect
   oracle, and later the negative modules shared accumulated diagnostics. Added
   distinct arm markers `8/9`, exact selected-arm trace assertions, and
   `ResetMessages()` before each independent rejection build.

The final CodeGen and test-review subagents both returned APPROVE with no
blocker or major finding. The final minor was also corrected before the last
Build/Semantics verification.

## Final verified checkpoint

| Gate | Result | Report |
|---|---:|---|
| Build after all production/review fixes | PASS | `Saved/Build/cta-s177-review-findings-final-build/20260901_195304_206_a8c6bdeb` |
| Semantics after production/review fixes | **15/15 PASS** | `Saved/Tests/cta-s177-semantics-review-final/20260901_195326_892_c43b936f` |
| SemaAuthority | **538/538 PASS** | `Saved/Tests/cta-s177-semaauthority-review-final/20260901_195404_651_f90409d2` |
| Frontend CanonicalAST | **189/189 PASS** | `Saved/Tests/cta-s177-frontend-review-final/20260901_195549_039_e733d7ab` |
| ProductionCodeGen | **230/230 PASS** | `Saved/Tests/cta-s177-production-codegen-review-final/20260901_195628_961_558bda16` |
| Build after final diagnostic-isolation minor | PASS | `Saved/Build/cta-s177-review-minor-final-build/20260901_200257_097_841d5980` |
| Semantics after final diagnostic-isolation minor | **15/15 PASS** | `Saved/Tests/cta-s177-semantics-review-minor-final/20260901_200316_367_3f9c6dc5` |

All listed final test reports have zero failures and zero skips. Cache V2/V12
was intentionally not run: the user explicitly deferred that prototype's
refactor/testing, and it is not a Task 5.4 closure gate.

## Non-claims

- Task 5.4 accepts the currently valid/supported source forms; it does not
  broaden parser syntax or LEGACY property-accessor mutation support.
- It does not prove complete block/loop/switch transfer and cleanup behavior;
  those remain 5.5/5.6 and 5.7/5.8.
- It does not prove that every remaining semantic rule is independent of
  parser-node walks; that is 13.2.
- It does not authorize default CANONICAL selection, LEGACY deletion, complete
  Bytecode/TypedASTJIT cutover, Cache prototype promotion, or final archive.
