# Wave B — next exclusive-UBT TDD bite: F6 / spec 13.5 remainder (verifier as executable publication firewall)

> **Attachment only now.** Do **not** edit `Plugins/`. Do **not** UBT. Do **not** flip or uncheck `tasks.md` 13.5 (checked and 虚标). Do **not** edit `async-work.md` / `async-dispatch.md`.
>
> Later exclusive UBT is queued **after** F2 mutex release (`async-work.md` §6 item 4). This file is the map for that UBT.
>
> This bite is **not** a 13.5 close, **not** a 2.8 reopen, **not** 5.5 / 5.6 / 13.2.

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`. LLVM/Clang is a shape reference only.

Companions: `async-work.md` §3 F6, `reviews/implementation-rereview-2026-08-22-tenth-pass.md` F6, `reviews/implementation-rereview-2026-08-22-ninth-pass.md` F6, `attachments/wave-c-28-verifier-remainder.md`, `attachments/wave-c-remaining-firewall.md` §5.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Package | **B-verifier-135-next** (research). Later UBT: publication-time required CALL/CONSTRUCT/DECL_REF target |
| Gate | F2 exclusive mutex released. Verifier **17/17** `wave-b-55-ver` still GREEN as regression |
| Do not mark | **13.5** (already `[x]` 虚标 — **do not uncheck**). Also leave **13.2 / 5.5 / 5.6 / 9.4** |
| Commands (later UBT only) | `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` from `D:\as-cta`, always `-NoXGE` |

`tasks.md:301` original text (leave `[x]`, do not rewrite):

> R08 verifier firewall: stmt/expr indices, operand kinds, parent/child ownership, cycles, control targets, types/value categories, resolved signatures, cleanup plans, sealed publication. Seal must fail before any consumer sees an incomplete graph.

---

## 1. Honest: 13.5 is checked and 虚标 — this dispatch must not uncheck it

Mechanical box: **`[x]` 13.5**. Closed note at `tasks.md:303` cites Wave C 2026-08-21 (`wave-c-28-green` Verifier **13/13**): stmt-multi-owner, stmt-cycle, fallthrough-switch, CLEANUP dtor-when-set, `asCASTVerifyPublication` / `UNSEALED_PUBLICATION`. That close **explicitly** kept CALL-without-callee out of `asCASTVerify`.

Tenth-pass F6 (`reviews/implementation-rereview-2026-08-22-tenth-pass.md` ~238–249, ~318): verifier hash unchanged vs ninth; still only checks `resolvedDecl` **when** `IsValid()`; does not require CALL/CONSTRUCT/DECL_REF/CLEANUP targets; no expr owner/reachability/cycle; no signature/receiver/arg-role. Reviewer would **reopen** 13.5. This change **records honesty only**. Checkbox surgery waits for an explicit rereview pass (`async-work.md` 虚标 rule). **Do not uncheck 13.5** in the later UBT either, even after this bite GREEN.

What is still missing vs the original 13.5 sentence:

| Named item | Still missing after Wave C + B-55 |
| --- | --- |
| resolved signatures | No required CALL/CONSTRUCT/DECL_REF target at **publication**. No callee kind, signature, receiver, arg role/order, type compatibility, route metadata |
| parent/child ownership | Stmt + decl only. **No** expr parent table / single-owner / reachability |
| cycles | Decl + stmt only. **No** expr-cycle |
| cleanup plans | CLEANUP dtor-**when-set** only. Missing CLEANUP target still verifies. **Do not** invent stmt-level cleanup-plan POD |
| sealed publication | Unsealed gate exists; after `Seal()` the same **loose** `asCASTVerify` runs. Recovery CALL (kind stays `CALL`, type ERROR, no callee) can publish |
| operand kinds | Fixed-arity expr kinds only (`ExpectedExprChildCount` ≥ 0). CALL/CONSTRUCT/DECL_REF arity is `-1` (unchecked) |
| “Seal must fail before any consumer sees an incomplete graph” | `Seal()` calls `asCASTVerify` (`as_ast_context.cpp:357–364`). `Generate` only checks `IsSealed()` (`as_bytecode_codegen.cpp:3062–3067`), **not** `asCASTVerifyPublication`. Incomplete CALL can seal and reach CodeGen |

This bite implements **one** missing publication-time check. It does **not** finish the table. After GREEN, 13.5 stays `[x]` 虚标.

---

## 2. HARD NO (Wave C, carried)

**Never add CALL-without-callee as an unsealed `asCASTVerify` firewall.**

Tried in Wave C; broke BodySema/CodeGen seals; **reverted** (`wave-c-remaining-firewall.md` §5, `wave-c-28-verifier-remainder.md` Global constraints).

| Surface | Required contract |
| --- | --- |
| `asCASTVerify` | Must still **succeed** on an unsealed graph whose CALL/CONSTRUCT/DECL_REF has no `resolvedDecl`. `Seal()` uses this function **before** `sealed = true` (`as_ast_context.cpp:350–365`). Incomplete construction graphs must still seal so dumps/diagnostics can exist |
| `asCASTVerifyPublication` on **unsealed** | Must still be `asAST_VERIFY_UNSEALED_PUBLICATION` / `unsealed-publication` **first**. An unsealed CALL-without-callee must **not** report `call-decl` |
| Publication of a **sealed** graph | **This is the gate.** Sealed CALL/CONSTRUCT/DECL_REF without a target must fail here |
| CLEANUP | Missing `resolvedDecl` still verifies at **both** layers (Sema often cannot find a dtor). Only wrong-kind-when-set is `cleanup-dtor` |
| Test names **not** to add | `RejectsCallWithoutResolvedDecl` as an `asCASTVerify` oracle. Do not resurrect Wave C’s reverted seal check |

Existing locks that **must stay GREEN** (unsealed / `Seal()` path):

- `RejectsUnsealedPublication` — `asCASTVerify` OK, publication unsealed-fail, `Seal()` OK, then publication OK (no CALL in that fixture)
- SemaAuthority `ParserActOnUnresolvedCallDoesNotDuplicateOnSuccessfulParse` (~5888–5891): `asCASTVerify` OK; `Seal()` OK (“unresolved CALL must not fail Seal for missing callee”)
- SemaAuthority `MemberAmbiguousOverloadDoesNotBindFirstSameArity` (~10587–10591): `Seal()` + `asCASTVerify` OK; “missing callee is not a verifier firewall”
- SemaAuthority `UnresolvedCallMissingIsErrorTypeNotInt` (~10702–10707): `asCASTVerify` OK; unsealed publication `UNSEALED_PUBLICATION`; `Seal()` OK. **Last assertion (~10708) currently expects sealed publication OK — that lock is the F6 hole and is the companion retarget below, not a reason to put the check in `asCASTVerify`**

`Seal()` of ERROR-typed CALL-without-callee stays legal. Publication after that Seal does not.

---

## 3. Live file:line — what the verifier actually checks vs spec 13.5

Source: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.cpp` (tenth-pass hash prefix `173CA1EF3A30`, unchanged vs ninth). Tests: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp` (**17** `TEST_METHOD`s, prefix `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier`, last green `wave-b-55-ver` **17/17** including `RejectsContinueSkippedNearerLoop`).

### `asCASTVerify` (`:127–541`)

| Spec 13.5 name | Live check | File:line | Detail token / category |
| --- | --- | --- | --- |
| stmt/expr indices | TU missing; decl/stmt/expr `id != table index`; invalid kinds | `:131–152`, `:218–233`, `:472–487` | `translation-unit` / `decl` / `decl-id` / `decl-kind` / `stmt` / `stmt-id` / `stmt-kind` / `expr` / `expr-id` / `expr-kind`. Tests: `RejectsDanglingWrongKindAndInvalidRange`, `RejectsStmtIndexMismatch`, `RejectsExprIndexMismatch` |
| parent/child (decls) | parent exists, parent lists child, child.parent == parent, parent-walk cycle | `:153–196` | `decl-parent` / `decl-parent-child` / `decl-cycle` / `decl-child`. Test: `RejectsParentChildNotBidirectional` |
| decl body ownership | body stmt exists and `body->owner == decl` | `:197–208` | `decl-body` |
| stmt owner/target/expr/range | dangling owner/target/expr; invalid range | `:234–249` | `stmt-owner` / `stmt-target` / `stmt-expr` / `stmt-range` |
| parent/child (stmts) | child exists; **stmt-multi-owner** via `stmtParent[]` | `:250–265` | `stmt-child` / `stmt-multi-owner`. Test: `RejectsStmtMultiOwner` |
| control targets | BREAK/CONTINUE: target kind, ancestor (`StmtContains`), skipped-nearer via parent walk. **Missing `target` is still allowed** (`if( stmt->target.IsValid() )`) | `:266–325` | `ctrl-target` / `continue-target` / `break-target` / `continue-ancestor` / `break-ancestor` / `continue-skipped-nearer` / `break-skipped-nearer`. Tests: `RejectsBreakTargetNotAncestor`, `RejectsBreakSkippedNearerLoop`, `RejectsContinueSkippedNearerLoop` |
| switch order | duplicate-case (literalBits+literal), duplicate-default, default-last | `:327–366` | `duplicate-default` / `duplicate-case` / `default-order`. Test: `RejectsDuplicateCaseAndDefaultNotLast` |
| fallthrough owner | FALLTHROUGH requires some decl `owner` | `:368–374` | `fallthrough-owner` |
| cycles (stmts) | DFS color on stmt children | `:72–102`, `:377–390` | `stmt-cycle`. Test: `RejectsStmtCycle` |
| fallthrough under switch + next case | ancestor SWITCH; if `target` set, must be next ordered CASE | `:392–470` | `fallthrough-switch` / `fallthrough-target`. Tests: `RejectsFallthroughOutsideSwitch`, `RejectsFallthroughTargetNotNextCase` |
| types / value categories | non-ERROR expr: type interned + valueCategory ∈ {PR,L,X}VALUE; quals `asASTQualifiersAreValid`; ERROR kind only checks type if set | `:488–508` | `expr-type` / `expr-value-category` / `expr-quals`. Test: `RejectsExprMissingExactType` |
| resolved signatures | **only** `if( resolvedDecl.IsValid() && GetDecl == 0 )` | `:509–512` | `expr-decl`. **Does not require** a target on CALL/CONSTRUCT/DECL_REF/CLEANUP |
| cleanup plans | CLEANUP **and** `resolvedDecl` set → decl kind must be `DESTRUCTOR` | `:513–520` | `cleanup-dtor`. Test: `RejectsCleanupResolvedDeclNotDestructor`. Missing target **passes** |
| operand kinds | `ExpectedExprChildCount` (`:104–125`): unary-family 1, binary-family 2, conditional 3; **default `-1` includes CALL/CONSTRUCT/DECL_REF/SEQUENCE/literals**. Then children must resolve as expr, not INVALID | `:526–538` | `expr-operand`. Test: `RejectsExprOperandWrongKind` (dangling BINARY child). **No** CALL callee operand rule |
| parent/child (exprs) | **absent** — no expr parent table, no expr-multi-owner | — | — |
| cycles (exprs) | **absent** | — | — |
| safepoint | **absent** (correct). Do not add | — | — |

`ExpectedExprChildCount` (`:104–125`) covers UNARY / CONVERSION / MATERIALIZE_TEMPORARY / CLEANUP / OPAQUE_VALUE / MEMBER_REF (1), BINARY / LOGICAL / ASSIGN / INDEX (2), CONDITIONAL (3). CALL / CONSTRUCT / DECL_REF fall through to `-1`.

### `asCASTVerifyPublication` (`:544–551`)

```cpp
if( !context.IsSealed() )
    return Fail(..., asAST_VERIFY_UNSEALED_PUBLICATION, ..., "unsealed-publication");
return asCASTVerify(context, result);
```

Test: `RejectsUnsealedPublication` (`VerifierTests.cpp:180–199`). After `Seal()`, publication is the **same loose verifier**. That is the F6 hole.

`Generate` (`as_bytecode_codegen.cpp:3062–3067`) duplicates `!IsSealed()` → `UNSEALED_PUBLICATION` and does **not** call `asCASTVerifyPublication`. **Do not wire Generate in this bite.**

---

## 4. Exact next TDD bite (ONE bite)

**First missing publication-time check that is implementable without a Sema environment:** on a **sealed** graph, `asCASTVerifyPublication` requires `resolvedDecl` to resolve for `asAST_EXPR_CALL`, `asAST_EXPR_CONSTRUCT`, and `asAST_EXPR_DECL_REF` when those nodes are present.

Construction-API fixtures only. No Parser, no `asCSema`, no script `Build()`.

### Why this, not expr-cycle, not signatures

- Tenth/ninth F6 lead with “executable CALL/DeclRef missing required target” and “`asCASTVerifyPublication` only checks `IsSealed()` then the loose verifier”.
- `SetResolvedDecl` / `CreateExpr` / `Seal` already exist (`as_ast_context.h:23,57,75`).
- Expr ownership/cycle is real 13.5 remainder but is **graph hygiene**, not the publication-vs-unsealed split this F6 names first.
- Signature/receiver/arg-role needs a Sema-shaped call plan. Out of this bite.

### Files (later UBT)

| Path | Change |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp` | Append **three** methods after `RejectsFallthroughTargetNotNextCase` |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_verifier.cpp` | After the unsealed gate in `asCASTVerifyPublication` **only**, walk exprs; require target for CALL/CONSTRUCT/DECL_REF. Do **not** change `asCASTVerify` |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Companion **lock-flip** of `UnresolvedCallMissingIsErrorTypeNotInt` last assertion only (see §4.4). No other SemaAuthority rewrites |

Do **not** touch `as_sema*`, `as_bytecode_codegen.cpp`, `as_ast_context.cpp` `Seal()`, `as_stmt.h` / `as_expr.h` POD, `tasks.md`.

### Detail tokens (stable)

| Case | Category | Detail |
| --- | --- | --- |
| Sealed CALL, `!resolvedDecl.IsValid()` or `GetDecl==0` | `asAST_VERIFY_DANGLING_ID` | `call-decl` |
| Sealed CONSTRUCT, same | `asAST_VERIFY_DANGLING_ID` | `construct-decl` |
| Sealed DECL_REF, same | `asAST_VERIFY_DANGLING_ID` | `declref-decl` |
| Unsealed anything (including CALL-without-callee) | `asAST_VERIFY_UNSEALED_PUBLICATION` | `unsealed-publication` (existing; **must stay first**) |

Do not add a new `asEASTVerifyCategory`. Reuse `DANGLING_ID`. Do not reuse `expr-decl` (that token is dangling-**when-set** inside `asCASTVerify`).

### Implementation shape (after RED)

Keep `asCASTVerify` byte-for-byte on the resolvedDecl-optional path (`:509–512`).

```cpp
int asCASTVerifyPublication(const asCASTContext& context, asSAstVerifyResult& result)
{
	if( !context.IsSealed() )
	{
		return Fail(result, asAST_VERIFY_UNSEALED_PUBLICATION, asCSourceRange(), "unsealed-publication");
	}
	const int required = VerifySealedRequiredTargets(context, result); // static helper, CALL/CONSTRUCT/DECL_REF only
	if( required != asAST_VERIFY_OK )
	{
		return required;
	}
	return asCASTVerify(context, result);
}
```

`VerifySealedRequiredTargets`: for each expr, if kind ∈ {CALL, CONSTRUCT, DECL_REF} and (`!resolvedDecl.IsValid()` or `GetDecl==0`) → Fail with the matching token. **Do not** check callee kind, signature, receiver, args. **Do not** require CLEANUP/MEMBER_REF/ERROR kinds.

Order is load-bearing: unsealed CALL-without-callee must still be `unsealed-publication`, never `call-decl`.

### 4.1 TEST_METHOD — exclusive first RED

`RejectsSealedPublicationCallWithoutResolvedDecl`

Three contexts in **one** method (mirrors `RejectsUnsealedPublication` + positive control):

```cpp
	TEST_METHOD(RejectsSealedPublicationCallWithoutResolvedDecl)
	{
		asCASTContext Missing;
		const asASTDeclId Tu = Missing.CreateTranslationUnit("PubCallMissing");
		const asCQualType IntType = Missing.InternPrimitive(ttInt, 0);
		const asASTDeclId Fn = Missing.CreateDecl(asAST_DECL_FUNCTION, Tu, asCSourceRange(), "F");
		const asASTStmtId Body = Missing.CreateStmt(asAST_STMT_RETURN, Fn, asCSourceRange());
		const asASTExprId Call = Missing.CreateExpr(asAST_EXPR_CALL, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Missing.SetBody(Fn, Body), TEXT("set body")));
		ASSERT_THAT(AreEqual(0, Missing.SetStmtExpr(Body, Call), TEXT("return CALL without callee")));
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Missing, Result),
			TEXT("HARD NO: unsealed asCASTVerify must succeed without CALL resolvedDecl")));
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_UNSEALED_PUBLICATION, asCASTVerifyPublication(Missing, Result),
			TEXT("unsealed publication stays UNSEALED_PUBLICATION, not call-decl")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("unsealed-publication"),
			TEXT("detail token must stay unsealed-publication")));
		ASSERT_THAT(AreEqual(0, Missing.Seal(),
			TEXT("Seal() uses asCASTVerify; ERROR-or-typed CALL without callee must still seal")));
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_DANGLING_ID, asCASTVerifyPublication(Missing, Result),
			TEXT("sealed publication must refuse CALL without resolvedDecl")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("call-decl"), TEXT("detail token must be call-decl")));

		asCASTContext Present;
		const asASTDeclId PTu = Present.CreateTranslationUnit("PubCallPresent");
		const asCQualType PInt = Present.InternPrimitive(ttInt, 0);
		const asASTDeclId Callee = Present.CreateDecl(asAST_DECL_FUNCTION, PTu, asCSourceRange(), "Callee");
		const asASTDeclId PFn = Present.CreateDecl(asAST_DECL_FUNCTION, PTu, asCSourceRange(), "F");
		const asASTStmtId PBody = Present.CreateStmt(asAST_STMT_RETURN, PFn, asCSourceRange());
		const asASTExprId PCall = Present.CreateExpr(asAST_EXPR_CALL, PInt, asAST_VALUE_PRVALUE, asCSourceRange());
		ASSERT_THAT(AreEqual(0, Present.SetBody(PFn, PBody), TEXT("set body")));
		ASSERT_THAT(AreEqual(0, Present.SetStmtExpr(PBody, PCall), TEXT("return CALL")));
		ASSERT_THAT(AreEqual(0, Present.SetResolvedDecl(PCall, Callee), TEXT("publication target present")));
		ASSERT_THAT(AreEqual(0, Present.Seal(), TEXT("CALL with resolvedDecl must seal")));
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerifyPublication(Present, Result),
			TEXT("sealed CALL with a resolving target must publish")));
	}
```

Use `InternPrimitive(ttInt, 0)` so non-ERROR `expr-type` does not fire first. Do **not** use `asAST_EXPR_ERROR` and do **not** switch CALL to ERROR kind (SemaAuthority already locks “keep CALL kind”).

### 4.2 Same bite, same helper (do not split UBT)

```cpp
	TEST_METHOD(RejectsSealedPublicationConstructWithoutResolvedDecl)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("PubCtorMissing");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asASTExprId Construct = Context.CreateExpr(asAST_EXPR_CONSTRUCT, IntType, asAST_VALUE_PRVALUE, asCSourceRange());
		(void)Construct;
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Result),
			TEXT("HARD NO: unsealed CONSTRUCT without resolvedDecl must asCASTVerify")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("Seal must still succeed")));
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_DANGLING_ID, asCASTVerifyPublication(Context, Result),
			TEXT("sealed publication must refuse CONSTRUCT without resolvedDecl")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("construct-decl"), TEXT("detail token must be construct-decl")));
	}

	TEST_METHOD(RejectsSealedPublicationDeclRefWithoutResolvedDecl)
	{
		asCASTContext Context;
		const asASTDeclId Tu = Context.CreateTranslationUnit("PubRefMissing");
		const asCQualType IntType = Context.InternPrimitive(ttInt, 0);
		const asASTExprId Ref = Context.CreateExpr(asAST_EXPR_DECL_REF, IntType, asAST_VALUE_LVALUE, asCSourceRange());
		(void)Ref;
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerify(Context, Result),
			TEXT("HARD NO: unsealed DECL_REF without resolvedDecl must asCASTVerify")));
		ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("Seal must still succeed")));
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_DANGLING_ID, asCASTVerifyPublication(Context, Result),
			TEXT("sealed publication must refuse DECL_REF without resolvedDecl")));
		ASSERT_THAT(IsTrue(Result.detail.Equals("declref-decl"), TEXT("detail token must be declref-decl")));
	}
```

CONSTRUCT/DECL_REF do not re-assert the unsealed-publication token (already locked by `RejectsUnsealedPublication` + the CALL method). They **do** re-assert `asCASTVerify` OK + `Seal()` OK so a mistaken `asCASTVerify` edit goes RED immediately.

### 4.3 Expected RED / GREEN

| Method | First run (tests in, verifier unchanged) | After `asCASTVerifyPublication` helper |
| --- | --- | --- |
| `RejectsSealedPublicationCallWithoutResolvedDecl` | **RED**: `Seal()` then `asCASTVerifyPublication` currently OK (`:544–551` → `asCASTVerify`) | **GREEN**: unsealed `UNSEALED_PUBLICATION`; sealed missing → `call-decl`; present target → OK |
| `RejectsSealedPublicationConstructWithoutResolvedDecl` | **RED** same | **GREEN** `construct-decl` |
| `RejectsSealedPublicationDeclRefWithoutResolvedDecl` | **RED** same | **GREEN** `declref-decl` |
| Existing **17** Verifier methods | stay GREEN | stay GREEN |

Do not implement the helper until the Verifier prefix shows the three new methods RED (not a compile error beyond a missing helper — tests call existing `asCASTVerifyPublication`).

If someone puts the check in `asCASTVerify`, `Seal()` in the CALL method goes non-zero and SemaAuthority unresolved-call `Seal()` tests RED. **Revert that.** Publication helper only.

### 4.4 Companion lock-flip (same UBT, not a second bite)

`UnresolvedCallMissingIsErrorTypeNotInt` (`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:10707–10709`) today:

```cpp
ASSERT_THAT(AreEqual(0, Context.Seal(), TEXT("structurally valid ERROR-typed CALL may Seal via asCASTVerify")));
ASSERT_THAT(AreEqual((int)asAST_VERIFY_OK, asCASTVerifyPublication(Context, Verify),
    TEXT("sealed ERROR-typed CALL is still a legal construction graph; Build publication is diagnostics")));
```

Retarget **only the publication assertion** (keep `asCASTVerify` OK, unsealed `UNSEALED_PUBLICATION`, `Seal()` OK, dump CALL/`type=<unresolved>`/empty callee):

```cpp
ASSERT_THAT(AreEqual((int)asAST_VERIFY_DANGLING_ID, asCASTVerifyPublication(Context, Verify),
    TEXT("sealed publication is the CALL-target gate; ERROR-typed CALL without callee must not publish")));
ASSERT_THAT(IsTrue(Verify.detail.Equals("call-decl"), TEXT("detail token must be call-decl")));
```

`UnresolvedDeclRefMissingIsErrorTypeNotInt` (~10747) only asserts unsealed `asCASTVerify` — leave it. It does not Seal+publish.

Do **not** flip `ParserActOnUnresolvedCallDoesNotDuplicateOnSuccessfulParse` / ambiguous-overload `Seal()` assertions.

### 4.5 Do not in this bite

- `RejectsCallWithoutResolvedDecl` on `asCASTVerify`
- Require CLEANUP `resolvedDecl` (no `RejectsSealedPublicationCleanupWithoutResolvedDecl`)
- Require MEMBER_REF / SEQUENCE / ERROR-kind targets
- Callee kind (`FUNCTION` vs `METHOD` vs `CONSTRUCTOR`), signature, receiver, arg role/order, type compatibility
- Expr parent / expr-multi-owner / expr-cycle / reachability from `stmt.expr` (next remainder, §6)
- `safepoint=` in `asCASTVerify` or publication
- Stmt-level cleanup-plan POD on `asCStmt` / `asCExpr`
- Wire `Generate` to `asCASTVerifyPublication`
- Uncheck or re-check `tasks.md` 13.5
- Full Sema environment / compile-seal dump tests as the oracle (construction APIs are enough)

---

## 5. Already GREEN — do not redo

Verifier **17/17** `wave-b-55-ver`. Do not rewrite, retarget, or re-implement these methods or their tokens.

| TEST_METHOD | Token / contract |
| --- | --- |
| `RejectsContinueSkippedNearerLoop` | `continue-skipped-nearer` (`as_ast_verifier.cpp:322`) |
| `RejectsBreakTargetNotAncestor` | `break-ancestor` |
| `RejectsBreakSkippedNearerLoop` | `break-skipped-nearer` + dangling `stmt-target`/`ctrl-target` |
| `RejectsDuplicateCaseAndDefaultNotLast` | `duplicate-case` + `default-order` |
| `RejectsFallthroughTargetNotNextCase` | `fallthrough-target` |
| `RejectsFallthroughOutsideSwitch` | `fallthrough-switch` |
| `RejectsUnsealedPublication` | `asCASTVerify` OK on unsealed Return+literal; publication `unsealed-publication`; `Seal()` then publication OK |
| `RejectsStmtMultiOwner` | `stmt-multi-owner` |
| `RejectsStmtCycle` | `stmt-cycle` |
| `RejectsCleanupResolvedDeclNotDestructor` | `cleanup-dtor` when set; missing CLEANUP target still not this test |
| `RejectsDanglingWrongKindAndInvalidRange` | TU / foreign child / `decl-kind` |
| `RejectsInvalidSourceRange` | `decl-range` |
| `RejectsStmtIndexMismatch` | `stmt-id` |
| `RejectsExprIndexMismatch` | `expr-id` |
| `RejectsParentChildNotBidirectional` | `decl-parent-child` |
| `RejectsExprMissingExactType` | `expr-type` |
| `RejectsExprOperandWrongKind` | `expr-operand` |

SemaAuthority **239/239** `wave-b-55-sema-g` is a **regression prefix after GREEN**, not this bite’s RED oracle. Only the one lock-flip in §4.4 is in scope.

---

## 6. Remainder after this bite (do not pull in)

Still not 13.5 close:

1. **Expr ownership/cycle/reachability** — `AddExprChild` is unguarded `PushLast` like pre-fix stmts; no expr parent table; arena orphans can Seal. Natural **next** verifier bite after this publication gate.
2. **Resolved signatures** — callee kind, param QualTypes, receiver, reverse-formal arg roles. Needs Sema call-plan facts; not construction-API only.
3. **Error/recovery node prohibition** beyond CALL/CONSTRUCT/DECL_REF missing target (`asAST_EXPR_ERROR` / `asAST_TYPE_ERROR` still publishable if kind is not those three).
4. **`Generate` → `asCASTVerifyPublication`** — today `IsSealed()` only (`as_bytecode_codegen.cpp:3062–3067`). Wiring is a consumer bite; it can RED CodeGen fixtures that Seal unresolved CALL then Generate. Not this UBT.
5. Cleanup-on-transfer / stmt cleanup-plan POD — **forbidden to invent**.
6. `safepoint=` as a verify requirement — **forbidden**.

---

## 7. Later UBT commands (do not run now)

Always from `D:\as-cta`. Always `-NoXGE`. Exclusive UBT. If `UnrealEditor` / `UnrealEditor-Cmd` for **this** project is live, wait. CAEngine `UE4Editor` / `MSBuild` / `link` on the machine is **not** this lock.

```powershell
Set-Location D:\as-cta

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-b-verifier-135-red -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-verifier-135-red -TimeoutMs 600000
```

Expected RED: three new methods fail on sealed `asCASTVerifyPublication` currently returning OK. Existing 17 PASS.

Then implement the publication helper (not `asCASTVerify`). Then:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-b-verifier-135-green -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-b-verifier-135-green -TimeoutMs 600000
```

Expected GREEN: Verifier **20/20**.

Companion lock-flip (same UBT; run after Verifier GREEN, or include the assertion edit in the RED tests so SemaAuthority RED then GREEN with the helper):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-verifier-135-sema -TimeoutMs 600000
```

Expected after helper + lock-flip: SemaAuthority **239/239** (count unchanged; `UnresolvedCallMissingIsErrorTypeNotInt` now expects `call-decl` on sealed publication). If the flip lands before the helper, that one method is the intended SemaAuthority RED.

Do not run All / ProductionCodeGen / Cutover for this bite. Default pipeline stays LEGACY. Do not check 13.5. Do not uncheck 13.5.
