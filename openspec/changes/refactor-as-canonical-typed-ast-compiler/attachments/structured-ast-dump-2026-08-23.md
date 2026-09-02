# Canonical AST structured inspection — 2026-08-23

## Outcome

OpenSpec task 2.10 is complete. The sealed Canonical Typed AST now has a
deterministic structured diagnostic surface in addition to the original flat
compatibility dump:

- hierarchical text (`AST_TREE`);
- valid deterministic JSON;
- exact filters for module name, stable declaration key, node class/ID,
  canonical node kind, and logical source key;
- structural filter closure: ancestors plus the matching node's structural
  subtree;
- semantic reference visibility without pulling the referenced declaration's
  subtree into a filtered result;
- canonical type key/kind/qualifiers, declaration traits, named structural and
  reference edges, resolved target identity, logical source, line/column/end
  position, and bounded optional source snippets.

Implemented files:

- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.h`
- `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp`
- `Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTStructuredDumpTests.cpp`

The existing `asCASTDump()` flat format is preserved. The new entry point is
`asCASTStructuredDump(context, options, out)` and accepts only a sealed,
immutable context.

## Clang comparison and deliberate scope

This slice corresponds to the useful core of Clang's text AST dumper,
`JSONNodeDumper`, and `-ast-dump-filter`, but uses the maintained AngelScript
node/edge contract rather than copying Clang's much larger generated node
hierarchy:

```text
Clang                                      maintained AngelScript
-----                                      ----------------------
ASTDumper text tree                   ->   AST_TREE
JSONNodeDumper                        ->   deterministic JSON
-ast-dump-filter                      ->   structured exact filters
SourceManager source ranges           ->   logical key + line/column + snippet
Decl/Stmt child traversal             ->   named structural edges
DeclRefExpr/callee/type links          ->   named reference edges + target facts
pointer-shaped diagnostic identity     ->   snapshot-local D/T/S/E labels only
```

It deliberately does not implement Clang's full AST Matcher DSL, CFG dump,
redecl/context machinery, template specialization graph, or serialized AST
schema. Compact typed test matchers and full semantic diff remain task 2.12;
developer `list/dump/verify/query/diff` command surfaces remain task 2.13.

## Output contract

Both formats begin with or contain these explicit facts:

```text
schema=as-canonical-ast-diagnostic-v1
diagnosticOnly=true
cacheInput=false
```

The schema label gives tools a way to identify the diagnostic layout, but it
is not a persistence promise. In particular, the structured dump:

- is not serialized into Cache V2;
- is not hashed into a cache key, semantic key, module identity, or JIT key;
- contains no raw addresses, Engine-local `typeId`/function IDs, or mutable
  context pointers;
- does not replace `ASTBodySidecar` DTO encoding;
- may evolve when diagnostic/tooling needs change.

Node labels are deterministic snapshot-table labels (`D1`, `T1`, `S1`,
`E1`). Resolved references carry target class, kind, name, and stable key. This
keeps a filtered call expression useful even if its callee declaration is an
excluded sibling.

## Filter closure

Filters other than module are combined with exact AND semantics. A match is
expanded only through structural ownership:

```text
TranslationUnit D1                         retained ancestor
  |- Helper D2                             excluded sibling
  `- Function D3                           matching stable key
       `- Block S1                         retained subtree
            `- Return S2
                 `- Call E1
                      --resolved-decl--> D2 target metadata remains visible
```

Reference edges such as `expr-resolved-decl`, `decl-type`, `stmt-owner`, and
`decl-parent` are printed, but are never treated as ownership. This prevents
call-to-callee or child-to-owner references from creating false tree cycles.
The closure reuses `asCASTParentEdgeIndex` and the generic structural visitor
from task 2.9 instead of introducing another recursive AST walker.

## Source and escaping rules

Tree strings and JSON strings use the same deterministic JSON-compatible
escaping for quotes, backslashes, control characters, and newlines. Logical
source keys are snapshot-owned SourceManager identities, not physical machine
paths. Snippets are disabled by default, must be explicitly requested, and
are byte-bounded by `maxSnippetBytes`; a node without a valid source range
reports empty/zero source facts.

## TDD record

1. The new test file was added first. The RED build failed because
   `asSASTStructuredDumpOptions`, filters/formats, and
   `asCASTStructuredDump()` did not exist.
2. The fixture's intended full-function range was corrected to use the actual
   source length before GREEN; this prevented a test-only invalid range from
   weakening source-position coverage.
3. The first implementation compiled and all three focused tests passed,
   proving repeated-context byte equality, valid JSON and escaping, all
   filters, structural closure, resolved target facts, no addresses/Engine
   IDs, diagnostic-only/Cache exclusion, and optional bounded snippets.
4. The complete Frontend CanonicalAST and Cache ASTBodySidecar prefixes passed
   together. Standalone then compiled the same standard-C++ implementation and
   passed its complete suite.

## Fresh verification

| Gate | Result | Evidence |
| --- | ---: | --- |
| Expected RED build | FAIL as expected: missing structured API | `Saved/Build/cta-ast-structured-dump-red/20260823_205515_935_ffe1762f/RunMetadata.json` |
| Runtime/Editor build | PASS | `Saved/Build/cta-ast-structured-dump-final-build/20260823_210842_719_7a4cb5fa/RunMetadata.json` |
| Focused StructuredDump | 3/3 PASS | `Saved/Tests/cta-ast-structured-dump-green/20260823_210239_635_78ff3f0f/RunMetadata.json` |
| Frontend CanonicalAST + Cache ASTBodySidecar | 129/129 PASS | `Saved/Tests/cta-ast-structured-dump-final-regressions/20260823_210855_491_580e3ace/RunMetadata.json` |
| Standalone CMake/CTest | 21/21 PASS | `Saved/StandaloneTests/cta-ast-structured-dump-final-verified_01_Standalone/20260823_210942_931_36d79110/RunMetadata.json` |

The joint 129-test gate comprises the complete current CanonicalAST prefix
(117 tests after this task) plus all 12 ASTBodySidecar regressions.

## What remains

The AST itself now has a solid debugger-facing read model, but the remaining
Clang-inspired usability layers are still explicit OpenSpec work:

- 2.11: verifier root-to-node path, related target, line/column, and bounded
  local subtree on failures;
- 2.12: typed native matcher/assertion helpers and complete semantic shadow
  diff with a first mismatch path;
- 2.13: lease-safe developer/commandlet operations for list, dump, verify,
  query, and diff.

This improves observability and AST-first diagnosis; it does not by itself
increase Canonical Sema or production CodeGen language coverage, so the real
default-cutover estimate remains approximately 46%.
