# Wave B remaining compile→seal dumps (B-sema-remainder)

> **For later exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority (and one Shadow) methods first. `RunBuild` then the SemaAuthority prefix **before** filling `as_sema*`. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2–4.6.

**Goal:** Exact TDD map for the next exclusive-UBT Wave B dump slice. Grow sealed compile→seal facts that backends would otherwise freeze (ambiguous first-name, hidden args, `opIndex`/single-eval, fallthrough target, `receiver=`, const-global trait, 4.6 ShadowDiff). This is **not** Sema environment (13.2) and **not** production `Build()` routing.

**Architecture today (do not contradict):**

```text
legacy Parser → asCScriptNode
  → optional Sema walk / incremental NotifySema   (shadow facts, growing)
  → asCBuilder / asCCompiler                      (production Bytecode)
  → isolated asCBytecodeCodeGen::Generate()       (test-only)
```

LLVM/Clang is a **shape reference only** (`attachments/llvm-ast-architecture.md`). Do not link Clang/LLVM.

---

## Header (this attachment)

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-sema-remainder** (`attachments/async-work.md` §7) |
| Mode now | **Attachment only.** Do not edit fork sources. Do not run UBT / `RunBuild` / `RunTests`. Do not mark `tasks.md`. Do not commit. Do not archive. |
| Mode later | Exclusive UBT package **B-sema-dumps**: `as_sema*` + SemaAuthority tests (Shadow tests only for 4.6). TDD. **Do not mark 13.2.** |
| UBT mutex | One UBT user in `D:\as-cta`. If `UE4Editor` / `MSBuild` / `UnrealBuildTool` / `link` are live, wait. `-NoXGE`. |

`attachments/sema-remaining-fixture-matrix.md` is **stale at 22/22**. Live SemaAuthority is **25/25**. This file is the executable remainder map.

虚标 = checking a task whose spec meaning is unmet. SemaAuthority 25/25 dumps are **not** 13.2 / 5.9 / 4.2–4.6. Parser still builds `asCScriptNode`. Production Bytecode is still `asCCompiler`.

---

## Global constraints

- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` (not `null`); mixin **functions**, not mixin classes; mutable script globals forbidden (`const` only); `asEP_REQUIRE_ENUM_SCOPE=1` so enum values are `ETeam::Red`; host `RegisterFuncdef` / `RegisterEnum` allowed; source spelling `float` stays `float`.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces, indented with surrounding C++ (`Documents/Rules/ASInlineFormattingRule.md`).
- TDD. SemaAuthority prefix first. After green, Compiler CanonicalAST prefix. **Never All.** Never production `Build()` routing. Never flip `Ready()` / default CANONICAL.
- **Hard no:** CALL-without-callee as a seal / verifier firewall. `asCASTVerify` must still succeed on unsealed graphs (`Seal()` needs that). Wave C 2.4 / 2.6 / 2.8 / 13.4 / 13.5 stay closed. Do not invent stmt-level cleanup-plan POD fields (CLEANUP / MATERIALIZE are expr kinds).
- Dump printer (`as_ast_dump.cpp`) only if a **new token** is required (`receiver=` and optionally Call-line `origin=hidden`). Do not restyle existing Call/Index grammar.
- Implementer files: `as_sema.cpp` / `as_sema_expr.cpp` / `as_sema_stmt.cpp` / `as_sema_decl.cpp` / dump printer only as above. Do not edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, `as_ast_verifier.cpp`, or `as_bytecode_codegen.cpp`.
- After these dump tests go green, **13.2 / 5.9 / 4.2 / 4.6 stay `[ ]`**. Record evidence in `attachments/wave-b-results.md` only if an implementer later runs tests (this attachment session does not).

---

## Dump surface today (`as_ast_dump.cpp`)

- DECL: `key=` / `type=` / `quals=` / `traits=` / `origin=` / `default=` / `deps=` / `bases=`.
- STMT: `kind=` and `target=` only when `stmt->target` is valid (Continue / Break / Case today; Fallthrough has **no** target).
- EXPR Call/Construct: `literal=` / `callee=` / `nargs=` / `args=` (child **literals**, not child ids) / `route=import` when resolved decl is `kind=Import`. **No** `receiver=`, **no** Call-line `origin=hidden`, **no** `route=native`.
- Other EXPR (including Index / Sequence / Conversion): `literal=` / `callee=` only. Conversion dest type keys are not dumped. Index dumps `kind=Index` with empty `callee=` unless `resolvedDecl` is set.

`ActOnCall` stores children reverse-formal. Isolated CodeGen may reverse again on emit — CodeGen issue, not a reason to uncheck a Sema dump.

---

## 1. SemaAuthority 25 methods (dump progress, not 13.2)

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Methods 1–22 copied from `attachments/sema-remaining-fixture-matrix.md`. Methods 23–25 from the live test file.

| # | TEST_METHOD | Path | Dump tokens asserted |
| --- | --- | --- | --- |
| 1 | `CallSelectsExactIntOverloadNotFirstName` | CANONICAL `Build()` + retain | `key=F(int)`, `key=F(float)`, `callee=F(int)`, not `callee=F(float)` |
| 2 | `IntArgumentToFloatParamRecordsConversionNode` | `Build()` | `kind=Conversion`, `callee=G(float)` |
| 3 | `ConstructorOverloadsSelectExactCtorNotFirstName` | `Build()` | `key=T::T()`, `key=T::T(int)`, `key=T::~T()`, `callee=T::T(int)` |
| 4 | `MixinFunctionKeepsMixinKindAndSignature` | `Build()` | `kind=Mixin`, `key=MixHelper(int)` |
| 5 | `MultipleLambdasKeepDistinctStableKeys` | Parser `SetSema` + `Seal` (no `Build()`) | two `name=<lambda>` keys with `(int)`, distinct `@offset` |
| 6 | `ValueTemporaryRecordsMaterializeAndCleanup` | `Build()` | `kind=MaterializeTemporary`, `kind=Cleanup`, `callee=FValue::FValue()` |
| 7 | `NamespaceOverloadSelectsScopedFunctionNotGlobal` | `Build()` | `key=Game::F(int)`, `key=F(int)`, `callee=Game::F(int)`, not `callee=F(int)` |
| 8 | `OperatorPlusSelectsOpAddNotBuiltinBinary` | `Build()` | `key=T::opAdd(int)`, `callee=T::opAdd(int)` |
| 9 | `DefaultArgumentIsRecordedOnCallPlan` | `Build()` | `default=7`, `callee=F(int,int)`, `literal=default:7`, `nargs=2`, `reverse-formal` |
| 10 | `ContinueTargetsEnclosingWhileOnCompileSealPath` | `Build()` | `kind=While`, `kind=Continue`, `target=` Atoi `> 0` |
| 11 | `NamedArgumentReordersIntoFormalSlots` | `Build()` | `callee=F(int,int)`, `nargs=2`, `args=named:b=2,named:a=1` (formal then reverse-formal) |
| 12 | `MixinCallBindsReceiverNotFreeGlobal` | `Build()` | `kind=Mixin`, `key=MixHelper(T,int)`, `callee=MixHelper(T,int)`, `nargs=2` (no `receiver=` token) |
| 13 | `PropertyReadWriteRewritesToAccessors` | `Build()` | `callee=T::GetValue()`, `callee=T::SetValue(int)` |
| 14 | `BreakTargetsNearestSwitchNotOuterLoop` | `Build()` | Break `target=` equals Switch id, not While id |
| 15 | `ReverseFormalChildrenMatchStoredOrder` | `Build()` | `callee=F(int,int)`, `nargs=2`, `args=2,1`, not `args=1,2` |
| 16 | `DestructorCallSiteRecordsCallee` | `Build()` | `key=T::~T()`, `kind=Cleanup`, `callee=T::~T()` |
| 17 | `FloatArgumentToIntParamRecordsConversionNode` | `Build()` | `kind=Conversion`, `callee=G(int)` |
| 18 | `TemplateContainerTypeKeyIsArrayIntNotBareArray` | Parser `SetSema` + `Seal` after `RegisterObjectType("array<class T>")` | `type=array<int>`, not `type=array ` |
| 19 | `ImportCallKeepsImportRouteDistinctFromGlobal` | `Build()` | `kind=Import`, `origin=CanonicalASTSemaImportProvider`, `callee=SharedValue()`, `route=import`, not `callee=LocalValue()` |
| 20 | `ListPatternRecordsStructuredNodes` | `Build()` + native `{repeat int}` list factory | `literal=list-pattern`, `args=1,2` |
| 21 | `GeneratedAccessorsHaveGeneratedTraitAndCallPlan` | `Build()` | `kind=Method name=GetValue`, `name=SetValue`, `callee=T::GetValue()`, GetValue line `traits=256` (`asAST_TRAIT_GENERATED`) |
| 22 | `ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails` | `ParseScript` fail (no `Build()` / no `Seal`) | `kind=Function name=First`, not `name=Second` |
| 23 | `EnumParamOnCompileSealPathInternsEnumKind` | `Build()` + host `RegisterEnum("ETeam")` / `ETeam::Red` | param `Team` is `asAST_TYPE_ENUM`, type key `ETeam` (not VALUE_OBJECT from the handle bit) |
| 24 | `ConstMethodOverloadKeepsDistinctStableKeysOnCompileSeal` | `Build()` | `key=T::F()` and `key=T::F() const` (or `key=T::F()const`); `FinishDecl` after traits+params |
| 25 | `IndexOnCompileSealPathRecordsIndexNode` | `Build()` | `Values[3]` dumps `kind=Index`. **Not** `callee=T::opIndex(int)`, Sequence, or single-eval of base |

Method 23 uses Engine intern (`FromDataType`), not a dump `kind=Enum` line. Method 25 is structural-only.

---

## 2. Remaining matrix rows (updated status)

Status legend: `covered-green` / `covered-dump-only` / `missing-test` / `fork-rejected`.

`covered-dump-only` = a dump token exists but production backends still rerun `asCCompiler`, or the fact is fixture-limited.

| Form | Spec/task | Status now | Note |
| --- | --- | --- | --- |
| Exact overload int vs float | 5.2 / 5.3 / 13.2 | `covered-green` | Method 1 |
| Implicit int→float / float→int | 5.2 | `covered-green` | Methods 2, 17. `RankArgument` is still only exact / int→float / float→int |
| Ctor `T v(3)` + dtor key | 5.2 / 5.7 | `covered-green` | Method 3 |
| Mixin decl + call `nargs=2` | 4.4 / 5.3 | `covered-green` | Methods 4, 12. Still **no** `receiver=` |
| Lambda distinct keys | 4.4 | `covered-dump-only` | Method 5 parse→seal |
| Value temporary materialize/cleanup | 5.4 / 5.7 / 5.8 | `covered-green` | Methods 6, 16 |
| Namespace vs global | 5.3 | `covered-green` | Method 7 |
| `+` → `opAdd` | 5.2 / 5.3 | `covered-green` | Method 8. Only `ttPlus` rewrites |
| Default / named args / reverse-formal store | 5.3 / 4.4 | `covered-green` | Methods 9, 11, 15 |
| Continue→While / Break→Switch | 5.5 / 5.6 | `covered-green` | Methods 10, 14. Phases still missing |
| Property Get/Set rewrite | 5.3 / 5.4 | `covered-green` | Method 13 |
| Generated accessors `traits=256` | 4.5 | `covered-green` | Method 21 |
| Import `route=import` | 4.2 / 5.3 | `covered-green` | Method 19 |
| List pattern | 4.4 | `covered-green` | Method 20 |
| Parser incremental `NotifySema` | 4.2 | `covered-dump-only` | Method 22. Still `asCScriptNode` |
| `array<int>` type key | 4.3 | `covered-dump-only` | Method 18 parse→seal |
| **Enum Engine kind** | 4.3 | **`covered-green`** | Method 23 compile→seal. Script-only names without Engine type stay 4.3 |
| **Const-method keys** | 4.5 / 13.3 | **`covered-green`** | Method 24 compile→seal. Param quals/ABI still missing |
| **Index structural node** | 5.4 | **`covered-dump-only`** | Method 25 `kind=Index`. `opIndex` callee / Sequence / single-eval **missing** |
| Hidden / injected args (`hiddenArgumentIndex`) | 5.3 / 7.4 | `missing-test` | Host trait, not a script keyword. Next dump test 2 |
| Index + mutation single-eval / `opIndex` callee | 5.4 | `missing-test` | Next dump test 3 |
| `this` / `receiver=` metadata | 5.3 | `missing-test` | Mixin `nargs=2` is not receiver metadata. Next dump test 5 |
| Const global trait + mutable reject | 4.5 / 5.9 | `missing-test` | Builder already rejects mutable. Sema trait unproven. Next dump test 6 |
| Delegate / script `funcdef` | 5.9 | `fork-rejected` | Host `RegisterFuncdef` allowed; do not write script `funcdef` tests |
| Lambda **call-through** | 5.3 / 5.9 | `missing-test` | Keys only. No `@` handle syntax. Not in this 7; keep for a later dump slice |
| Switch fallthrough **target** | 5.5 / 5.6 | `missing-test` | `ActOnFallthrough` creates a stmt and does **not** `SetTarget`. Next dump test 4 |
| Conversions beyond int↔float / `cast<T>` dest key | 5.2 | `missing-test` | Dest type id not dumped. Keep; not in this 7 |
| Native call `route=native` / ABI | 5.3 / 7.4 | `missing-test` | Hidden args share this gap. Hidden test may add `origin=hidden` without closing native ABI |
| Operators besides `opAdd` | 5.2 / 5.3 | `missing-test` | `opIndex` is test 3. `opAssign` / others stay later |
| Short-circuit / conditional sequencing | 5.4 | `missing-test` | `ActOnLogical` / `ActOnConditional` exist; no SemaAuthority |
| Control phases (for init/cond/incr, do, if/else) | 5.5 / 5.6 | `missing-test` | Continue/break targets only |
| Handles / refs / deferred out / return transfer cleanup | 5.7 / 5.8 | `missing-test` | Temporary Cleanup only. Do not invent stmt cleanup-plan fields |
| `try` / `catch` | 5.7 | `missing-test` | Stmt walk emits `try-catch-rejected`. Not a covered form |
| Suspend / safe-point metadata | 5.9 | `missing-test` | No AST fact |
| Typedef / script enum / interface / access / inheritance | 4.2 / 4.4 / 4.5 | `missing-test` | Host enum intern is covered-green (23). Script enum/interface/`bases=` unused |
| Qualifier / ref / handle ranking | 4.3 / 5.2 | `missing-test` | `CollectQuals` + `quals=` dump; no ranking test |
| Shadow mismatch gate | 4.6 | `missing-test` | Frontend ShadowDiff exists on **hand-built** graphs. Builder vs canonical + fail-closed publish is unmet. Next dump test 7 (Shadow file) |
| Sema environment replacing `asCScriptNode` | 13.2 / 4.2 | `missing-test` | **This is 13.2.** Dump-green ≠ environment. Not this dump slice |
| Script `funcdef` / `@` / `is` | 4.2 / 5.9 | `fork-rejected` | Do not invent these tests |

What lookup still cannot do after 25/25 (read from `as_sema_expr.cpp`):

1. **Hidden injection** — no `hiddenArgumentIndex` synthesis; native host functions are not interned as Decls.
2. **Ambiguity** — `FindBestCallee` keeps the first `score > bestScore`; ties are not rejected. On total miss, **`FindNamedDecl` first-same-name fallback** still returns a wrong Decl (`as_sema_expr.cpp` ~359–370).
3. **`FindNamedDecl`** — first child matching `name` walking parents; no type/const/import filter.
4. **`opIndex`** — `ActOnIndex` is structural (`as_sema.cpp` ~342–347). Only `ttPlus` rewrites to `opAdd`.
5. **`receiver=`** — mixin/method prepend implicit expr into `args` then reverse-formal store; dump has no field.
6. **Fallthrough edges** — `ActOnFallthrough` does not `SetTarget` (`as_sema.cpp` ~589–591).
7. **`RankArgument` width** — exact type-id, int→float (`1`), float→int (`0`).
8. **Lambda invoke / native route / cleanup plans / production consumption** — unchanged.

---

## 3. Exact NEXT dump tests (exclusive UBT, this order)

Add methods **after** method 25 in the SemaAuthority file unless noted. Keep `ON_SCOPE_EXIT { Engine.Destroy(); }`. Select CANONICAL attach for `Build()` paths. Parse→seal paths follow methods 5 / 18 / 22 (`CreateBuilderModule` + `Parser.SetSema` + `Seal`).

Shared verification (from `D:\as-cta`; implementer runs these, not this attachment session):

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-sema-remainder-red -TimeoutMs 600000
```

After green, also Compiler CanonicalAST (never All, never production `Build()` routing):

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-sema-remainder-green -TimeoutMs 600000
```

For test 7 only, also:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow" -Label wave-b-sema-remainder-shadow-red -TimeoutMs 600000
```

Do not reopen Verifier. Do not require CALL-without-callee to fail `Seal()`.

---

### 3.1 `AmbiguousOverloadIsRejectedNotFirstName`

| Field | Value |
| --- | --- |
| File | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| Path | Parser `SetSema` + `Seal` (no `Build()`). `asCCompiler` may already reject this script; the dump must still not bind first-name if attach happens. |
| Implementer may edit | `as_sema_expr.cpp` (`FindBestCallee` / `FindNamedDecl`). Optional diagnostic via `asCSema::AddDiagnostic`. **Do not** make missing callee a verifier/Seal failure. |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int F(int a, float b)
	{
		return 1;
	}

	int F(float a, int b)
	{
		return 2;
	}

	int Entry()
	{
		return F(1, 2);
	}
	)AS");
```

**Why this fixture:** `RankArgument` scores exact=2, int→float=1, float→int=0. `F(1, 2)` totals **2 vs 2** (tie). `FindBestCallee` only updates on `score > bestScore`, so the first child wins. That is first-name binding under a different name.

**Must appear:** `key=F(int,float)` and `key=F(float,int)` as DECL keys.

**Must not appear:** `callee=F(int,float)` or `callee=F(float,int)` on an EXPR Call (a successful bind). Empty `callee=` on the call is allowed. Optional Sema diagnostic token such as `ambiguous-overload` is allowed.

**Expected first RED:** dump contains `callee=F(int,float)` (first same-score child) and Seal still succeeds. Code today: `as_sema_expr.cpp` `FindBestCallee` ~358–370, then `FindNamedDecl` on total miss.

If parse→seal is awkward, a second legal-miss fixture (`class T` + `F(int)` / `F(float)` + `F(v)`) is the `FindNamedDecl` fallback; same method may assert **either** tie-reject **or** miss-reject, but the method name is tie-reject. Do not use script `funcdef` / `@` / `is`.

---

### 3.2 `HiddenArgumentInjectedOnNativeCallee`

| Field | Value |
| --- | --- |
| File | SemaAuthority tests (same as 3.1) |
| Path | CANONICAL `Build()` + retain. Host registers a native global; fork has **no** script hidden-arg keyword. |
| Implementer may edit | `as_sema_expr.cpp` (intern native callee + inject hidden into stored args). `as_sema_decl.cpp` only if native decls must be interned. Dump printer **only** if Call-line `origin=hidden` is chosen instead of a child literal. |

Host fixture (mirror HIR `MetadataHidden`; keep Unreal types out of `as_sema*`):

```cpp
// Register: "int MetadataHidden(int Visible, int Hidden)"
// Then:
asCScriptFunction* HiddenFn = /* GetFunctionById */;
HiddenFn->hiddenArgumentIndex = 1;
HiddenFn->hiddenArgumentDefault = "4";
```

Use `asCALL_GENERIC` like method 20’s list factory if `asCALL_CDECL` is awkward in this file. Include `source/as_scriptfunction.h` in the test only.

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int Entry()
	{
		return MetadataHidden(3);
	}
	)AS");
```

**Must appear:** `callee=MetadataHidden(int,int)` (or the interned stable key of that native); `nargs=2` (visible + hidden); `origin=hidden` **or equivalent** child `literal=hidden:4` (same shape as `literal=default:7`).

**Must not appear:** `nargs=1` as the only Call; empty `callee=` bound via `FindNamedDecl`; hidden masquerading as `named:` / source positional.

**Expected first RED:** native host functions are **not** AST Decls; `FindBestCallee` never sees them; `hiddenArgumentIndex` is unread; sealed Call has empty `callee=` and `nargs=1` (or the call is a DeclRef). `asCCompiler` still compiles and executes — that is not Sema authority.

Do not require `route=native` to close this method (that row stays `missing-test` unless the same dump grows it for free).

---

### 3.3 `IndexCompoundAssignEvaluatesBaseOnce`

| Field | Value |
| --- | --- |
| File | SemaAuthority tests |
| Path | CANONICAL `Build()` + retain |
| Implementer may edit | `as_sema_expr.cpp` (`ActOnExprFromNode` `ttOpenBracket` / assignment). `as_sema.cpp` `ActOnIndex` / `ActOnSequence` / `ActOnCall`. Dump printer **not** required: Index already prints `callee=` when `resolvedDecl` is set. |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	class T
	{
		int Value = 0;

		int &opIndex(int Index)
		{
			return Value;
		}
	}

	T Make()
	{
		T v;
		return v;
	}

	int Entry()
	{
		Make()[0] += 1;
		return 1;
	}
	)AS");
```

If `int &opIndex` is rejected by the fork fixture, substitute `Values[3]` **callee** (`callee=T::opIndex(int)`) plus a `Make()[0]` form that still proves **one** `callee=Make()` (do not drop single-eval). Do not fall back to `Make().Stored +=` — that is method 13 property rewrite, already green.

**Must appear:** `callee=T::opIndex(int)`; `kind=Index` **or** a Call whose callee is `T::opIndex(int)`; exactly one `callee=Make()` (single-eval of the base). `kind=Sequence` is the expected Clang-shaped wrapper if the rewrite materializes the base once.

**Must not appear:** two `callee=Make()` nodes; Index with empty `callee=` as the only indexed form; `opAdd` as a substitute for `opIndex`.

**Expected first RED:** method 25 already dumps `kind=Index` for `Values[3]`; `ActOnIndex` does not `SetResolvedDecl`; only `ttPlus` rewrites to `opAdd`; `snAssignment` does `TryRewritePropertySet` then `ActOnAssign` with Index lhs; no Sequence/single-eval plan of `Make()`.

Keep method 25. This method is the `opIndex` + single-eval remainder of 5.4.

---

### 3.4 `FallthroughTargetsNextCase`

| Field | Value |
| --- | --- |
| File | SemaAuthority tests |
| Path | CANONICAL `Build()` + retain |
| Implementer may edit | `as_sema_stmt.cpp` (`snFallthrough`) and `as_sema.cpp` `ActOnFallthrough` (`SetTarget`). Dump printer already emits `target=` when `stmt->target` is valid. **Do not** edit `as_ast_verifier.cpp` (2.8 already rejects fallthrough not under switch). |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int Entry()
	{
		int x = 0;
		switch (x)
		{
		case 0:
			x = 1;
			fallthrough;
		case 1:
			x = 2;
			break;
		}
		return x;
	}
	)AS");
```

**Must appear:** `kind=Fallthrough` with `target=<nextCaseId>` where that id equals the `kind=Case` stmt for `case 1` (same parse-lines technique as method 14 Break→Switch). `kind=Switch` and two `kind=Case` lines.

**Must not appear:** `kind=Fallthrough` with **no** `target=`; Fallthrough `target=` equal to the Switch id (that is Break’s rule, not next-case).

**Expected first RED:** `STMT … kind=Fallthrough` without `target=` because `ActOnFallthrough` is `return context.CreateStmt(asAST_STMT_FALLTHROUGH, owner, range);` (`as_sema.cpp` ~589–591). Verifier 2.8 already requires fallthrough-under-switch; do not reopen it to fake this box.

---

### 3.5 `ThisOrReceiverMetadataOnMethodCall`

| Field | Value |
| --- | --- |
| File | SemaAuthority tests |
| Path | CANONICAL `Build()` + retain |
| Implementer may edit | `as_sema_expr.cpp` (store receiver as a sealed fact, not only `args[0]`). **`as_ast_dump.cpp` is required** for a new `receiver=` token on Call/Construct lines. Do not change mixin method 12’s `nargs=2` contract. |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	class T
	{
		int F()
		{
			return 1;
		}
	}

	int Entry()
	{
		T v;
		return v.F();
	}
	)AS");
```

**Must appear:** `callee=T::F()`; a Call-line `receiver=` with a non-empty token (object expr id `> 0`, or the receiver’s interned type/decl key). `nargs` may include `this`; that is **not** sufficient.

**Must not appear:** proving `this` only by `nargs+=1`; using method 12 mixin `nargs=2` as this method’s oracle.

**Expected first RED:** dump grammar has no `receiver=` (`as_ast_dump.cpp` Call format is `callee=` / `nargs=` / `args=` / optional `route=`). Method calls prepend `implicitReceiver` then reverse-formal store (`as_sema_expr.cpp` ~586–651). Mixin already covers implicit first arg without metadata.

Do not invent a stmt-level field. Token lives on the Call expr dump line.

---

### 3.6 `ConstGlobalTraitAndMutableReject`

| Field | Value |
| --- | --- |
| File | SemaAuthority tests |
| Path | Split inside one method: (A) CANONICAL `Build()` + retain for `const`; (B) `Build()` failure for mutable; (C) parse→seal of mutable to lock the **Sema** gate, because builder already rejects mutable and that must not be mistaken for Sema authority. |
| Implementer may edit | `as_sema_decl.cpp` (`snDeclaration` / `ActOnVarDecl` / `CollectQuals`). Dump printer not required (`quals=` already exists). |

Const script (A):

```cpp
const std::string ConstSource = ASTEST_AS_ANSI(R"AS(
	const int Answer = 7;

	int Entry()
	{
		return Answer;
	}
	)AS");
```

Mutable script (B/C):

```cpp
const std::string MutableSource = ASTEST_AS_ANSI(R"AS(
	int Mutable = 1;

	int Entry()
	{
		return Mutable;
	}
	)AS");
```

**Must appear (A):** a `DECL` line `kind=Var name=Answer` with `quals=1` (`asAST_QUAL_CONST = 1u << 0`). Parse the Answer line the same way method 21 parses `traits=256`.

**Must not appear (A):** Answer with `quals=0`.

**Must appear (B):** `Module->Build() != 0` for mutable (language gate; builder already does this).

**Must appear (C):** parse→seal of mutable does **not** intern a successful writable global without a Sema diagnostic. Acceptable GREEN: diagnostic token (`mutable-global-rejected` or existing builder-equivalent) **and/or** no `kind=Var name=Mutable` with `quals=0` as an accepted executable fact.

**Expected first RED:** `CollectQuals` can set const on type nodes, so (A) **may already pass** — that is fine, keep the assertion. (B) already fails at `asCBuilder` — not Sema. (C) `WalkOne` `snDeclaration` calls `ActOnVarDecl` with no mutable reject (`as_sema_decl.cpp` ~873–884). That is the Sema RED.

Do not mark 5.9 from this method.

---

### 3.7 `CompileSealShadowMismatchFailsClosedOnOwnerTypeTrait` (4.6)

| Field | Value |
| --- | --- |
| File | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTShadowTests.cpp` — **not** SemaAuthority. Existing `ShadowMismatchReportsOwnerTypeTraitSourceAndDependencyWithoutMerging` is hand-built `ActOnFunctionDecl` vs `ActOnFunctionDecl`. Keep it. |
| Path | Two `asCASTContext`s, same script, Parser `SetSema` + `Seal` (compile-seal facts, not only `ActOn*`). Then perturb Right via `SetDeclParent` / `SetDeclType` / `SetDeclTraits`. |
| Implementer may edit | `as_sema_decl.cpp` / `as_sema.cpp` only if two identical parse-seals do not `match`. `as_ast_dump.cpp` `asCASTShadowDiff` already prints `mismatch owner` / `type` / `trait`. **Do not** merge Left into Right. **Do not** route production `Build()`. |

Inline script (both contexts):

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int F(int a)
	{
		return a;
	}
	)AS");
```

Procedure:

1. Parse+Sema+Seal into `Left` and `Right` with the same section text.
2. `asCASTShadowDiff(Left, Right, Match)` must be `match` **before** perturbation (locks compile-seal determinism).
3. Perturb Right owner, then type, then trait (restore between), same as the existing Shadow method.
4. Diff strings must contain `owner` / `type` / `trait` respectively and start with `mismatch`.
5. Left dump still contains `key=F(int)` and original parent/type/traits (no merge).

**Must not appear:** `match` after perturbation; Left dump picking up Right’s perturbed parent/type/traits.

**Expected first RED (honest):**

- If two parse-seals of this script already `match` and perturbation already reports mismatch, this method can go **green without `as_sema*` edits**. That does **not** close 4.6: there is still **no** builder-vs-canonical fact adapter, and production `Build()` still publishes `asCCompiler` regardless of ShadowDiff (`tasks.md` 4.6). Record that in `wave-b-results.md` if an implementer runs it; leave 4.6 `[ ]`.
- If two parse-seals do **not** `match` (extra generated decls, TU name, non-deterministic ids), that is a useful compile-seal RED — fix determinism in Sema/dump, then perturbation.

Do **not** add a production `Build()` failure assertion here (that is Wave D / 13.6). Fail-closed in this slice means ShadowDiff returns `mismatch` and does not merge graphs.

---

### Substitutions (do not invent fork-rejected tests)

| If blocked | Substitute |
| --- | --- |
| Script `funcdef` / `@` / `is` | Never. Host `RegisterFuncdef` is a different surface. |
| `int &opIndex` rejected | `Values[3]` `callee=T::opIndex(int)` + one `Make()` eval; still not property `Stored` |
| Call-line `origin=hidden` dump grammar fight | Child `literal=hidden:4` like `literal=default:7`; `nargs=2` still required |
| 4.6 already green as Sema-vs-Sema | Do not invent extra tokens; do not check 4.6; proceed |
| Lambda call-through | Later dump slice, not these 7. No `@` |

---

## 4. Architecture vs dumps — 13.2 cannot close from this slice

These seven tests, even all green, prove **more conversion facts** on a sealed graph. They do not replace:

```text
Parser builds asCScriptNode
  → NotifySema / ActOnParsedDeclaration / WalkOne
  → as_sema_* still #include as_scriptnode.h and recurse
  → production Bytecode from asCCompiler
```

13.2 requires a Sema **environment** (scopes, symbols, overload **candidates**, conversions, call plans, lifetimes, control targets) so backends do not rerun Sema. Dumps with `callee=` / `target=` / `receiver=` are still shadow facts until `Build()` consumes them (Wave D, later).

### Smallest next LLVM-shaped Sema-environment step (LATER exclusive slice — do not implement here)

Clang shape (`attachments/llvm-ast-architecture.md`): Parser calls Sema **actions**; Parser does not own overload/conversion/lifetime; `asCScriptNode` is recovery, not the semantic body.

**Smallest next step (one decl form only):**

1. Pick **global `snFunction`** (the form method 22 already incrementally `NotifySema`s).
2. During `ParseFunction`, after the name + parameter list are recognized, call `sema->ActOnFunctionDecl` / `ActOnParamDecl` / `FinishDecl` with tokens already in the parser — **action-only for that decl**, not `WalkOne` re-walking the finished function node.
3. **Keep** the `asCScriptNode` tree for error recovery, diagnostics, and every other decl form (`class`, `import`, mixin, …).
4. Do not delete `ParseScript`’s syntax tree. Do not move expression/statement bodies off `asCScriptNode` in that same slice. Do not route `Build()`. Do not flip Ready()/CANONICAL.

This dump slice must **not** start that Parser rewrite. Mixing dump TDD with Parser action-only in one UBT session collides and invites 虚标 (“Parser calls ActOn, therefore 13.2”).

---

## 5. Checkbox discipline

| After the 7 dump tests are green | Box |
| --- | --- |
| 13.2 Sema environment | stays `[ ]` |
| 5.9 complete-language Sema | stays `[ ]` |
| 4.2 Parser Sema-action entry points | stays `[ ]` |
| 4.6 builder-vs-canonical fail-closed publish | stays `[ ]` |
| 4.3 / 4.4 / 4.5 / 5.2–5.8 / 13.3 | stay `[ ]` unless a later session has **spec-meaning** evidence (not dump tokens alone) |
| 2.4 / 2.6 / 2.8 / 13.4 / 13.5 | stay `[x]` — do not reopen |
| 13.6 / 9.1 / section 10 | stay `[ ]` — do not route `Build()` |

Implementer evidence (not this session): append to `attachments/wave-b-results.md` with prefix, label, report path, pass/fail. Do not rewrite remaining `tasks.md` boxes down to match dumps.

---

## 6. Stale why-open lines in `tasks.md` (4.2–5.9 / 13.2–13.3)

4.5 / 5.3 / 5.6 / 13.6 were patched this session. **This attachment does not rewrite `tasks.md`.** Quoted lines below are still factually stale; prefer fixing them in a later record pass.

| Task | Exact stale sentence | Why stale | Still unmet (keep `[ ]`) |
| --- | --- | --- | --- |
| **4.2** | `asCSema stores the Engine and does not use it.` | `as_sema_decl.cpp` uses `engine->GetTypeInfoByDecl` / `FromDataType`. `as_sema.cpp` constructor still has leftover `(void)engine`. | Parser still builds `asCScriptNode`; Sema is still a conversion walk; Builder is still production declaration authority |
| **4.2** | `Parser still builds a complete asCScriptNode tree and only then invokes Sema.` | “Only then” is stale: `NotifySema` runs per completed top-level decl during parse (method 22). The tree is still built. | Not Clang action-only Sema |
| **4.4** | `They do not carry complete signatures, default-argument expressions as owned facts, mixin origins, or lambda identities.` | Dumps already have `key=F(int)` / `key=MixHelper(int)` / `key=MixHelper(T,int)` / `default=7` / `<lambda>(int)@offset` / `key=T::F() const`. | Public registration and diagnostics still come from builder/`asCCompiler`; default fill is `strtoul` strings, not owned default-expr ASTs; param quals/ABI incomplete |
| **5.2** | `Bool and int constants are handled; other constants, including strings, become int.` | `snConstant` now creates `STRING_LITERAL` and `NULL_LITERAL` (`as_sema_expr.cpp` ~523–543). | Overload/conversion for **production Bytecode** still rerun `asCCompiler`; `RankArgument` still int↔float only |
| **5.2** | `` `ttNull` becomes an int primitive with a handle qualifier. `` | `ttNull` creates `asAST_EXPR_NULL_LITERAL` with `ttVoid` + handle. | Same as above |
| **5.5** | `Failing tests were supposed to stay red until Sema recorded phases and targets.` | Continue→While and Break→Switch **targets** dump on compile→seal (methods 10, 14). **Phases** (for init/cond/incr, do, if/else) are still missing. | Control-phase dump + HIR oracles still unmet |

Not stale (keep as written): 4.3 (script-only names), 4.6 (no builder-vs-canonical gate), 5.3 progress paragraph, 5.4 (plans incomplete; Index is now dump-only), 5.6 (fallthrough target / phases), 5.7–5.9 (production still `asCCompiler`; 5.9 complete-language), 13.2 (environment vs dumps), 13.3 (keys progress vs ABI/StaticJIT).

4.4 is the loudest 虚标-adjacent leftover: the why-open still says signatures are missing while MixHelper(T,int) dumps exist. The **box** must stay `[ ]` because builder is still the public registration path.

---

## 7. File map (paths relative to `D:\as-cta`)

| Path | Role in this slice |
| --- | --- |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-b-sema-remainder.md` | This map |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/sema-remaining-fixture-matrix.md` | Stale 22/22 inventory; do not treat as live |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/async-work.md` | §7 package definition |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/llvm-ast-architecture.md` | Clang shape reference; no link |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/attachments/wave-b-results.md` | Implementer-only later evidence |
| `openspec/changes/refactor-as-canonical-typed-ast-compiler/tasks.md` | 4.2–5.9 / 13.2–13.3 stay `[ ]` |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Add tests 3.1–3.6 after method 25 |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTShadowTests.cpp` | Add test 3.7 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | `FindBestCallee` / `FindNamedDecl` / `ActOnExprFromNode` Index / Call / hidden |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_stmt.cpp` | `snFallthrough` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp` | Const global / mutable reject / native intern if needed |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp` | `ActOnIndex` / `ActOnFallthrough` / `ActOnCall` / `ActOnSequence` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` | **Only** if `receiver=` or Call-line `origin=hidden` is required |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.h` | Same as dump.cpp |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/TypedSemanticIR/CallMetadata/AngelscriptNativeTypedSemanticIRHiddenArgumentTests.cpp` | Hidden host-fixture **shape** reference only; do not capture HIR here |

Do not touch: `as_compiler.cpp` emit, `as_module.cpp` `Build()`, `as_bytecode_codegen.cpp`, `as_ast_verifier.cpp`, `Core/angelscript.h`.

---

## 8. What this attachment did **not** do

- Did not implement fork / test sources.
- Did not run UBT / `RunBuild` / `RunTests`.
- Did not mark any `tasks.md` box (including 13.2).
- Did not commit or archive.
- Did not rewrite `tasks.md`; stale why-open lines are listed in §6 only.
