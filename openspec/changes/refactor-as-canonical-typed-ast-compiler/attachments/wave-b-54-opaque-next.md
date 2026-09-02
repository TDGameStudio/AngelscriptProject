# Exclusive UBT — B-54 OpaqueValue memo / mutation write-through

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Diagnosis: `wave-b-54-generate-remaining.md` §2–§7.
Do **not** check `tasks.md` 5.4 / 13.2 / 4.2 / 5.6 / 9.5.
Do **not** redo 1070 intern-order, F1 eval-once, F4/F5 intern.

TDD. One UBT user. Commands only `Tools\RunBuild.ps1` / `RunTests.ps1` from `D:\as-cta`. Always `-NoXGE`. `RunTests.ps1` does not UBT — always `RunBuild.ps1` first after impl.

LLVM/Clang is a shape reference only. Do not link Clang/LLVM.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Package | **B-54-opaque** (`async-work.md` §7 exclusive UBT) |
| Mode | Exclusive UBT. TDD. |
| Gate | F5 + 1070 already GREEN. PropertyReadWrite / ForLoop `Build()==0`. No `line=1107`. |
| Do not mark | **5.4 / 13.2 / 4.2 / 9.5** |

---

## File map

| File | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Add `Module->Build()==0` to `IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath` (and/or `IndexCompoundAssignEvaluatesBaseOnce`) **before** CodeGen edits. Keep dump token locks. |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp` | Add CANONICAL Trace method(s) patterned on `CanonicalMemberPostfixCallEvaluatesReceiverOnce` (`:195-248`). Isolated Engine. `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)`. `RegisterCanonicalExecutionTrace`. No mutable script globals. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` | OpaqueValue memo keyed by expr id (`:896-897`). `ObjectTypeFromExpr` unwrap OpaqueValue child 0 (`:491-505`). Index assign write-through (`EmitIndex` `:1631-1653` + `EmitAssign` `:1325-1335`). |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | Only if Entry stmt is stolen postfix SEQUENCE: intern `literal=opaque` without FindExisting `seq` bag (`ActOnSequenceExpr` `:753-767`, `ActOnAssignExpr` `+=` `:819-876`). **Not** global full-span `FindExistingExpr`. |

Do **not** edit `as_sema.cpp` `ActOnDeclRefExpr` fileID split. Do **not** add `EmitDeclRef` literal fallback. Do **not** invent stmt-level cleanup-plan POD. Do **not** add new `asCExpr` fields.

---

## Task 1: RED — Generate no longer discarded on mutation fixtures

**Files:** SemaAuthority tests `IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath` around `:1579-1656`. Helper `DumpSealedCanonicalAst` `:233` still discards `Build()` — do **not** change the helper globally.

- [ ] **Step 1: Write the failing assert**

After `AddScriptSection`, before dump (same pattern as PropertyReadWrite `:824-825`):

```cpp
ASSERT_THAT(AreEqual(0, Module->Build(),
	TEXT("CANONICAL Make()[0] += 1 must Generate; OpaqueValue must not fail-close")));
```

Keep existing dump token locks (`kind=OpaqueValue`, `literal=opaque`, `callee=T::opIndex(int)`, one `callee=Make()`).

Optional sibling: same `Build()==0` on `IndexCompoundAssignEvaluatesBaseOnce` and/or `PropertyCompoundAssignEvaluatesReceiverOnceOnCompileSealPath`.

- [ ] **Step 2: Build then run the one method (expect RED)**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-opaque-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath" -Label wave-b-54-opaque-red -TimeoutMs 300000
```

Expected RED: `Build()!=0` and/or Generate fail log (`Canonical CodeGen failed`). If already `Build()==0` because mutation Generate somehow succeeds, still proceed to Task 2 traces (passthrough may `Build()==0` while re-eval / CopyVar-temp). Do not treat dump GREEN as 5.4.

---

## Task 2: RED — isolated CANONICAL mutation Trace

**Files:** `AngelscriptNativeCanonicalASTVmMatrixTests.cpp`. Pattern `:195-248` `CanonicalMemberPostfixCallEvaluatesReceiverOnce`. Helpers: `RegisterCanonicalExecutionTrace` / `FCanonicalTraceScope` in `AngelscriptNativeCanonicalASTTestSupport.h` `:236-265`.

- [ ] **Step 1: Add CANONICAL execute tests**

Two isolated Engines if comparing LEGACY vs CANONICAL. This bite needs at least the CANONICAL row. Default pipeline stays LEGACY on other Engines.

Fixture A — eval-once + write-through:

```text
class T {
  int Value = 0;
  int &opIndex(int Index) { Trace(2); return Value; }
}
T Make() { Trace(1); T v; return v; }
int Entry() { Make()[0] += 1; return 1; }
```

Assert: `Module.IsValid()` (Generate). Execute `int Entry()`. Trace Make once then opIndex (`"1,2"` not `"1,2,1,2"`).

Fixture B — mutation is visible (local, not temporary):

```text
class T {
  int Value = 41;
  int &opIndex(int Index) { return Value; }
}
int Entry() { T v; v[0] += 1; return v[0]; }
```

Assert: result `42`. This locks write-through, not only eval-once.

Optional same bite: `Make().Value += 1` with Get/Set Trace, patterned on `PropertyCompoundAssign*`.

Do **not** use mutable script globals as counters (`ConstGlobalTraitAndMutableReject`). Do **not** weaken `CanonicalMemberPostfixCallEvaluatesReceiverOnce`. Do **not** retcon `RunSingleEval` (that method is default LEGACY).

- [ ] **Step 2: Build then run the new method (expect RED)**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-opaque-trace-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics.FCanonicalASTVmMatrixTests." -Label wave-b-54-opaque-trace-red -TimeoutMs 300000
```

Expected RED: Generate fail, Trace double-eval, and/or `v[0] += 1` still 41.

---

## Task 3: GREEN — CodeGen memo + unwrap + write-through

**Files:** `as_bytecode_codegen.cpp`.

- [ ] **Step 1: OpaqueValue memo (no new asCExpr fields)**

Replace passthrough `:896-897` with CodeGen-local memo keyed by OpaqueValue **expr id**:

```text
EmitExpr(OpaqueValue id):
  if memo[id] bound: return that slot
  slot = EmitExpr(children[0])   // source, once
  memo[id] = slot
  return slot
```

Memo lives on the CodeGen instance for one `Generate()`, not on the node.

- [ ] **Step 2: ObjectTypeFromExpr unwrap**

`:491-505` currently unwraps Materialize/Cleanup/Sequence only. Add OpaqueValue: walk **child 0** (like Materialize/Cleanup), not Sequence last.

- [ ] **Step 3: Index assign write-through**

`EmitIndex` `:1645-1648` `RDR4`s `int &opIndex` into a dest. `EmitAssign` `:1325-1335` then `CopyVar`s that temp.

Keep the pointer: CALL ref-return stays in register; `CpyRtoV4`; store via `PshVPtr`+`PopRPtr`+`WRTV4` (or equivalent existing bytecode helpers). Do not load then CopyVar.

Address-mode vs load-mode: mutation lhs Index must not `RDR4` into a value temp. Reads (`return v[0]`) may still load.

- [ ] **Step 4: Sequence steal only if Entry stmt is the postfix bag**

If dump `literal=opaque` SEQUENCE `parts=` is not OV,Index,Add,Write: in `ActOnSequenceExpr` / `ActOnAssignExpr +=`, do not return an existing SEQUENCE whose `literal` is `seq` when creating `literal=opaque`. Keep `FindExistingExpr` kind+begin. Do **not** globally full-span.

- [ ] **Step 5: Build then SemaAuthority + Semantics + CanonicalAST**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-opaque -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-opaque-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics" -Label wave-b-54-opaque-sem -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-54-opaque-canonical -TimeoutMs 600000
```

Expected: IndexCompoundAssign `Build()==0`; mutation Trace GREEN; SemaAuthority **236/236** or live total; CanonicalAST **285/285** or live total; Semantics includes the new methods.

Compiler JSON may have `succeededWithWarnings` (TypedSemanticIR SourceProvenance). Do not write pure `N/N PASS` if a warning exists.

Never All. Never flip `canonicalCompilerPipeline`. Never CANONICAL `CompileFunction`.

---

## Hard nos

- Check 5.4 / 13.2 / 4.2 / 9.5 / 5.6.
- Redo 1070 intern-order (`ParseClass` / `ParseFor` NotifySema). Do not diagnose parser-range class-member / for-init as `unresolved-identifier:`.
- `EmitDeclRef` literal fallback.
- Global full-span `FindExistingExpr` / `FindExistingStmt`.
- New `asCExpr` fields. Stmt-level cleanup-plan POD.
- Mutable script globals as Trace counters.
- Second UBT. Wave E–G. Archive. Commit unless asked.
- CALL-without-callee as unsealed `asCASTVerify` firewall.
- Clang/LLVM link. Unreal types in fork frontend files.
- Script `funcdef` / `@` / `is`. Invent `dictionary`. C labeled break.

## Done means (this bite)

`IndexCompoundAssign*` `Build()==0`. Isolated CANONICAL Trace: Make once; `v[0] += 1` writes through. OpaqueValue is memoized, not passthrough. **5.4 stays `[ ]`** until isolated traces exist for the full §4 rows in `wave-b-54-generate-remaining.md` (Logical / Conditional / temporaries / property mutation / index mutation / receiver-once). This bite may land index mutation only — still not 5.4 close.
