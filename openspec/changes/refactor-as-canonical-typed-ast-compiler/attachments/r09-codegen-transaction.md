# R09 inventory — `asCBytecodeCodeGen::Generate` is not a transaction

Later-wave file map only. **Do not implement R09, do not route production `Build()`, do not check 13.6 / 9.1.** R11 teardown ownership is the success-path hole of the same install story; fix that before growing CodeGen or cutting over.

Worktree: `D:\as-cta`. Sources cited below are current as of this inventory.

## Production `Build()` is still legacy

`asCModule::Build` still ends compile with the builder, not CodeGen:

```406:406:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.cpp
		r = builder->BuildCompileCode();
```

Isolated tests call `Generate()`. `IsCanonicalBytecodeCodeGenReady()` stays false until Wave D actually wires this.

## Current `Generate` (1396–1517) — ordered mutations

Header comment (`as_bytecode_codegen.h`) claims failure must not mutate module functions. The body mutates Engine/module **before** all bodies succeed.

**No `AddFuncDef` in current `Generate`.** First-pass R09 / `tasks.md` 9.1 / `wave-c-g-file-map.md` still name `module->AddFuncDef()` at old line numbers. Today funcdefs are only **looked up** (`FuncPtrHandleType` walks `engine->funcDefs`, 525–546). Lambdas are `asAST_DECL_FUNCTION` + `asAST_TRAIT_LAMBDA` and go through the same `asNEW`/`AddScriptFunction` path as named functions. Wave D must still assert module/engine funcdef tables: a later atomic install will likely create them, and success-path `AddReferences` already touches funcdef/`functionBehaviours` refs.

### Fail-before-emit (no Engine function slot yet)

| Order | Gate | Mutations already done | Exit |
| --- | --- | --- | --- |
| 1 | `!context.IsSealed()` | none | `asAST_VERIFY_UNSEALED_PUBLICATION` |
| 2 | `GetDeclCount()==0` | none | `asAST_VERIFY_DANGLING_ID` |
| 3 | collect `functionDecls` (function/method/ctor/dtor **with body**) | none | — |
| 4 | `functionDecls` empty | **skips globals too** | `asAST_VERIFY_OK` (even if TU has `asAST_DECL_VAR`) |
| 5 | `module==0` | none | `asNO_MODULE` |
| 6 | TU global type `bridge.Resolve` fails **on that child** | **earlier globals already installed** | `asNOT_SUPPORTED`, **no rollback** |
| 7 | `asNEW` OOM | globals remain; prior pending funcs discarded | `asOUT_OF_MEMORY` |
| 8 | `FillFunctionSignature` fails | globals remain; this func never `AddScriptFunction` (dtor still calls `RemoveScriptFunction` on a never-occupied id); prior pending discarded | `asNOT_SUPPORTED` |

`GetNextScriptFunctionId()` does **not** consume `freeScriptFunctionIds`. `AddScriptFunction` does.

Local `asCBuilder builder(engine, module)` does not replace `module->builder`.

### Fail-after-`AddScriptFunction` (emit loop)

All function-like decls are `asNEW`’d, signature-filled, `engine->AddScriptFunction`’d, and pushed to `pending` **before any `Emit`**. Then bodies emit in order.

If `emitter.Emit(pending[i], …)` fails:

- Functions `0..i-1` already have `scriptData->byteCode` (`Finalize`/`Output`, 151–168).
- Function `i` usually has empty `byteCode` (fail returns before `Output`).
- `DiscardPending` runs; publisher is **not** set.
- **Globals stay.**

`EmitLine` may intern `engine->GetScriptSectionNameIndex` (engine-lifetime name table; not rolled back).

### Success path (all bodies OK)

For each pending func (1506–1516):

1. `func->AddReferences()`
2. `module->scriptFunctions.PushLast(func)`
3. `func->AddRefInternal()`  ← extra vs new-global `asCModule::AddScriptFunction`
4. `module->globalFunctions.Add(func)` + `globalFunctionList.PushLast(func)`
5. `SetLastBytecodePublisher(CANONICAL_CODEGEN)`

`GetFunctionCount()` is `globalFunctionList` length, not `engine->scriptFunctions`.

## `DiscardPending` (1340–1351) — what it rolls vs leaves

Does: reverse `engine->RemoveScriptFunction` + `func->ReleaseInternal()`, then `pending.SetLength(0)`. Slot pop or hole+`freeScriptFunctionIds`. Destructor also `RemoveScriptFunction` (idempotent if already cleared) then `DestroyInternal` → `ReleaseReferences()`.

Does **not** roll back:

| State | Left behind |
| --- | --- |
| Globals | `AllocateGlobalProperty`: `engine->globalProperties` + `varAddressMap`, `module->scriptGlobals` / `scriptGlobalsList`, `prop->AddRef()` (ctor 1 + module 1) |
| Funcdefs | none created today; lookup-only. `engine->funcDefs` / `registeredFuncDefs` unchanged in count; **refcounts** can still move via bytecode `ReleaseReferences` |
| Module function lists | success-only; failure never `PushLast` — `GetFunctionCount()==0` is **not** a transaction proof |
| Publisher | stays `NONE` on failure (OK) |
| Section names | interned names remain |
| Type refs | see next section |

`DestroyHalfCreated()` (clear bytecode then delete, avoiding `ReleaseReferences` on half-built BC) is **not** used.

**Fail-after-emit extra-release:** `ReleaseReferences` walks bytecode iff `byteCode.GetLength()>0` and releases `functionBehaviours` (`asBC_REFCPY`/`FREE`), `asBC_FuncPtr` callees, `asBC_CALL`/`CALLSYS`, `objVariableTypes`, return/param type infos. `AddReferences` runs **only** on the success path. Discarding an earlier fully-emitted function therefore **releases refs that were never added**. That is why “unsupported body after a function was added” must assert engine/funcdef/`functionBehaviours` teardown, not only `GetFunctionCount()`.

## Success-path refs — R11 implications

`asCScriptFunction` ctor: `internalRefCount=1`; `asFUNC_SCRIPT` allocates empty `scriptData`. Engine table is a pointer, not a ref.

Legacy new global: ctor 1, `module->AddScriptFunction` `PushLast` **without** extra `AddRefInternal`; compile then `AddReferences()` once. Module `InternalReset` does `DestroyInternal` + `ReleaseInternal` → 0 → delete; dtor clears the engine slot.

Canonical success adds **+1** `AddRefInternal` **and** `AddReferences()`, which itself `AddRefInternal`s:

- `asBC_FuncPtr` callee (lambda/`Double` stored in a handle)
- `asBC_REFCPY`/`FREE` → `&engine->functionBehaviours` (funcdef handles)
- `asBC_CALL`/`CALLSYS` targets
- `objVariableTypes` / return / params with `TypeInfo`

Mismatch either way is process-level: extra `ReleaseInternal` on `functionBehaviours` or a funcdef during `~asCScriptEngine` (`ReleaseAllFunctions` ~987, `funcDefs[n]->ReleaseInternal` ~1022); extra `AddRefInternal` leaks a function in `engine->scriptFunctions` after `Discard()` (module drops one ref, object stays at 1, engine dtor `DestroyInternal`s without `asDELETE`).

Existing R11 fixtures (`CodeGenEmitsFuncdefCallAndLambda` plus the four teardown methods) execute then `Module->Discard()` / `Engine.Destroy()`. They are the success-path Discard+Destroy matrix, not R09 failure rollback.

## What current tests actually assert

`CodeGenFailureLeavesNoPartialModuleState` (`AngelscriptNativeCanonicalASTCodeGenTests.cpp` ~151–173): unsealed context + `GetFunctionCount()==0`. Fails at gate 1 — **before** globals, `AddScriptFunction`, or emit. Does not prove 9.1.

`CodeGenDoesNotPublishPartialFunctionsOnUnsupportedBody` (~191–219): F then unsupported construct `Make`. Hits fail-after-`AddScriptFunction`. Asserts only `GetFunctionCount()==0`. No global, no `module->funcDefs`, no `engine->scriptFunctions` length/holes, no `engine->funcDefs` / `globalProperties`, no publisher, no Destroy-without-AV after a **funcptr** first body.

`CodeGenRejectsUnsealedAstAndAcceptsSealed`: no module.

## Wave D TDD (add these; do not implement install here)

Snapshot **before** `Generate`, compare after failure, then `Discard` + `Engine.Destroy()` without AV. Use `asCModule` / `asCScriptEngine` internals (tests already include them).

1. **Unsealed** — keep existing; not sufficient alone.
2. **Unsupported body after a function was added** — keep F+`Make`; extend with a **funcdef/lambda first body** then an unsupported second body so discarded bytecode actually held `FuncPtr`/`REFCPY`.
3. **Table equality after failure** (same module, retry-safe):
   - `GetFunctionCount()`, `scriptFunctions.GetLength()`, `globalFunctionList`
   - `GetGlobalVarCount()` / `scriptGlobalsList` — **global allocate then later `asNOT_SUPPORTED`** (today leaves the global)
   - `module->funcDefs.GetLength()`, `engine->funcDefs.GetLength()`, `engine->GetFuncdefCount()` (`registeredFuncDefs`)
   - `engine->scriptFunctions.GetLength()` + `freeScriptFunctionIds` occupancy
   - `engine->globalProperties` occupied count
   - `GetLastBytecodePublisher()==NONE`
4. **FillFunctionSignature fail after globals + after a prior `AddScriptFunction`.**
5. **Retry `Generate` on the same module** after (2)/(3) — must not see leftover names/ids.
6. **Success-path Discard+Destroy (R11)** — funcdef-only, function-reference-only, lambda-only, indirect-call-only, then the combination; plus Save/Load Bytecode / repeat build. Engine teardown must not skip destructors to go green.

Do **not** treat a green `GetFunctionCount()==0` as atomic install.

## Recommended later shape (do not implement now)

Emit into a **detached artifact** (functions, `ScriptFunctionData`, globals, funcdefs, dependency refs). Nothing is visible on the target `asCModule` / `engine->scriptFunctions` until **commit**. Failure destroys the artifact with `DestroyHalfCreated`-style bytecode wipe so `ReleaseReferences` never runs without a matching `AddReferences`. Commit is one install of already-complete objects (legacy `AddScriptFunction` refcount, one `AddReferences`, publisher last). Rollback restores the pre-Generate snapshot of globals/funcdefs/engine slots.

Suggested later files (from `wave-c-g-file-map.md`): optional `as_bytecode_codegen_artifact.h`; transaction tests beside `AngelscriptNativeCanonicalASTCodeGenTests.cpp`. Production routing (`BuildCompileCode` → `Generate` when CANONICAL, `Ready()` true) is a **later** Wave D step, blocked on R11 green **and** this transaction.

Not in this wave: default `canonicalCompilerPipeline`, checking 13.6/9.1, deleting `asCCompiler`.
