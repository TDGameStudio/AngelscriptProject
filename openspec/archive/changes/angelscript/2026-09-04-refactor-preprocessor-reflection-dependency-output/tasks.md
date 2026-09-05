---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["1.2"]
    "3.1": ["2.1", "2.2"]
    "4.1": ["3.1"]
---

Use one PowerShell 7 process for all Harness commands: import `./.agents/skills/harness/scripts/Harness.psd1`, create `$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path`, and activate that exact workspace once. Do not begin Task 1.1 until the three direct cross-Change prerequisites listed in `design.md` are complete; they are external readiness conditions rather than this file's intra-Change graph.

## 1. Concrete result and descriptor ownership

- [x] 1.1 Establish the single descriptor owner and a compilable concrete preprocessing-result contract — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'as-reflection-dependency-output-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDescriptors.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocess_result.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocess_result.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/ModuleGraph/AngelscriptFrontendModuleGraphTests.cpp`

  > Context: The prerequisite CQTest foundation supplies the replacement test support. Existing descriptor declarations are moved, not copied, and the existing Engine header remains a source-compatible include entry.

  > Produces: RED behavior fixtures that compile against the concrete result surface, one shared descriptor definition, lifecycle/stable-source fields, and result-owned declaration/body graph shells.

  > Constraints: Do not edit `AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.*`, any root-level legacy ThirdParty frontend file, or a stable public `angelscript.h` API. Put new fork-internal leaves inside `BEGIN_AS_NAMESPACE` in lowercase `frontend`; do not introduce `Frontend`, `V2`, or compatibility-twin names.

  1. Add CQTest cases for concrete result contents, descriptor state, null runtime pointers, active-configuration filtering, typed dependency evidence, SCCs, graph separation, and deterministic ordering; make the initial contract compile while the behavior remains RED.
  2. Extract the complete existing descriptor family into `AngelscriptDescriptors.h`, preserve existing includes through `AngelscriptEngine.h`, and keep existing methods/linkage intact.
  3. Add the exact `FAngelscriptPreprocessResult` surface and lifecycle/graph value types without adding a generic IR, DTO, or duplicate descriptor family.
  4. Run the exact Harness build and inspect the managed run state, exit code, and `UBT.log` on failure.

- [x] 1.2 Observe the grouped Reflection and ModuleGraph RED behavior against the freshly built contract — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Reflection+Angelscript.UnitTest.NativeEngine.ModuleGraph'; Label = 'as-reflection-dependency-output-red'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/ModuleGraph/AngelscriptFrontendModuleGraphTests.cpp`, `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/tasks.md`

  > Produces: Managed RED evidence from the same exact grouped selection later used for GREEN, with failures tied to missing semantic projection rather than discovery, stale binaries, process startup, or legacy tests.

  1. Require Task 1.1 build evidence to match both current test files.
  2. Run the exact grouped Fast selection and retain the expected descriptor-lifecycle, dependency-edge, SCC, graph-separation, and result-assembly failures.
  3. Record the managed run ID, Automation report, failed scenario names, and process outcome before implementing Tasks 2.1 and 2.2.

## 2. Semantic projections

- [x] 2.1 Project typed declaration and attribute events into resolved descriptors — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'as-reflection-descriptor-consumer-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocess_result.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocess_result.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp`

  > Inputs: Typed `Decl`, `Attr`, canonical type-use keys, source ranges, and stable declaration ownership from declaration Sema.

  > Produces: One concrete consumer that transitions complete candidates from `Parsed` to `Resolved`, rejects partial output transactionally, and leaves every materialization pointer null.

  > Constraints: The consumer must not inspect source text, regular expressions, chunks, `import`, mutable Engine state, UObject registries, filesystem state, or worker completion order.

  1. Preserve the compiled RED descriptor fixtures from Task 1.1 and extend only missing edge cases before implementation.
  2. Implement concrete callbacks for module, class/struct, enum, delegate, function, argument, and property declarations plus their validated UE attributes.
  3. Resolve stable ownership and type-use facts, finalize only a complete descriptor collection, and discard publishable output when declaration diagnostics fail the transaction.
  4. Run the incremental Harness build before any Automation execution; keep the behavior proof pending for Task 3.1.

- [x] 2.2 Build typed declaration dependencies, SCCs, and the separate body invalidation graph — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'as-module-dependency-graph-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_dependency_graph.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_dependency_graph.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/ModuleGraph/AngelscriptFrontendModuleGraphTests.cpp`

  > Inputs: Resolved declaration/type-use facts from Sema and optional body-reference facts from a distinct typed sink.

  > Produces: Use-site declaration edges with reason/range/completeness, deterministic SCC and condensation output, plus a body invalidation graph that cannot affect declaration scheduling.

  > Constraints: Do not infer dependencies from source imports or string spellings. Preserve distinct source ranges, exclude same-module and host-only pseudo-edges, and let Sema diagnose illegal completeness cycles.

  1. Implement recursive dependency extraction for bases, interfaces, stored properties, returns, parameters, generic arguments, and delegate signatures.
  2. Canonically order exact edge tuples, compute SCC membership and the condensation DAG, and prove legal cycles remain representable.
  3. Implement the separate optional body-reference sink and verify body-only changes leave declaration SCC output unchanged.
  4. Run the incremental Harness build before Automation; keep the grouped behavioral proof pending for Task 3.1.

## 3. Facade integration and focused behavior proof

- [x] 3.1 Wire atomic result assembly through the new preprocessor facade and pass the grouped NativeEngine proof — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'as-reflection-dependency-output-final-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'reflection/dependency output build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Reflection+Angelscript.UnitTest.NativeEngine.ModuleGraph'; Label = 'as-reflection-dependency-output-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'reflection/dependency output test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocess_result.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocess_result.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_dependency_graph.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_dependency_graph.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/ModuleGraph/AngelscriptFrontendModuleGraphTests.cpp`

  > Produces: The direct `asCPreprocessor` result, failure-safe transaction boundary, active-configuration behavior, and one grouped Fast run covering Reflection and ModuleGraph without paying for unrelated suites.

  > Constraints: Keep production routing dormant. Do not add compatibility calls into the old Runtime preprocessor, materialize UE/Runtime objects, or populate the declaration graph from body facts.

  1. Connect the prerequisite directive/preprocessor token flow to declaration Parser/Sema and the concrete descriptor/dependency consumers.
  2. Seal the result only after declaration resolution and canonical ordering succeed; return diagnostics with no publishable descriptors on failure.
  3. Run the incremental build embedded in this task's exact verify command so the Automation process cannot load stale binaries.
  4. Run the exact grouped Fast prefix, inspect its managed RunId, pass/fail counts, Automation report, and process exit, and repair only evidence-related failures in this Change's scope.
  5. Record that Harness Quick, Performance, Integration, full UE suites, Standalone, and dormant legacy tests were intentionally omitted because this Change affects the isolated frontend contract and its two exact NativeEngine areas.

## 4. Contract synchronization

- [x] 4.1 Create, synchronize, and strictly validate the verified reflection/dependency capability — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-preprocessor-reflection-dependency-output','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'reflection/dependency Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/proposal.md`, `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/design.md`, `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/specs/angelscript/language/frontend/reflection-dependencies/spec.md`, `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/tasks.md`, `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/attachments/INDEX.md`, `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/attachments/talks/talk-20260905-010721-direct-descriptors-and-dependency-authority.md`, `openspec/changes/angelscript/refactor-preprocessor-reflection-dependency-output/attachments/knowledges/semantic-events-to-reflection-and-dependency-graphs.md`, `openspec/specs/angelscript/language/frontend/reflection-dependencies/spec.md`, `openspec/specs/angelscript/language/frontend/reflection-dependencies/spec.yaml`, `openspec/specs/angelscript/language/frontend/reflection-dependencies/knowledges/INDEX.md`, `openspec/specs/angelscript/language/frontend/reflection-dependencies/knowledges/semantic-events-to-reflection-and-dependency-graphs.md`

  > Context: Use the `openspec-sync-specs` lifecycle. The CLI validates records but does not perform the semantic merge or create the durable capability manifest on its own.

  1. Create the missing current capability with `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create','angelscript/language/frontend/reflection-dependencies','--title','Frontend Reflection Dependencies','--json')`; never hand-author `spec.yaml`.
  2. Merge the complete verified Requirement delta into the durable capability, preserving every clause-owned detail block.
  3. Reconcile final behavior and evidence with every Requirement and Scenario Card, then run exact strict Change validation and strict current-spec validation before completing this terminal synchronization task.
