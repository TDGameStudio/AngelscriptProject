# Wave B — isolated LEGACY vs CANONICAL traces for already-`Build()==0` fixtures

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
**Attachment-only research. Do not implement now. No `Plugins/` edits. No UBT. No `tasks.md` / `async-work.md` / `async-dispatch.md` edits.**

LLVM/Clang is a shape reference only. Do not link Clang/LLVM.

Companions: `wave-b-54-generate-remaining.md` §4 (these three rows); `wave-b-54-opaque-next.md` (exclusive UBT **now**, same Semantics cpp); `wave-b-54-eval-once-next.md` (pattern already landed).

**Do not check `tasks.md` 5.4 / 13.2.** Dump tokens are not traces. SemaAuthority `Build()==0` is not 5.4.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Package | **B-54-traces-already-green** (`async-work.md` §7 parallel no-UBT) |
| Mode now | Attachment only. Exact TDD map. |
| Mode later | Exclusive UBT **after OpaqueValue GREEN**. Tests only unless a Trace string RED forces a tiny CodeGen bite. |
| Gate | `wave-b-54-opaque-next.md` GREEN on Semantics (mutation methods already in the shared cpp). Sequential exclusive — **one UBT user**. |
| Do not mark | **5.4 / 13.2 / 4.2 / 9.5** |

---

## Shared-file warning — do not implement now

B-54-opaque is the **current** exclusive UBT. It already edits both files this map would touch for tests:

| File | OpaqueValue UBT (live now) | This traces UBT (later) |
| --- | --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp` | **Already added** `CanonicalIndexCompoundAssignEvaluatesMakeOnce` (`:250-306`) and `CanonicalIndexCompoundAssignWritesThroughLocal` (`:308-351`) | Add the three isolated LEGACY/CANONICAL methods below. **Same cpp.** |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | **Already added** `Module->Build()==0` on `IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath` (`:1615-1616`) | **Do not edit.** The four dump methods below already `Build()==0`. |

**Do not implement this map while OpaqueValue still holds UBT.** Wait until OpaqueValue Semantics + SemaAuthority prefixes are GREEN, then one sequential exclusive. Do not race the same `AngelscriptNativeCanonicalASTVmMatrixTests.cpp`. Do not move or weaken the OpaqueValue methods.

This bite does **not** edit `as_sema.cpp`, `as_sema_expr.cpp`, `as_compiler.cpp`, `as_module.cpp`, dump, or verifier.

---

## Live file:line — SemaAuthority already `Build()==0` (dump, not traces)

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

These four methods call `Module->Build()` and **assert 0**. They then dump. That is not a VM side-effect trace.

| TEST_METHOD | Method | `Build()==0` | Fixture (dump only) | What dump locks |
| --- | --- | --- | --- | --- |
| `ValueTemporaryRecordsMaterializeAndCleanup` | `:516-554` | `:540` | `struct FValue { int Value = 41; }` / `return FValue().Value + 1;` | `kind=MaterializeTemporary`, `kind=Cleanup`, `callee=FValue::FValue()` |
| `LogicalAndRecordsNamedOperandsOnCompileSealPath` | `:1736-1807` | `:1770` | `return F(1) && G(2);` with `F(int)` / `F(float)` / `G(int)` | `kind=Logical literal=&&` + `lhs=`/`rhs=` distinct; `callee=F(int)` not `F(float)` |
| `ConditionalMismatchedArmsRecordConversionOnCompileSealPath` | `:1809-1865` | `:1828` | `float Entry(int Flag) { return Flag ? 1 : 2.0f; }` | `kind=Conditional` `cond=`/`then=`/`else=` + `kind=Conversion` dest/src int↔float |
| `LogicalShortCircuitRecordsOnCompileSealPath` | `:8530-8573` | `:8564` | same `F(1) && G(2)` as named-operands sibling | `kind=Logical` + callees; named lhs/rhs is the sibling |

They do **not** use `DumpSealedCanonicalAst` (`:232-247`), which **discards** `Build()`. Do not retcon these dump methods into Trace tests. Do not assert dump tokens in the new VmMatrix methods.

---

## Live file:line — Trace helpers and the copy pattern

Helpers: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Support/AngelscriptNativeCanonicalASTTestSupport.h`

| Symbol | Lines | Role |
| --- | --- | --- |
| `FCanonicalExecutionTrace` | `:195-214` | `Events` + `ToNormalizedString()` → `"1,2"` |
| `CanonicalTraceGeneric` | `:222-234` | `asCALL_GENERIC` `Trace(int id)` |
| `RegisterCanonicalExecutionTrace` | `:236-246` | `RegisterGlobalFunction("void Trace(int id)", …)` |
| `FCanonicalTraceScope` | `:248-265` | thread-local bind; `Reset()` on enter |
| `CanonicalExecuteInt` | `:325-338` | execute `int` decl into `int32&` |

VmMatrix wrapper `RegisterTrace` (`AngelscriptNativeCanonicalASTVmMatrixTests.cpp:25-35`) also turns HIR capture on and registers `Boom()`. Reuse it. Do not add a second `Trace` registrar.

**Pattern to copy:** `CanonicalMemberPostfixCallEvaluatesReceiverOnce` `:195-248` in `AngelscriptNativeCanonicalASTVmMatrixTests.cpp`.

```195:248:Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp
	TEST_METHOD(CanonicalMemberPostfixCallEvaluatesReceiverOnce)
	{
		using namespace AngelscriptNativeTestSupport;
		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };
		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));
		ASSERT_THAT(IsTrue(RegisterTrace(Engine), TEXT("canonical member eval-once needs Trace")));
		// FScopedNativeModule + FCanonicalTraceScope + CanonicalExecuteInt
		// assert result 1, Trace "1,2"
	}
```

**Do not retcon** `PropertyRewriteAndMutationSingleEvaluation` / `RunSingleEval` (`:119-193`). That Engine never calls `SetCompilerPipeline`. Default is LEGACY (`as_scriptengine.cpp:787` `canonicalCompilerPipeline = false`). `FScopedNativeModule` → `BuildNativeModule` → `Module->Build()` on **that** engine's pipeline. `RunSingleEval` is `asCCompiler` Bytecode, not AST-driven CodeGen.

Publisher enums (`as_ast_fwd.h:20-25`): LEGACY `asBYTECODE_PUBLISHER_COMPILER`; CANONICAL `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`. Add `#include "source/as_module.h"` on the test cpp if asserting `GetLastBytecodePublisher()`.

---

## Dialect (do not invent)

- Inline AS: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces, one blank line between functions (`Documents/Rules/ASInlineFormattingRule.md`).
- Script **class** = REF implicit handle. Script **struct** = VALUE. Value-temporary row is `struct FValue`, never `class`.
- No script `funcdef` / `@` / `is`. No mutable script globals as counters (`ConstGlobalTraitAndMutableReject`; VmMatrix already rejects `int Mutable = 1`).
- Host `Trace(int)` only. Do not invent `dictionary`. Do not use C labeled break.
- LEGACY `CompileCondition` requires a **bool** condition (`as_compiler.cpp:13905-13908` `TXT_EXPR_MUST_BE_BOOL`). SemaAuthority dump `Flag ? 1 : 2.0f` uses `int Flag` and is CANONICAL-only. Isolated traces that must compile on **both** engines use `true` / `false` (SemaAuthority logical dump already uses `return true;` / `return false;`).
- `&&` / `||` operands must be bool (`F`/`G` return bool, or `Mark(n) == 0`).
- Default pipeline stays LEGACY on every Engine that does not call `SetCompilerPipeline`. CANONICAL is **that Engine only**. Never flip `canonicalCompilerPipeline`. Never CANONICAL `CompileFunction`.

---

## New TEST_METHOD names (three rows)

Add on `FCanonicalASTVmMatrixTests` in `AngelscriptNativeCanonicalASTVmMatrixTests.cpp`, **after** the OpaqueValue methods (`CanonicalIndexCompoundAssignWritesThroughLocal` `:351`) and **before** `LoopsSwitchTransfersAndSafePoints`.

| # | TEST_METHOD | SemaAuthority parent (already `Build()==0`) |
| --- | --- | --- |
| 1 | `IsolatedLogicalShortCircuitMatchesLegacyCanonicalTrace` | `LogicalAndRecordsNamedOperandsOnCompileSealPath` + `LogicalShortCircuitRecordsOnCompileSealPath` |
| 2 | `IsolatedConditionalMismatchedArmsMatchesLegacyCanonicalTrace` | `ConditionalMismatchedArmsRecordConversionOnCompileSealPath` |
| 3 | `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace` | `ValueTemporaryRecordsMaterializeAndCleanup` |

Each method: **two** `FNativeTestEngine`s, **same** `ASTEST_AS_ANSI` source.

1. LEGACY: `Create` → `RegisterTrace` → **do not** `SetCompilerPipeline` → `FScopedNativeModule` → `GetLastBytecodePublisher() == asBYTECODE_PUBLISHER_COMPILER` → `FCanonicalTraceScope` + `CanonicalExecuteInt` per entry.
2. CANONICAL: new Engine → `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` on **that** engine only → `RegisterTrace` → same source → `GetLastBytecodePublisher() == asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` → same Trace/result asserts.

Expected Trace strings are **identical** on both engines (parity). Assert publisher so a forgotten `SetCompilerPipeline` cannot launder LEGACY as CANONICAL.

If the first CANONICAL run is already GREEN, **do not edit CodeGen**. Record the log. Tests-only is a valid exclusive UBT for this map.

---

## Row 1 — Logical short-circuit + named int overload

**TEST_METHOD:** `IsolatedLogicalShortCircuitMatchesLegacyCanonicalTrace`

SemaAuthority dump source is `F(1) && G(2)` with `F` always `true` — both operands run, so it does **not** prove skip. VM fixture keeps `F(int)` / `F(float)` / `G(int)` and makes `F(int)` depend on `a`.

```as
bool F(int a)
{
	Trace(1);
	return a != 0;
}

bool F(float a)
{
	Trace(9);
	return false;
}

bool G(int a)
{
	Trace(2);
	return true;
}

int RunAndTrue()
{
	return F(1) && G(2) ? 1 : 0;
}

int RunAndFalse()
{
	return F(0) && G(2) ? 1 : 0;
}

int RunOrTrue()
{
	return F(1) || G(2) ? 1 : 0;
}

int RunOrFalse()
{
	return F(0) || G(2) ? 1 : 0;
}
```

| Entry | Result | Trace | Meaning |
| --- | --- | --- | --- |
| `int RunAndTrue()` | `1` | `"1,2"` | both operands; `F(int)` not `F(float)` |
| `int RunAndFalse()` | `0` | `"1"` | `&&` skips `G` |
| `int RunOrTrue()` | `1` | `"1"` | `\|\|` skips `G` |
| `int RunOrFalse()` | `1` | `"1,2"` | `\|\|` evaluates `G` when LHS is false |

RED if Trace contains `9` (wrong overload), `"1,2"` on `RunAndFalse` / `RunOrTrue` (no short-circuit), or Generate fail (`Module.IsValid()==false`).

Live CANONICAL emit already short-circuits (`as_bytecode_codegen.cpp` `EmitLogical` `:1761-1782`, `JLowZ` for `&&`, `JLowNZ` otherwise). LEGACY `asCCompiler` `:21766-21807` is the same skip. First run may already GREEN.

Dump `lhs=`/`rhs=` (`as_ast_dump.cpp:472-482`) **are not traces**. Do not assert them here.

---

## Row 2 — Conditional mismatched arms

**TEST_METHOD:** `IsolatedConditionalMismatchedArmsMatchesLegacyCanonicalTrace`

SemaAuthority dump is `Flag ? 1 : 2.0f` (int Flag, no `Trace`). VM fixture uses bool cond so LEGACY compiles, plus one traced int arm and one traced float arm so Conversion is on the execute path.

```as
int Mark(int Value)
{
	Trace(Value);
	return Value;
}

float MarkF(int Value)
{
	Trace(Value);
	return 2.0f;
}

int EntryThen()
{
	float v = true ? Mark(1) : MarkF(2);
	if (v > 0.5f)
	{
		if (v < 1.5f)
		{
			return 1;
		}
	}
	return 0;
}

int EntryElse()
{
	float v = false ? Mark(1) : MarkF(2);
	if (v > 1.5f)
	{
		return 2;
	}
	return 0;
}
```

| Entry | Result | Trace | Meaning |
| --- | --- | --- | --- |
| `int EntryThen()` | `1` | `"1"` | then arm only; `Mark(1)` once |
| `int EntryElse()` | `2` | `"2"` | else arm only; `MarkF(2)` once |

RED: `"1,2"` / `"2,1"` (both arms), empty Trace, result 0, or Generate fail.

Notes (do not assert dump):

- LEGACY widest primitive for int vs float is `ttFloat32` (`as_compiler.cpp:14163-14175`).
- CANONICAL `ActOnConditionalExpr` (`as_sema_expr.cpp:1086-1116`) takes **then** type and `ActOnConversion`s else when types differ (`as_sema.cpp:867-871`). Dump already accepts either `dest=float src=int` or `dest=int src=float`.
- Result locks (`v` in `(0.5, 1.5)` vs `v > 1.5`) are execute values, not dump `kind=Conversion` tokens.
- Live CANONICAL emit already branches (`EmitConditional` `:1784-1806`). First run may already GREEN.

Do not use `int Flag` as the condition in this isolated pair.

---

## Row 3 — VALUE temporaries (`struct FValue().Value`)

**TEST_METHOD:** `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace`

SemaAuthority dump uses in-class `int Value = 41` and a generated `FValue()` with **no** `Trace`. Execute needs a **user** ctor/dtor that call `Trace`. Do not change the dump method. Do not use `class` (REF + GC is `CleanupDestructionExceptionsImportsAndGlobals`, not this row).

```as
struct FValue
{
	int Value;

	FValue()
	{
		Value = 41;
		Trace(1);
	}

	~FValue()
	{
		Trace(2);
	}
}

int Entry()
{
	return FValue().Value + 1;
}
```

| Entry | Result | Trace | Meaning |
| --- | --- | --- | --- |
| `int Entry()` | `42` | `"1,2"` | ctor of the temporary, then dtor; ctor once |

RED:

| Actual Trace | Likely cause |
| --- | --- |
| `"1"` | ctor ran; dtor skipped (`Cleanup`/`MaterializeTemporary` passthrough `:882-895` without `DestroyLiveObjects` `:713-718` / `beh.destruct`) |
| `"1,1,2"` / `"1,1"` | temporary constructed twice |
| `"2,1"` | dtor before ctor |
| empty / Generate fail | construct/member path broken |

ProductionCodeGen `CanonicalTemporaryConstructPublishesCodeGenAndExecutes` already executes `FValue().Value + 1` → 42 on CANONICAL **without** Trace. That is not this row. User `~FValue() { Trace(2); }` is required so cleanup is observable. `wave-d-95-lifecycle-next.md` forbids user dtor only for the **generated-dtor 9.5** slice — not here.

`AllocTyped` (`:664-678`) pushes VALUE objects; function epilogue `DestroyLiveObjects` CALLs `beh.destruct`. First run may already GREEN if that path is live.

---

## Copy-paste skeleton (one method; the other two swap source + asserts)

Keep Allman / `ASTEST_AS_ANSI` / matcher asserts. Two Engines. Unique module names per engine.

```cpp
TEST_METHOD(IsolatedLogicalShortCircuitMatchesLegacyCanonicalTrace)
{
	using namespace AngelscriptNativeTestSupport;
	const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
		bool F(int a)
		{
			Trace(1);
			return a != 0;
		}

		bool F(float a)
		{
			Trace(9);
			return false;
		}

		bool G(int a)
		{
			Trace(2);
			return true;
		}

		int RunAndTrue()
		{
			return F(1) && G(2) ? 1 : 0;
		}

		int RunAndFalse()
		{
			return F(0) && G(2) ? 1 : 0;
		}

		int RunOrTrue()
		{
			return F(1) || G(2) ? 1 : 0;
		}

		int RunOrFalse()
		{
			return F(0) || G(2) ? 1 : 0;
		}
		)AS");

	auto RunFour = [&](FNativeTestEngine& Engine, asIScriptModule* Module, const TCHAR* Side)
	{
		FCanonicalExecutionTrace Trace;
		int32 Result = 0;
		{
			FCanonicalTraceScope Scope(Trace);
			ASSERT_THAT(IsTrue(CanonicalExecuteInt(
				*TestRunner, Engine.Get(), Module, "int RunAndTrue()", Result)));
		}
		ASSERT_THAT(AreEqual(1, Result, *FString::Printf(TEXT("%s RunAndTrue result"), Side)));
		ASSERT_THAT(AreEqual(FString(TEXT("1,2")), Trace.ToNormalizedString(),
			*FString::Printf(TEXT("%s RunAndTrue Trace F then G; F(float) must not run"), Side)));

		{
			FCanonicalTraceScope Scope(Trace);
			ASSERT_THAT(IsTrue(CanonicalExecuteInt(
				*TestRunner, Engine.Get(), Module, "int RunAndFalse()", Result)));
		}
		ASSERT_THAT(AreEqual(0, Result, *FString::Printf(TEXT("%s RunAndFalse result"), Side)));
		ASSERT_THAT(AreEqual(FString(TEXT("1")), Trace.ToNormalizedString(),
			*FString::Printf(TEXT("%s false && must not evaluate G"), Side)));

		{
			FCanonicalTraceScope Scope(Trace);
			ASSERT_THAT(IsTrue(CanonicalExecuteInt(
				*TestRunner, Engine.Get(), Module, "int RunOrTrue()", Result)));
		}
		ASSERT_THAT(AreEqual(1, Result, *FString::Printf(TEXT("%s RunOrTrue result"), Side)));
		ASSERT_THAT(AreEqual(FString(TEXT("1")), Trace.ToNormalizedString(),
			*FString::Printf(TEXT("%s true || must not evaluate G"), Side)));

		{
			FCanonicalTraceScope Scope(Trace);
			ASSERT_THAT(IsTrue(CanonicalExecuteInt(
				*TestRunner, Engine.Get(), Module, "int RunOrFalse()", Result)));
		}
		ASSERT_THAT(AreEqual(1, Result, *FString::Printf(TEXT("%s RunOrFalse result"), Side)));
		ASSERT_THAT(AreEqual(FString(TEXT("1,2")), Trace.ToNormalizedString(),
			*FString::Printf(TEXT("%s false || must evaluate G"), Side)));
	};

	{
		FNativeTestEngine LegacyEngine;
		LegacyEngine.Create(*TestRunner);
		ON_SCOPE_EXIT { LegacyEngine.Destroy(); };
		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(LegacyEngine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline()));
		ASSERT_THAT(IsTrue(RegisterTrace(LegacyEngine), TEXT("LEGACY logical Trace")));
		FScopedNativeModule Module(
			*TestRunner, LegacyEngine, "CanonicalASTVmLogicalLegacy", ScriptSource);
		ASSERT_THAT(IsTrue(Module.IsValid(), TEXT("LEGACY F && G / F || G must compile")));
		if (!Module.IsValid())
		{
			TestRunner->AddInfo(LegacyEngine.GetMessagesText());
			return;
		}
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_COMPILER,
			static_cast<asCModule*>(static_cast<asIScriptModule*>(Module))->GetLastBytecodePublisher(),
			TEXT("LEGACY engine must stay asCCompiler")));
		RunFour(LegacyEngine, Module, TEXT("LEGACY"));
	}

	{
		FNativeTestEngine CanonicalEngine;
		CanonicalEngine.Create(*TestRunner);
		ON_SCOPE_EXIT { CanonicalEngine.Destroy(); };
		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(CanonicalEngine.Get());
		ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));
		ASSERT_THAT(IsTrue(RegisterTrace(CanonicalEngine), TEXT("CANONICAL logical Trace")));
		FScopedNativeModule Module(
			*TestRunner, CanonicalEngine, "CanonicalASTVmLogicalCanonical", ScriptSource);
		ASSERT_THAT(IsTrue(Module.IsValid(), TEXT("CANONICAL F && G / F || G must Generate")));
		if (!Module.IsValid())
		{
			TestRunner->AddInfo(CanonicalEngine.GetMessagesText());
			return;
		}
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_CANONICAL_CODEGEN,
			static_cast<asCModule*>(static_cast<asIScriptModule*>(Module))->GetLastBytecodePublisher(),
			TEXT("CANONICAL engine must publish CodeGen, not asCCompiler")));
		RunFour(CanonicalEngine, Module, TEXT("CANONICAL"));
	}
}
```

`FScopedNativeModule` converts to `asIScriptModule*` via its existing conversion operator (same as other VmMatrix methods). If the publisher cast does not compile against the live operator, use `asIScriptModule* const Raw = Module;` then `static_cast<asCModule*>(Raw)`.

Repeat the two-Engine envelope for rows 2 and 3 with the fixtures above.

---

## Commands (from `D:\as-cta`, always `-NoXGE` on build)

`RunTests.ps1` does not UBT. Always `RunBuild.ps1` first after adding tests / any impl. Never All. Never flip default CANONICAL.

### RED (tests added, no CodeGen unless already RED)

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-traces-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.IsolatedLogicalShortCircuitMatchesLegacyCanonicalTrace" -Label wave-b-54-traces-red-logical -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.IsolatedConditionalMismatchedArmsMatchesLegacyCanonicalTrace" -Label wave-b-54-traces-red-cond -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests.IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace" -Label wave-b-54-traces-red-temp -TimeoutMs 300000
```

If all three already match the Trace table, that **is** GREEN for this bite. Do not invent CodeGen work. Do not check 5.4.

### GREEN (after tests, and after any tiny CodeGen fix if a row was RED)

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-traces -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics" -Label wave-b-54-traces-sem -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-traces-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-54-traces-canonical -TimeoutMs 600000
```

Compiler JSON may `succeededWithWarnings` (TypedSemanticIR SourceProvenance). Do not write pure `N/N PASS` if a warning exists.

If VALUE dtor Trace is `"1"` only, the impl bite is `as_bytecode_codegen.cpp` live-object / `beh.destruct` for VALUE temps — **not** OpaqueValue memo, **not** 1070 intern-order, **not** `EmitDeclRef` literal fallback.

---

## Hard nos

- Implement now. Second UBT in `D:\as-cta` while OpaqueValue is exclusive.
- Edit `AngelscriptNativeCanonicalASTVmMatrixTests.cpp` / SemaAuthority until OpaqueValue GREEN.
- Check **5.4 / 13.2**. These three rows do not close 5.4 (property/index mutation traces remain OpaqueValue / later).
- Claim dump tokens (`kind=Logical`, `lhs=`, `kind=Conversion`, `kind=MaterializeTemporary`) are traces.
- Retcon `RunSingleEval` / `PropertyRewriteAndMutationSingleEvaluation`.
- Mutable script globals as counters. Script `funcdef` / `@` / `is`. `class` as VALUE.
- `int` condition on the LEGACY ternary (`Flag ?` / `1 ?`).
- Default `canonicalCompilerPipeline = true`. CANONICAL `CompileFunction`.
- Clang/LLVM link. Unreal types in fork frontend files.
- Wave E–G. Archive. Commit unless asked.

---

## Done means (later exclusive UBT, not this attachment)

Three VmMatrix methods exist. Each runs the same source on an isolated LEGACY Engine and an isolated CANONICAL Engine. Trace strings and int results match the tables above. Publishers are `COMPILER` vs `CANONICAL_CODEGEN`. OpaqueValue methods in the same file still GREEN. **5.4 stays `[ ]`.**
