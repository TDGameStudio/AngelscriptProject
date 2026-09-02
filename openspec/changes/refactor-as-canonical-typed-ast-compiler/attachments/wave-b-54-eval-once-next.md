# Wave B exclusive UBT — B-54-eval-once-codegen (F1 Generate remainder)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
**TDD. One UBT user. Do not check 5.4 / 13.2 / 9.5 / 9.4.**

F1 **dump** already GREEN (`MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath`, SemaAuthority **214/214** `wave-b-f1-sema`). This package is **only** the remaining CodeGen double-eval of `literalBits` after children.

Companions: `async-work.md` §4 Hole 1; `wave-b-54-generate-remaining.md` (later 1070 / OpaqueValue memo / mutation — **not this UBT**); `eighth-pass-verified.md` F1 row.

---

## Goal

CANONICAL `asCBytecodeCodeGen::Generate` of `return Make().Get();` evaluates `Make()` **once** and `Get()` **once**. Receiver is not `EmitExpr`'d a second time from `literalBits`.

## Architecture

Do not change Parser/Sema intern. The sealed graph already has one `callee=Make()` and one `callee=T::Get() receiver=`. `EmitCall` must treat `literalBits` as an **id alias** of a child already emitted, not a second evaluation.

## Files

- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` `EmitCall` (~1907-1924)
- Test: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp`
- Do **not** edit: `as_parser.cpp`, `as_sema_expr.cpp`, `as_sema.cpp`, `as_sema_decl.cpp`, verifier, dump grammar
- Record after GREEN: `attachments/wave-b-results.md` `## B-54-eval-once-codegen`; patch `eighth-pass-verified.md` F1 Generate row

## Live defect

```1907:1924:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
			asCArray<int> argOffsets;
			for( asUINT i = 0; i < expr->children.GetLength(); ++i )
			{
				const asCExpr* child = context.GetExpr(expr->children[i]);
				if( expr->literalBits && child && child->kind == asAST_EXPR_CONVERSION )
				{
					continue;
				}
				argOffsets.PushLast(EmitExpr(expr->children[i]));
			}
			if( !ok )
				return 0;

			int pop = 0;
			int recvOffset = 0x7fffffff;
			if( callee && callee->objectType && expr->literalBits )
			{
				recvOffset = EmitExpr(asASTExprId((asUINT)expr->literalBits));
			}
```

`ActOnCallExpr` stores the receiver both as a CALL child **and** in `literalBits`. After F1 Sequence pop, the stmt expr *is* the member CALL. Children eval already runs `Make()`. The `literalBits` path runs it again.

Minimal fix: if `literalBits` names an id already in `expr->children` whose offset was pushed, reuse that `argOffsets` slot. Only `EmitExpr(literalBits)` when that id was **not** already emitted as a child.

Do not invent a new `asCExpr` field. Do not globally change `FindExistingExpr`. Do not delete Sequence skip of unresolved CALL (`:922-926`) in this UBT.

## Hard nos

- Check **5.4** (1070, OpaqueValue memo, mutation traces, Logical/Conditional isolated matrix still open).
- Check **13.2 / 9.5 / 9.4**.
- Default `canonicalCompilerPipeline = true`. CANONICAL `CompileFunction`.
- Script `funcdef` / `@` / `is`. Mutable script globals as counters. Use existing `Trace(...)`.
- Second UBT. Wave E–G. Archive. Commit unless asked.
- CALL-without-callee as unsealed `asCASTVerify` firewall.
- Fixing `EmitDeclRef` `:1070`. OpaqueValue passthrough memo. Index write-through.
- Weakening F1 dump test.

---

### Task 1: Failing CANONICAL execute test

**Files:**
- Modify: `AngelscriptNativeCanonicalASTVmMatrixTests.cpp` (add a method on `FCanonicalASTVmMatrixTests`)

Existing `PropertyRewriteAndMutationSingleEvaluation` / `RunSingleEval` is **default LEGACY** `asCCompiler`. Do **not** retcon it. Do **not** weaken its asserts.

- [ ] **Step 1: Write the failing test**

Add `TEST_METHOD(CanonicalMemberPostfixCallEvaluatesReceiverOnce)` after `PropertyRewriteAndMutationSingleEvaluation`.

Shape (keep Allman / `ASTEST_AS_ANSI` / matcher asserts; follow nearby VmMatrix methods):

```cpp
TEST_METHOD(CanonicalMemberPostfixCallEvaluatesReceiverOnce)
{
	using namespace AngelscriptNativeTestSupport;
	FNativeTestEngine Engine;
	Engine.Create(*TestRunner);
	ON_SCOPE_EXIT { Engine.Destroy(); };
	asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
	ASSERT_THAT(IsTrue(ScriptEngine->SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)));
	ASSERT_THAT(IsTrue(RegisterTrace(Engine), TEXT("canonical member eval-once needs Trace")));

	FScopedNativeModule Module(
		*TestRunner,
		Engine,
		"CanonicalASTVmMemberOnce",
		ASTEST_AS_ANSI(R"AS(
			class T
			{
				int Get()
				{
					Trace(2);
					return 1;
				}
			}

			T Make()
			{
				Trace(1);
				T v;
				return v;
			}

			int Entry()
			{
				return Make().Get();
			}
			)AS"));
	ASSERT_THAT(IsTrue(Module.IsValid(), TEXT("CANONICAL Make().Get() must Generate")));
	if (!Module.IsValid())
	{
		TestRunner->AddInfo(Engine.GetMessagesText());
		return;
	}

	FCanonicalExecutionTrace Trace;
	int32 Result = 0;
	{
		FCanonicalTraceScope Scope(Trace);
		ASSERT_THAT(IsTrue(CanonicalExecuteInt(
			*TestRunner, Engine.Get(), Module, "int Entry()", Result)));
	}
	ASSERT_THAT(AreEqual(1, Result, TEXT("Get() returns 1")));
	ASSERT_THAT(AreEqual(FString(TEXT("1,2")), Trace.ToNormalizedString(),
		TEXT("Make() then Get(); Make() must run once")));
}
```

Do **not** use a mutable script global as the counter. `Trace(1)` / `Trace(2)` already exist.

Pipeline is **this Engine only**. Do not change the class-level default.

- [ ] **Step 2: Build, then run RED**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-eval-once-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics" -Label wave-b-54-eval-once-red -TimeoutMs 600000
```

Expected RED: `CanonicalMemberPostfixCallEvaluatesReceiverOnce` — trace `"1,1,2"` or `"1,2,1"` (Make twice), **or** `Module.IsValid()==false` with Generate fail. Record the exact failure in `wave-b-results.md`. If the failure is `EmitDeclRef` `:1070` on `T v;` / `Get()`, **stop** and write why — do not silently switch fixtures; do not widen lookup from the TU.

`RunTests.ps1` does not UBT. Always `RunBuild.ps1` first.

### Task 2: Minimal EmitCall reuse

- [ ] **Step 3: Implement**

In `EmitCall`, after the children loop:

```text
recvOffset = 0x7fffffff
if callee is object method:
  if literalBits names a child already pushed in argOffsets:
    recvOffset = that argOffsets slot
  else if literalBits:
    recvOffset = EmitExpr(literalBits)   // once; not a child
  else if extra child beyond formals:
    recvOffset = last argOffset          // keep existing fallback
```

Do not skip emitting the receiver child (the child *is* the single evaluation). Do not `EmitExpr` the same id twice.

Keep generated-Get property shortcut (`:1818-1855`) unchanged unless the new test proves it double-evals this fixture (it should not: `Get()` is a real method).

- [ ] **Step 4: Build, then GREEN prefixes**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-eval-once -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics" -Label wave-b-54-eval-once-sem -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-eval-once-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-54-eval-once-canonical -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-b-54-eval-once-frontend -TimeoutMs 600000
```

Expected: Semantics includes the new method PASS; SemaAuthority **214/214** or live total; CanonicalAST **262/262** or live (new method lives under Semantics, so CanonicalAST count may bump if the prefix includes it — record the live total); Frontend **85/85**.

Do **not** run All. Do **not** check `tasks.md` 5.4 / 13.2 / 9.5. Do **not** flip default.

- [ ] **Step 5: Record, do not commit**

Append `## B-54-eval-once-codegen` to `attachments/wave-b-results.md` with RED/GREEN report paths. Patch `eighth-pass-verified.md` F1 Generate row: dump landed + this execute slice landed; 1070 / OpaqueValue memo still open. Leave `tasks.md` boxes `[ ]`.

Do not commit unless the user asks.

## Done means (this UBT)

- `Make().Get()` CANONICAL execute: Trace `"1,2"`, result `1`.
- `EmitCall` does not re-eval a receiver id that was already a child.
- F1 dump test still green.
- **5.4 stays `[ ]`.** Isolated Logical/Conditional/mutation traces and `EmitDeclRef` 1070 are **not** this package.
