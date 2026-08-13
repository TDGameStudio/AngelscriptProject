## Why

Static AOT provides reproducible native delivery but requires generating and rebuilding C++, while Editor script iteration returns changed functions to the VM. A separate Angelsea-derived MIR backend can test whether AngelScript bytecode can regain native performance inside the Editor process without coupling MIR or third-party code to the core plugin.

## What Changes

- Add an optional sibling `AngelseaRuntimeJIT` plugin for Win64 Editor/Development, disabled by default and registered under Runtime BackendId `angelsea-mir`.
- Import an audited minimal derivative of Angelsea bytecode-to-C and its pinned MIR/c2mir backend into plugin-owned ThirdParty sources; never compile from `Reference/angelsea`.
- Adapt the backend to the maintained fork's immutable compile snapshot, whole-function VMEntry contract, helper/reference slots, Binding publication, cancellation, and code-lease lifetime.
- Support the shared first-slice scalar/control-flow bytecode subset under `EagerSync`, `EagerBackground`, and `LazyFirstCall`; fall back the complete function to VM for every unsupported opcode or semantic boundary.
- Add plugin-specific correctness, lifecycle, differential, and performance coverage without importing Angelsea's AngelScript, fmt, test, or benchmark dependencies.

## Capabilities

### New Capabilities

- `as-angelsea-runtime-jit-plugin`: An optional Angelsea-derived bytecode-to-C/c2mir/MIR Runtime JIT backend that produces Engine-local Win64 x64 VMEntry machine code under the unified coordinator.

### Modified Capabilities

None.

## Impact

- Adds a planned sibling plugin at `Plugins/AngelseaRuntimeJIT/` with Runtime, test, and ThirdParty modules; it remains a normal plugin directory for the PoC and does not require a Git submodule or remote repository.
- Uses Angelsea commit `1d367d431cdfd7e5e51b2341312078fd40cc10a4` (BSD-2-Clause) and MIR commit `3cb30b39b81b2a8d7348cd4db66f8b219a9ebee0` (MIT) as audited import baselines.
- Depends on `refactor-as-unified-jit-coordinator`; does not modify `SetJITCompiler()`, depend on `AngelseaLLVMJIT`, or replace Legacy/Semantic Static AOT.
- Does not add UObject, UFunction, Blueprint, RPC, GC, Raw/Parms, function-call, suspend, ResumeVM, packaged-game, or Shipping support in the first slice.
