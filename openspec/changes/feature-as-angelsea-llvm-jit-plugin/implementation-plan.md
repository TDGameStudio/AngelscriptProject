# Angelsea LLVM Runtime JIT Plugin Implementation Plan

> Plan-only record. Begin only after the unified coordinator ABI/conformance harness is frozen and a complete external LLVM 21.1.8 Developer SDK is available.

## File Map

| Area | Planned paths | Responsibility |
|---|---|---|
| Plugin descriptor | `Plugins/AngelseaLLVMJIT/AngelseaLLVMJIT.uplugin` | Disabled-by-default Win64 Editor/Development plugin, Runtime/test modules. |
| Runtime module | `Plugins/AngelseaLLVMJIT/Source/AngelseaLLVMJIT/` | Backend factory/session, target setup, host adapter, diagnostics. |
| Direct IR emitter | `Plugins/AngelseaLLVMJIT/Source/AngelseaLLVMJIT/Private/LLVM/` | Snapshot eligibility, LLVM C API IR generation, verifier, ORC materialization and code lease. |
| External SDK module | `Plugins/AngelseaLLVMJIT/Source/ThirdParty/LLVM/LLVM.Build.cs` plus license/provenance files | Exact 21.1.8 SDK probe, includes/import library/DLL staging, no SDK payload. |
| Local configuration | `AgentConfig.ini` template/parser documentation | Optional `Paths.LLVMRoot`; never commit a machine-specific value. |
| Test module | `Plugins/AngelseaLLVMJIT/Source/AngelseaLLVMJITTest/` | SDK failure/success, IR shape/verifier, ORC lifetime, differential and performance tests. |
| Shared fixtures | Reuse the coordinator conformance support under `Plugins/Angelscript/Source/AngelscriptTest/RuntimeJIT/` | Identical VM/MIR/LLVM source/input/expected observation corpus. |
| Evidence | `openspec/changes/feature-as-angelsea-llvm-jit-plugin/benchmarks/` and `llvm-sdk-contract.md` | Machine-readable results and exact SDK capability contract. |

Do not add LLVM headers/libraries to `AngelscriptRuntime`, invoke Clang, link the MIR plugin, or commit LLVM binaries.

## Milestone A: SDK gate and isolated factory

1. Verify coordinator dependency and obtain a complete LLVM 21.1.8 Developer SDK.
2. Add `Paths.LLVMRoot` template/parser support and red/green tests for every required header/library/DLL/export/version/architecture case.
3. Scaffold the disabled plugin and External module; stage/delay-load the exact `LLVM-C.dll` only when enabled.
4. Register a no-codegen `angelsea-llvm` factory/session and pass coordinator registration/two-Engine/teardown tests.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelsea-llvm-probe -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaLLVM.SDK" -Label angelsea-llvm-sdk -TimeoutMs 900000
```

## Milestone B: Constant ORC entry and resource ownership

1. Create/verify a direct constant-return LLVM module through the C API.
2. Validate exact triple/data layout/calling convention and materialize it through ORC LLJIT.
3. Return a VMEntry plus resource-tracker-backed code lease and prove the native marker.
4. Pass verifier/link/unknown-symbol/stale/unpublished/active-reader/session/DLL teardown tests.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaLLVM.ORC" -Label angelsea-llvm-orc -TimeoutMs 900000
```

## Milestone C: Shared scalar/control-flow semantics

1. Implement frame values/conversions, arithmetic/bitwise/shifts/comparisons, guarded division/modulo and branch/loop lowering in TDD-sized opcode families.
2. Avoid LLVM undefined/poison behavior and prove VM equivalence at integer/floating boundaries.
3. Reject objects, native/external/mixin receivers, calls, suspend, Raw/Parms, unknown neutral profiles, and unknown helpers for the complete function before LLVM module creation; do not parse source traits or alter declared parameter zero.
4. Pass EagerSync, EagerBackground, LazyFirstCall, Hot Reload, unload and two-Engine coordinator conformance.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaLLVM" -Label angelsea-llvm-runtime -TimeoutMs 900000
```

## Milestone D: Cross-backend differential and performance report

1. Run the shared corpus in explicit VMOnly and RuntimeOnly/LLVM Engines; add MIR as a separate Engine when its plugin is present.
2. Add representative arithmetic-loop, branch-heavy and conversion workloads.
3. Capture exact LLVM SDK/Engine/CPU/build identity, all policy latencies, steady-state ns/op, code size, memory and tracker/DLL release data into CSV/JSON under `benchmarks/`.
4. Update the SDK contract, Chinese architecture/testing guidance and research decision section; leave the plugin disabled and SDK external.

Final verification:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelsea-llvm-jit -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaLLVM" -Label angelsea-llvm -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.Differential" -Label runtime-jit-differential -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label angelsea-llvm-static-regression -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix angelsea-llvm-native-core -TimeoutMs 900000
```

## Acceptance Gate

- Plugin-disabled builds require no LLVM SDK and retain VM/AOT/MIR behavior.
- Plugin-enabled builds accept only a complete exact LLVM 21.1.8 Developer SDK and produce precise failures otherwise.
- No code path emits C, invokes Clang, consumes typed HIR, uses MIR, or queries live Engine pointers during lowering.
- Every advertised semantic passes VM differential boundary coverage and proves an ORC native hit; unsupported semantics fall back for the whole function.
- ORC trackers, sessions and DLL lifetime pass stale/replacement/active-reader/unload/two-Engine tests under all three policies.
- The comparable performance report is complete and does not alter default enablement, SDK distribution, or Shipping scope.
