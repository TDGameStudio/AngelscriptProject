# Canonical AST traversal and parent/edge index — 2026-08-23

## Outcome

OpenSpec task 2.9 is complete. The canonical typed AST now has one internal,
standard-C++ read-only traversal substrate shared by debugging, verification,
dumping, tests, and one production TypedASTJIT analysis path. This is the first
implemented slice of the Clang-inspired observability plan; it does not claim
that the later structured dump, matcher, path diagnostic, or command surfaces
are complete.

Implemented files:

- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_traversal.h`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_traversal.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTTraversalTests.cpp`
- `Standalone/CMakeLists.txt` includes the same maintained traversal source.

Migrated consumers:

- `as_ast_verifier.cpp`: statement and expression structural-cycle detection.
- `as_ast_dump.cpp`: address-free flat compatibility dump inventory.
- `AngelscriptTypedASTJITCanonical.cpp`: canonical eligibility statement/
  expression walk.

## Why this follows Clang without copying Clang

The relevant Clang capabilities are `RecursiveASTVisitor` for one traversal
contract and `ParentMapContext` for an on-demand reverse index. AngelScript's
graph is smaller and uses stable table IDs, so it does not need Clang's
generated visitor hierarchy or `DynTypedNode`. The implemented equivalent is:

```text
Clang                                         maintained AngelScript
-----                                         ----------------------
RecursiveASTVisitor                      ->   asIASTConstVisitor
TraverseDecl/Stmt/Type                   ->   asCASTTraverse / TraverseAll
DynTypedNode                             ->   asSASTNodeRef
child traversal customization           ->   ShouldTraverseEdge
ParentMapContext                         ->   asCASTParentEdgeIndex
AST node ownership tree + semantic refs  ->   named structural/reference edge
```

The critical AngelScript-specific distinction is that containment and semantic
references are not interchangeable:

```text
structural / followed by default

TranslationUnit
  `- decl-child -> Function
       `- decl-body -> BlockStmt
            `- stmt-child -> ReturnStmt
                 `- stmt-expr -> CallExpr
                      |- expr-receiver -> receiver expression
                      `- expr-child[] -> argument expressions

reference / reported but not followed by default

Function --decl-type----------> Type
Function --decl-parent--------> TranslationUnit
CallExpr --expr-type----------> Type
CallExpr --resolved-decl------> Function
Stmt     --owner--------------> Function
Stmt     --control-target-----> Loop/Switch
```

If `resolved-decl` were treated as containment, a call inside a function body
would walk back into the function declaration and body, creating a false
cycle. The parent index therefore finds a parent only from incoming structural
edges while still exposing all incoming reference edges for diagnostics and
queries.

## API and behavior

`asSASTNodeRef` represents Decl, Type, Stmt, and Expr IDs without storing raw
node pointers. `asSASTTraversalEdge` records source, target, structural versus
reference class, a stable role, and the source-array index where applicable.

The traversal provides:

- deterministic `EnterNode -> VisitEdge -> child -> LeaveNode` order;
- a single-root walk and a complete-context forest walk;
- one-visit behavior for complete-context traversal while every incoming edge
  remains observable;
- default structural-only descent with optional reference following;
- consumer-controlled edge descent through `ShouldTraverseEdge`;
- optional target validation so diagnostic dump can inventory a malformed
  graph without truncating at its first dangling edge;
- explicit depth, node-budget, cycle, invalid-node, and callback-abort results;
- an offending node and offending named edge in failure results.

Array edge slots and optional scalar edges intentionally differ. An invalid
scalar field means “no optional edge”; an invalid ID already stored in a
`children`, `bases`, `captures`, or `inits` array is a real malformed edge and
is retained so traversal can report it. A regression caught and fixed the
initial implementation incorrectly skipping array `ID=0` slots.

`asCASTParentEdgeIndex::Build()` refuses an unsealed context. A successful
index is tied to the lifetime of that immutable context and stores flattened,
deterministic incoming-edge ranges by node class and table ID. It supports:

- `GetIncomingEdgeCount` / `GetIncomingEdge` for structural and reference
  edges;
- `GetStructuralParent` for the unique containment parent;
- fail-closed behavior when no unique structural parent exists.

No index becomes a Cache input, public SDK ABI, or mutable AST owner.

## Consumer migrations

### Verifier

The old separate `VisitStmtCycle` and `VisitExprCycle` recursive functions were
removed. Two filtered shared traversals now follow only `stmt-child`, or only
`expr-child` plus `expr-receiver`, preserving the verifier's existing ordering
and stable detail tokens `stmt-cycle` / `expr-cycle`. Other semantic checks
remain in their current explicit passes; task 2.11 will enrich their paths and
local subtrees.

### Flat compatibility dump

The existing textual format and table order remain unchanged. Dump now obtains
its Decl/Stmt/Expr inventory from a non-descending complete-context traversal.
It disables target validation deliberately, so a dump-on-verify-fail still
prints nodes after a dangling edge. Task 2.10 will build tree text and JSON on
the same edge model rather than changing this compatibility format.

### TypedASTJIT eligibility

The hand-written recursive `WalkExpr` body was removed and `WalkStmt` now uses
an `asIASTConstVisitor`. All reviewed statement/expression fallback categories
and source spans are retained. The prior walk visited call arguments but not
the separately stored receiver; the new visitor explicitly skips receiver
descent while still observing that named edge. This makes the compatibility
choice visible and keeps this infrastructure migration from silently changing
eligibility. A later semantic task can decide whether receiver eligibility
should expand, with its own tests and fallback review.

## TDD and debugging record

1. Baseline before edits: Frontend CanonicalAST **108/108 PASS**.
2. Initial RED: new traversal test failed compilation only because
   `source/as_ast_traversal.h` did not exist.
3. First implementation: build passed; focused traversal was **2/3**, with the
   test expectation missing legitimate `stmt-owner` and `decl-parent`
   reference edges. The expectation was corrected rather than removing those
   facts.
4. Full-context traversal RED/GREEN added one-visit inventory coverage.
5. Consumer edge-filter RED/GREEN added “observe edge but skip descent”.
6. Verifier, dump, and TypedASTJIT migrations passed Frontend **113/113** and
   complete TypedASTJIT **64/64**.
7. Self-review found array zero-ID slots were silently skipped. The new
   regression failed **0/1**, then passed **1/1** after array slots became real
   edges.
8. Depth and malformed-dump assertions completed guard/debug coverage.

The first Standalone run compiled the traversal successfully and passed 20/21,
but exposed a pre-existing task-8.4 architecture violation. The generation
snapshot correctly owned public V1 leases, while its lease-failure diagnostic
still called `GetCanonicalASTContext()` only to print `PendingCanonicalAST`.
Removing that raw read and field preserved the useful policy/publisher/purpose
diagnostics and made the final Architecture test pass.

## Fresh verification

| Gate | Result | Evidence |
| --- | ---: | --- |
| Runtime/Editor build | PASS | `Saved/Build/cta-ast-traversal-final-build/20260823_204601_678_646e312d/RunMetadata.json` |
| Frontend CanonicalAST | 114/114 PASS | `Saved/Tests/cta-ast-traversal-final-frontend/20260823_204623_655_2d132a7c/RunMetadata.json` |
| complete TypedASTJIT prefix | 64/64 PASS | `Saved/Tests/cta-ast-traversal-final-typedast/20260823_204709_053_8c637cde/RunMetadata.json` |
| Standalone CMake/CTest | 21/21 PASS | `Saved/StandaloneTests/cta-ast-traversal-final-standalone_01_Standalone/20260823_204912_638_e538219d/RunMetadata.json` |

## What remains

This substrate deliberately stops before later tooling tasks:

- 2.10: deterministic tree text, JSON, filters, source locations/snippets;
- 2.11: verifier root-to-node path, related target, bounded local subtree;
- 2.12: compact test matcher/assertion helpers and full semantic shadow diff;
- 2.13: developer/commandlet `list`, `dump`, `verify`, `query`, and `diff`
  operations over immutable snapshot leases.

Those features should consume this node/edge contract instead of adding new
per-tool recursion.
