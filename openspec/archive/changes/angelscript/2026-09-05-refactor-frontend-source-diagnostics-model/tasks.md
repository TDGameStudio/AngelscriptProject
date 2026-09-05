---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "3.1": ["2.1"]
---

## 1. Immutable source model

- [x] 1.1 Implement snapshot-bound UTF-8 locations and ranges with focused RED/GREEN coverage — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'source-ranges-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'source-ranges build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.SourceDiagnostics'; Label = 'source-ranges-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'source-ranges test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_snapshot.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_snapshot.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_location.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_manager.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_source_manager.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/SourceDiagnosticsTests.cpp`

  > Context: Do not begin until `angelscript/refactor-native-engine-test-foundation` is implemented and its Foundation prefix passes.

  > Replan context: Real UBT run `8d50869f797a421ebf421d793298f080` rejected a second `as_source_manager.cpp` basename even in a distinct subdirectory because non-Unity intermediate outputs collide. Keep the public frontend header name, but give the new implementation unit the unique basename `as_frontend_source_manager.cpp`; preserve the old production implementation unchanged.

  > Constraints: Preserve explicit FileID plus UTF-8 byte offsets and half-open ranges. Do not add Engine pointers, absolute-path identity, or Clang raw-location packing.

  1. Add CQTests for exact byte slicing, multi-byte input, invalid ranges, and cross-snapshot rejection; build and observe the focused RED.
  2. Implement construction, freeze, owner validation, immutable byte access, and stable source anchors.
  3. Rebuild the editor target and rerun the same SourceDiagnostics prefix to GREEN.

- [x] 1.2 Add lazy line maps and the range-indexed origin graph — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'source-origin-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'source-origin build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.SourceDiagnostics'; Label = 'source-origin-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'source-origin test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_snapshot.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_snapshot.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_provenance.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_provenance.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_source_manager.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_source_manager.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/SourceDiagnosticsTests.cpp`

  > Replan context: The accepted design makes `asCSourceManager` the compilation-session query facade. The Task `1.2` RED calls line and provenance queries through that facade, so the Task must own the manager declarations and forwarding implementation as well as snapshot storage and provenance records.

  1. Add failing cases for deferred line-map construction, concurrent equal queries, direct and synthetic origins, origin chains, and stable-anchor relocation failure.
  2. Implement once-only lazy indexes and snapshot-local provenance IDs with owner checks.
  3. Rebuild and rerun the identical area prefix.

## 2. Structured diagnostics

- [x] 2.1 Implement the engine-independent diagnostic engine, consumer, ordering, and fix-its — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'source-diagnostics-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'source-diagnostics build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.SourceDiagnostics'; Label = 'source-diagnostics-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'source-diagnostics test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_diagnostics.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_diagnostics.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/SourceDiagnosticsTests.cpp`

  > Produces: Structured records suitable for every later frontend stage and a collecting test consumer; no compatibility adapter to the live Engine is installed.

  1. Add failing tests for typed arguments, related ranges, fix-its, delayed rendering, and deterministic fragment merge.
  2. Implement the diagnostic builder/consumer contract with explicit source ownership validation.
  3. Prove the same serialized sequence with one and multiple producer threads, then rerun the full area prefix.

## 3. Contract synchronization

- [x] 3.1 Run the scoped final proof, synchronize the source-diagnostics capability, and strictly validate both records — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-frontend-source-diagnostics-model','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'source diagnostics Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-frontend-source-diagnostics-model/proposal.md`, `openspec/changes/angelscript/refactor-frontend-source-diagnostics-model/design.md`, `openspec/changes/angelscript/refactor-frontend-source-diagnostics-model/specs/angelscript/language/frontend/source-diagnostics/spec.md`, `openspec/changes/angelscript/refactor-frontend-source-diagnostics-model/tasks.md`, `openspec/changes/angelscript/refactor-frontend-source-diagnostics-model/attachments/INDEX.md`, `openspec/domains/angelscript/language/frontend/domain.yaml`, `openspec/specs/angelscript/language/frontend/source-diagnostics/spec.yaml`, `openspec/specs/angelscript/language/frontend/source-diagnostics/spec.md`

  > Replan context: The first capability-create attempt was correctly rejected because the planned parent domain `angelscript/language/frontend` was not registered. Create that domain through `openspec.domain` before creating the source-diagnostics spec; do not fabricate either manifest.

  1. Run an incremental `AngelscriptProjectEditor` Development build through Harness and the exact SourceDiagnostics Fast prefix once against the final content.
  2. Record the managed run IDs, report path, pass/fail counts, and any evidence-driven scope expansion.
  3. If missing, create the shared parent domain with `Invoke-Harness -Command openspec.domain -Context $context -ArgumentList @('create','angelscript/language/frontend','--title','Frontend','--json')`, then create the missing current capability with `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create','angelscript/language/frontend/source-diagnostics','--title','Frontend Source Diagnostics','--json')`. Do not fabricate either manifest; merge the delta without operation headings, then run exact strict Change validation and strict current-spec validation before completing this terminal synchronization task.

  Intentionally omit aggregate Harness profiles, full UE suites, Standalone, and upper Runtime tests: this isolated source/diagnostic API has no production consumer in this Change.
