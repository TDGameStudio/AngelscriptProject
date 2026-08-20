## Why

The current Runtime JIT host is a C++ factory/session/coordinator stack that is hard to extend and harder to operate: one BackendId per Engine, `Reconfigure` wipes compiled code, fork callbacks do not surface a host event stream, and MIR versus LLVM cannot stay warm together for switch or comparison. Unreal already has an object model for plugin subclasses; Runtime JIT should use it for discovery while keeping Engine-local sessions, leases, and a single `asIJITCompiler`.

## What Changes

- Add abstract `UAngelscriptRuntimeJIT` plus a subsystem-owned catalog of loaded subclasses (Mass-style discovery).
- Split **warm set** (backends that compile and retain code) from **dispatch backend** (the one Binding attached to a function).
- Allow two or more Runtime backends in one Engine: compile both, switch dispatch at a safe point without cancelling the other, and run an explicit compare pass.
- Replace generation-wide “selection change = cancel everything” with separate update generations for script revision, warm-set membership, and dispatch.
- Add a game-thread host event stream derived from existing fork callbacks (`OnFunctionReady` / `OnJITEntry` / `ReleaseFunctionBinding`) plus safe-point publication. Do not add extra virtuals to `asIJITCompiler` in this change.
- Keep snapshot/session/code-lease contracts. Lowering cores stay host-neutral.
- Give each backend a stable **name** (BackendId) and a display name. `UAngelscriptSettings` gains an INI `RuntimeJITName` field; if that name is registered and available, the primary Engine uses it as dispatch (and auto-warms it). Missing names do not fail startup.
- Do **not** merge the MIR/LLVM worktree plugins in this change; they become later adapters of `UAngelscriptRuntimeJIT`.

## Capabilities

### New Capabilities

- `as-runtime-jit-uobject-host`: UObject catalog of Runtime JIT backends owned by `UAngelscriptSubsystem`, used only to discover backends and create Engine-local sessions.
- `as-runtime-jit-multi-backend`: Warm set, dispatch switch, and in-process compare of two or more Runtime backends without dual-issuing one call.
- `as-runtime-jit-host-lifecycle`: Host events and update generations for script reload, backend enable/disable, dispatch switch, and plugin unload.
- `as-runtime-jit-function-handle`: Owning, copyable handle for one compiled Runtime function revision; Binding, switch, compare, and events use handles rather than raw `VMEntry` pointers.

### Modified Capabilities

- `as-runtime-jit-backend`: Authoritative factory discovery becomes the UObject catalog. Session/snapshot/lease contracts remain. `IModularFeatures` is a migration shim then removed from the coordinator lookup path.
- `as-unified-jit-coordinator`: Coordinator still remains the sole `asIJITCompiler`. It owns one session/state machine per warm backend, and publishes only the dispatch backend’s Binding.
- `static-jit-diagnostics`: Report warm set, dispatch BackendId, per-backend compile state, and compare rows in addition to the current single Runtime BackendId fields.

## Impact

- `UAngelscriptSubsystem`, `UAngelscriptRuntimeJIT`, `UAngelscriptSettings` (`RuntimeJITName` / `RuntimeJITWarmNames`), `FAngelscriptJITCoordinator`, `FAngelscriptRuntimeJITRequestStateMachine`.
- Public ABI in `JIT/AngelscriptRuntimeJITBackend.h` (session/snapshot unchanged; host catalog is additional).
- Existing RuntimeJIT coordinator/state tests, later MIR/LLVM plugins.
- Does not change Static AOT Provider ABI, Cache V2, BytecodeJIT/TypedASTJIT, or VM semantics.
