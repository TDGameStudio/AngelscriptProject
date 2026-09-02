# Wave D R09 — isolated remainder after Task 1 (D-r09-task2plus)

**Date:** 2026-08-21  
**Worktree:** `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`)  
**Change:** `refactor-as-canonical-typed-ast-compiler`  
**Package:** `async-work.md` **D-r09-2-7** — **isolated Tasks 2–5 landed.** Do **not** mark `tasks.md` 9.1 / 9.5 / 13.6 / 10.4 / 13.1. Stop before Task 6 (`Build()`).

**Stop:** isolated `Generate` remainder only (plan Tasks 2–5). **Do not start production `Build()`** (`wave-d-r09-plan.md` Tasks 6+). Default pipeline stays LEGACY. `IsCanonicalBytecodeCodeGenReady()` stays false.

Companions: `wave-d-r09-plan.md` (authoritative task list), `wave-d-r09-freshness.md` (**stale line numbers** — `Generate` was 1461), `async-work.md` §8.

R11 teardown AV is **closed** (CodeGen 24/24). Do not re-diagnose it.

---

## Header facts (live, 2026-08-21)

| Fact | Live |
| --- | --- |
| Isolated `asCBytecodeCodeGen::Generate` | **test-only** |
| Production `asCModule::Build` | still `builder->BuildCompileCode()` → `asCCompiler` (`as_module.cpp:406`) |
| Default pipeline | LEGACY (`ep.canonicalCompilerPipeline = false` at `as_scriptengine.cpp:787`) |
| `IsCanonicalBytecodeCodeGenReady()` | unconditional `return false` (`as_scriptengine.h:249-252`) |
| `as_bytecode_codegen_artifact.h` | **absent** (not in `Fork/`; no `.h`/`.cpp` include) |
| Wave D Task 1 | **landed** — Transaction 3/3 |
| Task 1 test file | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp` |
| Task 1 methods | `CodeGenUnsealedFailureLeavesTablesUnchanged`, `CodeGenFailureAfterGlobalAllocateRollsBackGlobalAndFunctions`, `CodeGenFillSignatureFailureAfterGlobalAndPriorFunctionRollsBack` |
| Task 1 fork change | `DiscardAllocatedGlobals` in `as_bytecode_codegen.cpp:1418-1454` also shrinks the last engine global slot so `freeGlobalPropertyIds` matches pre-Generate |
| Generate install model | still **live-mutate then `DiscardPending` + `DiscardAllocatedGlobals`** — not a detached artifact |

Path aliases:

| Alias | Path from `D:\as-cta` |
| --- | --- |
| `Fork/` | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` |
| `SDK/FrontendAST/` | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/` |

---

## Live line-number table

`wave-d-r09-freshness.md` claimed “none of the plan’s production-fact line numbers have moved.” That was true **before** Task 1 inserted `DiscardAllocatedGlobals`. Re-grep of live `Fork/as_bytecode_codegen.cpp` on 2026-08-21:

| Site | Plan (`wave-d-r09-plan.md`) | Freshness (`wave-d-r09-freshness.md`) | **Live 2026-08-21** | Status |
| --- | --- | --- | --- | --- |
| `Generate` start | `:1461` | `:1461` **stale** (`async-work.md` already said ~1499) | **`:1499`** `int asCBytecodeCodeGen::Generate(...)` | **moved +38** (Task 1 helper) |
| sealed gate | implied `:1467-1471` | `:1467-1471` `!context.IsSealed()` → `asAST_VERIFY_UNSEALED_PUBLICATION` | **`:1505-1510`** same gate | moved |
| empty `functionDecls` skip | `:1488-1489` before TU global loop | `:1488-1489` | **`:1526-1527`** `if( functionDecls.GetLength() == 0 ) return asAST_VERIFY_OK;` **before** the global loop | **still skips globals** |
| `AllocateGlobalProperty` loop | `:1518` | `:1518-1521` | **`:1542-1565`** TU `asAST_DECL_VAR` walk; allocate at **`:1557-1560`** | moved; still **before** pending/emit |
| pending `AddScriptFunction` loop | `:1532-1557` | `:1532-1557` | **`:1571-1598`** `asNEW` + `FillFunctionSignature` + `engine->AddScriptFunction` for **all** functions before any `Emit` | moved; order **unchanged** |
| emit loop | `:1559-1569` | `:1559-1568` fail → `DiscardPending` | **`:1600-1612`** fail → `DiscardPending` **and** `DiscardAllocatedGlobals` | moved; globals now discarded on emit fail |
| `DiscardPending` | `:1400-1416` | `:1400-1416` | **`:1400-1416`** reverse `RemoveScriptFunction` + wipe `byteCode` + `ReleaseInternal` | **same** (R11 wipe still here) |
| `DiscardAllocatedGlobals` | not in plan table | **absent** (pre-Task 1) | **`:1418-1454` NEW** — `RemoveGlobalVar` / `RemoveGlobalProperty`, then shrink last engine slot + pop matching free id | Task 1 only |
| success extra `AddRefInternal` | `:1577` | `:1577` | **`:1619`** after `scriptFunctions.PushLast` | **still present** |
| `asCModule::Build` | `:406` `BuildCompileCode` | `:406` | **`:406`** still `r = builder->BuildCompileCode();` (`Build()` `:354-445`) | **unchanged** |
| `IsCanonicalBytecodeCodeGenReady()` | `:249` `return false` | `:249-252` | **`:249-252`** unconditional `return false` | **unchanged** |
| artifact header | create in Task 3 | not present | **does not exist** | Task 3 still required |

Other live anchors that did **not** move:

| Site | Live |
| --- | --- |
| `Fork/as_bytecode_codegen.h:17` comment | “Failure must not mutate functions, globals, funcdefs, or types.” — **comment already claims the R09 contract; Generate still live-mutates** |
| `FillFunctionSignature` | **`:1456-1496`** (was `:1418` in freshness; shifted by `DiscardAllocatedGlobals`) |
| `LookupExistingFuncdef` | **`:564-587`** engine `funcDefs` then `registeredFuncDefs` only |
| `EmitFuncPtrInto` `FuncPtr`/`REFCPY` | **`:603-610`** `asBC_FuncPtr` + `asBC_REFCPY` of `&functionBehaviours` |
| `EmitConstructInto` unresolved type | **`:746-752`** `GetTypeInfo()` null → `asNOT_SUPPORTED` |
| `asCBuilder::BuildCompileCode` | **`:863`** function; `:885` `asCCompiler compiler(this)` |
| `AttachCanonicalSemaIfNeeded` silent OOM | **`:652-675`** `asNEW` fail → `return;` |
| `DestroyHalfCreated` | `as_scriptfunction.cpp:469` — **unused by CodeGen** (still wipe+`ReleaseInternal`) |
| `FindMatchingFuncdef` | `as_scriptengine.cpp:5830` — **not called from `as_bytecode_codegen.cpp`** |

Live `Generate` control flow after Task 1:

```text
1499  Generate
1505  sealed? else UNSEALED_PUBLICATION (no mutation)
1511  decl-count? else DANGLING_ID
1518  collect function-like decls with bodies
1526  functionDecls empty → return OK   ← skips globals (Task 4)
1529  no module → asNO_MODULE
1542  TU asAST_DECL_VAR → AllocateGlobalProperty (live module + engine)
1571  for each fn: asNEW + Fill + AddScriptFunction (live engine slots)
1600  for each fn: Emit; on fail DiscardPending + DiscardAllocatedGlobals
1614  success: AddReferences + PushLast + extra AddRefInternal + lists
1624  publisher CANONICAL_CODEGEN last
```

---

## What Task 1 proved vs what it did not

Snapshot helper **`FCodeGenTableSnapshot` + `CaptureCodeGenTables` + `AssertCodeGenTablesEqual`** in the Transaction test file is still **the contract** for Tasks 2–5. `GetFunctionCount()==0` is not proof. Existing CodeGen methods `CodeGenFailureLeavesNoPartialModuleState` / `CodeGenDoesNotPublishPartialFunctionsOnUnsupportedBody` stay regression-only (function count, not tables).

### Proved (Transaction 3/3 — reported; this package did not re-run)

| Method | Path hit on **current** `Generate` | What equality proved |
| --- | --- | --- |
| `CodeGenUnsealedFailureLeavesTablesUnchanged` | gate at `:1505` before any allocate | unsealed failure does not touch functions/globals/funcdefs/types/publisher |
| `CodeGenFailureAfterGlobalAllocateRollsBackGlobalAndFunctions` | allocate `G` at `:1557`, then **Fill of `Make` fails** (`ActOnFunctionDecl(..., Obj)` → unresolved `FValue` return → `asINVALID_DECLARATION` at `:1463-1474`) | `DiscardAllocatedGlobals` restores module globals, occupied `engine->globalProperties`, `varAddressMap`, and **`freeGlobalPropertyIds`** (last-slot shrink at `:1444-1451`). `DiscardPending` is a no-op here if Fill fails before `AddScriptFunction` of `Make`; prior `F` is discarded if already pending |
| `CodeGenFillSignatureFailureAfterGlobalAndPriorFunctionRollsBack` | allocate `G`, Fill `F` OK + `AddScriptFunction`, Fill `Bad` param `NoSuchType` fails (`:1484-1488`) | leftover `G` and prior pending `F` roll back; engine function occupancy / free ids match |

Task 1 **did** land the first R09 global hole: failure after `AllocateGlobalProperty` no longer leaves `G`.

### Did **not** prove (still the isolated remainder)

- **Detached artifact / atomic install.** Generate still mutates live `module->scriptGlobals*` / `engine->globalProperties` / `engine->scriptFunctions` **during** the call, then discards. Nothing is held off-module until `Commit`.
- **Fail-after-emit with `FuncPtr`/`REFCPY` bytecode.** Task 1 `Make` returns unresolved `FValue`, so `FillFunctionSignature` fails **in the pending loop** (`:1584`) **before** the emit loop (`:1600`). `Double`/`Store` never run `EmitFuncPtrInto`. `FunctionBehavioursInternalRefs` was never stressed by half-created FuncPtr bytecode.
- **Same-module retry** after a failed Generate, then a successful isolated `int F() { return 7; }` on that module (`Ready` stays false).
- **Success-path extra `AddRefInternal`** at `:1619` vs legacy new-global (`AddScriptFunction` is table-pointer only, `:5692-5706`).
- **Empty `functionDecls` + TU globals** (Task 4).
- **Production `Build()` → `Generate`**, Ready true, Cutover publisher flip (Tasks 6–12).
- **`DestroyHalfCreated` on abandon.** Failure still wipes `byteCode` then `ReleaseInternal` (`:1411-1413`). Restore uses `as_restore.cpp`; CodeGen does not.

Do **not** check 9.1 / 9.5 / 13.6 / 10.4 / 13.1 from Transaction 3/3.

---

## Isolated remainder: plan Tasks 2–5 still executable?

**Yes.** Tasks 2–5 remain isolated `Generate()` TDD. Do not edit `asCModule::Build`, `asCBuilder::BuildCompileCode`, or `IsCanonicalBytecodeCodeGenReady()`. Do not grow CodeGen language coverage. Reuse integer returns, host `Callback`, `ActOnConstruct` of unresolved `FValue`.

| Plan task | Still the next isolated work? | Caveat |
| --- | --- | --- |
| **Task 2** FuncPtr fail-after-emit + same-module retry | **Yes — not landed.** Append two methods to the existing Transaction class. **Patch fixtures** (below) or they miss emit. | After Task 1 + R11 wipe, patched table equality **may already PASS**. That is a **lock**, not Task 3. Live-mutate remains. |
| **Task 3** header-only artifact + `Commit`/`Abandon` | **Yes.** Header still absent. `Generate` must stop live-mutating module lists until `Commit`. | Drop extra `AddRefInternal` on commit. |
| **Task 4** empty-functionDecls global skip | **Yes — still a hole** (`:1526-1527`). | Preferred: no-op OK, **no** `AllocateGlobalProperty`. |
| **Task 5** freeze isolated R09 | **Yes.** Honesty pair after 2–4: CodeGen (R11 24/24 must not regress) + Cutover 5/5 Ready **false**, CANONICAL `Build` still **COMPILER**. | Stop here. |

C-28 / Wave C construction (2.4 / 13.4 / 2.8) stay closed. Public `GetDecl` / `GetStmt` / `GetExpr` / `GetSourceManager` are **const-only**; `Mutable*` are private. Writes go through `asCSema` `ActOn*` / construction APIs. `Parser.SetSema` is still `as_parser.h:60`.

---

## Task 2 fixture patches (mandatory)

Plan paste in `wave-d-r09-plan.md` Task 2 is still the right **methods and bodies**, with two construction patches. Keep `FCodeGenTableSnapshot`. Keep `GenerateCanonicalFromSource` **out** of failure fixtures (it dumps Generate errors as test errors). Call `Generate` directly.

Add includes the current Transaction file lacks:

```cpp
#include "source/as_parser.h"
#include "source/as_scriptcode.h"
```

(`as_objecttype.h` / `as_sema.h` / `as_module.h` / `as_scriptengine.h` / `as_bytecode_codegen.h` already present.)

### Hard no

- **`engine->FindMatchingFuncdef(func, module)`** — lookup-only. With non-null `module` it **creates** a funcdef, `funcDefs.PushLast`, `AddScriptFunction` (`as_scriptengine.cpp:5849-5873`). CodeGen must keep `LookupExistingFuncdef` (`:564-587`).
- Script-level `funcdef` / `@` / `is`. Host `RegisterFuncdef("int Callback(int)")` **before** the snapshot, same as R11 `CodeGenFuncPtrStoreTeardownSurvivesEngineDestroy`.
- POD writes / `GetDecl(Make)->type = …` after the fact (const-only public `Get*`).
- New opcodes / script structs / containers.

Use `functionBehaviours` (`$func`) + host `Callback` as the FuncPtr/REFCPY baseline. Snapshot `FunctionBehavioursInternalRefs` / `EngineFuncDefs` / `EngineRegisteredFuncDefs` against that baseline, not against zero.

### Patch 1 — FuncPtr store + unsupported Make must fail **after emit**

Plan paste:

```cpp
const asCQualType Obj = Context.InternNamedType(asAST_TYPE_VALUE_OBJECT, "FValue", 0);
const asASTDeclId BadFn = Sema.ActOnFunctionDecl(Tu, "Make", Obj, asCSourceRange());
```

That is the Task 1 Fill-fail shape. `FillFunctionSignature` resolves the **function return type** first (`:1463`). Unresolved `FValue` → `asINVALID_DECLARATION` **during the pending loop**, **before** `Emit` of `Double`/`Store`. No `asBC_FuncPtr` / `asBC_REFCPY`. `FunctionBehavioursInternalRefs` may already match → **wrong PASS**.

**Required Make:** resolvable `int` return; fail in the body via `ActOnConstruct` of unresolved `FValue`.

```cpp
const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
const asCQualType Obj = Context.InternNamedType(asAST_TYPE_VALUE_OBJECT, "FValue", 0);
const asASTDeclId BadFn = Sema.ActOnFunctionDecl(Tu, "Make", IntType, asCSourceRange());
asCArray<asASTExprId> Args;
Sema.ActOnReturnStmt(BadFn, Sema.ActOnConstruct(Obj, Args, asCSourceRange()), asCSourceRange());
```

Why this hits emit:

1. Parse `Double` + `Store` (`Callback L = Double; return L(1);`) — R11 subset, host `Callback`.
2. `ActOnFunctionDecl` appends `Make` after those decls. `functionDecls` order: `Double`, `Store`, `Make`.
3. Pending loop Fills all three (`int` returns) and `AddScriptFunction`s them.
4. Emit `Double` OK; emit `Store` runs `EmitFuncPtrInto` (`FuncPtr` + `REFCPY $func`); emit `Make` → `ActOnConstruct` wraps `CONSTRUCT` in `MATERIALIZE`/`CLEANUP`; `EmitConstructInto` `:746-752` `asNOT_SUPPORTED` when `GetTypeInfo()` is null.
5. Fail path: `DiscardPending` (wipe bytecode **before** `ReleaseInternal`) + `DiscardAllocatedGlobals` (none).

`ActOnConstruct` still `SetResolvedDecl`s an empty ctor id when `SelectConstructor` finds no class (`as_sema.cpp:460-497`). C-28 hard-no CALL/CONSTRUCT-without-`resolvedDecl` does **not** reject this graph. `Seal()` must stay 0. If Seal fails, dump `asCASTDump` in the assertion message — do not add a verifier exception.

`ASTEST_AS_ANSI` must wrap the snippet; Allman braces; indent with surrounding C++. Intended host-funcdef fixture: if parse of `Callback L = Double` fails without a script `funcdef`, that is the same R11 host path — do not invent `FindMatchingFuncdef(..., module)`.

### Patch 2 — retry fail-then-success on the **same** module

Plan paste `SealUnsupportedWithGlobal` uses `ActOnFunctionDecl(..., Obj)` for `Make` — **Fill-fail**, already greened by Task 1. A retry that only Fill-fails then succeeds would **re-prove Task 1**, not leftover CALL ids / FuncPtr bytecode after emit.

**Required first fail:** same emit-fail `Make` as Patch 1 (`int` return + `ActOnConstruct(FValue)`), keep TU global `G` so leftover globals would still show if `DiscardAllocatedGlobals` regresses.

```cpp
auto SealUnsupportedWithGlobal = [&](asCASTContext& Context)
{
	asCSema Sema(ScriptEngine, Context);
	const asASTDeclId Tu = Sema.ActOnTranslationUnit("TxnRetry");
	const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
	Sema.ActOnVarDecl(Tu, "G", IntType, asCSourceRange());
	const asASTDeclId OkFn = Sema.ActOnFunctionDecl(Tu, "F", IntType, asCSourceRange());
	Sema.ActOnReturnStmt(OkFn, Sema.ActOnIntegerLiteral(7, asCSourceRange()), asCSourceRange());
	const asCQualType Obj = Context.InternNamedType(asAST_TYPE_VALUE_OBJECT, "FValue", 0);
	const asASTDeclId BadFn = Sema.ActOnFunctionDecl(Tu, "Make", IntType, asCSourceRange());
	asCArray<asASTExprId> Args;
	Sema.ActOnReturnStmt(BadFn, Sema.ActOnConstruct(Obj, Args, asCSourceRange()), asCSourceRange());
	return Context.Seal();
};
```

Keep the plan’s second graph: sealed `int F() { return 7; }`, `Generate` == 0, `CanonicalExecuteInt` `F()==7`, publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, **`IsCanonicalBytecodeCodeGenReady()==false`**. That Ready assert is the tripwire through Tasks 2–5. Isolated success must **not** flip Ready.

`GetNextScriptFunctionId()` (`:5682`) peeks only; `AddScriptFunction` consumes the free id. Retry RED, if any, is leftover occupied `engine->scriptFunctions` / free ids / `G` after the first emit-fail, or a second `F` colliding on success.

### Expected color after patches (do not skip Task 3)

Plan Task 2 text still says RED. After Task 1 `Discard*` + R11 bytecode wipe, patched `AssertCodeGenTablesEqual` **may already PASS**:

- module function/global lists are not published until the success loop (`:1614-1622`);
- emit-fail already calls `DiscardPending` + `DiscardAllocatedGlobals`;
- wipe at `:1411-1412` is meant to stop extra-release of `$func` / `Callback`.

**If GREEN:** land the two methods as locks. **Do not** treat that as 9.1 or as “transaction done.” Task 3 still exists because tables matching **after** a live mutate is not a detached install.

**If RED:** remaining holes are extra-release of `functionBehaviours` / host `Callback` despite wipe, leftover engine function occupancy after emit, or `EngineFuncDefs` growth. Fix in Task 3 `Abandon` (`DestroyHalfCreated`-style wipe, no `AddReferences`), not by expanding emitters.

Do not add new opcodes to make FuncPtr “more real.” `Store` already emits `FuncPtr`+`REFCPY` on the R11 subset.

---

## Task 3 — detached artifact: header-only shape still correct

`Fork/as_bytecode_codegen_artifact.h` **still does not exist.** The plan’s header-only `asSBytecodeCodeGenArtifact` is still the right shape:

```cpp
struct asSBytecodeCodeGenArtifact
{
	asCArray<asCScriptFunction*> functions;
	asCArray<asCGlobalProperty*> globals;
	asCArray<asCFuncdefType*> funcdefs;
	asCArray<asCTypeInfo*> types;

	void Abandon(asCScriptEngine* engine); // DestroyHalfCreated-style wipe; no AddReferences
	int  Commit(asCModule* module);        // lists + one AddReferences + publisher last
};
```

Constraints that still hold:

- Standard C++ only (`asCArray`). No Unreal types in this header or `as_bytecode_codegen.cpp`.
- Included **solely** by `as_bytecode_codegen.cpp`. Tests **must not** include it; they observe `Generate` through `FCodeGenTableSnapshot`.
- Implement `Abandon` / `Commit` in `as_bytecode_codegen.cpp` (no new `.cpp`, no CMake change).
- Public API stays `int Generate(const asCASTContext& context, asCModule* module)`.
- `Generate` must **not** mutate live module function/global/funcdef/type lists until `Commit`. Preferred: nothing visible in `engine->scriptFunctions` / `engine->globalProperties` until commit either. If CALL ids require a reservation, reserve without module publication and roll the reservation on failure so the post-failure snapshot matches.
- Failure `Abandon`: for each function reverse, `scriptData->byteCode.SetLength(0)` **before** any `ReleaseReferences`; then `RemoveScriptFunction` if inserted; then **`DestroyHalfCreated()`** (preferred) or `ReleaseInternal` after the wipe. Never `AddReferences` on abandon.
- Globals reverse: `RemoveGlobalProperty` (clears `varAddressMap` + slot). They must never have been on `module->scriptGlobalsList` if allocate-at-commit is chosen. Keep Abandon symmetric with whatever allocate timing you pick. Task 1’s last-slot shrink can move into Abandon if engine slots are reserved before commit.
- Funcdefs/types: Tasks 2–5 should keep these arrays empty (lookup-only). Do not call `FindMatchingFuncdef(func, module)` to “make types exist.”
- **Commit must drop the extra `AddRefInternal` currently at `:1619`.** Legacy new-global: ctor internal 1, `AddScriptFunction` (table pointer, not a ref), `module->scriptFunctions.PushLast` **without** extra ref, `globalFunctions` / `globalFunctionList` for globals, exactly one `AddReferences()` per published function, publisher `CANONICAL_CODEGEN` **last**.
- Keep local `asCBuilder builder(engine, module); builder.silent = true;` — must **not** replace `module->builder`.
- Do not intern section names until Commit if avoidable; intern during emit is allowed only as documented non-rollback cache (do not fail Task 2 solely on `scriptSectionNames` growth).
- If dropping the extra ref breaks R11 teardown, **fix commit refcount to match legacy new-global**. Do not restore the extra ref. Do not skip destructor to go green.

`Generate` after Task 3:

```text
gates (unsealed / no decls / no module) -> return, no artifact
collect functionDecls (unchanged)
if functionDecls empty: do not skip TU globals if you still allocate them —
  either emit globals too or leave the skip; Tasks 2–5 always include a function body
build artifact (signatures + emit) without module list publication
any fail -> Abandon -> return error (publisher unchanged)
Commit -> return asAST_VERIFY_OK
```

Do **not** edit `as_module.cpp` / `as_builder.cpp` / Ready in Task 3.

---

## Task 4 — empty-functionDecls global skip is still a hole

Live `:1526-1527` returns `asAST_VERIFY_OK` when there is no function-like body, **before** the TU global loop at `:1542`. A sealed TU with only `ActOnVarDecl("G", int)` never reaches `AllocateGlobalProperty` today.

Add `CodeGenGlobalOnlyDeclDoesNotLeavePartialGlobals`:

- Snapshot, `Generate`, then tables must not grow on a path that does not set publisher.
- Preferred R09 behavior: no-op success, **no** `AllocateGlobalProperty`.
- If current code already leaves tables unchanged (returns OK before the global loop), the test **PASSES without a fork edit** — keep it as a lock.
- If a later Task 3 control-flow change allocates then returns OK without publisher, that is a success-path leak: Abandon or skip.

Do not grow global-init bytecode (9.5 / 9.6). Tasks 2–5 always include at least one function body except this one lock.

---

## Hard stop — plan Tasks 6–12 are **out of this package**

Do **not** treat isolated Task 2–5 greens as permission to start production routing. Do **not** copy their implementation steps as next work.

| Plan task | Why it is out of D-r09-task2plus |
| --- | --- |
| **Task 6** Production provenance tests (`ProductionCodeGen` prefix, Ready true, publisher CodeGen) | Requires `Build()` contract; still no `Build()` implementation in that task, but it is the production-RED gate |
| **Task 7** CANONICAL `asCModule::Build` routes to `Generate` | First edit of `as_module.cpp` / `as_builder.cpp` |
| **Task 8** Flip Cutover tests off `COMPILER` | Honesty lock during isolated work; flipping now would hide LEGACY production |
| **Task 9** Differential Ready/publisher | Production publisher on `CompileNativeModule` |
| **Task 10** `IsCanonicalBytecodeCodeGenReady()` true | Ready means CANONICAL `Build()` calls `Generate`, not “the class exists” |
| **Task 11** Wider CanonicalAST regression | After routing/Ready |
| **Task 12** `wave-d-r09-results.md` | Evidence after production routing |

Gated on **both**: isolated Tasks 2–5 **and** Sema dumps that backends would otherwise freeze. Exclusive UBT when idle is Wave B remaining dumps first (`async-work.md` §4), then Wave D isolated 2–5. **This attachment does not recommend starting Task 6+.**

Also out of scope here: default `canonicalCompilerPipeline = true` (Wave G), deleting `asCCompiler`, 9.5 language coverage, Wave E snapshot ABI, Wave F Cache DTO, CALL-without-callee, re-opening R11 / 2.4 / 2.6 / 2.8.

---

## Exclusive-UBT commands (later implement — **do not run now**)

Always `Set-Location D:\as-cta`. One UBT user. `-NoXGE`. Do not invoke `UnrealEditor-Cmd.exe` or `Build.bat` directly.

Task 2 RED (tests only; no fork edits):

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label r09-txn-funcptr-red -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.Transaction" -Label r09-txn-funcptr-red -TimeoutMs 600000
```

After Task 3 (artifact GREEN), also run parent CodeGen (R11 **24/24 must not regress**; prefix also includes `.CodeGen.Transaction`) and Cutover **5/5** (Ready still **false**, CANONICAL `Build` still **COMPILER**):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label r09-txn-codegen-regress -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label r09-txn-cutover-still-legacy -TimeoutMs 600000
```

Task 4 optional: `-Label r09-txn-global-only` on the Transaction prefix. Task 5 freeze: CodeGen + Cutover labels `r09-isolated-freeze-codegen` / `r09-isolated-freeze-cutover`.

If `UE4Editor` / `MSBuild` / `UnrealBuildTool` are live, **do not** start these.

---

## Checkbox discipline

| Evidence | May check in `tasks.md`? |
| --- | --- |
| Transaction 3/3 (Task 1) | **No.** Not 9.1, 9.5, 13.6, 10.4, 13.1. |
| Task 2 FuncPtr/retry methods green | **No.** Same boxes. Isolated fail-after-emit is not production CodeGen. |
| Task 3 detached artifact + Task 4 lock + Task 5 Ready false | **No.** `Build()` still `asCCompiler`. |
| Later production routing / Ready true / default still LEGACY | **Still no from the implementer.** Leave 13.6 / 9.1 / 10.4 / 13.1 `[ ]` for rereview. |

`tasks.md` 13.6 why-open is still accurate: live-mutate then `Discard*`, no artifact header, extra `AddRefInternal` on success, production `Build()` unrouted.

This package did **not** mark those boxes.

---

## Confirmation (this session)

| Check | Result |
| --- | --- |
| Path written | `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\wave-d-r09-task2plus.md` |
| Live `Generate` line | **`as_bytecode_codegen.cpp:1499`** |
| `as_bytecode_codegen_artifact.h` | **does not exist** |
| Fork sources edited | **no** |
| UBT / `RunBuild` / `RunTests` | **not run** |
| `tasks.md` 9.1 / 9.5 / 13.6 / 10.4 / 13.1 | **not marked** |
| Production `Build()` recommended | **no** |
| Task 2 fixture patches | **Make must return `int`**; retry first-fail must be emit-fail (`ActOnConstruct` of unresolved `FValue`), not Fill-fail; no `FindMatchingFuncdef(func, module)` |
