# Wave B exclusive UBT — snExprTerm FindExisting CALL collision (B-term-fix)

> **For the exclusive-UBT worker:** REQUIRED SUB-SKILL: `superpowers:systematic-debugging` then `superpowers:test-driven-development`. The eight SemaAuthority methods are **already RED**. Do **not** add a ninth fixture unless a dump still lies after the intern fix. `RunBuild.ps1` then the SemaAuthority prefix after the intern change. Do **not** check `tasks.md` 4.2 / 13.2 / 13.3 / 5.4 / 5.9 / 9.5.

**Goal:** `InternParsedExprTerm` must intern Sequence/Index/Unary/postfix-call/member via dedicated `ActOn*` **without** treating an inner or rewrite CALL whose `range.begin.offset` equals the term start as "this term already interned".

This is **not** 13.2 close and **not** production Build routing. LEGACY still `asCCompiler`. LLVM/Clang is a shape reference only.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-22 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-term-fix** (`attachments/async-work.md` §7, `async-dispatch.md`) |
| Mode now | Exclusive UBT. TDD. One UBT user. |
| Evidence now | SemaAuthority **200/208** `wave-b-term-sema` — `D:\as-cta\Saved\Tests\wave-b-term-sema\20260822_133047_287_09ac5738` |
| Gate | Existing eight RED methods. Do not start 5.4 / 5.6 on this red. |
| Do not mark | **4.2 / 13.2 / 13.3 / 5.4 / 9.5** |

---

## Global constraints

- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` = `ttNull`; mixin **functions**; mutable script globals intern-then-reject; host `RegisterFuncdef` legal.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Commands only from `D:\as-cta`: `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. Always `-NoXGE`. `RunTests.ps1` does not UBT.
- **Hard no:** CALL-without-callee; default CANONICAL; CANONICAL CompileFunction; second UBT; archive; commit unless asked; Unreal types in fork frontend files; globally changing `FindExistingExpr` to full-span match; reverting `InternParsedExprTerm` to whole-node FromNode.
- Do **not** edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, or verifier firewalls.
- After these eight tests go green, **4.2 / 13.2 stay `[ ]`**.

---

## Architecture today (do not contradict)

```text
legacy Parser → asCScriptNode (recovery)
  → InternParsedDeclRef / InternParsedCall (landed)
  → InternParsedExprTerm (landed intern, broken identity):
        FindExisting SEQUENCE / INDEX / UNARY / CALL at whole-term range
        walk snExprPreOp / snExprPostOp / else FromNode
        sequence length > 1 → ActOnSequenceExpr
  → snExpression still ActOnBinaryExpr → rewrite to ActOnCall(opSub/…)
  → FindExistingExpr matches kind + begin.offset only
  → ActOnCall always MakeExpr (no FindExisting)
  → CANONICAL Build → Generate(); LEGACY still asCCompiler
```

`FindExistingExpr` (`as_sema_expr.cpp:35-52`):

```cpp
static asASTExprId FindExistingExpr(asCASTContext& context, asEASTExprKind kind, const asCSourceRange& range)
{
	if( range.begin.fileID == 0 || range.begin.offset == 0 )
	{
		return asASTExprId();
	}
	for( asUINT i = 1; i <= context.GetExprCount(); ++i )
	{
		const asCExpr* existing = context.GetExpr(asASTExprId(i));
		if( existing
			&& existing->kind == kind
			&& existing->range.begin.fileID == range.begin.fileID
			&& existing->range.begin.offset == range.begin.offset )
		{
			return existing->id;
		}
	}
	return asASTExprId();
}
```

---

## 1. Dumps already prove the collision

### `v - 3` (`OperatorMinusSelectsOpSubNotBuiltinBinary` / incomplete-parse twin)

Automation.log ~2814 / ~3069:

```text
STMT id=3 kind=Return expr=6 children=
EXPR id=2 kind=DeclRef type=T literal=v callee=Entry()::v
EXPR id=4 kind=Call type=int callee=T::opSub(int) nargs=1 args=3
EXPR id=6 kind=Binary type=int literal=- callee=
```

Parser interned rewrite CALL id=4. Attached Return uses Binary id=6. Tests fail on `IsFalse(bMinusBinary)`, not on missing `callee=T::opSub(int)`.

`OperatorPlusSelectsOpAddNotBuiltinBinary` PASSes because it never forbids `kind=Binary literal=+`. Do not weaken the minus/star/slash/percent/equal/less locks to match Plus.

### `Make()[0] += 1` (`IndexCompoundAssignEvaluatesBaseOnce`)

Automation.log ~2545:

```text
EXPR id=13 kind=Call type=T callee=Make() nargs=0
EXPR id=16 kind=Conversion dest=T src=int
EXPR id=17 kind=Assign literal==
```

No `kind=Index`, no `callee=T::opIndex(int)`. Assign sees lhs type `T`. CodeGen fail-closes (`Canonical CodeGen failed code=1 line=1068`). `Make()` count is already 1 — the fail is missing opIndex, not double Make.

### Sequence of intern (must keep this order in mind)

1. Parser `ActOnParsedExpr` `snExprTerm` `v` → DeclRef (no CALL yet).
2. Parser `snExpression` `v - 3` → `ActOnBinaryExpr` → CALL at range whose **begin.offset is `v`**.
3. WalkOne `snExprTerm` `v` → `InternParsedExprTerm` FindExisting CALL at begin=`v` → **returns opSub CALL**.
4. WalkOne `snExpression` → `ActOnBinaryExpr(lhs=Call(int), "-", 3)` rewrite fails → Binary.
5. Return attaches Binary.

`Make()[0]`: inner CALL `Make()` begin.offset = `Make`. Whole term also begins at `Make`. FindExisting CALL returns `Make()` and **never** walks `[`.

---

## Files

- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` (`InternParsedExprTerm` ~1399-1505; optionally `ActOnBinaryExpr` ~884-944)
- Do **not** modify: `as_sema_expr.cpp` `FindExistingExpr` matching rule; `as_compiler.cpp`; `as_module.cpp` `Build()`; tests unless a dump still lies after intern fix
- Test (already exist): `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  - `IndexCompoundAssignEvaluatesBaseOnce` ~1350
  - `OperatorMinusSelectsOpSubNotBuiltinBinary` ~7323
  - `OperatorStar` / `Slash` / `Percent` / `Equal` / `Less` nearby
  - `ParserActOnBinaryOverloadBeforeFunctionCloseFails` ~9004
  - Keep: `ParserActOnUnaryMinusSelectsOpNegBeforeFunctionCloseFails`, `ParserActOnPostIncSelectsOpPostIncBeforeFunctionCloseFails`

---

### Task 1: Confirm RED still matches these dumps

- [ ] **Step 1:** Do not add tests. The eight methods already fail.

- [ ] **Step 2:** If you rebuild, re-run only after impl. The on-disk report is sufficient evidence to edit.

Expected: same eight names, same dump shape (CALL present + Binary leftover; Index missing).

---

### Task 2: Stop Term from reusing a CALL at the term start offset

**Interfaces:**

- Consumes: `FindExistingExpr`, `ActOnUnaryExpr`, `InternParsedCall`, `ActOnMemberExpr`, `ActOnIndexExpr`, `ActOnPostfixCallExpr`, `ActOnSequenceExpr`
- Produces: `InternParsedExprTerm` returns the term's Sequence/Index/Unary/postfix result, never an inner `Make()` or a binary-rewrite `opSub` CALL that merely shares `begin.offset`

- [ ] **Step 1: Remove the whole-term CALL FindExisting in `InternParsedExprTerm`**

In `as_sema_expr.cpp` `InternParsedExprTerm`, delete only this block (currently ~1421-1425):

```cpp
	const asASTExprId existingCall = FindExistingExpr(context, asAST_EXPR_CALL, range);
	if( existingCall.IsValid() )
	{
		return existingCall;
	}
```

Keep SEQUENCE / INDEX / UNARY FindExisting. Inner named calls already reuse by **ident** offset in `InternParsedCall` (`as_sema_expr.cpp:1350-1365`). Unary `opNeg` CALL reuse stays inside `ActOnUnaryExpr` (`as_sema_expr.cpp:734`).

Comment (short, factual):

```cpp
	// Do not FindExisting CALL at the whole-term range. FindExistingExpr
	// matches begin.offset only, so v-3 rewrite CALL and Make() share the
	// term start and would skip Index / steal the binary rewrite.
```

Do **not** change the child walk (pre-op / `.` / `[` / `(` / postfix `++`/`--`).

- [ ] **Step 2: Build then SemaAuthority**

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-term2
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-term-sema2 -TimeoutMs 600000
```

Expected: **208/208** (or live total). The eight names PASS. opNeg / opPostInc still PASS.

- [ ] **Step 3: If Binary leftover remains, second-line only**

If dumps still show `kind=Binary literal=-` **and** `callee=T::opSub(int)` after Step 1, then in `ActOnBinaryExpr` **before** `return ActOnBinary(...)`, reuse an existing rewrite CALL at the same range:

```cpp
	const asASTExprId existingCall = FindExistingExpr(context, asAST_EXPR_CALL, range);
	if( existingCall.IsValid() )
	{
		return existingCall;
	}
	if( !lhs.IsValid() )
	{
		return asASTExprId();
	}
	return ActOnBinary(op ? op : "", lhs, rhs, intType, range);
```

Do this **only** if Step 1 leaves Binary. Do not add it speculatively.

- [ ] **Step 4: CanonicalAST then Compiler**

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-term-canonical -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-term-compiler -TimeoutMs 600000
```

Expected: CanonicalAST live total PASS (was **254/254** before term peel; live total may be 256 with the two new Term methods). Compiler live total PASS (was **444/444**).

- [ ] **Step 5: Record, do not check boxes**

Append a short GREEN note to `attachments/wave-b-results.md`. Leave `tasks.md` 4.2 / 13.2 / 13.3 `[ ]`. Do not commit. Do not archive.

---

## Must stay true

| TEST_METHOD | Dump lock |
| --- | --- |
| `ParserActOnUnaryMinusSelectsOpNegBeforeFunctionCloseFails` | incomplete `-v;` → `callee=T::opNeg()`, not builtin Unary `-` |
| `ParserActOnPostIncSelectsOpPostIncBeforeFunctionCloseFails` | incomplete `v++;` → `callee=T::opPostInc()`, not `opPreInc` |
| `ParserActOnCallSelectsIntOverloadBeforeFunctionCloseFails` | incomplete `return F(3` → `callee=F(int)` not `F(float)` |
| `ParserActOnBinaryOverloadBeforeFunctionCloseFails` | incomplete `return v - 3` → `callee=T::opSub(int)` and **no** `kind=Binary literal=-` |
| `IndexCompoundAssignEvaluatesBaseOnce` | `callee=T::opIndex(int)` and exactly one `callee=Make()` |
| `OperatorMinusSelectsOpSubNotBuiltinBinary` (and star/slash/percent/equal/less) | rewrite CALL, **no** builtin Binary of that operator |

---

## Forbidden

- Sharing UBT with 5.4 / 5.6 / Wave E–G
- Reverting `InternParsedExprTerm` to `ActOnExprFromNode` whole-node
- Changing `FindExistingExpr` globally to compare `end.offset`
- Nesting local-init (F4 trap: sibling `STMT_EXPR`)
- Checking 4.2 / 13.2 / 13.3 / 9.5
- Default `canonicalCompilerPipeline = true`
- CANONICAL `CompileFunction`

---

## What GREEN is not

Term identity GREEN means WalkOne does not intern a leftover Binary and Index intern runs. It does **not** mean:

- Parser is action-only for the language (4.2)
- Sema environment so backends do not rerun Sema (13.2)
- OpaqueValue / `+=` single-eval plan (5.4) — `IndexCompoundAssignEvaluatesBaseOnce` is a **weak** count lock
- Production default CANONICAL (10.2)
