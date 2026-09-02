# Canonical declaration-reference expression typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-25 — replace CANONICAL declaration-reference name/scope replay with one owned, pointer-free Parser→Sema action |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixtures | direct action over local `i`, relative `Game::X`, and absolute `::Game::X`; real Parser source `int Entry(int i) { return i; }` |
| Constructed AST facts | exact `DeclRefExpr` target/type/range for local and explicitly scoped references; exact Parser-bound `ExprId` before parent replay |
| Architecture fact | action owns name, scope segments, absolute-scope bit, owner and offsets; it contains no `asCScriptNode*`; Sema no longer decodes `snVariableAccess` |
| Expected RED | desired `asSDeclRefExprAction` and `asCSema::ActOnDeclRefExprAction` API do not exist |
| Downstream gate | complete SemaAuthority, ProductionCodeGen reference/call behavior, and retained native ScriptNode shape |

## Target contract

Parser recognizes one variable-access grammar form and copies the exact
identifier, ordered scope segments, leading-global-scope bit, current
declaration owner and half-open processed-source offsets into a short-lived
action. Sema owns lexical lookup, exact explicit-scope lookup, receiver
handling, native-enum projection, automatic-import projection, deferred
binding, diagnostics and typed expression construction.

The action contains no Parser node, token-buffer pointer, Engine pointer or
Runtime numeric TypeId. Its `owner` is an ASTContext-local construction ID used
only within the current semantic build. It is not a durable/cache identity and
must never cross snapshot or generation boundaries.

After Sema returns, Parser binds the exact `ExprId` to the retained native
`snVariableAccess` node. Parent expression construction may retrieve that
identity, but it must not reconstruct the reference by reading the native
node's identifier or scope children. Missing identity fails closed with
`decl-ref-expression-action-missing`.

The native node remains intact for explicit LEGACY compilation, syntax and
recovery, differential/reference testing and rollback. Native AST retention is
therefore orthogonal to CANONICAL semantic authority.

## Semantic matrix retained by the action path

| Form | Sema-owned decision |
|---|---|
| `i` | lexical lookup from the current owner, including parameters/locals |
| `Game::X` | relative explicit-scope resolution through copied segments |
| `::Game::X` | root-relative resolution, distinguished by `absoluteScope` |
| `this` | enclosing-class receiver projection without a synthetic variable declaration |
| `NativeEnum::Value` | typed native-enum literal projection from the owned qualified spelling |
| automatic-import script global | provider global projection from copied qualified scope and name |
| unresolved forward/qualified reference | deferred reference record with copied name, scope, absolute bit and range |

## Permanent tests

1. `SemaDeclRefSyntaxActionOwnsNameAndScopeWithoutScriptNode` constructs a
   translation unit, namespace, global, function and parameter, invokes only
   the action API, and proves exact targets, types and ranges for unqualified,
   relative-scope and absolute-scope references.
2. `ParserDeclRefActionBindsExactExprIdentityBeforeParentReplay` parses a real
   function body, proves the independent native `snVariableAccess` node still
   exists, and requires `FindParsedExpressionIdentity` to return the exact
   parameter `DeclRefExpr` immediately after parsing.
3. Existing SemaAuthority and ProductionCodeGen cases remain the behavioral
   gates for `this`, native enum values, automatic imports, deferred qualified
   names, scope misses and executable reference behavior.

## RED evidence

The test-only build failed before production edits at:

`Saved/Build/cta-s25-decl-ref-action-red/20260827_221232_922_e9fe55bc/RunMetadata.json`.

The compile errors identify the missing `asSDeclRefExprAction` and
`asCSema::ActOnDeclRefExprAction` API. Both permanent tests were introduced in
that build, so compilation stopped before either runtime case could execute.
There is intentionally no separately claimed Parser runtime RED for this
slice; the compile-time RED is the only pre-production evidence.

One attempted multi-hunk `apply_patch` command referenced the same target file
more than once and was rejected atomically. It changed no file. The edits were
then split into valid patches. This was an editing-workflow issue, not a
compiler defect or test result.

## Implemented boundary

`asSDeclRefExprAction` owns the current `asASTDeclId`, copied identifier,
copied ordered scope segments, explicit root-scope bit and half-open offsets.
`asCSema::ActOnDeclRefExprAction` validates the source range and implements the
complete previously supported declaration-reference matrix without accepting
an `asCScriptNode*`.

`InternNativeEnumLiteral` and `InternAutomaticImportScriptGlobal` now receive
owned qualified-scope text instead of script/node inputs. Deferred references
store the copied spelling/scope/range from the action. The old
`InternParsedDeclRef` API and implementation are physically deleted.

`asCParser::ParseVariableAccess()` still constructs the native
`snVariableAccess`, parses its scope and identifier, copies those just-parsed
grammar facts into the action, calls Sema, and binds the returned identity.
The two surviving Sema `snVariableAccess` switch cases are identity-only and
fail closed if Parser did not bind an expression.

The action copy is currently assembled from Parser's newly constructed native
syntax node. This is no longer a Sema authority leak: no node crosses the
Parser→Sema boundary and no semantic decision reads the node. A later parser
cleanup may assemble the same action directly while reducing scope and
identifier productions, removing that local copy step without changing Sema's
contract.

## GREEN evidence

- Runtime/Editor API build: **PASS** at
  `Saved/Build/cta-s25-decl-ref-action-api-green-build/20260827_221606_066_1c774296/RunMetadata.json`;
- direct pointer-free action fixture: **1/1 PASS** at
  `Saved/Tests/cta-s25-decl-ref-action-api-green/20260827_221643_700_acd0d036/RunMetadata.json`;
- real Parser identity fixture: **1/1 PASS** at
  `Saved/Tests/cta-s25-parser-decl-ref-identity-green/20260827_221725_602_e004e2a2/RunMetadata.json`;
- complete Canonical SemaAuthority: **346/346 PASS** at
  `Saved/Tests/cta-s25-sema-authority-check/20260827_221809_104_ca348054/RunMetadata.json`;
- ProductionCodeGen: **114/114 PASS** at
  `Saved/Tests/cta-s25-production-codegen-green/20260827_221856_537_89e803de/RunMetadata.json`;
- retained native ScriptNode shape: **32/32 PASS** at
  `Saved/Tests/cta-s25-scriptnode-green/20260827_221935_748_7b64766e/RunMetadata.json`.

The final live-source scan finds zero `InternParsedDeclRef`. Native
`snVariableAccess` creation remains intentionally positive. Parser still has
18 general `ActOnParsedExpr` call sites; those are a concrete inventory for
the remaining composite-expression migration, not evidence against this
declaration-reference boundary.

## Explicit non-claims

- Call, prefix/postfix, member/index, binary/logical, assignment and
  conditional expression replay remain outside this leaf-expression slice.
- Statement/control/function-body/default/initializer/lifetime adapters remain
  open.
- Builder Runtime-shell narrowing and complete language CodeGen are not closed.
- Task 4.2 and CTA-SEMA-01 remain open.
- Compiler default remains LEGACY; Cache V2 remains default-disabled; native
  AST/Parser/Builder/Compiler and explicit LEGACY remain intentionally
  retained.
