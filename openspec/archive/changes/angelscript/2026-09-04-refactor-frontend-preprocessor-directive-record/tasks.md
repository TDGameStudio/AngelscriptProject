---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "2.1": ["1.3"]
    "3.1": ["2.1"]
    "3.2": ["3.1"]
    "4.1": ["3.2"]
---

The coordinator must confirm that `angelscript/refactor-native-engine-test-foundation`, `angelscript/refactor-frontend-source-diagnostics-model`, and `angelscript/refactor-frontend-lexer-token-pipeline` have published their required contracts before Task 1.1 starts. These external prerequisites are deliberately not represented as fake cross-Change Task DAG nodes.

## 1. Conditional routing and tree

- [x] 1.1 Implement minimal conditional evaluation through CQTest RED/GREEN — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'preprocessor-condition-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'preprocessor condition build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Preprocessor'; Label = 'preprocessor-condition-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'preprocessor condition test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_kinds.def`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativePreprocessorDirectiveRoutingTests.cpp`

  > Context: Consume frozen source/token/configuration inputs from the prerequisite Changes. Put final, unsuffixed leaf names inside `BEGIN_AS_NAMESPACE` and lowercase `namespace frontend`. Do not add macro replacement, import discovery, reflection policy, a legacy ForceInclude, or a private engine pool.

  1. Add CQTest cases for `#if`, single `!`, `#ifdef`, `#ifndef`, `#elif`, `#else`, nesting, first-taken selection, and unreachable-condition suppression; build, run the exact Fast prefix, and record the expected RED failures.
  2. Implement the smallest deterministic evaluator and active-token routing needed by those cases.
  3. Rerun the same Fast prefix to GREEN and retain exact diagnostic assertions for unknown evaluated flags and malformed branch ordering.

- [x] 1.2 Preserve the complete directive tree and inactive ranges through CQTest RED/GREEN — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'preprocessor-tree-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'preprocessor tree build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Preprocessor'; Label = 'preprocessor-tree-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'preprocessor tree test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_tree.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_tree.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_kinds.def`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativeDirectiveTreeTests.cpp`

  > Inputs: Task 1.1's directive tokens and evaluation states.

  > Produces: A raw-source tree whose code, directives, nested conditionals, branch ranges, terminators, taken branch, and skipped ranges remain inspectable independently of parser input.

  1. Add CQTest tree-shape and exact-range cases, including no-taken, nested-inactive, comments/strings containing `#`, missing terminators, and duplicate `#else`; build, run, and observe RED.
  2. Implement compact tree nodes and structural validation with one directive taxonomy source.
  3. Prove GREEN without constructing typed AST nodes for inactive branches.

- [x] 1.3 Preserve typed restriction directives and reject unsupported include directives through CQTest RED/GREEN — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'preprocessor-policy-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'preprocessor policy build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Preprocessor'; Label = 'preprocessor-policy-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'preprocessor policy test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_tree.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_tree.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_kinds.def`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativePreprocessorPolicyTests.cpp`

  > Produces: Typed `#restrict usage allow/disallow <pattern>` records with exact ranges and fail-closed `#include` diagnostics that do not recommend or create an `import` dependency.

  > Constraints: Restriction directives are policy records, not conditional expressions. Do not add macro expansion, include loading, keyword-driven module loading, or generic key-value annotations.

  1. Add valid allow/disallow fixtures, malformed operation/policy/argument fixtures, and active `#include` rejection fixtures; build, run, and observe the expected RED results.
  2. Implement the typed restriction grammar, exact authored ranges, and deterministic diagnostics at the directive boundary.
  3. Rerun the same build and exact Fast prefix to GREEN, proving that no rejected directive emits active tokens or a dependency edge.

## 2. Preprocessing record and backquery

- [x] 2.1 Add snapshot-bound range queries through CQTest RED/GREEN — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'preprocessing-record-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'preprocessing record build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Preprocessor'; Label = 'preprocessing-record-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'preprocessing record test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessing_record.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessing_record.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativePreprocessingRecordTests.cpp`

  > Constraints: Use source ranges and snapshot-local IDs with owner checks. Do not attach preprocessing IDs to every AST node, persist local IDs, or expose borrowed views beyond the snapshot lease.

  1. Add CQTest cases for overlap/containment, different-region, directive-intersection, source ordering, skipped-range ownership, and cross-snapshot rejection; build, run, and observe RED.
  2. Implement the per-file range index and immutable result ownership.
  3. Rerun the Fast prefix to GREEN and prove two snapshots may reuse numeric IDs without aliasing.

## 3. Build and focused acceptance

- [x] 3.1 Compile the new frontend boundary with an incremental Editor build — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessor.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_tree.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_directive_tree.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessing_record.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_preprocessing_record.cpp`, `openspec/changes/angelscript/refactor-frontend-preprocessor-directive-record/tasks.md`

  1. Run the incremental Development Editor build after all focused implementation tasks are GREEN.
  2. Repair only compile/include/export issues inside this Change's owned frontend boundary.
  3. Record the managed build result and intentionally omit unrelated suites unless failure evidence expands impact.

- [x] 3.2 Pass the exact NativeEngine Preprocessor Fast area — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Preprocessor'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativePreprocessorDirectiveRoutingTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativeDirectiveTreeTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativePreprocessorPolicyTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/AngelscriptNativePreprocessingRecordTests.cpp`, `openspec/changes/angelscript/refactor-frontend-preprocessor-directive-record/tasks.md`

  1. Run only `Angelscript.UnitTest.NativeEngine.Preprocessor` with the Fast route.
  2. Record run ID, pass/fail counts, and report path as completion evidence.
  3. Confirm the run exercises the intended new frontend rather than any quarantined legacy preprocessor.

## 4. Durable specification synchronization

- [x] 4.1 Create, synchronize, and strictly validate the preprocessing capability after implementation verification — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-frontend-preprocessor-directive-record','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'preprocessing Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-frontend-preprocessor-directive-record/specs/angelscript/language/frontend/preprocessing/spec.md`, `openspec/specs/angelscript/language/frontend/preprocessing/spec.yaml`, `openspec/specs/angelscript/language/frontend/preprocessing/spec.md`, `openspec/changes/angelscript/refactor-frontend-preprocessor-directive-record/tasks.md`, `openspec/changes/angelscript/refactor-frontend-preprocessor-directive-record/attachments/INDEX.md`

  1. Create the missing current capability with `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create','angelscript/language/frontend/preprocessing','--title','Frontend Preprocessing','--json')`; never hand-author `spec.yaml`.
  2. Semantically merge the complete delta Requirements and Scenario Cards into the current capability without delta-operation headings.
  3. Run exact strict Change validation and strict current-spec validation, record both results as synchronization evidence, and complete the terminal task only after the durable contract matches verified behavior.
