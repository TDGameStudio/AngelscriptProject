## Why

AS-defined `USTRUCT` values can enter Unreal-owned value buffers through delegate/event argument marshalling. That path currently reaches `FASStructOps::Construct` through Unreal `UScriptStruct` lifecycle callbacks.

Investigation found two related runtime problems. The immediate crash is caused by a UE 5.8 fake-vtable callback ABI mismatch: Unreal calls struct ops callbacks as `Construct(void* Address)` and similar signatures, while the current AS callbacks expect an extra leading `FASStructOps*` argument. The destination buffer is therefore misinterpreted as the ops pointer. The same path also needs to construct the AngelScript object shell before AS constructor execution.

This surfaced while expanding delegate hot reload coverage: a delegate taking an AS `USTRUCT` parameter crashes during the first invocation, before reload assertions can run.

## What Changes

- Add a focused regression test for executing a delegate whose signature includes an AS-defined `USTRUCT` value parameter.
- Fix `UASStruct` value lifecycle so Unreal `UScriptStruct` callbacks can recover the owning AS struct ops under the UE 5.8 fake-vtable ABI.
- Construct the AngelScript object shell before executing AS constructor logic.
- Keep the fix at the runtime struct lifecycle layer so delegate/event marshalling, property initialization, and other UE value-buffer paths share the same behavior.
- Document the crash cause and new regression-test expectation in the unit-test guidance.

## Capabilities

### New Capabilities

- `as-script-struct-value-lifecycle`: AS-defined `USTRUCT` values are safely constructed, copied, invoked, and destroyed when Unreal owns their storage.

### Modified Capabilities

- None.

## Impact

- Runtime: `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASStruct.cpp`.
- Tests: standalone delegate/runtime regression under `Plugins/Angelscript/Source/AngelscriptTest/`.
- Related coverage: existing hot reload delegate parameter tests continue to exercise AS struct delegate signatures after reload.
- Docs: `Documents/UnitTest/UnitTest.md`.
