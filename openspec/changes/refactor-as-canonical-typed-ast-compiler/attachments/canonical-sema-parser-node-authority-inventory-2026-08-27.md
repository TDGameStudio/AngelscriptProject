# Canonical Sema / Parser-node authority inventory — 2026-08-27

## Purpose

This inventory re-establishes the truthful authority boundary after the
qualified-name and deferred-parent-expression gates. It is not a completion
claim for Tasks 4.2, 5.2–5.9, or 13.2.

The target contract remains:

```text
Parser recognizes syntax
    -> typed Sema actions (names, types, ranges, already-built AST IDs)
        -> sealed Canonical AST
            -> read-only CodeGen / metadata / JIT consumers
```

`asCScriptNode` may remain as a temporary legacy Parser product while the
LEGACY compiler is still an explicit migration oracle. It must not remain the
semantic payload consumed by the completed Canonical path.

## Current measured boundary

The maintained-fork production Sema sources still contain the following direct
`asCScriptNode` references:

| File | Direct occurrences | Main role |
|---|---:|---|
| `as_sema_decl.cpp` | 25 | explicitly named property/default/initializer and function/lambda body adapters |
| `as_sema_expr.cpp` | 41 | expression-tree decoding; cast/construct target types now come from exact typed bindings |
| `as_sema_stmt.cpp` | 20 | statement/control decoding |
| `as_sema.cpp` | 5 | explicit transitional declaration-identity and expression-target-type binding implementations |

These counts are an inventory signal, not a sufficient final gate: one helper
can consume many node kinds, and some occurrences are comments or declarations.
Final closure must use both source scans and behavior/parity evidence.

The count was re-measured after CTA-S-21. CTA-S-08 through CTA-S-10 removed
enum, primitive-typedef and import declaration replay; CTA-S-11 through
CTA-S-15 removed ordinary function, record, global/field/local declaration and
class-default whole-node decoders. CTA-S-16 deleted retained `snFuncDef`
decoding, CTA-S-17 deleted `snAccessDeclaration` replay, and CTA-S-18 replaced
the four-node parameter boundary with an exact callable action. CTA-S-19 moved
every declaration-site return, parameter and variable type to one pointer-free
type-syntax action. CTA-S-20 moved cast/construct destinations to exact typed
bindings and reduced the measured inventory to **80/41/20/5**.

CTA-S-21 then removes the final generic `ActOnQualTypeFromNode` API and all
lambda signature/type reconstruction helpers. `ParseLambda` publishes the
header and explicit parameter actions, receives the exact lambda DeclId and
pushes that exact context before the body. Declaration Sema falls from **80**
to **49** direct line-bearing references; expression, statement and core stay
at **41/20/5**. The core five sites make the transient declaration-identity and
expression-target-type bridges explicit; neither bridge re-decodes semantic
type syntax. Raw occurrence count is still not an architecture score:
enumerator/default/property initializers, the lambda body and general
expression/statement/lifetime adapters remain named migration boundaries.

CTA-S-22 physically removes the inactive generic declaration entry:

```text
deleted:
  asCParser::NotifySema / semaDeclActions / zero-action fallback
  asCSema::ActOnParsedDeclaration / ActOnParsedScript
  WalkOne / WalkDecls / replay-only recursive helpers
```

Declaration Sema now measures **25** direct line-bearing node references.
There is no whole-tree declaration fallback or completed-declaration callback;
all remaining declaration-family crossings are explicitly named adapters.

The migrated lambda header now follows a different boundary:

```text
ParseLambda
    -> BuildQualTypeSyntaxAction / ActOnQualTypeAction
    -> ActOnLambdaHeaderAction
    -> ActOnParameterDeclAction(exact lambda DeclId)
    -> Push(exact lambda DeclContext)
    -> ActOnFunctionBodyFromNode(exact bound lambda; body-only adapter)
```

Parser callbacks are incremental in time and migrated declaration families now
publish typed phases. Residual property/default/body adapters and general
expression/statement/lifetime callbacks still replay Parser nodes after
accumulating children. Therefore the implementation is **not yet equivalent
to Clang's typed Parser→Sema action boundary**, even though Sema owns the
canonical nodes it constructs.

## Existing strengths that must be preserved

- Parser invokes declaration/expression/statement callbacks before many later
  syntax failures, so earlier semantic facts survive error recovery.
- `ActOnStart*` APIs already construct canonical declarations without Parser
  nodes and provide the correct target seam for typed payload migration.
- Sema owns lookup, overload choice, conversions, deferred-name reconciliation,
  lexical-scope replay, and canonical node construction.
- Canonical Bytecode CodeGen reads the sealed AST for the supported production
  surface and no longer needs the legacy compiler on those routes.
- Source identity is remapped through `asCSourceManager`; typed actions can pass
  half-open source coordinates without carrying Parser nodes.

## Remaining authority leaks

1. The generic `WalkOne`/`WalkDecls` path is absent, but explicitly named
   property/default/initializer and function/lambda body adapters still accept
   `asCScriptNode` and decode completed subtrees.
2. `ActOnQualTypeFromNode` and the lambda signature/type walkers are absent.
   Contextual lambda/funcdef signature and return inference remain incomplete,
   while `ActOnExprFromNode` and `ActOnStmtFromNode` remain broad Parser-tree
   decoders inside Sema.
3. `parsedDeclBindings` retains Parser-node pointers as a transitional bridge
   to legacy Builder/compiler callbacks. CTA-S-10 names its identity-only
   producer entry as `BindParsedDeclarationIdentity`; it must not acquire
   semantic decoding responsibilities.
4. `ActOnParsedScript` and `ActOnParsedDeclaration` are absent; permanent API-
   surface tests prevent their silent restoration.
5. Residual Parser paths can call both an early action and a later node-specific
   adapter; exact owner/range checks must replace any duplicate-tolerant
   declaration interning before final closure.

## Migration order

The migration proceeds by source-language family, with an AST-first RED gate
for every slice:

1. namespace path actions;
2. class/interface/mixin start/finish actions and base/member payloads; enum
   and enumerator name actions are complete, while enum initializer expressions
   remain under step 6;
3. functions/methods/constructors/destructors, parameter headers and traits are
   complete; their declaration-site return/parameter types are typed actions;
   lambda headers and explicitly typed parameters are complete, while
   contextual/untyped parameters, return inference and default expressions
   remain;
4. globals, funcdef and custom access-group declaration identity are complete;
   properties remain, while primitive typedef and import signature/origin
   actions are complete and general return-type payloads belong with typed type
   actions;
5. declaration-site primitive/qualified/template type payloads,
   cast/construct target types and explicit lambda parameter types are
   complete; contextual lambda/funcdef and residual property type semantics
   remain;
6. expressions and resolved call/candidate payloads;
7. statements/control/lifetime payloads;
8. removal of Parser-node declaration mapping and whole-tree replay; the
   whole-tree replay half is complete, while transient identity mappings remain;
9. final scan proving production Sema has no semantic `asCScriptNode` input.

Completed declaration-identity slices are namespace paths, enum/enumerator,
primitive typedef, import, ordinary function, record, global/field/local/loop,
generated class-default, retained Parser funcdef, custom access-specifier and
ordinary/import/interface/funcdef parameter-header families, plus lambda header
identity and explicitly typed lambda parameters. Declaration-site return/
parameter/variable QualType payloads and cast/construct target types are also
complete, and the generic node-to-type API is physically gone. The next
declaration slice should be the smallest residual property, default-expression
or contextual lambda/body boundary that can publish a complete start/finish
contract without reintroducing whole-node replay; the order above remains
dependency guidance rather than a count-driven target.

CTA-S-22 additionally removes the generic whole-tree declaration callback,
public replay APIs and recursive replay walker. Final focused evidence is
SemaAuthority **339/339** plus the combined TypeSema/Parser-declaration/
ProductionCodeGen/Frontend-Type matrix **152/152**. This is a stronger
authority boundary, not completion of the remaining named node adapters.

## Non-claims

- This inventory does not mark any umbrella task complete.
- Reducing the occurrence count is not proof of semantic completeness.
- Migrated declaration actions do not prove that general type/default/
  property/lambda/expression/statement/lifetime families are complete.
- The LEGACY compiler remains the migration oracle until the final cutover gate.
