# Wave D R09 freshness — `wave-d-r09-plan.md` vs current `Generate` (post R11 + Wave C construction)

**Date:** 2026-08-21  
**Worktree:** `D:\as-cta`  
**Change:** `refactor-as-canonical-typed-ast-compiler`  
**Mode:** attachment only. Did **not** implement Wave D, edit fork sources, run UBT, route `Build()`, or check `tasks.md` 9.1 / 9.5 / 13.6 / 10.4.

Companions: `wave-d-r09-plan.md` (authoritative task list), `async-work.md` §9 (this package), `wave-c-results.md` (const-only public `Get*`), `wave-c-28-verifier-remainder.md` (C-28 hard-no CALL/CONSTRUCT-without-`resolvedDecl`). Older inventory `r09-codegen-transaction.md` has **pre-R11-wipe** line numbers (`Generate` 1396–1517, `DiscardPending` 1340–1351) — do not use it for Task 3 edits.

---

## Verdict

**`wave-d-r09-plan.md` is still executable.** Tasks 1–7 remain isolated `Generate()` rollback TDD. Do **not** rewrite those tasks or jump to Task 7 `Build()` routing. Production Tasks 8–12 still match `asCModule::Build` → `BuildCompileCode`.

Patch fixtures when implementing, do not rewrite the task list:

- Task 2 fail-after-emit (and any Task 1 method that claims **body** emit) must give `Make` a **resolvable signature** (`int` return). The pasted `ActOnFunctionDecl(..., Obj)` graph fails in `FillFunctionSignature` before any `Emit`.
- Construction writes go through `ActOn*` / `asCASTContext` construction APIs. Public `GetDecl` / `GetStmt` / `GetExpr` / `GetSourceManager` are **const-only**.
- Plan “Out of scope: remaining Wave C construction APIs” is **historical**. 2.4 / 13.4 already landed. Wave D must not re-do them.

After C-28 lands, **re-grep** `Generate`’s unsealed gate (optional `asCASTVerifyPublication`); install/rollback must be unchanged.

---

## Plan-claimed line numbers vs current tree

`Fork/` = `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`  
`SDK/FrontendAST/` = `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/`

Wave C construction edited `as_ast_context.*` / `as_sema*`, not CodeGen. R11 bytecode wipe is already the body the plan cites. **None of the plan’s production-fact line numbers have moved.**

| Plan claim | Current | Status |
| --- | --- | --- |
| `Fork/as_bytecode_codegen.h:17` comment: failure must not mutate module **functions** | `:17` same sentence | **still true** |
| `Fork/as_bytecode_codegen.cpp:1461` `Generate` | `:1461` `int asCBytecodeCodeGen::Generate(...)` | **still true** |
| `Generate` sealed gate | `:1467-1471` `!context.IsSealed()` → `asAST_VERIFY_UNSEALED_PUBLICATION` | **still true** (C-28 may replace this call only) |
| empty `functionDecls` → OK, **skips globals** | `:1488-1489` **before** the TU global loop | **still true** |
| `AllocateGlobalProperty` `:1518` before any body succeeds | `:1518-1521` inside TU `asAST_DECL_VAR` walk, **before** pending/emit | **still true** |
| pending loop `:1532-1557` `asNEW` + `FillFunctionSignature` + `AddScriptFunction` for **all** functions before `Emit` | `:1532-1557` identical order | **still true** |
| emit loop `:1559-1569` fail → `DiscardPending`, globals stay, publisher `NONE` | `:1559-1568` `DiscardPending` then `return error` | **still true** |
| `DiscardPending` `:1400-1416` reverse `RemoveScriptFunction` + wipe `byteCode` + `ReleaseInternal` | `:1400-1416` same (R11 wipe comment `:1408-1411`) | **still true** |
| success `:1572-1583` extra `AddRefInternal` | `:1577` `func->AddRefInternal()` after `scriptFunctions.PushLast` | **still true** |
| `Fork/as_module.cpp:406` `Build` always `builder->BuildCompileCode()` | `:406` still that call; `Build()` is `:354-445` | **still true** |
| `Fork/as_builder.cpp:863` `BuildCompileCode` instantiates `asCCompiler` | `:863` function; `:885` `asCCompiler compiler(this)` | **still true** |
| `Fork/as_builder.cpp:652` `AttachCanonicalSemaIfNeeded` silent OOM | `:652-675` `asNEW` fail → `return;` | **still true** |
| `Fork/as_scriptengine.h:249` `IsCanonicalBytecodeCodeGenReady` `return false` | `:249-252` unconditional `return false` | **still true** |
| `Fork/as_scriptengine.cpp:787` `ep.canonicalCompilerPipeline = false` | `:787` still false | **still true** |
| `SDK/FrontendAST/...CodeGenTests.cpp:180` `CodeGenFailureLeavesNoPartialModuleState` | `:180` unsealed; `GetFunctionCount()==0` only | **still true** |
| same file `:220` `CodeGenDoesNotPublishPartialFunctionsOnUnsupportedBody` | `:220` fail-closed; `GetFunctionCount()==0` only | **still true** |
| R11 CodeGen prefix 24/24 | 24 `TEST_METHOD`s in that file (incl. four teardown + `CodeGenEmitsFuncdefCallAndLambda`) | **still true** (not re-run; count matches source) |
| Task 7 `Build()` `:354-443` | `:354-445` (`#endif` after `return r`) | **still true** (end line +2, body unchanged) |
| Task 7 `PublishCanonicalASTSnapshot` empty-TU fabricate `:2088-2096` | `:2088-2096` `asNEW` + `CreateTranslationUnit` when context missing | **still true** |
| `r09-codegen-transaction.md` `Generate` 1396–1517 / `DiscardPending` 1340–1351 | live `Generate` 1461 / `DiscardPending` 1400 | **stale inventory** — ignore for edits |

No row is “moved” in the plan’s own table.

---

## Behavior checklist (R09 holes)

### Generate still mutates globals before all bodies succeed — **yes**

Order in `Generate` today:

1. Sealed / decl-count / collect function-like decls with bodies (`:1467-1486`).
2. If `functionDecls` empty: `return asAST_VERIFY_OK` (`:1488-1489`) — **never** reaches globals (Task 4 hole).
3. TU children `asAST_DECL_VAR` → `module->AllocateGlobalProperty` (`:1518`) which does `engine->AllocateGlobalProperty` + `varAddressMap.Add` + `scriptGlobals` / `scriptGlobalsList` + `prop->AddRef()` (`as_module.cpp:1800-1819`).
4. Then `asNEW` + `FillFunctionSignature` + `engine->AddScriptFunction` for **every** function (`:1532-1557`).
5. Then `Emit` (`:1559`).

Invalid global type in the TU loop (`:1512-1516`) returns `asNOT_SUPPORTED` **without** rolling already-allocated earlier globals.

`GetNextScriptFunctionId()` (`as_scriptengine.cpp:5682`) **peeks** only. `AddScriptFunction` consumes the free-id. Fill-fail of the current function (`:1544-1549`) `ReleaseInternal`s it without occupying a slot; prior pending functions are `DiscardPending`’d; **globals stay**.

### DiscardPending still leaves globals — **yes**

```1400:1416:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
	void DiscardPending(asCScriptEngine* engine, asCArray<asCScriptFunction*>& pending)
	{
		for( asUINT i = pending.GetLength(); i > 0; --i )
		{
			asCScriptFunction* func = pending[i - 1];
			if( func == 0 )
				continue;
			engine->RemoveScriptFunction(func);
			if( func->scriptData )
				func->scriptData->byteCode.SetLength(0);
			func->ReleaseInternal();
		}
		pending.SetLength(0);
	}
```

Does **not** call `RemoveGlobalProperty`, does not touch `varAddressMap`, `scriptGlobalsList`, funcdefs, or types. R11 wipe is success-path Destroy safety, not R09 rollback. `DestroyHalfCreated` exists (`as_scriptfunction.cpp:469`) and is still unused here.

### Extra `AddRefInternal` on success — **yes**

```1572:1583:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
	for( asUINT i = 0; i < pending.GetLength(); ++i )
	{
		asCScriptFunction* func = pending[i];
		func->AddReferences();
		module->scriptFunctions.PushLast(func);
		func->AddRefInternal();
		module->globalFunctions.Add(func);
		module->globalFunctionList.PushLast(func);
	}

	module->SetLastBytecodePublisher(asBYTECODE_PUBLISHER_CANONICAL_CODEGEN);
```

Still the extra ref vs legacy new-global `AddScriptFunction(int…)`. Task 3 must drop it on commit, not restore it if R11 teardown goes red.

### `AddFuncDef` still absent (lookup-only) — **yes**

No `AddFuncDef` / `FindMatchingFuncdef(..., module)` in `as_bytecode_codegen.cpp`. Funcdefs are `LookupExistingFuncdef` over `engine->funcDefs` then `engine->registeredFuncDefs` (`:564-587`). Missing match → `asNO_FUNCTION` (`:592-596`). Lambdas stay `asAST_DECL_FUNCTION` + trait and use the same `asNEW`/`AddScriptFunction` path.

Snapshot `module->funcDefs` / `engine->funcDefs` / `GetFuncdefCount()` / `functionBehaviours.GetInternalReferenceCountForTesting()` anyway. Success-path `AddReferences` still touches `$func` / funcdef refs. Host `RegisterFuncdef("int Callback(int)")` is a pre-snapshot baseline.

### `Build()` / Ready / default pipeline

- `asCModule::Build` always `builder->BuildCompileCode()` (`:406`). Never `Generate`.
- `IsCanonicalBytecodeCodeGenReady()` still `return false`.
- `ep.canonicalCompilerPipeline = false` at `:787`.

Isolated `Generate` setting publisher `CANONICAL_CODEGEN` must still not flip Ready (plan Task 2 retry assert).

---

## Tasks 1–7 still isolated rollback after C-28 — **yes**

C-28 (`wave-c-28-verifier-remainder.md`) owns verifier remainder only. Hard constraints that keep Tasks 1–7 valid:

| C-28 rule | Effect on R09 Tasks 1–7 |
| --- | --- |
| Must not rewrite `Generate` install/rollback | Transaction RED/GREEN still measures today’s live mutate-then-`DiscardPending` |
| Hard no: CALL/CONSTRUCT missing `resolvedDecl` as a seal firewall | `ActOnConstruct` of unresolved `FValue` must still `Seal()` == 0 |
| `asCASTVerify` stays OK on unsealed construction graphs | Unsealed `Generate` remains a CodeGen/publication gate, not `Seal()` |
| Optional: unsealed CodeGen gate → `asCASTVerifyPublication` | Task 1 unsealed still expects `asAST_VERIFY_UNSEALED_PUBLICATION`; **re-grep lines** after C-28 |
| New checks: stmt multi-owner / stmt-cycle / fallthrough-under-switch / CLEANUP-dtor-when-set | Task 1–7 graphs do not use those shapes |

Do **not** start Tasks 1–7 while C-28 holds exclusive UBT. After C-28 reports Verifier + Frontend CanonicalAST + BodySema + CodeGen green **without** CALL-without-callee, Tasks 1–7 are still the first Wave D work: new transaction test file, **no** `as_module.cpp` / `as_builder.cpp` / Ready edits until Task 7 / 10.

Do **not** grow CodeGen language surface in 1–7. Reuse integer return, globals, host `Callback`, `ActOnConstruct(FValue)` fail-closed.

---

## Construction-API fixture updates (public `Get*` are const-only)

Landed in `as_ast_context.h` (Wave C 2.4 / 13.4). Existing CodeGen tests already compile this way (`CodeGenDoesNotPublishPartialFunctionsOnUnsupportedBody` `:220`).

### What the implementer must use

| Need | API | Do not |
| --- | --- | --- |
| Read nodes / SM | `const asCDecl* GetDecl` / `GetStmt` / `GetExpr` / `const asCSourceManager& GetSourceManager()` | Non-const overload (gone). `Mutable*` are **private**. |
| Build graphs in tests | `asCSema` `ActOn*` + `InternPrimitive` / `InternNamedType` / `Seal` / `GetTranslationUnit()` | `GetDecl(id)->children.PushLast`, `->body =`, `->type =` |
| Extra / malformed edges (not needed in 1–7 subset) | `AddDeclChild` / `SetBody` / `SetStmtExpr` / `SetResolvedDecl` / `AddSourceSection` | Friend-poke POD |
| Parse + Sema | `Parser.SetSema(&Sema)` (still on `as_parser.h:60`) | |
| Snapshot tables | `asCModule` / `asCScriptEngine` internals (`scriptFunctions`, `scriptGlobalsList`, `varAddressMap.Num()`, …) | AST `Get*` |

`asCSema::GetContext()` remains `asCASTContext&` (unsealed builder). Overload resolution still gives **const** `GetDecl` on that reference. `FinishDecl` / `ActOnParamDecl` already read through const `GetDecl`.

`asCRuntimeTypeBridge::FromDataType` still takes **non-const** `asCASTContext&` because it interns types. Rollback tests should not need it; they intern with `InternPrimitive` / `InternNamedType`.

`varAddressMap` is `TMap<void*, asCGlobalProperty*>` (`as_scriptengine.h:422`). Plan’s `Num()` is the right Unreal API. `functionBehaviours` is `asCObjectType`; `GetInternalReferenceCountForTesting()` is on `asCTypeInfo`.

### Fail-after-**emit** vs fail-at-**Fill** (must patch Task 2 paste)

`FillFunctionSignature` (`:1418`) `bridge.Resolve`s the function **return type**. Unresolved `InternNamedType(asAST_TYPE_VALUE_OBJECT, "FValue", 0)` as `ActOnFunctionDecl` return type → empty `asCDataType` → `asINVALID_DECLARATION` **during the pending loop**, **before** the emit loop.

Consequences on **current** `Generate`:

- Task 1 `CodeGenFailureAfterGlobalAllocateRollsBackGlobalAndFunctions` still RED: `AllocateGlobalProperty` runs first, then Fill of `Make` fails, `DiscardPending` drops `F`, **`G` stays**. Keep the global; that is the first R09 hole. Do not treat `GetFunctionCount()==0` as proof.
- Task 1 `CodeGenFillSignatureFailureAfterGlobalAndPriorFunctionRollsBack` (`NoSuchType` param) is already a Fill-fail fixture. RED is leftover `G`, not leftover engine function occupancy (`GetNextScriptFunctionId` does not consume; `DiscardPending` restores prior `F`).
- Task 2 `CodeGenUnsupportedBodyAfterFuncdefStoreRollsBackRefs` as pasted (`Make` returns `FValue`) **never emits** `Double`/`Store`. No `FuncPtr`/`REFCPY` bytecode, so `FunctionBehavioursInternalRefs` may already match and the method may **PASS** today — wrong RED. **Fix:** `ActOnFunctionDecl(Tu, "Make", IntType, …)` then `ActOnReturnStmt(Make, ActOnConstruct(Obj, empty, …), …)`. `ActOnConstruct` wraps `CONSTRUCT` in `MATERIALIZE`/`CLEANUP`; `EmitConstructInto` then `asNOT_SUPPORTED` when `GetTypeInfo()` is null (`:746-752`). Cannot patch `GetDecl(Make)->type` after the fact.

Copy the live CodeGen ActOn* style (`AngelscriptNativeCanonicalASTCodeGenTests.cpp`), not POD writes from any pre-construction draft.

C-28 must keep this `FValue` construct graph sealable (hard no CALL/CONSTRUCT-without-`resolvedDecl`). `ActOnConstruct` already `SetResolvedDecl`s an empty ctor id when `SelectConstructor` finds no class — that is not a verifier reject.

### Task 4 global-only skip

Still live: no function-like body → return OK at `:1488` before `:1503`. `ActOnVarDecl(Tu, "G", IntType, …)` + no function + `Seal` + `Generate` must leave tables unchanged (preferred) or fully commit. Do not allocate-without-publisher.

---

## What not to do from this note

- Do not implement the artifact / `Build()` routing / Ready flip.
- Do not edit `as_bytecode_codegen.cpp` until Tasks 1–2 are RED on exclusive UBT after C-28.
- Do not mark `tasks.md` 9.1 / 9.5 / 13.6 / 10.4 from this freshness pass or from later isolated greens.
- Do not treat `r09-codegen-transaction.md` line numbers as current.
- Do not re-open Wave C construction (2.4 / 13.4 closed).
