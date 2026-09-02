# Wave D-95 — production `array<int>` intern vs execute 42

Worktree: `D:\as-cta`. Read-only package **D-95-array-intern**.
Did not edit `Plugins/`, tests, `tasks.md`, `async-work.md`, `async-dispatch.md`, `wave-d-95-plan.md`, `wave-d-95-results.md`. No UBT.

Script:

```angelscript
int F() { array<int> Values; Values.insertLast(41); return Values[0] + 1; }
```

Live RED: `CanonicalArrayIntBuildPublishesCodeGenAndExecutes` in `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` **741–812**. Host is TypeTests `array<class T>` **plus** factory / `insertLast` / `opIndex` generic stubs (`FProdCanonicalIntArray` + `TArray<int32>`, **23–55**). Live flags add `asOBJ_IMPLICIT_HANDLE` and factory decl `"array<T> f(int&in)"` **without `@`** (token disabled) so `RegisterObjectBehaviour` still sees a handle return (**754–761**, engine check `as_scriptengine.cpp` **2324–2327**). TypeTests intern does **not** set `IMPLICIT_HANDLE`. Isolated CodeGen has **no** `array` emit (`AngelscriptNativeCanonicalASTCodeGenTests.cpp`: zero matches).

Type intern already works; production execute 42 does not.

---

## 1. Factory vs constructor vs ALLOC vs CALLSYS

`asCCompiler` default-construct of a **non-handle** `asOBJ_REF` uses **`beh.factory`**, not `beh.constructors`:

- `CallDefaultConstructor` (`as_compiler.cpp` **4388–4437**): skip if `!IsObject()` **or** `IsObjectHandle()` (**4390–4391**). Else `asOBJ_REF` → `beh->factory`, else factories with default args (**4399–4416**). Local: `PerformFunctionCall(func, …, true, offset)` then `PopPtr` (**4434–4440**).
- `PerformFunctionCall` (`as_compiler.cpp` **22198–22259**): **`asBC_ALLOC` only when `isConstructor`** (VALUE/heap ctor). Else `asFUNC_SCRIPT` → `asBC_CALL`, `asFUNC_SYSTEM` → `asBC_CALLSYS` (or `Thiscall1` for `T& opIndex(uint)`).

Template factory `array<T>@ f(int&in)` (hidden type): template `beh.factory` stays **0** unless `parameterTypes.GetLength()==0` (`as_scriptengine.cpp` **2355–2358**). Instance `array<int>` runs `GenerateTemplateFactoryStub` (**3618–3629**, **3796–3878**): `asFUNC_SCRIPT` `$fact`, **drops** the first param, remaining arity **0**, then `ot->beh.factory = func->id`. Stub bytecode: `OBJTYPE` + **`CALLSYS` original factory** + `RET`. Compiler therefore **`CALL`s `$fact`**, not `ALLOC`, not a bare `CALLSYS` of the registered factory.

Canonical CodeGen does the opposite:

- `FindConstructorId` (`as_bytecode_codegen.cpp` **99–140**) walks **`beh.constructors` / `beh.construct` only**. Never `beh.factory` / `factories`.
- `EmitConstructInto` (**992–1053**): `FindFunc(resolvedDecl)` else `FindConstructorId`. Missing → `FailAt(__LINE__, asNO_FUNCTION)` (**1019–1022**). VALUE: `PSF` + `CALL`/`CALLSYS`. **REF: `asBC_ALLOC` + ctorId** (**1050–1053**). ALLOC on a factory id is the wrong ABI.
- `STMT_DECL` dummy construct is **VALUE-only** (**1505–1516**). REF/template locals never enter `EmitConstructInto`.

---

## 2. `array<int> Values;` with no init

Sema intern is **TEMPLATE**, not VALUE, and **not a factory assign**:

- `ActOnQualTypeFromNode` (`as_sema_decl.cpp` **302–314**): key with `<` → `InternNamedType(asAST_TYPE_TEMPLATE, "array<int>", quals)`. No engine flags. Script has no `@` → no `asAST_QUAL_HANDLE`.
- TypeTests `RuntimeBridgeInternsArrayIntAsTemplateKind` (**185–214**): `GetTypeInfoByDecl("array<int>")` + `FromDataType` kind `TEMPLATE`, key `array<int>` not bare `array`.
- SemaAuthority `TemplateContainerTypeKeyIsArrayIntNotBareArray` (**805–839**): parse/seal dump `type=array<int>` for **global** `array<int> Values;` — not production CodeGen, not execute.
- `AppendDefaultValueConstruct` (`as_sema_stmt.cpp` **57–83**): **VALUE-only** (`QualTypeIsValueObject` → `asAST_TYPE_VALUE_OBJECT` and not handle). TEMPLATE returns immediately. No-init locals (**298–300**, **357–360**) emit **`STMT_DECL` only**.
- `SelectConstructor` / `ActOnConstruct` (`as_sema.cpp` **552–701**) look for **`DECL_CONSTRUCTOR` under `DECL_CLASS`**. Host `array<int>` is not a script class. No factory decl is interned.

CodeGen `TypeOf` → `bridge.Resolve` (`as_runtime_type_bridge.cpp` **98–102**) **`MakeHandle(true)` for any `asOBJ_REF`**. `AllocTyped` then **`ClrVPtr`** (`as_bytecode_codegen.cpp` **388–391**). `STMT_DECL` skips VALUE construct because `IsObjectHandle()` (**1505–1507**).

Net: **null handle, no `$fact`, no ALLOC, no CALLSYS factory.** Matches `CallDefaultConstructor` skip for handles (`as_compiler.cpp` **4390**) and the fork note that implicit-handle construct must not build a handle (`16242–16245`) — but that skip **cannot execute 42**. The production test wants a live array.

Live stubs hide the null: `insertLast` no-ops on `GetObject()==nullptr` (**38–41**); `opIndex` returns static `Missing=0` (**48–51**). `Values[0]+1` would be **1**, not 42, if CALLSYS ran on an unconstructed local.

---

## 3. `insertLast` — host SYSTEM vs `FindFunc` binds

Sema `ResolveCallee` (`as_sema_expr.cpp` **328–359**):

1. Method: `FindNamedTypeDecl` (**224–241**) only `DECL_CLASS` / `DECL_INTERFACE` whose **name equals** `array<int>`. Host template is not a TU class. **Miss.**
2. `InternNativeGlobals` (**266–326**, used **350–352**): engine **global** functions only. `insertLast` is an object method. **Miss.**
3. `FindBestCallee` on the function scope. **Miss.**

`snFunctionCall` still `ActOnCall`s the invalid id (**887–927**). Fallback type is **`intType`**. No diagnostic except `ambiguous-overload`. Seal can succeed.

CodeGen `binds` are **only script `functionDecls`** created in `Generate` (**2113–2143**). Host SYSTEM methods are never bound.

`EmitCall` (**1359–1407**): `FindFunc(resolvedDecl)` then `FindSlot`. Both empty → **`FailAt(__LINE__, asNO_MODULE)`** (**1402–1406**). **Does not** `CALL` id 0. (`asNO_MODULE = -15`, `asNO_FUNCTION = -6` in `angelscript.h` **99 / 108**.) If a callee existed and `funcType==asFUNC_SYSTEM`, it would `CALLSYS` (**1444–1445**).

---

## 4. `EmitIndex` / `opIndex` once the object exists

`Values[0]` is `asAST_EXPR_INDEX` (`as_sema_expr.cpp` **1076–1097**). AST `opIndex` bind also needs `FindNamedTypeDecl` → **miss**; expr type stays `intType`.

CodeGen `EmitIndex` (**1127–1163**) does **not** use `FindFunc`. It `TypeOf`s the base, then `objType->FindMethodUntil("opIndex")`. Instance copies template methods (`as_scriptengine.cpp` **3535–3604**). With the live `RegisterObjectMethod`, **lookup works**. SYSTEM → `PSF` + `PshV4` + **`CALLSYS`**.

Hole after that: `T &opIndex(uint)` returns a **pointer**. `StoreReturn` is `CpyRtoV4` (**507–511**) with `dwords` from the **int-typed** INDEX node — stores the address bits, does not `RDR4`. Compiler uses `Thiscall1` then deref for `Values[0] + 1`. Even with a live array, current INDEX ABI would not yield **41**.

---

## 5. Exact production RED

First failing assert on the live method is **`CompileNativeModule == 0`** (**787–792**), not execute.

CANONICAL `Build()` runs `asCBytecodeCodeGen::Generate`. Seal has no diagnostic for the unbound `insertLast` CALL. Generate hits **`EmitCall` `FailAt(…, asNO_MODULE)`** (`as_bytecode_codegen.cpp` **1405**). `Build() < 0`, `InternalReset`, publisher ≠ `COMPILER`. Opcode assert (**808–811**) and execute 42 are not reached.

Do not treat TypeTests / SemaAuthority `type=array<int>` as this method going green.

If Generate were forced past the CALL (empty callee or skipped `insertLast`): null `ClrVPtr` + stub `Missing` → execute **1**, still not 42. Empty `asBC_CALL` is forbidden; current miss is already fail-closed.

---

## 6. Minimal honest GREEN

No dictionary. No Standalone `CScriptArray` / GC. Keep test-file generic stubs. No `CALL` without a real callee.

1. **Factory, not ALLOC.** On `STMT_DECL` of host `asOBJ_REF|TEMPLATE` (handle or not) with no init — or Sema default-construct sibling of `AppendDefaultValueConstruct` for TEMPLATE/REF — resolve **instance `beh.factory`** (`$fact`, 0 visible params) and **`asBC_CALL`** it, store the returned handle into the local (compiler **4434–4440**). If `beh.factory==0`, walk `factories` the same way as **4407–4415**. **`FailAt(asNO_FUNCTION)`** if none. Do **not** `ALLOC` a factory id. Do **not** `CALLSYS` the template factory without the stub’s `OBJTYPE`.
2. **`insertLast` host SYSTEM.** In `EmitCall`, after `FindFunc` miss: resolve `FindMethodUntil` on the receiver object type (same as `EmitIndex`), **`CALLSYS`** with object + `const T&in` (`PSF`). Missing method → `asNO_FUNCTION` / `asNO_MODULE`, never `CALL` 0. Sema intern of host methods under a synthetic class is optional and must **not** go through `RegisterCanonicalScriptTypes` VALUE `DECL_CLASS`.
3. **INDEX rvalue.** After `CALLSYS opIndex`, if return is primitive `T&`, **`RDR4`** (or equivalent) before `+ 1`.

That is the smallest path to execute **42** + `CANONICAL_CODEGEN` + `CALLSYS` (factory stub may also show `CALL` + inner `CALLSYS`; ALLOC is the VALUE ctor opcode, not this fixture’s honest factory).

do not check tasks.md 9.5.
