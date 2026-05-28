# Proposal - improve-as-bind-verse-style-thunks

## Why

The current cross-module direct-bind path solved the unexported-symbol boundary by emitting thunks into the target module and registering a POD table through `IModularFeatures`. That matches one important Verse property, but its thunk ABI is still a narrow raw form:

```cpp
void (*Thunk)(UObject* Self, void** Args, void* Ret)
```

This keeps AS Runtime responsible for understanding generic-call argument slots, and it makes follow-up support for out/ref parameters, hidden context, implicit receiver projection, and future container protocols harder to reason about.

Verse's useful pattern is not "direct bind every UFunction"; it is:

- UHT emits native wrapper code in the function's owning module.
- The wrapper owns C++ parameter construction and native function invocation.
- A central runtime hook stores/discovers thunk tables but does not need to link target modules.

We should align the AS generated bind path with that shape.

## What Changes

- Replace the cross-module thunk ABI with a versioned call-frame ABI.
- Keep target-module UHT generated wrappers as the owner of C++ argument extraction, call expression generation, return writeback, and future out/ref writeback.
- Keep `IModularFeatures` as the plugin-side central rendezvous point because we cannot add a CoreUObject API like Verse's `RegisterVerseCallableThunks`.
- Keep the current safe direct-bind set enabled, but emit it through frame-wrapper thunks.
- Preserve RPC/Net fallback behavior.

## Non-Goals

- Do not modify UE Engine, CoreUObject, or built-in UHT CodeGen.
- Do not add target-module dependencies on `AngelscriptRuntime`.
- Do not enable RPC/Net direct bind.
- Do not default-enable `TArray` / `TSet` / `TMap` / static-array direct bind in this change.
- Do not rewrite manual `Bind_*.cpp` bindings.

