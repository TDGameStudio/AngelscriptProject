# Wave B exclusive UBT — MemberRef execute 42 (sealed field, not first property)

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-member-exec**. **This mutex.** One UBT. `-NoXGE`.

Companions: `attachments/async-work.md` §4–9; `attachments/async-dispatch.md`.
This bite is **not** a 13.2 / 5.4 / 9.5 close. Do not check those boxes.

LLVM/Clang is **shape only**. Do not link. No Unreal types in fork frontend files.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Exclusive UBT. TDD: tests already exist and are RED on execute. Systematic-debug H1/H2 before a second tactic. |
| Live symptom | ProductionCodeGen **41/42** `wave-b-member-prod`. Only `CanonicalNativeMemberRefUsesSealedFieldNotFirstProperty` **got=0**. Dump already has `kind=MemberRef` + `callee=FProdFields::Stored`. |
| Do not mark | **any remaining OpenSpec box** |
| Skills | `superpowers:systematic-debugging` then `superpowers:test-driven-development` (tests exist) then `superpowers:verification-before-completion` |

---

## 0. Already true — do not redo / do not restore

- InitPlan execute 42. Parser class properties use `ParseConditionAsAssignment` when Sema is on.
- Native 0-arg intern (`InternNativeZeroArgCallablesForType`). Factory STOREOBJ for listed factories.
- Dummy VALUE invent CONSTRUCT **deleted**. `STMT_DECL` fail-closes `asNO_FUNCTION` without sibling Construct-assign.
- `FindConstructorId` / `FindFactoryId` **definitions may remain**. **Call sites must stay gone.**
- `EmitMember` / `EmitMemberStore` / `FindThisProperty` use `PropertyFromFieldDecl` from `resolvedDecl`. **Do not restore `GetFirstProperty` there.**
- Sema `InternNativeProperties` + `ActOnMemberExpr` `SetResolvedDecl`. Dump on the failing test already prints `callee=FProdFields::Stored`.
- Generated Get FindFunc-miss inline (`GetFirstProperty`) may stay until the **next** mutex. Do not expand it. Do not restore always-inline.

Must-stay-green named rows: InitPlan 42, ArrayInt, 0-arg factory/ctor, Method/Member CALLSYS, generated accessors, FValue, import CALLBND, script overload.

---

## 1. Tests that already exist (do not rewrite the fixture)

Production: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`
`CanonicalNativeMemberRefUsesSealedFieldNotFirstProperty` (~3039).

SemaAuthority: `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
`NativeMemberRefRecordsResolvedFieldOnCompileSealPath` (~11350). **Not run after MemberRef CodeGen** (prod failed first). Must be GREEN after this mutex.

Native type: `FProdFields { int32 Poison=0; int32 Stored=0; }` Poison registered first.

Script:

```angelscript
int F()
{
    FProdFields Object;
    Object.Stored = 41;
    return Object.Stored + 1;
}
```

Required execute **42**. First-property write+read of Poison would also be 42 — dump must keep `Stored`.

Allowed test tweak: split `CanonicalExecuteInt && Value==42` so a false execute (exception) is not reported as `got=0`. Use `CanonicalExecuteStatus` + exception + `asCBytecodeCodeGenDumpFunction` of `F()`. Do not weaken `Value == 42`. Do not delete the dump `kind=MemberRef` + `Stored` assert.

---

## 2. Live dump (already in `Saved/Tests/wave-b-member-prod/.../Report/index.json`)

```text
DECL Poison id=5, Stored id=6, $beh0 Constructor id=7 under Class FProdFields id=4
Block children = DeclStmt, Construct-assign (expr=19), Stored-assign (expr=5), Return (expr=12)
MemberRef id=2/9 literal=Stored callee=FProdFields::Stored
Sequence id=3 parts=1,2  (DeclRef Object, MemberRef)
Sequence id=10 parts=8,9
Construct id=15 callee=FProdFields::$beh0() nargs=0
```

Sema intern order is correct. `resolvedDecl` is Stored. **Do not “fix” Sema intern unless a new dump shows empty callee=.**

---

## 3. Code sites

Fork root: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`

| Site | Live | Problem |
| --- | --- | --- |
| `EmitAssign` `as_bytecode_codegen.cpp` ~1672–1838 | `EmitMemberStore` only if `lhs->kind == MEMBER_REF`. Else `dest = EmitExpr(lhs); CopyVar(dest, rhs)` | Assign lhs is **Sequence**, not MemberRef |
| `EmitExpr` SEQUENCE ~1445–1471 | Emits last child (MemberRef **load**) | Assign then CopyVar into the **load temp** |
| `ActOnAssignExpr` `as_sema_expr.cpp` ~1105–1242 | Unwraps Sequence for `+=` / property Set rewrite; plain `=` does `ActOnAssign(lhs, rhs)` with Sequence lhs intact | Matches dump Sequence beside Assign |
| `EmitMember` / `EmitMemberStore` ~2046–2108 | `PropertyFromFieldDecl(GetDecl(resolvedDecl))`; FailAt if missing | Keep. Dump says resolvedDecl is valid |
| `PropertyFromFieldDecl` ~2901–2931 | DECL_VAR child index → `properties[index]` | Dump children Poison then Stored. Weak for got=0 |
| VALUE Assign construct ~1723–1747 | `EmitConstructInto` only if lhs type is **handle/funcdef** | VALUE uses EmitExpr temp + CopyVar (H3) |

`TryRewritePropertySet` already unwraps Sequence (`as_sema_expr.cpp` ~214). `EmitAssign` does not.

---

## 4. Debug order (systematic-debugging — do not skip)

1. Rebuild `.44` (codegen untracked skip). Run ProductionCodeGen. Confirm still only MemberRef RED.
2. Split execute vs value **or** read exception via `CanonicalExecuteStatus` on this fixture. If execute==false, dump exception + `F()` bytecode before changing Sema.
3. Prove H1: in `EmitAssign`, log or bytecode-inspect whether Stored-assign emits `WRTV4` of 41 through `ADDSi` of Stored offset, or `CopyVar` into an RDR4 temp.
4. One fix. Preferred if H1 holds: unwrap Sequence / Materialize / Cleanup on Assign lhs (same loop as `ActOnAssignExpr` `+=` target walk ~1132–1151) until `MEMBER_REF` or `INDEX` or `DECL_REF`, then existing `EmitMemberStore` / slot store.
5. If still got=0 after store hits Stored: H2/H3. Dump construct+member bytecode. Do not flip `thisOffset`. InitPlan this-ABI already maps PSF 0.

Do not:

- Restore `GetFirstProperty` in `EmitMember`.
- Restore dummy CONSTRUCT.
- Restore `FindConstructorId(0)`.
- Intern extra native properties.
- Always-inline Get.
- Check 13.2.

---

## 5. Commands

```powershell
Set-Location D:\as-cta
Remove-Item -Force -ErrorAction SilentlyContinue `
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.44.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Module.AngelscriptRuntime.49.cpp.obj,`
  D:\as-cta\Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptRuntime.dll,`
  D:\as-cta\Plugins\Angelscript\Binaries\Win64\UnrealEditor-AngelscriptTest.dll
.\Tools\RunBuild.ps1 -Label wave-b-member-g2 -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-member-g2 -TimeoutMs 600000
```

After ProductionCodeGen **42/42**:

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-member-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-member-canonicalast -TimeoutMs 600000
```

Stop. Do not start generated-Get fail-closed, ABI width, Verifier, Wave E–G.

`RunTests.ps1` does not UBT. Prefix must be the bucket, not `...ProductionCodeGen.CanonicalNativeMemberRef` (CQTest may match 0).

---

## 6. Done when

- ProductionCodeGen full prefix GREEN (42/42 expected; count may grow only if you add an oracle, not a new language row).
- SemaAuthority MemberRef dump still `callee=Stored` and prefix GREEN.
- CanonicalAST GREEN vs last 304/304 (count may be 305+ if new methods; no new fails).
- `EmitMember` still has no `GetFirstProperty`. Dummy invent still deleted. 0-arg arity fallback still absent.
- **13.2 / 4.2 / 5.4 / 5.5 / 5.6 / 9.5 stay `[ ]`.**
