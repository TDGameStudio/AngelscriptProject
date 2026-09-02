# Wave B queued exclusive UBT — DeclContext lookup on sealed `scope->children`

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-declcontext**. **Queued.** Not this mutex.

**B-sealed-env holds UBT now** (`attachments/wave-b-sealed-env-next.md`: `EmitSwitch` + delete innermost-loop fallback). Do **not** start this package until that mutex is released. Do **not** UBT from this research session.

Companions: `attachments/async-work.md` §4; `attachments/async-dispatch.md`; `attachments/clang-ast-reference.md` (LLVM commit below); `attachments/wave-b-132-remaining.md` §2 `LookupInScope`.

This bite is **not** a 13.2 / 5.4 / 5.5 / 5.6 / 5.9 / 4.2 / 9.5 close. Do not check those boxes.

LLVM/Clang is **shape only**. Do not link. Do not copy Clang types (`DeclContext`, `StoredDeclsMap`, `DeclarationName`, `NamedDecl`, `lookup_result`) into the fork. No Unreal types in fork frontend files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | **LANDED 2026-08-22.** Exclusive UBT closed. SemaAuthority **249/249**, CanonicalAST **319/319**, Compiler **509/509** (`succeeded=508`, `succeededWithWarnings=1`). Did **not** mark `tasks.md`. |
| Gate (dispatch) | SemaAuthority **248/248**, CanonicalAST **316/316**, Compiler **506/506** (`succeededWithWarnings=1`). Isolated **4/4**. Semantics **12/12**. After B-sealed-env lands, ProductionCodeGen / Compiler counts may grow; SemaAuthority stays 248 until this test |
| Do not mark | **any remaining OpenSpec box** |
| Skills | `superpowers:test-driven-development` then `superpowers:verification-before-completion` |
| Clang | `Reference/llvm-project` commit `9bc4fd0fafb58ff1fb50231e39a882a678542dac` (2026-08-09) |

---

## 0. Already true — do not redo / do not restore

- `CreateDecl` already appends the new id to `parent->children` (`as_ast_context.cpp:164-171`). Lexical membership is not the hole.
- Every `ActOn*Decl` that creates a named language decl also `InsertSymbol`s (table below). Construction-API `ActOnFunctionDecl` / `ActOnVarDecl` / `ActOnParamDecl` tests stay GREEN today **because** of `symbols[]`, not because lookup reads children.
- `LookupCandidatesFrom` already grovels **CLASS/INTERFACE** children that are **VAR/PROPERTY** (`as_sema.cpp:117-129`) when `LookupInScope` returned 0. That is a partial `localUncachedLookup`. It does **not** see FUNCTION / METHOD / PARAM / namespace members / TU members.
- `InternNativeGlobals` / `InternNativeMethods` / `InternNativeProperties` go through `ActOnFunctionDecl` / `ActOnMethodDecl` / `ActOnVarDecl` (`as_sema_expr.cpp:378`, `:543`, `:453`) — they **do** `InsertSymbol`. They are not the RED fixture.
- Sidecar restore (`as_ast_sidecar.cpp:203`) is `CreateDecl` only — no `InsertSymbol`. That is production evidence the hole is real; do **not** make sidecar the first oracle (heavier than construction-API).
- InitPlan 42. MemberRef 42. Native 0-arg intern. Dummy CONSTRUCT **deleted**. `GetFirstProperty` **gone** from `as_bytecode_codegen.cpp`.
- FindExistingExpr: kind + begin; **when request end nonzero, also match end**. Do **not** globally full-span `FindExistingExpr` / `FindExistingStmt`.
- ObjectTypeFromExpr: unwrap then **only** `bridge->Resolve`.
- Compile-seal dumps for inner **function** overload (`NamespaceOverloadSelectsScopedFunctionNotGlobal`) and inner **var** (`CompileSealInnerShadowedVarSelectsFloatNotGlobalInt`) already GREEN — they intern through `ActOn*` so `InsertSymbol` ran. They do **not** prove children lookup.
- Fork dialect: no script `funcdef` / `@` / `is`. Host `RegisterFuncdef` already covered. Do not intern script funcdef.

Must-stay-green after this bite: SemaAuthority previous 248 + 1, CanonicalAST previous + 1, Compiler previous + 1, Isolated 4/4, Semantics 12/12, `SemaScopeLookupReturnsBothOverloadCandidatesNotFirstName` **exactly 2** hits, `SemaScopeLookupPrefersCurrentContextThenOuterAfterPop`, `UnresolvedDeclRefMissingIsErrorTypeNotInt` still ERROR / `unresolved-identifier:Missing`.

---

## 1. Live file:line — InsertSymbol / LookupInScope / LookupCandidatesFrom / callers

### 1.1 `InsertSymbol` — intern-time visibility table (dies with `asCSema`)

Declaration: `as_sema.h:141`.
Definition: `as_sema.cpp:67-79`. Shape:

```text
InsertSymbol(id):
  decl = GetDecl(id); skip if null or name empty
  symbols.push { scope = decl->parent, name = decl->name, id }
```

`asSSemaSymbol` is private on `asCSema` (`as_sema.h:158-164`). Not on `asCDecl`. Not sealed. Not in dumps.

| Line | Caller | Kind interned |
| --- | --- | --- |
| `as_sema.cpp:269` | `ActOnFunctionDecl` | FUNCTION |
| `as_sema.cpp:327` | `ActOnMethodDecl` | METHOD |
| `as_sema.cpp:342` | `ActOnConstructorDecl` | CONSTRUCTOR |
| `as_sema.cpp:358` | `ActOnDestructorDecl` | DESTRUCTOR |
| `as_sema.cpp:391` | `ActOnParamDecl` | PARAM |
| `as_sema.cpp:477` | `ActOnPropertyDecl` | PROPERTY |
| `as_sema.cpp:485` | `ActOnTypedefDecl` | TYPEDEF |
| `as_sema.cpp:493` | `ActOnMixinDecl` | MIXIN |
| `as_sema.cpp:508` | `ActOnInterfaceDecl` | INTERFACE |
| `as_sema.cpp:516` | `ActOnFuncDefDecl` | FUNCDEF (host only; do not add script funcdef tests) |
| `as_sema_decl.cpp:1580` | `ActOnNamespaceDecl` | NAMESPACE |
| `as_sema_decl.cpp:1588` | `ActOnClassDecl` | CLASS |
| `as_sema_decl.cpp:1596` | `ActOnEnumDecl` | ENUM |
| `as_sema_decl.cpp:1670` | `ActOnImportDecl` | IMPORT |
| `as_sema_decl.cpp:1679` | `ActOnVarDecl` | VAR |

`FinishDecl` (`as_sema.cpp:146-240`) writes `stableKey` only. It does **not** `InsertSymbol`.
`ActOnStart*` that create a new decl call the `ActOn*` above (so they InsertSymbol). Replay / `FindExisting*` paths skip InsertSymbol **and** skip CreateDecl — already in `children[]` and `symbols[]`.
`ActOnTranslationUnit` does not InsertSymbol (TU has no parent scope).

### 1.2 `LookupInScope` — this-context only, **symbols[] only today**

Declaration: `as_sema.h:144`.
Definition: `as_sema.cpp:81-96`.

```81:96:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp
asUINT asCSema::LookupInScope(asASTDeclId scope, const char* name, asCArray<asASTDeclId>& out) const
{
	if( name == 0 || *name == 0 )
	{
		return 0;
	}
	const asUINT before = out.GetLength();
	for( asUINT i = 0; i < symbols.GetLength(); ++i )
	{
		if( symbols[i].scope == scope && symbols[i].name.Equals(name) )
		{
			out.PushLast(symbols[i].id);
		}
	}
	return out.GetLength() - before;
}
```

Returns **all** same-name hits in this scope (overload set). Does **not** walk `GetDecl(scope)->children`. Does **not** walk parents.

Callers:

| File:line | Caller | Why it matters |
| --- | --- | --- |
| `as_sema.cpp:108` | `LookupCandidatesFrom` | First probe of each enclosing decl. If 0, maybe CLASS VAR/PROPERTY grovel, else parent |
| `as_sema_expr.cpp:124` | `FindDirectChildNamed` | Qualified `A::B` inner identifier — **this scope only** |
| `as_sema_stmt.cpp:58` | `FindExistingVar` | Local / param VAR reuse; PARAM is **not** VAR so param reuse is `ActOnStartParamDecl` children walk, not this helper |

### 1.3 `LookupCandidatesFrom` — enclosing DeclContexts, then a **narrow** children grovel

Declaration: `as_sema.h:143`.
Definition: `as_sema.cpp:98-134`.
`LookupCandidates` (`as_sema.h:142`, `as_sema.cpp:136-144`) is `LookupCandidatesFrom(CurrentDeclContext() or TU, name)`.

Callers of `LookupCandidatesFrom` (all miss a CreateDecl-only FUNCTION/PARAM/namespace member):

| File:line | Caller |
| --- | --- |
| `as_sema.cpp:143` | `LookupCandidates` |
| `as_sema.cpp:719` | `ActOnDeclRefExpr` — prefers VAR among hits, else `hits[0]`; `range.begin.fileID == 0` miss → diagnostic `unresolved-identifier:<name>` + ERROR type (see `UnresolvedDeclRefMissingIsErrorTypeNotInt`) |
| `as_sema_expr.cpp:113` | `FindNamedDecl` — first hit (scope owner for `A::B`) |
| `as_sema_expr.cpp:1530` | `FindFuncdefHandle` — PARAM/VAR whose type is host funcdef |
| `as_sema_expr.cpp:1623` | `FindBestCallee` — FUNCTION/METHOD/CONSTRUCTOR/MIXIN/IMPORT by name then rank |

Live CLASS/INTERFACE grovel (`as_sema.cpp:117-129`) is why a CreateDecl-only **class field** would already resolve. It is **not** why a CreateDecl-only **function** resolves. Do not use a CLASS VAR as the RED fixture — it can PASS without touching `LookupInScope`.

### 1.4 After Seal

`Seal()` rejects further `CreateDecl`. `asCSema::symbols[]` is **not** copied onto the context. Backends (`asCBytecodeCodeGen::Generate(const asCASTContext&, …)`) never see the table. 13.2 remaining (`wave-b-132-remaining.md`): lookup is still intern-time Sema, not a sealed DeclContext.

This bite does **not** move lookup onto a const context API. It makes `LookupInScope` read the same `children[]` Seal already preserves, so lookup no longer **depends** on `symbols[]`.

---

## 2. Clang analogue (shape only)

Local source: `Reference/llvm-project`, commit `9bc4fd0fafb58ff1fb50231e39a882a678542dac`.

Do **not** copy these types. Map responsibilities:

| Clang | Fork today | Fork after GREEN |
| --- | --- | --- |
| `DeclContext` lexical chain (`FirstDecl` / `noload_decls`) | `asCDecl::children` + `parent` | unchanged (already the sealed graph) |
| `addHiddenDecl` — “Add the declaration D to this context **without modifying any lookup tables**” (`DeclBase.h:2572-2578`) | `asCASTContext::CreateDecl` (`as_ast_context.cpp:136-173`) | unchanged |
| `makeDeclVisibleInContext` (`DeclBase.h:2617-2631`) | `InsertSymbol` | keep as intern-time cache **optional** |
| `DeclContext::lookup(Name)` — “will **not** look into parent contexts” (`DeclBase.h:2593-2598`); impl `DeclBase.cpp:1902-1909` → `lookupImpl` | `LookupInScope` | same contract; **source of names = children** |
| `noload_lookup` — visible names, **don’t load external AST** (`DeclBase.h:2600-2603`; `DeclBase.cpp:1974-1992`) | no PCH/modules; closest is “don’t require `symbols[]` rebuild” | walk already-interned `children[]` |
| `localUncachedLookup` slow path — “grovel through the declarations in our chain looking for matches” (`DeclBase.cpp:2035-2043`) | CLASS/INTERFACE VAR/PROPERTY grovel only | **all named children** of the scope (FUNCTION/PARAM/VAR/METHOD/…) |
| `buildLookup` / `StoredDeclsMap` rebuilt from lexical decls (`DeclBase.cpp:1833-1899`) | `symbols[]` filled only at InsertSymbol | cache may remain; **must be rebuildable from children** and must not be the only source |
| Transparent DC (`LinkageSpec`/`Export` lookup in parent, `DeclBase.cpp:1904-1906`) | no such kinds | do **not** invent |
| `Sema` walks enclosing `DeclContext`s | `LookupCandidatesFrom` parent walk | keep parent walk; stop special-casing only VAR/PROPERTY |

Quote shape (`DeclBase.h:2593-2598`):

> lookup - Find the declarations (if any) with the given Name in this context. … Note that this routine will not look into parent contexts.

Quote shape (`DeclBase.cpp:2035-2043`):

> Slow case: grovel through the declarations in our chain looking for matches. … if (ND->getDeclName() == Name) Results.push_back(ND);

Fork translation: `LookupInScope(scope, name)` appends every `scope->children[i]` whose `name` equals, for named language decls. Parents stay `LookupCandidatesFrom`.

---

## 3. ONE next TDD bite

### 3.1 TEST_METHOD

**`SemaLookupInScopeFindsChildFunctionWithoutInsertSymbol`**

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Place near the other intern-time lookup methods (`SemaScopeLookupPrefersCurrentContextThenOuterAfterPop` ~3445, `SemaScopeLookupReturnsBothOverloadCandidatesNotFirstName` ~3472). Construction-API. **No** `Build()`. **No** script section. **No** `Parser`. **No** `InsertSymbol` (do not call it from the test). **No** `ActOnFunctionDecl` / `ActOnParamDecl` / `ActOnVarDecl` for the hidden names.

Why FUNCTION on the TU, not VAR on a CLASS: CLASS/INTERFACE children that are VAR/PROPERTY already resolve via `LookupCandidatesFrom` `:117-129`. A class-field CreateDecl fixture can PASS with zero production edits. A TU FUNCTION cannot.

### 3.2 Smallest fixture

Mirror `SemaStartFunctionDeclActionRecordsKindWithoutScriptNode` / `UnresolvedDeclRefMissingIsErrorTypeNotInt` (native engine + `asCASTContext` + `asCSema`). Default `asCSourceRange` has `fileID == 0`, so a lookup miss takes the `unresolved-identifier:` path (`as_sema.cpp:736-750`) — that is the RED.

```cpp
TEST_METHOD(SemaLookupInScopeFindsChildFunctionWithoutInsertSymbol)
{
	AngelscriptNativeTestSupport::FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };

	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	asCASTContext Context;
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("SemaChildLookup");
	const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
	const asCSourceRange Range;

	// addHiddenDecl analogue: lexical child, no makeDeclVisibleInContext / InsertSymbol.
	const asASTDeclId HiddenF = Context.CreateDecl(asAST_DECL_FUNCTION, Tu, Range, "HiddenF");
	ASSERT_THAT(IsTrue(HiddenF.IsValid(), TEXT("CreateDecl FUNCTION must attach a TU child")));
	Context.SetDeclType(HiddenF, IntType);
	Sema.FinishDecl(HiddenF); // stableKey only; must not InsertSymbol

	asCArray<asASTDeclId> scopeHits;
	ASSERT_THAT(AreEqual(1, (int)Sema.LookupInScope(Tu, "HiddenF", scopeHits),
		TEXT("LookupInScope must grovel TU children, not only symbols[]")));
	ASSERT_THAT(IsTrue(scopeHits.GetLength() > 0 && scopeHits[0] == HiddenF,
		TEXT("the CreateDecl FUNCTION id is the hit")));

	const asASTExprId Ref = Sema.ActOnDeclRefExpr(Tu, "HiddenF", Range);
	ASSERT_THAT(IsTrue(Ref.IsValid(), TEXT("ActOnDeclRefExpr must intern")));
	const asCExpr* Expr = Context.GetExpr(Ref);
	ASSERT_THAT(IsNotNull(Expr, TEXT("DeclRef node")));
	ASSERT_THAT(IsTrue(Expr->resolvedDecl == HiddenF,
		TEXT("resolvedDecl must be the CreateDecl child, not an invented miss")));
	ASSERT_THAT(IsTrue(!CanonicalASTSemaAuthorityTest::SemaHasDiagnosticPrefix(Sema, "unresolved-identifier:HiddenF"),
		TEXT("must not take the fileID==0 miss path")));

	asCString Dump;
	asCASTDump(Context, Dump);
	const FString Text = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Dump);
	const FString DumpMsg = FString::Printf(
		TEXT("CreateDecl FUNCTION HiddenF must resolve DeclRef. dump:\n%s"), *Text);
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Function name=HiddenF")), *DumpMsg));
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=DeclRef")), *DumpMsg));
	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("type=<unresolved>")), *DumpMsg));
	ASSERT_THAT(IsTrue(!Text.Contains(TEXT("typeKind=Error")), *DumpMsg));
	// Dump callee= uses stableKey after FinishDecl → HiddenF()
	ASSERT_THAT(IsTrue(Text.Contains(TEXT("callee=HiddenF()")) || Text.Contains(TEXT("literal=HiddenF")),
		*DumpMsg));
}
```

Do **not** `Seal()` before `ActOnDeclRefExpr` (post-seal mutation). Children after `CreateDecl` are the same list Seal will freeze.

Do **not** add a compile-seal `Build()` script as this first oracle: `WalkOne` / `ActOnFunctionDecl` will `InsertSymbol`, so the test would PASS today.

Optional same-method PARAM (only if the FUNCTION asserts are already written and you want a second hit in one RED): `CreateDecl(asAST_DECL_PARAM, HiddenF, Range, "a")` + `SetDeclType` + `LookupInScope(HiddenF, "a")` + `ActOnDeclRefExpr(HiddenF, "a")`. Not required. Walking **all named children** makes PARAM/VAR/METHOD fall out of the FUNCTION fix. Do **not** add a second `TEST_METHOD` in this mutex.

### 3.3 Expected RED today

No UBT in the 梳理 session. RED from live `LookupInScope`:

| Check | Today | GREEN |
| --- | --- | --- |
| `LookupInScope(Tu, "HiddenF")` | **0** (`symbols[]` empty for that name) | **1**, `hits[0] == HiddenF` |
| `ActOnDeclRefExpr` `resolvedDecl` | invalid | `HiddenF` |
| diagnostic | `unresolved-identifier:HiddenF` | none for HiddenF |
| dump | `kind=DeclRef` `type=<unresolved>` `typeKind=Error` (same as `UnresolvedDeclRefMissingIsErrorTypeNotInt`) | DeclRef to HiddenF, **not** ERROR |

If the new method PASSes immediately: stop. Record “children lookup already landed”. Do **not** restyle `LookupInScope`. Do **not** start unique-bind in surprise-GREEN.

If the test errors (compile / crash / `CreateDecl` not visible): fix the test first. `as_sema.h` already includes `as_ast_context.h`. Do not implement lookup until the failure is **0 hits / unresolved**.

---

## 4. GREEN production change (only this)

File: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp` — `LookupInScope` (`:81-96`).

**Authoritative:** walk `GetDecl(scope)->children` by `child->name.Equals(name)`. Include at least FUNCTION / PARAM / VAR / METHOD (also PROPERTY / CONSTRUCTOR / DESTRUCTOR / MIXIN / IMPORT / NAMESPACE / CLASS / INTERFACE / ENUM / TYPEDEF — any named child, Clang `NamedDecl`). Skip empty names (same as `InsertSymbol`).

**Cache:** `symbols[]` **may** stay as intern-time cache during Sema. Lookup **must not depend** on it being populated.

**Dedupe (required if both sources are scanned):** `SemaScopeLookupReturnsBothOverloadCandidatesNotFirstName` asserts **exactly 2** hits for `F(int)` + `F(float)`. `ActOnFunctionDecl` both InsertSymbols **and** CreateDecl-appends. Naïve `symbols[]` then children → 4. Skip an id already in `out`, **or** walk children only and leave `symbols[]` unused by lookup.

**Do not:**

- store `asCScriptFunction*` / engine function id on sealed decls
- change `LookupCandidatesFrom` parent walk
- require deleting the CLASS/INTERFACE VAR/PROPERTY grovel (it becomes dead once `LookupInScope` returns > 0 on those children; leaving it is fine; if you keep it **and** `LookupInScope` misses, you still have the FUNCTION hole)
- make `LookupInScope` walk `parent` (that is `LookupCandidatesFrom`)
- copy Clang `StoredDeclsMap` / `DeclarationName`
- touch `as_bytecode_codegen.cpp` (B-sealed-env + unique-bind)
- globally full-span `FindExisting*`
- intern script `funcdef` / `@` / `is`

`LookupCandidatesFrom` stays: this-scope `LookupInScope`; if empty, parent. After GREEN, CreateDecl-only FUNCTION/PARAM/namespace VAR resolve at the owning scope without InsertSymbol.

---

## 5. What NOT to fold

| Item | Why | Where |
| --- | --- | --- |
| **Control-target / `EmitSwitch` / last-loop fallback** | **Other agent. This mutex (B-sealed-env).** | `wave-b-sealed-env-next.md`. `as_bytecode_codegen.cpp` |
| **Global unique-bind** (`FindRegisteredGlobalFunction` name+`paramCount` first SYSTEM) | Different production file (`as_bytecode_codegen.cpp:61-96`, used `:3574`). Methods already unique-signature (`FindExactRegisteredMethod` `:98-237`, used `:3584`). **Following exclusive**, not bite 1 of this UBT. May share this **map**; must **not** share the live B-sealed-env UBT; after that mutex, do not fold into the DeclContext first cycle — lookup GREEN first, then a **later** exclusive (or a second cycle of **this** exclusive only after lookup is GREEN **and** codegen is free). Do **not** store `asCScriptFunction*` on the decl as the unique-bind fix. | this file §7 |
| Packed int8 execute 1934 | Other leftover | `wave-b-abi-width-next.md` |
| `HasConstructAssignTo` / `PropertyFromFieldDecl` ordinal / `fieldOffsets[]` | Generate-local leftover | `wave-b-codegen-remaining.md` |
| 13.2 close / Wave E–G / default CANONICAL | Honesty | `wave-b-132-remaining.md` |
| Global full-span `FindExistingExpr` / `FindExistingStmt` | Control stub fill stays kind+begin | — |
| Script `funcdef` / `@` / `is` / try-catch | Fork dialect | — |

Do **not** check 13.2 after this GREEN. Children lookup is one Sema-environment brick. Production Bytecode is still LEGACY `asCCompiler`. `symbols[]` / `controlStack` / `FindBestCallee` still live on Sema. CodeGen still re-binds globals by name+arity until the following exclusive.

---

## 6. TDD protocol and commands

Only from `D:\as-cta`. Always `-NoXGE` on build. `RunTests.ps1` does **not** UBT. Never All. Never `UnrealEditor-Cmd` direct. One UBT user. Do not start while B-sealed-env holds the mutex.

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-declcontext -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-declcontext-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-declcontext-canonicalast -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-declcontext-compiler -TimeoutMs 600000
```

Order:

1. Add `SemaLookupInScopeFindsChildFunctionWithoutInsertSymbol` only. No fork edits.
2. `RunBuild.ps1 -Label wave-b-declcontext-red -NoXGE`. SemaAuthority: **new method FAIL** (0 hits / `unresolved-identifier:HiddenF` / `type=<unresolved>`). Previous 248 PASS. `UnresolvedDeclRefMissingIsErrorTypeNotInt` still PASS.
3. Implement `LookupInScope` children grovel (+ dedupe if `symbols[]` still scanned).
4. Rebuild. New method PASS. `SemaScopeLookupReturnsBothOverloadCandidatesNotFirstName` still **2**. SemaAuthority **249/249** (or previous+1 if sealed-env added SemaAuthority tests). CanonicalAST / Compiler previous+1 (`succeededWithWarnings=1` ok).
5. Stop. Do not start unique-bind / EmitSwitch / 13.2.

If UBT says up to date while `as_sema.cpp` changed (often plugin git `??`): delete Runtime DLL + `Module.AngelscriptRuntime.48.cpp.obj` (sema `.48`; codegen `.44`; dump `.43`; context `.42`; sema_expr `.49`) then rebuild.

Copy reports to `C:\Users\scottmei\AppData\Local\Temp\grok-goal-cafa12c46849\implementer\` if that scratch exists.

Leave `tasks.md` 13.2 / 13.3 / 10.2 / 9.5 / 4.2 / 5.4 / 5.5 / 5.6 `[ ]`. Do not archive. Do not commit unless asked. Default pipeline stays LEGACY.

---

## 7. Following exclusive — global unique-bind (not this first cycle)

After DeclContext lookup GREEN **and** B-sealed-env has released `as_bytecode_codegen.cpp`:

`FindRegisteredGlobalFunction` (`:61-96`) matches first `asFUNC_SYSTEM` with **name + `parameterTypes.GetLength() == paramCount`**. Two host overloads of the same arity can bind the wrong function. Methods already require unique signature (`FindExactRegisteredMethod`).

GREEN for that later bite: same uniqueness as methods (name + resolved param types + return / in-out), miss → 0 / fail-closed. **Still do not store `asCScriptFunction*` on the sealed decl** — engine mapping stays a bind table keyed by interned decl id / signature, like methods.

Do **not** implement it under the DeclContext first TDD cycle. Do **not** implement it under B-sealed-env.

---

## 8. Stay-unchecked

Leave `[ ]`: **13.2 / 13.3 / 10.2 / 9.5 / 4.2 / 5.4 / 5.5 / 5.6 / 9.1 / 13.1**.

9.3 虚标 is B-sealed-env’s problem, not this package.

Do not archive. Do not commit unless asked. Default pipeline stays LEGACY.
