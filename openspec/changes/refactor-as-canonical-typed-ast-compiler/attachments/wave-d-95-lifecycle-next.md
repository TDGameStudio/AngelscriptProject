# Wave D 9.5 — next ProductionCodeGen fixtures (generated lifecycle after array AND imports)

Worktree: `D:\as-cta`. Read-only package **D-95-lifecycle-next**.
Did not edit `Plugins/`, tests, `tasks.md`, `async-work.md`, or `async-dispatch.md`.
Did not run UBT / `RunBuild` / `RunTests`. Did not check `tasks.md` 9.5.

Live ProductionCodeGen file (`AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`): **15 methods**, all GREEN. Array stubs (`FProdCanonicalIntArray`, factory / `insertLast` / `opIndex`) already sit at lines 23–55; there is still **no** array `TEST_METHOD`. Imports are not in that file.

Do **not** add these three until **array AND imports** are GREEN on this prefix. Do not re-propose generated default ctor (`CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes`, lines 547–609: `struct FValue { int Value = 41; }` + ctor `asBC_WRTV4`). Live VALUE with **user** ctor (`CanonicalValueObjectBuildPublishesCodeGenAndExecutes`, 94–135) is already GREEN.

Dialect: no `dictionary`; no script `funcdef` / `@` / `is`. `struct` = VALUE. `RegisterCanonicalScriptTypes` still registers every TU `DECL_CLASS` as VALUE (`as_bytecode_codegen.cpp:1823`), so do not use script `class` as REF. Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`.

Even 18/18 later does **not** close `tasks.md` 9.5. Default pipeline stays LEGACY. No CALL-without-callee.

---

## Rank after imports

**1. Generated accessors** (next exclusive method). No extra `Register*`. Smallest remaining execute-42 that is **not** already a false-green property load.

**2. Generated destructor.** Same VALUE family; execute 42 is already GREEN without `~T`. Needs install + CALL, not another `Object.Value + 1`.

**3. List factory.** Host `asBEHAVE_LIST_FACTORY` + list buffer. Sema dump only. Easy `return 42` lie. Do not CALL a missing factory.

---

## 1. `CanonicalGeneratedAccessorBuildPublishesCodeGenAndExecutes` — first after imports

Script (no user `GetValue` / `SetValue`, no user ctor):

```angelscript
struct FValue { int Value; }
int F() { FValue Object; Object.Value = 41; return Object.Value + 1; }
```

Host `Register*`: **none**.

### Why this is next

Sema already synthesizes accessors and rewrites property syntax:

- `EnsureGeneratedAccessors` (`as_sema_decl.cpp:673–715`, called `1049–1050`): for each field, `Get`+name / `Set`+name `DECL_METHOD` + `asAST_TRAIT_GENERATED` (`as_ast_kind.h:136` = 256). **No bodies.** Setter gets param `"value"`.
- `TryRewritePropertyGet` / `TryRewritePropertySet` (`as_sema_expr.cpp:140–165`, `167–221`) → `ActOnCall`. Dot rewrite `1061–1068`; assignment `1292–1297`.

SemaAuthority **dump only** — not this gate:

- `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` (`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:944–999`): `class T { int Value = 3; }` + `return v.Value` → dump `GetValue`/`SetValue` + `traits=256` + `callee=T::GetValue()`. No execute 42.
- `PropertyReadWriteRewritesToAccessors` (576–611): **user** `GetValue`/`SetValue` bodies. Not generated.

CodeGen today **does not emit accessor bodies**:

- Collect (`as_bytecode_codegen.cpp:2059–2073`): `METHOD` only if `body.IsValid()`. Generated getters/setters are skipped. (FUNCTION without body **is** collected — that is the handle intern path, not this.)
- `EmitCall` (`1359–1406`): missing `FindFunc` + generated **Get*** name → inline `PSF`/`ADDSi`/`RDR4` (`1391–1399`). **SetValue is not inlined** → `FailAt(..., asNO_MODULE)`.
- Member path `EmitMember` / `EmitMemberStore` (`1065–1125`) is `ADDSi`/`RDR4`/`WRTV4` without `GetValue`/`SetValue` functions.
- `Commit` (`2006–2010`): `objectType == 0` still publishes as a global (fifth-pass F1). Empty `functionDecls` can still `Commit` OK (`2112` path after collect).

Live VALUE `Object.Value` already executes 42 via **ADDSi/RDR4** (user-ctor or generated-ctor WRTV4) **without** generated Get/Set **bodies**. That is the false green this method exists to reject.

### What must RED today

| Assert | Honest outcome |
| --- | --- |
| Sema dump Get/Set | Already green. **Ignore.** |
| `CompileNativeModule == 0` | Likely **fails** (`asNO_MODULE` on rewritten `SetValue`). Valid RED iff publisher ≠ `COMPILER`. |
| Execute `F()==42` | Must stay required. If Build succeeds via MEMBER_REF `WRTV4`, 42 is **not** GREEN. |
| `GetValue` / `SetValue` on `FValue`, `objectType` set, **not** in `globalFunctionList` | Missing today (not collected). F1: methods must not be globals. |
| Getter bytecode `asBC_RDR4`; setter `asBC_WRTV4` | No bodies today. |
| `int F()` contains `asBC_CALL` of those method ids | Inline Get* `ADDSi` on `F()` is a **false green**. |

### False green

- `Object.Value` load/store through `ADDSi`/`RDR4`/`WRTV4` on `F()` only.
- Field default `int Value = 41` + generated ctor WRTV4 (already GREEN) + inlined Get*.
- Dump `Build()==0` / `callee=T::GetValue()`.
- Publishing `GetValue`/`SetValue` as module globals.

GREEN = execute 42 + `CANONICAL_CODEGEN` + both methods owned by `FValue` with bodies + `F()` CALLs them. Do not weaken execute 42. Use `struct`, not `class`.

---

## 2. `CanonicalGeneratedDestructorBuildPublishesCodeGenAndExecutes`

Script (user ctor; **omit** `~FValue`):

```angelscript
struct FValue { int Value; FValue() { Value = 41; } }
int F() { FValue Object; return Object.Value + 1; }
```

Host `Register*`: **none**. Do **not** register `FNativeCaseValue`.

### Why not first

Same execute-42 script as live VALUE (94–135). Sema still always adds a generated dtor (`EnsureGeneratedLifecycle` `as_sema_decl.cpp:648–652`) because the script omitted `~FValue`. Builder/legacy often leaves POD `beh.destruct == 0` (`wave-d-95-legacy-map.md` §3, `CreateDefaultDestructors`). Isolated `CodeGenEmitsValueObjectConstructMemberAndCleanup` (`AngelscriptNativeCanonicalASTCodeGenTests.cpp:695–726`) is host `CALLSYS` on `FNativeCaseValue`, **not** generated script `~T`.

CodeGen:

- `RegisterCanonicalScriptTypes` zeros `beh.destruct` (`as_bytecode_codegen.cpp:1832`).
- Collect **skips** `DECL_DESTRUCTOR` with `asAST_TRAIT_GENERATED` (`2070`).
- `FillFunctionSignature` binds `beh.destruct` only for collected dtors (`1944–1946`).
- `DestroyObject` (`407–425`) CALLs `beh.destruct` only if set; otherwise cleanup is a silent no-op.

Cleanup `EXPR_CLEANUP` can resolve the generated dtor decl (`as_sema_lifetime.cpp:33–46`) and still emit nothing useful.

### What must RED today

Execute 42 + `CANONICAL_CODEGEN` **already pass** on this script. That is a **false green** for generated `~T`.

Required extra asserts (all RED now):

- `FValue` behaviour `asBEHAVE_DESTRUCT` installed (generated empty body / `RET` is enough).
- That function `objectType == FValue` and is **not** on `globalFunctionList`.
- `int F()` bytecode CALLs that destruct id (`asBC_CALL`, not `CALLSYS`).

Do not accept host `FNativeCaseValue` `Destruct` recorder counts as this row. Do not write a **user** `~FValue()` (that is not generated). Mutable script globals stay rejected — no `~FValue() { G = 1; }`.

If `CompileNativeModule != 0` once dtor collect is forced: fail-closed is allowed only if publisher ≠ `COMPILER`.

---

## 3. `CanonicalListFactoryBuildPublishesCodeGenAndExecutes`

Script:

```angelscript
int F() { FSemaListBox Box = {41}; return Box.Marker + 1; }
```

Host (same type name as SemaAuthority `ListPatternRecordsStructuredNodes`, `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:894–941`, **but not** that dump factory):

```text
RegisterObjectType("FSemaListBox", 0, asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE)
RegisterObjectProperty("FSemaListBox", "int Marker", offset of test struct)
RegisterObjectBehaviour("FSemaListBox", asBEHAVE_LIST_FACTORY,
  "FSemaListBox f(int &in) {repeat int}", GENERIC factory)
```

Factory **must** read the list buffer and set `Marker` from the first repeated int (`41`), then return the box address. Do **not** copy `CreateListBox` (`SemaAuthorityTests.cpp:33–38`): it ignores the buffer and returns `GListBox` with `Marker == 0`.

No `dictionary`. Do not CALL `beh.factories` / 0-arg construct if `listFactory` is unset.

### Why last

Sema `snInitList` (`as_sema_expr.cpp:1303–1316`) records `EXPR_CONSTRUCT` with `literal=list-pattern` and **`intType`**, not `FSemaListBox`. Dump `literal=list-pattern` / `args=1,2` is already green. Local init is `STMT_DECL` plus assign (`as_sema_stmt.cpp:272–297`).

CodeGen has **no** list-pattern / `beh.listFactory` emit:

- `FindConstructorId` walks `beh.constructors` / `beh.construct` only (`as_bytecode_codegen.cpp:99–140`). Never `beh.listFactory` / `beh.factories`.
- `EmitConstructInto` with no ctor → `FailAt(..., asNO_FUNCTION)` (`1019–1022`). Honest: no CALL-without-callee.
- `STMT_DECL` dummy construct is VALUE-only (`1505–1516`). REF list local is not 0-arg constructed.
- Unknown/wrong-typed construct → `asNOT_SUPPORTED`.

### What must RED today

`CompileNativeModule != 0` (`asNO_FUNCTION` / `asNOT_SUPPORTED`) with publisher ≠ `COMPILER` is the honest RED. Skip execute if Build fails.

### False green

- `int F() { FSemaListBox Box = {41}; return 42; }` — constant 42, factory never proven.
- Dump `Build()==0` / `literal=list-pattern`.
- `CALLSYS` of a 0-arg factory / `ALLOC` that never sees `{41}`.
- Sema `CreateListBox` (`Marker` stays 0) plus a hardcoded 42.

GREEN = execute 42 from `Box.Marker + 1` + `CANONICAL_CODEGEN` + `F()` `asBC_CALLSYS` of the registered **list** factory. If the factory is missing, fail-closed — do not emit `CALL`/`CALLSYS` with an empty callee.

---

## F1 (do not close it from these)

Fifth-pass F1: empty `functionDecls` can still `Generate` → `Commit` OK; methods/ctors/dtors with `objectType == 0` land on `globalFunctionList` (`as_bytecode_codegen.cpp:2006–2010`, collect `2059–2073`). Accessor/dtor GREEN must keep the not-global asserts. A later empty-module test is separate (`wave-d-95-f1-next.md`).

---

## Exact `TEST_METHOD` constraints (all three)

Add inside `FCanonicalASTProductionCodeGenTests`. Tabs. `FNativeTestEngine`. `SetCompilerPipeline(CANONICAL)`. `ASTEST_AS_ANSI`. `CompileNativeModule`. `CanonicalExecuteInt`. Publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`. Keep “`int F()` is actually published”. Do not weaken execute `42`.

If `CompileNativeModule != 0`: valid RED **only if** publisher ≠ `COMPILER`. Then skip execute / opcode (try/catch / mutable-global pattern).

Do not treat SemaAuthority dumps, isolated `FNativeCaseValue`, or live VALUE `Object.Value` as these methods going green.

---

## Later commands (from `D:\as-cta`)

New `TEST_METHOD` requires a rebuild. Always `-NoXGE` after touching tests or codegen. `RunTests.ps1` has no `-NoXGE`. **Do not run until array + imports are GREEN.** First exclusive method is accessors (`d95-genacc`).

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-genacc
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-genacc -TimeoutMs 600000
```

Expect **previous GREEN count + 1**. Do not mark `tasks.md` 9.5. Follow-ups: `d95-gendtor`, then `d95-listfactory`, same prefix/timeout.

---

## Reminder

**Do not check `tasks.md` 9.5 after these go green.** Capturing closures, F1 empty-`functionDecls` preflight, and Wave G remain open. Generated default ctor is already GREEN — do not re-add it.
