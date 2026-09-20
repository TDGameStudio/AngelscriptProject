## Why

The archived Change `angelscript/feature-delegates-ue-interop` proved `DECLARE_*` admission and script CallPtr execute. It did not prove a dynamic delegate stored as a real `UPROPERTY`. Isolated-host `CompileModules` then rejected `UPROPERTY FOnHealth Ev` as `void` because `Bind_Delegates` returns on `IsHostTarget` and never installs `ScriptDelegateType` / `ScriptMulticastDelegateType`. Four `DelegateProperty` cases and `SeedHostScriptDelegateTypes` were written after archive and are not in a Change.

Native `ProcessDelegate` on `FMulticastInlineDelegateProperty` bytes is unsafe: the script slot is pointer-sized, while the property claims `sizeof(FMulticastScriptDelegate)`. Overlay storage is a later feature Change, not this one.

## What Changes

- Seed `FScriptDelegateType` and `FMulticastScriptDelegateType` on every isolated host that already seeds `ScriptObjectType`, so ClassGen `CanCreateProperty` succeeds for dynamic `DECLARE_*` members.
- Land NativeEngine `Compile.DelegateProperty` with the four already-written cases: multicast Broadcast 100/75, single-cast Execute Result=42 through a void `UFUNCTION`, native `ProcessDelegate` on a local `FMulticastScriptDelegate` driven by the published signature, and dynamic `UPROPERTY(BlueprintAssignable)` flags.
- Thicken the same class with `PropertyIsBoundClearRemove`, `ScriptBindUFunctionFires`, and `DynamicMulticastOneParamFires`. Bound state after Clear/Remove is observed through Broadcast side effects because `Ev.IsBound()` is not a Sema callable operation.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/bindings/delegates`: an isolated host materializes dynamic `UPROPERTY` members as `FDelegateProperty` / `FMulticastInlineDelegateProperty` after TypeDatabase seeding.
- `angelscript/runtime/delegates`: script AddDynamic / BindDynamic / BindUFunction / Broadcast / Execute / Clear / Remove run through the CallPtr slot of those `UPROPERTY` members.

## Impact

`AngelscriptEngine.cpp` gains `SeedHostScriptDelegateTypes` next to the existing `SeedHostScriptObjectType` calls. Tests live only in `DelegatePropertyTests.cpp`. No overlay of `FMulticastScriptDelegate` onto property bytes. No Language-folder execute, full cook, or PIE gate. `DelegateReflection.OrdinaryBlueprintAssignableRejected` stays the ordinary-multicast reject control and is not this Change's proving prefix.

## Boundaries

- Do not `ProcessDelegate` through `ContainerPtrToValuePtr` on `FMulticastInlineDelegateProperty` bytes.
- Do not fold property-storage overlay into this Change. That later Change is `angelscript/feature-delegates-property-storage`.
- Do not treat Language admission, cook, or PIE as green.
- Do not add a 60-row `DECLARE_*` matrix or change the ordinary BlueprintAssignable reject.
- BindDynamic + Execute retval writeback stays out: the single-cast proof is a void `UFUNCTION` side effect on a `UPROPERTY` int.
