# Canonical lexical value cleanup-plan gate (CTA-S44, 2026-08-28)

## Result

CTA-S44 closes one concrete part of the lifetime critical path: initialized
lexical value-object locals with an exact Canonical destructor now carry
explicit reverse-live `scope-exit` cleanup plans in the sealed Canonical AST.
The plans cover normal block exit and transfers that leave the block. Canonical
CodeGen consumes those plans directly and retires the corresponding normal-path
object state so the function epilogue cannot destroy the same live object a
second time.

This is not completion of Tasks 5.7 or 5.8. Deferred/out values, global
initialization and shutdown, exception-only paths, suspend/resume lifetimes,
owning handle/reference cleanup, and the complete active language matrix
remain open. The default compiler pipeline remains LEGACY.

## Sealed AST contract

`asCSema::ActOnBlockStatementAction` now identifies direct block-local
variables that satisfy all of the following:

- the declaration is a `VAR` with an initialization plan;
- its type is a non-handle `VALUE_OBJECT` after the bounded typedef probe;
- the Canonical declaration graph contains an exact destructor for the value
  type.

For those variables, Sema publishes cleanup in two places:

1. Normal block exit receives one `ExprStmt(Cleanup(scope-exit,
   DeclRef(local)))` for each still-live direct local, in reverse declaration
   order.
2. `return`, and `break`/`continue`/`fallthrough` whose target lies outside the
   current block subtree, receive their own cleanup statement children in the
   same reverse declaration order.

Every transfer-site cleanup is a distinct statement/expression identity. A
single mutable node is never shared by multiple structural owners. Nested
blocks finalize from the inside out, so an early return from the inner block
observes `inner-last -> inner-first -> outer-last -> outer-first`.

The representative authority fixture seals this order:

```text
outer block
  Decl Outer
  inner block
    Decl First
    Decl Second
    Return
      Cleanup Second
      Cleanup First
      Cleanup Outer
    Cleanup Second
    Cleanup First
  Return
    Cleanup Outer
  Cleanup Outer
```

The native AngelScript `asCScriptNode` tree is still built for syntax/recovery,
explicit LEGACY compilation, reference and differential tests. It does not
supply the cleanup plan after seal.

## CodeGen consumption and no-double-destruction rule

`asCBytecodeCodeGen` treats a sealed `Cleanup` expression whose literal is
`scope-exit` as an executable destructor operation. It requires:

- one exact `DeclRef` target;
- the target's allocated object slot;
- an exact resolved destructor declaration and Runtime function;
- Runtime object ownership compatible with the target slot.

Normal-path cleanup marks the object entry dead after emitting the destructor
call. This prevents the existing function epilogue from destroying it again.
Transfer-site copies do not globally retire compile-time state, because other
control-flow paths may still reach their own normal cleanup. Return,
fallthrough, break and continue emit their sealed cleanup children before the
transfer. Existing foreach loop cleanup frames remain a separate structured
loop mechanism and are not silently substituted for the new lexical plan.

The execution fixture runs both early-return and normal-return branches. Each
branch constructs three native value objects, returns `42`, and observes
exactly three destructor calls. It also asserts the Canonical publisher and
zero legacy compiler invocations.

## Verifier firewall

Every `Cleanup` expression tagged `scope-exit` is now rejected before any
consumer sees it unless all of these facts are true:

- `resolvedDecl` is an exact destructor;
- the expression has exactly one `DeclRef` child;
- the child resolves to a `VAR`;
- the variable has `VALUE_OBJECT` identity;
- the variable's stable type identity matches the destructor owner.

Stable detail tokens are:

- `scope-exit-cleanup-dtor`;
- `scope-exit-cleanup-target`;
- `scope-exit-cleanup-type`.

The RED/GREEN verifier fixture forges a cleanup targeting
`FExpectedScopeValue` while resolving `~FWrongScopeValue`; it changes from the
expected verifier failure to a complete **31/31 PASS** verifier prefix after
the firewall is implemented.

## Prepared generated-destructor publication issue

The first complete ProductionCodeGen regression run was **114/115**. The only
failure was
`PreparedGeneratedAccessorClosurePublishesCallableMethods` with
`EmitScopeExitCleanup` returning `asNO_FUNCTION`.

Root cause: prepared Builder compilation already let Canonical Sema create a
generated destructor declaration for a script value type, but detached
Canonical CodeGen only prepared Runtime shells for generated accessors. The
old function-epilogue behavior silently skipped the missing destructor;
explicit sealed cleanup correctly exposed the incomplete artifact.

The fix generalizes `pendingGeneratedAccessorDecls` to
`pendingGeneratedObjectFunctionDecls`. Generated accessors and generated
destructors are now allocated, emitted, resolved and attached in the same
unpublished artifact as lambdas and global initializers. The existing
transactional commit still attaches the destructor behavior only after every
body and relocation succeeds. Failure abandons the candidate rather than
publishing a partial type.

The strengthened regression now directly proves that:

- the generated function is published as `asBEHAVE_DESTRUCT`;
- the prepared entry function calls that exact destructor ID;
- generated getter/setter publication and execution still work.

## TDD and regression evidence

### Authority RED and GREEN

- RED test build PASS:
  `Saved/Build/cta-s44-lexical-cleanup-plan-red-build/20260828_071036_861_54326709/RunMetadata.json`;
- expected missing-contract RED **0/1**:
  `Saved/Tests/cta-s44-lexical-cleanup-plan-red/20260828_071106_212_c7627a7e/RunMetadata.json`;
- implementation build PASS:
  `Saved/Build/cta-s44-lexical-cleanup-plan-build-1/20260828_071319_822_5cbdbe24/RunMetadata.json`;
- focused authority **1/1 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-plan-green-1/20260828_071334_323_864c45d1/RunMetadata.json`;
- first complete SemaAuthority **394/394 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-plan-sema-full-1/20260828_071456_918_7c9050b7/RunMetadata.json`.

### Verifier RED and GREEN

- RED verifier test build PASS:
  `Saved/Build/cta-s44-scope-exit-verifier-red-build/20260828_071733_783_2aa2ddc7/RunMetadata.json`;
- expected class-prefix RED **30/31**, with only the new forged-type test
  failing:
  `Saved/Tests/cta-s44-scope-exit-verifier-red-class/20260828_071824_047_c38bdf49/RunMetadata.json`;
- verifier implementation build PASS:
  `Saved/Build/cta-s44-scope-exit-verifier-green-build/20260828_072104_212_02aebb58/RunMetadata.json`;
- complete verifier prefix **31/31 PASS**:
  `Saved/Tests/cta-s44-scope-exit-verifier-green-class/20260828_072221_885_fe1cfeb8/RunMetadata.json`.

### Runtime exact-once and regression closure

- exact-once test build PASS:
  `Saved/Build/cta-s44-lexical-cleanup-runtime-build/20260828_072536_191_d49ace04/RunMetadata.json`;
- exact-once execution **1/1 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-runtime-focused/20260828_072853_437_71a5c242/RunMetadata.json`;
- first complete ProductionCodeGen **114/115**, exposing the missing prepared
  generated-destructor shell:
  `Saved/Tests/cta-s44-lexical-cleanup-production-full/20260828_072925_652_ae67d44a/RunMetadata.json`;
- generated-destructor closure build PASS:
  `Saved/Build/cta-s44-prepared-generated-dtor-build/20260828_073439_094_e5dc1705/RunMetadata.json`;
- exact previously failing regression **1/1 PASS**:
  `Saved/Tests/cta-s44-prepared-generated-dtor-focused/20260828_073452_428_c81a4dba/RunMetadata.json`;
- first repaired complete ProductionCodeGen **115/115 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-production-full-2/20260828_073602_958_72792c1e/RunMetadata.json`;
- final SemaAuthority **394/394 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-sema-full-final/20260828_073717_442_fd6463e3/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode
  downstream gate **159/159 PASS**:
  `Saved/Tests/cta-s44-lexical-cleanup-secondary-gates/20260828_074313_559_241b64f9/RunMetadata.json`;
- strengthened generated-destructor contract build PASS:
  `Saved/Build/cta-s44-generated-dtor-contract-final/20260828_075948_648_55a6c899/RunMetadata.json`;
- direct generated-destructor publication/call assertion **1/1 PASS**:
  `Saved/Tests/cta-s44-generated-dtor-contract-focused-final/20260828_080026_587_a647b6f2/RunMetadata.json`;
- final complete ProductionCodeGen **115/115 PASS**:
  `Saved/Tests/cta-s44-production-full-final/20260828_080135_903_de82f8e9/RunMetadata.json`.

## Tooling and false-evidence record

Two invocations are deliberately excluded from semantic evidence:

1. The first CTA-S44 test command used the runner's nonexistent `-Target`
   parameter instead of `-TestPrefix`. It failed before selecting a test and
   therefore is neither RED nor GREEN evidence.
2. The first exact verifier filter omitted the CQTest class segment and
   selected zero tests:
   `Saved/Tests/cta-s44-scope-exit-verifier-red/20260828_071748_850_c08b7772/RunMetadata.json`.
   The stable class-prefix rerun produced the real **30/31 RED**.

An accidental duplicate `TEST_METHOD` line was removed before compilation and
did not produce a build result. These records remain here to prevent a future
progress report from counting an invalid selection or test-authoring edit as
product evidence.

## Remaining lifetime boundaries

The following work still blocks Tasks 5.7/5.8 and default cutover:

1. deferred/out argument and returned-temporary cleanup;
2. global initialization, failed initialization and shutdown destruction;
3. exception-edge cleanup encoded in the sealed AST rather than relying only
   on VM `ObjInfo` metadata;
4. suspend/resume and coroutine-frame lifetime ownership;
5. owning handle/reference/funcdef locals, whose release route is distinct
   from a value-object destructor call;
6. complete loop/switch/transfer combinations and live/dead-path matrices;
7. direct TypedASTJIT/AOT consumption of the same cleanup plan;
8. final full SDK, Cache, Hot Reload, StaticJIT, Standalone and configured All
   gates after the remaining implementation work.

The source grammar intentionally limits `typedef` to `PRIMTYPE`, so a
"typedef-wrapped value object" is not an active AngelScript source lifetime
family. It is excluded from this remaining-work list rather than being used to
justify an unreachable compatibility branch.

## Record validation

After the implementation and documentation updates:

- `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict`
  exits 0 with `Change ... is valid`;
- parent and plugin `git diff --check` both exit 0; they report only existing
  LF-to-CRLF conversion warnings;
- a direct trailing-whitespace scan of the six CTA-S44 production/test files
  returns no matches;
- this focused slice does not claim a fresh configured All, Standalone Release
  or StaticJIT matrix.

## Progress impact

No umbrella checkbox is closed. `tasks.md` therefore remains **87/125
(69.6%)**. The conservative weighted implementation estimate advances from
about **75% to 76%**, and safe default-CANONICAL readiness from about **48% to
49%**. Whole-Sema action-only authority remains about **98%** because this
slice closes lifetime facts for one important family but does not eliminate
the residual declaration/type/scope identity boundary or complete every
lifetime family.
