I'm using the writing-plans skill to create the implementation plan. This change is plan-only: do not implement until the user authorizes it. Overturn `feature-as-typed-semantic-aot` persistence and generation-Engine rules as recorded in `design.md`.

## File map

Create / extend:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheTypes.h` — add `TypedHIRSidecar = 8`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheTypedHIRSidecar.h/.cpp` — pointer-free DTO, absence hash, FunctionKey link
- Cache remaining-record archive, decoded record, clean capture, compiler bridge (same files as DebugSidecar)
- Fork persist codec beside `ThirdParty/angelscript/source/as_typed_semantic_ir.*` — stable-key encode/decode; remap on restore
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/NativeCalls/AngelscriptNativeFormCatalog.h/.cpp` — process-global catalog
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/BytecodeJIT/StaticJITBinds.cpp` — catalog insert; optional per-Engine attach
- `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptProjectSourceGraph.cpp` — matching-profile path skips `FAngelscriptEngine::Create`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptJITGeneration.cpp` + generator/orchestrator — primary vs commandlet
- `Plugins/Angelscript/Source/AngelscriptEditor/StaticJIT/AngelscriptJITCommand.cpp` — Editor batch: matching profile from primary, remaining profiles through the shared sequential generation-Engine helper (same helper as the commandlet)
- Attachments (discussion notes, not tasks): `openspec/changes/refactor-as-primary-engine-typed-ast-generate/attachments/`
- Tests: `AngelscriptTest/Cache/AngelscriptCacheTypedHIRSidecarTests.cpp`, `AngelscriptTest/StaticJIT/AngelscriptPrimaryEngineTypedASTGenerateTests.cpp`, `AngelscriptTest/StaticJIT/AngelscriptNativeFormCatalogTests.cpp`, commandlet tests beside `AngelscriptJITCommandletTests.cpp`

Do not: load `.hir.txt` as input; store engine-local function IDs; create an in-process Shipping Engine beside Editor; add a `"dual"` backend.

## 1. Cache V2 TypedHIR sidecar codec

- [ ] 1.1 <!-- TDD --> Add failing Cache tests in `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheTypedHIRSidecarTests.cpp` for record kind `TypedHIRSidecar`, FunctionBody optional link, canonical `function-typed-hir-absent` coordinate, FunctionKey mismatch, and empty-payload-not-absence. Automation prefix `Angelscript.TestModule.Cache`.
- [ ] 1.2 <!-- TDD --> Extend `EAngelscriptCacheRecordKind` in `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheTypes.h` with `TypedHIRSidecar = 8` and wire decode/serialize beside DebugSidecar in remaining-record archive, decoded record, and clean capture. Keep FunctionBody bytecode bytes HIR-free.
- [ ] 1.3 <!-- TDD --> Add a pointer-free sidecar DTO (integer node IDs, stable module/function/type keys, no `resolvedFunctionId` on disk) and a payload schema version independent of DebugSidecar. Prove capture-on vs capture-off FunctionBody bytecode payloads are equal when only the sidecar link differs.
- [ ] 1.4 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label typed-hir-sidecar-codec -TimeoutMs 1800000 -NoXGE` then `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label typed-hir-sidecar-codec -TimeoutMs 600000`. If the focused new file can be isolated, prefer its full test name; otherwise keep the Cache prefix.

## 2. Sidecar encode from live HIR and ExactStartup remap

- [ ] 2.1 <!-- TDD --> Add failing compiler/cache tests proving a capture-on compile publishes a sidecar, ExactStartup into a fresh capture-on Engine attaches verified HIR, and preprocess/parse/function-compiler counters stay zero for restored bodies. Place runtime-facing cases under `AngelscriptTest/Cache/` or `AngelscriptTest/StaticJIT/` with prefix `Angelscript.TestModule.Cache` / `Angelscript.TestModule.StaticJIT`.
- [ ] 2.2 <!-- TDD --> Implement encode from `asCTypedSemanticFunction` to sidecar bytes and decode+remap onto a restored `asCScriptFunction` in the target Engine. Re-run the HIR verifier after remap; verifier failure is ExactStartup miss, not a half-attached graph.
- [ ] 2.3 <!-- TDD --> Prove a capture-on typed-ast Engine misses ExactStartup for bytecode-valid generations that lack sidecars, then source-compiles and recaptures HIR. Prove mixed sidecar coverage inside one module is ineligible.
- [ ] 2.4 <!-- TDD --> Prove a capture-off `"bytecode"` Engine ExactStartup of a generation that contains sidecars executes bytecode and leaves HIR unset. Prove `.hir.txt` / `.hir.json` presence cannot change restore or Generate.
- [ ] 2.5 <!-- TDD --> Keep `SaveByteCode` HIR-free. Extend the existing capture-on/off archive assertion in compiler tests rather than inventing a new public IR ABI.
- [ ] 2.6 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label typed-hir-exactstartup -TimeoutMs 600000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label typed-hir-savebytecode -TimeoutMs 600000`.

## 3. Optional primary capture and Hot Reload

- [ ] 3.1 <!-- TDD --> Add failing Editor/runtime tests that a primary Engine may start with `bCaptureTypedSemanticIR=true` or `false`, that the flag is frozen before `Create()`, and that `"bytecode"` stays capture-off. Hook config in `UAngelscriptEngineSubsystem` / `FAngelscriptEngineConfig`, not a live `SetTypedSemanticIRCapture` toggle.
- [ ] 3.2 <!-- TDD --> Prove Hot Reload Full/Soft replaces HIR on affected functions when capture is on and republishes sidecars for those FunctionBodies. Unchanged functions keep prior sidecar content hashes. Capture-off Hot Reload does not attach HIR.
- [ ] 3.3 <!-- TDD --> Prove changing Static backend, primary target profile, or capture policy is rejected until process restart.
- [ ] 3.4 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label primary-hir-capture -TimeoutMs 1800000 -NoXGE` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label primary-hir-hotreload -TimeoutMs 600000` plus the new StaticJIT tests from 3.1–3.3.

## 4. Process-global native-form catalog (Collect binds)

Collect binds today: `bCollectStaticJITCompatibilityBinds` (default false). `StaticJITBinds.cpp` `AddNativeForm` deletes the form when the flag is off. Generation Engines set the flag true so TypedASTJIT can emit reviewed HeaderInline calls. Improvement: catalog, not a sibling Engine.

- [ ] 4.1 <!-- TDD --> Add failing tests in `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptNativeFormCatalogTests.cpp` proving sealed Bind replay inserts HeaderInline `IsRunningCommandlet` (and one module-exported control case) by stable declaration identity, and a second Engine in the same process resolves the recipe with `bCollectStaticJITCompatibilityBinds=false`.
- [ ] 4.2 <!-- TDD --> Implement `FAngelscriptNativeFormCatalog` and insert from `AttachReviewedHeaderInlineScalarCall` / `AddNativeForm` regardless of the per-Engine collect flag. Per-Engine attach remains optional compatibility.
- [ ] 4.3 <!-- TDD --> Prove matching-profile TypedASTJIT emit uses the catalog, missing entries degrade to bridge/fallback, and a display name without a reviewed linkage contract is not treated as a DLL symbol. Reuse `AngelscriptStaticJITNativeCallLinkageTests.cpp` oracles.
- [ ] 4.4 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label native-form-catalog -TimeoutMs 600000`.

## 5. Matching-profile Generate from primary HIR

- [ ] 5.1 <!-- TDD --> Rewrite the current generation-Engine assertions in `AngelscriptProjectSourceGraphTests.cpp` / TypedASTJIT Generate tests: matching-profile Editor Generate MUST NOT construct `EAngelscriptEnginePurpose::StaticJITGeneration`. Add `AngelscriptPrimaryEngineTypedASTGenerateTests.cpp` for this contract.
- [ ] 5.2 <!-- TDD --> Implement the matching-profile path in `AngelscriptProjectSourceGraph.cpp` and the StaticJIT generator: freshness-gated read of primary modules (and HIR only when capture is on), freeze Hot Reload queue, emit owned files only. Stale inventory returns `AuthoritativeEngineStale` with no ForceClean. Matching `"typed-ast"` with capture off returns `CaptureRequired` without constructing `StaticJITGeneration`.
- [ ] 5.3 <!-- TDD --> Containment: before/after snapshots of `/Script/Angelscript` ownership, routes, CDOs, class caches. Success and every early-fail path. File-change during Generate is queued, not applied.
- [ ] 5.4 <!-- TDD --> Matching-profile `"bytecode"` Generate also skips the sibling Engine so the two backends do not fork orchestration.
- [ ] 5.5 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label primary-typed-ast-generate -TimeoutMs 1800000 -NoXGE` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -LabelPrefix primary-typed-ast-generate`.

## 6. Multi-profile Generate: keep generation Engines for non-matching

Keep `StaticJITGeneration` for GameDevelopment/GameShipping (Editor convenience or pack-time commandlet). Matching Editor Generate still must not create one. At most one extra Engine alive. HIR capture on that Engine is only for `"typed-ast"` requests.

Existing pack-time entry: `Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile EditorDevelopment|GameDevelopment|GameShipping`.

- [ ] 6.1 <!-- TDD --> Add failing tests beside `AngelscriptJITCommandletTests.cpp` proving Editor matching-profile Generate never constructs `StaticJITGeneration`, while an Editor `GameShipping` request does construct exactly one Shipping generation Engine, emits `Generated/GameShipping`, and destroys it without mutating primary packages/HIR.
- [ ] 6.2 <!-- TDD --> Implement Editor batch: matching profile from primary; remaining profiles through the same sequential generation-Engine helper the commandlet uses. Output stays `Source/AngelscriptJIT/Generated/<Profile>/`. Two extra Engines must never be alive together.
- [ ] 6.3 <!-- TDD --> Commandlet process: one Engine per requested profile (sequentially), capture-on only for `"typed-ast"`, collect/catalog native forms, no live Editor mutation. `"bytecode"` commandlet Generate stays capture-off. Verify mode still diffs owned files with LF bytes.
- [ ] 6.4 <!-- TDD --> Prove `EditorDevelopment` and `GameShipping` artifacts have distinct identity, and Verify reports stale if one profile's tree is copied onto the other. Prove matching `"typed-ast"` with primary capture off returns `CaptureRequired` and does not spawn a generation Engine.
- [ ] 6.5 <!-- Non-TDD --> Update `Documents/Guides/Build.md` only where Generate still implies a sibling Engine for the matching Editor profile. Keep commandlet as the pack-time path. Then run:
  `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile EditorDevelopment`
  and
  `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile GameShipping`
  followed by Verify for each profile. Do not treat packaged smoke as part of the first land.

## 7. HIR dump and fallback compatibility

- [ ] 7.1 <!-- TDD --> Matching-profile developer HIR dump MAY read primary HIR. Non-matching-profile dump stays on `UAngelscriptHIRDumpCommandlet` in its own process. Dump files remain non-inputs. Keep the existing tests in `AngelscriptHIRDumpCommandletTests.cpp` and add a matching-profile in-process read case.
- [ ] 7.2 <!-- TDD --> Capture-profile mismatch still fails the whole generation task. Per-function MissingTypedHIR still falls back through BytecodeJIT/VM. No production `"dual"` backend.
- [ ] 7.3 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label hir-dump-primary -TimeoutMs 600000`.

## 8. Close-out verification

- [ ] 8.1 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label primary-engine-typed-ast -TimeoutMs 1800000 -NoXGE`.
- [ ] 8.2 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache" -Label primary-engine-cache -TimeoutMs 600000`.
- [ ] 8.3 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStaticJITTests.ps1 -LabelPrefix primary-engine-staticjit`.
- [ ] 8.4 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix primary-engine-standalone -TimeoutMs 600000`.
- [ ] 8.5 <!-- Non-TDD --> Update plugin-facing notes only where they still say “HIR never in Cache V2” or “TypedASTJIT always uses a temporary Engine”. Do not archive `feature-as-typed-semantic-aot` unless the user asks.
