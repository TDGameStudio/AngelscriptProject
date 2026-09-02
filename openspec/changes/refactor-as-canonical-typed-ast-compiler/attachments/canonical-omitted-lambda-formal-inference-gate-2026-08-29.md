# Canonical omitted-lambda formal inference gate (CTA-S62)

Date: 2026-08-29

## Scope

This gate closes the next bounded part of Tasks 4.3, 4.4, 5.2, 5.3, 5.9 and
13.2: a Lambda formal whose source type is omitted must become an exact
Canonical `ParamDecl` from the selected `funcdef` context, and every dependent
body fact must be reconciled by Sema before the AST becomes publishable.

Standalone remains explicitly deferred by user direction and is not changed or
run by this gate. The product default remains `LEGACY`. The retained native
`asCScriptNode` Lambda syntax is still available to LEGACY, syntax recovery,
differential/reference tooling and rollback, but it is not a semantic input to
the CANONICAL inference pass.

## AST-first gate card

### Source-path tests

- `ParserOmittedLambdaParameterInfersFuncdefAndRetypesBody`
  - host declaration: `funcdef bool BoolCallback(int)`
  - source shape:

    ```angelscript
    BoolCallback Stored = function(Value)
    {
        return Value > 0;
    };
    ```

  - required sealed facts:
    - the Lambda owns exactly one `ParamDecl` named `Value`;
    - that declaration has source-level `int` with no synthetic Runtime ABI
      `const` qualifier;
    - the Lambda return type is the target `bool`;
    - the reachable `DeclRef(Value)` resolves to that exact `ParamDecl` and has
      the same `int` `QualType`;
    - the reachable `Binary(>)` has `bool` type and consumes the resolved
      parameter reference;
    - the `ReturnStmt` consumes that exact comparison rather than a stale
      recovery wrapper;
    - the Lambda stable signature contains `(int)` and records the exact
      `BoolCallback` stable dependency;
    - no unresolved/pending-formal diagnostic remains.

- `ParserCallArgumentOmittedLambdaParameterInfersFuncdefAndRetypesBody`
  - same body, but the target `BoolCallback` is supplied by an ordinary call
    formal rather than a local initializer;
  - proves that inference is contextual conversion authority, not a local
    declaration-parser special case.

### Required downstream evidence

- focused RED for both new methods before production changes;
- focused GREEN after implementation;
- complete `SemaAuthority` prefix;
- Parser declarations, Frontend type surface, ProductionCodeGen, Module
  Snapshot and TypedASTJIT regression matrix;
- Runtime/Editor build;
- static scans proving no Parser node, Builder pointer, Runtime pointer,
  numeric TypeId, HIR or backend semantic replay enters the new contract;
- strict OpenSpec validation and `git diff --check`.

## Intended ownership model

1. Parser publishes every Lambda formal name and range through a pointer-free
   action. An omitted type is represented by the construction-only
   `typeOmitted` syntax fact plus an invalid `QualType`, never by absence of a
   declaration and never by interning or persisting an `ERROR` type.
2. Sema creates the `ParamDecl` before parsing the body, so lexical lookup owns
   the exact parameter identity even while its type is pending.
3. Contextual conversion resolves the complete target `funcdef` signature.
4. Sema replaces only omitted formal types, validates explicitly authored
   formals, rebinds/retypes the Lambda body, reconciles return conversion and
   removes only diagnostics attributable to the pending formal.
5. `FinishDecl`, dependency publication, verifier, lifetime planning and freeze
   occur after those facts are exact.
6. Bytecode and TypedASTJIT consume the frozen result mechanically. They do not
   infer Lambda formals or revisit native syntax.

## Non-claims

- This gate does not yet close Lambda-to-funcdef viability during overload
  ranking. An incompatible contextual target must already fail closed, but
  choosing among multiple funcdef-shaped overload candidates remains a later
  AST-first gate.
- It does not remove the LEGACY compiler or the native AngelScript AST.
- It does not change the product default to CANONICAL.
- It does not claim Tasks 4.3, 4.4, 5.2, 5.3, 5.9 or 13.2 complete.

## Evidence log

### RED

The test-only build passed before any production change:

- `Saved/Build/cta-s62-omitted-lambda-red-build/20260829_114347_132_a51d0f98`

The first attempted focused target omitted CQTest's generated class segment and
matched zero tests. It is execution-configuration evidence only and is not
counted as RED:

- `Saved/Tests/cta-s62-omitted-lambda-local-red/20260829_114416_381_59457d2f`
- missing segment:
  `FCanonicalASTSemaAuthorityTests`

The corrected source-path run found both tests and failed both for the expected
missing semantic behavior:

- `Saved/Tests/cta-s62-omitted-lambda-red-corrected/20260829_114505_206_9d568816`
- result: **0/2 PASS, 2/2 FAIL, zero skipped**
- both graphs contained no Lambda `ParamDecl`;
- both Lambda stable keys were `...::<lambda>()@...` rather than `(int)`;
- both Lambda declarations retained recovery return type `int`;
- both body `DeclRef(Value)` nodes had no resolved declaration;
- both Sema instances retained
  `unresolved-identifier:Value: 'Value' is not declared`;
- contextual conversion nodes to `BoolCallback` existed, proving that the
  failure is specifically omitted-formal/body inference rather than absence of
  the target conversion site.

Production remains unchanged at this RED checkpoint.

### Implemented ownership

- `asSParameterDeclAction` now carries `typeOmitted`; Parser emits an action for
  every Lambda formal even when there is no source type node.
- `ActOnParameterDeclAction` accepts an invalid `QualType` only for an omitted
  formal owned by a Lambda, creates its exact `ParamDecl` before body parsing,
  and records that declaration identity in the transient Lambda syntax fact.
  A normal function, method, import or funcdef cannot use this construction
  escape hatch.
- The initial gate card proposed a named pending Canonical type. Implementation
  review rejected that representation because an interned `ERROR` type could
  accidentally survive into stable identity, snapshots or backend input. The
  final design keeps pendingness only in Parser/Sema transient state. The
  verifier therefore fails closed if contextual Sema does not replace the
  invalid `QualType` before seal.
- `ContextualizeLambdaToFuncdef` validates the exact omitted-declaration set and
  parameter count. It replaces only omitted formal types; explicitly authored
  formal types still require an exact Canonical match or the existing Runtime
  ABI-normalized match.
- `asCRuntimeTypeBridge::FromScriptParameterABI` is the narrowly scoped inverse
  boundary used when the target is a live host funcdef rather than an exact
  Canonical `FuncDefDecl`. It removes Runtime-only primitive value constness,
  reverses the live `const T&inout` normalization for value-object by-value
  parameters, and preserves explicit `in`, `out` and `inout` direction bits.
- `ReconcileContextualLambdaBody` walks only the statements and expressions
  reachable from that Lambda's exact body and does not enter nested Lambda
  bodies. It retypes only `DeclRef` nodes bound to that Lambda's own
  `ParamDecl`s, removes only exact-range unresolved-identifier diagnostics,
  recomputes reachable primitive binary parents, and reconciles return
  conversions before `FinishDecl` recomputes the stable Lambda signature.
- Named inferred types and the target funcdef stable key are recorded as Lambda
  dependencies. Bytecode, TypedASTJIT, snapshots and Cache receive only the
  sealed result and contain no pending-formal replay.

### Issues found and disposition

1. **Focused RED target matched zero CQTest methods.** The first command omitted
   the generated `FCanonicalASTSemaAuthorityTests` class segment. It is retained
   above as execution-configuration evidence only; the corrected command found
   and failed both intended tests.
2. **A pending type must not become durable Canonical identity.** The initial
   named-pending-type idea was replaced with an invalid construction-time
   `QualType` plus an explicit transient omission bit. This keeps the sealed AST
   free of an artificial error/pending type and makes a missing context fail the
   verifier.
3. **Runtime funcdef shells lose one source distinction.** A live value-object
   by-value parameter and an explicitly authored `const T&inout` parameter can
   both appear as Runtime `const T&inout`. The inverse bridge must select the
   normal source-level by-value interpretation. Whenever an exact Canonical
   `FuncDefDecl` exists it remains authoritative and preserves the distinction;
   the Runtime shell is only the compatibility boundary for host funcdefs.
4. **The first full SemaAuthority GREEN exposed a bodyless direct-Sema
   regression.** `SemaCanonicalFuncdefContextuallyBindsLambdaWithoutRuntimeTypeLookup`
   deliberately constructs a fully explicit Lambda signature without a body.
   The first implementation rejected every bodyless Lambda and produced
   **417/418 PASS**. The rule is now precise: a body is mandatory only when at
   least one formal type was omitted; fully explicit direct-Sema signature
   fixtures remain valid.

### GREEN and regression evidence

Runtime/Editor builds:

- first complete implementation build:
  `Saved/Build/cta-s62-omitted-lambda-green-build/20260829_115727_519_de72ee0d`
- incremental build after the bodyless-explicit regression fix:
  `Saved/Build/cta-s62-explicit-bodyless-fix-build/20260829_115956_126_9a8871fd`
- final post-regression Runtime/Editor build:
  `Saved/Build/cta-s62-omitted-lambda-final-build/20260829_120743_467_85b4814d`
  — succeeded; UBT reported the target up to date against the already-built
  implementation.

Focused and authority tests:

- two new source-path methods:
  `Saved/Tests/cta-s62-omitted-lambda-green/20260829_115807_865_68f9946b`
  — **2/2 PASS**;
- first SemaAuthority run, retained as regression evidence:
  `Saved/Tests/cta-s62-sema-authority/20260829_115845_250_9428a55f`
  — **417/418 PASS**, only the fully explicit bodyless direct-Sema fixture
  failed;
- two new methods plus the bodyless direct-Sema fixture after the fix:
  `Saved/Tests/cta-s62-bodyless-regression-fix/20260829_120010_038_ecd8f4df`
  — **3/3 PASS**;
- final complete SemaAuthority rerun:
  `Saved/Tests/cta-s62-sema-authority-rerun/20260829_120045_881_fd2f9809`
  — **418/418 PASS**, zero failures and zero skips.

Cross-surface regression:

- `Saved/Tests/cta-s62-omitted-lambda-cross-surface/20260829_120310_739_2099e3cc`
- result: **224/224 PASS**, zero failures and zero skips;
- covered Parser declarations, Frontend Canonical type/Sema surfaces,
  Canonical ProductionCodeGen, Module Canonical snapshots and all TypedASTJIT
  prefixes used by the preceding CTA-S61 gate.

Static boundary review:

- `typeOmitted`, `omittedParameters`, `ReconcileContextualLambdaBody` and
  `FromScriptParameterABI` have no consumer in Bytecode, StaticJIT, snapshot,
  Cache or provider code;
- Canonical Sema and the Runtime type bridge add no `as_compiler.h` include;
- the only `asCScriptNode` match in the changed Sema surface is an explanatory
  comment stating that reconciliation does not revisit it; no Builder/compiler
  pointer or numeric Runtime TypeId was added to the new action/state contract;
- no HIR/`TypedSemanticIR` file was added and the production HIR file count
  remains zero;
- native `as_scriptnode.h`, `as_builder.h` and `as_compiler.h` remain present
  for LEGACY, syntax/recovery, reference/differential tooling and rollback;
- default LEGACY selection and the absence of a production `dual` backend are
  unchanged.

Final repository checks:

- plugin implementation commit:
  `4c43c35 [CanonicalAST] Fix: infer omitted lambda formal types`;
- `openspec validate refactor-as-canonical-typed-ast-compiler --strict`:
  valid;
- plugin and parent `git diff --check`: pass.
