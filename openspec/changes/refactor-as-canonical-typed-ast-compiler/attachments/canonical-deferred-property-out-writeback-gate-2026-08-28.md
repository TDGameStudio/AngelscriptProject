# Canonical deferred property `&out` write-back gate (2026-08-28)

## Result

CTA-S48 closes the first deferred/out lifetime family end to end for the
CANONICAL compiler: a primitive script property passed to an exact `T&out`
formal is now represented by a sealed call-edge plan and is executed by
Canonical Bytecode CodeGen without invoking `asCCompiler`.

The representative source is:

```angelscript
struct FDeferredOutBox
{
    int Value;
}

int Fill(int& out Target)
{
    Target = 41;
    return 1;
}

int Entry()
{
    FDeferredOutBox Box;
    return Fill(Box.Value) + Box.Value;
}
```

`Entry()` executes as `42`, proving both the preserved primary return value
and the deferred property write-back. Its bytecode calls `Fill` once, the exact sealed
`FDeferredOutBox::SetValue(int)` once, and `GetValue` once for the final return
expression only. The out route does not pre-read the property. The module
publisher is `CANONICAL_CODEGEN` and the retained LEGACY compiler invocation
count is zero.

This is a bounded closure, not a claim that all deferred/out lifetimes are
complete. The implemented family is primitive, exact `&out`, generated script
property accessor, direct script/system setter ABI. Non-POD/value-object out,
`&inout`, stored/escaping deferred values, exceptional cleanup, suspend/resume
frames and reference-return aliasing remain fail-closed or open.

## Architecture

### Sema owns the call-edge plan

Ordinary property reads remain a resolved getter `Call`. When overload
conversion sees that this exact argument is being bound to an exact primitive
out-only reference formal, it does not hand the getter call to CodeGen and ask
the backend to rediscover property semantics. Sema instead creates
`asAST_EXPR_DEFERRED_OUT` with:

- the exact formal `T&out` `QualType`;
- `LVALUE` category and the literal `deferred-out`;
- the exact generated setter `DeclId` in `resolvedDecl`;
- an `OpaqueValue` receiver, stored as both the dedicated receiver edge and
  the only child;
- the original receiver expression beneath the opaque node.

The setter is matched from already-sealed accessor metadata: same owner, same
`accessorField`, setter accessor kind, one exact value parameter. It is not
looked up by backend spelling and is not inferred from `GetValue`/`SetValue`
names.

Direct local `T&out` arguments stay ordinary lvalue references. Only the
property route becomes deferred.

### Verification is the publication firewall

Before Seal, `asCASTVerify` requires all of the following:

- primitive, reference, out-only type and `LVALUE` category;
- exactly one child equal to the receiver edge;
- an `OpaqueValue` receiver with exactly one source child;
- a method declaration with setter accessor kind and a valid sealed field;
- exactly one setter value parameter whose canonical type equals the deferred
  value type;
- a receiver type matching the setter owner.

The permanent SemaAuthority test also replaces the setter edge with the global
`Fill` declaration and proves verification fails with
`asAST_VERIFY_WRONG_KIND` and stable detail token `deferred-out-setter`. It
then restores the exact edge and proves the graph is sealable. The dump now
prints `kind=DeferredOut`, `setter=<stable key>` and `receiver=<ExprId>` so the
complete backend permission is inspectable without HIR or a semantic dump
transport.

### CodeGen consumes, but does not infer

While evaluating call arguments in the AST's reverse-formal order, CodeGen:

1. validates the sealed formal against the Runtime ABI and verifies that the
   Runtime direction is exactly `asTM_OUTREF`;
2. allocates one primitive temporary used as the actual by-reference argument;
3. evaluates `DeferredOut.receiver` once through `EmitLValueAddress` and keeps
   that pointer slot alive across the call;
4. invokes the primary callee using the ordinary reference ABI;
5. preserves any primary return value before another call can overwrite the
   VM return registers;
6. pushes the temporary value plus the captured receiver and calls the exact
   setter obtained from `DeferredOut.resolvedDecl`.

Multiple plans retain the same reverse-formal order used by the maintained
LEGACY compiler's `AfterFunctionCall` deferred-parameter collection. The new
route does not read `asCScriptNode`, invoke `asCCompiler`, parse property names
or use HIR/dump as transport.

Reference-return aliasing is deliberately rejected when a deferred-out plan is
present. Supporting that family requires an explicit lifetime/alias contract;
silently saving an unproven reference before setter write-back would not be a
safe closure.

## TDD and diagnostic trail

### Sema RED and GREEN

- Clean source RED, getter call still supplied to `Fill`:
  `Saved/Tests/cta-s48-deferred-out-red/20260828_113811_566_99dc3700/RunMetadata.json`
  — **0/1**, AST showed `Fill(GetValue(Box))`.
- First implementation build:
  `Saved/Build/cta-s48-deferred-out-sema/20260828_114349_615_f1ddc589/RunMetadata.json`
  — PASS.
- Verifier diagnostic run:
  `Saved/Tests/cta-s48-deferred-out-verify-detail/20260828_114922_693_a9daec8d/RunMetadata.json`
  — expected failure detail `deferred-out-receiver` exposed the Context setter
  contract described below.
- Corrected Context build:
  `Saved/Build/cta-s48-deferred-out-context-corrected/20260828_115201_537_0693733f/RunMetadata.json`
  — PASS.
- First positive Sema GREEN:
  `Saved/Tests/cta-s48-deferred-out-sema-green/20260828_115214_903_84f13a63/RunMetadata.json`
  — **1/1 PASS**.
- Final positive plus forged-setter firewall:
  `Saved/Tests/cta-s48-deferred-out-verifier-green/20260828_122625_234_4a883b59/RunMetadata.json`
  — **1/1 PASS**.

### CodeGen RED and GREEN

- Clean production RED:
  `Saved/Tests/cta-s48-deferred-out-codegen-red/20260828_115826_065_2829e3e1/RunMetadata.json`
  — **0/1** with `unsupported expression ... kind=23
  literal=deferred-out`; no LEGACY fallback occurred.
- CodeGen implementation build:
  `Saved/Build/cta-s48-deferred-out-codegen-impl/20260828_120748_540_9e21ee6e/RunMetadata.json`
  — PASS.
- Final test/build after retention and module-local type lookup correction:
  `Saved/Build/cta-s48-deferred-out-module-typeinfo/20260828_121909_632_fc3b3db5/RunMetadata.json`
  — PASS.
- Focused execution GREEN:
  `Saved/Tests/cta-s48-deferred-out-codegen-green-3/20260828_121926_361_19cd52ee/RunMetadata.json`
  — **1/1 PASS**.
- Direct local out regression:
  `Saved/Tests/cta-s48-direct-out-regression/20260828_122033_206_6820675a/RunMetadata.json`
  — **1/1 PASS**.
- Final dump/verifier build:
  `Saved/Build/cta-s48-deferred-out-verifier-dump/20260828_122439_681_eecf9ea1/RunMetadata.json`
  — PASS.
- Complete ProductionCodeGen class:
  `Saved/Build/cta-s48-return-preservation-build/20260828_123700_270_5070c927/RunMetadata.json`
  and
  `Saved/Tests/cta-s48-production-codegen-return-class/20260828_123717_588_701e024c/RunMetadata.json`
  — build PASS and **113/113 PASS**, including a non-void primary return that
  remains `1` across the setter call.
- Complete SemaAuthority class:
  `Saved/Tests/cta-s48-sema-authority-class/20260828_122907_997_78646914/RunMetadata.json`
  — **391/391 PASS**.

## Problems found and their disposition

### `SetExprReceiver` admitted only calls

The first implementation created the correct opaque receiver but the generic
AST Context setter rejected the new expression kind. The first patch also
briefly changed `SetExprCallDispatch` instead of the adjacent receiver setter.
The correction restores call-dispatch to CALL-only and explicitly admits
receiver edges on CALL or DEFERRED_OUT. The verifier then passed with the exact
single-evaluation receiver.

### A successful Build normally released the internal AST

The first post-CodeGen test run compiled successfully and then failed because
the test attempted to read `GetCanonicalASTContext()` without selecting
`asAST_RETAIN_SNAPSHOT`. This is correct module-lifetime behavior, not a
compiler failure. The production test now creates the module explicitly,
selects retention before `Build()`, and inspects the same sealed input consumed
by CodeGen.

Evidence:
`Saved/Tests/cta-s48-deferred-out-codegen-green/20260828_120812_083_e0aac002/RunMetadata.json`
— **0/1**, null retained context.

### Script-local type lookup must use the module

The retained graph was present on the next run, but
`ScriptEngine->GetTypeInfoByName("FDeferredOutBox")` returned null for this
module-local script type. The test now uses `Module->GetTypeInfoByName`, which
finds the generated getter/setter Runtime shells and permits exact bytecode
call-count assertions.

Evidence:
`Saved/Tests/cta-s48-deferred-out-codegen-green-2/20260828_121359_300_a0675920/RunMetadata.json`
— **0/1**, null getter fixture lookup.

### One non-unique test patch produced invalid build evidence

While correcting retention, a non-unique patch hunk changed an earlier integer
return test's `Module` declaration and caused a C++ const-reference mismatch.
It was immediately restored and is not counted as product RED evidence.

- Invalid harness build:
  `Saved/Build/cta-s48-deferred-out-test-retention/20260828_121200_727_0159229d/RunMetadata.json`
- Corrected build:
  `Saved/Build/cta-s48-deferred-out-test-retention-corrected/20260828_121341_785_5bdda5c7/RunMetadata.json`

## Remaining work

CTA-S48 advances Tasks 5.7, 5.8, 9.5 and 13.2 but does not complete any of
those umbrella tasks. The next deferred/lifetime closures are:

1. non-POD/value-object `&out` construction, destruction and ownership;
2. property `&inout`, including the required pre-read and exact write-back;
3. reference-return aliasing across deferred writes;
4. exception and suspend/resume behavior while a deferred value/receiver is
   live;
5. globals/import slots and direct Canonical-AST AOT consumption of the same
   plan.

Mechanical task progress remains **88/125 (70.4%)**. The weighted whole-change
estimate is now **about 78%**; action-only Sema authority remains about **98%**,
Canonical Bytecode/Runtime closure is about **74%**, direct Canonical-AST AOT
about **55%**, and safe default readiness about **50%**. LEGACY remains the
default, the native AngelScript AST remains intentionally retained, and HIR
remains physically deleted.
