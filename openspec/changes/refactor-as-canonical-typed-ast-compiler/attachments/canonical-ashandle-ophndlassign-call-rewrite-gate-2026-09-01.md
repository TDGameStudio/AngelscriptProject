# Canonical ASHANDLE `opHndlAssign` call rewrite gate (CTA-S172)

## Scope and outcome

CTA-S172 closes the `opHndlAssign` item in the task-5.3 remaining-call
inventory. Plain `=` on a type carrying the source-language
`asOBJ_ASHANDLE` trait is now resolved by Canonical Sema to an ordinary sealed
`Call` of `opHndlAssign`; Canonical Bytecode consumes that call without
reopening Runtime type flags or invoking the LEGACY compiler.

The formal OpenSpec count remains **107/136 complete (78.7%)**. Task 5.3 and
13.2 remain `[ ]` because reverse-operator family completeness beyond the
existing `opAdd_r` characterization is still unproved.

## Authentic positive RED

The fixture registers a native VALUE type with `asOBJ_ASHANDLE` and two
distinguishable methods:

- `opAssign` writes `-100`;
- `opHndlAssign` writes `Other.Stored + 21`.

Before the implementation, Canonical Sema mapped every authored `=` through
the generic assignment name `opAssign`. The focused dump retained:

```text
EXPR kind=Assign literal==
     callee=FHandleValue::opAssign(const FHandleValue&in)
```

Evidence:

- build: `Saved/Build/cta-sema-call-53-hndlassign-red/`
  `20260901_142158_543_f741936d`, **PASS**;
- focused Sema test: `Saved/Tests/cta-sema-call-53-hndlassign-red/`
  `20260901_142244_319_e8284450`, **0/1 FAIL**.

This was a semantic-selection failure, not a CodeGen storage-width failure:
the legacy compiler selects `opHndlAssign` from the left type's
`asOBJ_ASHANDLE` flag, while Canonical Sema had not projected that decision.

## LLVM/Clang-style ownership boundary

The repair follows the architecture used throughout this change:

1. Engine registration is copied into pointer-free Canonical registered-type
   and template-declaration facts for the current Sema generation.
2. `IsCanonicalAsHandleType()` reads only those Sema facts. It supports both
   ordinary registered nominal types and template instances by resolving the
   instance's stable template base.
3. Plain `=` selects `opHndlAssign` only when that semantic trait is present.
4. Overload ranking, exact formal provenance, receiver and result type are
   sealed into a real `asAST_EXPR_CALL`.
5. Canonical CodeGen lowers the call it was given. It does not inspect
   `asOBJ_ASHANDLE`, re-rank methods, or infer a backend assignment operator.

Registered `opHndlAssign` is normally an EXTERNAL/native declaration. The
assignment-call helper now admits that exact semantic operator while retaining
the existing EXTERNAL exclusion for ordinary `opAssign` storage semantics.

## Fail-closed negative RED/GREEN

The first positive implementation still had a dangerous fallback: if an
ASHANDLE type omitted `opHndlAssign` but did expose `opAssign`, the call rewrite
failed and the generic leftover `Assign` path resolved `opAssign`. That would
let the backend reinterpret the source operation after Sema.

A second fixture therefore registers the same ASHANDLE surface without
`opHndlAssign`, while deliberately retaining `opAssign`.

Authentic RED:

- `Saved/Tests/cta-sema-call-53-hndlassign-discovery-audit/`
  `20260901_143105_796_4c008204`, **1/2 PASS, 1/2 FAIL**;
- the failing dump contained `Assign(... callee=opAssign)` and zero Sema
  diagnostics.

Canonical Sema now publishes the stable diagnostic
`no-appropriate-opHndlAssign` and returns no generic assignment expression.
There is no bytewise or `opAssign` fallback for this semantic operation.

GREEN:

- final build: `Saved/Build/cta-sema-call-53-hndlassign-negative-green/`
  `20260901_143215_383_ff9b993d`, **PASS**;
- positive plus negative class gate:
  `Saved/Tests/cta-sema-call-53-hndlassign-negative-green/`
  `20260901_143311_549_5fc2edfb`, **2/2 PASS**.

An earlier method-level test filter matched zero tests because CQTest includes
the generated class segment in the full path. It is excluded from evidence;
the class-level runs above discovered and executed both tests.

## Production execution proof

The production fixture executes:

```angelscript
int Entry()
{
    FHandleValue Left;
    FHandleValue Right;
    Right.SetStored(21);
    Left = Right;
    return Left.ReadStored();
}
```

`Entry() == 42` proves `opHndlAssign`, not the deliberately hostile
`opAssign`, executed. The same gate verifies Canonical CodeGen publication and
zero LEGACY compiler invocations.

- focused production result:
  `Saved/Tests/cta-sema-call-53-hndlassign-codegen/`
  `20260901_142635_652_0639c8bc`, **1/1 PASS**.

## Full regression gates

- complete SemaAuthority:
  `Saved/Tests/cta-sema-call-53-hndlassign-sema-full/`
  `20260901_143410_833_cbbe970c`, **530/530 PASS**;
- complete ProductionCodeGen, including ScriptCorpus and the new execution
  fixture:
  `Saved/Tests/cta-sema-call-53-hndlassign-prodcodegen-full/`
  `20260901_143618_627_89cd71b5`, **226/226 PASS**, zero failures/skips;
- plugin `git diff --check`: clean apart from expected Windows line-ending
  notices.

The wide ProductionCodeGen run included two existing ScriptCorpus cases that
took about 128 and 123 seconds and UE connectivity-probe warnings. Both slow
tests passed, the harness exit code was zero, and neither warning is a compiler
failure.

## Non-claims and next boundary

CTA-S172 does not close 5.3 or 13.2, remove all backend `asCCompiler` reruns,
or prove every call/conversion family. It closes only ASHANDLE assignment
selection, exact Call publication, execution and missing-operator fail-closed
behavior. The remaining task-5.3 call-family boundary is the complete reverse
operator mapping/ranking/execution matrix beyond the existing `opAdd_r` gate.
