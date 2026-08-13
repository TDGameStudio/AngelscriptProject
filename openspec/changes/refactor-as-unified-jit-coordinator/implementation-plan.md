# Unified Static/Runtime JIT Architecture Implementation Plan

> Implementation was explicitly authorized on 2026-08-13. Work proceeds in the current main checkout as required by the repository instructions, preserves unrelated work, and records the exact pre-implementation status rather than resetting it. Every behavior task uses TDD and project-owned build/test entry points.

The architecture review baseline is parent `e0766f3fea75cd73179a4232407ef5d8f532f8e0` with `Plugins/Angelscript` at `3d6f231ab0d902e14a4fe944cf2ea9c1191711e7`; that plugin commit contains the multi-provider artifact foundation. The plugin submodule was clean during the 2026-08-13 plan review, while the parent contained unrelated and OpenSpec work. Re-check both repositories when implementation actually begins; this baseline is evidence, not permission to overwrite later changes.

Implementation began from parent `58e860ee52eb113f5115dbd4d0adcd2dea33d37f` and plugin `3d6f231ab0d902e14a4fe944cf2ea9c1191711e7`, both with clean working trees. The parent already records that plugin gitlink. Prerequisite evidence in `3d6f231` includes complete immutable Binding publication (`AngelscriptJITBindingPublicationTests`), stable reference slots and Engine-local resolution (`AngelscriptJITReferenceSlotTests`), deterministic multi-provider registration and generation replacement (`AngelscriptJITMultiProviderTests`), immutable direct-set validation (`AngelscriptJITImmutableArtifactSetTests`), and Runtime-owned Provider code-image leases (`AngelscriptJITProviderLifetime`). This satisfies the implementation dependency gate without depending on later project scaffolding or Live Coding work.

## Dependency And Workspace Gate

Before each milestone:

- inspect parent and plugin `git status --short` and the path-scoped diff;
- preserve the active `refactor-as-static-jit-multi-provider` implementation, especially Provider ABI revision 2, stable references/routes, immutable Binding readers, and generated-file layout;
- never regenerate or delete user-owned generated artifacts except through the existing maintained workflow;
- treat `FAngelscriptJITGeneration` and Provider registry/router as established shared infrastructure, not scaffolding to replace.

Record the exact prerequisite plugin commit and dirty paths when a milestone begins. A milestone may land on the dirty baseline only when its path-scoped diff is independently reviewable and its focused tests pass.

## File Map

| Area | Planned paths | Responsibility |
|---|---|---|
| Bytecode backend | `Source/AngelscriptRuntime/StaticJIT/BytecodeJIT/AngelscriptBytecodeJIT.{h,cpp}` plus moved bytecode/context implementation files | Current bytecode analysis, opcode/bind/reference lowering, task-wide analysis, and emitted C++ body/entries. |
| Static backend core | `Source/AngelscriptRuntime/StaticJIT/Backends/AngelscriptStaticJITBackend.h` and `StaticJIT/AngelscriptStaticJITGenerator.{h,cpp}` | Private BackendId/factory/request/result contract, per-task construction, fallback, and packaging handoff. |
| Compatibility generation | Existing `StaticJIT/AngelscriptJITGeneration.*` and `AngelscriptStaticJIT.*` | Preserve deterministic packager and bytecode-default public facade during migration. |
| Generation Engine | `Core/AngelscriptEngine.{h,cpp}`, ClassGenerator analysis files, and Editor/test generation orchestration | Complete Bind/source compilation and pure descriptor view without script reflection materialization. |
| Runtime backend ABI | `Source/AngelscriptRuntime/Public/JIT/AngelscriptRuntimeJITBackend.h` | Runtime BackendId, factory/session ABI, snapshot/result/code-lease views. |
| Coordinator | `Source/AngelscriptRuntime/RuntimeJIT/AngelscriptJITCoordinator.{h,cpp}` | Sole `asIJITCompiler`, Engine policy, request state, publication, and teardown. |
| Runtime snapshot/host | `RuntimeJIT/AngelscriptRuntimeJITSnapshot.*`, `AngelscriptRuntimeJITState.*`, and `AngelscriptRuntimeJITHost.*` | Owned bytecode snapshot, validation, helper ABI, VMEntry/FScriptExecution bridge. |
| Tests | Existing `AngelscriptTest/StaticJIT/` plus new `AngelscriptTest/RuntimeJIT/` files beginning with `Angelscript` | Characterization, Static contracts, no-UClass generation, Runtime policies/lifetimes, and dispatch. |

Do not create a second Provider registry, route authority, stable identity type, or generated-file packager.

## Milestone A: BytecodeJIT Characterization And Extraction

Completed and verified on 2026-08-13. `FAngelscriptBytecodeJIT` now owns bytecode analysis and emission beneath `StaticJIT/BytecodeJIT/`; `FAngelscriptStaticJIT` remains only the temporary `asIJITCompiler` lifecycle/publication facade. Compatibility and direct-generator output are compared byte-for-byte in the generated-output fixture. Exact commands and results are recorded in `implementation-notes.md`.

1. Extend existing deterministic generation tests before production edits. Capture request normalization, implementation templates, references, symbols, module files, manifest, and owned-file inventory.
2. Run the focused test and retain the expected pre-feature failure if the wished-for BytecodeJIT class boundary does not yet exist.
3. Add `FAngelscriptBytecodeJIT` and move the current generator implementation mechanically. Keep `FAngelscriptStaticJIT` as the Engine lifecycle facade and delegate generation to the new class.
4. Move `AngelscriptBytecodes` and context helpers into the BytecodeJIT folder only when include changes remain mechanical; do not rewrite opcode handlers during this milestone.
5. Re-run determinism/generated-output tests and compare checked/generated artifacts byte-for-byte.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label bytecode-jit-extraction -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.GeneratedOutput" -Label bytecode-jit-generated-output -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Generation" -Label bytecode-jit-generation -TimeoutMs 600000
```

## Milestone B: Static Backend Contract And Generator

Completed and verified on 2026-08-13. Static BackendIds, the Runtime-module-owned per-task contract, deterministic registry/generator, BytecodeJIT factory, explicit backend/capture request, typed per-function fallback, and backend-neutral Provider packaging are implemented. The built-in bytecode factory is registered explicitly from Runtime module startup. Exact TDD incidents and verification results are recorded in `implementation-notes.md`.

1. Add failing pure value/registry tests for Static BackendId and fake per-task backends.
2. Define the private contract. Keep request/view types internal; expose only the explicit generation settings needed by Editor/test modules. Model the complete `CompiledSourceGraph` separately from `EmitModuleSet` so output filtering never hides semantic dependencies from a backend.
3. Implement deterministic explicit registration during Runtime module initialization; do not rely on static constructor order or `IModularFeatures` for Static backends.
4. Register `"bytecode"`, route existing generation overloads through `FAngelscriptStaticJITGenerator`, and keep their default output unchanged.
5. Implement typed per-function dispositions and generator-owned fallback with fake `"typed-ast"` tests. Do not add real HIR in this milestone.
6. Prove mixed fake-backend/BytecodeJIT functions share one module translation unit and Provider identity excludes provenance.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.Backend" -Label static-jit-backend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label static-jit-backend-regression -TimeoutMs 900000
```

## Milestone C: Generation-Only Engine And Descriptor View

1. Add the no-UClass regression first with unique reflected script names and observations for UObject lookup, CDO, reload/reinstancing delegates, and current routes.
2. Add two-live-Engine Bind/profile isolation coverage. Never require numeric type/function IDs to differ; assert they are interpreted only by their owning Engine and compare stable identities across Engines.
3. Add an explicit `EAngelscriptEnginePurpose::StaticJITGeneration` (ordinary runtime/editor remains the default purpose) and a generation-local module result; avoid spreading unrelated boolean branches when later engine purposes may be added.
4. Factor pure descriptor analysis from ClassGenerator setup. Reuse its semantic analysis, but exclude redirects, reload planning, UObject creation/linking/finalization, CDO work, and route publication to another Engine.
5. Change project/test generation to use the generation-only path and construct a complete synchronous `CompiledSourceGraph` plus explicit `EmitModuleSet` while the Engine remains alive.
6. Run all three target profiles and prove the selected Provider domain compiles its complete source graph while output remains restricted to the requested modules.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label static-jit-generation-engine -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.ProjectGeneration" -Label static-jit-generation-engine -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.MultiEngine" -Label static-jit-generation-engine-isolation -TimeoutMs 900000
```

## Milestone D: Runtime Contract, Snapshots And Policies

1. Add ABI/layout/configuration tests and the fake Runtime factory/session.
2. Implement factory metadata validation, deterministic duplicate rejection, one selected session per Engine, typed outcomes, and code leases.
3. Add owned bytecode/frame/control-flow/profile snapshot validation and module-discard safety.
4. Implement EagerSync, EagerBackground, then LazyFirstCall against one request/publication state machine.
5. Add coalescing, cancellation, unsupported memoization, stale Hot Reload results, and two-Engine isolation.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.Coordinator.Contract" -Label jit-coordinator-contract -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.Coordinator.Policy" -Label jit-coordinator-policy -TimeoutMs 900000
```

## Milestone E: Coordinator Ownership And Routing

1. Add the one-compiler lifecycle test before changing Engine installation.
2. Move `asIJITCompiler` ownership and function-ready/release callbacks to `FAngelscriptJITCoordinator` while keeping current Binding lifecycle intact.
3. Delete only the obsolete `FAngelscriptStaticJIT` class facade; retain BytecodeJIT and generation compatibility functions.
4. Implement mode/backend/policy parsing and AOT/Runtime/VM selection.
5. Publish Runtime VMEntry-only Bindings through immutable routes and verify readers/code leases during replacement/unload.
6. Add debugger/coverage and UASFunction Raw/Parms gates, generic diagnostics, and state observations.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT.Coordinator" -Label jit-coordinator -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label jit-coordinator-static-regression -TimeoutMs 900000
```

## Final Verification And Handoff

```powershell
openspec validate "refactor-as-unified-jit-coordinator" --type change --strict --no-interactive
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label unified-jit-final -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.RuntimeJIT" -Label unified-jit-runtime -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label unified-jit-static -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label unified-jit-compiler -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix unified-jit-standalone -TimeoutMs 900000
```

Record exact pass/fail/skip/timeout counts, report paths, plugin commit, parent gitlink state, and remaining dirty paths. Only then hand `"typed-ast"` contract implementation to `feature-as-typed-semantic-aot` and freeze the Runtime conformance harness for MIR/LLVM plugins.
