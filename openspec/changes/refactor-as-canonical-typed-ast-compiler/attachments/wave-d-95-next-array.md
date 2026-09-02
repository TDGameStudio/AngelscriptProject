# Wave D 9.5 — next ProductionCodeGen fixture (array\<T\>)

Worktree: `D:\as-cta`. Exclusive UBT package **D-95-array**.
Did not check `tasks.md` 9.5.

Handle / generated default ctor / host funcdef are **landed**. Do not redo them.
Live ProductionCodeGen file: **15 methods**, all GREEN (`d95-funcdef`).

Even 16/16 does **not** close `tasks.md` 9.5.

---

## Chosen next method

**`CanonicalArrayIntBuildPublishesCodeGenAndExecutes`**

One-line script:

```angelscript
int F() { array<int> Values; Values.insertLast(41); return Values[0] + 1; }
```

Host `Register*`: same `array<class T>` as TypeTests **plus** factory / `insertLast` / `opIndex` stubs. Do not CALL an unregistered callee. Do not invent `dictionary`. Do not pull Standalone `CScriptArray` / GC.

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`

---

## Why this row is next

Remaining 9.5 rows **not** in the live 15: `array<T>`, imports, generated accessors / dtor / list factory.

1. Gap matrix already named this script as the template row.
2. Type intern (`type=array<int>`) is Sema/TypeTests only — not production CodeGen.
3. Honest holes already visible in source (do not wait for research to start the RED test):
   - `FindConstructorId` walks `beh.constructors` / `beh.construct`, not `beh.factories`.
   - `EmitConstructInto` FailAt `asNO_FUNCTION` when no ctor — good (no CALL-without-callee), but REF template factory never binds.
   - `EmitCall` only `FindFunc`s CodeGen script binds. Host `insertLast` is `asFUNC_SYSTEM` and will miss (`asNO_MODULE`).
   - `EmitIndex` already looks up `opIndex` on the object type — likely usable once the array object exists.
   - `AppendDefaultValueConstruct` is VALUE-only. `array<int> Values;` as a REF local currently gets no factory assign. Honest RED may be null-handle execute, `asNOT_SUPPORTED`, or `asNO_FUNCTION`.
4. Imports / accessors / list factory are larger (two modules, false-green property path, missing list emit). Array is the smallest remaining execute-42 that forces template install + host method + index.

---

## Exact TEST_METHOD constraints

Add after `CanonicalScriptFuncdefRejectedDoesNotPublishCompiler`, still inside `FCanonicalASTProductionCodeGenTests`. Tabs. `FNativeTestEngine`. `SetCompilerPipeline(CANONICAL)`. `ASTEST_AS_ANSI`. `CompileNativeModule`. `CanonicalExecuteInt`. Publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`. Keep “`int F()` is actually published”. Do not weaken execute `42`.

Registration (match TypeTests flags; add only the stubs the script needs):

```text
RegisterObjectType("array<class T>", 0, asOBJ_REF | asOBJ_TEMPLATE | asOBJ_NOCOUNT)
RegisterObjectBehaviour("array<T>", asBEHAVE_FACTORY, "array<T>@ f(int&in)", GENERIC factory)
RegisterObjectMethod("array<T>", "void insertLast(const T&in value)", GENERIC insertLast)
RegisterObjectMethod("array<T>", "T &opIndex(uint index)", GENERIC opIndex)
```

Generic stubs live in this test `.cpp` (same style as `ProdCanonicalHandleAddRef`). `asCALL_GENERIC`. No Unreal types in fork files; test-file `TArray<int32>` / `TArray` is allowed. Prefer a tiny C++ struct + `TArray<int32>` or `TArray` equivalent owned by the test.

If `CompileNativeModule != 0`: valid RED **only if** publisher ≠ `COMPILER`. Then skip execute / opcode.

If Build succeeds but execute ≠ 42: that is the language RED (unconstructed handle, wrong index ABI, missing CALLSYS). Do not drop execute 42.

Do not treat TypeTests intern or SemaAuthority dump `type=array<int>` as this method going green.

---

## Later commands (from `D:\as-cta`)

New `TEST_METHOD` requires a rebuild. Always `-NoXGE` after touching tests or codegen.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-array
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-array -TimeoutMs 600000
```

Expect **16 methods**. Do not mark `tasks.md` 9.5.
