# Wave B — CALL callee= and honest global DECL_VAR

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. The four SemaAuthority methods are already on disk. RunBuild + SemaAuthority **before** editing `as_sema_expr.cpp` / `as_sema_decl.cpp`. Do **not** check `tasks.md` 13.2 / 4.2 / 5.3 / 5.9 / 9.1 / 13.6. Do **not** start Wave D Task 6.

**Status:** **LANDED 2026-08-21.** SemaAuthority **90/90**, CanonicalAST **105/105**, Frontend CanonicalAST **77/77**, Compiler **293/293**. Leave 13.2 `[ ]`. Do not start D Task 6.

**Goal:** Sealed dumps record real CALL `callee=` for funcdef PARAM/VAR handles and function→funcdef conversions, and intern rejected mutable script globals as TU `DECL_VAR` plus `mutable-global-rejected`.

**Architecture:** Clang-shaped Sema already owns `ActOnCall` / `FindBestCallee` / `RankArgument` / WalkOne `snDeclaration`. Fill the two holes that produce `callee=` empty and `globals=0`. Production Bytecode stays `asCCompiler`. Isolated CodeGen already has `FindFunc` then `FindSlot` for PARAM/VAR callees.

**Tech Stack:** Maintained AngelScript fork. CQTest SemaAuthority prefix. Host `RegisterFuncdef` only. No Unreal types in fork files. No Clang/LLVM.

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-call-callee** |
| Mode | Exclusive UBT |
| Default pipeline | LEGACY |
| `Ready()` | false |

## Global constraints

- TDD. SemaAuthority prefix first.
- Host `RegisterFuncdef("int Callback(int)")` only. Do not re-enable script `funcdef` / `@` / `is`.
- Do not mark 13.2. Criterion (4) is still false (`asCCompiler` on `Build()`).
- Do not start production `Build()` / Ready() true / default CANONICAL.
- CALL-without-callee remains a hard no for the verifier firewall. Filling `resolvedDecl` with the PARAM/VAR handle is the opposite of that.
- Intern the rejected mutable global, then diagnostic. Do not `break` before `ActOnVarDecl`. Keep `Build() != 0` via asCCompiler.
- No Unreal types in fork files. No Clang/LLVM link.
- Do not commit. Do not archive.
- Commands from `D:\as-cta` only:

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label <label>
Tools\RunTests.ps1 -TestPrefix "<prefix>" -Label <label>
```

---

## File map

| Path | Role |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Tests already written: `ConstGlobalTraitAndMutableReject` requires interned `kind=Var name=Mutable`; three new CALL methods. Do not rewrite them down. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | `RankArgument`, `FindBestCallee`, `ResolveCallee`, `snFunctionCall` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` | WalkOne `snDeclaration` mutable-global `break` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` | Observer only. `callee=` comes from `resolvedDecl` `stableKey`/`name`. Do not special-case empty callee. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` | Do not edit in this package. Indirect CALL already `FindFunc` then `FindSlot`. |

---

### Task 1: Prove RED on the four SemaAuthority methods

**Files:** tests already on disk. No fork edits.

- [ ] **Step 1: Build**

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label wave-b-call-callee-red
```

Expected: exit 0.

- [ ] **Step 2: Run SemaAuthority and require the new contracts to fail**

```powershell
Set-Location D:\as-cta
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-call-callee-red
```

Expected RED (not a hang, not a compile error):

| Method | Why it must fail today |
| --- | --- |
| `ParserActOnFuncdefParamCallRecordsCallee` | `Cb(X)` dumps `callee=` empty (`literal=call:reverse-formal callee= nargs=`) |
| `ParserActOnFuncdefLocalCallRecordsCallee` | `L(1)` same empty `callee=` |
| `ParserActOnNamedCallConvertsFunctionToFuncdef` | `Invoke(Double, 3)` not selected; empty `callee=` and no Conversion |
| `ConstGlobalTraitAndMutableReject` | dump has no `kind=Var name=Mutable` because WalkOne `break`s before intern |

If any of those four is already GREEN, stop and re-read dumps before changing Sema — do not weaken the tests.

Last control-body GREEN was 87/87. This prefix should now be 90 methods with four failures (or 87 + 3 new + rewritten const/mutable).

---

### Task 2: Function→funcdef conversion rank

**Files:** Modify `as_sema_expr.cpp` `RankArgument` / `FindBestCallee` only after Task 1 RED.

`RankArgument` today (QualTypes only):

```cpp
static int RankArgument(asCASTContext& context, const asCQualType& paramType, const asCQualType& argType)
{
	if( QualTypesMatch(paramType, argType) )
	{
		return 2;
	}
	// int↔float ranks 1/0, else -1
}
```

`FindBestCallee` calls it as `RankArgument(context, param->type, arg->type)`. A DeclRef to `Double` carries the function **return** type (`int`), so `Callback` vs `int` is `-1` and `Invoke(Callback,int)` is not selected.

- [ ] **Step 3: Change RankArgument to see the argument expression**

Replace the QualType-only helper with one that reads `arg->resolvedDecl`:

```cpp
static bool IsFuncdefType(asCASTContext& context, const asCQualType& type)
{
	const asCType* named = context.GetType(type.type);
	return named && named->kind == asAST_TYPE_FUNCDEF;
}

static bool IsFunctionValuedDecl(const asCDecl* decl)
{
	return decl && (decl->kind == asAST_DECL_FUNCTION
		|| decl->kind == asAST_DECL_METHOD
		|| decl->kind == asAST_DECL_IMPORT);
}

static int RankArgument(asCASTContext& context, const asCQualType& paramType, const asCExpr* arg)
{
	if( arg == 0 )
	{
		return -1;
	}
	if( QualTypesMatch(paramType, arg->type) )
	{
		return 2;
	}
	if( IsFuncdefType(context, paramType) )
	{
		const asCDecl* value = arg->resolvedDecl.IsValid() ? context.GetDecl(arg->resolvedDecl) : 0;
		if( IsFunctionValuedDecl(value) )
		{
			return 1;
		}
	}
	const asCType* param = context.GetType(paramType.type);
	const asCType* argType = context.GetType(arg->type.type);
	if( IsFloatPrimitive(param) && IsIntegerPrimitive(argType) )
	{
		return 1;
	}
	if( IsIntegerPrimitive(param) && IsFloatPrimitive(argType) )
	{
		return 0;
	}
	return -1;
}
```

Update the single call site in `FindBestCallee`:

```cpp
const int rank = RankArgument(context, param->type, arg);
```

Do not change `FindBestCallee`’s FUNCTION/METHOD/… filter in this step. `Invoke` itself is a FUNCTION; only the *argument* rank was `-1`.

`snFunctionCall` already wraps mismatched args with `ActOnConversion` after a callee is chosen. Once `Invoke` is selected, `Double` should intern `kind=Conversion` (or dump `callee=Double(int)` on the DeclRef). Do not add a second conversion rewrite unless RED still lacks Conversion.

- [ ] **Step 4: Rebuild and rerun SemaAuthority**

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label wave-b-call-callee-rank
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-call-callee-rank
```

Expected: `ParserActOnNamedCallConvertsFunctionToFuncdef` closer to GREEN. `Cb(X)` / `L(1)` / Mutable Var still RED.

---

### Task 3: PARAM/VAR FUNCDEF as indirect CALL callee

**Files:** `as_sema_expr.cpp` `ResolveCallee` after `FindBestCallee` fails.

`FindBestCallee` must **keep** skipping PARAM/VAR. Those are not overload candidates for a direct call. After a total miss, resolve the name as a funcdef handle:

```cpp
static asASTDeclId FindFuncdefHandle(asCSema& sema, asCASTContext& context, asASTDeclId searchOwner, const char* name)
{
	if( name == 0 || name[0] == 0 )
	{
		return asASTDeclId();
	}
	asCArray<asASTDeclId> hits;
	sema.LookupCandidatesFrom(searchOwner, name, hits);
	for( asUINT i = 0; i < hits.GetLength(); ++i )
	{
		const asCDecl* decl = context.GetDecl(hits[i]);
		if( decl == 0 || (decl->kind != asAST_DECL_PARAM && decl->kind != asAST_DECL_VAR) )
		{
			continue;
		}
		if( IsFuncdefType(context, decl->type) )
		{
			return hits[i];
		}
	}
	return asASTDeclId();
}
```

At the end of `ResolveCallee`, after `FindBestCallee`:

```cpp
	const asASTDeclId direct = FindBestCallee(context, searchOwner, name, args, &sema);
	if( direct.IsValid() )
	{
		return direct;
	}
	return FindFuncdefHandle(sema, context, searchOwner, name);
```

Dump `callee=` uses `stableKey` else `name`. PARAM is not parent-qualified in `FinishDecl`, so `callee=Cb` / `callee=L` match the tests.

Call result type: `ActOnCall` currently copies `decl->type`. For PARAM/VAR that is the FUNCDEF handle, not the invoke return. Isolated CodeGen `FindSlot` does not need the return type to be perfect for dump GREEN. If SemaAuthority Seal fails because CALL type is FUNCDEF, set result type from the handle’s named type only as a follow-up — do not invent a fake FUNCTION decl.

Do not intern a CALL with invalid `resolvedDecl` to “pass” dumps. Empty `callee=` is the bug.

- [ ] **Step 5: Rebuild and rerun SemaAuthority**

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label wave-b-call-callee-handle
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-call-callee-handle
```

Expected: the three CALL methods GREEN. Mutable Var still RED.

---

### Task 4: Intern rejected mutable globals

**Files:** `as_sema_decl.cpp` WalkOne `snDeclaration` (~1119–1128).

Today:

```cpp
			if( parentDecl
				&& (parentDecl->kind == asAST_DECL_TRANSLATION_UNIT || parentDecl->kind == asAST_DECL_NAMESPACE)
				&& primitiveGlobal
				&& (type.quals & asAST_QUAL_CONST) == 0 )
			{
				sema->AddDiagnostic("mutable-global-rejected");
				break;
			}
			asASTDeclId existingVar = FindExistingNamedDecl(...);
```

- [ ] **Step 6: Intern then diagnostic**

Delete the `break`. Keep `AddDiagnostic`. Fall through to `ActOnVarDecl` / `NoteActedDecl`. Const globals (`quals=1`) stay interned without that diagnostic.

Do not make `Build()` succeed. `ConstGlobalTraitAndMutableReject` still asserts `MutableBuildModule->Build() != 0`.

If some other test required “no `kind=Var name=Mutable`”, keep intern and assert diagnostic presence instead. Do not drop intern.

- [ ] **Step 7: GREEN SemaAuthority**

```powershell
Set-Location D:\as-cta
Tools\RunBuild.ps1 -NoXGE -Label wave-b-call-callee-green
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-call-callee-green
```

Expected: all SemaAuthority methods PASS (90/90 if the three new methods are discovered; record the actual count).

---

### Task 5: Regression prefixes (not cutover)

- [ ] **Step 8: Compiler CanonicalAST then Frontend CodeGen then Compiler**

```powershell
Set-Location D:\as-cta
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-call-callee-canonical
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-b-call-callee-frontend
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-call-callee-compiler
```

Expected:

- CanonicalAST: previous 102 plus the new SemaAuthority methods, all PASS.
- Frontend CanonicalAST: CodeGen parent **31/31** is the hoped regression (was 24/31 on empty `callee=` / missing `G`). Transaction **7/7** and Cutover **5/5** stay green with Ready false.
- Compiler: previous **290/290** plus new methods, no new fails.

If Frontend CodeGen still fails after honest dumps, debug CodeGen lowering with systematic-debugging. Do **not** start Task 6. Do **not** mark 9.5.

- [ ] **Step 9: Leave boxes `[ ]`**

Do not check 13.2 / 4.2 / 5.3 / 5.9 / 9.1 / 13.6 / 10.4. Patch progress notes only.

---

## Spec coverage

| Requirement | Task |
| --- | --- |
| Sealed CALL shows selected callee / conversion | Tasks 2–3 |
| Funcdef handle CALL is PARAM/VAR `resolvedDecl`, not empty | Task 3 |
| Honest global DECL_VAR + language rejection | Task 4 |
| Isolated CodeGen can see those facts | Task 5 regression |
| Production backends do not rerun Sema | **Not this package** (13.2 criterion 4) |
| `Build()` → `Generate()` | **Blocked D-task-6** |

## Placeholder scan

No TBD. Exact commands, files, and code are above.

## Type consistency

`FindFuncdefHandle` / `IsFuncdefType` / `IsFunctionValuedDecl` / `RankArgument(context, paramType, arg)` are the names later steps use. Do not rename mid-slice.

## Stop

After Task 5, exclusive UBT may move to **B-sema-remainder** (remaining WalkOne interiors) or wait. **C-debug-impl** must not share `as_ast_dump.cpp` until CALL dump lines are stable. **D-task-6** stays blocked.
