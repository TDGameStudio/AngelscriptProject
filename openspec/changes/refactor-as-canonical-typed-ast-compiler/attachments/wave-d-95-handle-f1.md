# Wave D 9.5 — handle RED vs F1 (read-only)

Worktree: `D:\as-cta`. Package **D-95-handle-f1**. Do not edit `Plugins/`, tests, `tasks.md`, `async-work.md`, `async-dispatch.md`, `wave-d-95-plan.md`, `wave-d-95-results.md`, or `wave-d-95-f1-next.md`. No UBT. No Wave G. Do not mark 9.5. Dialect: no script `funcdef` / `@` / `is`. `nullptr` is `ttNull`; `null` is an identifier.

Question: production `CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes` RED (`Build()==0` and `CollectFunctionDeclarations == <no functions>` for `int F() { CObj Obj = null; if (Obj == nullptr) return 42; return 0; }`) — fifth-pass F1 empty-`functionDecls` skip, F1 inverse (method Commit skip), or a different intern hole?

Evidence already: `d95-handle` (`async-work.md`) — `CompileNativeModule == 0`, `{<no functions>}`, no `Canonical CodeGen failed`, no `Canonical Seal failed`. Isolated cousin `bool IsNull(CObj Obj) { return Obj == nullptr; }` is GREEN. `CollectFunctionDeclarations` walks **module globals only** (`GetFunctionCount()` → `globalFunctionList`).

---

## 1. Fifth-pass F1 vs live `Generate()` order

Fifth-pass (`reviews/implementation-rereview-2026-08-22-fifth-pass.md` F1) claimed collect at `as_bytecode_codegen.cpp:1558-1567` (FUNCTION/METHOD/CTOR/DTOR **and** `decl->body.IsValid()`), and if the list was empty the function returned `asAST_VERIFY_OK` **before** checking module/Engine, allocating globals, or installing types.

Those line numbers and that early-return are **stale**. Live `asCBytecodeCodeGen::Generate` (`as_bytecode_codegen.cpp` 2015–2163):

**Fail-closed first** (2015–2039), then types, then collect, then globals, then emit, then Commit:

```text
2015  int asCBytecodeCodeGen::Generate(const asCASTContext& context, asCModule* module)
2021  if( !context.IsSealed() ) → asAST_VERIFY_UNSEALED_PUBLICATION
2027  if( context.GetDeclCount() == 0 ) → asAST_VERIFY_DANGLING_ID
2034  if( module == 0 || module->engine == 0 ) → asNO_MODULE
2046  if( !RegisterCanonicalScriptTypes(...) ) → fail  // TU-direct DECL_CLASS only
2054  asCArray<const asCDecl*> functionDecls;
2055  for( asUINT i = 1; i <= context.GetDeclCount(); ++i )
2058    if( decl == 0 || !CanonicalDeclIsFunctionLike(decl->kind) ) continue;
2062    if( decl->body.IsValid()
2063        || decl->kind == asAST_DECL_FUNCTION          // LIVE: FUNCTION even without body
2064        || decl->kind == asAST_DECL_CONSTRUCTOR
2065        || (decl->kind == asAST_DECL_DESTRUCTOR && (decl->traits & asAST_TRAIT_GENERATED) == 0) )
2067      functionDecls.PushLast(decl);
2071  // TU-direct DECL_VAR → AllocateGlobalProperty (even if functionDecls is empty)
2110  // signature + engine->AddScriptFunction  (no-op when list empty)
2141  // Emit                              (no-op when list empty)
2155  const int commit = artifact.Commit(module);
2163  return asAST_VERIFY_OK;
```

`CanonicalDeclIsFunctionLike` (30–36): `FUNCTION` / `METHOD` / `CONSTRUCTOR` / `DESTRUCTOR`.

There is **no** `if (functionDecls.GetLength()==0) return asAST_VERIFY_OK` before types/globals. Empty collect still reaches Commit then OK **after** `RegisterCanonicalScriptTypes` and the TU-direct `DECL_VAR` walk.

`wave-d-95-f1-next.md` collect snippet is also slightly stale: live additionally collects `decl->kind == asAST_DECL_FUNCTION` even when `body` is invalid. METHOD still needs a body (or it is skipped). CTOR always; non-generated DTOR always.

CANONICAL `asCModule::Build()` (`as_module.cpp` 397–440): parse/seal → `codegen.Generate(*pending, this)` → on `r>=0` skip legacy type/function/layout/compile stages, `PublishCanonicalASTSnapshot()`, `ResetGlobalVars`. Generate OK with an empty artifact is how `Build()==0` happens with nothing on the global lookup surface.

---

## 2. Empty `functionDecls` still OK after empty Commit — matches `Build==0` + no globals

Live `asSBytecodeCodeGenArtifact::Commit` (1990–2013):

```text
1990  int asSBytecodeCodeGenArtifact::Commit(asCModule* module)
1994  for( asUINT i = 0; i < functions.GetLength(); ++i )
1999    func->AddReferences();
2000    module->scriptFunctions.PushLast(func);
2001    if( func->objectType == 0 )
2003      module->globalFunctions.Add(func);
2004      module->globalFunctionList.PushLast(func);
2007  module->SetLastBytecodePublisher(asBYTECODE_PUBLISHER_CANONICAL_CODEGEN);
2012  return asAST_VERIFY_OK;
```

Empty `artifact.functions` → Commit still returns OK and still stamps `CANONICAL_CODEGEN`. No `scriptFunctions` rows from this Generate, no `globalFunctionList` rows, no TU-direct globals in this fixture (the only source decl is `int F()`). That is exactly `Build()==0` + `CollectFunctionDeclarations == <no functions>`.

This is the **live remainder** of fifth-pass F1 empty-install, **not** the fifth-pass “return OK before globals/types”. Silent success is still real; the order changed.

---

## 3. F1 inverse: METHOD + `objectType` → globals empty, `scriptFunctions` not

`FillFunctionSignature` (1914–1948) sets `func->objectType` only for `METHOD` / `CONSTRUCTOR` / `DESTRUCTOR` whose parent is `DECL_CLASS` with a name `FindCanonicalObjectType` can resolve. `FindCanonicalObjectType` (78–97) searches `module->classTypes` **then** `engine->GetTypeInfoByName` — so **host** `CObj` is a legal owner if the decl is classified as a method of a class named `CObj`.

Commit then skips `globalFunctions` / `globalFunctionList` when `objectType != 0`, but **always** `scriptFunctions.PushLast(func)` and may `objType->methods.PushLast(func->id)`.

`asCModule::GetFunctionCount()` (1033–1035) is `globalFunctionList.GetLength()`. The test helper therefore cannot see a method. F1 inverse **can** produce this RED **without** empty `functionDecls`.

`ActOnFunctionLike` (`as_sema_decl.cpp` 752–770) intern a **METHOD** only when `parentKind` is `CLASS`/`INTERFACE`; otherwise `ActOnFunctionDecl` → `DECL_FUNCTION`. Global `ParseFunction()` (`as_parser.h:140`) is `isMethod=false`, `notifySemaAfterParams=true`. File-scope `int F()` is interned under the TU, not under a script `DECL_CLASS`. This fixture has **no** script class; `RegisterCanonicalScriptTypes` only materializes TU-direct `DECL_CLASS` (1790–1809). Host `RegisterObjectType("CObj")` is not a script class child of the TU.

So F1 inverse is **mechanically possible** if intern mis-parents `F` under a `DECL_CLASS` named `CObj` (host type then binds). It is **not** the default classification for this source shape.

---

## 4. If AST never interned `F`, dump has no `DECL_FUNCTION`

`asCSema::ActOnFunctionDecl` (`as_sema.cpp` 262–268) is `CreateDecl(asAST_DECL_FUNCTION, ...)`. Live collect **always** takes `DECL_FUNCTION`, body or not (2063). Therefore:

- `DECL_FUNCTION F` in the sealed graph Generate walks ⇒ `functionDecls` is non-empty ⇒ signature+Emit run ⇒ on success Commit with `objectType==0` ⇒ **global `int F()` exists** (this RED cannot happen).
- Empty-body `DECL_FUNCTION` still publishes a global (Emit 194–197 skips body, still `Ret`). The RED would then fail execute-42 / opcode, **not** `{<no functions>}`.
- `EmitDeclRef` of an unresolved identifier (`as_bytecode_codegen.cpp` 782–788) is `FailAt(..., asAST_VERIFY_DANGLING_ID)`. Identifier `null` is **not** `ttNull`; Sema `snConstant`/`ttNull` is the only `EXPR_NULL_LITERAL` path (`as_sema_expr.cpp` 769–771). Unresolved `null` as `EXPR_DECL_REF` with invalid `resolvedDecl` does **not** fail Seal (verifier only flags `resolvedDecl.IsValid() && GetDecl==0`, `as_ast_verifier.cpp` 416–418), but **would** fail Generate if that expr were emitted. The log has **no** `Canonical CodeGen failed`. So Generate did **not** emit a dangling `null` ref inside `F`.

Parser intern of `F` is **before** the body (`ParseFunction` NotifySema after params, then `ParseScript` NotifySema on the completed decl). `null` in the initializer **cannot** un-create a `DECL_FUNCTION` that already exists. If intern ran as `DECL_FUNCTION` and Generate saw it, this RED is impossible (globals or CodeGen fail).

Seal with no diagnostics + `GetDeclCount()!=0` (else Generate `DANGLING_ID`) + empty function-like collect ⇒ the sealed graph has a TU (and maybe vars/types) **without** `DECL_FUNCTION`/`METHOD`+body/`CTOR`/non-gen-`DTOR` named `F`. That is an **intern-before-Generate** hole (or a context that is not the interned graph). Dump: **no** `DECL_FUNCTION`.

---

## Conclusion

| Hypothesis | Live match to this RED | Why / why not leading |
| --- | --- | --- |
| Fifth-pass F1 empty-skip **before** globals/types | **No.** Order changed. Empty collect no longer early-returns before `RegisterCanonicalScriptTypes` / TU-direct `DECL_VAR`. | Stale finding. Empty list still **succeeds after** empty Commit — that fail-open is still how intern-miss becomes `Build()==0`. |
| F1 inverse (METHOD Commit skip) | Possible: globals empty, `scriptFunctions` **non-empty**, host `CObj` methods grow. | Not leading: this script is TU-scope `int F()`; `ActOnFunctionLike` intern `DECL_FUNCTION`; `FillFunctionSignature` does not set `objectType` on `FUNCTION`. |
| Intern-before-Generate (no function-like `F` in the graph Generate collected) | Matches `Build==0`, `{<no functions>}`, no CodeGen fail, no Seal fail. | **Leading.** Live collect would not drop a `DECL_FUNCTION`. Empty `functionDecls` + empty Commit is the F1 remainder that **hides** the intern miss. Dialect `null` is a body-poisoner (dangling `DECL_REF` would fail **Emit**, not intern of `F`); it is not sufficient by itself to explain missing globals unless intern of `F` never landed. |

**Leading explanation: intern-before-Generate**, with live F1 empty-`functionDecls` → empty `Commit()` → `asAST_VERIFY_OK` as the fail-open wrapper. Not fifth-pass pre-install skip. Not F1 owner-skip unless a dump shows `F` on `scriptFunctions`.

**Single dump that falsifies intern-before-Generate:** retain the sealed AST on the failing module (`GetCanonicalASTContext()` after `PublishCanonicalASTSnapshot` would otherwise drop it) and print `asCASTDump` decl kinds/names. A row `DECL_FUNCTION` / name `F` falsifies intern-miss. The same dump plus `module->scriptFunctions` vs `globalFunctionList` vs host `CObj` method count then decides the remainder: `scriptFunctions` has `F` with `objectType == CObj` is F1 inverse; `DECL_FUNCTION F` and empty `scriptFunctions` is a Generate collect/`GetDecl` hole (not F1 inverse, not intern). Identifier `null` vs `EXPR_NULL_LITERAL` is a follow-up on that dump, not a third exclusive cause of `{<no functions>}`.
