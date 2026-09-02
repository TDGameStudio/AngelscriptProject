# Wave B research — next exclusive UBT after B-ctor-green: Sema-owned 0-arg construct

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-ctor-zeroarg**. Design map only. **Not this mutex.** Exclusive UBT starts after `wave-b-ctor-green.md` is GREEN.

Companions: `wave-b-ctor-green.md` (current exclusive; keep 0-arg arity fallback there); `wave-b-ninth-f2-exact-binding.md` §2.4 dummy / factory; `async-work.md` / `async-dispatch.md` (do not edit).

This bite is **not** a 13.2 / 9.4 / 5.4 close. Do not check those boxes.

LLVM/Clang is a **shape** reference only. Do not link. No Unreal types in fork frontend files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Design map. Next exclusive UBT after B-ctor-green. Do not implement in that mutex. |
| Gate | B-ctor-green ProductionCodeGen ctor/factory execute 42; ArrayInt/Method/Member still 42; 1-arg arity walks gone; 0-arg dummy still `FindConstructorId(0)` / `FindFactoryId(0)` |
| Do not mark | **any remaining OpenSpec box** |

---

## 0. Already true after B-ctor-green — do not redo

- Phase A Method+Member exact bind. Do **not** delete `FindExactRegisteredMethod`.
- Phase B 1-arg ctor/factory: `ActOnConstruct` intern when `args.GetLength() > 0`, `FindExactRegisteredConstructor`, native METHOD/CONSTRUCTOR no body not GENERATED → `continue` (no `asNEW`).
- Dummy VALUE `STMT_DECL` **zeros** `resolvedDecl`. Do **not** restore `asCExpr dummyConstruct;` without that assign.
- `FindFunc` returns 0 if `!decl.IsValid()`.
- 0-arg emit still arity fallback. **This map owns deleting that fallback**, not B-ctor-green.
- Must-stay-green: `CanonicalArrayIntBuildPublishesCodeGenAndExecutes`, script overload, generated accessors, FValue, import CALLBND, Method execute 42, Member execute 42, Constructor/Factory 1-arg execute 42.

Tactical patch that restored ArrayInt: intern native ctor/factory **only** when `args.GetLength() > 0`. That is **not** Sema-owned 0-arg construct.

---

## 1. Live file:line (this worktree)

Paths are under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` unless noted.

### 1.1 Dummy VALUE `STMT_DECL` invents a 0-arg CONSTRUCT — `as_bytecode_codegen.cpp:2683-2709`

```2683:2709:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			case asAST_STMT_DECL:
				if( stmt->decl.IsValid() && FindSlot(stmt->decl) == 0x7fffffff )
				{
					// ...
					if( dataType.IsObject() && !dataType.IsObjectHandle()
						&& dataType.GetTypeInfo()
						&& (dataType.GetTypeInfo()->GetFlags() & asOBJ_VALUE) )
					{
						asCExpr dummyConstruct;
						dummyConstruct.kind = asAST_EXPR_CONSTRUCT;
						dummyConstruct.type = var->type;
						dummyConstruct.resolvedDecl = asASTDeclId();
						if( EmitConstructInto(&dummyConstruct, slot, dataType) == 0 && !ok )
```

- CodeGen-local `asCExpr`. **Not** in the sealed AST. No children. `resolvedDecl` invalid.
- VALUE only (`asOBJ_VALUE` and not handle). REF `array<int> Values;` does **not** enter this dummy.
- `asCExpr()` (`as_expr.h:26-32`) does not list `resolvedDecl` in the initializer list. `asASTDeclId()` zeros (`Core/angelscript.h:979`), and the dummy **also** assigns `asASTDeclId()` (`:2704`). Keep the assign. Historical AV: interned REF factory in `binds` + `FindFunc` on a dummy/stale DeclId + VALUE `PSF`+`CALLSYS` path on a factory (`CallSystemFunction` read 0x38 / write `0x00000003000002a6`).

### 1.2 `EmitConstructInto` 0-arg arity fallback — `as_bytecode_codegen.cpp:1973-2020`

```1995:2020:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			asCScriptFunction* ctor = FindFunc(expr->resolvedDecl);
			// SYSTEM && !isValue → treat as factory (CALLSYS + STOREOBJ)  :2000-2006
			if( (ctor == 0 || ctorId <= 0) && (factory == 0 || factoryId <= 0)
				&& expr->children.GetLength() == 0 )
			{
				ctorId = FindConstructorId(objType, 0);   // :561-603
				// else
				factoryId = FindFactoryId(objType, 0);    // :605-614; userArgCount==0 → immediate beh.factory
			}
```

`FindFactoryId(0)` returns `objType->beh.factory` with **no signature** (`:611-614`). Template `array<T> f(int&in)` does not set template `beh.factory` (`as_scriptengine.cpp:2355-2358`, param count 1). Instance `array<int>` `GenerateTemplateFactoryStub` drops the hidden param and sets `ot->beh.factory = func->id` (`:3628-3629`). ArrayInt execute 42 today is this stub, not a Sema DeclId.

ASSIGN of a real CONSTRUCT also calls `EmitConstructInto` (`:1791-1798` handle, `:1824-1831` VALUE). Dummy and Sema sibling can **double-construct** VALUE locals.

### 1.3 Collect-all `functionDecls` — `as_bytecode_codegen.cpp:3344-3358` (and hasFunctionLike `:3286-3302`)

```3344:3358:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
	asCArray<const asCDecl*> functionDecls;
	for( asUINT i = 1; i <= context.GetDeclCount(); ++i )
	{
		const asCDecl* decl = context.GetDecl(asASTDeclId(i));
		if( decl == 0 || !CanonicalDeclIsFunctionLike(decl->kind) )
			continue;
		if( decl->body.IsValid()
			|| decl->kind == asAST_DECL_FUNCTION
			|| decl->kind == asAST_DECL_CONSTRUCTOR
			|| decl->kind == asAST_DECL_METHOD
			|| decl->kind == asAST_DECL_DESTRUCTOR )
		{
			functionDecls.PushLast(decl);
		}
	}
```

`CanonicalDeclIsFunctionLike` (`:30-36`) includes **every** `DECL_CONSTRUCTOR`. There is no `DECL_FACTORY`. Native interned factories are constructors.

Bind loop (`:3526-3564`): `FindRegisteredGlobalFunction` → `FindExactRegisteredMethod` → `FindExactRegisteredConstructor` (`:239-407`) → else native METHOD/CONSTRUCTOR no body not GENERATED → `continue`. Every interned ctor/factory that unique-matches occupies `funcs[]`. Unused arities still bind.

### 1.4 Sema `ActOnConstruct` — `as_sema.cpp:1023-1088`

```1023:1028:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp
asASTExprId asCSema::ActOnConstruct(const asCQualType& type, const asCArray<asASTExprId>& args, const asCSourceRange& range)
{
	if( args.GetLength() > 0 )
	{
		InternNativeCallablesForType(type);
	}
```

Then `SelectConstructor` (`:936-1020`) ranks interned `DECL_CONSTRUCTOR` children by arity + primitive rank. 0-arg with **no** interned ctor → invalid `resolvedDecl`. `SetResolvedDecl` / `SetLiteral` still run (`:1078-1083`). Dump `callee=` is empty (`as_ast_dump.cpp:332-341`, `:410`).

`args.GetLength() > 0` is the tactical ArrayInt restore. It is **not** 0-arg intern.

### 1.5 `InternNativeCallablesForType` — `as_sema_expr.cpp:642-667` (decl `as_sema.h:85`)

```642:667:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp
void asCSema::InternNativeCallablesForType(const asCQualType& type)
{
	// FindNamedTypeDecl or ActOnClassDecl(TU, key)
	InternNativeBehaviourList(..., objectType->beh.constructors, false);
	InternNativeBehaviourList(..., objectType->beh.factories, true);
}
```

`InternNativeBehaviourList` (`:538-640`): **every** id in the list. Hidden type-id / template first param skipped so `array<T> f(int&in)` interns as **0 user params**. `ActOnConstructorDecl` (`as_sema.cpp:338-344`) + params + `FinishDecl`. `exists` is `DECL_CONSTRUCTOR` + `NativeBehaviourParamsMatch`. No arity filter.

`InternNativeMethods` (`as_sema_expr.cpp:391+`) does **not** call this. Do not start. `ActOnIndexExpr` intern `opIndex` (`:1126`) is METHOD, out of scope.

### 1.6 Default-init already has a real CONSTRUCT — `as_sema_stmt.cpp:72-106`, `:241-248`

```72:106:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp
static bool QualTypeNeedsDefaultConstruct(...)
{
	// VALUE_OBJECT && !handle, or TEMPLATE, or REFERENCE_OBJECT
}
static void AppendDefaultValueConstruct(...)
{
	asCArray<asASTExprId> args;
	const asASTExprId value = sema.ActOnConstruct(type, args, range);  // 0-arg
	const asASTExprId ref = sema.ActOnDeclRef(var, type, range);
	children.PushLast(sema.ActOnExprStmt(owner, sema.ActOnAssign(ref, value, type, range), range));
}
```

`EmitLocalDeclStmts` (`:241-248`): `STMT_DECL` then either init ASSIGN or `AppendDefaultValueConstruct`. `array<int> Values;` **does** call `ActOnConstruct` with 0 args. Same for VALUE `FBindBox b;` / script `FValue Object;`. Dummy `STMT_DECL` is a **second** 0-arg construct for VALUE.

Explicit `T()` is `snConstructCall` → `ActOnConstruct` (`as_sema_decl.cpp:1796-1811`).

### 1.7 Dead option-3 stub — `as_bytecode_codegen.cpp:410-454`

`FindInternedZeroArgConstructor(context, type)` walks `DECL_CLASS` children and returns the **first** 0-param `DECL_CONSTRUCTOR`. **Zero call sites.** Do not wire it.

---

## 2. Why collect-all `DECL_CONSTRUCTOR` + intern-all factories pollutes insertLast Generate

Script (ArrayInt / same-arity insertLast):

```angelscript
int F() { array<int> Values; Values.insertLast(41); return Values[0] + 1; }
```

One sealed TU, one Generate:

| Intern | Kind | How it enters `functionDecls` |
| --- | --- | --- |
| `insertLast` | `DECL_METHOD` | `InternNativeMethods` from `ActOnCallExpr`. Phase A. Keep. |
| `opIndex` | `DECL_METHOD` | `ActOnIndexExpr`. Keep. |
| **every** `beh.constructors` + **every** `beh.factories` | `DECL_CONSTRUCTOR` | only if `InternNativeCallablesForType` runs |

`AppendDefaultValueConstruct` always calls `ActOnConstruct(type, empty)`. Intern-on-**every**-`ActOnConstruct` (including 0-arg) therefore interned `array<T>` factories into the **same** context as insertLast.

Then Generate:

1. Collect-all `DECL_CONSTRUCTOR` (`:3344-3358`) pushes unused 1-arg / copy / extra factories, not only the 0-arg default.
2. `FindExactRegisteredConstructor` unique-matches each and `binds.PushLast` (`:3549-3557`).
3. Dummy / 0-arg CONSTRUCT with invalid `resolvedDecl` still `FindFunc`s the bind table, then VALUE `CALLSYS` or factory `STOREOBJ` on **whatever** unique-match returned.
4. Template instance adds `$fact` **and** the template SYSTEM factory as two 0-user-arg matches → `matches != 1` → no bind → arity `beh.factory`. Mix that with a bound unused factory and a dummy DeclId and you get VALUE-ctor ABI on a REF factory: `CallSystemFunction` AV. That was ArrayInt `wave-b-ninth-f2-ctor-g13`.

insertLast itself stayed exact (`FindExactRegisteredMethod`). The pollution is **sibling** ctor/factory DeclIds in `functionDecls` / `binds`, not the METHOD table.

`args.GetLength() > 0` skip stops ArrayInt intern. 1-arg `FBindCtor b(3)` / `FBindHost h(3)` still intern-**all** behaviours for that type. Do not widen this bite to intern-matching-arity-only for 1-arg.

---

## 3. One TDD bite — compare, then recommend

Goal: dummy/default 0-arg construct binds an **interned 0-arg** ctor/factory **without** intern-on-every-construct. Not whole 13.2.

### Option A — bind-from-use

Only `binds.PushLast` for `resolvedDecl` that appear on CONSTRUCT / CALL / INDEX (and import / script bodies). Skip interned `DECL_CONSTRUCTOR` that no expr names.

- Stops unused factory DeclIds occupying `funcs[]` (helps the AV).
- Dummy has **invalid** `resolvedDecl` → bind-from-use never binds dummy. 0-arg still `FindConstructorId(0)` / `FindFactoryId(0)`.
- Does not intern 0-arg. Does not put a callee on the sealed CONSTRUCT. Backend still looks up.
- Hygiene for leftover intern-all on `args > 0`. **Not** this bite’s primary.

### Option B — Sema intern 0-arg only for LocalDecl / default-init, record DeclId on a real CONSTRUCT

`AppendDefaultValueConstruct` already emits CONSTRUCT + ASSIGN. Explicit `T()` already `ActOnConstruct`s.

- Add `InternNativeZeroArgCallablesForType` (filter user arity 0 after hidden/template skip). Call it for 0-arg default-init / `ActOnConstruct` when `args.GetLength() == 0`. **Do not** call `InternNativeCallablesForType` on 0-arg.
- `SelectConstructor` sets `resolvedDecl` on that CONSTRUCT. Dump `callee=` becomes the interned `stableKey` (`FinishDecl` `as_sema.cpp:147-183`, ctor `Parent::name()`).
- Delete dummy `STMT_DECL` invent. VALUE default-init already has the sibling ASSIGN CONSTRUCT (`:1824-1831`). Deleting dummy also removes double-construct.
- Delete `expr->children.GetLength() == 0` → `FindConstructorId(0)` / `FindFactoryId(0)`. Miss → `asNO_FUNCTION`.
- `FindFunc(resolvedDecl)` + existing `FindExactRegisteredConstructor` unique-match. REF SYSTEM → factory STOREOBJ (`:2000-2048`). Script `FValue()` 0-arg ctor is already a `DECL_CONSTRUCTOR` with body; SelectConstructor finds it without native intern.

Clang shape (do not link):

- `CXXConstructExpr` always stores `CXXConstructorDecl *Constructor` (`Reference/llvm-project/clang/include/clang/AST/ExprCXX.h:1548-1611`, `getConstructor()`).
- Default-init still `BuildCXXConstructExpr` (`clang/lib/Sema/SemaDeclCXX.cpp:16325-16347`). `InitializationKind::IK_Default` forces even a trivial implicit default ctor to be checked (`clang/lib/Sema/SemaInit.cpp:7519-7528`).
- CodeGen reads `E->getConstructor()` (`clang/lib/CodeGen/CGExprCXX.cpp:603-607`). It does not invent a construct with no callee, and it does not re-run overload lookup by arity.

### Option C — dummy `FindInternedZeroArgConstructor(type)` by type, not DeclId

Already written, unused (`:410-454`). First 0-param child wins = CodeGen overload lookup (pipeline spec: backend MUST NOT). Dummy stays CodeGen-invented. Still needs someone to intern the 0-arg decl. Poison two 0-param interned ctors → first intern order, not unique-match.

### Recommend against intern-all-on-ActOnConstruct

That is the ArrayInt AV. `InternNativeCallablesForType` intern **all** constructors and **all** factories. Collect-all then binds unused arities into insertLast Generate.

**Recommend B.** Keep `InternNativeCallablesForType` only for `args > 0` (Phase B). For 0-arg, intern **only** user-arity-0 ctor/factory on the default-init / `T()` path, seal that DeclId on the real CONSTRUCT, delete dummy + 0-arg arity walk. Do not wire option C. Option A can follow later as Generate filtering; it does not make 0-arg Sema-owned.

---

## 4. Exact RED tests

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`  
Class: `FCanonicalASTProductionCodeGenTests`  
Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`  
**Do not** use `...ProductionCodeGen.CanonicalNativeZeroArg` (matches nothing).

CQTest. Isolated Engine. `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)`. `asAST_RETAIN_SNAPSHOT`. Bool poison + `MORE_CONSTRUCTORS` for VALUE. Do not re-register float + `ALLINTS`. No `@`. No script `funcdef`.

### 4.1 Must-stay-green (do not weaken)

| Method | Lock |
| --- | --- |
| `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` (`:1006-1097`) | Build 0, execute **42**, publisher CodeGen, CALLSYS or ALLOC. Fixture stays one factory `array<T> f(int&in)` + insertLast + opIndex. |
| `CanonicalNativeSameArityMethodExecutesSelectedNotFirstRegistered` | insertLast int CALLSYS, not bool. |
| `CanonicalNativeSameArityMemberExecutesSelectedNotFirstRegistered` | `FBindBox b;` 0-arg `void f()` + Get(int). Member 42. After dummy delete, default-init must still run `ProdBindBoxConstruct`. |
| Constructor / Factory 1-arg rows | execute 42, CALLSYS int not bool. |
| FValue Object execute 42 | generated 0-arg script ctor. |

Do **not** change ArrayInt into a poison-factory fixture. Do **not** require ArrayInt `ProdBytecodeCallsFunction(RegisteredGenericFactoryId)` while `$fact` CALL is the instance default (`beh.factory` after stub). That assert is false today for reasons unrelated to Sema DeclId.

### 4.2 RED first — Sema callee on default-init (ArrayInt can host this without poison)

In `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` **or** a sibling that copies the same fixture:

- Sealed dump contains `kind=Construct` with **non-empty** `callee=` (today `ActOnConstruct` 0-arg does not intern → `callee=` empty, `:410`).
- Do not lock an exact `stableKey` until the interned name is visible in a dump; require `callee=` nonempty and not the insertLast key.

This is RED **before** deleting the arity walk. Execute 42 may still pass via `FindFactoryId(0)`.

### 4.3 RED — poison 1-arg FIRST vs selected 0-arg (new methods)

Same-arity 0-arg vs 0-arg is unregisterable (duplicate). Poison is **1-arg first**, selected **0-arg second**. That is “not first registered”, not two 0-arg overloads.

**Factory (REF, no template — avoids `$fact`):**

```text
TEST_METHOD(CanonicalNativeZeroArgDefaultFactoryExecutesInternedNotFirstRegistered)
  FBindHost REF NOCOUNT IMPLICIT_HANDLE
  poison factory(int) FIRST   → ProdBindHostFactoryBoolPoison or a dedicated IntPoison Stored=0
  selected factory() SECOND  → new ProdBindHostFactoryZero, Stored=41
  int F() { FBindHost h; return h.Stored + 1; }
  execute 42
  ProdBytecodeCallsFunction(Published, ZeroArgId)
  !ProdBytecodeCallsFunction(Published, PoisonId)
  dump Construct callee= nonempty
```

`RegisterObjectBehaviour`: 0-param sets `beh.factory` (`as_scriptengine.cpp:2355-2358`); 1-param does not. `FindFactoryId(0)` already returns the selected 0-arg. Execute 42 / CALLSYS selected id may be **GREEN via arity**. Dump `callee=` is still RED. After Task 2 deletes the 0-arg walk, execute goes RED until intern+`FindFunc`.

**Constructor (VALUE):**

```text
TEST_METHOD(CanonicalNativeZeroArgDefaultConstructorExecutesInternedNotFirstRegistered)
  FBindCtor VALUE POD APP_CLASS CONSTRUCTOR MORE_CONSTRUCTORS
  poison void f(int) FIRST   → Stored=0
  selected void f() SECOND   → reuse ProdBindBoxConstruct + Stored=41, or a dedicated 0-arg that sets 41
  int F() { FBindCtor b; return b.Stored + 1; }
  execute 42, CALLSYS 0-arg id not poison 1-arg
  dump Construct callee= nonempty
```

Member row already registers 0-arg `void f()` with Stored left 0. Do not overload that method; add the new one.

### 4.4 TDD order (this future mutex only)

1. Write 4.2 dump assert + 4.3 methods. Run ProductionCodeGen. Expect dump `callee=` RED; ArrayInt 42 still GREEN; 4.3 execute may luck-GREEN via `FindFactoryId(0)` / `FindConstructorId(0)`.
2. Delete dummy `:2701-2708` and the 0-arg `FindConstructorId(0)` / `FindFactoryId(0)` block `:2007-2021`. ArrayInt + 4.3 execute RED (`asNO_FUNCTION` or unconstructed insertLast → not 42).
3. Implement option B: intern **only** 0-user-arg ctor/factory for default-init; `SelectConstructor` records DeclId; ASSIGN path `FindFunc`.
4. GREEN: ArrayInt 42, 4.3 CALLSYS selected 0-arg not poison 1-arg, dump `callee=` set, Member/FValue 42, 1-arg ctor/factory rows untouched. SemaAuthority **239/239**.

If ArrayInt AV after intern: **stop**. Do not restore intern-all. Causes already known: unused factory in `binds`, dummy without zeroed `resolvedDecl`, VALUE path on REF factory, unique-match `matches==2` on template+$fact. Fix the specific one with evidence.

---

## 5. Commands the later UBT would use

Only `Tools\RunBuild.ps1` / `RunTests.ps1` from `D:\as-cta`. Always `-NoXGE`. `RunTests.ps1` does not UBT — `RunBuild.ps1` first after impl. `as_bytecode_codegen.cpp` is often plugin git `??`; Adaptive UBT skips it — delete Runtime objs + DLL before build (same paths as `wave-b-ctor-green.md` §2.1).

```powershell
Set-Location D:\as-cta
# confirm no UnrealBuildTool / UnrealEditor with D:\as-cta
Remove-Item -Force -ErrorAction SilentlyContinue `
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.44.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.48.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.49.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptRuntime.dll
.\Tools\RunBuild.ps1 -Label wave-b-ctor-zeroarg-r1 -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-ctor-zeroarg-r1 -TimeoutMs 600000
```

After any Sema edit:

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-ctor-zeroarg-sema -TimeoutMs 600000
```

Labels `-r1`, `-g1`, … as needed. CAEngine `UE4Editor` / `MSBuild` / `link` is **not** this lock.

---

## 6. Hard nos

- Check 13.2 / 9.4 / 5.4 / 5.5 / 5.6 / 4.2 / 13.5
- Intern-all-on-`ActOnConstruct` / call `InternNativeCallablesForType` when `args.GetLength() == 0`
- Call `InternNativeCallablesForType` from `InternNativeMethods`
- Wire unused `FindInternedZeroArgConstructor` (`:410`)
- Leave dummy `asCExpr` `resolvedDecl` uninitialized; restore dummy after Sema CONSTRUCT exists
- Store `asCScriptFunction*` on sealed `asCDecl`
- Unsealed CALL-without-callee; require CALL-without-callee on `asCASTVerify`
- Delete Phase A exact METHOD bind / restore `EmitCall` name+arity
- Script `funcdef` / `@` / `is` / `dictionary`
- Default CANONICAL. CANONICAL `CompileFunction`
- Wave E–G. InitPlan `atoi`. ABI width. Archive. Commit unless asked
- Second UBT. New worktree
- Edit `async-work.md` / `async-dispatch.md` / `wave-b-ctor-green.md` / `tasks.md` checkboxes
- Commands other than `Tools\RunBuild.ps1` / `RunTests.ps1` from `D:\as-cta`
- Prefix `...ProductionCodeGen.CanonicalNativeZeroArg` (matches 0 tests)
- Link Clang/LLVM; copy Clang types into the fork

---

## 7. Done when (future mutex)

- Default-init 0-arg CONSTRUCT has Sema `resolvedDecl` (dump `callee=` nonempty).
- Generate `FindFunc` that DeclId; 0-arg `FindConstructorId(0)` / `FindFactoryId(0)` **gone**.
- Dummy VALUE `STMT_DECL` invent **gone**; VALUE default-init uses the Sema CONSTRUCT sibling.
- Interned 0-arg only (not intern-all). ArrayInt insertLast Generate is not filled with unused factories.
- ArrayInt / Method / Member / FValue / 1-arg Constructor / Factory still 42.
- New 4.3 rows: CALLSYS selected 0-arg, not poison 1-arg.
- SemaAuthority 239.

Still **not** done: 13.2, 9.4 checkbox, typed InitPlan, intern-matching-arity-only for 1-arg, bind-from-use Generate filter, ABI width, Verifier 13.5, Wave E–G.
