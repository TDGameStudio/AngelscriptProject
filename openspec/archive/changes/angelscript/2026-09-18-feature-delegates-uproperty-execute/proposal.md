## Why

Isolated-host `UPROPERTY` dynamic delegates already compile, seed `FDelegateProperty` / `FMulticastInlineDelegateProperty`, and fire through the pointer-sized CallPtr slot. That is not a complete execute surface. `Ev.IsBound()` is not a Sema operation, `BindDynamic(this, FunctionName)` fails as `unresolved-reference:this`, `ExecuteIfBound` shares the throwing `CallPtr` path, `asCallBoundUFunction` skips `CPF_ReturnParm` and writes only `FIntProperty`, SoftReload `CopyCompleteValue` can memcpy a native delegate blob over an 8-byte slot, and native fire still has no convert-from-CallPtr helper. The archived test Change left those holes as later work. This Change closes them on CallPtr without overlaying native `FMulticastScriptDelegate` on property bytes.

## What Changes

Product work stays in `Plugins/Angelscript`. NativeEngine `Compile.DelegateProperty` remains the proving prefix. The seven landed methods stay controls.

- Sema admits `IsBound()` on a CallPtr delegate member and returns the slot bound state.
- Parser/Sema treat `this` in `BindDynamic` / `AddDynamic` as the current script object, not `ActOnDeclReference("this")`.
- `ExecuteIfBound` stays quiet when the CallPtr slot is unbound; unbound `Execute` still throws.
- `asCallBoundUFunction` writes `CPF_ReturnParm` and dword-sized values including `FName`.
- `FAngelscriptDelegateOperations::ProcessCallPtr` builds a temporary native multicast from the CallPtr slot and fires it. Property bytes are never `ProcessDelegate` targets.
- SoftReload copies only the CallPtr slot for script delegate properties so a neighbor `int` stays intact and a later Broadcast still fires.

## Capabilities

### New Capabilities

- None. This Change extends the existing delegate capabilities.

### Modified Capabilities

- `angelscript/bindings/delegates`: isolated-host adapters stay required; native fire is convert-and-fire, not property-byte overlay.
- `angelscript/runtime/delegates`: CallPtr `UPROPERTY` execute now includes `IsBound`, `this`, quiet `ExecuteIfBound`, UFUNCTION writeback, convert-and-fire, and CallPtr-sized SoftReload copy.

## Impact

- Submodule `Plugins/Angelscript`: `AngelscriptRuntime` Sema postfix, parser bare-target `this`, `as_context.cpp` `asCallBoundUFunction`, `Bind_Delegates.h` convert helper, `AngelscriptClassGenerator_SoftReload.cpp` `CopyValue`. `AngelscriptTest` `NativeEngine/Compile/DelegatePropertyTests.cpp` thickens the representative map.
- Parent repository: OpenSpec change records and the two delta specs only.
- User entry point: none. Proof is NativeEngine `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty` with CacheV2 off.
- Out of scope: Language-folder execute, cook, PIE, CacheV2, property-byte overlay, `feature-delegates-property-storage`, a 60-row `UPROPERTY` execute matrix.
