# Canonical typedef typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-09 — primitive typedef Parser→Sema typed action |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixtures | `typedef int Count` without `;`; complete `typedef int Count;` plus a later function |
| Sealed-AST assertion | the typedef is published after its identifier even when the later semicolon is missing; complete input contains exactly one Typedef with primitive `int` QualType |
| Architecture assertion | `ParseTypedef()` publishes recognized name, resolved primitive token and exact range through a typed action; it does not call `NotifySema(node)`; `WalkOne` has no `snTypedef` case |
| Expected RED | current Parser calls `NotifySema(node)` and `WalkOne` decodes the typedef name and type from `snTypedef` children |
| Production edit allowed after RED | yes, limited to the fork's currently supported primitive typedef grammar and removal of `snTypedef` replay |

## Locked design

The maintained fork currently restricts script typedef syntax to one non-void
primitive type. This slice does not broaden that language. Parser continues to
build `snTypedef` for LEGACY syntax recovery/oracle use, but Canonical Sema
receives a plain payload:

```text
{ recognized alias name, Parser-resolved primitive token,
  alias-name begin byte offset, alias-name end byte offset }
```

The Parser-resolved token is important for configured `float` width. Sema
validates the primitive token and SourceManager range, creates/reuses the
Typedef under the exact current DeclContext, and assigns the canonical
primitive QualType. No type/node adapter is required for this restricted
grammar.

The action fires after both type and identifier have been recognized but before
the semicolon, preserving the existing error-recovery contract.

## Required evidence

1. focused architecture RED before production edits;
2. Runtime/Editor build after the repair;
3. focused architecture GREEN;
4. incomplete and complete/unique typedef AST gates GREEN;
5. full SemaAuthority and ProductionCodeGen GREEN;
6. source scan, parent/plugin `diff --check`, strict OpenSpec validation;
7. issue log and task progress updated without closing Tasks 4.2/4.3/13.2.

## Non-claims

- CTA-S-09 covers only the current primitive typedef grammar.
- General qualified/template/handle typedef syntax remains unsupported by the
  maintained fork and is not invented by this refactor.
- Funcdef/import/class/interface/mixin/function/variable/type/expression/
  statement node callbacks remain open.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD execution

The architecture test
`ParserTypedefUsesTypedActionWithoutTypedefNodeReplay` was added before the
production edit. Its test-only build passed at:

- `Saved/Build/cta-typedef-typed-action-red-test-build/20260827_084519_331_88ea522d/RunMetadata.json`.

The focused run then produced the intended valid **0/1 RED** because
`ParseTypedef()` did not yet publish `ActOnTypedefAction`:

- `Saved/Tests/cta-typedef-typed-action-red/20260827_084539_629_c76cf1bc/Report/index.json`.

The repair introduced `asSTypedefDeclAction` and
`asCSema::ActOnTypedefAction`, removed `case snTypedef` from `WalkOne`, and
excluded `snTypedef` from the generic completed-declaration callback. Parser
still builds the node for the LEGACY oracle and error recovery, but it no
longer sends that node to Canonical Sema for typedef meaning.

## Verification evidence

- Runtime/Editor build: PASS at
  `Saved/Build/cta-typedef-typed-action-fix-build/20260827_084730_791_1106805b/RunMetadata.json`;
- focused architecture: **1/1 PASS** at
  `Saved/Tests/cta-typedef-typed-action-focused-green/20260827_084758_328_2f4e1e4b/Report/index.json`;
- final incomplete/complete/unique/type-fact behavior gates: **2/2 PASS** at
  `Saved/Tests/cta-typedef-behavior-final-green/20260827_085025_680_43265705/Report/index.json`;
- complete SemaAuthority: **311/311 PASS** at
  `Saved/Tests/cta-typedef-sema-full/20260827_085100_053_944da7da/Report/index.json`;
- complete ProductionCodeGen: **114/114 PASS** at
  `Saved/Tests/cta-typedef-production-full/20260827_085139_160_8ba25e55/Report/index.json`;
- corrected assertion test build: PASS at
  `Saved/Build/cta-typedef-type-fact-assertion-fix-build/20260827_085003_763_e49b8f2b/RunMetadata.json`;
- source scan: zero `case snTypedef`; `ParseTypedef()` contains
  `ActOnTypedefAction` and no `NotifySema(node)`; the generic completed callback
  excludes `snTypedef`;
- direct `asCScriptNode` occurrences after this slice are
  `as_sema_decl.cpp=117`, `as_sema_expr.cpp=42`, `as_sema_stmt.cpp=27`, and
  `as_sema.cpp=2`;
- strict OpenSpec validation and separate parent/plugin `git diff --check`
  passed; diff checks emitted only pre-existing LF/CRLF notices.

## Invalid test history retained

The first strengthened two-method behavior run reported **0/2**, but it is not
product evidence:

- `Saved/Tests/cta-typedef-behavior-green/20260827_084905_428_49945bea/Report/index.json`.

The dump already contained exactly one `Typedef` named `Count` with
`type=int`. The new test had incorrectly assumed the `name` and `type` fields
were adjacent. The assertion was corrected to inspect one declaration line
and require both fields on that line; no production code changed for this
invalid run.
