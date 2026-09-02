# Canonical namespace typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-07 — namespace Parser→Sema typed action |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixtures | `namespace Game { int F(int a) { return a; } }`; `namespace A::B::C { ... }`; nested namespace with a later incomplete return |
| Sealed-AST assertion | one namespace declaration per path segment; `F` owned by the final segment; successful source seals; later syntax failure retains already-acted namespace/function facts |
| Architecture assertion | `ParseNamespace()` invokes a typed namespace-path Sema action and does not call `NotifySema(asCScriptNode*)`; `WalkOne` has no `snNamespace` semantic replay case |
| Expected RED | the architecture assertion fails because `ParseNamespace()` calls `NotifySema(node)` and `WalkOne` decodes `case snNamespace` |
| Production edit allowed after RED | yes, limited to namespace action payload, Parser dispatch, and removal of namespace node replay |

## Production RED discovered after the first repair

The first implementation removed whole-namespace replay and passed the new
architecture assertion plus the then-current SemaAuthority suite, but the full
ProductionCodeGen gate was `109/114`. All five failures involved namespaced
functions/globals/value methods. The generic namespace replay had also been the
only post-body path that revisited completed child declarations inside
`ParseScript(true)`. Early function actions interned signatures, but their final
authored bodies were not attached.

Before changing production code again, the existing successful-namespace AST
test is strengthened to require `Game::F(int)` to own a Block with a reachable
Return. Expected RED: the declaration exists but `Function->body` is invalid.

The fix must notify the still-transitional **child declaration family** after
each completed namespace-body parse; it must not restore whole `snNamespace`
replay. Function/class/etc. child replay remains separately inventoried work.

## Locked design

The Parser may continue building the legacy `snNamespace` node for the explicit
LEGACY oracle. For Canonical Sema it constructs a plain action payload:

```text
[{ segment name, begin byte offset, end byte offset }, ...]
```

Sema remaps the active `asCScriptCode` through `asCSourceManager`, converts each
half-open coordinate to `asCSourceRange`, interns/reuses the namespace segment
under the exact current declaration context, and returns the final namespace
ID used while parsing the body.

No `asCScriptNode*` crosses the namespace-specific Parser→Sema boundary. This
does not introduce a second syntax tree: it is a bounded action DTO discarded
after the call.

## Required evidence

1. focused architecture RED before production change;
2. build after production change;
3. focused namespace action GREEN;
4. full SemaAuthority GREEN;
5. ProductionCodeGen regression GREEN because namespace ownership affects
   resolved stable keys and callable publication;
6. source scan showing no `case snNamespace` in `WalkOne` and no
   `NotifySema(node)` inside `ParseNamespace()`;
7. `diff --check` and strict OpenSpec validation.

## Non-claims

- CTA-S-07 closes only the namespace declaration family.
- Tasks 4.2, 5.2–5.9 and 13.2 remain open until all relevant families and
  consumers cross the same boundary.
- The remaining Parser-node counts are expected to stay non-zero after this
  slice.

## RED-to-GREEN evidence

### Architecture RED

`ParserNamespaceUsesTypedActionPayloadWithoutScriptNodeReplay` was added before
the production edit. The test-build passed at:

`Saved/Build/cta-namespace-typed-action-red-test-build/20260827_081848_183_4faafc16/RunMetadata.json`.

An initial exact-prefix attempt selected no tests and is therefore explicitly
invalid evidence:

`Saved/Tests/cta-namespace-typed-action-red/20260827_081908_210_4863a2af/`.

The valid complete SemaAuthority run selected 309 tests and failed only the new
architecture assertion, **308/309 PASS**:

`Saved/Tests/cta-namespace-typed-action-sema-red/20260827_081945_553_6c1c43c3/Report/index.json`.

### First repair and production regression

The first repair introduced `asSNamespaceDeclActionSegment` and
`ActOnNamespacePath`, moved namespace-path publication before body parsing and
removed `case snNamespace` from `WalkOne`. Its build and focused architecture
gate passed:

- build: `Saved/Build/cta-namespace-typed-action-fix-build/20260827_082152_151_ca7e1a07/RunMetadata.json`;
- architecture: **1/1 PASS** at
  `Saved/Tests/cta-namespace-typed-action-focused-green/20260827_082219_085_53618343/Report/index.json`;
- SemaAuthority: **309/309 PASS** at
  `Saved/Tests/cta-namespace-typed-action-sema-final-green/20260827_082252_339_8d38183c/Report/index.json`.

The required ProductionCodeGen run then found a real regression: **109/114
PASS** at
`Saved/Tests/cta-namespace-typed-action-production-final-green/20260827_082331_889_90b68e4c/Report/index.json`.
The five failures were all namespace-owned function/global/value-method cases.
The AST contained declarations and no diagnostics, but namespaced functions
did not own their completed authored bodies and value methods did not finish
their declaration publication.

Root cause: the removed whole `snNamespace` replay had hidden two separate
responsibilities. It created the namespace path, but it also recursively
revisited each completed child after `ParseScript(true)`. Early function/class
actions intentionally intern partial declarations before their bodies are
available. Root declarations receive a completed callback from outer
`ParseScript`, whereas namespace children had depended on the recursive
namespace replay for that callback.

### AST-first regression RED and final repair

Before the second production edit,
`ParserActOnNamespaceDoesNotDuplicateOnSuccessfulParse` was strengthened to
require `Game::F(int)` to own a valid Block containing a reachable Return. The
test-build passed at:

`Saved/Build/cta-namespace-child-body-red-test-build/20260827_082543_299_d62d2f8a/RunMetadata.json`.

The focused test then failed **0/1** with the exact missing-body assertion:

`Saved/Tests/cta-namespace-child-body-sema-red/20260827_082602_269_298bedad/Report/index.json`.

The final repair keeps the namespace path action-only and does not restore
`snNamespace` replay. Instead, `ParseScript(true)` now sends the same
transitional completed-child callback used for root declarations to every
successful non-namespace child. This attaches bodies/class traits that do not
exist at the early action point. The comment and inventory explicitly retain
this as per-family migration debt: each child family still needs a typed finish
action before its legacy child-node callback can be deleted.

Final evidence:

| Gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-namespace-child-finish-fix-build/20260827_082808_157_d18e9806/RunMetadata.json` |
| Authored namespace child body | 1/1 PASS | `Saved/Tests/cta-namespace-child-body-sema-green/20260827_082829_020_6a245fdf/Report/index.json` |
| No namespace node replay | 1/1 PASS | `Saved/Tests/cta-namespace-typed-action-architecture-regreen/20260827_082904_108_3b72e0ea/Report/index.json` |
| ProductionCodeGen | 114/114 PASS | `Saved/Tests/cta-namespace-child-finish-production-regreen/20260827_082935_642_82e4c9d1/Report/index.json` |
| SemaAuthority | 309/309 PASS | `Saved/Tests/cta-namespace-child-finish-sema-final-green/20260827_083009_371_1df2c6ed/Report/index.json` |

## Gate conclusion

CTA-S-07 is resolved as one bounded declaration-family slice. Namespace-path
identity, source ranges and ownership now cross a short-lived typed action
payload, while the legacy namespace syntax node is retained only for the
explicit LEGACY oracle/recovery tree. The remaining completed-child callbacks
for function/class/enum/etc. are not waived: they remain open under CTA-S-01,
Tasks 4.2 and 13.2 and the declaration-family inventory.
