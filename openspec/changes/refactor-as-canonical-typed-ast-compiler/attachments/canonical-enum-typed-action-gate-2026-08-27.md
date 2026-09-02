# Canonical enum typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-08 — enum/enumerator Parser→Sema typed name actions |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixtures | complete enum with implicit/positive/negative explicit values; incomplete `Blue =` after a valid earlier enumerator |
| Sealed-AST assertion | one Enum with canonical Enum QualType; one const enum-typed Var per enumerator; exact explicit and implicit values; earlier facts survive later syntax failure |
| Architecture assertion | `ParseEnumeration()` publishes enum/enumerator names and half-open byte ranges through typed actions, does not call `NotifySema(node)` or `ActOnParsedEnumerator(asCScriptNode*)`, and `WalkOne` has no `snEnum` case |
| Expected RED | current Parser calls `NotifySema(node)` for the enum shell and `ActOnParsedEnumerator(ident,...)`; `WalkOne` still decodes `case snEnum` |
| Production edit allowed after RED | yes, limited to typed enum/enumerator name payloads, enum Parser dispatch and removal of whole-enum replay |

## Locked design

The Parser continues building `snEnum` for the explicit LEGACY oracle and
syntax recovery. Canonical declaration identity crosses only a short-lived
plain payload:

```text
{ recognized name, begin byte offset, end byte offset }
```

Sema prepares/remaps the active `asCScriptCode` through SourceManager, validates
the half-open range and invokes the existing `ActOnStartEnumDecl` or
`ActOnStartEnumeratorDecl` under the exact current DeclContext. The enum
DeclContext is pushed before parsing enumerators, so already recognized facts
survive a later malformed initializer or missing brace.

Enumerator initializer syntax remains part of the separately inventoried
expression migration. This slice may keep a clearly named transitional
expression-node adapter, but it must not use a Parser node to rediscover enum or
enumerator declaration identity.

## Required evidence

1. focused architecture RED before production edits;
2. Runtime/Editor build after the repair;
3. focused architecture GREEN;
4. incomplete-enum and complete explicit/implicit value AST gates GREEN;
5. full SemaAuthority and ProductionCodeGen GREEN;
6. source scan, parent/plugin `diff --check`, strict OpenSpec validation;
7. issue log and task progress updated without closing Tasks 4.2/13.2.

## Non-claims

- CTA-S-08 closes only enum/enumerator declaration-name replay.
- Expression parsing of enum initializers remains transitional until the
  expression action family migrates.
- Class/interface/mixin/function/variable/import/type/expression/statement
  node callbacks remain open.
- Compiler and Cache V2 defaults remain unchanged.

## TDD and verification record

The permanent architecture test
`ParserEnumUsesTypedNameActionsWithoutEnumNodeReplay` was added before the
production edit. Its first supported-runner execution was a valid **0/1 RED**:

- test build PASS:
  `Saved/Build/cta-enum-typed-action-red-test-build/20260827_083616_365_81c4a00c/RunMetadata.json`;
- focused RED **0/1** because `ParseEnumeration()` did not publish a typed
  enum-name action:
  `Saved/Tests/cta-enum-typed-action-red/20260827_083633_177_38131c5c/Report/index.json`.

The repair adds the short-lived `asSEnumDeclActionName` payload and the
`ActOnEnumName` / `ActOnEnumeratorName` action pair. Both actions validate the
recognized name and exact half-open SourceManager range before constructing
the declaration under the current context. `ParseEnumeration()` pushes the
new enum declaration before recognizing its enumerators. `WalkOne` no longer
contains `case snEnum`, and the generic completed-declaration callback excludes
`snEnum` so it cannot replay the same semantic shell.

`ActOnEnumeratorInitializerFromNode` is intentionally retained and named as a
transitional **expression-family** adapter. It receives an already-created
enumerator ID and cannot rediscover the enum/enumerator declaration identity.
Its removal belongs to the expression action migration, not this name-action
slice.

Final evidence:

| Gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-enum-typed-action-fix-build/20260827_083825_410_54f9a951/RunMetadata.json` |
| focused architecture | 1/1 PASS | `Saved/Tests/cta-enum-typed-action-focused-green/20260827_083850_221_28b76a35/Report/index.json` |
| complete SemaAuthority | 310/310 PASS | `Saved/Tests/cta-enum-typed-action-sema-full/20260827_083927_544_324b6a6e/Report/index.json` |
| complete ProductionCodeGen | 114/114 PASS | `Saved/Tests/cta-enum-typed-action-production-full/20260827_084006_885_daa7d173/Report/index.json` |
| strict OpenSpec validation | PASS | `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict` on 2026-08-27 |
| parent/plugin diff check | PASS | separate `git diff --check` runs on 2026-08-27; existing LF/CRLF notices only |

This closes CTA-S-08 only. Tasks 4.2 and 13.2 remain unchecked; class,
interface, mixin, function, variable, import, type, expression and statement
families still contain Parser-node semantic adapters. Compiler default remains
LEGACY and Cache V2 remains default-disabled.
