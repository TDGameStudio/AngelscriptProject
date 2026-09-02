# CTA-S107 `auto` deduction and production range-for gate

Date: 2026-08-30

## Scope and conclusion

CTA-S107 closes the production UE range-for failure caused by Canonical Sema
committing the parser placeholder `auto` instead of the exact initializer
type.  The fix does not read dynamic runtime `TypeId`, persist an
`asCDataType`, or add a new HIR representation.  It seals the declaration with
the pointer-free canonical `asASTQualType` already owned by the initializer
expression.

The representative range-for test is green and the staged whole-Engine run
reduces Sema diagnostics from **39 to 29**.  All occurrences of
`Proceed`, `GetKey`, `GetValue` and `SetValue` disappear from the remaining
unresolved-callee inventory.

## Actual production lowering

The UE preprocessor does not send the ordinary source range-for construct into
the maintained fork's separate stock `foreach` protocol.  It lowers range-for
to ordinary declarations and calls resembling:

```angelscript
for (auto _Iterator = Range.Iterator(); _Iterator.CanProceed; )
{
    __auto_constref_type auto Element = _Iterator.Proceed();
}
```

The exact initializer expressions already had the correct canonical types
(`FAutoIterator` and `FAutoElement`).  The information was lost while the
declaration action committed `auto`, so later member resolution received the
placeholder rather than an exact nominal owner.

## Implemented typed intent

- Global and local `auto` declarations infer from an exact, non-error,
  non-wildcard initializer expression.
- The first successful declarator refreshes the shared declaration-group type,
  preserving the maintained legacy rule for declarations such as
  `auto A = 1, B = 2.0`.
- `auto&`, `const auto`, handle intent and the preprocessor's transient
  `__auto_constref_type` marker are consumed before the declaration is sealed.
- Reference intent comes from the declaration syntax/marker and is not guessed
  from the initializer value category.
- The verifier rejects any sealed declaration whose exact stable type key is
  still `auto` (`decl-auto-placeholder`).
- Dependency recording uses the committed exact type rather than the parser
  placeholder.

No native pointer, runtime object address or dynamic TypeId is stored in the
canonical graph by this closure.

## TDD and whole-Engine evidence

- Initial focused RED build:
  `Saved/Build/cta-s107-local-auto-inference-red-build/20260830_225410_664_61c57150`.
- Initial focused RED:
  `Saved/Tests/cta-s107-local-auto-inference-red/20260830_225438_358_44a04c96`
  — **1/1 FAIL**; declarations remained `auto` and
  `Proceed/GetValue/Consume` were unresolved.
- Exact nominal inference build:
  `Saved/Build/cta-s107-local-auto-inference-green-build/20260830_225928_909_3d1888f7`.
- First focused nominal GREEN:
  `Saved/Tests/cta-s107-local-auto-inference-green/20260830_225944_492_4a93d741`
  — **1/1 PASS**.
- First whole-Engine run after nominal inference:
  `Saved/Tests/cta-s107-whole-engine-after-local-auto-inference/20260830_230033_791_81a231aa`
  — Sema diagnostics **39 -> 29**, unresolved-callee **18 -> 8**.
- Qualifier-intent RED build:
  `Saved/Build/cta-s107-auto-constref-red-build/20260830_230255_941_fe292c3f`.
- Qualifier-intent RED:
  `Saved/Tests/cta-s107-auto-constref-red/20260830_230323_217_80608763`
  — **1/1 FAIL** because the inferred element did not yet retain const/ref
  intent.
- Full typed-intent build:
  `Saved/Build/cta-s107-auto-intent-green-build/20260830_230808_900_7bfe5bee`.
- Full focused GREEN:
  `Saved/Tests/cta-s107-auto-intent-green/20260830_230844_389_e994ba48`
  — **1/1 PASS**, including exact `FAutoElement const&`.
- Final staged whole-Engine run:
  `Saved/Tests/cta-s107-whole-engine-after-auto-intent/20260830_230928_898_4b098535`
  — the same 29-diagnostic inventory as the first post-inference run, proving
  the qualifier closure introduced no diagnostic regression.

Final Sema inventory:

```text
11 ambiguous-overload
 8 unresolved-callee
 6 unresolved-identifier
 2 native-function-canonical-identity-invalid
 1 generated-accessor-copy-constructor-unavailable
 1 global-init-not-constant
-----------------------------------------------
29 total
```

The remaining unresolved callees are:

```text
AddUFunction  3
Add           1
ApplyFormat   1
CreateWidget  1
Execute       1
NewObject     1
```

## Remaining independent roots

1. The three `AddUFunction` cases are not function-name/delegate-reference
   failures. The `FName` arguments are already correct; the missing receiver
   properties are inherited native fields. CTA-S108 closes this root together
   with `Tags.Add` and records the corrected analysis separately.
2. Template nominal conversion does not yet prove
   `TSubclassOf<UExampleWidget> -> TSubclassOf<UUserWidget>`, blocking
   `CreateWidget`.
3. Delegate invocation still has an `Execute` resolution/native canonical
   identity closure.
4. `ApplyFormat`, `Tags.Add`, `NewObject` and the remaining overload inventory
   require separate provenance/ranking fixes; they are no longer range-for
   placeholder cascades.
5. Downstream CodeGen/lifetime gates are now visible: dangling construct
   relation, interface-dispatch graph identity, generated accessor width,
   string-literal construction and materialized `FString` lvalue receivers.

## Known representation follow-ups

- The current single canonical const qualifier bit cannot fully distinguish a
  top-level-const handle slot from a handle-to-const object.  Full auto-handle
  const parity needs an explicit representation decision; it is not required
  by the current Array/Map range-for closure.
- The maintained fork's separate stock `foreach` parser consumes the marker in
  a different protocol path.  UE production range-for is fixed because it uses
  the preprocessor lowering above, but stock `foreach` should receive its own
  focused parity test before that path is claimed complete.
