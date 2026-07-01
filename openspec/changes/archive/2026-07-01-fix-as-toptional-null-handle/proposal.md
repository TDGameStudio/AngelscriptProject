## Why

Script-side `TOptional<T>` can crash when `T` is a UObject-derived handle and the value expression comes from a native binding that exposes a nullable C++ pointer return as an AngelScript reference, such as `UObject&`. Direct `TOptional<UObject>(nullptr)` and ordinary pure-AS null handles are already safe, but the native reference ABI can pass a null source address into optional storage.

## What Changes

- Add AngelScript regression coverage for ordinary pure-AS null handles and a test-only native binding that reproduces the nullable-pointer-as-reference path.
- Fix `TOptional<T>` value-copy handling for nullable object handle subtypes so a null handle stores as a set optional with a null inner value.
- Preserve current optional semantics: `IsSet()` means the value slot has been populated, even if the stored object handle is null.

## Capabilities

### New Capabilities
- `script-toptional-null-handle`: Defines expected behavior for `TOptional<T>` when `T` is a nullable script object handle.

### Modified Capabilities

## Impact

- Affected runtime binding: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.*`.
- Affected tests: `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptOptionalBindingsTests.cpp`.
- No new dependencies, public configuration, or breaking API changes.
