# Angelsea MIR Runtime JIT Plugin Implementation Plan

> Plan-only record. Begin only after the unified coordinator ABI and fake-backend conformance harness are implemented and frozen.

## File Map

| Area | Planned paths | Responsibility |
|---|---|---|
| Plugin descriptor | `Plugins/AngelseaRuntimeJIT/AngelseaRuntimeJIT.uplugin` | Disabled-by-default Win64 Editor/Development plugin, Runtime/test modules. |
| Runtime module | `Plugins/AngelseaRuntimeJIT/Source/AngelseaRuntimeJIT/` | Backend factory/session, host adapter, diagnostics registration. |
| Backend core | `Plugins/AngelseaRuntimeJIT/Source/AngelseaRuntimeJIT/Private/Backend/` | Snapshot scanner, BytecodeToC, c2mir/MIR compile integration, code lease. |
| Angelsea-derived import | `Plugins/AngelseaRuntimeJIT/Source/ThirdParty/AngelseaDerived/` | Audited source subset, BSD-2-Clause notice, pinned provenance and patch inventory. |
| MIR import | `Plugins/AngelseaRuntimeJIT/Source/ThirdParty/MIR/` | Minimal c2mir/MIR Win64 x64 sources, MIT notice, External module/build rules. |
| Test module | `Plugins/AngelseaRuntimeJIT/Source/AngelseaRuntimeJITTest/` | Plugin automation, differential fixtures, lifecycle and performance tests. |
| Shared fixtures | Reuse the coordinator conformance support under `Plugins/Angelscript/Source/AngelscriptTest/RuntimeJIT/` | Identical VM/MIR/LLVM source/input/expected observation corpus. |
| Evidence | `openspec/changes/feature-as-angelsea-runtime-jit-plugin/benchmarks/` and `third-party-provenance.md` | Machine-readable results and source/license manifest; never put logs in `tasks.md`. |

Do not add plugin source to the main `Plugins/Angelscript` submodule and do not compile any file through `Reference/angelsea`.

## Milestone A: Isolated build and factory

1. Verify coordinator dependency and pinned reference commits.
2. Scaffold the disabled plugin and test module.
3. Import only the reviewed source set and prove minimal MIR/c2mir compilation.
4. Register a no-codegen `angelsea-mir` factory/session and pass coordinator registration, policy plumbing, two-Engine and teardown tests.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelsea-mir-probe -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaMIR.Registration" -Label angelsea-mir-registration -TimeoutMs 900000
```

## Milestone B: Neutral scalar C emitter

1. Add eligibility tests and stable unsupported reason/offsets, including direct conformance rejection for native-object, external-parameter-alias, mixin, and unknown neutral receiver profiles before C emission.
2. Port decoding/BytecodeToC to the immutable snapshot and neutral helper ABI.
3. Implement values/frame/conversions, arithmetic/bitwise/shifts/comparisons, guarded division/modulo, and structured control flow in small TDD batches.
4. Reject every object/receiver/call/suspend/Raw/Parms/unknown semantic before c2mir without parsing source traits, erasing declared parameter zero, or fabricating native `this`.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaMIR.Lowering" -Label angelsea-mir-lowering -TimeoutMs 900000
```

## Milestone C: Native code and lifecycle

1. Compile a constant-return fixture through c2mir/MIR and prove the native marker.
2. Add the closed helper symbol table and FScriptExecution VMEntry trampoline.
3. Implement one disposable MIR context/code arena per successful function revision, retain it through the code lease, and add exact allocation/release counters.
4. Pass success/failure/stale/cancel/replacement/active-reader/unload/two-Engine lifetime tests.
5. Pass EagerSync, EagerBackground and LazyFirstCall conformance.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaMIR" -Label angelsea-mir-runtime -TimeoutMs 900000
```

## Milestone D: Differential and performance report

1. Run the complete shared scalar/control-flow corpus in explicit VMOnly and RuntimeOnly/MIR Engines.
2. Add representative arithmetic-loop, branch-heavy and conversion workloads.
3. Capture build/Engine/CPU identity, all policy latencies, steady-state ns/op, code size, memory and release data into CSV/JSON under `benchmarks/`.
4. Update provenance, Chinese architecture/testing guidance and the research decision section; leave the plugin disabled regardless of the result.

Final verification:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelsea-runtime-jit -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.AngelseaMIR" -Label angelsea-mir -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.Differential" -Label runtime-jit-differential -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label angelsea-mir-static-regression -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix angelsea-mir-native-core -TimeoutMs 900000
```

## Acceptance Gate

- Plugin-disabled builds contain no MIR dependency and retain VM/AOT behavior.
- Provenance/licenses identify every imported file and no build input points into `Reference/`.
- Every advertised opcode/type/control-flow case passes VM differential boundary coverage and proves a MIR native hit.
- Every unsupported semantic falls back for the complete function with a stable reason.
- All three policies, Hot Reload staleness, active execution, unload and two-Engine isolation pass with exact resource release.
- The performance report includes compile/first-call/steady-state/code-size/memory data and does not change product defaults.
