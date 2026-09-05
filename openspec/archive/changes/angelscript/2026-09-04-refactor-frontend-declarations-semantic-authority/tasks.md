---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
    "3.1": ["2.2"]
---

## 1. Typed collection and declaration barrier

- [x] 1.1 Implement the Engine-independent collection session and build the focused CQTests — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-declarations-collection-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_declaration_fragment.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_parser.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/DeclarationSemanticTests.cpp`

  > Context: Begin only after the direct Lexer, Preprocessor, TypeIdentity, and AST prerequisites listed in `design.md` are implemented and synchronized; their verified dependency chains supply the transitive Foundation and SourceDiagnostics contracts. This is cross-Change readiness, not part of this local task graph.

  > Constraints: Use `BEGIN_AS_NAMESPACE` plus lowercase `namespace frontend`, final leaf names, and concrete typed declarations from the AST Change. Do not introduce `V2`, a generic semantic IR, `import`, live Engine/Builder access, or runtime type stubs.

  1. Add CQTests for the `asCParser(asCPreprocessor&, asCSema&)` boundary, typed Parser/Sema actions, all-source collection, the declaration barrier, deferred body ranges, and construction with no live Engine or Builder; build the new translation units.
  2. Run the newly built Declarations prefix and retain the expected focused RED before implementing the missing semantics.
  3. Implement the minimum compilation-session, parser, Sema, and fragment behavior, then rebuild the exact editor target to GREEN at the compile boundary.

- [x] 1.2 Prove typed collection against the freshly built editor — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Declarations'; Label = 'frontend-declarations-collection-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/DeclarationSemanticTests.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`

  1. Require Task `1.1` build evidence to match the current source and test content.
  2. Run the complete Declarations prefix once and require the collection scenarios to pass.
  3. Record the managed run ID, report path, pass/fail counts, and process outcome.

## 2. Whole-session resolution, recovery, and determinism

- [x] 2.1 Implement declaration resolution and deterministic fragment finalization, then rebuild — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-declarations-resolution-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_declaration_fragment.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_declaration_fragment.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_context.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_ast_context.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_decl.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_decl.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/DeclarationSemanticTests.cpp`

  > Produces: Source-order-independent declaration contexts, canonical lookup and overload sets, resolved bases/signatures, typed recovery nodes, and deterministic diagnostic/reference projections.

  1. Extend the CQTests first with later-file type references, reversed input order, duplicates, malformed declarations, and one-worker versus multi-worker comparisons; rebuild and observe the focused RED.
  2. Implement barrier-only lookup, stable merge ordering, typed recovery, and non-publishable error state without constructing runtime objects.
  3. Rebuild the exact editor target after the final C++ modification.

- [x] 2.2 Prove the complete declaration authority against the latest build — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Declarations'; Label = 'frontend-declarations-final-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/DeclarationSemanticTests.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_declaration_fragment.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`

  1. Require Task `2.1` build evidence to match every compiled declaration source and test file.
  2. Run the full Declarations prefix and compare stable projections rather than pointer or worker completion order.
  3. Record the managed run ID, report path, pass/fail counts, and evidence for the no-Engine/no-Builder boundary.

## 3. Contract synchronization

- [x] 3.1 Create, synchronize, and strictly validate the verified declaration capability — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-frontend-declarations-semantic-authority','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'declaration semantics Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-frontend-declarations-semantic-authority/proposal.md`, `openspec/changes/angelscript/refactor-frontend-declarations-semantic-authority/design.md`, `openspec/changes/angelscript/refactor-frontend-declarations-semantic-authority/specs/angelscript/language/frontend/declarations/spec.md`, `openspec/changes/angelscript/refactor-frontend-declarations-semantic-authority/tasks.md`, `openspec/changes/angelscript/refactor-frontend-declarations-semantic-authority/attachments/INDEX.md`, `openspec/specs/angelscript/language/frontend/declarations/spec.yaml`, `openspec/specs/angelscript/language/frontend/declarations/spec.md`

  1. Confirm the final incremental build and exact Declarations prefix remain current and successful.
  2. Record managed run IDs, report paths, and any evidence-driven verification expansion.
  3. Create the missing current capability with `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create','angelscript/language/frontend/declarations','--title','Frontend Declaration Semantics','--json')`; never hand-author `spec.yaml`.
  4. Semantically merge this delta without operation headings, then run exact strict Change validation and strict current-spec validation before completing this terminal synchronization task.

  Intentionally omit Harness aggregate profiles, full UE suites, Standalone, production Builder/Engine tests, reflection generation, bytecode, and VM tests because this Change has no production consumer and stops at declaration semantics.
