# Wave D 9.5 — F4 later RED (default LEGACY lambda node-layout)

Worktree: `D:\as-cta`. Read-only package **D-95-f4-next**.
Do **not** edit `Plugins/`, tests, `tasks.md`, or fork source in this package.
Do **not** run UBT / `RunBuild` / `RunTests`.
Do **not** check `tasks.md` 9.5 / 13.3 / 13.1 / 10.2.
Do **not** implement the parser/compiler fix here.
Do **not** redo `attachments/wave-d-95-lambda-map.md` or GREEN `CanonicalLambdaBuildPublishesCodeGenAndExecutes`.

Default pipeline stays LEGACY. No Clang/LLVM. No Unreal types in the fork. No script `funcdef` / `@` / `is`. Host `RegisterFuncdef` is allowed.

Exclusive UBT is currently **D-95-import** (`attachments/wave-d-95-import-impl.md`). Queue this test + fork walk after that mutex releases. Same plugin DLL; one UBT user in `D:\as-cta` even though F4 files do **not** overlap `as_bytecode_codegen.cpp`.

---

## Why F4 is still open

Fifth-pass F4 (`reviews/implementation-rereview-2026-08-22-fifth-pass.md`): default Engine is LEGACY (`as_scriptengine.cpp:787` `ep.canonicalCompilerPipeline = false`). Wave B `ParseLambda()` added `snIdentifier("function")` plus `snParameterList` so Canonical Sema can intern `<lambda>`. `asCCompiler::ImplicitConvLambdaToFunc()` still walks **direct children** of `snFunction` as if names/types were siblings of the statement block.

That is a **default-pipeline** regression, not a CANONICAL-only hole.

Live Compiler prefix is **344/344** (`wave-b-compiler` / `async-work.md`). That count includes CanonicalAST ProductionCodeGen. It is **not** an F4 counter-proof:

| Existing method | Prefix | Pipeline | What it does | Why it does not close F4 |
| --- | --- | --- | --- | --- |
| `CanonicalLambdaBuildPublishesCodeGenAndExecutes` | `Compiler.CanonicalAST.ProductionCodeGen` | **SetCompilerPipeline(CANONICAL)** | IIFE `function(int X){ return X+1; }(41)` execute 42 + `CANONICAL_CODEGEN` | Different pipeline. Immediate call, **no** host funcdef, **no** `ImplicitConvLambdaToFunc` |
| `CanonicalHostFuncdefBuildPublishesCodeGenAndExecutes` | same | CANONICAL | Named `Double` passed to host `Callback` | No lambda node |
| Frontend `CodeGenEmitsFuncdefCallAndLambda` / `CodeGenLambdaTeardownSurvivesEngineDestroy` | `Frontend.CanonicalAST.CodeGen` | Isolated `GenerateCanonicalFromSource` | Stored 1-arg lambda after host `RegisterFuncdef` | Not module `Build()` on default LEGACY `asCCompiler` |
| Frontend `AnonymousFunctionProducesCurrentParserShape` | `Frontend.Parser.Expressions` | parse-only | `function() { return 1; }` counts one `snFunction` | No funcdef conversion, no execute |
| SemaAuthority lambda dumps | `Compiler.CanonicalAST.SemaAuthority` | CANONICAL seal/dump | Intern `<lambda>` / CALL callee | No LEGACY Bytecode |
| Conformance `AnonymousFunctionCompilesInvokesAndReturnsValue` | `Conformance.Lambda238` **Disabled `#as-v238-backport`** | uses script `funcdef` + `@` | Forbidden dialect | Must not be re-enabled for F4 |

**Compiler 344/344 has no default-LEGACY 0-arg (or 1-arg) lambda-to-host-funcdef compile+execute fixture.** That is why F4 stays open after ProductionCodeGen IIFE 42 is GREEN.

---

## Live node shape vs what `ImplicitConvLambdaToFunc` scans

### `ParseLambda()` (`as_parser.cpp:1722-1807`)

BNF (`1721`): `LAMBDA ::= 'function' '(' [[TYPE TYPEMOD] IDENTIFIER …] ')' STATBLOCK`.

Live tree (not the pre–Wave-B sibling list):

```text
snFunction
├── snIdentifier("function")          // 1736-1740; FunctionNameNode / Sema intern cue
├── snParameterList                   // 1742-1794
│   └── [optional] snDataType + snDataType(TYPEMOD) + snIdentifier(name) …
└── snStatementBlock                  // 1805 ParseFunctionStatementBlock
```

0-arg `function() { return 42; }`: `snParameterList` has **no** children.

1-arg `function(int X) { return X + 1; }`: list children are `snDataType(int)`, `ParseTypeMod` node (`snDataType`, possibly empty), `snIdentifier("X")`. They are **not** direct children of `snFunction`.

Canonical Sema is fine with this: `WalkParameterList` (`as_sema_decl.cpp:816`) uses `FirstChildOfType(node, snParameterList)` then `WalkParameterSequence` on the **list** children. That path is **not** what LEGACY conversion uses.

### `ImplicitConvLambdaToFunc()` (`as_compiler.cpp:11521-11578`)

Triggered only when `to.IsFuncdef() && ctx->IsLambda()` (`11606-11608`). LEGACY expr of `snFunction` is `ctx->SetLambda(vnode)` (`15685-15690`); `exprNode` is the `snFunction`.

Quoted scan (`11527-11553`):

```text
asUINT count = 0;
asCScriptNode *argNode = ctx->exprNode->firstChild;
while( argNode->nodeType != snStatementBlock )
{
    if (argNode->nodeType == snDataType)
    {
        // CreateDataTypeFromNode + ModifyDataTypeFromNode vs funcDef[count]
        argNode = argNode->next;
    }
    if( argNode->nodeType == snIdentifier )
        count++;
    argNode = argNode->next;
}
if (funcDef->parameterTypes.GetLength() != count)
    return asCC_NO_CONV;
```

Direct-child walk only. It **does not enter `snParameterList`**.

| Source | Direct children the scan sees | `count` | Type check |
| --- | --- | ---: | --- |
| 0-arg `function(){…}` | `"function"` ident, empty `snParameterList`, block | **1** | never (no `snDataType` sibling) |
| 1-arg `function(int X){…}` | `"function"` ident, `snParameterList` (skipped), block | **1** (arity coincidence) | **skipped** — real `int` / `X` live under the list |

0-arg assigned to host `int ZeroArg()` → `count==1` vs 0 params → `asCC_NO_CONV` → **honest compile RED**.

1-arg assigned to host `int Unary(int)` → count matches by accident; types never compared. `RegisterLambda` (`as_builder.cpp:5505-5516`) uses the **same sibling walk**: parameter name becomes `"function"`, never `"X"`. Body `return X + 1` is then an unknown identifier (or the lambda is registered with the wrong name). **Honest compile RED**; do not treat arity-1 as GREEN without execute `42`.

`RegisterLambda` dummy pad (`5518-5528`) only extends names when `names.Length < funcDef->parameterTypes.Length`. 1-arg already has one identifier (`"function"`), so it does **not** invent `"X"`.

---

## Why CANONICAL IIFE 42 does not close F4

`CanonicalLambdaBuildPublishesCodeGenAndExecutes` (`AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp:214`):

```angelscript
int F() {
  return function(int X) {
    return X + 1;
  }(41);
}
```

| | CANONICAL IIFE (already GREEN) | F4 LEGACY funcdef (this brief) |
| --- | --- | --- |
| Pipeline | `SetCompilerPipeline(CANONICAL)` | **default LEGACY**; do not Set CANONICAL |
| Publisher | `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` | `asBYTECODE_PUBLISHER_COMPILER` |
| Lowering | CodeGen `asBC_CALL` of interned `TRAIT_LAMBDA` (`wave-d-95-lambda-map.md`) | `ImplicitConvLambdaToFunc` → `RegisterLambda` → `asBC_FuncPtr` / later `CallPtr` |
| Host funcdef | **none** (must not add one to that method) | **required** `RegisterFuncdef` |
| Script `funcdef` | rejected | still rejected |
| Node consumer | Sema `WalkParameterList` + CodeGen binds-by-decl-id | Compiler sibling ident walk |

Fixing F4 in `as_bytecode_codegen.cpp` only cannot repair default LEGACY conversion. **Hard no.**

---

## Later TEST_METHODs (do not add in this package)

Add to existing class `FCompilerCoreTests` in:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/AngelscriptNativeCompilerCoreTests.cpp`

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.Core`

Do **not** add these to `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` (D-95-import owns that file + CANONICAL IIFE already lives there). Do **not** use `FScopedNativeModule` as the only Build gate: that helper returns early on `Build()<0` without failing (`AngelscriptNativeCoreTestSupport.h:650-657`) and would **false-green** the 0-arg `asCC_NO_CONV`. Use `CompileNativeModule` and assert `== 0`.

Extra includes on that file (today it has no `as_scriptengine.h`):

```cpp
#include "StartAngelscriptHeaders.h"
#include "source/as_module.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"
```

Execution: `AngelscriptSDKTestSupport::ExecuteScriptFunction` (already via `AngelscriptNativeExecutionTestSupport.h`) or `CanonicalExecuteInt` if the CanonicalAST support header is added. Result must be **42**.

Keep existing Core methods. Do not `SetCompilerPipeline`. Do not re-enable tokenizer `funcdef`.

### 1. `LegacyZeroArgLambdaToHostFuncdefExecutes42` — honest RED today

0-parameter lambda stored in a **host** funcdef. Current scan counts `function` as one parameter → Build must fail (or, if someone later special-cases count, execute must still be 42).

```cpp
	TEST_METHOD(LegacyZeroArgLambdaToHostFuncdefExecutes42)
	{
		using namespace AngelscriptNativeTestSupport;

		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline(),
			TEXT("F4 must run on the default LEGACY pipeline")));

		ASSERT_THAT(IsTrue(ScriptEngine->RegisterFuncdef("int ZeroArg()") >= 0,
			TEXT("host RegisterFuncdef ZeroArg is allowed")));

		asIScriptModule* Module = nullptr;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int F()
			{
				ZeroArg Z = function()
				{
					return 42;
				};
				return Z();
			}
			)AS");
		ASSERT_THAT(AreEqual(0, CompileNativeModule(
			Engine.Get(),
			"LegacyZeroArgLambda",
			ScriptSource.c_str(),
			Module),
			TEXT("LEGACY 0-arg lambda-to-host-funcdef must compile (F4: snIdentifier function must not count as a parameter)")));
		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			AngelscriptSDKTestSupport::ExecuteScriptFunction(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 42,
			TEXT("LEGACY 0-arg lambda F() must execute 42")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_COMPILER,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("default pipeline must still publish asCCompiler")));
	}
```

Smallest RED fixture (same script):

```angelscript
int F()
{
	ZeroArg Z = function()
	{
		return 42;
	};
	return Z();
}
```

Host: `RegisterFuncdef("int ZeroArg()")`. No `SetCompilerPipeline`. No script `funcdef`.

### 2. `LegacyOneArgLambdaToHostFuncdefExecutes42` — arity coincidence is not GREEN

Explicit `int` parameter. Count may already be 1. Execute `U(41)==42` proves the real param is `X:int`, not the `"function"` label.

```cpp
	TEST_METHOD(LegacyOneArgLambdaToHostFuncdefExecutes42)
	{
		using namespace AngelscriptNativeTestSupport;

		FNativeTestEngine Engine;
		Engine.Create(*TestRunner);
		ON_SCOPE_EXIT { Engine.Destroy(); };

		asCScriptEngine* const ScriptEngine = static_cast<asCScriptEngine*>(Engine.Get());
		ASSERT_THAT(AreEqual(asCOMPILER_PIPELINE_LEGACY, ScriptEngine->GetCompilerPipeline(),
			TEXT("F4 must run on the default LEGACY pipeline")));

		ASSERT_THAT(IsTrue(ScriptEngine->RegisterFuncdef("int Unary(int)") >= 0,
			TEXT("host RegisterFuncdef Unary is allowed")));

		asIScriptModule* Module = nullptr;
		const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
			int F()
			{
				Unary U = function(int X)
				{
					return X + 1;
				};
				return U(41);
			}
			)AS");
		ASSERT_THAT(AreEqual(0, CompileNativeModule(
			Engine.Get(),
			"LegacyOneArgLambda",
			ScriptSource.c_str(),
			Module),
			TEXT("LEGACY 1-arg lambda-to-host-funcdef must compile and bind X, not the function label")));
		int32 Value = 0;
		ASSERT_THAT(IsTrue(
			AngelscriptSDKTestSupport::ExecuteScriptFunction(*TestRunner, Engine.Get(), Module, "int F()", Value)
				&& Value == 42,
			TEXT("LEGACY 1-arg lambda F() must execute 42")));
		ASSERT_THAT(AreEqual(
			asBYTECODE_PUBLISHER_COMPILER,
			static_cast<asCModule*>(Module)->GetLastBytecodePublisher(),
			TEXT("default pipeline must still publish asCCompiler")));
	}
```

Do not merge these into the CANONICAL IIFE method. Two methods: 0-arg cannot hide behind 1-arg count coincidence, and a count-only “skip the function identifier” patch cannot hide skipped `snParameterList` types/names.

Optional later (not this RED slice): N-arg, `&` / `in`/`out`, member-owned lambda, teardown. Fifth-pass asked for that matrix; 0+1 execute-42 is the gate that is missing from 344/344.

---

## Later exclusive UBT (after D-95-import)

**Wait for D-95-import** even though F4 sources do not touch `as_bytecode_codegen.cpp`:

- This worktree allows **one** UBT user (`async-dispatch.md`). Import currently owns `as_bytecode_codegen.cpp` + ProductionCodeGen tests and the AngelscriptRuntime / AngelscriptTest DLLs.
- Adding Core tests still compiles `AngelscriptTest`. Fixing F4 still relinks `AngelscriptRuntime`. A second `RunBuild.ps1` races the same mutex.
- After import 17/17 + Cutover, this package may take exclusive UBT.

Files a later implementer may edit:

| File | Why |
| --- | --- |
| `AngelscriptNativeCompilerCoreTests.cpp` | TDD: two methods above first (RED), then GREEN |
| `as_compiler.cpp` `ImplicitConvLambdaToFunc` | Enter `snParameterList`; do not count `snIdentifier("function")` as a parameter; type-check list `snDataType` nodes |
| `as_builder.cpp` `RegisterLambda` | Same layout: names from the list, not the `function` token |
| `as_parser.cpp` `ParseLambda` | Only if the chosen fix restores a compiler-compatible sibling layout **without** breaking Canonical Sema intern (`snParameterList` + `"function"` ident). Prefer compiler/builder walks matching Sema over ripping the Sema shape |

Do **not** “fix” F4 by emitting a CANONICAL CodeGen IIFE path, by `SetCompilerPipeline(CANONICAL)` in these tests, or by re-enabling script `funcdef`. Default pipeline is LEGACY; publisher must stay `COMPILER`.

TDD order: tests RED on Compiler.Core → parser/compiler/builder walk → Compiler.Core GREEN → Compiler prefix still all-pass. Do **not** mark `tasks.md` 9.5 from these two going green (9.5 is full-language CodeGen, not LEGACY layout). F4 close is “default LEGACY lambda-to-host-funcdef compile+execute 42 for 0-arg and explicit-`int` 1-arg.”

Verification later (not this package):

```text
Tools\RunBuild.ps1 -NoXGE
Tools\RunTests.ps1 -Prefix Angelscript.TestModule.AngelScriptSDK.Compiler.Core -NoXGE
```

Then the full Compiler prefix. Never All for this slice.
