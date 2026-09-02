# Wave B — canonical CodeGen consumes the sealed-publication gate

Worktree: `D:\as-cta`
Change: `refactor-as-canonical-typed-ast-compiler`
Date: 2026-08-23

This is the consumer follow-up to
`wave-b-publication-required-targets.md`. It does **not** make CANONICAL the
default compiler, and it does not change Sema recovery or ordinary `Seal()`.

## Decision and resulting boundary

`asCBytecodeCodeGen::Generate()` promised in its public header to accept only
a "sealed verified AST", but it had only checked `context.IsSealed()`. A graph
could therefore be immutable and structurally well-formed while an executable
expression still had no semantic target.

`Generate()` now calls `asCASTVerifyPublication()` before it computes
function-like declarations, creates a builder/type bridge, registers a type,
allocates a global, or publishes a function.

```text
Parser / Sema recovery
    unresolved call stays CALL + ERROR type + no invented resolvedDecl
    asCASTVerify() and Seal() remain permissive

canonical CodeGen publication
    asCBytecodeCodeGen::Generate()
        -> asCASTVerifyPublication()
             sealed + structural integrity
             CALL / CONSTRUCT / DECL_REF each require resolvedDecl
        -> only then type/global/function registration and bytecode emission
```

The verifier category is propagated verbatim. In particular,
`asAST_VERIFY_DANGLING_ID` is an enum category with value `1`, not a generic
negative AngelScript compiler error. This preserves the existing unsealed
contract (`asAST_VERIFY_UNSEALED_PUBLICATION`) and gives callers the exact
publication reason. Production builder callers already treat **any non-zero**
`Generate()` result as failure.

## Test-first implementation

`CodeGenRejectsSealedPublicationMissingCallTargetBeforeMutation` was added to
the CodeGen transaction suite first. It directly creates this graph:

```text
translation unit
  function int F
    return CALL:int              <- no resolvedDecl
```

The graph seals successfully by design. Before the implementation, CodeGen
did not return `asAST_VERIFY_DANGLING_ID`, making the new expectation a true
red test. The test snapshots all module and engine function/global/funcdef/type
tables before the call and requires the snapshot to be unchanged afterwards.

The first consumer run also exposed three older transaction fixtures that used
an unresolved `CONSTRUCT` merely to force a late lowering failure. They are no
longer valid inputs to the lowering phase: the new boundary correctly rejects
them first. Their assertions and names now state the stronger contract:

- a missing construct target returns `asAST_VERIFY_DANGLING_ID`;
- the rejection happens before global/function/FuncPtr-related mutation; and
- a clean graph can subsequently be generated into the same module.

This deliberately does **not** pretend that these fixtures still cover
post-registration artifact rollback. A separate transaction test must use a
fully publication-valid graph whose lowering fails later when that specific
rollback behavior is next extended.

## Changed implementation surface

- `ThirdParty/angelscript/source/as_bytecode_codegen.cpp`
  - includes `as_ast_verifier.h`;
  - replaces the `IsSealed()`-only early return with
    `asCASTVerifyPublication()` and preserves its category as `error`.
- `AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp`
  - adds the missing-CALL target/no-mutation regression;
  - updates three deliberately unresolved-CONSTRUCT fixtures to test the
    earlier, exact publication rejection.

No parser route, `asCSema` recovery rule, legacy compiler route, cache DTO, or
compiler selection flag changed.

## Evidence

| Stage | Result |
| --- | --- |
| Test-source build (RED) | `Saved/Build/build/20260823_033146_455_67ac5ca1` — succeeded; known fixture warnings only |
| Transaction RED | `Saved/Tests/cta-codegen-publication-gate-red/20260823_033206_138_1be3d475` — **8 total, 7 passed, 1 failed**; only the new missing-CALL expectation failed |
| Runtime implementation build | `Saved/Build/build/20260823_033255_129_07580e15` — succeeded |
| Final build | `Saved/Build/build/20260823_033523_095_bf20f9a6` — succeeded; known fixture warnings only |
| Transaction GREEN | `Saved/Tests/cta-codegen-publication-gate-transaction-green-v2/20260823_033540_050_72ec00c9` — **8/8 PASS** |
| ProductionCodeGen | `Saved/Tests/cta-codegen-publication-gate-production/20260823_033618_378_04f3a920` — **53/53 PASS** |
| Compiler | `Saved/Tests/cta-codegen-publication-gate-compiler/20260823_033657_097_07bc666c` — **518/518 PASS** |

The transient consumer-integration run that first exposed the three stale
`< 0` assumptions is retained at
`Saved/Tests/cta-codegen-publication-gate-transaction-green/20260823_033308_066_80050723`.
It is diagnostic evidence, not a final green result.

## Deliberate non-claims

- `asCASTVerify()` and `Seal()` still permit unresolved recovery nodes; do not
  move this requirement into either API.
- The publication verifier still does not prove expression reachability or
  ownership, cycle freedom, callee kind/signature/receiver/argument plans,
  complete cleanup/lifetime facts, or error-node rejection.
- Passing the gate proves only that the currently supported canonical CodeGen
  fixtures carry these three target identities. It is not full-language CodeGen
  coverage and is not a Sema-environment or HIR authority claim.
- LEGACY `asCCompiler` remains the product default. No default routing,
  `CompileFunction` provenance, Cache V2 DTO, StaticJIT, or public snapshot
  work is closed by this increment.
- Tasks 13.5, 13.2, 5.5, 5.6, and 9.4 remain unchecked.
