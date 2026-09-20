# Handoff: UPROPERTY delegate execute completion

## OpenSpec Handoff

- Scope: coverage-scope
- Target Change: angelscript/feature-delegates-uproperty-execute

## Problem

The archived `test-delegates-uproperty-execute` Change proved dynamic `UPROPERTY` materialization and CallPtr fire, but only seven int/void cases. `Ev.IsBound()`, BindDynamic+Execute return writeback, non-int arguments, unbound `ExecuteIfBound`, `AddDynamic(this, FunctionName)`, convert-and-fire from CallPtr, and SoftReload copy of the pointer slot are still missing. Property bytes are not an `FMulticastScriptDelegate`. `ContainerPtrToValuePtr(Ev)` remains illegal.

## Success

- Sema accepts `Ev.IsBound()` and reads the same CallPtr slot.
- `asCallBoundUFunction` writes back `CPF_ReturnParm` and covers representative `FName` arguments.
- Unbound single-cast `ExecuteIfBound` does not throw `TXT_UNBOUND_FUNCTION`.
- UCLASS methods compile `BindDynamic` / `AddDynamic(this, FunctionName)`.
- C++ builds a temporary native delegate from CallPtr and `ProcessDelegate`s it; it does not fire property bytes.
- SoftReload copies the eight-byte CallPtr for delegate `UPROPERTY`s.
- The `DelegateProperty` representative map is green against the existing seven controls.
- Proving command: `ue.test` `TestPrefix=Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty` `Fast=true`. Observe adjacent Compile prefixes touched by Sema/VM edits.

## Scope

In: convert-and-fire, IsBound Sema, return/non-int writeback, quiet `ExecuteIfBound`, `this` bind, SoftReload copy, representative map.

Out: single-blob or dual native storage; legal `ContainerPtrToValuePtr(Ev)`; Language execute gate; cook/PIE; 60-row `UPROPERTY` execute; changing the ordinary multicast `BlueprintAssignable` reject; redoing DECLARE parse or local CallPtr Execute.

## Constraints

- Harness `ue.*` only; CacheV2 off.
- Do not change CallPtr slot size, tags, or `BindPtr` / `AddPtr` / `RemovePtr` / `ClearPtr` / `ClonePtr`.
- Do not `ProcessDelegate` property bytes.
- Convert-and-fire C++ name is `Naming assumed` at apply.
- Commit only this Change's paths.

## Approach

Feature Change. Script source of truth stays CallPtr. Engine edits Sema, `asCallBoundUFunction`, the convert API, and SoftReload copy. Tests stay on the existing `DelegateProperty` class.

## Alternatives and flip

- Single native blob / dual sync: rejected by Q3-C and Q4-A. Flip: property bytes must accept `ProcessDelegate` directly.
- Language / cook gate: rejected by Q2-A. Flip: those surfaces become the release gate.
- 60-row `UPROPERTY` execute: rejected by Q5-A. Flip: declaration-table regression, not representative execute.

## Failure

- `ProcessDelegate` on `Ev` as `FMulticastScriptDelegate`.
- Unbound `ExecuteIfBound` still sharing the throwing Execute CallPtr path.
- Language fixtures or cook as this Change's green gate.

## Verification

`Invoke-Harness ue.test -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty'; Fast = $true; TimeoutMs = 600000 }`

Observe representative cases RED, then GREEN. Omit Language / cook / PIE because Q2=A.

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Selected scope and vocabulary |
| handoff.md | attachments/drafts/handoff.md | Scope and accepted handoff |
