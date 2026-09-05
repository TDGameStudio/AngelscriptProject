---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "3.1": ["2.1"]
    "3.2": ["3.1"]
    "4.1": ["3.2"]
---

The coordinator must confirm that `angelscript/refactor-native-engine-test-foundation` and `angelscript/refactor-frontend-source-diagnostics-model` are implemented before Task 1.1 starts. These external prerequisites are not fake cross-Change nodes in this local DAG. This Change precedes and supplies identity contracts to `angelscript/refactor-frontend-clang-typed-ast`; it does not depend on the preprocessor Change.

## 1. Canonical identity core

- [x] 1.1 Build deterministic TypeDecl identity through CQTest RED/GREEN — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'type-decl-identity-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'type declaration identity build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Identity'; Label = 'type-decl-identity-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'type declaration identity test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_canonical_encoding.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_canonical_encoding.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Identity/AngelscriptNativeTypeDeclIdentityTests.cpp`

  > Constraints: Implement inside `BEGIN_AS_NAMESPACE` and lowercase `namespace frontend`; final names have no `V2` suffix. UE types are allowed, but canonical bytes cannot depend on their internal representation.

  1. Add CQTest golden vectors for stable scope/owner/kind/name/arity, cross-worktree and registration-order equality, nominal distinctions, non-cacheable unstable declarations, unknown schema/domain versions, and an injected hash collision; build, run, and observe RED.
  2. Implement versioned domain-separated length-framed encoding, complete witnesses, BLAKE3-256 indexing, and exact equality.
  3. Rerun the same Fast area to GREEN and prove no pointer, runtime ID, `FName` index, absolute path, line, or traversal ordinal enters the witness.

- [x] 1.2 Build structural TypeUse identity and role validation through CQTest RED/GREEN — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'type-use-identity-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'type use identity build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Identity'; Label = 'type-use-identity-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'type use identity test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Identity/AngelscriptNativeTypeUseIdentityTests.cpp`

  > Inputs: Task 1.1's canonical encoder and `TypeDeclKey`; recursive type-use descriptors remain independent of the later AST object layout.

  > Produces: Recursive ordered `TypeUseKey`, separate alias spelling, explicit schema/ABI domains, and typed qualifier-role validation.

  1. Add CQTest matrices for primitives, nominal objects, reordered and nested generic arguments, const/reference/handle uses, weak and strong aliases, parameter/ownership misuse, malformed child references, depth/count budgets, and deterministic encoding; build, run, and observe RED.
  2. Implement structural descriptors without parsing stable-key strings.
  3. Prove GREEN and one-fact-at-a-time isolation across declaration identity, use identity, schema, and ABI keys.

## 2. Artifact and runtime scope projection

- [x] 2.1 Define `TypeSlot` and `RuntimeTypeId` scopes and adapt existing key projections through CQTest RED/GREEN — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'type-scope-adapter-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'type scope adapter build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Identity'; Label = 'type-scope-adapter-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'type scope adapter test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Identity/AngelscriptNativeTypeScopeIdentityTests.cpp`

  > Constraints: The frontend key is the only identity producer. Existing Unreal/runtime structures are checked projections, not a second normalization authority. Do not resolve against or mutate a live Engine, publish a candidate, change VM opcodes, or change a persistence format.

  1. Add CQTest cases for artifact-local slot renumbering, duplicate and inconsistent requirement candidates, synthetic generations with different runtime IDs, wrong-owner rejection, durable-encoding rejection, collision buckets, and one-way legacy projections; build, run, and observe RED.
  2. Implement scoped wrapper types and adapt the existing hash/ABI declarations to consume canonical witnesses without reverse string parsing or Engine lookup.
  3. Rerun the exact Fast prefix to GREEN and prove the entire fixture operates without creating or mutating an `asCScriptEngine`.

## 3. Build and focused acceptance

- [x] 3.1 Compile the identity authority and adapters with an incremental Editor build — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_canonical_encoding.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_canonical_encoding.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.cpp`, `openspec/changes/angelscript/refactor-frontend-stable-type-identity/tasks.md`

  1. Run the incremental Development Editor build after all focused identity tests are GREEN.
  2. Repair only owned compile, include, export, and adapter issues.
  3. Record the managed build result and any evidence-driven verification expansion.

- [x] 3.2 Pass the exact NativeEngine Identity Fast area — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Identity'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Identity/AngelscriptNativeTypeDeclIdentityTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Identity/AngelscriptNativeTypeUseIdentityTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Identity/AngelscriptNativeTypeScopeIdentityTests.cpp`, `openspec/changes/angelscript/refactor-frontend-stable-type-identity/tasks.md`

  1. Run only `Angelscript.UnitTest.NativeEngine.Identity` through the Fast route.
  2. Record the managed run ID, pass/fail totals, and report path.
  3. Confirm the suite executes the lowercase `frontend` identity authority and checked adapters, not legacy stable-key parsing as the oracle.

## 4. Durable specification synchronization

- [x] 4.1 Create, synchronize, and strictly validate the stable type identity capability after verification — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-frontend-stable-type-identity','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'stable type identity Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-frontend-stable-type-identity/specs/angelscript/language/types/stable-identity/spec.md`, `openspec/specs/angelscript/language/types/stable-identity/spec.yaml`, `openspec/specs/angelscript/language/types/stable-identity/spec.md`, `openspec/changes/angelscript/refactor-frontend-stable-type-identity/tasks.md`, `openspec/changes/angelscript/refactor-frontend-stable-type-identity/attachments/INDEX.md`

  1. Create the missing current capability with `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create','angelscript/language/types/stable-identity','--title','Stable Type Identity','--json')`; never hand-author `spec.yaml`.
  2. Semantically merge the complete verified Requirements and Scenario Cards without delta-operation headings.
  3. Confirm final evidence refers to the current successful build and complete Identity Fast prefix, then run exact strict Change validation and strict current-spec validation before completing this terminal synchronization task.

  Intentionally omit aggregate Harness profiles, full UE suites, Standalone, Builder publication, and VM tests: the Change establishes identity and scoped projections without a production consumer or live Engine mutation.
