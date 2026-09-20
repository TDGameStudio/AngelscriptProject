# Handoff: UPROPERTY delegate execute coverage

## OpenSpec Handoff

- Scope: uproperty-execute
- Target Change: angelscript/test-delegates-uproperty-execute

## Problem

The archived `feature-delegates-ue-interop` Change proved DECLARE and CallPtr, but `FOnHealth Ev` was not a `UPROPERTY`. Four later `DelegateProperty` cases are green and host seeding is written; neither is in a Change. The script slot is a pointer, so native `ProcessDelegate` on the property bytes is unsafe.

## Success

- `SeedHostScriptDelegateTypes` lets an isolated host materialize dynamic delegates as `FDelegateProperty` / `FMulticastInlineDelegateProperty`.
- The four landed cases stay green: multicast Broadcast 100/75, single-cast Execute Result=42, native ProcessDelegate through the published signature, dynamic BlueprintAssignable flags.
- New green cases: `PropertyIsBoundClearRemove`, `ScriptBindUFunctionFires`, `DynamicMulticastOneParamFires`.
- Proving command: `ue.test` `TestPrefix=Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty` `Fast=true`.

## Evidence

- [current-coverage.md](findings/current-coverage.md)
- Run `c74cfc56c01045c3bdb81e8eb068ecd3` 4/4
- [glossary.md](glossary.md)

## Scope

In: land the green tests and host seeding; thicken IsBound/Clear/Remove, script BindUFunction, and OneParam multicast `UPROPERTY`.

Out: property-storage overlay; Language execute; cook / PIE; a 60-macro matrix; changing the ordinary multicast BlueprintAssignable reject.

## Constraints

- Harness `ue.*` only; CacheV2 off; no Language-folder execute surface.
- Do not `ProcessDelegate` on `FMulticastInlineDelegateProperty` bytes.
- Commit only this Change's paths.

## Approach

Test Change. Product work is host TypeDatabase seeding only. New cases stay on the existing `DelegateProperty` class.

## Alternatives and flip

- Do overlay in this Change: rejected by R1 Q1. Flip: script slot and `FMulticastScriptDelegate` must share one blob; open `angelscript/feature-delegates-property-storage`.
- Language / cook proof: rejected by R1 Q2. Flip: user asks for Language execute or cooked load.
- 60-row matrix: rejected by R1 Q3. Flip: declaration-table regression, not one extra family.

## Failure

- `ContainerPtrToValuePtr` + `ProcessDelegate` on the property bytes.
- Folding overlay product work into this test Change.
- Using Language fixtures or a full cook as this Change's green gate.

## Verification

`Invoke-Harness ue.test -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty'; Fast = $true; TimeoutMs = 600000 }`

Observe the three new cases RED, then GREEN the prefix. Omit Language / cook / PIE because R1 Q2.

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted scoped design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| glossary.md | attachments/drafts/glossary.md | Settled Change and test names |
| ../../findings/current-coverage.md | attachments/drafts/findings/current-coverage.md | What already passed and the layout gap |
| ../../log.md#r1 | attachments/talks/talk-20260918-171800-coverage-boundary.md | R1 Q1–Q3 product, surface, thickness |
