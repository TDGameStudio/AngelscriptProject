# R11 — `asCCompiler` vs isolated `asCBytecodeCodeGen` function-pointer ownership

Worktree: `D:\as-cta`. Current sources only. Companion: `async-work.md` §3.

Crash (execute-correct, then `Engine.Destroy()`):

```text
EXCEPTION_ACCESS_VIOLATION reading 0xffffffffffffffff
asCObjectType::ReleaseAllFunctions  as_objecttype.cpp:723
  engine->scriptFunctions[beh.factories[a]]
asCScriptEngine::~asCScriptEngine    as_scriptengine.cpp:987
  RegisteredNonFuncdefTypes (skip asOBJ_FUNCDEF) → CastToObjectType → ReleaseAllFunctions
```

Native fixture `allRegisteredTypes` after `RegisterFuncdef("int Callback(int)")` is the host `asCFuncdefType` (plus nothing else of interest). A **live** `Callback` has `asOBJ_FUNCDEF` and is skipped at 982. Reaching 723 therefore means `Type` is already freed/garbage (flags lost `FUNCDEF`), and `CastToObjectType` interprets `asCFuncdefType` memory as `asCObjectType::beh.factories`.

---

## 1. `asBC_FuncPtr` — operand vs value type

| | Operand | Value type after emit |
| --- | --- | --- |
| Compiler `CompileFunctionPointer` | `InstrPTR(asBC_FuncPtr, func)` `as_compiler.cpp:5060` | `CreateType(FindMatchingFuncdef(func, module), false).MakeHandle(true)` `:5061–5063` |
| Compiler lambda | `InstrPTR(asBC_FuncPtr, func)` `:11572` | `ctx->type.dataType = to` (target funcdef) `:11558` |
| CodeGen `EmitFuncPtrInto` | `InstrPTR(asBC_FuncPtr, callee)` `as_bytecode_codegen.cpp:555` | not set here; slot type comes from `FuncPtrHandleType` / `AllocTyped` |
| VM | pushes the `asCScriptFunction*` only — **no AddRef** `as_context.cpp:4000–4005` | n/a |

`FuncPtr` is a raw pointer. Ownership is **not** the instruction operand. Compiler leaves that pointer on the expression stack; CodeGen immediately stores it.

CodeGen store sequence (`:552–559`): `ClrVPtr` + `FuncPtr` + `PSF dest` + `REFCPY($func)` + `PopPtr` + **`ObjInfo(dest, asOBJ_INIT)`**. Compiler handle assign is `REFCPY($func)` only (`:10564–10567`) — **no `ObjInfo(INIT)`**.

`FuncPtrHandleType` (`:525–549`): uses `callee->funcdefType` or walks `engine->funcDefs` by `IsSignatureExceptNameEqual`. **Does not** call `FindMatchingFuncdef`. Then `CreateType(funcDef, false).MakeHandle(true)` — same value type as compiler, lookup-only.

Note: this fork’s `asCScriptFunction::funcdefType` is a **static** (`as_scriptfunction.h:371`). Each `asNEW(asCScriptFunction)` zeros it (`as_scriptfunction.cpp:375`). After Generate creates Double/Invoke/lambda, the static is 0 and CodeGen falls through to the `engine->funcDefs` walk. Do not treat `callee->funcdefType` as per-function identity.

---

## 2. `asBC_REFCPY` / `asBC_FREE` — `$func` vs funcdef typeinfo

`$func` is `engine->functionBehaviours`: `asOBJ_REF|asOBJ_GC`, name `"$func"` (`as_scriptfunction.cpp:127–129`). Behaviours are **EXTERNAL** `AddRef`/`Release` (`:132–143`, VM `as_context.cpp:2851–2855` / `:2940–2943`).

| Site | Funcdef operand |
| --- | --- |
| Compiler assign / convert-to-var / member store | `REFCPY, &engine->functionBehaviours` `as_compiler.cpp:10564`, `:20246`, `:3060`, `:4318`, `:4482`, `:7553` |
| Compiler `CallDestructor` heap/handle | `FREE, &engine->functionBehaviours` `:4649–4650` |
| CodeGen `EmitFuncPtrInto` | `REFCPY, &functionBehaviours` `as_bytecode_codegen.cpp:557` |
| CodeGen `DestroyObject` | `IsFuncdef() ? $func : GetTypeInfo()` then `FREE` `:266–271` |

**Never** `REFCPY`/`FREE` the funcdef `asCTypeInfo*`. `GetTypeIdFromDataType` asserts `ot != &functionBehaviours` (`as_scriptengine.cpp:5023–5024`). Do not `CreateType($func)` as a variable type.

VM `FREE`/`REFCPY` on `$func` call `asCScriptFunction::Release`/`AddRef` (EXTERNAL) on the **script function in the slot**, not `ReleaseInternal` on `Callback`.

Compiler `MoveArgsToStack` **GETOBJ**-moves funcdef/object-by-value args (`:5470–5477`) so the callee owns the EXTERNAL ref and `CallDestructor` FREEs parameters (`:4082–4090`). CodeGen `PushValue` is `PshV4`/`PshV8` **copy** (`as_bytecode_codegen.cpp:575–579`, `:1058–1065`); parameters are **not** in `objects` (`BindParameters` `:334–337`); `DestroyLiveObjects` does **not** FREE params. Caller temps are FREE’d at epilogue instead.

---

## 3. `ObjInfo` / `ExtractObjectVariableInfo` / `objVariableTypes` / `objVariablePos`

| | Compiler `FinalizeFunction` `as_compiler.cpp:3211–3274` | CodeGen `Emit` `:155–180` |
| --- | --- | --- |
| `ExtractObjectVariableInfo` | `:3222` → `objVariableInfo` only (`as_bytecode.cpp:1542–1579`) | `:157` same |
| Heap prefix | heap `IsObject\|\|IsFuncdef` first, then `objVariablesOnHeap = objVariablePos.GetLength()` `:3263` | **`objVariablesOnHeap = 0` always** `:170` |
| Types pushed | `variableAllocations[n].GetTypeInfo()` (the **funcdef**, not `$func`) `:3232`, `:3270` | `objects[i].type.GetTypeInfo()` unless null or **`$func`** `:173–179` |
| Handle `ObjInfo(INIT)` | constructors/value objects; **not** funcdef handle assign | `EmitFuncPtrInto` **always** `:559` |

`ExtractObjectVariableInfo` does **not** fill `objVariableTypes`. It records `asBC_ObjInfo` / block markers for exception liveness (`as_context.cpp:4944–4982`).

Compiler handle FREE has **no** `ObjInfo(UNINIT)` (that is the value-on-stack branch `:4677`). CodeGen epilogue FREEs every `objects[]` entry (`DestroyLiveObjects` `:285–291`) **without** `UNINIT`, after having marked `INIT`.

`PrepareScriptFunction` only nulls the heap prefix (`as_context.cpp:1736–1741`). With `objVariablesOnHeap=0`, handle slots are not VM-precleared (CodeGen `ClrVPtr` compensates). Exception cleanup with `n >= objVariablesOnHeap` treats the slot as **value** (`:5289–5307`) and `CastToObjectType(Callback)` is 0 (`asOBJ_FUNCDEF`).

---

## 4. `AddReferences` scan — EXTERNAL vs INTERNAL

`asCScriptFunction::AddRef`/`Release` = **EXTERNAL** (`as_scriptfunction.cpp:538–565`). `AddRefInternal`/`ReleaseInternal` = **INTERNAL** (`:568–588`). Types use the same split (`as_typeinfo.cpp:82–129`).

`AddReferences` / `ReleaseReferences` run only if `scriptData->byteCode.GetLength()` (`:1187`, `:1337`):

| Source | INTERNAL on |
| --- | --- |
| `returnType` / `parameterTypes` / `templateSubTypes` | that `asCTypeInfo*` (`:1189–1208`, `:1339–1358`) |
| `objVariableTypes[v]` | that `asCTypeInfo*` — **`Callback`**, not `$func` if skip holds (`:1210–1217`) |
| `asBC_FREE` / `asBC_REFCPY` / `asBC_RefCpyV` / `asBC_OBJTYPE` | **operand as `asCObjectType*`** (`:1227–1235`) → **`$func`** |
| `asBC_FuncPtr` | the **script function** (`:1320–1326`) — Double / lambda / Invoke |
| `asBC_CALL` / `asBC_CALLINTF` | `scriptFunctions[funcId]` (`:1309–1316`) |
| `asBC_CALLSYS` | the system function (`:1295–1305`) |

EXTERNAL refs are **not** created by this scan. They are created only by VM `$func` addref/release.

`DestroyInternal` (`:486–520`): `ReleaseReferences()`, then `parameterTypes.SetLength(0)` (`asCDataType` dtor is empty `as_datatype.cpp:85–87`), then `DeallocateScriptFunctionData`. A second `DestroyInternal` after `scriptData==0` is a no-op for type refs.

---

## 5. `FindMatchingFuncdef` — create vs lookup

`as_scriptengine.cpp:5830–5900`:

1. `func->funcdefType` (static in this fork — unusable as per-callee identity).
2. Else walk `engine->funcDefs` for `IsSignatureExceptNameEqual`.
3. Else **create** `asFUNC_FUNCDEF` + `asCFuncdefType`, `funcDefs.PushLast` (no extra ref), `AddScriptFunction`, and if `module` **transfer ctor ref** via `module->funcDefs.PushLast`.
4. If existing `funcDef->module && funcDef->module != module`: `module->funcDefs.PushLast` + **`AddRefInternal`**.

Host `RegisterFuncdef`: `funcDef->module == 0` → step 4 does **not** run. Compiler and CodeGen must **not** create. CodeGen lookup (`:531–540`) is the right shape. Calling `FindMatchingFuncdef(callee, module)` from CodeGen **created** extra engine+module funcdefs; crash moved to ~1026.

---

## 6. `asCFuncdefType` vs `asCObjectType` / `asOBJ_FUNCDEF`

- `asCFuncdefType` **is** `asCTypeInfo`, **not** `asCObjectType` (`as_typeinfo.cpp:456–470`). Flags: `asOBJ_REF|asOBJ_GC|asOBJ_FUNCDEF|(SHARED?)`.
- `CastToObjectType` (`:294–304`): `(VALUE|REF|LIST_PATTERN) && !FUNCDEF`. Live funcdef → **null**.
- `asCDataType::IsFuncdef` is the flag (`as_datatype.cpp:672–677`). `IsObject()` uses `CastToObjectType` (`:669`) → funcdefs are **not** objects.
- `GetBehaviour()` is null for funcdefs (`:771–775`). VM/engine funcdef addref/release go through `$func` (`as_scriptengine.cpp:5558–5560`, `:5591–5593`).
- `allRegisteredTypes` skip at dtor 982 is `asOBJ_FUNCDEF`. Funcdefs are **not** released in the 987 pass; they are owned by `funcDefs` until `:1022–1026`.

Freed `asCFuncdefType` still in `allRegisteredTypes` → flags garbage → 982 keeps it → `CastToObjectType` succeeds → `beh.factories` is not a real array → `:723` reads `0xffffffffffffffff`.

---

## 7. Engine dtor order (`as_scriptengine.cpp`)

`ShutDownAndRelease` (`:1197–1237`) GC + `Module->Discard` **before** the destructor body.

Then:

| Line | Action |
| --- | --- |
| 978–984 | Snapshot `RegisteredNonFuncdefTypes` (`!asOBJ_FUNCDEF`) while entries are live |
| 985–986 | `allRegisteredTypes` erase (**no** `ReleaseInternal` of funcdefs) |
| **987–990** | `CastToObjectType` → **`ReleaseAllFunctions`** ← AV |
| 992–996 | `DestroyInternal` + `ReleaseInternal` of those types |
| 998–999 | `scriptTypeBehaviours` / **`functionBehaviours`.ReleaseAllFunctions** |
| 1004–1013 | `scriptFunctions.DestroyInternal` (bytecode INTERNAL release) then `SetLength(0)` |
| 1017–1018 | extra `AddRefInternal` on builtin `$func` / script-type behaviours |
| 1022–1028 | `funcDefs.DestroyInternal` + `ReleaseInternal` |

987 / 999 / 1022 moves are **one** ownership hole, not three bugs (`async-work.md` §3).

---

## 8. Constructor INTERNAL = 1; host `RegisterFuncdef` + Double / Invoke / lambda

`asCTypeInfo` / `asCScriptFunction` (non-delegate) start `internalRefCount = 1` (`as_typeinfo.cpp:64`, `as_scriptfunction.cpp:354`).

`RegisterFuncdef` (`as_scriptengine.cpp:5758–5811`):

- `asNEW asCScriptFunction(..., asFUNC_FUNCDEF)` → INTERNAL 1, owned by the type (`as_typeinfo.cpp:466`).
- `AddScriptFunction` (`:5693–5705`) — table slot only, **no** extra ref.
- `asNEW asCFuncdefType` → INTERNAL 1; `funcDefs.PushLast` / `allRegisteredTypes.Add` **do not** AddRef (`:5791–5793`). That **1** is the engine-owned ref released at **1026**, not at 987.

CodeGen success (`as_bytecode_codegen.cpp:1468–1514`):

```text
asNEW asFUNC_SCRIPT          → INTERNAL 1
GetNextScriptFunctionId + AddScriptFunction
Emit (bytecode, objVariableTypes, FREE/REFCPY/FuncPtr)
AddReferences                → +INTERNAL on Callback (params + objVariableTypes),
                               $func (FREE/REFCPY), Double/lambda (FuncPtr)
module->scriptFunctions.PushLast
AddRefInternal               → +1 (module)
globalFunctions.Add
```

`InternalReset` (`as_module.cpp:872–889`): `DestroyInternal` (pairs `AddReferences`) + `ReleaseInternal` (module +1). Constructor 1 of Double/Invoke/lambda remains until 1004.

Host `Callback` after a **balanced** Generate/Discard: still 1, skipped at 987, released at 1026.

---

## Conclusion — single most likely extra release / type corruption

**Extra INTERNAL `ReleaseInternal` of host `Callback` (`asCFuncdefType`) during `Module->Discard()` / `ReleaseReferences`, while `allRegisteredTypes` still holds the pointer.** 987 then `CastToObjectType`s the freed funcdef; `beh.factories[a]` is garbage.

The **one current CodeGen difference** most likely to produce that extra INTERNAL (after the failed skip-`$func` experiment) is:

**`EmitFuncPtrInto` `ObjInfo(INIT)` + epilogue `FREE($func)` + `objVariableTypes.PushLast(Callback)` with `objVariablesOnHeap = 0` (`as_bytecode_codegen.cpp:170–179`, `:552–559`, `:263–291`).**

Compiler never `ObjInfo(INIT)`s a funcdef handle store; it counts those slots in the **heap** prefix (`as_compiler.cpp:3263`) whose typeinfo is the funcdef; call-arg temps are `GETOBJ`’d out (`:5476`) rather than epilogue-FREE’d as still-live `objects[]`. CodeGen classifies the same `Callback*` as a **stack value object** for VM/exception metadata while `AddReferences` still INTERNAL-refs it as a type. That is the remaining type-corruption path that keeps the AV at 987/723.

Not chosen as primary: extra EXTERNAL on Double/lambda (GETOBJ vs `PshV` + caller FREE) — that does not free `Callback`, and 987 is a **type** `factories[]` index. Extra `$func` INTERNAL is paired with FREE/REFCPY and `$func` is not in `allRegisteredTypes`.

---

## Next (one change) / do not retry

**Next — one change:** remove `bc.ObjInfo(dest, asOBJ_INIT)` from `EmitFuncPtrInto` only. Compiler handle store has no INIT. Do not stack other ownership patches on the same run.

**Do not retry:** `FindMatchingFuncdef(func, module)` from CodeGen (creates funcdefs; crash ~1026); `CreateType(&functionBehaviours)` as a local type (forbidden; extra-AddRefs `$func`; `GetTypeIdFromDataType` asserts); `module->AddFuncDef` of incomplete AST FUNCDEF decls; skip-`$func` in `objVariableTypes` **without** removing handle `ObjInfo(INIT)` / fixing `objVariablesOnHeap` (already failed; crash stayed at 987/723).
