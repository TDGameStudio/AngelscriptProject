# Design - Verse-style AS UHT thunks

## Context

Verse registers generated thunks by emitting wrapper code in the owning module and registering a small thunk table through an engine-provided rendezvous API. AS cannot use Verse's CoreUObject API, but the existing `IModularFeatures` path gives us the same boundary:

- target module owns generated native wrapper code
- AS Runtime discovers a POD table centrally
- neither side links in the opposite direction

The current AS cross-module ABI still exposes `void** Args` and `void* Ret` directly at the cross-module boundary. That is enough for the first safe subset, but it is the wrong extension point for richer UFunction parameter forms.

## Chosen Shape

Use a versioned frame ABI:

```cpp
struct FAngelscriptCrossModuleCallFrame
{
	void** ArgSlots;
	uint16 ArgCount;
	uint16 Reserved0;
	void* ReturnSlot;
	UObject* ScriptSelf;
	UObject* WorldContext;
	uint32 Flags;
	uint32 Reserved1;
};

struct FAngelscriptCrossModuleEntry
{
	const TCHAR* ClassName;
	const TCHAR* FunctionName;
	void (*Thunk)(UObject* Self, FAngelscriptCrossModuleCallFrame* Frame);
	uint16 ArgCount;
	uint16 RetSize;
	uint32 Flags;
};
```

The runtime generic hook builds the call frame from `asIScriptGeneric`. Generated target-module wrapper thunks read from the frame and call the native C++ function. The frame fields reserve room for future `WorldContext`, implicit script receiver, and copy-back protocols without changing the central generic hook again.

## Gate Policy

- Phase 1 keeps the current automatic safe set behavior and changes only the thunk ABI/shape.
- Complex parameters remain diagnosed and deferred unless the implementation can prove native-compatible slot/writeback behavior with tests. Interface and delegate payloads are also deferred because they need explicit frame projection/copy semantics rather than raw slot forwarding.
- RPC/Net remains excluded because direct native calls bypass UE RPC routing.
- `ScriptMethod` and `ScriptMixin` remain diagnosed as implicit receiver projections, not automatically enabled.
