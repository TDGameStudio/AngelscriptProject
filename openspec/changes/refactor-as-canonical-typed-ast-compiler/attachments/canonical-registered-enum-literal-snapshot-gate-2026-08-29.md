# Canonical registered enum literal snapshot gate (CTA-S66)

Date: 2026-08-29

## Scope

This gate advances Tasks 4.3 and 13.2 immediately after CTA-S65. It removes
the remaining `GetTypeInfoByDecl`/`GetTypeInfoByName` calls from
`as_sema_expr.cpp`: the `HostEnum::Enumerator` projection in
`InternNativeEnumLiteral`. Canonical expression Sema must derive the enum type,
enumerator identity and exact integer value from the same translation-unit-
local registered-declaration snapshot used by declaration Sema.

Standalone remains deferred by user direction and is not changed or run. The
product default remains `LEGACY`; the native Parser AST, Builder and Compiler
remain available for syntax/recovery, explicit LEGACY, differential/reference
and rollback use. HIR remains physically absent. No production `dual` or
silent LEGACY fallback is introduced.

## Evidence-backed defect

`InternNativeEnumLiteral` currently runs before ordinary explicit-scope AST
resolution and performs two live Engine queries. It then casts the returned
generation-local pointer to `asCEnumType`, walks `enumValues`, bridges the live
type into the AST and copies the selected integer. This has two authority
defects:

1. a Sema/translation unit can observe an enum or enumerator registered after
   its snapshot began;
2. an already-published Host/old-module enum with the same qualified key can be
   selected before a current-translation-unit lexical scope gets authority.

The AST literal itself is pointer-free, but copying from a live pointer at each
action makes its type and bits registration-order/generation dependent.

## Locked authority boundary

1. `asSCanonicalRegisteredTypeDeclarationFact` gains owned enumerator facts
   only for `asAST_TYPE_ENUM`. Each enumerator fact contains the exact stable
   name and signed integer value; it contains no Runtime pointer, module,
   numeric TypeId, Parser node or callback.
2. Enumeration data is copied at Sema construction/translation-unit start with
   the containing registered declaration. Same-key enum facts are equal only
   when their ordered name/value facts are equal. A mismatch marks the
   declaration ambiguous and must fail closed.
3. Current Canonical lexical scopes are checked first. If the authored scope
   already resolves to a current TranslationUnit namespace/enum/class scope,
   registered enum fallback must not preempt it.
4. Registered fallback resolves the authored enum scope through the copied
   stable-key environment, honoring relative enclosing namespaces and leading
   `::`. It accepts only an unambiguous `asAST_TYPE_ENUM` fact.
5. Sema interns `asAST_EXPR_INTEGER_LITERAL` with the fact's Canonical enum
   type, copied signed value bits and resolved stable spelling
   `<EnumStableKey>::<Enumerator>`. It does not invoke
   `asCRuntimeTypeBridge`, construct a Builder or retain Runtime identity.
6. A registered enum fact without the requested enumerator remains an
   unresolved explicit-scope expression. It must not guess, bind another
   symbol or silently route through LEGACY.
7. Runtime binding/install remains responsible for mapping stable enum type
   identity to the current Engine type/TypeId where executable ABI requires it.

## AST-first gate card

Owning suite:

`Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

### `SemaRegisteredEnumLiteralSnapshotIsTranslationUnitLocal`

The test registers an early Host enum/value, begins an old Canonical
translation unit, registers a distinct late Host enum/value, and submits exact
pointer-free declaration-reference actions. It requires:

- the old Sema resolves the early enumerator as an enum-typed integer literal
  with its exact copied signed value and stable spelling;
- the old Sema does not resolve the late enumerator as an integer literal;
- a new Sema started after registration resolves that same late enumerator as
  the exact enum-typed literal;
- neither resulting AST type/literal identity contains a Runtime pointer or
  numeric TypeId.

Expected RED before production changes: the old Sema queries the live registry
and incorrectly resolves the late enum literal.

Existing `EnumParamOnCompileSealPathInternsEnumKind`, script enum scope and
qualified lexical scope gates remain required parity evidence.

## Required evidence

- test-only Runtime/Editor build and exact causal RED;
- focused lifecycle + Host enum + lexical enum scope GREEN;
- complete SemaAuthority;
- ProductionCodeGen, Module Snapshot and TypedASTJIT cross-surface regression;
- final Runtime/Editor build;
- static scan proving no `GetTypeInfoByDecl(`/`GetTypeInfoByName(` remains in
  `as_sema_expr.cpp` and that registered enumerator facts contain no forbidden
  Runtime identity;
- strict OpenSpec validation and plugin/parent `git diff --check`;
- plugin commit before the parent gitlink/OpenSpec commit.

## Encountered risks and non-claims

- This gate snapshots registered enum constants only. Engine-wide automatic-
  import function/global projection and native function/property ABI discovery
  in expression Sema are separate mutable symbol/binding boundaries and are not
  counted as fixed here.
- Exact duplicate-generation enum conflict injection may still require a
  controlled old/current registry fixture because normal registration rejects
  most duplicate declarations. Conservative mismatch-to-ambiguity logic does
  not substitute for that future behavior test.
- CTA-S65's `PreClassData::ShadowType` and maintained-fork interface
  classification issue remain open. This gate does not make CANONICAL default,
  complete full expression/lifetime authority or close Tasks 4.3/13.2.

## Evidence log

1. The first test-only build did **not** count as the causal RED. It failed in
   the new fixture because one `ASSERT_THAT(IsTrue(...), TEXT(...))` closed
   `IsTrue` before the message argument, producing C4002. The fixture-only
   parenthesis correction is recorded at:
   `Saved/Build/cta-s66-registered-enum-red-build/20260829_141908_537_35c2aaa6`.
2. Corrected test-only build: **PASS**, exit 0:
   `Saved/Build/cta-s66-registered-enum-red-build-fixed/20260829_141943_120_3d0a6bf0`.
3. Causal pre-production RED: **0/1 PASS**, with the old Sema incorrectly
   observing the enum/value registered after its translation-unit snapshot:
   `Saved/Tests/cta-s66-registered-enum-red/20260829_142005_163_cd522696`.
4. Production implementation build: **PASS**, exit 0:
   `Saved/Build/cta-s66-registered-enum-green-build/20260829_142200_997_a3244a7a`.
   After review added the direct same-stable-key lexical-shadow assertion, the
   final Runtime/Editor build also passed:
   `Saved/Build/cta-s66-registered-enum-final-build/20260829_143124_991_80e71c5c`.
5. Exact lifecycle gate: **1/1 PASS**:
   `Saved/Tests/cta-s66-registered-enum-green/20260829_142228_166_b697e608`.
6. Focused lifecycle/Host-enum/lexical-scope/action matrix: **5/5 PASS**:
   `Saved/Tests/cta-s66-registered-enum-focused/20260829_142308_789_67283cd1`.
7. Complete Canonical SemaAuthority: **426/426 PASS**, zero failures/skips:
   `Saved/Tests/cta-s66-sema-authority/20260829_142343_877_71ea276d`.
   The final source, including the lexical-shadow assertion, was rerun as
   **1/1 PASS** and then **426/426 PASS**:
   `Saved/Tests/cta-s66-registered-enum-final-focused-corrected/20260829_143237_302_864f71d8`,
   `Saved/Tests/cta-s66-sema-authority-final/20260829_143310_349_becdbfa4`.
   An earlier final-focus invocation used the wrong Automation fixture class
   name and matched zero tests; it is explicitly invalid evidence, not a test
   failure:
   `Saved/Tests/cta-s66-registered-enum-final-focused/20260829_143146_945_e5b6d513`.
8. Parser Declarations + Frontend Canonical Type + ProductionCodeGen +
   Module Snapshot + TypedASTJIT: **224/224 PASS**, zero failures/skips:
   `Saved/Tests/cta-s66-cross-surface/20260829_142638_705_bd8c5f06`.
9. Static boundary checks find zero `GetTypeInfoByDecl(`/
   `GetTypeInfoByName(` calls in `as_sema_expr.cpp`; the copied enumerator
   fact contains only owned `asCString name` plus signed `int value`. Plugin
   `git diff --check` is clean apart from Git's existing LF-to-CRLF notices.
10. `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict`
    reports the change valid. Parent `git diff --check` is clean apart from the
    same existing LF-to-CRLF notice. The required plugin-first commit is
    `0e5d5e7` (`[CanonicalAST] Refactor: snapshot registered enum literals in
    Sema`); the parent gitlink/OpenSpec commit follows this attachment.

## Accounting

CTA-S66 is a bounded slice of Tasks 4.3 and 13.2. The formal task ledger stays
`101/136 = 74.3%` until a whole task requirement is proven and checked.
