# Wave B research — ninth-pass F2 exact Runtime binding (name+arity reselect)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-ninth-f2-exact-binding**. Design map. **Implement from `wave-b-tenth-f2-wire.md` (exclusive UBT now).** Isolated traces are GREEN. Do not re-research this file.
Companions: `async-work.md`; `async-dispatch.md`; `wave-b-tenth-f2-wire.md`; `reviews/implementation-rereview-2026-08-22-ninth-pass.md` F2 (cutoff 16:54; **live line numbers below, not the review’s 1893/1440**).

LLVM/Clang is a **shape** reference only. Do not link. Sequential exclusive — same `as_bytecode_codegen.cpp`.

This map is **not** a 9.4 close, not a 13.2 close, not a 5.4 close. Do not check those boxes because this file exists, because RED tests exist, or because the later bite goes GREEN.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Design map. Exclusive implement is `wave-b-tenth-f2-wire.md`. |
| Gate | Isolated traces GREEN. Exclusive UBT is live. |
| Do not mark | **any remaining OpenSpec box** from this map or from the later prefix greens |

---

## 1. What ninth-pass F2 actually is

Sema can already select an exact callable (`array<int>::insertLast(const int&in)` dump lock is GREEN). CANONICAL CodeGen does **not** consume that `expr->resolvedDecl` as a Runtime callable.

Live path:

```text
sealed CALL/CONSTRUCT.resolvedDecl  (asASTDeclId → asCDecl: name, stableKey, param QualTypes)
        │
        ▼
FindFunc(decl)     CodeGen-local asSCodeGenFuncBind[] only
        │ miss for interned native METHOD (no body, not GENERATED)
        ▼
re-search Runtime by name + parameter COUNT
        FindMethodUntil(name) / FindConstructorId(argCount) / FindFactoryId(userArgCount)
        first match wins
```

Spec (`as-canonical-compiler-pipeline`): backend MUST NOT perform overload lookup.
Spec (`as-canonical-typed-ast`): backend traversal does not perform another overload search.

Clang shape (do not link): CodeGen builds a callee from the Canonical `FunctionDecl` already selected (`CGCallee` / `GetAddrOfFunction(GlobalDecl)`). It does not re-run Sema overload resolution by spelling + arity.

---

## 2. Live file:line (current `as_bytecode_codegen.cpp`, not ninth-pass cutoff)

Ninth-pass quoted `:1893-1934` / `:1440-1447`. Those drifted after OpaqueValue / returnSlot. Use these.

### 2.1 Bind table and FindFunc — why native methods miss

`asSCodeGenFuncBind` (`:160-166`) is DeclId → `asCScriptFunction*` plus lambda capture range. **Generate-local.** Sealed AST has no Runtime function pointer (correct: public snapshot forbids Engine-local FunctionId as durable identity).

```808:816:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		asCScriptFunction* FindFunc(asASTDeclId decl) const
		{
			for( asUINT i = 0; i < funcs.GetLength(); ++i )
			{
				if( funcs[i].decl == decl )
					return funcs[i].func;
			}
			return 0;
		}
```

Who gets a bind:

| Source | Live lines | What it covers |
| --- | --- | --- |
| `DECL_IMPORT` | `:3033-3114` | imported script functions |
| `FindRegisteredGlobalFunction` then bind | `:59-94`, `:3120-3128` | host **global** `asFUNC_SYSTEM` with **no body** |
| `asNEW asCScriptFunction` + `FillFunctionSignature` | `:3130-3158` | script bodies, **every** `DECL_CONSTRUCTOR`, **GENERATED** methods, destructors |

Collect into `functionDecls` (`:2935-2950`):

```text
body.IsValid()
|| kind == FUNCTION
|| kind == CONSTRUCTOR
|| (kind == METHOD && TRAIT_GENERATED)
|| kind == DESTRUCTOR
```

**Native interned METHOD** (`InternNativeMethods` in `as_sema_expr.cpp:391-503`):

- `ActOnMethodDecl` + params + `FinishDecl` → `stableKey` like `array<int>::insertLast(const int&in)`
- **no body**
- **not** `asAST_TRAIT_GENERATED`
- **not** `DECL_FUNCTION` / `DECL_CONSTRUCTOR`

→ **excluded** from `functionDecls` → **never** `binds.PushLast` → `FindFunc(expr->resolvedDecl)` is always `0`.

That is the whole native-method miss. Sema’s exact DeclId is present. CodeGen drops it because the table only knows script/import/generated/host-global.

`asCDecl` (`as_decl.h:13-37`) has `name`, `stableKey`, `origin`, param children, **no** `asCScriptFunction*` / engine function id. InternNativeMethods holds `asCScriptFunction* method` in the walk (`as_sema_expr.cpp:414`) and **throws it away** after copying types.

### 2.2 EmitCall — name + arity first match

```2025:2116:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		int EmitCall(const asCExpr* expr, const asCDataType& dataType, int dwords)
		{
			asCScriptFunction* callee = FindFunc(expr->resolvedDecl);
			if( callee == 0 )
			{
				const asCDecl* calleeDecl = context.GetDecl(expr->resolvedDecl);
				// GENERATED Get* → GetFirstProperty(name without "Get")  :2028-2066
				// else FindMethodUntil(calleeDecl->name) + arity          :2067-2108
			}
			const int funcVar = callee ? 0x7fffffff : FindSlot(expr->resolvedDecl);
			if( callee == 0 && funcVar == 0x7fffffff )
			{
				FailAt(__LINE__, asNO_MODULE);   // :2112
```

Arity predicate (`:2091-2108`), first `return true` wins:

```text
search = objType; search; search = search->templateBaseType
  FindMethodUntil(calleeDecl->name):
    method.name == calleeDecl->name
    && ( params == userArgs
      || params == expr.children
      || params + 1 == expr.children )
```

`userArgs` is `children.length`, minus 1 when `literalBits` marks a receiver (`:2086-2090`).

**Not compared:** canonical parameter types, in/out/ref/handle, const method, `stableKey`, `IsSignatureExceptNameEqual`, route/ABI, Sema’s selected DeclId.

`asCObjectType::FindMethodUntil` (`as_objecttype.h:240-255`) walks `methodTable` then `shadowType` and stops at the first callback `true`. Registration order = first same-arity SYSTEM method.

For `array<int>`, methods live on `templateBaseType` (`array<T>`). If both `insertLast(bool)` and `insertLast(const T&in)` are registered, **bool first** is the CALLSYS target even when dump says `callee=array<int>::insertLast(const int&in)`.

Generated `Get*` special case (`:2028-2066`) is a second reselect (`GetFirstProperty` by stripped name). Generated methods **are** in `functionDecls` (TRAIT_GENERATED), so `FindFunc` should hit and this path is dead for current ProductionCodeGen accessors. Keep those tests GREEN via the table; do not make property inlining the native bind.

After a callee is chosen, emit uses **that** `asCScriptFunction*` (`:2225-2232` CALL / CALLSYS / CALLBND). Wrong table entry = wrong CALLSYS id.

### 2.3 FindRegisteredGlobalFunction — same hole for host globals

```59:94:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
	asCScriptFunction* FindRegisteredGlobalFunction(...)
	{
		// kind FUNCTION, no body, not lambda
		// first asFUNC_SYSTEM global with name.Equals(decl->name)
		//   && parameterTypes.GetLength() == paramCount
	}
```

If two same-arity host globals intern, **both** DeclIds bind to the **first** SYSTEM global. `FindFunc` then “hits” the wrong function.

`InternNativeGlobals` (`as_sema_expr.cpp:329-389`) `exists` is also **name + CountParams**, so the second same-arity global may never intern. Method intern **does** compare substituted types (`as_sema_expr.cpp:438-471`). Do not treat dump-green `insertLast` as proof that globals are exact.

### 2.4 EmitConstructInto — arity constructor / factory

```1531:1575:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			asCScriptFunction* ctor = FindFunc(expr->resolvedDecl);
			int ctorId = ctor ? ctor->id : 0;
			if( ctor == 0 )
			{
				ctorId = FindConstructorId(objType, expr->children.GetLength());
				...
			}
			if( ctor == 0 || ctorId <= 0 )
			{
				factoryId = FindFactoryId(objType, expr->children.GetLength());
				...
			}
			if( (ctor == 0 || ctorId <= 0) && (factory == 0 || factoryId <= 0) )
			{
				FailAt(__LINE__, asNO_FUNCTION);  // :1573
```

`FindConstructorId` (`:201-243`): first `beh.constructors[i]` with `parameterTypes.GetLength() == argCount`; prefer `asFUNC_SCRIPT`, else first SYSTEM. Zero-arg also considers `beh.construct`.

`FindFactoryId` (`:245-288`):

- `userArgCount == 0` → **immediate** `beh.factory` (`:251-254`), no signature
- else first factory whose **user** arity (`parameterTypes - hidden`) matches; prefer SCRIPT, else first SYSTEM

No `resolvedDecl.stableKey`. No param types.

Native constructors/factories are **not interned**. `ActOnConstruct` (`as_sema.cpp:1023-1084`) calls `SelectConstructor` (`:936-1020`), which only ranks interned `DECL_CONSTRUCTOR` children of a `DECL_CLASS`. `InternNativeMethods` never walks `beh.constructors` / `beh.factories`. For `array<int> Values;` the CONSTRUCT often has **invalid** `resolvedDecl`; factory execute today is `FindFactoryId(0)` → default `beh.factory`, not Sema’s target.

Dummy VALUE construct in `asAST_STMT_DECL` (`:2290-2300`) synthesizes an `asCExpr` with **no** `resolvedDecl` and calls `EmitConstructInto`. That is CodeGen inventing a 0-arg construct, then `FindConstructorId(objType, 0)`. After deleting arity search, default construct must bind the interned/generated 0-arg ctor already in `binds` (script `FValue()` is `DECL_CONSTRUCTOR` and already bound). Do not keep arity walk for dummy construct.

### 2.5 EmitIndex — same class of search (same UBT, not a second bite)

```1758:1782:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			asCScriptFunction* opIndex = 0;
			objType->FindMethodUntil("opIndex", [&](asCScriptFunction* method)
			{
				opIndex = method;
				return true;          // first opIndex, no arity even
			});
			// then templateBaseType walk, same first match
			if( opIndex == 0 ) FailAt(__LINE__, asNOT_SUPPORTED);
```

Sema `ActOnIndexExpr` (`as_sema_expr.cpp:949-976`) **does** `SetResolvedDecl` when `FindBestCallee(..., "opIndex")` hits, but it does **not** call `InternNativeMethods`. Native `opIndex` is often unbound; emit ignores `resolvedDecl` entirely.

Deleting CALL/CONSTRUCT name+arity and leaving this walk still reruns Sema for `Values[0]`. Same exclusive UBT, same table. Existing `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` registers **one** `opIndex` — it does not prove exact bind.

### 2.6 Sema side (read, later UBT may intern ctors/factories/opIndex)

| Site | Role |
| --- | --- |
| `as_sema.cpp:840-864` `ActOnCall` | `SetResolvedDecl(id, callee)` — fact exists |
| `as_sema.cpp:1074-1078` `ActOnConstruct` | `SetResolvedDecl(id, ctor)` — ctor often invalid for native |
| `as_sema_expr.cpp:391-503` `InternNativeMethods` | exact-type intern of SYSTEM methods; **drops** `asCScriptFunction*` |
| `as_sema_expr.cpp:505-557` `ResolveCallee` | intern methods, `FindBestCallee`, `fileID==0` same-arity native defense |
| `as_sema.cpp:146-240` `FinishDecl` | `stableKey` includes param type keys + in/out + ` const` |
| `as_sema_expr.cpp:329-389` `InternNativeGlobals` | name+arity `exists` skip |
| `as_ast_dump.cpp:330-341` | dump `callee=` is `stableKey` / name — **not** CALLSYS id |

Dump `callee=array<int>::insertLast(const int&in)` is Sema. It is not evidence CodeGen called that function.

---

## 3. Why current greens do not close this

| Evidence | What it is | What it is not |
| --- | --- | --- |
| `NativeTemplateMethodRanksInstantiatedSubtypeNotSameArityBool` | Dump + interned param `ttInt`; **both** overloads share `RankArrayInsertLastUnused`; **no execute** | CodeGen CALLSYS id |
| `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` | One `insertLast(const T&in)`, execute 42, CALLSYS or ALLOC | Same-arity bool vs T&in |
| `CanonicalOverloadBuildPublishesSelectedCalleeNotFirstName` | **Script** `F(int)` vs `F(float)` — both have bodies, `FindFunc` **hits** | Native SYSTEM miss path |
| `MemberSameArityTypeMismatchDoesNotBindFirstMethod` | Script intern fail-closed dump | CodeGen |
| ProductionCodeGen **33/33** | Named 9.5 subset | Exact native bind |

---

## 4. Later exclusive UBT — TDD bite (after 5.4 traces GREEN)

One exclusive UBT in `D:\as-cta`. `-NoXGE`. Do not spawn a second UBT. Do not mix leftover FromNode, returnSlot, 5.5, Wave E–G.

Clang/LLVM: shape only (Decl → callee table, no re-lookup). No Unreal types in fork frontend files. No script `funcdef` / `@` / `is`. No invented `dictionary`. Unsealed `asCASTVerify` must still succeed without CALL `resolvedDecl`. Publication stays the unsealed gate.

### 4.1 Files

| Path | This UBT |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` | Three (plus factory) **execute** TEST_METHODs. Dump `callee=` may be a secondary assert; execute + CALLSYS id are the contract. |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp` | One construction-API **fail-closed** TEST_METHOD. Prefix `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen`. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` | Populate `binds` for interned native METHOD/FUNCTION/CONSTRUCTOR from **exact** Runtime signature. `FindFunc` stays the only emit lookup. **Delete** `FindMethodUntil` name+arity in `EmitCall` (`:2091-2108`), arity `FindConstructorId` / `FindFactoryId` fallbacks in `EmitConstructInto` (`:1555-1570`), first-`opIndex` walk in `EmitIndex` (`:1758-1777`). Tighten `FindRegisteredGlobalFunction` (`:85-91`) from name+count to unique `IsSignatureExceptNameEqual` / `GetGlobalFunctionByDecl`. Bind miss → `FailAt(__LINE__, asNO_FUNCTION)`, `Generate < 0`, publisher **not** `COMPILER`. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | Intern native constructors/factories (and `opIndex`) the same way as methods, **keeping** the `asCScriptFunction*` only long enough to record a Generate-time key if needed. Call intern from `ActOnConstruct` / `ActOnIndexExpr` so `resolvedDecl` is valid. Fix `InternNativeGlobals` `exists` to type-aware if the global bind table would otherwise skip the selected overload. |
| `as_sema.cpp` `ActOnConstruct` | Only if native ctor intern must be triggered here. Do not change `SelectConstructor` ranking that already prefers exact types. |
| `as_ast_verifier.cpp` / public snapshot / Cache | **Do not edit.** Do not store `asCScriptFunction*` or FunctionId on `asCDecl`. |
| `tasks.md` | **Do not touch checkboxes.** |

Do not put live `asCScriptFunction*` on sealed `asCDecl`. Table lives in `asSCodeGenFuncBind` at Generate.

### 4.2 GREEN binding table shape

At Generate, **before** body emit, for every sealed CALL / CONSTRUCT / INDEX / DECL_REF-to-function with valid `resolvedDecl`:

```text
asSCodeGenFuncBind
  decl  = expr->resolvedDecl          // Sema's exact asCDecl
  func  = unique current-Engine callable whose
            name + object type + return + each param asCDataType
            + inOutFlags + const-method
          equal the interned QualTypes (bridge.Resolve)
          OR unique GetMethodByDecl / GetFactoryByDecl / GetGlobalFunctionByDecl
             from FinishDecl stableKey / GetDeclaration()
  fail  = 0 or >1 match → asNO_FUNCTION, no emit
```

Allowed matches: `asCScriptFunction::IsSignatureExceptNameEqual` after name+object match (`as_scriptengine.cpp:1585`, `:1621-1630` `GetMethodIdByDecl`). **Forbidden matches:** `FindMethodUntil(name)`, `GetMethodByName`, `parameterTypes.GetLength()` only, first `beh.constructors[i]`, `beh.factory` because `userArgCount==0`.

`FindFunc` remains a linear DeclId table. EmitCall/EmitConstruct/EmitIndex **only** `FindFunc(resolvedDecl)`. Missing DeclId or missing unique Runtime callable → fail-closed.

Intern-time assist (preferred, still no durable pointer in AST): while `InternNativeMethods` holds `method`, `FinishDecl` already writes `stableKey`. Generate maps that key through the current Engine bridge. Optional `SetOrigin` of `GetDeclaration()` is acceptable as a **lookup spelling**, not as a live pointer.

Dummy VALUE `STMT_DECL` construct: bind the class’s interned 0-arg `DECL_CONSTRUCTOR` already in `binds` (script generated/user ctor). If none, fail-closed — do not `FindConstructorId(0)`.

### 4.3 RED tests — exact names and fixtures

Add these methods. They must fail on **today’s** CodeGen (wrong CALLSYS / ctor, or success with first arity). Do not weaken to dump-only. Do not reuse `RankArrayInsertLastUnused` for both overloads.

Helpers stay `asCALL_GENERIC`. No `@`. Default pipeline stays LEGACY; these tests `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` only.

#### 1. `CanonicalNativeSameArityMethodExecutesSelectedNotFirstRegistered`

File: `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.

Host `array<class T>` as in `CanonicalArrayIntBuildPublishesCodeGenAndExecutes`, **plus** a **first** method:

```text
void insertLast(bool value)     → Items.Add(0)          // poison; register FIRST
void insertLast(const T&in)     → Items.Add(*value)     // register SECOND
T &opIndex(uint index)          → existing
factory array<T> f(int&in)      → existing, no @
```

Script:

```text
int F()
{
    array<int> Values;
    Values.insertLast(41);
    return Values[0] + 1;
}
```

Assert:

- `Build()==0`, publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`
- dump contains `callee=array<int>::insertLast(const int&in)` and does **not** contain `callee=array<int>::insertLast(bool)` (Sema already does this; keep as secondary)
- `CanonicalExecuteInt` → **42** (poison path yields **1**)
- `ProdBytecodeCallsFunction(F, IntInsertLast->GetId())`
- `!ProdBytecodeCallsFunction(F, BoolInsertLast->GetId())`

Today: `FindMethodUntil` picks bool → execute 1, or bool CALLSYS id. RED.

#### 2. `CanonicalNativeSameArityMemberExecutesSelectedNotFirstRegistered`

Host VALUE POD (no `@`):

```text
RegisterObjectType("FBindBox", sizeof(FBindBox), asOBJ_VALUE | asOBJ_POD | asOBJ_APP_CLASS)
asBEHAVE_CONSTRUCT "void f()"     default
int Get(bool)   → SetReturnDWord(0)     // FIRST
int Get(int)    → SetReturnDWord(42)    // SECOND
```

Script:

```text
int F()
{
    FBindBox b;
    return b.Get(3);
}
```

Assert: execute **42**, CALLSYS id of `Get(int)`, not `Get(bool)`, publisher CodeGen, dump `callee=` the int method key not the bool key.

Today: first same-arity `Get` is bool → **0**.

#### 3. `CanonicalNativeSameArityConstructorExecutesSelectedNotFirstRegistered`

Same VALUE layout with property `int Stored`:

```text
asBEHAVE_CONSTRUCT "void f(float)"  → Stored = 0     // FIRST
asBEHAVE_CONSTRUCT "void f(int)"    → Stored = 42    // SECOND
RegisterObjectProperty "int Stored"
```

Script:

```text
int F()
{
    FBindBox b(3);
    return b.Stored;
}
```

Assert: execute **42**, bytecode calls the **int** construct behaviour id, not float. Dump CONSTRUCT `callee=` the interned int ctor key once intern exists (may be empty **today** — execute is the RED, not dump).

Today: `resolvedDecl` often invalid; `FindConstructorId(1)` → first SYSTEM float ctor → **0**.

#### 4. `CanonicalNativeSameArityFactoryExecutesSelectedNotFirstRegistered`

REF host, **no `@`**, same pattern as array factory:

```text
RegisterObjectType("FBindHost", 0, asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE)
asBEHAVE_FACTORY "FBindHost f(bool)"  → Stored = 0    // FIRST
asBEHAVE_FACTORY "FBindHost f(int)"   → Stored = 42   // SECOND
RegisterObjectProperty or Get() → Stored
```

Script: `FBindHost h(3); return h.Stored;` (or `h.Get()` if property rewrite is a problem — prefer property only if generated accessors stay out of this RED).

Assert: execute **42**, CALLSYS/ALLOC the **int** factory id, not bool. Today: `FindFactoryId(1)` first SYSTEM bool factory → **0**.

#### 5. `CanonicalNativeBindMissFailsClosedDoesNotCallFirstArity`

File: `AngelscriptNativeCanonicalASTCodeGenTests.cpp` (construction API + `asCBytecodeCodeGen::Generate`, not script ranking).

- Register host VALUE `FBindMiss` with **only** `int Pick(bool)` (side-effect flag / return 0).
- Construction API: intern `DECL_CLASS FBindMiss`, intern `DECL_METHOD Pick` with **int** param (not bool), `ActOnCall` that DeclId with an int literal + receiver, body of `int F()`.
- `Seal()`, `Generate(Context, Module)`.

Assert:

- `Generate < 0` and `GetError() == asNO_FUNCTION` (or the existing fail-closed code used at `:1573` / a new bind-miss `FailAt`, **not** `asNO_MODULE` from `:2112` after a guessed CALLSYS)
- `Pick(bool)` **not** invoked (side-effect false)
- `GetLastBytecodePublisher()` is **not** `asBYTECODE_PUBLISHER_COMPILER`

Today: `FindFunc` miss → `FindMethodUntil("Pick")` arity 1 → CALLSYS `Pick(bool)` → Generate 0. RED.

Do **not** implement this as unsealed `asCASTVerify` requiring CALL `resolvedDecl`. Unsealed verify on this graph may still be OK; **Generate** is the fail-closed gate.

### 4.4 Task order (TDD)

1. **RED** — add methods 1–5. Build, run the two prefixes. Expect Fail (wrong 0/1 or guessed CALLSYS). Do not implement bind yet.
2. **GREEN table + intern** — populate `binds` for native METHOD from exact signature; intern native ctor/factory/`opIndex` so `resolvedDecl` is valid; `FindFunc` hits.
3. **Delete searches** — remove `EmitCall` `:2091-2108`, `EmitConstructInto` arity fallbacks, `EmitIndex` first-`opIndex`, name+count global bind. Miss → `asNO_FUNCTION`.
4. **Verify** — new methods GREEN; must-stay-green list below still GREEN. Do not check OpenSpec boxes.

### 4.5 Commands (only these, from `D:\as-cta`, always `-NoXGE` on build)

`RunTests.ps1` does **not** UBT. Always `RunBuild.ps1` first after impl. Do not run tests against a failed build. CAEngine `UE4Editor`/`MSBuild`/`link` on this machine is **not** this lock. Confirm no `UnrealBuildTool`/`UnrealEditor` with `D:\as-cta` before UBT.

**Step 1 — build**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-ninth-f2-bind -NoXGE -TimeoutMs 1800000
```

**Step 2 — RED / GREEN ProductionCodeGen (new execute methods live here)**

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-ninth-f2-prod -TimeoutMs 600000
```

**Step 3 — fail-closed construction-API method**

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label wave-b-ninth-f2-codegen -TimeoutMs 600000
```

**Step 4 — must-stay-green Sema dump locks (do not rewrite weaker)**

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-ninth-f2-sema -TimeoutMs 600000
```

Optional after GREEN: `Compiler.CanonicalAST` prefix if time. Do not run All. Do not `RunTestSuite.ps1` for this bite.

### 4.6 Must stay green (do not weaken)

| Method | Contract |
| --- | --- |
| `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` | still 42, CALLSYS or ALLOC, publisher CodeGen — after intern+bind of factory/`insertLast`/`opIndex`, **not** arity fallback |
| `CanonicalOverloadBuildPublishesSelectedCalleeNotFirstName` | script `F(int)` CALL id, execute 42 |
| `CanonicalGeneratedAccessorBuildPublishesCodeGenAndExecutes` | CALL generated Get/Set, not inline ADDSi on `F()` |
| `CanonicalValueObjectBuildPublishesCodeGenAndExecutes` | script `FValue()` dummy/default construct still 42 |
| `CanonicalTemporaryConstructPublishesCodeGenAndExecutes` | stays 42 |
| `CanonicalImportCallBuildPublishesCodeGenAndExecutes` | CALLBND |
| `NativeTemplateMethodRanksInstantiatedSubtypeNotSameArityBool` | dump still int-not-bool |
| `MemberSameArityTypeMismatchDoesNotBindFirstMethod` | no first script `Get(bool)` |
| `UnresolvedCallMissingIsErrorTypeNotInt` | unsealed `asCASTVerify` OK without CALL callee |

Default `canonicalCompilerPipeline` stays false. `CompileFunction` stays mixed COMPILER.

---

## 5. Hard nos

- Implement this bite in the remaining-traces UBT, or while Isolated property/temp is still RED.
- Check **any** OpenSpec remaining box from this map, from RED tests landing, or from later GREEN prefixes.
- Store `asCScriptFunction*` / FunctionId on sealed `asCDecl` / public snapshot / Cache DTO.
- Keep `FindMethodUntil(name)` / `FindConstructorId(argCount)` / `FindFactoryId(userArgCount)` / `GetMethodByName` as a “temporary” emit path.
- Restore script same-arity-first (eighth-pass F4 intern contract).
- Require CALL-without-callee on unsealed `asCASTVerify`.
- Invent script `funcdef` / `@` / `is` / `dictionary`. Re-enable mutable globals. C labeled break.
- Clang/LLVM link. Unreal types in fork frontend files.
- Flip default CANONICAL. CANONICAL `CompileFunction`.
- Globally change `FindExistingExpr` / `FindExistingStmt` to full-span.
- `EmitDeclRef` literal fallback. Stmt-level cleanup POD.
- Mix leftover FromNode, returnSlot, 5.5, F1 detached install, F6 verifier firewall, Wave E–G.
- Commands other than `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` / `Tools\RunTestSuite.ps1` from `D:\as-cta`. Build without `-NoXGE`.
- Second UBT in `D:\as-cta`. New worktree. Archive. Commit unless asked.
- Dump-only new tests. Weakening Isolated 5.4 asserts. Editing `async-work.md` / `async-dispatch.md` / `tasks.md` checkboxes from this package.

---

## 6. What this package did / did not do

Did: map live name+arity drop of Sema `resolvedDecl`; write the later exclusive UBT TDD bite.

Did not: edit `Plugins/`; UBT; implement bind table; intern native ctors; delete `FindMethodUntil`; touch `tasks.md`.
