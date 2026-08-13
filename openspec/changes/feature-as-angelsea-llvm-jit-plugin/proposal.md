## Why

The MIR PoC answers whether a lightweight bytecode-to-C runtime compiler is useful, but it cannot show the optimization ceiling or integration cost of a direct SSA backend. A separate LLVM ORC plugin provides an independent bytecode-to-native path while sharing the same coordinator, eligibility contract, fixtures, and VM oracle.

## What Changes

- Add an optional sibling `AngelseaLLVMJIT` plugin for Win64 Editor/Development, disabled by default and registered under Runtime BackendId `angelsea-llvm`.
- Lower the coordinator's immutable AngelScript bytecode snapshot directly to LLVM IR, verify it, and compile it through LLVM ORC LLJIT; do not pass through C, Clang, MIR, or typed semantic HIR.
- Use the LLVM C API/ORC boundary against one externally configured LLVM 21.1.8 Developer SDK and keep LLVM C++ ABI details out of UE modules.
- Implement Engine-local ORC sessions and revision-scoped resource trackers so stale compilation, module replacement, Engine shutdown, and plugin unload release executable code safely.
- Support the same first-slice scalar/control-flow subset and all three compile policies as the MIR backend, with whole-function VM fallback and shared differential/performance reporting.

## Capabilities

### New Capabilities

- `as-angelsea-llvm-jit-plugin`: An optional direct bytecode-to-LLVM-IR/ORC Runtime JIT backend that produces Engine-local Win64 x64 VMEntry machine code under the unified coordinator.

### Modified Capabilities

None.

## Impact

- Adds a planned sibling plugin at `Plugins/AngelseaLLVMJIT/` with Runtime, test, and LLVM SDK contract modules; it remains a normal plugin directory for the PoC and does not require a Git submodule or remote repository.
- Adds optional machine configuration `Paths.LLVMRoot`; the main plugin, VM, Static AOT, and MIR plugin remain independent of it.
- Pins the first supported SDK to LLVM 21.1.8 with Core/Analysis/Target/ORC C headers, `LLVM-C.lib`, and `LLVM-C.dll`. Missing SDK data is ignored while the plugin is disabled and is a precise build error when the plugin is enabled.
- Depends on `refactor-as-unified-jit-coordinator`; does not depend on `AngelseaRuntimeJIT`, reuse typed semantic HIR, or assume Unreal Engine ships linkable LLVM libraries.
- Does not add UObject, UFunction, Blueprint, RPC, GC, Raw/Parms, function-call, suspend, ResumeVM, packaged-game, or Shipping support in the first slice.
