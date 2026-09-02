# Canonical import binding immutability gate (CTA-S175)

## Decision

CTA-S175 closes the final historical `TypedSemanticIR/Call*` oracle required by
Task 5.3. A retained Canonical import call continues to name the same stable
`ImportDecl` when its Runtime slot is bound, rebound, and unbound. Mutable
provider FunctionIds never enter the AST.

Task 5.3 is accepted. This gate does not accept Task 7.4's complete native
ABI/bridge consumer contract or broader Sema umbrella 13.2.

## Authenticated relation

The consumer snapshot contains exactly:

- one `ImportDecl` named `ImportedValue`, with provider-A origin and a non-empty
  stable declaration key;
- one zero-argument `Call` whose `resolvedDecl` is that exact `ImportDecl`;
- no receiver, source argument, hidden argument, Engine import-slot number, or
  mutable bound FunctionId;
- a concrete primitive `int` result type.

The verifier accepts the Frozen/Publishable graph. Sidecar V12 encodes the
complete snapshot.

## Runtime mutation oracle

The same import slot is exercised in three states:

| Runtime action | `sBindInfo::boundFunctionId` | Execution | Canonical snapshot |
|---|---:|---:|---|
| bind provider A | provider-A FunctionId | `11` | dump and V12 bytes identical |
| rebind provider B | provider-B FunctionId | `29` | dump and V12 bytes identical |
| unbind | `-1` | `asEXECUTION_EXCEPTION` | dump and V12 bytes identical |

Canonical CodeGen emits `CALLBND`, publishes with
`asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, and records zero LEGACY compiler
invocations. The execution change is therefore caused solely by Runtime slot
state.

## Characterization-first evidence

- Initial RED:
  `Saved/Tests/cta-sema-call-53-import-immutability-sema-characterization/`
  `20260901_164058_758_80b666a5`, **0/1**. The test had not requested public
  snapshot retention, so `GetCanonicalASTContext()` correctly returned null.
- Test-fixture correction build:
  `Saved/Build/cta-sema-call-53-import-immutability-retention/`
  `20260901_164207_914_5c8ec555`, PASS. The consumer now selects
  `asAST_RETAIN_SNAPSHOT` before `Build()`; no production source changed.
- Focused Sema immutability:
  `Saved/Tests/cta-sema-call-53-import-immutability-sema-green/`
  `20260901_164227_087_0d3488e3`, **1/1 PASS**.
- Focused CodeGen execution:
  `Saved/Tests/cta-sema-call-53-import-immutability-codegen-characterization/`
  `20260901_164307_715_051522c6`, **1/1 PASS**.
- Complete SemaAuthority:
  `Saved/Tests/cta-sema-call-53-import-immutability-sema-full/`
  `20260901_164355_819_c4757669`, **533/533 PASS**, zero failures/skips.
- Complete ProductionCodeGen:
  `Saved/Tests/cta-sema-call-53-import-immutability-prodcodegen-full/`
  `20260901_164556_792_040d4d37`, **229/229 PASS**, zero failures/skips.
- CTA-S174 companion gates retained for final 5.3 acceptance: Frontend
  CanonicalAST **189/189 PASS** and Cache V12 **586/586 PASS**.

## Non-claims

The imported function's Runtime shell and `sBindInfo` remain mutable execution
state by design. Task 7.4 must still authenticate native ABI,
bridge/direct/fallback disposition, binding-snapshot consumption and cross-TU
restrictions. This gate neither copies that state into `CallExpr` nor authorizes
default CANONICAL cutover or LEGACY deletion.
