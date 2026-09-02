# Wave B exclusive UBT — 5.4 sequencing / single-evaluation (B-54-single-eval)

> **For the exclusive-UBT worker:** REQUIRED SUB-SKILL: `superpowers:test-driven-development`. Add the four failing SemaAuthority methods first. `RunBuild` then the SemaAuthority prefix **before** filling `as_sema_expr.cpp`. Do **not** check `tasks.md` 5.4 / 13.2 / 13.3 / 4.2 / 5.6 / 5.9 / 9.5.

**Goal:** Exact exclusive-UBT TDD map for task 5.4: explicit sequencing / single-evaluation nodes for property/index/mutation chains, short-circuit logic, conditional expressions, temporaries, and compiler-generated values. Backends must not re-infer evaluation order from source tokens or Bytecode.

This is **not** 13.2 close and **not** production Build routing. Named dumps on compile→seal. LEGACY still `asCCompiler`. Do not prove VM side-effect traces in this UBT (those traces today are still `asCCompiler`).

LLVM/Clang is a **shape reference only** (`attachments/llvm-ast-architecture.md`, `clang-ast-reference.md`). Do not link Clang/LLVM.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-22 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-54-single-eval** (`attachments/async-work.md` §7, `async-dispatch.md`) |
| Mode now | **Attachment only** until this file is consumed. This write-up is the TDD map. |
| Mode later | Exclusive UBT. TDD. One UBT user. |
| Evidence now | SemaAuthority **200/202** `wave-b-param-sema` (param intern identity RED). Do not start this UBT on that red. |
| Gate | **B-param-identity GREEN** first (`attachments/wave-b-param-identity-next.md`). SemaAuthority all PASS (202/202 or live total) and `ConstructorOverloadsSelectExactCtorNotFirstName` `Build()==0`. |
| Do not mark | **5.4 / 13.2** (also 4.2 / 5.6 / 5.9 / 9.5 / 13.3) |

---

## Global constraints

- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` = `ttNull`; mixin **functions**; mutable script globals intern-then-reject; host `RegisterFuncdef` legal.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Commands only from `D:\as-cta`: `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. Always `-NoXGE`. `RunTests.ps1` does not UBT.
- **Hard no:** CALL-without-callee; default CANONICAL; CANONICAL CompileFunction; second UBT in `D:\as-cta`; archive; commit unless asked; Unreal types in fork frontend files; invent stmt-level cleanup-plan POD fields; invent dictionary; re-enable mutable globals as language; C labeled break.
- Dump printer (`as_ast_dump.cpp`) only for the **new tokens** listed below. Do not restyle existing Call/Index/Conversion grammar.
- Do **not** edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, or `as_ast_verifier.cpp` firewall beyond a one-line `ExpectedExprChildCount` for a new expr kind.
- After these dump tests go green, **5.4 / 13.2 stay `[ ]`**. Full 5.4 still wants isolated legacy/canonical VM traces of AST-driven CodeGen. This UBT only locks the sealed plan.

---

## Architecture today (do not contradict)

```text
legacy Parser → asCScriptNode (recovery)
  → dedicated intern already landed for:
      Index / Sequence / Logical / Conditional / Assign / Conversion /
      MaterializeTemporary / Cleanup / Member / Call / Unary
  → ActOnAssignExpr ignores += (always intern "=")
  → ActOnIndexExpr sets opIndex resolvedDecl; does not wrap OpaqueValue
  → TryRewritePropertyGet/Set rewrite v.Value; compound += drops get-add
  → Sequence is the snExprTerm postfix bag (literal=seq), not a mutation plan
  → asCExpr has no OpaqueValue kind
  → dump of Sequence/Logical/Conditional is the generic EXPR line (no parts=/lhs=/then=)
  → CANONICAL Build → Generate(); LEGACY still asCCompiler
```

`asCExpr` stays compact tagged POD (`id/kind/range/type/valueCategory/resolvedDecl/literal/literalBits/children`). Single-eval must use **children IDs**, not new stmt cleanup fields and not new expr POD members.

---

## 1. What already dumps vs what is missing

Live dump surface (`as_ast_dump.cpp`):

| Kind / token | Live? | Where |
| --- | --- | --- |
| `kind=Index` | yes | `ExprKindName`; generic EXPR line `literal=[]` once `ActOnIndex` runs |
| `callee=T::opIndex(int)` | yes, when `resolvedDecl` set | `ActOnIndexExpr` `SetResolvedDecl`; IndexCompoundAssign / Parser index tests |
| `kind=Sequence` | yes | intern + dump name; `ActOnSequence` sets `literal=seq` |
| Sequence `parts=` child ids | **no** | generic EXPR line only: `literal=` / `callee=` |
| `kind=Logical` | yes | `ActOnLogical` stores op in `literal` (`&&` / `\|\|` / `xor`) |
| Logical `literal=&&` asserted | **no** | `LogicalShortCircuitRecordsOnCompileSealPath` asserts kind + callees only |
| Logical `lhs=` / `rhs=` | **no** | children exist (2); dump does not name them |
| `kind=Conditional` | yes | `ActOnConditional` `literal=?:`; children cond/then/else |
| Conditional `cond=` / `then=` / `else=` | **no** | If **stmt** already dumps `then=`/`else=`; Conditional **expr** does not |
| `kind=Conversion` `dest=` `src=` | yes | dedicated Conversion dump; `ConversionDumpRecordsDestTypeKey` |
| `kind=MaterializeTemporary` / `kind=Cleanup` | yes | `ValueTemporaryRecordsMaterializeAndCleanup` (`struct FValue`) |
| `callee=T::GetValue()` / `T::SetValue(int)` | yes | `PropertyReadWriteRewritesToAccessors` (`v.Value = 4` / `return v.Value`) |
| `kind=Assign` `literal=` | yes | `ActOnAssign` **hardcodes** `literal="="` |
| `kind=OpaqueValue` | **no** | `asEASTExprKind` has no such enumerator (`as_ast_kind.h` 55–77) |
| Single-eval of `Make()` as a **shared** source | weak | `IndexCompoundAssignEvaluatesBaseOnce` counts `kind=Call callee=Make()` == 1; does not require Sequence/OpaqueValue/`+=` plan |
| Compound `+=` plan (get, add, set) | **no** | `snAssignment` middle child is `snExprOperator` (`ttAddAssign`); both `ActOnParsedExpr` and `ActOnExprFromNode` ignore it |

Landed SemaAuthority methods that **must stay** (do not rewrite them down):

| TEST_METHOD | What it locks | What it is not |
| --- | --- | --- |
| `IndexOnCompileSealPathRecordsIndexNode` | `kind=Index` for `Values[3]` | opIndex callee / single-eval |
| `IndexCompoundAssignEvaluatesBaseOnce` | `callee=T::opIndex(int)` + one `callee=Make()` Call line | OpaqueValue / `+=` rewrite / Sequence mutation plan |
| `PropertyReadWriteRewritesToAccessors` | Get/Set on simple `=` / read | compound `+=` single-eval of receiver |
| `SemaSequenceExprActionRecordsKindWithoutScriptNode` | `ActOnSequenceExpr(1,2)` → `kind=Sequence` | mutation plan |
| `SemaLogicalActionRecordsShortCircuitWithoutScriptNode` | `kind=Logical` without FromNode | named lhs/rhs / compile→seal `literal=&&` |
| `LogicalShortCircuitRecordsOnCompileSealPath` | compile→seal `kind=Logical` + `callee=F(int)` | `literal=&&` / `lhs=` / `rhs=` |
| `SemaConditionalExprActionRecordsTernaryWithoutScriptNode` | `kind=Conditional` + F(int)/G(int) | named cond/then/else |
| `ParserActOnConditionalRecordsTernaryOnSuccessfulParse` | one Conditional, selected F(int) | Conversion on mismatched arms |
| `ValueTemporaryRecordsMaterializeAndCleanup` | `struct FValue().Value` materialize + cleanup | mutation single-eval of `Make()` |
| `SemaAssignActionRewritesPropertySetWithoutScriptNode` | `v.Value = 4` → SetValue | `+=` must not become `SetValue(v, 1)` |
| `ConstGlobalTraitAndMutableReject` | const global `quals=1`; mutable intern-then-reject | do not use mutable globals as trace counters |

Code that still forces backends to re-infer (cite):

```text
as_sema_expr.cpp ActOnAssignExpr (~665)
  TryRewritePropertySet then ActOnAssign; no assign-op parameter

as_sema_expr.cpp snAssignment (~1613)
  ActOnExprFromNode: lhs/rhs only; middle snExprOperator discarded

as_sema_decl.cpp ActOnParsedExpr snAssignment (~1732)
  same: ActOnAssignExpr(lhs, rhs) — ttAddAssign never observed

as_sema.cpp ActOnAssign (~723)
  MakeExpr(..., "=") always

as_sema_expr.cpp TryRewritePropertySet (~168)
  Get* Call or MemberRef → Set*(receiver, rhs). Compound += would Set the addend, not get+add+set

as_sema_expr.cpp ActOnIndexExpr (~696)
  ActOnIndex + SetResolvedDecl(opIndex). No OpaqueValue wrap of base

as_sema_expr.cpp snExprTerm (~1471)
  sequence.GetLength() > 1 → ActOnSequenceExpr (postfix bag, literal=seq)

as_ast_kind.h
  no asAST_EXPR_OPAQUE_VALUE

as_ast_dump.cpp else-branch (~401)
  Sequence / Logical / Conditional / Index: no parts=/lhs=/then=/source=
```

Clang shape (do not copy code, do not link): `OpaqueValueExpr` + `BinaryOperator`/`CXXOperatorCallExpr` compound-assign; `ImplicitCastExpr` on logical/ternary operands; `ConditionalOperator` named cond/true/false; `MaterializeTemporaryExpr` / `ExprWithCleanups` already mapped to existing expr kinds. Sequence is **not** a substitute for OpaqueValue: CodeGen already walks `asAST_EXPR_SEQUENCE` as left-to-right last-value (`as_bytecode_codegen.cpp` ~914). Using Sequence for both postfix bags and once-only bindings would make backends re-infer which child is a binding.

---

## 2. Chosen encoding (do not invent extra POD)

| Role | Node | Dump tokens | Children |
| --- | --- | --- | --- |
| Once-only binding | **new** `asAST_EXPR_OPAQUE_VALUE` | `kind=OpaqueValue` `source=%u` | 1: source expr |
| Ordered plan | existing `asAST_EXPR_SEQUENCE` | `kind=Sequence` `literal=opaque` `parts=` comma-ids | N ≥ 2; last is the value |
| Postfix bag (already) | `asAST_EXPR_SEQUENCE` | `literal=seq` (keep) | snExprTerm parts |
| Short-circuit | existing `asAST_EXPR_LOGICAL` | `kind=Logical` `literal=&&` `lhs=` `rhs=` | 2 |
| Ternary | existing `asAST_EXPR_CONDITIONAL` | `kind=Conditional` `literal=?:` `cond=` `then=` `else=` | 3 |
| Compiler-generated conversion | existing `asAST_EXPR_CONVERSION` | `dest=` `src=` (already) | 1 |
| Temporary | existing Materialize/Cleanup | `kind=MaterializeTemporary` / `kind=Cleanup` | 1 |

**OpaqueValue:** `children[0]` is the source. Later Index / Get / Set / Binary operands that must not re-evaluate the source store the **OpaqueValue expr id**, not a second Call. Dump `source=` is that child id (the Make()/receiver expr), not the OpaqueValue's own id.

**Mutation Sequence (`literal=opaque`)** for `Make()[0] += 1` (sketch, implement against tests):

```text
Sequence literal=opaque parts=<OV>,<Index>,<Add>,<Set-or-Assign>
  OpaqueValue source=<Make-or-Materialize>
  Index(OV, 0)  callee=T::opIndex(int)
  Binary/Call +  (get + 1)
  write through same OV  (Assign to Index(OV,0) or opIndex-set)
```

Exactly one `kind=Call` line with `callee=Make()` (reuse `CountDumpLinesContaining` / the Call-line filter already in `IndexCompoundAssignEvaluatesBaseOnce`).

**Do not:**

- Add stmt-level cleanup-plan fields. CLEANUP / MATERIALIZE stay expr kinds.
- Encode single-eval only as DAG-shared Call ids without OpaqueValue. Naive `EmitExpr` of a shared id still re-runs the call (`EmitIndex` always `EmitExpr(children[0])`). OpaqueValue is the fact backends can memoize; sharing without it is still re-inference.
- Reuse postfix `literal=seq` Sequence as the mutation plan. New mutation wrappers use `literal=opaque`.
- Invent script `funcdef` / `@` / `is`.
- Use a mutable script global as a side-effect counter (`ConstGlobalTraitAndMutableReject`).

**CodeGen fire-break (not 9.5):** `Generate()` `default:` is `FailAt(asINVALID_ARG)` (`as_bytecode_codegen.cpp` ~940). Compile→seal tests that `Build()` will fail-closed if OpaqueValue is unknown. If — and only if — the new tests' `Build()!=0` is proven to be that unknown-kind path, add:

```cpp
case asAST_EXPR_OPAQUE_VALUE:
    return expr->children.GetLength() ? EmitExpr(expr->children[0]) : 0;
```

That passthrough still double-evaluates when Index also emits the source. It is **not** single-eval lowering and **not** 9.5. Prefer not touching CodeGen if the test dumps via Parser `SetSema` + `Seal` instead; the four methods below use CANONICAL `Build()` so the fire-break is listed.

---

## 3. Four TEST_METHOD names (add to SemaAuthority)

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Add **after** `IndexCompoundAssignEvaluatesBaseOnce` (keep that method). Pattern: `FNativeTestEngine` + `ON_SCOPE_EXIT { Engine.Destroy(); }` + `SetCompilerPipeline(asCOMPILER_PIPELINE_CANONICAL)` + `SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)` + `ASTEST_AS_ANSI` Allman + **`Build()==0`** + `asCASTDump` of `GetCanonicalASTContext()`. Prefer `DumpSealedCanonicalAst` only if you also assert `Build()==0` (the helper currently swallows Build failure).

Use `CanonicalASTSemaAuthorityTest::CountDumpLinesContaining` for Call-line counts. For `callee=Make()` count, copy the existing Call-line filter (`kind=Call` && `callee=Make()` && `!callee=Make()::`) so DeclRef/other lines do not inflate.

### 3.1 `IndexCompoundAssignRecordsOpaqueValueOnCompileSealPath`

Index + mutation + single-eval of base. Temporaries: `class T` is a ref type, so **do not** require `kind=MaterializeTemporary` here (`ValueTemporaryRecordsMaterializeAndCleanup` already locks `struct FValue`).

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

Same fixture as `IndexCompoundAssignEvaluatesBaseOnce` on purpose. That method stays the weak count lock. This method is the plan lock.

**Must appear:**

- `Build()==0`
- `kind=OpaqueValue`
- `source=` with a non-zero id on an OpaqueValue line
- `kind=Sequence` and `literal=opaque` (mutation plan, not only postfix `literal=seq`)
- `callee=T::opIndex(int)`
- `kind=Index` **or** a Call whose callee is `T::opIndex(int)`
- exactly one Call line `callee=Make()` (same filter as the existing method)

**Must not appear:**

- two `callee=Make()` Call lines
- Index with empty `callee=` as the only indexed form
- `opAdd` as a substitute for `opIndex`
- `literal==` as the **only** assign of `+=` (simple `ActOnAssign` leftover)

**Expected first RED:** no `kind=OpaqueValue`; Sequence if present is postfix `literal=seq`; Assign `literal==`; `ttAddAssign` discarded; `Build` may still succeed because Index+Assign is a legal (wrong) graph.

### 3.2 `PropertyCompoundAssignEvaluatesReceiverOnceOnCompileSealPath`

Property + mutation + single-eval of receiver. Do not fall back to `v.Value = 4` (already green).

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	class T
	{
		int Stored = 0;

		int GetValue()
		{
			return Stored;
		}

		void SetValue(int Next)
		{
			Stored = Next;
		}
	}

	T Make()
	{
		T v;
		return v;
	}

	int Entry()
	{
		Make().Value += 1;
		return 1;
	}
	)AS");
```

**Must appear:**

- `Build()==0`
- `kind=OpaqueValue` + `source=`
- `kind=Sequence` `literal=opaque`
- `callee=T::GetValue()`
- `callee=T::SetValue(int)`
- exactly one Call line `callee=Make()`

**Must not appear:**

- two `callee=Make()` Call lines
- SetValue without GetValue (current `TryRewritePropertySet` on a Get* lhs with rhs=`1` would dump SetValue(receiver, 1) and drop get-add)
- mutable script global used as a counter

**Expected first RED:** `TryRewritePropertySet` sees GetValue Call, rewrites to `SetValue(Make(), 1)` or SetValue on a once-interned Make without OpaqueValue/`+=` add.

### 3.3 `LogicalAndRecordsNamedOperandsOnCompileSealPath`

Short-circuit. Parent intern is already green (`LogicalShortCircuitRecordsOnCompileSealPath`). This method locks **named operands** so backends cannot treat `&&` as `kind=Binary`.

Keep bool-returning callees so the fixture compiles without inventing `int && int` (fork `&&` is bool). Compiler-generated Conversion is method 3.4.

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	bool F(int a)
	{
		return true;
	}

	bool F(float a)
	{
		return false;
	}

	bool G(int a)
	{
		return true;
	}

	bool Entry()
	{
		return F(1) && G(2);
	}
	)AS");
```

**Must appear:**

- `Build()==0`
- a Logical line containing `kind=Logical` and `literal=&&`
- that same Logical line contains `lhs=` and `rhs=` with Atoi > 0
- `callee=F(int)` and `callee=G(int)`

**Must not appear:**

- `callee=F(float)`
- `kind=Binary` as the `&&` node (`literal=&&` on Binary)
- inventing `is` / `@`

**Expected first RED:** dump still generic `kind=Logical type=bool ... literal=&& callee=` **without** `lhs=`/`rhs=`. Kind+callees already pass on the sibling method — dump printer work is this method's RED.

### 3.4 `ConditionalMismatchedArmsRecordConversionOnCompileSealPath`

Conditional expr + compiler-generated Conversion. Named cond/then/else on the **expr** line (If **stmt** `then=`/`else=` already landed; do not reuse those tests).

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	float Entry(int Flag)
	{
		return Flag ? 1 : 2.0f;
	}
	)AS");
```

No extra overloads, no `class T` ctor, no mutable global. `ActOnConditionalExpr` already converts else→then type when type ids differ (`as_sema_expr.cpp` ~860); the missing dump is named phases + asserting Conversion on the sealed graph.

**Must appear:**

- `Build()==0`
- a Conditional line containing `kind=Conditional` and `literal=?:`
- that same line contains `cond=` `then=` `else=` with Atoi > 0
- a Conversion line with `kind=Conversion` and (`dest=float` `src=int` **or** `dest=int` `src=float`) — whichever arm Sema canonicalizes. Lock **both dest and src** on that line so backends do not redo the conversion.

**Must not appear:**

- only If-stmt `then=`/`else=` satisfying the Conditional assert (search `kind=Conditional` lines)
- script `funcdef` / `@` / `is`
- requiring `kind=OpaqueValue` on this fixture (no repeated mutation target)

**Expected first RED:** Conditional dump is generic (`literal=?:` without `cond=`/`then=`/`else=`). Conversion may already exist from `ActOnConditionalExpr`; if dest/src already dump, the named-phase tokens are still RED.

---

## 4. File map

| File | What to change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Four methods above. Keep existing Index/Property/Logical/Conditional/Sequence/Materialize tests |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_expr.cpp` | Thread assign-op (`OperatorText` of `snExprOperator`) into assign intern; wrap mutation targets with OpaqueValue + Sequence `literal=opaque`; Index/property `+=` get+add+set using the **same** OpaqueValue id |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` | `kind=OpaqueValue` `source=`; Sequence `parts=`; Logical `lhs=` `rhs=`; Conditional `cond=` `then=` `else=`. Do not restyle Call/Index/Conversion |

Required companions (new kind / action, still this UBT):

| File | Why |
| --- | --- |
| `as_ast_kind.h` | `asAST_EXPR_OPAQUE_VALUE` **after** `CLEANUP`, **before** `ERROR` |
| `as_sema.h` / `as_sema.cpp` | `ActOnOpaqueValueExpr` (1 child, `literal=opaque`). Extend `ActOnAssignExpr` with op (default `"="`) **or** add `ActOnCompoundAssignExpr` and keep `=` tests on the old signature |
| `as_sema_decl.cpp` `ActOnParsedExpr` `snAssignment` | Pass middle-child token into the assign action (leftover **extract**, not leftover intern of Assign) |
| `as_ast_verifier.cpp` `ExpectedExprChildCount` | OpaqueValue → 1. Sequence stays default `-1`. **Not** a 2.8 reopen. Do not add stmt cleanup fields |
| `as_bytecode_codegen.cpp` | **Only** the OpaqueValue passthrough fire-break if CANONICAL `Build` fail is unknown-kind. No eval-once memo. Not 9.5 |

Do **not** edit: `as_compiler.cpp`, `as_module.cpp` `Build()` routing, production default pipeline, enumerator WalkOne, leftover `ActOnParsedExpr` whole-node FromNode except the assignment operator token.

Do **not** invent: stmt-level cleanup POD; script `funcdef` / `@` / `is`; `dictionary`; mutable globals as language.

---

## 5. TDD steps (later exclusive UBT)

### Step 0 — gate

Do **not** start this UBT until `B-param-identity` is GREEN:

- SemaAuthority all PASS (`wave-b-param-sema2` or successor)
- `ConstructorOverloadsSelectExactCtorNotFirstName` `Build()==0` and `callee=T::T(int)`
- three Param tests still PASS

These four methods use `class T` / `T Make()` / default construction. Intern-after-name ctor identity RED will fail-closed CANONICAL `Build` and hide 5.4 dumps.

No other intern peel is required first. Enumerator WalkOne and leftover `ActOnParsedExpr` FromNode wrappers are **not** this package. Threading `+=` through existing Assign intern **is** this package.

### Step 1 — RED tests only

Add the four methods. No fork edits yet.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-54-red -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-sema-red -TimeoutMs 600000
```

Expected: the four new methods FAIL for the missing tokens above. Existing Index/Property/Logical/Conditional methods stay PASS.

### Step 2 — dump tokens (printer first is allowed when RED is dump-only)

Methods 3.3 / 3.4 may go GREEN from `as_ast_dump.cpp` alone (`lhs=`/`rhs=`, `cond=`/`then=`/`else=`). That is honest: Logical/Conditional intern already exists. Do not call that 5.4 close.

Methods 3.1 / 3.2 stay RED until Sema wraps OpaqueValue.

### Step 3 — Sema mutation plan

In `ActOnAssignExpr` / assign extract:

1. Read assign-op (`=` / `+=` / …). `=` keeps today's Get/Set rewrite.
2. For `+=` (this UBT; other compound ops may follow the same helper but tests only lock `+=`):
   - If lhs is Index or property-Get/MemberRef: intern `OpaqueValue` of the **base/receiver** (Make() / v).
   - Index and Get/Set children use that OpaqueValue id.
   - Build Sequence `literal=opaque` of `[OV, get, add, set]`.
3. `FindExistingExpr` OpaqueValue by range so Parser ActOn + WalkOne do not duplicate.
4. Keep `ActOnIndexExpr` opIndex `resolvedDecl`. Do not replace Index with a callee-less CALL.

### Step 4 — GREEN prefixes

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-54 -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-54-sema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-54-canonical -TimeoutMs 600000
```

If CanonicalAST is green, Compiler prefix is allowed as regression only (not 5.4 close):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-54-compiler -TimeoutMs 600000
```

Never All. Never flip `canonicalCompilerPipeline`. Never CANONICAL `CompileFunction`.

Expected: SemaAuthority all PASS (live total = previous green + 4, or +3 if a method is merged — do not merge). CanonicalAST all PASS. **Did not check 5.4 / 13.2.**

Record evidence in `attachments/wave-b-results.md` (append a short B-54 section). Patch `tasks.md` 5.4 **progress note only**. Leave the box `[ ]`.

---

## 6. Hard nos

- CALL-without-callee as a seal/verifier firewall. `asCASTVerify` still OK on unsealed graphs.
- Default CANONICAL. CANONICAL CompileFunction. Wave E–G. Archive. Commit unless asked.
- Second UBT in `D:\as-cta`. New worktree.
- Check 5.4 / 13.2 / 4.2 / 5.6 / 5.9 / 9.5 / 13.3 from prefix green or dump green.
- Clang/LLVM link. Unreal types in fork frontend files.
- Script `funcdef` / `@` / `is`. Invent `dictionary`. Mutable globals as language / trace counters.
- Invent stmt-level cleanup-plan POD. CLEANUP / MATERIALIZE stay expr kinds.
- VM side-effect-trace parity as this UBT's pass criterion (`RunSingleEval` in `AngelscriptNativeCanonicalASTVmMatrixTests.cpp` is still `asCCompiler`).
- Start this UBT while `B-param-identity` is RED.
- Reopen Wave C 2.4 / 2.6 / 2.8 / 13.4 / 13.5.

---

## 7. Done means (this UBT only)

- Four new SemaAuthority methods PASS on compile→seal dumps with the tokens in §3.
- Existing Index / property Get-Set / Logical / Conditional / Sequence / Materialize / Param / ctor-identity tests still PASS.
- `asCExpr` gained at most a **kind enumerator**, not new POD fields, not stmt cleanup fields.
- LEGACY default unchanged. Production Bytecode still `asCCompiler` on the default pipeline.
- **5.4 stays `[ ]`:** backends still may re-eval OpaqueValue via the CodeGen passthrough; isolated legacy/canonical VM traces of AST-driven CodeGen are not this slice.
- **13.2 stays `[ ]`:** this is still dump facts, not a Sema environment.

---

## Gate answer

**Do not start this exclusive UBT until `B-param-identity` is GREEN.** After that, **5.4 can start immediately.** It does **not** need enumerator WalkOne or another leftover-intern peel first. Threading `ttAddAssign` through already-dedicated Assign intern is this slice's extract, not a prior package.
