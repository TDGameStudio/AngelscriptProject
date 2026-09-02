# Wave D 9.5 — next ProductionCodeGen fixture (after handle 12/12)

Worktree: `D:\as-cta`. Read-only package **D-95-next-after-handle**.
Did not edit `Plugins/`, tests, `tasks.md`, or other attachments except this file.
Did not run UBT / `RunBuild` / `RunTests`. Did not check `tasks.md` 9.5.

Exclusive UBT hole **right now**: `CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes` (host REF `CObj`, production `Build()` publishing zero functions). Do **not** start this method until that handle fixture is GREEN and the prefix is **12/12**.

Live gate after that GREEN: `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` — **12 methods**. `&in` / `&out` / `SUSPEND` / named-local VALUE / host-REF handle are already in that file — do not re-propose them.

Even 12/12 does **not** close `tasks.md` 9.5. Do not flip default CANONICAL. Do not invent CALL-without-callee. Do not re-enable script `funcdef` / `@` / `is`. Do not invent `dictionary`.

---

## Chosen next method

**`CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes`**

One-line script:

```angelscript
struct FValue { int Value = 41; } int F() { FValue Object; return Object.Value + 1; }
```

No user `FValue()`. Host `Register*`: **none**.

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`

---

## Why this row is the next one

Remaining 9.5 rows **not** in the live 12: `array<T>`, host funcdef + script `funcdef` reject, imports, generated default ctor / accessors / list factory (plus capturing closures / F1 empty-`functionDecls`, which are not this pick).

Preference: smallest honest execute-42 + `CANONICAL_CODEGEN` with no extra host surface and no CALL-without-callee.

1. **No extra `Register*`.** Same preference that picked `&in` over host REF before handle existed. After handle GREEN, this is the smallest remaining execute-42 that does not add host types.
2. **Still a 9.5 hole.** Live VALUE / temporary methods use a **user** ctor body `Value = 41`. SemaAuthority `ValueTemporaryRecordsMaterializeAndCleanup` dumps `struct FValue { int Value = 41; }` + `FValue()` only (`Build()==0`). Isolated CodeGen value-object is native `FNativeCaseValue`, not a generated script default ctor.
3. **Sema already synthesizes an empty `TRAIT_GENERATED` ctor** (`as_sema_decl.cpp` `EnsureGeneratedLifecycle`: `ActOnConstructorDecl` + trait, **no body**). Collect includes every `DECL_CONSTRUCTOR` even without a body. `FillFunctionSignature` can bind `beh.construct`. Member `defaultArg` `41` is on the field, not on a ctor statement. Honest RED: empty ctor + uninitialized `Value` → execute `!= 42`, or missing construct → `asNOT_SUPPORTED`. Do not treat a lucky `42` without ctor `WRTV4` as GREEN.
4. **No CALL-without-callee.** Construct must `FindFunc` the generated ctor decl. Missing callee must `FailAt(..., asNO_FUNCTION / asNO_MODULE / asNOT_SUPPORTED)`, not `asBC_CALL` with an empty function.

---

## Exact `TEST_METHOD` (match live file style)

Add after `CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes`, still inside `FCanonicalASTProductionCodeGenTests`. Tabs, `FNativeTestEngine`, `SetCompilerPipeline(CANONICAL)`, `ASTEST_AS_ANSI`, `CompileNativeModule`, `CanonicalExecuteInt`, publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`. Keep the handle-style “`int F()` is actually published” assert (the current zero-function hole). Do not weaken execute `42`. Do not execute Sema dump `Entry()`.

```cpp
	TEST_METHOD(CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
			TEXT("generated-default-ctor fixture selects CANONICAL")));
		asIScriptModule* Module = nullptr;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			struct FValue
			{
				int Value = 41;
			}

			int F()
			{
				FValue Object;
				return Object.Value + 1;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, AngelscriptNativeTestSupport::CompileNativeModule(
			Engine.Get(),
			"ProdGenDefaultCtor",
			ScriptSource.c_str(),
			Module),
			TEXT("CANONICAL generated default ctor Build must succeed from CodeGen")));
		asIScriptFunction* const Published = AngelscriptNativeTestSupport::GetNativeFunctionByDecl(Module, "int F()");
		ASSERT_THAT(IsNotNull(
			Published,
			*FString::Printf(
				TEXT("CANONICAL generated-default-ctor module must publish int F(); have {%s}"),
				*AngelscriptNativeTestSupport::CollectFunctionDeclarations(Module))));
		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			AngelscriptNativeTestSupport::CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 42,
			TEXT("CANONICAL generated default ctor F() must execute from CodeGen")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("CANONICAL generated default ctor Build must not record asCCompiler")));
		asITypeInfo* const TypeInfo = Module != nullptr ? Module->GetTypeInfoByName("FValue") : nullptr;
		asIScriptFunction* Ctor = nullptr;
		if (TypeInfo != nullptr)
		{
			for (asUINT BehaviourIndex = 0; BehaviourIndex < TypeInfo->GetBehaviourCount(); ++BehaviourIndex)
			{
				asEBehaviours Behaviour = asBEHAVE_CONSTRUCT;
				asIScriptFunction* const Candidate = TypeInfo->GetBehaviourByIndex(BehaviourIndex, &Behaviour);
				if (Candidate != nullptr && Behaviour == asBEHAVE_CONSTRUCT)
				{
					Ctor = Candidate;
					break;
				}
			}
		}
		ASSERT_THAT(IsNotNull(Ctor, TEXT("generated default ctor must be installed on FValue, not only int F()")));
		ASSERT_THAT(IsTrue(
			AngelscriptCompilerBytecodeTestSupport::ContainsOpcode(Ctor, asBC_WRTV4),
			TEXT("generated default ctor must write Value = 41, not RET an uninitialized local")));
	}
```

If `CompileNativeModule != 0`: valid RED **only if** publisher ≠ `COMPILER`. Do not launder via LEGACY `asCCompiler`. Then skip execute / opcode (same pattern as try/catch / mutable-global).

---

## What must fail today (honest)

| Assert | Honest outcome today |
| --- | --- |
| Sema dump `Build()==0` for `int Value = 41` + `FValue()` | Already green (`ValueTemporaryRecordsMaterializeAndCleanup`). **Ignore.** |
| Live user-ctor VALUE / temporary execute 42 | Already green. **Not this row.** |
| `CompileNativeModule(...) == 0` | May succeed (Sema generates ctor; Generate collects empty ctors). Not the language proof. |
| `int F()` published | Must not repeat the handle zero-function skip. |
| `CanonicalExecuteInt && Value == 42` | **Must be the RED** unless ctor actually stores 41. Uninitialized `Value + 1` is `1` or garbage — both RED. |
| Ctor `asBC_WRTV4` | Empty generated ctor has no field store. **Do not drop this** to bless a false execute 42. |
| Publisher `CANONICAL_CODEGEN` | If Build succeeds, publisher may already be CodeGen. That does not make the row green. |

---

## Why not the other remaining rows yet

- **`array<T>`.** TypeTests / SemaAuthority only `RegisterObjectType("array<class T>", ..., asOBJ_REF \| asOBJ_TEMPLATE \| asOBJ_NOCOUNT)`. Isolated CodeGen has **no** template emit. Execute `insertLast` / `Values[0]` needs factory + `opIndex` + length stubs. Registering the type alone would CALL an unregistered callee. Dictionary is **not registered** — out of coverage.
- **Host funcdef execute.** Isolated `CodeGenEmitsFuncdefCallAndLambda` already lowers `RegisterFuncdef("int Callback(int)")` + `Invoke(Double, …)` + `CallPtr`. Production twin is real 9.5, but it needs extra host `RegisterFuncdef` and is larger than this VALUE script. Next after **this** method GREEN, not a substitute: `int Double(int X) { return X + X; } int Invoke(Callback Cb, int X) { return Cb(X); } int F() { return Invoke(Double, 21); }` + opcode `asBC_CallPtr` on `Invoke`.
- **Script `funcdef` reject.** Same 9.5 row, fail-closed sibling: `funcdef int Cb(int); int F() { return 1; }` → `Build() < 0`, publisher ≠ `COMPILER`. Token is already disabled — cheap GREEN, does not drive ctor emit. Do not re-enable the keyword. Do **not** pick it as this execute-42 method.
- **Imports.** Two-module + `BindImportedFunction`. SemaAuthority dump and VM-matrix execute are not this prefix. `FindFunc` only sees CodeGen binds — import call is `asNO_MODULE` / `asNOT_SUPPORTED` today. Larger than a single-module VALUE script.
- **Generated accessors.** Sema dump `GetValue`/`SetValue` on `class T { int Value = 3; }`. CodeGen already inlines generated `Get*` as `ADDSi`/`RDR4`. `Object.Value` can false-green via the live VALUE property path without accessor **bodies**. Not this method.
- **List factory.** SemaAuthority registers `asBEHAVE_LIST_FACTORY` `{repeat int}` and dumps `literal=list-pattern`. No list-pattern emit. Do not CALL a missing factory.
- **Capturing closures / lambda stored in funcdef.** Isolated stores a non-capturing lambda in host `Callback`. Not a substitute for generated ctor. Do not treat capture as GREEN without a new RED.
- **`&in` / `&out` / `SUSPEND` / host-REF handle / named-local VALUE.** Already in the live 12. Do not re-add.

---

## Later commands (from `D:\as-cta`)

New `TEST_METHOD` requires a rebuild. Always `-NoXGE` after touching tests or codegen. `RunTests.ps1` has no `-NoXGE` switch. **Do not run until handle is 12/12.**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-gendefctor
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-gendefctor -TimeoutMs 600000
```

Expect **13 methods** on that prefix after this add (the original 12 stay green, including handle). Do not mark `tasks.md` 9.5.

---

## Reminder

**Do not check `tasks.md` 9.5 after this one method greens.** Host funcdef + script `funcdef` reject, `array<T>`, imports, generated accessors / dtor / list factory, capturing closures, loop already covered, and F1 empty-`functionDecls` remain open. Default pipeline stays LEGACY (Wave G). Handle 12/12 is not this fixture.
