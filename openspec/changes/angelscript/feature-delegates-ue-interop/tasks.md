---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "2.1": ["1.3"]
    "2.2": ["2.1"]
    "2.3": ["2.2"]
    "3.1": ["2.3"]
    "3.2": ["1.2"]
    "3.3": ["2.2", "3.2"]
    "4.1": ["3.1", "3.3"]
---

## Authorization and execution boundary

This is a creation-only feature record. Every task remains unchecked. The workflow requires tasks.md even at proposal stage; the first node completes the remaining planning before product work becomes Ready. Neither a derived Ready planning node nor strict structural validation authorizes implementation. Do not start product tasks during record creation.

Read proposal.md and attachments/INDEX.md first. Task 1.1 owns completing design, durable deltas, exact interface contracts and any evidence-required changes to the pending cards. This graph is deliberately not advertised as a completed implementation-ready planning handoff until that node finishes. Later plan completion must use the applicable OpenSpec lifecycle Skills and preserve permanent IDs.

All paths below are repository-relative. Runtime work consumes the replacement execution/identity owners of angelscript/refactor-vm-symbolic-execution; do not duplicate its VM, source emitter, metadata fingerprints or generation-lifetime authority. The current host startup and legacy corpus remain dormant until a separately valid replacement host path exists. Unavailable host/VM prerequisites must be made explicit during 1.1, not discovered by silently enabling legacy services in a test. Do not modify the diagnostics/testing-framework Changes as a side effect.

## Language-surface prerequisite

The accepted language policy removes every Lambda form, source funcdef, script exception/coroutine syntax and AS BlueprintGetter/BlueprintSetter requests. This Change retains named free/member bindings, explicit payload values and UE delegate/event interoperability. It must not restore anonymous-function syntax, BindLambda/CreateLambda/AddLambda or lexical capture storage.

Consume `angelscript/refactor-language-surface-ue-focused` task 2.1's completed structured callable API and proof before executing product nodes here. Task 1.1 records that external prerequisite and the design's actual `asCCallableType` / `CreateCallableType` / `CreateCallableSignature` contracts. Its own design/spec work may proceed earlier, but it cannot finish while the required interface evidence is absent. Cross-change dependencies are explicit prose; local DAG IDs remain local. Runtime faults/unwind and host Context control are preserved.

## Future proving setup

After separate continuation authorizes the applicable work, import Harness in the current PowerShell 7 process and use the selected workspace:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
```

New C++ fixtures use replacement CQTest under WITH_ANGELSCRIPT_TESTS, live in Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/, and expose the public test area Angelscript.UnitTest.Delegates. Test class names in cards define the exact proving prefixes. Their classes/APIs are planned additions, not existing runner selections or callable symbols.

Before each changed-C++ proving phase, build the matching binary through Harness:

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }
```

For every behavior group, prepare its concrete related cases, observe grouped missing-behavior RED, implement that bounded outcome, and rerun the same selector for GREEN. Compile-enabling unavailable seams may be used when necessary; compilation failure alone or already passing controls are not behavioral RED. Record exact case identities, results, RunId, report path and source/binary identity. Freeze source writes during UE operations. Compatible selectors may share a justified actual run while retaining task-specific evidence. No unconditional full suite or performance gate is introduced.

## 1. Language contracts

- [ ] 1.1 Complete the delegate design, durable behavior deltas and executable prerequisite contracts — verify: `Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/feature-delegates-ue-interop', '--type', 'change', '--strict', '--json')`
  > Files: `openspec/changes/angelscript/feature-delegates-ue-interop/design.md`, `openspec/changes/angelscript/feature-delegates-ue-interop/specs/**/spec.md`, `openspec/changes/angelscript/feature-delegates-ue-interop/tasks.md`, `openspec/changes/angelscript/feature-delegates-ue-interop/attachments/INDEX.md`, `openspec/changes/angelscript/feature-delegates-ue-interop/attachments/data/planning-contracts.md`

  Consume the proposal and indexed evidence. Produce a decision-complete design, scenario deltas for the five named capabilities, and a complete requirement-to-task mapping. Strict validation proves record structure only; completion also requires all product cards to be executable without another design pass. No C++ or current-spec mutation belongs here.

  1. Resolve the exact existing VM/emitter/host services against their owning current records and source. Record which are implemented versus planned; consume their actual APIs. If a required replacement host lifecycle or runtime prerequisite is absent, apply an evidence-gated update with bounded prerequisite ownership before enabling dependent work. Do not mark this task complete while those contracts are unresolved.
  2. Specify actual public/internal interface names and types for binding expressions, explicit receiver/payload state, generation leases, native-event views and reflected descriptors. Set parameter conversion/error behavior, copy/destruction, weak receiver and managed payload treatment, runtime-fault boundaries, reload rejection, signature fingerprint inputs and AST/metadata format evolution. Keep the proposal's six-family scope and explicit exclusions.
  3. Specify real Blueprint and editor/cooked-load fixture construction, commands and artifact oracles. Replace any still-unavailable proving surface in pending cards with a supported exact Harness route or introduce the necessary bounded prerequisite. Do not substitute an editor-only fake for a cooked load.
  4. Write design/deltas and indexed contracts; refine pending cards through the matching update route where contracts change. Strictly validate and check every scope, interface, scenario, file owner and proof mapping. Leave all product tasks pending.

- [ ] 1.2 Normalize supported UE declaration forms into flavor-aware callable declarations — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.Declarations'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_decl*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_parser.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_codec.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_projection.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_ast_verifier.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/DeclarationTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Declarations/DeclarationSemanticTests.cpp`

  Consume the existing type parser, asCCallableTypeDecl and 1.1 flavor/identity contract. Produce the shared declaration-form lookup and resolved ordinary/dynamic classification for later binding and projection. Globs cover only callable declarations and their direct representation consumers; exclude legacy parser, text preprocessor, VM and unrelated AST changes.

  Cases: enumerate all 60 supported names with independently authored expected return/count/names/flavor; ordinary unnamed parameters; return type first; dynamic type/name pairs; nested generic commas; forward signature types; equivalent raw/form declarations in separate compilations; distinct nominal names; invalid arity; event int rejection; all 31 deferred spellings diagnosed; inactive invalid form ignored; recovery reaches the next valid declaration; diagnostics preserve the offending input range. Codec roundtrip retains flavor and rejects incompatible format versions.

  1. Prepare the declaration matrix and observe RED for unsupported forms/flavor and currently accepted nonvoid multicast. Keep existing callable identity cases as controls.
  2. Implement table-driven declaration parsing and shared validation/representation updates without source rewriting.
  3. Run grouped GREEN and retain case-to-form coverage, including every rejected deferred family.

- [ ] 1.3 Resolve typed free/member references and binding operations — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.BindingSemantics'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_expr*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema*.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/BindingSemanticTests.cpp`

  Consume 1.2 signatures and 1.1 binding-expression contract. Produce resolved callee/receiver/dispatch and payload argument plans for source lowering. Package globs permit only callable-reference/binding nodes and direct consumers, excluding unrelated operators, diagnostics infrastructure and legacy code.

  Cases: select the int overload for delegate void(int); reject bool-only target, inaccessible member, foreign receiver and const-to-nonconst binding; preserve virtual target dispatch; reject incompatible ref/out or return types; accept ordinary script member without UFUNCTION; require reflected target eligibility for dynamic forms; diagnose unregistered C++ target. Both Bind and Create use the same checks.

  1. Observe grouped RED for absent member-reference and binding-expression semantics.
  2. Implement semantic binding plans and source-accurate rejection without constructing runtime objects.
  3. Prove AST identity/dispatch and diagnostic outcomes in GREEN; do not claim execution until 2.1.

## 2. Executable callable model

- [ ] 2.1 Execute ordinary free/member delegates through the replacement runtime — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.Execution'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callable*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/ExecutionTests.cpp`

  Consume resolved binding plans and the owning VM Change's implemented indirect-call/emitter/lifetime services. Produce callable construction, copy/release, invocation and explicit generation invalidation. Existing-owner globs permit only delegate lowering/runtime wiring; no second interpreter, raw persistent address format, unrelated opcode work or legacy activation.

  Cases: source-created free function AddOne(41) returns 42; bound member adds receiver value; base-typed receiver calls derived virtual implementation; copied callback retains valid target after original reset; empty Execute fails without output writes and empty void ExecuteIfBound skips; retired generation refuses entry; invalidation then destruction releases ownership once. Actual execution is required.

  1. Prepare source execution/lifetime fixtures with independent values and counters; observe RED for missing construction/invocation/invalidation.
  2. Wire the shared callable representation into the existing executor and emitter using 1.1's exact ownership contract.
  3. Run GREEN, proving return/output values and release counts rather than only emitted instruction shapes.

- [ ] 2.2 Store explicit named-target payloads and receiver state with managed lifetime — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.Payloads'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema_postfix.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_expr*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callable*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode*`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/PayloadTests.cpp`

  Disposition: preserved task ID, revised pending outcome by the user-approved language-surface replan. Consume 2.1 and 1.1's explicit payload/receiver schema. Produce bind-time value initialization, copy/destruction and typed trailing payload invocation for named functions/members. Package globs cover only those binding-state consumers and their format evolution. No Lambda node, lexical capture parser, anonymous function conversion or boxed legacy wrapper is included.

  Cases: named AddOffset(Value, Offset) bound with Offset=10 returns 15 for Execute(5) after the factory returns; later changing the factory's local Offset does not change the stored value. A managed handle payload retains its object until the final callback owner releases it; an escaping local-stack reference payload rejects. Result=200 and stored RequestId=7 reach the named handler arguments (200,7). Copy/reset/runtime-fault paths destroy counted payload values exactly once. Incompatible payload layout cannot rebind as compatible. A weak UObject member receiver is not kept alive by receiver storage. Anonymous function syntax and Lambda-specific Bind/Create variants remain rejected.

  1. Prepare payload lifetime and named-target invocation fixtures, then observe RED for missing explicit payload storage/execution; existing Lambda rejection is a retained control.
  2. Implement typed receiver/payload binding state and its call adapter using canonical callable metadata; do not add a capture environment or Lambda producer.
  3. Run grouped GREEN including runtime-fault cleanup and compatibility failures. Record exact payload values, argument order and release counts; defer allocation tuning until measured.

- [ ] 2.3 Implement multicast subscription handles and deterministic mutation boundaries — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.Multicast'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_callable*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_multicast*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema_postfix.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/MulticastTests.cpp`

  Consume 2.2 callback ownership. Produce subscription-domain handles, Add/Remove/RemoveAll/Clear and broadcast over owned script events. Exclude UE native container semantics and reflection materialization.

  Cases: two callbacks observe value 42; removal leaves only its distinct peer; duplicate Add produces two subscriptions; unique member binding deduplicates; copied event has independent handle domain; stale/foreign handle cannot remove another entry; newly added callback misses current round; removed pending callback is skipped; nested broadcast sees current membership; runtime fault stops script broadcast and cleans temporary ownership; destruction during valid teardown releases receiver/payload ownership once. Do not assert incidental listener ordering.

  1. Prepare the mutation/identity matrix with observable logs and release counts; observe RED for absent subscription behavior.
  2. Implement the proposal's handle and broadcast contracts with explicit reentrancy-safe lifetime.
  3. Prove grouped GREEN and no memory-derived payload equality.

## 3. Unreal interoperability

- [ ] 3.1 Adapt registered native C++ delegates and live multicast members — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.NativeInterop'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/DelegateAdapters/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/NativeInteropTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/DelegateNativeFixtures.*`

  Consume 2.3 and compiled typed adapter interfaces from 1.1. Produce real TDelegate values for exposed signatures and borrowed native-event views retaining original instance/native handles. Binds glob excludes legacy runtime restoration; adapter fixture types stay in the plugin test module.

  Cases: registered TDelegate<int(int)> retains a returned named AddOffset callback and yields 42 from input 2 with explicit payload 40; mismatched signature fails before native callback entry; native multicast broadcasts reach a script subscriber and stop after exact handle removal; subscribe/unsubscribe operates on the original object, not a copy; invalid UObject weak binding is skipped; weak UObject member binding does not retain the receiver or validate unrelated payload objects; native-boundary callback failure follows 1.1's defined return/error contract without unwinding illegally through C++ frames. Native teardown after script invalidation is safe.

  1. Prepare real compiled native fixtures and source-driven binding; observe missing-adapter/weak-lifetime RED.
  2. Implement typed adaptation, native handle ownership and receiver policy without runtime C++ template generation or storage reinterpretation.
  3. Execute GREEN against original host delegates and independent values/lifetime counters.

- [ ] 3.2 Materialize dynamic signature functions and reflected delegate properties — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.Reflection'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.*`, `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/DelegateReflection/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates_Type.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/ReflectionTests.cpp`

  Consume 1.2 resolved flavor-aware signatures and 1.1's replacement host lifecycle. Produce complete UDelegateFunction and FDelegateProperty/FMulticastInlineDelegateProperty with valid parameter flags/layout and instance storage. Do not derive signatures from generated methods, mutate AST-time UObjects or materialize sparse delegates.

  Cases: dynamic float OldValue/NewValue signature preserves names/types and multicast flags; return-bearing single delegate preserves return property; a BlueprintAssignable dynamic event property points to the canonical signature; ordinary event with BlueprintAssignable is rejected; nonreflectable signature rejects atomically with no public partial class; two modules with same short delegate name do not collide; property construction/copy/destruction use native UE-compatible storage. Resolve descriptors without UE pointers as a frontend control.

  1. Prepare host materialization fixtures; observe RED for missing complete signatures/property publication.
  2. Implement staged reflection construction against resolved descriptors and explicit host registration.
  3. Prove real UObject/property state and failure atomicity in GREEN; invocation belongs to 3.3.

- [ ] 3.3 Execute dynamic delegates between script, native UFunctions and Blueprint listeners — verify: `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.DynamicInterop'; Fast = $true; TimeoutMs = 600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/DelegateReflection/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASFunction*`, `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates*`, `Plugins/Angelscript/Source/AngelscriptEditor/DelegateInterop/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/DynamicInteropTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/DelegateReflectionFixtures.*`

  Consume 2.2 executor and 3.2 signatures/storage. Produce typed BindDynamic/AddDynamic target validation, UE parameter marshalling and script UFunction invocation bridges. Broad ASFunction/Binds patterns cover delegate-required adapter changes only; exclude restoration of unrelated old host behavior.

  Cases: script broadcasts health (100,75) and a compiled real Blueprint listener records both values; a real UE dynamic delegate invokes a script UFUNCTION and observes expected state/output; void unbound path skips; compatible struct and ref/out arguments roundtrip with correct lifetime; missing UFUNCTION target fails at typed bind analysis; dead receiver is not invoked; callback failure leaves frame/temporary state reusable. No descriptor-only assertion can substitute for execution.

  1. Build the actual Blueprint/native/script fixture selected in 1.1 and observe RED for missing invocation bridges.
  2. Implement both directions over real reflection storage and the replacement executor.
  3. Run GREEN and retain listener values, return/output values and frame/payload release oracles.

## 4. Host lifecycle acceptance

- [ ] 4.1 Prove delegate host loading, invalidation and integrated ownership — verify: `Actual editor and cooked fixture runs both report the independently specified delegate values and exit successfully; reload mismatch refuses callback entry and releases all test-owned bindings`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/DelegateReflection/**`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/DelegateInterop/**`, `Plugins/Angelscript/Source/AngelscriptEditor/DelegateInterop/**`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/LifecycleTests.cpp`, `Plugins/Angelscript/Content/Tests/Delegates/**`, `openspec/changes/angelscript/feature-delegates-ue-interop/attachments/data/integration-evidence.md`, `openspec/changes/angelscript/feature-delegates-ue-interop/attachments/INDEX.md`

  Consume both real bridge paths and 1.1's exact supported Harness editor/cook/run fixture contract. This is the only card allowed to add delegate-owned plugin test assets. Use only explicit Harness ue.* routes for cooking, processes and observations; root wrappers or unmanaged child workers are not substitutes. It cannot enter Ready without exact executable routes, artifact paths and host prerequisites being fixed by 1.1.

  Cases: a dependent Blueprint asset loads only after complete script reflection publication in editor and a real cooked fixture; dynamic broadcast delivers (100,75); native retained named-target callback with explicit payload returns 42; same stable name with incompatible signature/payload layout cannot re-enter stale code; active callback completion and subsequent invalidation follow the generation lease; native and reflected bindings release safely on teardown; unrelated script behavior and dormant startup controls are preserved. No automatic payload-state migration or engine patch belongs here.

  1. Prepare startup/reload/integrated fixtures and observe actual missing lifecycle behavior before implementing repairs within the declared boundary.
  2. Wire delegate registration/invalidation into the existing replacement host lifecycle. An unavailable broader host service triggers prerequisite replan rather than scope creep.
  3. Execute the editor and cooked proofs, retain source/binary/asset identities and exact outputs, and reconcile every task's discovered cases. Reuse valid focused evidence; expand only for demonstrated shared-contract impact. Later verification/spec-sync/archive remain separate lifecycle operations.

## Acceptance mapping

| Proposal outcome | Owning tasks |
|---|---|
| Decision-complete design/specification and runtime/host prerequisites | 1.1 |
| 60 declaration forms, 31 diagnostics, flavor/identity/codec | 1.2 |
| Typed symbols, overloads, receiver/const/access rules | 1.3 |
| Executable ordinary callable and generation lifetime | 2.1 |
| Explicit named-target payload and receiver lifetime | 2.2 |
| Multicast subscriptions, copy domains and mutation | 2.3 |
| Native adapters, live event views and weak UObject policy | 3.1 |
| Dynamic reflection descriptors, signatures and properties | 3.2 |
| Blueprint/native/script dynamic invocation | 3.3 |
| Host loading, cooked execution, invalidation and teardown | 4.1 |

No task was executed during creation. The creation check is strict OpenSpec validation plus scoped record/link/DAG inspection. C++ builds, Automation, editor/cooked fixtures, benchmarks and broader Harness suites are intentionally omitted because no product or workflow implementation changed.
