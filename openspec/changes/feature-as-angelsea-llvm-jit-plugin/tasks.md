## 1. Confirm Coordinator And LLVM SDK Preconditions

- [ ] 1.1 <!-- Non-TDD --> Record the implemented `refactor-as-unified-jit-coordinator` ABI revision/commit and prove its fake-backend three-policy conformance prefix passes before plugin work.
- [ ] 1.2 <!-- Non-TDD --> Obtain/configure one complete LLVM 21.1.8 Win64 x64 Developer SDK; do not treat the current header-trimmed Scoop installation or UE toolchain as sufficient.
- [ ] 1.3 <!-- TDD --> Add SDK-probe tests for exact version/architecture, Core/Analysis/Target/ORC C headers, `LLVM-C.lib`, `LLVM-C.dll`, required ORC exports, missing path/components, and plugin-disabled behavior.
- [ ] 1.4 <!-- Non-TDD --> Add optional `Paths.LLVMRoot` to the local config template/documentation without committing a machine path or SDK binary.

## 2. Scaffold The Optional Plugin And LLVM Runtime Boundary

- [ ] 2.1 <!-- Non-TDD --> Create disabled-by-default `Plugins/AngelseaLLVMJIT/AngelseaLLVMJIT.uplugin` restricted to Win64 Editor/Development with Runtime and test modules.
- [ ] 2.2 <!-- Non-TDD --> Create an External LLVM module that consumes only the validated SDK C headers/import library, stages/delay-loads `LLVM-C.dll`, and preserves LLVM license/provenance.
- [ ] 2.3 <!-- TDD --> Add module startup tests for SDK/DLL version, required exports, DLL load/unload, and precise failure diagnostics.
- [ ] 2.4 <!-- Non-TDD --> Prove the main project builds with the plugin disabled and performs no LLVM SDK probe/link/stage step.

## 3. Register An Engine-Local ORC Backend Session

- [ ] 3.1 <!-- TDD --> Add registration tests for BackendId `angelsea-llvm`, current coordinator ABI, Win64 Editor/Development capability, duplicate rejection, and no direct `SetJITCompiler()` call.
- [ ] 3.2 <!-- TDD --> Implement one LLVM C API/ORC LLJIT session per AngelScript Engine with serialized compilation capability.
- [ ] 3.3 <!-- TDD --> Add target triple, pointer width, data layout, VMEntry calling-convention, and version mismatch tests before code generation.
- [ ] 3.4 <!-- TDD --> Add two-Engine tests proving LLJIT contexts, dylibs, symbol tables, resource trackers, cancellation, and teardown are isolated.

## 4. Establish Direct Bytecode-To-LLVM IR Codegen

- [ ] 4.1 <!-- TDD --> Add a constant-return IR shape/verifier test and lower one snapshot directly through LLVM C API without C, Clang, MIR, typed HIR, or live Engine pointers.
- [ ] 4.2 <!-- TDD --> Add the closed scalar helper symbol allowlist and prove unknown symbols fail without unrestricted process-symbol lookup.
- [ ] 4.3 <!-- TDD --> Implement bool/integer/float/double parameters, results, locals, constants, loads/stores, returns, and explicit conversions with VM differential tests.
- [ ] 4.4 <!-- TDD --> Implement arithmetic, bitwise, comparison, boolean, and shift IR while avoiding LLVM undefined/poison behavior; cover signed/unsigned boundaries.
- [ ] 4.5 <!-- TDD --> Implement divide/modulo guards and maintained-fork exception reporting for zero and signed overflow cases.
- [ ] 4.6 <!-- TDD --> Implement branches, loops, break/continue, SSA/phi or explicit frame lowering, and control-flow verification with termination/result tests.
- [ ] 4.7 <!-- TDD --> Add complete-function rejection tests for objects, handles, references, native-object/external-parameter/mixin receivers, strings, containers, delegates, calls, suspend/cleanup, Raw/Parms, unknown function-profile values, unknown opcodes, and required host symbols outside the ABI; prove no source/trait parsing or extra native-this slot.

## 5. Compile Through ORC And Own Executable Resources

- [ ] 5.1 <!-- TDD --> Add LLVM verifier, target/data-layout validation, ThreadSafeModule transfer, LLJIT materialization, VMEntry lookup, and native-hit marker coverage.
- [ ] 5.2 <!-- TDD --> Implement per-function/module-revision ORC resource trackers retained by coordinator code leases.
- [ ] 5.3 <!-- TDD --> Prove IR verification failure, materialization/link failure, unsupported, cancelled, stale, replaced, and unpublished results remove their ORC resources exactly once.
- [ ] 5.4 <!-- TDD --> Prove active execution retains the LLJIT session/resource tracker/DLL while replacement or plugin retirement waits for the code lease.
- [ ] 5.5 <!-- TDD --> Prove backend/session/plugin teardown removes all symbol/resource trackers without affecting another Engine session.

## 6. Pass Every Coordinator Policy And Lifecycle Case

- [ ] 6.1 <!-- TDD --> Pass EagerSync conformance for success, unsupported, verifier/backend failure, and resource release.
- [ ] 6.2 <!-- TDD --> Pass EagerBackground conformance with serialized session work, VM while compiling, safe publication, cancellation, and Hot Reload staleness.
- [ ] 6.3 <!-- TDD --> Pass LazyFirstCall conformance with one compile request, VM for current first calls, and ORC Native for later calls.
- [ ] 6.4 <!-- TDD --> Pass debugger/coverage suppression, module discard, Engine shutdown, DLL/plugin unload, and two-Engine coordinator conformance.

## 7. Complete Differential Coverage And Performance Evidence

- [ ] 7.1 <!-- TDD --> Run the shared VM/LLVM scalar/control-flow corpus across boundary values and require matching return, exception, and declared scalar observations with ORC native-hit markers.
- [ ] 7.2 <!-- TDD --> When MIR is available, run separate explicit VM/MIR/LLVM Engines and distinguish semantic mismatches from backend-specific unsupported cases without a fallback chain.
- [ ] 7.3 <!-- TDD --> Add benchmark kernels and record SDK/Engine/build identity, compile latency, first/second-call policy latency, steady-state ns/op, code size, session memory, and tracker/DLL release counts.
- [ ] 7.4 <!-- Non-TDD --> Record benchmark/environment data under this change without committing the SDK/DLL, enabling the plugin by default, or claiming distribution/Shipping readiness.
- [ ] 7.5 <!-- Non-TDD --> Build through `Tools\RunBuild.ps1`, run LLVM/RuntimeJIT/StaticJIT/NativeCore prefixes, and update Chinese SDK/architecture/testing guidance before English plugin guidance.
