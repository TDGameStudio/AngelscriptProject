# Canonical lambda-expression typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-23 — replace the CANONICAL lambda expression node adapter with an exact typed action and transient expression-identity binding |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | direct pointer-free action construction plus source-built lambda parse/body/call fixtures already owned by SemaAuthority and ProductionCodeGen |
| Construction/sealed-AST assertion | the expression action references the exact Parser-created lambda `DeclId`, creates one `DeclRef`, creates no duplicate lambda declaration, and never reattaches or reparses the body |
| Architecture assertion | Parser retains and returns native `asCScriptNode/snFunction` syntax, but the CANONICAL expression route binds and retrieves an exact `ExprId`; `ActOnLambdaFromNode` is physically absent |
| Expected RED | the desired expression action/binding API is missing and `asCSema::ActOnLambdaFromNode` remains publicly detectable before production edits |
| Production edit allowed after RED | add the bounded pointer-free action and build-only identity map, publish the action after the Parser body action, consume only the bound `ExprId`, and delete the node adapter |

## Audited current path

`asCParser::ParseLambda()` already performs most of the canonical work:

1. it constructs the native `snFunction` syntax node;
2. it calls `ActOnLambdaHeaderAction` and receives the exact lambda `DeclId`;
3. it publishes explicit parameters, finishes the declaration and binds the
   native node to that declaration identity;
4. it enters the exact lambda `DeclContext` while parsing the body;
5. it calls `ActOnFunctionBodyFromNode` once after the body is complete.

The remaining expression route is duplicative. When the enclosing expression
is lowered, `ActOnExprFromNode` handles `snFunction` by calling
`ActOnLambdaFromNode`. That adapter looks the declaration up from the native
node, creates a `DeclRef`, finds the statement block in the node and attaches
the body a second time. The native node therefore still acts as a semantic
identity/body carrier after Parser already published those facts.

## Target contract

The slice introduces a short-lived, pointer-free action with only:

- the exact existing lambda `DeclId`;
- the exact half-open expression source range.

Sema validates that the declaration is a function carrying
`asAST_TRAIT_LAMBDA`, then creates a `DeclRef` to that exact declaration. The
Parser binds its native node to the resulting `ExprId` for the rest of the
same build. A legacy body reparse may recover the binding only by unique
`section + token offset`; ambiguity fails closed. This transient map is not a
snapshot, Provider, Cache, relocation or Runtime ABI.

`ActOnExprFromNode(snFunction)` may retrieve the exact expression identity but
may not inspect child nodes, rediscover the lambda declaration, recreate the
expression, or attach a body. A missing binding emits the stable
`lambda-expression-action-missing` diagnostic and fails closed.

## Native AST retention boundary

This gate deliberately preserves AngelScript's native syntax infrastructure:

- `asCParser::ParseLambda()` still returns `asCScriptNode*`;
- it still constructs `snFunction`, parameter-list and statement-block nodes;
- the native AST remains available to the explicit LEGACY Builder/Compiler,
  syntax/recovery tests, differential comparison and future language work.

Only CANONICAL semantic reconstruction from that node is retired. This gate
does not delete `asCScriptNode`, Parser, Builder, `asCCompiler`, or the explicit
LEGACY pipeline. TypedSemantic HIR deletion remains a separate required part
of the same OpenSpec.

## TDD and mutation contract

Permanent tests are added before production edits:

1. `SemaLambdaExpressionActionReferencesExactExistingDeclWithoutScriptNode`
   calls the desired pointer-free action and proves exact declaration identity,
   one lambda declaration and one reference without body replay;
2. `SemaDoesNotExposeNodeBasedLambdaExpressionAction` detects the obsolete
   public node adapter independently of implementation spelling;
3. the existing `ParserLambdaHeaderUsesTypedActionsWithoutNodeTypeDecoder`
   architecture test is extended after GREEN to require the expression action
   and binding while also locking that `ParseLambda` still returns and builds
   the native syntax node.

The first test-only build is expected to fail because the new action/API does
not exist. That compile failure is the valid RED. After adding only the API,
the obsolete-adapter assertion must remain RED until the node route is
physically removed.

## Required evidence

1. Supported test-only build RED naming the missing action/API.
2. Focused pre-removal RED for the obsolete node adapter, if the first API
   scaffold permits the test module to compile before the adapter is deleted.
3. Runtime/Editor build after production edits.
4. Complete SemaAuthority, Parser declarations, native ScriptNode shape,
   ProductionCodeGen lambda and relevant differential execution regressions.
5. Source scan proving `ActOnLambdaFromNode` is absent while native
   `ParseLambda`/`snFunction` construction remains.
6. Update the execution ledger, issue log, tasks/progress inventory and strict
   OpenSpec/diff checks.

## Execution issue before RED

An initial inventory command passed Windows wildcard path components such as
`*SemaAuthority*.cpp` and `**/*.cpp` directly to `rg`. On this shell those are
not expanded as file paths, so the command reported invalid paths. The audit
was rerun against directory roots with `--glob`; all cited counts and symbols
come from the corrected scan. This is a search-command correction, not a
repository or product defect.

## Explicit non-claims before implementation

- Lambda return-type inference, contextual funcdef conversion, captured-lambda
  storage ABI and every remaining expression/statement node adapter are not
  completed by this slice.
- `ActOnFunctionBodyFromNode` remains a named transitional statement-family
  adapter and is not claimed removed here.
- The compiler default remains LEGACY until the complete CANONICAL gate matrix
  passes; there is no automatic fallback, merge, or `dual` backend.
- Cache V2 remains default-disabled.

## RED evidence

The permanent direct-action and obsolete-API tests were added before
production edits. The supported Runtime/Editor build failed exactly on the
missing contract:

`Saved/Build/cta-lambda-expression-action-red/20260827_170515_552_cb021d38/RunMetadata.json`.

`asSLambdaExpressionAction` was undeclared and `asCSema` had no
`ActOnLambdaExpressionAction`. No unrelated compile error appeared in that
run. This is the valid compile-time RED. Because the desired API was added and
the obsolete node adapter was removed in one minimal production mutation, no
intermediate executable test run with only the obsolete-API assertion RED was
manufactured.

## Production result

CTA-S-23 now has one bounded lambda-expression route:

- `asSLambdaExpressionAction` carries only the exact existing lambda `DeclId`
  and full half-open source offsets;
- `ActOnLambdaExpressionAction` validates the exact function/lambda trait and
  creates one `DeclRef` without inspecting Parser nodes or attaching a body;
- Parser publishes that expression after its one explicit body action and
  binds the retained native node to the exact `ExprId`;
- the transient binding uses exact pointer identity first and a unique logical
  `section + token offset` fallback for a legacy body reparse; ambiguity fails
  closed;
- both expression and bare-lambda statement lowering retrieve only the bound
  `ExprId` and emit `lambda-expression-action-missing` when it is absent;
- `ActOnLambdaFromNode` and its sole `FirstChildOfType` helper are physically
  deleted.

The native syntax path remains intact. `ParseLambda()` still returns
`asCScriptNode*`, constructs `snFunction`, its parameter list and statement
block, and is covered by a real ScriptNode-shape regression.

## Build repair and encountered issues

The first post-mutation build failed at:

`Saved/Build/cta-lambda-expression-action-green-build/20260827_170659_069_da9e2481/RunMetadata.json`.

The initial inventory had found `as_sema_expr.cpp` but missed a second direct
`ActOnLambdaFromNode` call for a bare lambda statement in `as_sema_stmt.cpp`.
That was the only compiler error. The statement route was migrated to the same
exact expression-identity lookup and stable missing-action diagnostic; the
stale comment naming the old adapter was corrected. The repaired full build
passed:

`Saved/Build/cta-lambda-expression-action-green-build-fix1/20260827_170800_056_12ab0643/RunMetadata.json`.

A first `apply_patch` attempt for that correction used an inexact expected
comment line and failed safely without changing the file. The exact local
slice was reread and the corrected patch applied. A later read-only `rg`
command repeated the Windows wildcard-path mistake already described above;
it was discarded and rerun against directory roots. Neither tooling correction
is product evidence or a repository defect.

Existing native-fixture C5038/C4191 warnings remained visible during the
failed build. They predate this slice and are not claimed fixed.

## GREEN evidence

- repaired Runtime/Editor build: **PASS**:
  `Saved/Build/cta-lambda-expression-action-green-build-fix1/20260827_170800_056_12ab0643/RunMetadata.json`;
- final SemaAuthority: **341/341 PASS**:
  `Saved/Tests/cta-lambda-expression-action-final-sema/20260827_171049_642_4ce5dbcd/RunMetadata.json`;
- retained native ScriptNode shape: **14/14 PASS**:
  `Saved/Tests/cta-lambda-native-ast-retention-green/20260827_171004_229_60d52e39/RunMetadata.json`;
- Parser declarations: **18/18 PASS**:
  `Saved/Tests/cta-lambda-expression-action-parser-declarations/20260827_171140_724_0516a334/RunMetadata.json`;
- complete ProductionCodeGen, including immediate, stored, capturing and
  sibling-lambda fixtures: **114/114 PASS**:
  `Saved/Tests/cta-lambda-expression-action-production-codegen/20260827_171213_695_de9cb526/RunMetadata.json`.

The final production scan reports zero `ActOnLambdaFromNode` and zero
`FirstChildOfType` matches in Sema. It also finds the exact native
`asCParser::ParseLambda()` signature, its `CreateNode(snFunction)`, and the
typed expression action/binding route. Direct line-bearing node references are
now declaration **22**, expression **41**, statement **20**, and core **7**.
The core count rises from five to seven because the build-only identity map
names native pointers; it does not decode node meaning or publish those
pointers. Declaration references fall from 25 to 22 because the body-replay
adapter and its child search are gone.

Parent and plugin `git diff --check` both exit zero. Existing LF-to-CRLF
conversion notices are the only output.

## Final non-claims

CTA-S-23 closes only the completed lambda-expression identity/body-replay
adapter. Contextual lambda/funcdef signature and return inference, parameter
defaults, property/function bodies, general expression/statement/control and
lifetime action authority remain open. `ActOnFunctionBodyFromNode` remains.
Tasks 4.2, 4.3, 4.4, 5.2–5.9, 10.6 and 13.2 stay unchecked. The compiler
default remains LEGACY, the native AST/Builder/Compiler stay retained, HIR
deletion is still pending, and Cache V2 remains default-disabled.
