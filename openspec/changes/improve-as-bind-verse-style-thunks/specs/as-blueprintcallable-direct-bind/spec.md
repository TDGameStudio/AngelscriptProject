## ADDED Requirements

### Requirement: Cross-module generated bindings use Verse-style frame wrapper thunks

Cross-module UHT-generated direct bindings SHALL use a versioned call-frame ABI between AngelscriptRuntime and target-module generated code. The target-module wrapper owns C++ argument extraction, native function invocation, and return writeback. AngelscriptRuntime SHALL only construct the frame from `asIScriptGeneric`, resolve the object receiver, and invoke the generated wrapper.

#### Scenario: Runtime public ABI exposes a call-frame payload

- **WHEN** AngelscriptRuntime exposes the cross-module ABI
- **THEN** it declares `FAngelscriptCrossModuleCallFrame`
- **AND** `FAngelscriptCrossModuleEntry::Thunk` takes `UObject* Self` and `FAngelscriptCrossModuleCallFrame* Frame`
- **AND** the ABI is guarded by `LayoutVersionExpected` and `static_assert(sizeof(...))`

#### Scenario: Generated target-module shard uses frame wrapper thunks

- **WHEN** UHT emits `AS_FunctionTable_<Module>_CrossModule_*.cpp`
- **THEN** each generated thunk takes `UObject* Self, FCrossModuleCallFrame* Frame`
- **AND** it reads explicit arguments through `Frame->ArgSlots`
- **AND** it writes non-void return values through `Frame->ReturnSlot`
- **AND** it does not include AngelScript SDK or AngelscriptRuntime headers

#### Scenario: Runtime generic hook is frame-only

- **WHEN** AS calls a cross-module direct-bound function
- **THEN** the generic hook builds a call frame with `ArgSlots`, `ArgCount`, `ReturnSlot`, and `ScriptSelf`
- **AND** it invokes the generated wrapper with the frame
- **AND** it does not expose `void** Args, void* Ret` as the cross-module thunk signature

### Requirement: Verse-aligned frame-wrapper diagnostics preserve fallback semantics

The generated diagnostics SHALL identify whether each unsupported cross-module candidate is blocked by a missing protocol rather than by an unresolved C++ symbol.

#### Scenario: Complex parameter forms are explicitly deferred

- **WHEN** a supported-module UFunction has WorldContext, out/ref parameters, ref return, static arrays, containers, or implicit script receiver projection
- **THEN** it remains on the fallback/stub path
- **AND** the skipped reason identifies the missing protocol family

#### Scenario: RPC and Net functions are not direct-bound

- **WHEN** a UFunction has `FUNC_Net`, `FUNC_NetServer`, `FUNC_NetClient`, or `FUNC_NetMulticast`
- **THEN** it is classified as `rpc-net-function`
- **AND** no frame-wrapper direct thunk is emitted for it

