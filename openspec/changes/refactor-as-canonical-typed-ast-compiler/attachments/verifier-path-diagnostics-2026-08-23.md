# Canonical AST verifier path diagnostics — 2026-08-23

## Outcome

OpenSpec task 2.11 is complete. Every verifier failure now keeps its existing
stable category, source range, and detail token while also carrying enough
deterministic context to locate and inspect the failure:

- offending Decl/Type/Stmt/Expr snapshot node and canonical kind;
- named edge role that triggered the failure;
- related target node and target kind, including dangling snapshot IDs;
- logical source key plus one-based line and column;
- deterministic TranslationUnit-to-node structural path;
- a bounded address-free local subtree.

Implemented files:

- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.h`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.cpp`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierDiagnosticTests.cpp`

## Compatibility contract

The original compatibility fields remain authoritative and unchanged:

```text
category = INVALID_CHILD
detail   = stmt-child
range    = snapshot-local source range
```

Existing manually constructed `asSAstVerifyResult` values still format to the
same one-line output when no enrichment is present. Results returned by
`asCASTVerify` or `asCASTVerifyPublication` append diagnostic facts and the
local subtree:

```text
VERIFY category=INVALID_CHILD detail=stmt-child range=1:9-1:11
  node=S1 kind=Block edge=stmt-child related=S99 relatedKind=Invalid
  source="Diagnostics/Diag.as" line=5 column=10
  path="D1/decl-child[0]/D2/decl-body[0]/S1"
DIAGNOSTIC_SUBTREE root=S1 maxNodes=8 maxEdges=16 maxDepth=3
node=S1 kind=Block
  edge=stmt-child[0] target=S99 targetKind=Invalid class=structural
```

The actual formatter emits the first diagnostic facts on one line for log
compatibility; the wrapped example above is only for readability.

## Clang comparison

Clang diagnostics commonly combine a stable diagnostic ID with source
locations, related declarations, parent/context navigation, and targeted AST
dumps. The maintained AngelScript equivalent now combines:

```text
Clang facility                         maintained AngelScript
--------------                         ----------------------
diagnostic ID / message           ->   category + stable detail token
SourceManager location            ->   logical source + line/column/range
Decl/Stmt pointer identity        ->   snapshot-local D/T/S/E label
parent/context navigation         ->   deterministic structural root path
related Decl/Stmt note            ->   named edge + related target
targeted AST dump                 ->   hard-bounded local subtree
```

Unlike Clang, this is not yet a rich source-note/fix-it engine and does not
construct CFG paths. It is intentionally a compact verifier diagnostic record
that later developer commands and test matchers can consume.

## Mutation and failure safety

Diagnostic enrichment is read-only. It does not seal, unseal, repair, reorder,
or publish the context. A dedicated publication test builds a structurally
valid sealed AST with an unresolved `CallExpr`, captures the flat dump and node
counts, invokes `asCASTVerifyPublication`, and proves all of the following:

- failure remains `DANGLING_ID` / `call-decl`;
- the offending node is the call and the edge is `expr-resolved-decl`;
- no target declaration is invented;
- the context stays sealed;
- Decl/Stmt/Expr counts are unchanged;
- the before/after flat dumps are byte-identical.

## Bounded bad-graph handling

The diagnostic layer must remain safer than the malformed graph it explains.
The local subtree therefore has independent hard bounds:

- at most 8 entered nodes;
- at most 16 reported edges;
- at most 3 structural levels below the root.

It reports `truncated=true` when any bound is hit. Dangling edges are printed
but never followed. Repeated/cyclic nodes are marked rather than recursively
expanded. Root-path search follows only valid structural edges, has a 256-level
depth guard and a context-sized visit budget, and falls back to
`unreachable:<node>` for detached malformed nodes. References such as owner,
target, type, and resolved declaration are diagnostics, not parent edges.

## Failure coverage

The new tests cover the required failure families, not just one happy-path
format:

| Family | Representative stable detail | Diagnostic relationship |
| --- | --- | --- |
| dangling child | `stmt-child` | `S1 --stmt-child--> S99` |
| foreign table identity | `expr-id` | offending `E1` |
| wrong node kind | `decl-kind` | offending `D2` |
| invalid owner | `stmt-owner` | `S1 --stmt-owner--> D99` |
| control target | `break-ancestor` | break to sibling loop |
| structural cycle | `stmt-cycle` | cycle-closing `stmt-child` edge |
| publication call target | `call-decl` | missing `expr-resolved-decl` target |
| cleanup target kind | `cleanup-dtor` | cleanup to non-destructor declaration |
| oversized malformed graph | `expr-decl` | subtree truncation and size bound |

All other existing verifier `Fail` sites were also assigned their natural
offending node, edge role, and related target where one exists; the enrichment
is not a detail-token lookup table or a test-only special case.

## TDD record

1. `AngelscriptNativeCanonicalASTVerifierDiagnosticTests.cpp` was added first.
   The RED build failed because the result had none of the new fields.
2. The result contract and failure-site metadata were implemented, followed by
   deterministic source/path/subtree enrichment and conditional formatting.
3. Focused diagnostics passed 4/4.
4. The first combined gate invocation was externally killed by the shell's
   120-second wrapper after 131 tests had passed and zero had failed. Its
   incomplete report is deliberately not completion evidence.
5. The same complete gate was rerun with the repository test runner's intended
   600-second budget and passed 145/145.
6. Standalone compiled the same maintained standard-C++ verifier/dump code and
   passed 21/21.

## Fresh verification

| Gate | Result | Evidence |
| --- | ---: | --- |
| Expected RED build | FAIL as expected: missing result fields | `Saved/Build/cta-ast-verifier-diagnostics-red/20260823_211425_049_669c66c8/RunMetadata.json` |
| Runtime/Editor build | PASS | `Saved/Build/cta-ast-verifier-diagnostics-green-build/20260823_212044_958_fc608908/RunMetadata.json` |
| Focused VerifierDiagnostics | 4/4 PASS | `Saved/Tests/cta-ast-verifier-diagnostics-green/20260823_212109_012_246d9e15/RunMetadata.json` |
| CanonicalAST + Module Snapshot + Cache ExactWarmStartup | 145/145 PASS | `Saved/Tests/cta-ast-verifier-diagnostics-final-gates-rerun/20260823_212444_968_8f2383c8/RunMetadata.json` |
| Standalone CMake/CTest | 21/21 PASS | `Saved/StandaloneTests/cta-ast-verifier-diagnostics-standalone_01_Standalone/20260823_212701_178_2f31e2db/RunMetadata.json` |

The complete 145-test gate comprises 121 current Frontend CanonicalAST tests,
9 public Module CanonicalAST Snapshot tests, and all 15 ExactWarmStartup tests,
including the fail-closed sidecar/verifier negative cases.

## What remains

- 2.12: compact typed test matchers and a full deterministic semantic shadow
  diff;
- 2.13: lease-safe developer/commandlet list, dump, verify, query, and diff
  operations;
- separate language-coverage work: Canonical Sema, CodeGen, Cache DTO, and JIT
  closures are not made complete by richer diagnostics.

This task materially improves diagnosis when AST-first gates fail, but does not
change the approximately 46% real default-cutover estimate.
