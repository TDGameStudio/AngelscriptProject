# Wave D 9.5 — host REF handle production publish (TDD RED already)

Worktree: `D:\as-cta`. Exclusive UBT package **D-95-handle**.
Do **not** check `tasks.md` 9.5 / 9.1 / 13.2 / 13.3 / 13.6 / 10.2 / 10.4.
Do not archive. Do not commit unless asked. Dual-repo: plugin submodule first if a commit is later requested.

**Goal:** `CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes` publishes `int F()`, executes `F()==42` with publisher `CANONICAL_CODEGEN`, and bytecode contains `asBC_CmpPtrNull`. Then re-run ProductionCodeGen and Cutover. Leave 9.5 `[ ]`.

The RED already exists (`d95-handle`: Build==0, `{<no functions>}`). Do not add a new test file. Do not delete the RED test. Do not weaken publisher / opcode / execute asserts. Do not treat `GetFunctionByName("F")` as GREEN.

---

## Global constraints

- Commands only from `D:\as-cta`: `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. Always `-NoXGE` after touching tests or fork codegen/sema.
- Default `ep.canonicalCompilerPipeline` stays `false` (LEGACY). Wave G is forbidden.
- No Clang/LLVM link. No Unreal types in `as_bytecode_codegen*` / `as_sema*` / `as_ast_*`.
- No CALL-without-callee verifier requirement. No empty cleanup-plan POD fields.
- Script dialect: no `funcdef` / `@` / `is`. Mutable globals intern then reject. Const globals allowed. `struct` = VALUE. `nullptr` is `ttNull`; **`null` is not a keyword**.
- `CompileFunction` may stay `COMPILER`.
- Leave 9.5 `[ ]` even if these 12 tests go green.

---

## Symptom (already reproduced)

```text
CompileNativeModule == 0
CollectFunctionDeclarations == <no functions>
no Canonical CodeGen failed
no Canonical Seal failed
duration ~350ms
```

Isolated GREEN cousin (Frontend `CodeGenEmitsHandleParameterNullCheck`):

```text
bool IsNull(CObj Obj) { return Obj == nullptr; }
GenerateCanonicalFromSource → function exists → Execute null handle → true
```

Production RED:

```text
int F() { CObj Obj = null; if (Obj == nullptr) return 42; return 0; }
```

Working production cousins (same prefix, no host REF local): integer `F()`, named VALUE local, `&in`/`&out`, while.

---

## Root-cause protocol (no guessed emitter tweak)

Phase 1 evidence, **one variable at a time**:

1. Retain snapshot on the failing module so `GetCanonicalASTContext()` survives `PublishCanonicalASTSnapshot` (default policy deletes the graph).
2. On the existing `{<no functions>}` assert, dump:
   - `asCASTDump` of the sealed context
   - `asCModule::scriptFunctions` (Commit list) vs `GetFunctionCount()` (globals)
   - host `CObj` method count
3. `printf` in `Generate()` only when `functionDecls.GetLength()==0`, listing every decl kind/name/body.
4. Form **one** hypothesis from that dump:
   - **H1 intern:** dump has no `DECL_FUNCTION F` → Sema/parser never interned the function. Fix intern.
   - **H2 owner:** `scriptFunctions` has `F` with `objectType != 0` → `Commit()` skip. Fix classification.
   - **H3 dialect `null`:** dump shows identifier `null` (not `EXPR_NULL_LITERAL`) and that poisons intern. Change initializer to `nullptr` (honest dialect). Keep `CmpPtrNull`.
5. Only then implement the matching single fix. Re-run ProductionCodeGen then Cutover.

Do **not** dummy-construct REF locals as VALUE. Do **not** re-enable `@` / `is` / script `funcdef`.

---

## File map

| Path | Role |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` | RED already. Enrich failure dump. Do not weaken asserts |
| `.../ThirdParty/angelscript/source/as_bytecode_codegen.cpp` | Diagnostic printf on empty collect. Then the **one** GREEN matching the dump |
| `.../as_sema_stmt.cpp` / `as_sema_expr.cpp` / `as_sema_decl.cpp` | Touch only if H1/H3 is intern, not Commit |
| `.../AngelscriptNativeCanonicalASTCutoverTests.cpp` | Re-run after GREEN. Do not add handle Cutover unless a twin already exists |
| `openspec/.../attachments/wave-d-95-results.md` | Implementer evidence after greens |

---

## Bite-sized tasks

### 1. Evidence on the existing RED  <!-- TDD already RED -->

Retain snapshot + dump AST/`scriptFunctions`/CObj methods. Generate empty-collect printf.

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label d95-handle-dump
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -Filter "CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes" -Label d95-handle-dump -TimeoutMs 600000
```

Expect still RED, but the error text names H1 vs H2 vs H3.

### 2. GREEN the matching hole

One fix. Then:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label d95-handle-green -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label d95-handle-cutover -TimeoutMs 600000
```

Expect ProductionCodeGen 12/12, Cutover 5/5. Leave 9.5 `[ ]`.
