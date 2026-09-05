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

## 1. Deferred body parsing and typed semantics

- [x] 1.1 Implement deferred body work and build the focused CQTests — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-bodies-core-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_fragment.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_parser.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_stmt.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_stmt.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_expr.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_expr.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/BodySemanticTests.cpp`

  > Context: Begin only after `angelscript/refactor-frontend-declarations-semantic-authority` is implemented, synchronized, and its complete Declarations prefix passes. Earlier Changes 1-6 are transitive prerequisites, not task IDs here.

  > Constraints: Use the frozen declaration environment and concrete typed AST. Do not add `V2`, generic semantic records, `import`, runtime IDs, live Engine/Builder access, bytecode, or production routing.

  1. Add CQTests first for deferred-body gating, later-file and mutually recursive calls, concrete statement/expression subclasses, explicit conversions, and phase-mutation rejection; build all new translation units.
  2. Run the newly built Bodies prefix and retain the expected focused RED before implementing the missing semantics.
  3. Implement the minimum body work-item, Parser, Sema, and fragment behavior, then rebuild the exact editor target after the final C++ change.

- [x] 1.2 Prove core body semantics against the freshly built editor — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Bodies'; Label = 'frontend-bodies-core-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/BodySemanticTests.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_fragment.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`

  1. Require Task `1.1` build evidence to match the current body source and test content.
  2. Run the complete Bodies prefix once and require every core typed-semantic scenario to pass.
  3. Record the managed run ID, report path, pass/fail counts, and process outcome.

## 2. Control, lifetime, recovery, and deterministic fragments

- [x] 2.1 Implement control/lifetime facts and deterministic recovery, then rebuild — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-bodies-finalization-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_fragment.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_fragment.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_lifetime.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_lifetime.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_context.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_ast_context.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/BodySemanticTests.cpp`

  > Produces: Typed control targets, source-language lifetime and cleanup obligations, range-bearing recovery nodes, guaranteed parser progress, and one-worker/multi-worker equivalent body results.

  1. Extend tests first with nested exits, construction failures, explicit `asCErrorType`/`asCRecoveryExpr` recovery, malformed statements, later valid functions, reversed input order, and worker-count comparisons; rebuild and observe focused RED.
  2. Implement grammar-aware recovery, semantic control/lifetime planning, fragment remapping, stable attachment order, and deterministic diagnostic merge.
  3. Rebuild the exact editor target after every final source adjustment; do not use bytecode output as the oracle.

- [x] 2.2 Prove the complete body authority against the latest build — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Bodies'; Label = 'frontend-bodies-final-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Bodies/BodySemanticTests.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_fragment.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_body_lifetime.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`

  1. Require Task `2.1` build evidence to match all compiled body-semantic and test sources.
  2. Run the full Bodies prefix and compare typed semantic projections rather than addresses, runtime IDs, or thread completion order.
  3. Record the managed run ID, report path, pass/fail counts, and evidence that bytecode/Engine/Builder paths were not entered.

## 3. Contract synchronization

- [x] 3.1 Create, synchronize, and strictly validate the verified body capability — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-frontend-bodies-semantic-authority','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'body semantics Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-frontend-bodies-semantic-authority/proposal.md`, `openspec/changes/angelscript/refactor-frontend-bodies-semantic-authority/design.md`, `openspec/changes/angelscript/refactor-frontend-bodies-semantic-authority/specs/angelscript/language/frontend/bodies/spec.md`, `openspec/changes/angelscript/refactor-frontend-bodies-semantic-authority/tasks.md`, `openspec/changes/angelscript/refactor-frontend-bodies-semantic-authority/attachments/INDEX.md`, `openspec/specs/angelscript/language/frontend/bodies/spec.yaml`, `openspec/specs/angelscript/language/frontend/bodies/spec.md`

  1. Confirm the final incremental build and exact Bodies prefix remain current and successful.
  2. Record managed run IDs, report paths, and any evidence-driven verification expansion.
  3. Create the missing current capability with `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create','angelscript/language/frontend/bodies','--title','Frontend Body Semantics','--json')`; never hand-author `spec.yaml`.
  4. Semantically merge this delta without operation headings, then run exact strict Change validation and strict current-spec validation before completing this terminal synchronization task.

  Intentionally omit Harness aggregate profiles, full UE suites, Standalone, production Parser/Builder tests, reflection generation, bytecode, JIT, and VM tests because this Change has no production consumer and stops at typed body semantics.
