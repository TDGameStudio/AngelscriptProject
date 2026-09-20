# Approve the UPROPERTY execute coverage Change

## Context

The archived delegates Change left `UPROPERTY` execute unowned. Four later NativeEngine cases are green. The user asked for a Change to add more coverage.

## Evidence

Isolated host rejected `UPROPERTY FOnHealth Ev` as `void` until delegate types were seeded. Run `c74cfc56c01045c3bdb81e8eb068ecd3` then passed 4/4. Script slots are pointer-sized; `FMulticastInlineDelegateProperty` is not. Provenance: draft log R1.

## Options

Q1: test Change vs overlay feature vs overlay-only.
Q2: NativeEngine only vs Language execute vs cook/PIE.
Q3: land four cases only vs thicken three cases vs 60-macro matrix.

## Settled Decision

Q1=A, Q2=A, Q3=B. Identity: `angelscript/test-delegates-uproperty-execute`. Land the four green cases and host seeding. Add `PropertyIsBoundClearRemove`, `ScriptBindUFunctionFires`, and `DynamicMulticastOneParamFires`. Overlay storage is a later Change.

## Consequences

Implementation stays on `DelegatePropertyTests.cpp` and `SeedHostScriptDelegateTypes`. Native fire keeps using a local `FMulticastScriptDelegate` plus the published signature.

## Flip Condition

If script Bind/Broadcast and native `ProcessDelegate` must share one `FMulticastScriptDelegate` blob, stop this test Change and open `angelscript/feature-delegates-property-storage`.

## Sources

[Design](../drafts/design.md), [handoff](../drafts/handoff.md), [current-coverage](../drafts/findings/current-coverage.md). Provenance: draft log R1.
