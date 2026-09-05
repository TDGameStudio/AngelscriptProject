---
review_schema: review-v2
review_kind: external
requested_by: user
state: closed
assigned_at: 2026-09-05T19:43:35.9446829+08:00
snapshot_ref: Saved/Harness/Reviews/builder-20260905-194219/snapshot.zip
snapshot_sha256: 89babe822b45e852df8b3858d0c27c7253c011c2ef00f8b4e6f1b797d09a32b1
reviewed_at: 2026-09-05T19:52:04.4134425+08:00
closed_at: 2026-09-05T21:04:23.1488285+08:00
verdict: APPROVE
---

# Parser and Sema correctness

Assigned by the coordinator for the user's explicit current-code review. Read only the materialized read-only tree at D:/Workspace/AngelscriptProject/Saved/Harness/Reviews/builder-20260905-194219/tree, verified against the hash-bound ZIP. Do not follow subsequent live source changes.

Scope is the current reconstructed NativeEngine implementation and its requirement/test evidence, including completed access/conversion work. Existing pending host-callable, call-context, old-AST and namespace-cutover outcomes are not presumed complete. No UE execution, source/planning edits, automatic replan, Git commit or archive is part of this assignment.

## Review basis

This review read the assigned access, conversion, body, declaration, control-flow and lambda tests before tracing the affected Sema paths. The frozen `tasks.md`, attachment index and maintained-language coverage inventory were used to distinguish demonstrated baseline behavior from pending tasks 4.4/4.5 and later integration/cutover work. The retained compiler was consulted only as a semantics reference within the same immutable tree.

Every source path and line below refers to the materialized snapshot named above, not the current live implementation. For brevity, `frontend/` below means `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/`; `tests/` means `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/`. The coordinator supplied the verified snapshot digest and the prior 535/539-case task evidence. This reviewer did not rebuild or execute UE, Automation or the retained runtime. Reproducers below are unexecuted source-derived cases, with their predicted result justified by explicit control flow; they are not reported as observed runtime failures.

## Finding SEM-1 — Mutable receivers cannot select an ordinary const/non-const overload pair

- Severity: Required
- Status: resolved
- File/line: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema_postfix.cpp:480`; selection at the same file:216.
- Observation: `ActOnMemberCall` removes mutable methods when the receiver is readonly, but supplies both const and non-const candidates for a mutable receiver. `ResolveCall` scores only explicit arguments and sets ambiguity on equal scores. It receives no receiver information with which to apply the maintained const preference.
- Impact: An otherwise valid ordinary overload pair makes calls on mutable objects fail with `unresolved-member-call:Read`. This also affects the analogous `opIndex` route at `frontend/as_frontend_sema_postfix.cpp:603`. It is independent of frozen-host callable support and execution-context propagation.

Source-derived reproducer:

```angelscript
class Item {
    int Read();
    int Read() const;
}
int F(Item Obj) {
    return Obj.Read();
}
```

Both zero-argument candidates have score zero. The second candidate sets `bAmbiguous` at line 217, line 219 returns null, and the member-call route produces a recovery expression. The declaration/signature model already distinguishes const methods; `tests/Bodies/BodyConversionTests.cpp` explicitly proves such a pair for conversion functions. The maintained compiler applies `FilterConst(funcs)` after best-cost selection at `source/as_compiler.cpp:3069`, with its implementation at line 18802. The new conversion selector and foreach selector likewise implement a mutable-receiver preference.

Existing test gap: `tests/Bodies/BodySemanticTests.cpp:640` tests different argument-type member overloads, line 654 tests a mutable-only method on a const receiver, and line 665 tests a const-only method. None places the ordinary const/non-const pair in the same candidate set.

Resolution condition: A mutable receiver selects the non-const member among equally ranked applicable overloads; a const receiver selects the const member. Cover ordinary member calls and `opIndex`, while preserving genuine argument ambiguity and readonly rejection. Confirm the selected real declaration in the typed result.

## Finding SEM-2 — Conditional expressions erase handle qualifiers before their consumer checks the result

- Severity: Required
- Status: resolved
- File/line: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp:657`.
- Observation: `ActOnConditional` compares and chooses bare `asCType*` values, then initializes the result with `SetExpressionSemantics`. That operation stores no handle/reference qualifiers. The branches retain their handle types, but the newly created conditional expression becomes a value of the unqualified nominal type.
- Impact: A valid conditional choosing between handles cannot be returned or passed to a handle parameter. Inferred locals can also receive the wrong value-versus-handle type. This is a typed-expression composition defect in the current frontend, unrelated to VM execution.

Source-derived reproducer:

```angelscript
class Item {}
Item@ F(bool Pick, Item@ A, Item@ B) {
    return Pick ? A : B;
}
```

The two branches resolve to the same nominal `Item` type, so lines 647–654 perform no conversion. Line 657 creates a conditional whose `GetExpressionQualType().IsHandle()` is false. `ActOnReturn` then invokes `ConvertTo` against `Item@`; `frontend/as_frontend_sema_postfix.cpp:63` rejects the differing handle bits after finding no user conversion. This yields `incompatible-return-value` for the source above. The distinction between the bare setter and `SetExpressionQualType` is explicit in `frontend/as_stmt.h:59`. The retained maintained conditional implementation preserves handle semantics and handles const qualification at `source/as_compiler.cpp:10655` and handle branch selection at line 10689.

Existing test gap: `tests/Bodies/BodySemanticTests.cpp:316` proves right association and typing only for integer branches. The handle tests beginning at line 830 cover direct contextual null returns, not a handle-valued conditional used by another expression.

Resolution condition: Compute and retain the conditional's full qualified result type and appropriate value category. The reproducer must analyze and verify successfully, with an actual handle-valued conditional. Add mutable/const handle branch controls so const widening succeeds and const removal remains rejected. Inspect the analogous bare-type result assignment at `frontend/as_frontend_sema.cpp:628` when repairing the shared expression-result invariant; this review's concrete failure claim is the conditional case above.

## Finding SEM-3 — Foreach conversion admission disagrees with verification about handle constness

- Severity: Required
- Status: resolved
- File/line: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema_statements.cpp:49`; corresponding verification at `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_ast_verifier.cpp:432`.
- Observation: Foreach uses its own `StatementCanInitialize` predicate. Its same-type fast path ignores constness, while the verifier's `ControlCanInitialize` demands exactly equal qualifiers through `ControlSameType`. The only verifier fallback is a numeric conversion. These predicates therefore disagree in both directions for mutable/const handles.
- Impact: Valid readonly iteration over mutable handles passes body analysis and then fails AST verification. Conversely, an explicitly mutable element declared for a const-handle producer passes body analysis and can resolve mutable method calls, although the verifier subsequently rejects it. No claim is made that the latter can publish a frozen invalid image: verification catches that direction.

Source-derived valid reproducer:

```angelscript
class Item {}
class Range {
    int opForBegin() const;
    bool opForEnd(int I) const;
    void opForNext(int I) const;
    Item@ opForValue(int I) const;
}
void F(Range Items) {
    foreach (const Item@ Value : Items) {}
}
```

`CreateVariable` at `frontend/as_frontend_sema_statements.cpp:420` resolves the declared `const Item@`; line 429 accepts it because the producer and target have equal handle bits and nominal type. At verification, `ControlValueType` preserves constness, `ControlSameType` at `frontend/as_frontend_ast_verifier.cpp:325` rejects the qualifier difference, and the fallback at line 433 rejects handles. The foreach therefore fails with `foreach statement has incomplete authored or protocol semantics` at line 1269. Ordinary `ConvertTo` accepts this safe const addition (`frontend/as_frontend_sema_postfix.cpp:65`) and rejects its unsafe inverse at line 67.

The inverse negative control changes the producer to `const Item@ opForValue(int I) const` and the iteration variable to `Item@ Value`. It should be rejected during semantic conversion admission, not first discovered by structural verification. These are the existing tested `opFor*` and explicit-variable syntaxes with only handle constness changed.

Existing test gap: `tests/Bodies/BodyControlFlowTests.cpp:161` uses integer element/key results; line 183 checks incomplete protocols and an incorrect end type; line 197 uses a nominal value result for lifetime checks. No handle-qualification conversion is exercised.

Resolution condition: Make foreach's conversion admission and typed representation agree with the maintained ordinary conversion rules, and validate that same contract. The valid const-addition case must pass both analysis and verification; the const-removal case must fail analysis with a conversion diagnostic. Include equivalent key-variable coverage because `CreateVariable` serves both element and key.

## Verdict and verification story

Original: CHANGES_REQUIRED with three open Required findings.

Coordinator closure 2026-09-05T21:04:23.1488285+08:00: SEM-1/2/3 resolved by task 8.3. Mutable receivers prefer the non-const equal-rank member and opIndex; conditionals retain handle qualifiers via SetExpressionQualType; foreach const-addition analyzes and verifies while const-removal fails during analysis. Evidence: NativeEngine `59f6cb38656845afb018ed7291108382`, 559/559, SHA-256 3656C5809F065A509DC84AADCAD54615453ABB8CEF302D2296FE53D7C7DFF9B0. Mapped BodiesPostfix.MutableReceiverPrefersNonConstOverloadOfEqualRank, MutableReceiverPrefersNonConstIndexOverloadOfEqualRank, BodiesCore.ConditionalBetweenHandlesKeepsHandleQualifiers, BodiesControlFlow.ForeachHandleConstAdditionAnalyzesAndVerifies and ForeachHandleConstRemovalFailsDuringAnalysis. Verdict is now APPROVE.
