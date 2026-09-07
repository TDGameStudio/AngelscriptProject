---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
    "3.1": ["2.2"]
    "4.1": ["3.1"]
    "5.1": ["4.1"]
    "5.2": ["5.1"]
---

## Delivery and execution boundary

The accepted delivery is Change creation and adjacent delegate-plan alignment only. All eight product/verification nodes remain unchecked. Do not treat the creation validation or derived Ready state as implementation authorization. Read proposal.md, design.md and attachments/INDEX.md before later apply. All implementation belongs to the current workspace and Plugins/Angelscript; no new worktree, legacy startup, UE engine patch or host project implementation.

Each basename/package glob below is bounded to the named feature's producer, representation and direct consumers. Exclude `Legacy/**`, old test corpus, generated JIT outputs and unrelated features unless an explicit compiled public-header boundary is named. Common evidence updates belong in this tasks.md card, not a second task ledger. The linear DAG serializes overlapping SDK/frontend consumers and snapshot evidence; it is not a requirement to start one UE process per test.

## Future verification setup

Use replacement CQTest and `WITH_ANGELSCRIPT_TESTS`. New LanguageSurface classes expose `Angelscript.UnitTest.NativeEngine.LanguageSurface.<Class>.<Method>`; preserve existing VM identities except a test explicitly dedicated to removed Lambda/funcdef authoring. Use `TEST_CLASS_WITH_FLAGS` with suite `Angelscript.UnitTest.NativeEngine.LanguageSurface` and the class names below. No product tests ran during creation.

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
Invoke-Harness -Command workspace.activate -Context $context
Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }
```

Build changed C++ before each proving binary. Freeze source writers during build/test. Prepare a feature group's related positive/negative/boundary fixtures together, observe expected RED, implement and observe GREEN. Existing rejections and runtime controls may be baseline GREEN: do not manufacture failures or claim compile errors as RED. A minimal compilable renamed-API seam is permitted to reach real missing-behavior RED. Shared proving runs retain exact task-to-case outcomes and source/binary identity.

## 1. Source language

- [ ] 1.1 Enforce removed declaration/control syntax and preserve host parameterization — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.LanguageSurface.Syntax'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_language_surface.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_token_kinds.def`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_identifier_table.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LanguageSurface/SyntaxTests.cpp`

  Consume existing Parser/Sema and preprocessed input. Produce `asERemovedLanguageFeature` and `DiagnoseRemovedFeature` as specified in design; task 1.2 consumes AnonymousFunction reporting. This node handles shared/external declarations, funcdef, try/catch/throw, coroutine/yield, user template declarations/specialization and virtual properties/decorators, not Lambda product deletion or SDK migration.

  Cases: `shared class C {}`, `external class C {}`, shared/external function declarations and `funcdef int Callback(int);` reject their specific feature; `try { Work(); } catch {}` and `throw 1;` reject; coroutine/yield statement forms reject without banning a host function merely named yield. `template<class T> class Box { T Value; }`, a function-template declaration and explicit specialization reject. `int Value { get { return 1; } set {} }` and `int get_Value() property` reject. A following `int Good(){return 7;}` remains visible for diagnostics but the compilation cannot publish. Inactive copies under a false configured conditional do not fail. Ordinary get/set-named calls return 7; get_Value alone does not create Value. Registered parameterized-type fixtures accept nested type arguments and reject wrong arity/unknown providers; established Cast<T> control and supplied-file/external-definition lookup retain their prior semantics. These preservation controls do not add a UE TArray implementation.

  1. Prepare the full Syntax group with source ranges and named feature oracles. Separate existing generic syntax errors from missing explicit removed-feature diagnostics/recovery.
  2. Implement grammatical-position checks and recovery using current diagnostic APIs. Preserve identifiers, inactive input and host-only facilities; do not introduce feature switches.
  3. Build and run the exact Syntax selection. Record which cases were baseline GREEN and which observed RED/GREEN.

- [ ] 1.2 Remove Lambda semantics and reject retired semantic artifacts — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder_frontend.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_emitter*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**`

  Package scope is Lambda parsing/Sema, taxonomy, typed nodes, visitors/projection/codec/verifier, Lambda identity/origin, definition/lowering consumers and their tests only; exclude unrelated grammar and runtime work. Produce no active Lambda construction path and explicit AnonymousFunction diagnostics using 1.1. This broad NativeEngine selector is required because typed AST codecs, definition origins and identity share consumers beyond body tests.

  Cases in new `LanguageSurface.Lambda`: immediate `function(int V){return V+1;}(41)`, stored anonymous function, explicit empty capture-list and value/reference capture-list forms all reject and produce no publishable image. Retired Lambda node/origin encodings and prior incompatible format versions reject; an ordinary named-function AST roundtrip keeps identities/ranges and a named AddOne(41) executes 42. Convert Lambda-only positive tests to rejection controls; preserve named-call and retained metadata lease tests. Identity wire ordinals remain reserved, not reassigned.

  1. Observe RED for currently accepted noncapturing Lambda and retired product admission; retain already rejected capture controls honestly.
  2. Remove the owned semantic path, `SetLambdaOrigin` and Lambda-only consumers. Version incompatible affected formats and migrate ordinary codec controls without old-name aliases.
  3. Build and run NativeEngine; retain exact new Lambda cases plus affected AST/identity/Builder regression cases and explain removed public test identities.

## 2. SDK surface and retained runtime behavior

- [ ] 2.1 Replace funcdef SDK interfaces with structured callable metadata — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AngelscriptLambda*`, `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**`

  Bounded SDK package ownership covers the exact funcdef-to-callable mapping in design and direct compiled ABI/GC/linker/fingerprint/definition consumers; it does not authorize unrelated VM rewrites or new UE delegate features. Existing dormant bind sources may only lose obsolete interfaces or have their isolation boundary repaired; they must not be activated. Produce `asCCallableType`, `CreateCallableType`, `IsCallableType`, callable signature/child queries and retained `CreateCallableSignature`. Remove string RegisterFuncdef and Engine funcdef enumeration, with no compatibility aliases. The delegate Change consumes this completed interface and evidence.

  Cases in new `LanguageSurface.CallableSDK`: two nominal delegate/event types share one structural signature but keep distinct nominal keys; manual named callback definition freezes/registers and executes 42 through indirect call; return-type mismatch rejects without installing; native generic invocation returns 42; receiver ownership releases exactly once; retained metadata survives producer release. Migrate existing VMDispatch/VMNativeABI/VMCache/Definitions/Identity oracles to the new names without deleting their assertions. Add C++ dependent-requires compile assertions for absence of RegisterFuncdef/GetFuncdefCount/GetFuncdefByIndex and old member queries. Record static absence of old type aliases in maintained public headers. Preserve stable keys for retained equivalent callable contracts and bytecode opcode ordinals.

  1. Prepare behavioral contracts and compile-time API-absence checks; preserve existing dispatch/ABI/GC outcomes as baseline controls. Use only minimal new-name seams to reach behavioral RED.
  2. Migrate factories, signatures, public queries and direct consumers in one coordinated buildable slice; remove old wrappers, not the actual runtime services.
  3. Build and run NativeEngine, including native calls, dispatch, GC, executable leases and cache. Verify the public-header migration list has no live compatibility alias. NativeEngine is justified by the shared type and runtime contract.

- [ ] 2.2 Remove shared-module/accessor SDK policy while preserving engine-owned inputs and Context control — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.LanguageSurface.SDK'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typeinfo.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_objecttype.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_module.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_configgroup.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**`

  Only shared declaration policy, legacy module-management/provenance exposure, accessor-mode flags and their direct compile consumers are owned. Preserve ordinary external definitions, source/module keys, host templates and native generic calls. Remove IsShared/SetShared and policy-driven owner reassignment, accessor configuration and obsolete source-import/module compilation interfaces. Read-only retained provenance uses stable source/definition identities rather than mutable legacy module pointers. Dormant compatibility objects remain isolated rather than forcing old runtime restoration.

  Cases: two supplied files resolve/execute a named cross-file call to 7 without shared flags; frozen external provider calls still succeed; failed provider/link leaves installed code unchanged; ordinary get_Value call works while implicit Value access rejects. C++ compile assertions show removed sharing/accessor-policy interfaces are absent. A host callback suspends and resumes to 42; abort cleans roots; runtime division failure cleans a counted local and a subsequent function returns 97; native generic Add(20,22) returns 42. These are retained-runtime controls, not new script coroutine/exception features. Unknown removed engine-property numeric options cannot silently re-enable policy.

  1. Prepare SDK controls plus source/header rejection assertions, observing RED for surviving public policy interfaces while retaining runtime baseline GREEN.
  2. Remove only the owned policy and migrate compiled consumers. Do not change C++ exception settings, VM error statuses, suspension opcodes or GC algorithms.
  3. Build and run the SDK group. Record actual engine-input, Context and cleanup values as the handoff for final regression.

## 3. Reflection authoring

- [ ] 3.1 Reject AS Blueprint accessor metadata and remove its dedicated consumers — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.LanguageSurface.Reflection'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptDescriptors.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LanguageSurface/ReflectionTests.cpp`

  Own only AS-authored BlueprintGetter/BlueprintSetter validation, dedicated descriptor fields and their production/consumption; do not edit UE native reflection or ordinary metadata. Binds scope is an actual accessor-metadata consumer only. No legacy runtime activation is permitted for tests.

  Cases: UPROPERTY(BlueprintGetter=Read), UPROPERTY(BlueprintSetter=Write), corresponding UFUNCTION markers and nested meta/UMETA forms reject at the marker range and return no publishable descriptor set. Unknown unrelated metadata continues through the existing policy. UPROPERTY(BlueprintReadWrite) int Value plus explicit UFUNCTION Read/Write methods projects ordinary field/function descriptors with stable keys. False conditional accessor requests are ignored. Ordinary names never synthesize an accessor. No dedicated Blueprint accessor field remains in active descriptor output.

  1. Prepare source-to-descriptor cases together; observe RED for currently accepted or silently projected accessor metadata.
  2. Validate at the semantic attribute boundary, then remove dedicated legacy producer and maintained generator handling. Preserve generic metadata storage and native host metadata.
  3. Build and run Reflection. Static inspection verifies no active getter/setter-specific association callback remains; no claim of UE materialization or Blueprint execution follows.

## 4. Library distribution

- [ ] 4.1 Remove upstream add-on packages and their dedicated dependency chain — verify: `python Plugins/Angelscript/Standalone/Tests/CheckRemovedAddons.py`
  > Files: `Plugins/Angelscript/Standalone/ThirdParty/AngelScriptAddons/**`, `Plugins/Angelscript/Standalone/CMakeLists.txt`, `Plugins/Angelscript/Standalone/Source/**`, `Plugins/Angelscript/Standalone/Tests/**`, `Plugins/Angelscript/Standalone/README*`, `Plugins/Angelscript/Standalone/docs/**`

  Scope is the four removed packages and exact package-dependent includes, link targets, registrations, runtime/runner operations, fixtures and documented distribution claims. Keep unrelated standalone architecture/CLI adapters. Produce CheckRemovedAddons.py as a bounded read-only audit with explicit ignored build/output directories, self-exclusion and documented historical exclusions. It checks package absence and forbidden dependency symbols/paths in retained nonhistorical manifests/source/tests/docs; it does not reject arbitrary host array/string/math identifiers. No standalone build revival or substitute library is included.

  Cases: original package/CMake/include/registration references fail the audit; a temporary fixture with an introduced forbidden add-on include must fail even after package deletion; unrelated host TArray/FString/C++ standard-library references pass. Remove exclusively add-on tests; remove package-dependent subcases and exclusively dependent operations from mixed consumers, with their callers/help claims. Retained mixed CLI operations report an explicit unsupported-library outcome before invocation if their advertised optional library argument selects a removed package. Do not leave a successful no-op registration or unresolved CScriptArray type.

  1. Write and self-check the audit; run against the current tree and observe package/dependency RED. Enumerate the exact affected mixed consumers from the inventory.
  2. Delete packages and exclusive targets/tests, remove or explicitly reject the specified dependent operations, and update distribution identity/help. Preserve Standalone and preexisting unrelated missing SDK source references.
  3. Run the audit GREEN and negative self-control. Record that this proves reference cleanup only; final UE build proves the active product boundary.

## 5. Completion evidence

- [ ] 5.1 Prove the reduced language and retained NativeEngine contracts on one current binary — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/data/implementation-verification.md`, `openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/INDEX.md`, `openspec/changes/angelscript/refactor-language-surface-ue-focused/tasks.md`

  Consume completed 1.1-4.1 and build the current unchanged source through Harness. Produce exact source/binary SHA-256, build/test RunIds, discovered case identities, retired-case explanations, interface absence evidence and requirement mapping. Whole NativeEngine is justified by AST/identity/fingerprint/ABI/linker/GC/Context shared contracts. Verify hand-authored bytecode, source execution and decode/link execution remain independent producer oracles. Confirm the delegate Change refers to the new callable interface and prohibits Lambda; do not complete its tasks. No product fix is owned by this evidence node: ordinary owner defects return to their owning work; invalidated boundaries receive a follow-up plan without unchecking history.

- [ ] 5.2 Prove dormant startup and record terminal verification boundaries — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Baseline'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/data/implementation-verification.md`, `openspec/changes/angelscript/refactor-language-surface-ue-focused/attachments/INDEX.md`, `openspec/changes/angelscript/refactor-language-surface-ue-focused/tasks.md`

  Use the 5.1 binary without intervening source changes. Require Baseline's real startup dormancy cases to execute, retain warnings accurately, and ensure no script engine/watcher legacy services were enabled. Record omitted standalone/JIT/full UE/performance tests with scope reasons. Later spec synchronization, terminal evolution evidence and archive use the owning lifecycle skills; no routine Review is introduced and no existing Review is implicitly closed.

## Requirement and cross-change mapping

| Contract | Task owners |
|---|---|
| Permanent source boundary and host parameterization | 1.1, 1.2 |
| Lambda-free semantic products and persisted rejection | 1.2 |
| Structured callable SDK and preserved signatures/ABI/GC | 2.1 |
| Engine-owned membership and runtime fault/Context retention | 2.2 |
| Blueprint accessor authoring and consumer removal | 3.1 |
| Removed upstream library distribution | 4.1 |
| Integrated source/bytecode/runtime and startup proof | 5.1, 5.2 |

Delegate Change task 1.1 remains its own planning prerequisite and checks this Change's 2.1 interface completion before delegate product work. The two records never encode foreign task IDs into local frontmatter. VM Change completed history is preserved; current tests of retained behavior are migrated, not dropped to inflate GREEN counts.
