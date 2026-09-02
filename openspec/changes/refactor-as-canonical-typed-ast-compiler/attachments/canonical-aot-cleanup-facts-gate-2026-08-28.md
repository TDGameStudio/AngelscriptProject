# CTA-S49 — Canonical AOT cleanup-facts gate

Date: 2026-08-28

## Outcome

TypedASTJIT production diagnostics now derive a bounded lifetime fact directly
from the same sealed Canonical AST used by eligibility and C++ emission. A
function whose exact structural body contains no cleanup action is published
as `VerifiedEmpty`, with `bCleanupPlanCoversAllTransfers=true`. The result is
copied into pointer-free backend/provider diagnostics while the generation AST
lease is alive.

This closes a real diagnostic transport gap. It does **not** complete OpenSpec
Task 7.5: non-empty destructor/release plans, partial construction, exception
cleanup, suspension state, mutable globals/imports, call-site fallback and the
remaining provider dependency families are still open.

## Problem found

`FAngelscriptStaticJITCanonicalFunctionDiagnostic` already contained:

- `CleanupPlanState`;
- `bHasSuspendState`;
- `bHasExceptionCleanup`;
- `bCleanupPlanCoversAllTransfers`.

Provider copying and dump serialization also retained those fields, but
`BuildSemanticFunctionDiagnostic()` only populated function identity,
receiver, traits, eligibility and Canonical-AST verification. Consequently,
production TypedAST closures emitted the default `Unverified/false` lifetime
values even for scalar functions that had no cleanup action at all.

This was not a dump problem and did not require a HIR or bytecode bridge. The
missing edge was between the sealed AST consumer and the already pointer-free
diagnostic model.

## Architecture after the change

```text
same-generation AST snapshot lease
        |
        v
sealed asCASTContext + exact FunctionDecl
        |
        +--> eligibility / call closure / C++ emission
        |
        +--> shared asCASTTraverse structural lifetime visitor
                    |
                    v
          pointer-free CanonicalLifetimeFacts
                    |
                    v
       backend result -> generated provider diagnostics -> dump observer
```

Important boundaries:

1. The visitor accepts only a sealed context and one exact `FunctionDecl`.
2. It uses structural `asCASTTraverse`; it does not inspect bytecode, dump text,
   native syntax nodes or a reconstructed HIR.
3. A malformed/dangling/unsealed graph returns `Unverified`.
4. No `asCASTContext*`, AST node pointer or snapshot lease escapes in the
   returned fact object or provider binding.
5. `VerifiedEmpty` is published only after a successful complete traversal
   finds no `asAST_EXPR_CLEANUP` action. With no action to schedule, every
   return/break/continue path is vacuously covered.
6. Any non-empty cleanup remains `Unverified` in this slice. The implementation
   deliberately does not infer `ScriptDestructor`, `PartialConstruction`,
   `CompilerExceptionRegion`, exception cleanup or suspend state without the
   later action/liveness proofs required by Tasks 5.8 and 7.5.

## Implementation

- `AngelscriptTypedASTJITModel.h` owns the pointer-free
  `FAngelscriptTypedASTJITCanonicalLifetimeFacts` result.
- `AngelscriptTypedASTJITCanonical.h/.cpp` exposes and implements
  `AnalyzeAngelscriptTypedASTJITCanonicalLifetimeFacts()`.
- The implementation traverses the exact function body through the shared AST
  traversal and recognizes the one currently provable state: verified empty.
- `AngelscriptTypedASTJITBackend.cpp` copies the facts only after the exact AST
  is verified sealed and the exact declaration exists.
- `AngelscriptTypedASTJITBackendDependencyTests.cpp` verifies the real
  production recursion root/helper closure diagnostics, rather than testing a
  hand-filled diagnostic row.

## TDD and validation evidence

### Invalid selection, excluded

The first command attempted to select a CQTest method without its generated
class segment:

```text
Angelscript.TestModule.StaticJIT.TypedASTJIT.Dependencies.Backend.ValidDirectClosuresUseTypedBackendWithCompilerSignatureOnly
```

It matched zero tests and is not RED or product evidence:

`Saved/Tests/cta-s49-aot-cleanup-facts-red/20260828_130109_695_6211d294/RunMetadata.json`

### Clean RED

The class prefix selected two real tests. One passed and the new production
diagnostic assertion failed because `TypedASTSelfRecursion` remained
`Unverified`:

```text
total=2 passed=1 failed=1 skipped=0
```

Evidence:

`Saved/Tests/cta-s49-aot-cleanup-facts-red-class/20260828_130246_857_ed36f7f9/RunMetadata.json`

### GREEN

- Runtime/Editor Development build: PASS
  - `Saved/Build/cta-s49-aot-cleanup-facts-green-build/20260828_130529_075_6b6849b1/RunMetadata.json`
- Backend dependency class: **2/2 PASS**
  - `Saved/Tests/cta-s49-aot-cleanup-facts-green-class/20260828_130559_400_6beb809c/RunMetadata.json`
- CanonicalASTMigration: **11/11 PASS**
  - `Saved/Tests/cta-s49-canonical-ast-migration-regression/20260828_130646_649_b283ed0c/RunMetadata.json`
- Complete TypedASTJIT: **40/40 PASS**
  - `Saved/Tests/cta-s49-typed-ast-jit-regression/20260828_130718_746_0c07ca89/RunMetadata.json`
- Parent/plugin `git diff --check`: PASS; only existing line-ending notices
  were printed.

The build retains pre-existing C4191 function-pointer cast warnings and the
pre-existing possible-uninitialized `DividePosition` warning. Neither was
introduced by this slice.

## Progress accounting and remaining work

No umbrella task is checked. Mechanical progress remains **88/125 (70.4%)**.
Weighted implementation remains **about 78%**. This production AOT lifetime
transport moves the direct Canonical-AST AOT estimate from about **55% to
about 57%**; Canonical Bytecode/Runtime remains about **74%**, safe default
readiness about **50%**, and action-only Sema authority about **98%**.

The next Task 7.5 slices should proceed in this order:

1. classify exact non-empty `scope-release` and destructor cleanup actions;
2. prove cleanup liveness and ordering over all transfer edges;
3. add partial-construction and exception-region facts;
4. add suspend/resume frame ownership facts;
5. complete mutable-global/import eligibility and remaining provider
   dependency publication;
6. rerun full StaticJIT and the default/cutover matrices before considering
   Task 7.5 complete.

The product default remains LEGACY. The original AngelScript native AST,
Builder and Compiler remain retained for Parser/recovery/LEGACY/reference use;
TypedSemantic HIR remains physically deleted.
