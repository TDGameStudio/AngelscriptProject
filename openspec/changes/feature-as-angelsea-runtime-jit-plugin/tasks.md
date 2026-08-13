## 1. Confirm The Coordinator And Third-Party Baselines

- [ ] 1.1 <!-- Non-TDD --> Record the implemented `refactor-as-unified-jit-coordinator` ABI revision/commit and prove its fake-backend EagerSync/EagerBackground/LazyFirstCall conformance prefix passes before plugin work.
- [ ] 1.2 <!-- Non-TDD --> Verify `Reference/angelsea` is at `1d367d431cdfd7e5e51b2341312078fd40cc10a4` and its MIR submodule at `3cb30b39b81b2a8d7348cd4db66f8b219a9ebee0`; record source-file, license, and local-patch manifests.
- [ ] 1.3 <!-- Non-TDD --> Review Angelsea/MIR licenses and exclude bundled AngelScript, fmt, Catch2, nanobench, examples, tools, tests, unused target backends, and any `Reference/` build path.

## 2. Scaffold The Optional Plugin And MIR Build Probe

- [ ] 2.1 <!-- Non-TDD --> Create disabled-by-default `Plugins/AngelseaRuntimeJIT/AngelseaRuntimeJIT.uplugin` restricted to Win64 Editor/Development with Runtime and test modules.
- [ ] 2.2 <!-- Non-TDD --> Import the audited Angelsea-derived and MIR/c2mir source subset into plugin-owned ThirdParty directories with complete notices/provenance.
- [ ] 2.3 <!-- TDD --> Add a ThirdParty build smoke test/automation probe that compiles the minimal MIR/c2mir sources without upstream AngelScript or fmt.
- [ ] 2.4 <!-- Non-TDD --> Configure required MIR feature definitions and Win64 x64 allocator/codegen sources; document every excluded feature and compiler warning adaptation.
- [ ] 2.5 <!-- Non-TDD --> Prove the main project still builds with the plugin disabled and does not compile/link MIR.

## 3. Register An Engine-Local Backend Session

- [ ] 3.1 <!-- TDD --> Add registration tests for BackendId `angelsea-mir`, current coordinator ABI, Win64 Editor/Development capability, duplicate rejection, and no direct `SetJITCompiler()` call.
- [ ] 3.2 <!-- TDD --> Implement the factory and one MIR session per AngelScript Engine, advertising serialized compile concurrency and creating one disposable MIR context/code arena per accepted function revision.
- [ ] 3.3 <!-- TDD --> Add two-Engine tests proving MIR contexts, queues, helper symbols, code leases, cancellation, and teardown are isolated.
- [ ] 3.4 <!-- TDD --> Add plugin unload/session teardown tests before the backend returns any real native code.

## 4. Port Snapshot Support Scanning And Neutral C Emission

- [ ] 4.1 <!-- TDD --> Add snapshot eligibility tests for the exact shared scalar types, frame operations, normalized receiver/function profile, conversions, opcode families, control flow, Entry ABI, and unsupported reason/offset taxonomy; non-None/unknown receivers, including external-parameter-alias with retained parameter zero, reject before C emission.
- [ ] 4.2 <!-- TDD --> Port Angelsea bytecode decoding/BytecodeToC to consume only immutable coordinator snapshot data and a versioned neutral scalar helper ABI.
- [ ] 4.3 <!-- TDD --> Implement bool/integer/float/double constants, parameters, locals, loads/stores, returns, and numeric conversions with VM differential tests.
- [ ] 4.4 <!-- TDD --> Implement arithmetic, bitwise, comparison, boolean, and shift emission with signed/unsigned/boundary VM differential tests.
- [ ] 4.5 <!-- TDD --> Implement divide/modulo guards and maintained-fork exception reporting for zero and signed overflow cases.
- [ ] 4.6 <!-- TDD --> Implement branches, loops, break/continue, and control-flow target validation with termination/result differential tests.
- [ ] 4.7 <!-- TDD --> Add complete-function rejection tests for objects, handles, references, native-object/external-parameter/mixin receivers, strings, containers, delegates, calls, suspend/cleanup, Raw/Parms, unknown function-profile values, and unknown opcodes; prove no source/trait parsing or extra native-this slot.

## 5. Compile C Through c2mir/MIR And Own Native Code

- [ ] 5.1 <!-- TDD --> Add a constant-return native-hit test, then compile emitted C through c2mir/MIR into one Win64 x64 VMEntry.
- [ ] 5.2 <!-- TDD --> Add the closed external-symbol allowlist and prove unknown symbols fail without arbitrary process lookup.
- [ ] 5.3 <!-- TDD --> Implement the VMEntry/FScriptExecution host trampoline and scalar exception/helper table without UE headers in the backend core.
- [ ] 5.4 <!-- TDD --> Implement per-result MIR context/code-arena and executable allocation ownership in the code lease, reviewed write/execute transitions, instruction-cache flushing, and exact resource counters.
- [ ] 5.5 <!-- TDD --> Prove unpublished, compile-failed, unsupported, cancelled, stale, replaced, and normally retired results release MIR resources exactly once.
- [ ] 5.6 <!-- TDD --> Prove active execution remains callable while a replacement Binding/plugin retirement waits for its lease.

## 6. Pass Every Coordinator Policy And Lifecycle Case

- [ ] 6.1 <!-- TDD --> Pass EagerSync conformance for success, unsupported, backend failure, and resource release.
- [ ] 6.2 <!-- TDD --> Pass EagerBackground conformance with serialized session queues, VM while compiling, safe publication, cancellation, and Hot Reload staleness.
- [ ] 6.3 <!-- TDD --> Pass LazyFirstCall conformance with one compile request, VM for current first calls, and MIR Native for later calls.
- [ ] 6.4 <!-- TDD --> Pass debugger/coverage suppression, module discard, Engine shutdown, plugin unload, and two-Engine coordinator conformance.

## 7. Complete Differential Coverage And Performance Evidence

- [ ] 7.1 <!-- TDD --> Run the shared VM/MIR scalar/control-flow corpus across boundary values and require matching return, exception, and declared scalar observations with native-hit markers.
- [ ] 7.2 <!-- TDD --> Add regression fixtures for every imported/upstream opcode assumption changed to match the maintained fork.
- [ ] 7.3 <!-- TDD --> Add benchmark kernels with branches/loops/arithmetic and record compile latency, first/second-call policy latency, steady-state ns/op, code size, session memory, and release counts.
- [ ] 7.4 <!-- Non-TDD --> Record benchmark/environment data under this change without changing default enablement or claiming Shipping readiness.
- [ ] 7.5 <!-- Non-TDD --> Build through `Tools\RunBuild.ps1`, run MIR/RuntimeJIT/StaticJIT/NativeCore prefixes, and update Chinese documentation/provenance before English plugin guidance.
