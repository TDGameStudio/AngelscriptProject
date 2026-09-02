# Wave B exclusive UBT — B-54-1070-declref (class-member / for-init lookup)

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:test-driven-development` then `superpowers:systematic-debugging` if SemaAuthority `Build()==0` stays RED, then `superpowers:verification-before-completion` before claiming GREEN. One exclusive UBT. Do **not** check `tasks.md` 5.4 / 13.2 / 4.2 / 9.5.

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
Companions: `attachments/wave-b-54-generate-remaining.md` §1 (live F4 `ActOnDeclRefExpr`); `attachments/async-work.md` §3 Where 5.4 / §4 Hole 3; `attachments/wave-b-eighth-f4-native-next.md` (F4 insertLast — **not this UBT**).

---

## Goal

CANONICAL Generate of **class-member reads** and **for-init locals** binds DeclRef `resolvedDecl` to a live `VAR` / `PROPERTY` / `PARAM`. `EmitDeclRef` (`as_bytecode_codegen.cpp:1107`) no longer FailAt `asAST_VERIFY_DANGLING_ID` on:

- `GetValue() { return Value; }` (user-written method; class field)
- `for (int i = 0; i < 1; i += 1)` (cond/incr `i`)

Parser-range silent `int` on a **true** miss stays recovery (no diagnostic). Construction-API miss (`fileID == 0`) stays ERROR + `unresolved-identifier:`.

This is **not** OpaqueValue memo, **not** mutation write-through, **not** isolated 5.4 VM traces, **not** F4 `insertLast`, **not** F5 Param/Enumerator identity.

## Architecture

```text
Class member:
  ParseClass NotifySema(class ident)     // no VAR children yet
  ParseDeclaration(int Value)            // AST only — no NotifySema today
  ParseFunction GetValue body
    ParseVariableAccess("Value")
      ActOnParsedExpr → ActOnDeclRefExpr(METHOD, "Value")
        LookupCandidatesFrom: METHOD scope miss, CLASS children empty
        fileID != 0 → silent int, resolvedDecl invalid
  ParseScript NotifySema(complete class) intern Value
  AttachParsedFunctionBody reuses BLOCK (B-56 owner==fn)
    FindExistingExpr DECL_REF at same begin → frozen miss

For-init:
  ParseFor ParseDeclaration(int i)       // no NotifySema
  ParseExpressionStatementCondition
    ParseVariableAccess("i") → silent int miss
  incr i += 1 → FindExisting reuses miss
  ActOnParsedStmt(for) intern VAR i      // too late

EmitDeclRef GetDecl(resolvedDecl)==0 → FailAt :1107
EmitAssign of the same identifier can still WRTV4 via lhs->literal
  + objectType->GetFirstProperty  (FValue() { Value = 41; } prod3 GREEN)
```

Preferred bind (intern order, not CodeGen fallback, not ERROR types):

1. `NotifySema` class member `ParseDeclaration` **before** later methods in `ParseClass` (parent is CLASS via `classScope`).
2. `NotifySema` / `ActOnParsedStmt` the for-init declaration **before** cond/incr `ParseVariableAccess`.
3. Optional safety: `InternParsedDeclRef` must **not** `FindExistingExpr` reuse a DECL_REF whose `resolvedDecl` is invalid — so a later intern with the VAR in scope can bind. Do **not** globally change `FindExistingExpr` to full-span.

Clang/LLVM is a **shape** reference only (lookup after the named decl is in the scope). No link. No Unreal types in fork frontend files.

## Global constraints

- Default pipeline stays **LEGACY**. CANONICAL is per-Engine in these tests only.
- `CompileFunction` stays mixed **COMPILER**.
- Do not start while F4 native or F5 identity is the exclusive UBT (`as_sema.cpp` / `as_sema_expr.cpp` shared). One UBT user in `D:\as-cta`.
- Do **not** edit `as_bytecode_codegen.cpp` in this UBT (no `EmitDeclRef` literal fallback; no OpaqueValue memo).
- Do **not** mix `insertLast` RankArgument, F5 `duplicate-param:`, OpaqueValue Sequence steal, Index write-through.
- Unsealed `asCASTVerify` must still succeed on legal construction graphs. Do **not** require CALL `resolvedDecl` on unsealed verify.
- Commands only from `D:\as-cta`. Always `-NoXGE` on `RunBuild.ps1`. `RunTests.ps1` does not UBT. Always `RunBuild.ps1` first after impl.
- Do not check **5.4 / 13.2 / 4.2 / 9.5**. Do not archive. Do not commit unless asked.

## Live evidence (do not guess)

`ActOnDeclRefExpr` `as_sema.cpp:680-737` after F4:

- `fileID == 0` → `unresolved-identifier:` + `asAST_TYPE_ERROR` `"<unresolved>"`
- `fileID != 0` → silent `int`, invalid `resolvedDecl`, no diagnostic

`EmitDeclRef` FailAt **`:1107`**. Historical dump logs said **1070**.

| Run | What it shows |
| --- | --- |
| `wave-b-eighth-f4-red` | ForLoop / IndexCompoundAssign `Canonical CodeGen failed code=1 line=1107` |
| `wave-b-eighth-f4-sema2` **227/227** | `unresolved-identifier:Value` / `:i` / `:Stored` — intern still diagnosed **all** misses; dump helper discards `Build()`; Generate often skipped after Seal fail-closed |
| `wave-b-eighth-f4-prod3` **32/33** | parser-range recovery: value-object ctor GREEN via **`EmitAssign` literal fallback**, not a bound DeclRef. Only `insertLast` RED. **SemaAuthority not re-run** |

First implementer step: re-measure `Canonical CodeGen failed code=1 line=` after F4 native GREEN. Use the printed line, not 1070.

## File map

| Path | This UBT |
| --- | --- |
| `as_parser.cpp` `ParseClass` member loop; `ParseFor` after init declaration | `NotifySema` so VAR exists before `ParseVariableAccess` |
| `as_sema_expr.cpp` `InternParsedDeclRef` (`:1503-1530`) | skip FindExisting reuse when `resolvedDecl` invalid |
| `as_sema.cpp` `ActOnDeclRefExpr` | **keep** fileID split; do not diagnose parser-range true misses |
| `as_bytecode_codegen.cpp` / verifier | **do not edit** |
| Tests | SemaAuthority: `Build()==0` on PropertyReadWrite + ForLoop (see Task 1). Do not weaken dump tokens |

## Must stay green (do not weaken)

| Test | Contract |
| --- | --- |
| `UnresolvedDeclRefMissingIsErrorTypeNotInt` | construction-API empty range: ERROR `"<unresolved>"`, `unresolved-identifier:Missing`, unsealed verify OK |
| `UnresolvedCallMissingIsErrorTypeNotInt` / `UnresolvedCallDoesNotPublishFakeIntSuccess` | CALL miss ERROR; CANONICAL `Missing()` Build `!= 0` |
| `MixinCallBindsReceiverNotFreeGlobal` | mixin bind |
| `MemberSameArityTypeMismatchDoesNotBindFirstMethod` | F4 script same-arity stays gone |
| `ClassTemporaryConstructInternsReferenceObjectNotValueObject` | F3 |
| `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath` | F1 dump |
| `LogicalAndRecordsNamedOperandsOnCompileSealPath` / `ValueTemporaryRecordsMaterializeAndCleanup` | already `Build()==0` |
| ProductionCodeGen FValue ctor / generated accessors | stay GREEN (literal assign + generated Get/Set). Do not require `insertLast` if F4 native is not yet GREEN — but do **not** start this UBT until F4 native is GREEN (**33/33**) |

Do **not** require `IndexCompoundAssign*` `Build()==0` here. Binding `opIndex`’s `return Value` removes 1107 from that **method**; Entry `Make()[0] += 1` can still fail later (OpaqueValue steal / Index write-through).

---

### Task 1: RED — `Build()==0` on class-member read + for-init

- [ ] **Step 1: Re-measure (no impl yet)**

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-54-1070-pre -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-1070-pre-sema -TimeoutMs 600000
```

Grep the new Automation.log for `Canonical CodeGen failed code=1 line=`. Record the FailAt line. Confirm PropertyReadWrite / ForLoop / IndexCompoundAssign / PropertyCompoundAssign still print it. CAEngine `UE4Editor`/`MSBuild`/`link` on this machine is **not** this lock.

- [ ] **Step 2: Write the failing asserts** (TDD — tests first, expect RED)

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Do **not** change `DumpSealedCanonicalAst` (it discards `Build()`; many dump methods are not this hole).

In `PropertyReadWriteRewritesToAccessors` and `ForLoopRecordsInitCondIncrBodyPhasesOnCompileSeal`, after `AddScriptSection`, assert:

```cpp
ASSERT_THAT(AreEqual(0, Module->Build(),
	TEXT("CANONICAL class-member / for-init DeclRef must Generate, not EmitDeclRef dangling")));
```

Keep the existing dump token asserts (call `asCASTDump` on `GetCanonicalASTContext()` after Build, or keep `DumpSealedCanonicalAst` **after** the `Build()==0` assert — the helper Builds again, that is OK).

Inline AS stays `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).

Optional sibling (do not replace the two above): dump `kind=DeclRef` for `Value` / `i` must not be `type=<unresolved>` and must not be a target-less `type=int` if you can lock `resolvedDecl` via dump fields already present. Prefer `Build()==0` as the Generate oracle.

- [ ] **Step 3: Build + RED tests**

```powershell
.\Tools\RunBuild.ps1 -Label wave-b-54-1070-red -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.PropertyReadWriteRewritesToAccessors" -Label wave-b-54-1070-red-prop -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.ForLoopRecordsInitCondIncrBodyPhasesOnCompileSeal" -Label wave-b-54-1070-red-for -TimeoutMs 300000
```

Expected RED: `Build() != 0` and log `Canonical CodeGen failed code=1 line=<EmitDeclRef FailAt>`.

---

### Task 2: GREEN — intern order + no frozen miss

- [ ] **Step 4: Bind, do not diagnose**

Minimal changes:

1. `ParseClass` member loop (`as_parser.cpp` ~4024): after `ParseDeclaration(true)`, `NotifySema(node->lastChild)` so `int Value` is a CLASS child **before** `ParseFunction` body `ParseVariableAccess`.
2. `ParseFor`: after `ParseDeclaration()` of the init, `NotifySema` that declaration (owner = `CurrentDeclContext()` = function) **before** `ParseExpressionStatementCondition`.
3. `InternParsedDeclRef`: if `FindExistingExpr(DECL_REF)` hits a node with `!resolvedDecl.IsValid()`, do not return it — call `ActOnDeclRefExpr` again (or `SetResolvedDecl` after a fresh lookup). Do **not** change `FindExistingExpr` itself to full-span.

Do **not** flip parser-range miss to ERROR. Do **not** walk every CLASS from the TU. Do **not** add `EmitDeclRef` literal fallback.

- [ ] **Step 5: Build + GREEN locks**

```powershell
.\Tools\RunBuild.ps1 -Label wave-b-54-1070 -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-1070-sema -TimeoutMs 600000
```

Expected: PropertyReadWrite + ForLoop `Build()==0`. Dump tokens unchanged. `UnresolvedDeclRefMissingIsErrorTypeNotInt` still ERROR. Mixin / F3 / F1 dump still green. Log: **no** `code=1 line=<EmitDeclRef>` on PropertyReadWrite / ForLoop / IndexCompoundAssign **methods**. IndexCompoundAssign **Entry** may still fail later for non-1107 reasons — do not chase OpaqueValue here.

- [ ] **Step 6: Regression (must stay green)**

```powershell
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-54-1070-prod -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.FCanonicalASTSemaAuthorityTests.UnresolvedDeclRefMissingIsErrorTypeNotInt" -Label wave-b-54-1070-api -TimeoutMs 300000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-54-1070-ver -TimeoutMs 300000
```

ProductionCodeGen **33/33** (F4 native already GREEN). Verifier **16/16**. Unsealed verify still OK without CALL `resolvedDecl`.

- [ ] **Step 7: Record only.** Patch `attachments/wave-b-results.md` with the labels above if that file is the running log. Do **not** check `tasks.md` 5.4 / 13.2. Do not start OpaqueValue memo in the same bite.

---

## Hard nos

- Check 5.4 / 13.2 / 4.2 / 9.5.
- OpaqueValue memo, ObjectTypeFromExpr unwrap, Index write-through, mutation VM traces.
- Restore script same-arity. Diagnose parser-range `Value` / `i` as `unresolved-identifier:` (prod2).
- Global `FindExistingExpr` full-span.
- CALL-without-callee as unsealed `asCASTVerify` firewall.
- Default CANONICAL. CANONICAL `CompileFunction`. Wave E–G. Second UBT. Archive. Commit unless asked.
