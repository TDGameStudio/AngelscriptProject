# Wave D 9.5 — next ProductionCodeGen fixture (after 8/8 + Cutover)

Worktree: `D:\as-cta`. Read-only package **D-95-next-fixture**.
Did not edit `Plugins/`, tests, `tasks.md`, or fork sources. Did not run UBT / `RunBuild` / `RunTests`.

Live gate: `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` — **8 methods**. `d95-green9` is **7/8**; exclusive work is named VALUE local. **Even 8/8 does not close `tasks.md` 9.5.** Cutover `CanonicalSelectionPublishesValueObjectsFromCodeGen` is the value-object publisher twin; it is not this method.

Do **not** check 9.5 after this one method greens. Do not flip default CANONICAL. Do not invent CALL-without-callee. Do not re-enable script `funcdef` / `@` / `is`. Do not pick dictionary (not registered). Do not pick capturing closures.

---

## Chosen next method

**`CanonicalInRefBuildPublishesCodeGenAndExecutes`**

One-line script:

```angelscript
int InF(int &in x) { return x; } int F() { return InF(41) + 1; }
```

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`

---

## Why this row is the next one

Preference order from the dispatch: (1) `&in` execute 42 + `CANONICAL_CODEGEN`, (2) implicit-handle / host REF null check, (3) loop `SUSPEND` + execute 42.

1. **`&in` is dialect.** Sema already interns `&` + `in` (`ttAmp` → `asAST_QUAL_REFERENCE`, `ttIn` → `asAST_QUAL_IN`). No `@` handle suffix. No script `class` VALUE mis-register. No extra host `RegisterObjectType`.
2. **It is still a 9.5 hole after 8/8.** The live eight plus Cutover cover integer routing, LEGACY control, named VALUE local, temporary, non-capturing IIFE, const global intern, try/catch reject, mutable-global reject. Handles/refs, templates, funcdefs, imports, generated lifecycle, and loop `SUSPEND` are **not** in that file.
3. **Dump-only Sema is already green and is not this gate.** `ParamQualifiersKeepDistinctStableKeysOnCompileSeal` (`ByRef(const int &in)`) and `InOutParamOverloadsKeepDistinctStableKeysOnCompileSeal` (`InF(int &in)` / `OutF(int &out)`) only require CANONICAL `Build()==0` plus dump keys. Isolated CodeGen calls are by-value ints (`CodeGenEmitsCallInReverseFormalOrder`). Neither is production execute 42 + publisher.
4. **Skipped #2 for now.** Implicit-handle / host REF needs `RegisterObjectType("CObj", 0, asOBJ_REF)` (isolated already has `CodeGenEmitsHandleParameterNullCheck`). Script `class` is still forced VALUE in `RegisterCanonicalScriptTypes`. Do not add a script-class fixture until that registrar is honest.
5. **Skipped #3 for now.** Loop `SUSPEND` already has isolated `CodeGenEmitsLoopSuspendAndIndex`. Integer `while` can execute 42 without proving ref ABI. Refs are the first uncovered 9.5 fragment that Sema accepts and CodeGen can silently lower wrong.
6. **Not this method:** `&out` write-back (follow-up after `&in` GREEN), `array<T>`, host funcdef, imports, generated default ctor/dtor/accessor/list factory, F1 empty-`functionDecls` skip.

`&out` stays the ABI follow-up, not a substitute:

```angelscript
int OutF(int &out x) { x = 41; return 1; } int F() { int v = 0; OutF(v); return v + 1; }
```

---

## Exact `TEST_METHOD` (match live file style)

Add after `CanonicalMutableGlobalRejectedDoesNotPublishCompiler`, still inside `FCanonicalASTProductionCodeGenTests`. Tabs, `FNativeTestEngine`, `SetCompilerPipeline(CANONICAL)`, `ASTEST_AS_ANSI`, `CompileNativeModule`, `CanonicalExecuteInt`, publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`. Do not weaken those asserts. Do not execute `Entry()` from the Sema dump fixture.

```cpp
	TEST_METHOD(CanonicalInRefBuildPublishesCodeGenAndExecutes)
	{
		AngelscriptNativeTestSupport::FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL),
			TEXT("&in fixture selects CANONICAL")));
		asIScriptModule* Module = nullptr;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int InF(int &in x)
			{
				return x;
			}

			int F()
			{
				return InF(41) + 1;
			}
			)AS");
		ASSERT_THAT(AreEqual(0, AngelscriptNativeTestSupport::CompileNativeModule(
			Engine.Get(),
			"ProdInRef",
			ScriptSource.c_str(),
			Module),
			TEXT("CANONICAL &in Build must succeed from CodeGen")));
		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			AngelscriptNativeTestSupport::CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 42,
			TEXT("CANONICAL &in F() must execute from CodeGen")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("CANONICAL &in Build must not record asCCompiler")));
	}
```

---

## What must fail today (honest)

SemaAuthority dump `Build()==0` for `&in` **already passes**. That is **not** this gate.

Current CodeGen (`as_bytecode_codegen.cpp`):

- `InOutFromQuals` writes `func->inOutFlags` (`asTM_INREF`).
- `asCRuntimeTypeBridge::Resolve` `MakeReference(true)` when `asAST_QUAL_REFERENCE` is set, so `GetSizeOnStackDWords()` is `AS_PTR_SIZE`.
- `PushValue` is only `PshV4` / `PshV8`. `EmitCall` never `PSF` / address-of for `&in`.
- `EmitDeclRef` for a `DECL_PARAM` returns the bound slot with **no** load-through (`RDSPtr` / `RDR4` of the pointed-to int).
- Isolated Generate has **no** `&in` fixture.

Expected TDD RED once this method is added (after 8/8 + Cutover, against current Generate):

| Assert | Honest outcome today |
| --- | --- |
| Sema dump `Build()==0` / `key=InF(int &in)` | Already green. **Ignore.** |
| `CompileNativeModule(...) == 0` | Likely **succeeds** (Sema accepts `&in`; Generate still `Commit`s). Not the language proof. |
| `CanonicalExecuteInt && Value == 42` | **Must be the RED.** Wrong ABI: value/`PshV8` of a 1-dword temp, or callee reads the ref slot as the int. Exception / `Value != 42` are both RED. |
| Publisher `CANONICAL_CODEGEN` | If Build succeeds, publisher may already be CodeGen. That does **not** make the row green. If Generate fail-closes, publisher must stay ≠ `COMPILER`. |

Silent-wrong-ABI risk: if `InF(41)` happens to return 41 because the callee copies the pushed dword without a pointer, execute 42 would be a **false green**. Do not accept that as 9.5 coverage. Real GREEN needs address-of of the actual int (temporary or local) plus callee load-through, still publisher `CANONICAL_CODEGEN`. `&out` write-back is the later discriminator; do not swap this first method for `&out`.

If `CompileNativeModule != 0` instead: still a valid RED **only if** publisher ≠ `COMPILER`. Do not launder via LEGACY `asCCompiler`.

---

## Later commands (from `D:\as-cta`)

New `TEST_METHOD` requires a rebuild. Always `-NoXGE` after touching tests or codegen. `RunTests.ps1` has no `-NoXGE` switch.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-inref
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-inref -TimeoutMs 600000
```

Exact later `RunTests.ps1` (after the method is in the binary):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-inref -TimeoutMs 600000
```

Expect **9 methods** on that prefix after this add (the original 8 stay green). Do not run this until named VALUE local is 8/8 and Cutover value-object has been re-run.

---

## Reminder

**Do not check `tasks.md` 9.5 after this one method greens.** Handles, `&out`, `array<T>`, funcdefs, capturing closures, imports, generated lifecycle, loop `SUSPEND`, and F1 empty-`functionDecls` remain open. Default pipeline stays LEGACY (Wave G). Cutover value-object is not this fixture.
