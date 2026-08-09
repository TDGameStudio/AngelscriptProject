# Direct Manual Binding Callback Architecture — Implementation Tasks

This checklist is updated incrementally as source implementation and focused verification land.

## Implementation Constraints

- Keep exactly one process-wide callback-record collection; do not add subsystem bind storage or expanded binding descriptions.
- Every `FAngelscriptBind` explicitly declares one `EAngelscriptBindPhase`.
- Keep direct registration: each full engine replays the sealed callbacks.
- Do not redesign `FAngelscriptType`, type-usage semantics, AngelScript Generic Calling Convention, or existing generic-call marshalling. Only route binding-side access through explicit engine-owned targets where required.
- Preserve complete declaration strings, callable/macro/lambda forms, StaticJIT/native metadata, reflection/RPC routing, `Binds.Cache`, and generated POD layouts.
- Production hand-written project-owned AS callables use stable named `FAngelscript<Name>Binds` entries; keep DSL lambda overloads and do not add per-function metadata, per-call tracing, blanket no-inline, or empty `_Functions` pairs for pointer-only binds.
- Former ordinary lambdas remain ordinary function-pointer registrations. Preserve existing `FUNC`/`FUNC_TRIVIAL`/custom-native/template-native classification and link/include visibility exactly where it already exists.
- Do not add dependencies, priorities, runtime disabling, direct-provider dynamic unload/replay, central manifests, or a dual binding architecture. Preserve the existing NativeModuleFunctionAddress transport as the only documented exception.
- New C++ test files use the `Angelscript` prefix and project test commands only.

## 0. Baseline and Migration Evidence

- [x] 0.1 <!-- Non-TDD --> Capture `rg` inventories for `FAngelscriptBinds::FBind`, `RegisterBinds`, `CallBinds`, `GetSortedBindArray`, `EOrder`, every integer order expression, PreviousBind getters/setters, `DisabledBindNames`, binding `StartupModule()` submission, native-module arrival/unload hooks, auxiliary fallback access, provider-like sources outside `Binds/`, every direct AS callable lambda, every project-owned named direct callable, and every `FUNC`/`FUNC_TRIVIAL`/custom-native/template-native form; save counts and file lists under this change.
- [x] 0.2 <!-- Non-TDD --> Create `openspec/changes/refactor-as-manual-binding-architecture/order-migration.md` mapping every manual integer/Early/Normal/Late expression and UHT-generated offset to `TypeDeclarations`, `TypeInfrastructure`, `ExplicitBindings`, `GeneratedBindings`, `ReflectionBindings`, `PostReflectionBindings`, or `Finalization`, including the required callback split or local merge.
- [x] 0.3 <!-- Non-TDD --> Capture pre-migration `FAngelscriptStateDump` output, binding timing/allocation observations, `Binds.Cache` create/load evidence, UHT/CodeGen fixtures, and representative `FColor`, `FVector`, FString-format, reflection, RPC, generic-call, GameplayTags, and GAS behavior.
- [x] 0.4 <!-- Non-TDD --> Add source-architecture guards that reject new public binding Registries/manifests, dependency/priority APIs, runtime bind-disable fields, binding submission in `StartupModule()`, subsystem binding members, expanded binding-operation caches, new uses of integer `EOrder`, and inline lambdas passed directly to production hand-written AS callable registration APIs. Keep focused DSL lambda fixtures and non-AS-entry type-finder/local/delegate/async lambdas outside the callable guard.
- [x] 0.5 <!-- Non-TDD --> Confirm in the change record that parser/compiler/VM, Standalone, `FAngelscriptType` semantics, generic-call marshalling, and native-module POD layouts require no redesign.
- [x] 0.6 <!-- Non-TDD --> Create `openspec/changes/refactor-as-manual-binding-architecture/callable-migration.md` with one row per production hand-written bind: current callable form, future `Bind_<Name>_Functions.h/.cpp` ownership or pointer-only exemption, primary `FAngelscript<Name>Binds` owner, template/header exception, existing native/trivial form, required export/include visibility, and focused regression prefix.
- [x] 0.7 <!-- Non-TDD --> Create and strictly validate record-only follow-up `refactor-as-native-module-binding-preseal-transport`; document the circular Runtime/target-module dependency that prevents direct target-shard `FAngelscriptBind` construction and keep the current POD layout/version unchanged here.

## 1. File-Static Callback Collection

**Primary files:** `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`, and new `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptDirectBindCallbackTests.cpp`.

- [x] 1.1 <!-- TDD --> Add failing local-collection tests for required logical name/phase, automatic owner/source capture, `void(*)(FAngelscriptBinds&)`, multiple binds per source file, metadata-only construction, and rejection of empty callback records.
- [x] 1.2 <!-- TDD --> Implement `EAngelscriptBindPhase`, standalone `FAngelscriptBind`, the compact internal record, and one function-local static process collection; keep the outer callback non-capturing and do not expose a public Registry or handle.
- [x] 1.3 <!-- TDD --> Add failing permutation tests for fixed phase order and stable same-phase sorting by owner, bind name, source file, and source line, independent of append/module order.
- [x] 1.4 <!-- TDD --> Implement in-place validate/sort/seal without creating a second array; make finalization idempotent and make the engine execution view const.
- [x] 1.5 <!-- TDD --> Add duplicate-identity and late-append tests asserting module/name/phase/source diagnostics and restart-required behavior.
- [x] 1.6 <!-- TDD --> Implement duplicate/late failure handling with no replay, rebuild, unregister, or mutation of the sealed order.
- [x] 1.7 <!-- TDD --> Add an execution test proving two passes reuse the same backing collection, never call `GetSortedBindArray`, and invoke callbacks in identical order.
- [x] 1.8 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label direct-bind-collection -TimeoutMs 1800000 -NoXGE` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture.Collection" -Label direct-bind-collection -TimeoutMs 600000`.

## 2. Subsystem-Coordinated Module Load and Seal

**Primary files:** `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSubsystem.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptRuntimeModule.cpp`, and new `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptManualBindingArchitectureTests.cpp`.

- [x] 2.1 <!-- TDD --> Add failing lifecycle tests asserting `BindModules.Cache` modules load on the Game Thread before collection finalization and before primary-engine callback execution.
- [x] 2.2 <!-- TDD --> Move generated binding module discovery/loading from the AnyThread engine binding path into subsystem-coordinated pre-engine startup, then finalize the global collection.
- [x] 2.3 <!-- TDD --> Add structural tests asserting `UAngelscriptSubsystem` has no bind array, pointer view, expanded-data cache, registration handle, or callback ownership member.
- [x] 2.4 <!-- TDD --> Add a no-`GEngine` compatibility test proving RuntimeModule startup uses the same idempotent load/finalize operation and does not create a second collection.
- [x] 2.5 <!-- TDD --> Implement the mutually exclusive compatibility call path while keeping the global collection as the sole metadata owner.
- [x] 2.6 <!-- TDD --> Add failure tests for missing generated modules, invalid records, duplicate identities, and late native modules, asserting primary engine initialization does not start or publish.
- [x] 2.7 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Subsystem.BindLifecycle" -Label direct-bind-subsystem -TimeoutMs 600000`.

## 3. Explicit-Engine Direct Binding Context

**Primary files:** `AngelscriptBinds.h/.cpp`, `AngelscriptEngine.h/.cpp`, existing engine-owned database/store classes, and new `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptExplicitBindContextTests.cpp`.

- [x] 3.1 <!-- TDD --> Add failing tests that construct `FAngelscriptBinds` for Engine A or Engine B and assert class/global/property registrations, bind state, type database, BindDB, and provenance mutate only the selected engine.
- [x] 3.2 <!-- TDD --> Add `FAngelscriptBinds(FAngelscriptEngine&)` and instance accessors for the target AS engine and engine-owned stores; preserve the established typed class/global/enum authoring surface.
- [x] 3.3 <!-- TDD --> Change stored callback execution to receive the explicit `FAngelscriptBinds&`; remove callback-array copying and sorting from `BindScriptTypes()`.
- [x] 3.4 <!-- TDD --> Add an ambient-access guard test that fails if completed binding callbacks/helpers call `FAngelscriptEngine::GetCurrent()` or write an unpartitioned fallback for a binding mutation.
- [x] 3.5 <!-- TDD --> Migrate binding-side type database, BindDB, ToString, interface-signature, well-known-slot, string-factory/default-array, and StaticJIT/native metadata access to explicit instance targets without changing their domain semantics.
- [x] 3.6 <!-- TDD --> Add two-engine and recreation tests for distinct AS ids/pointers, type database, BindDB, ToString, finders, interface state, and teardown while sharing the same callback backing array.
- [x] 3.7 <!-- TDD --> Add focused generic-call regression tests proving direct/generic registration, `asIScriptGeneric` marshalling, ASAutoCaller, call convention, userdata, and generic bind behavior are unchanged; do not refactor generic-call internals without a failing compatibility case.
- [x] 3.8 <!-- TDD --> Add focused `FAngelscriptType` regression tests for type usage, template/subtype resolution, matching, and registration behavior; limit source edits to explicit target routing needed by this binding architecture.
- [x] 3.9 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture.ExplicitContext" -Label direct-bind-context -TimeoutMs 600000` plus the existing generic-call and multi-engine prefixes identified in task 0.3.

## 4. Direct Fluent Function and Property Results

**Primary files:** `AngelscriptBinds.h/.cpp`, documentation/native/StaticJIT binding helpers, new `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptDirectBindFluentTests.cpp`, and new `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptNamedBindCallableTests.cpp`.

- [x] 4.1 <!-- TDD --> Add failing tests that member/free/global/constructor/behaviour registrations return `FAngelscriptBoundFunction`, property registrations return `FAngelscriptBoundProperty`, and discarded values remain valid.
- [x] 4.2 <!-- TDD --> Implement the two small explicit-engine result values with validity/failure propagation and no global/provider lifetime role.
- [x] 4.3 <!-- TDD --> Add interleaved function/property and two-engine tests proving chained traits always target the exact stored result rather than the most recently registered object.
- [x] 4.4 <!-- TDD --> Implement editor-only, deprecation, accessor, no-discard, world-context, callable/generated-accessor, implicit-constructor, compile-out, forced-const, output-type, script-function/object injection, documentation, native/trivial, and pure-constant fluent operations.
- [x] 4.5 <!-- TDD --> Add injected registration-failure tests proving an invalid bound result preserves the first AS diagnostic, mutates no other result, stops later providers, and prevents engine publication.
- [x] 4.6 <!-- TDD --> Add focused callable-form tests proving member/free pointers, explicit overloads, `METHOD`/`METHODPR`/`FUNC`, trivial/native macros, and supported non-capturing method/global/constructor lambdas still compile and register through the explicit facade; keep this compatibility fixture separate from the production named-callable source rule.
- [x] 4.7 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture.Fluent" -Label direct-bind-fluent -TimeoutMs 600000` and the focused Color/Vector binding prefixes.

## 5. Seven-Phase Manual Provider Migration

**Primary files:** `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.cpp`, colocated `Bind_*_Functions.h/.cpp`, provider-like Runtime/Editor helpers found by task 0.1, new `Plugins/Angelscript/Source/AngelscriptTest/Core/AngelscriptBindSourceLayoutTests.cpp`, and corresponding CQTest binding coverage.

- [x] 5.1 <!-- TDD --> Migrate `Bind_FColor.cpp` into explicit phase callbacks and a `Bind_FColor_Functions.h/.cpp` family with one primary `FAngelscriptFColorBinds` owner; preserve every declaration, constructor, property, method, namespace function, trait, callable behavior, and focused script-visible test.
- [x] 5.2 <!-- TDD --> Migrate `Bind_FVector.cpp` into `Bind_FVector.cpp` plus `Bind_FVector_Functions.h/.cpp` as the reference family. Move all project-owned direct callable implementations to `FAngelscriptFVectorBinds`, keep type-finder capture and ToString/infrastructure lifetimes unchanged, and register former ordinary lambdas through plain function pointers.
- [x] 5.3 <!-- TDD --> Add failing source-layout tests for the FColor/FVector reference families, pointer-only exemption, one primary owner, semantic non-numeric callable names, non-template `.cpp` definitions, template header exceptions, and the narrow production direct-callable-lambda prohibition; make them pass without rejecting DSL fixtures or auxiliary lambdas.
- [x] 5.4 <!-- TDD --> Migrate primitive, typedef, enum, name/string/text, math, container, delegate, and core type providers in reviewable waves. Move both lambdas and existing file-local direct callable wrappers, retain specialized container support types/templates, and run the focused binding prefix after each wave.
- [x] 5.5 <!-- TDD --> Migrate UObject/UClass/UStruct/BlueprintType and reflection-derived manual providers, splitting callbacks at phase boundaries and callable bodies into owners without changing `FAngelscriptType`, reflection, dynamic declaration, or generic marshalling semantics.
- [x] 5.6 <!-- TDD --> Migrate actor/component/controller/pawn/player/world/game-instance and gameplay-facing Runtime providers. Split any existing owner shared by several registration files only where callable ownership requires it, preserve established owner names with their primary bind, and keep world-context/output-type traits and marshalling behavior identical.
- [x] 5.7 <!-- TDD --> Migrate editor/platform/asset/input/debug/console/network and remaining Runtime providers; permit multiple file-static phase binds per registration file but keep one primary callable owner and do not create empty companion pairs for pointer-only binds.
- [x] 5.8 <!-- TDD --> Preserve the baseline native/trivial/custom-native classification while replacing legacy `SCRIPT_NATIVE_TEMPLATED_CALL*` metadata attachment with exact fluent bound-result APIs. Add assertions that former ordinary lambdas did not gain native/trivial forms.
- [x] 5.9 <!-- TDD --> Generate and compile representative StaticJIT/AOT C++ covering moved FColor/FVector, actor, container-template, and optional-plugin callables; fix missing includes, exports, or C++ spellings without broadening visibility for ordinary former lambdas.
- [x] 5.10 <!-- Non-TDD --> Complete every row of `order-migration.md` and `callable-migration.md` with implemented phase/split/merge, companion/pointer-only decision, owner name, native-form parity, and focused test evidence. Stop and propose a separate dependency OpenSpec if ordering cannot be expressed without an escape hatch.
- [x] 5.11 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture" -Label direct-bind-callable-layout -TimeoutMs 600000`, the focused prefix after each migration wave, `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label direct-bind-manual -TimeoutMs 600000`, and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" -Label direct-bind-static-jit-aot -TimeoutMs 600000`.

## 6. Auxiliary Store and PreviousBind Cleanup

- [x] 6.1 <!-- TDD --> Add/update tests for explicit type adapter/finder, alias/well-known slots, ToString contribution/finalization, BindDB contribution/finalization, string factory/default array selection, interface signatures/userdata, and consistency finalizers in their declared phases.
- [x] 6.2 <!-- TDD --> Migrate those auxiliary callbacks to direct explicit-engine APIs while preserving `Binds.Cache` schema and existing capture/lifetime behavior.
- [x] 6.3 <!-- TDD --> Convert every PreviousBind-dependent trait, documentation, native, StaticJIT, compile-out, property-constant, and function-id consumer to `FAngelscriptBoundFunction` or `FAngelscriptBoundProperty`, adding a focused regression before each non-mechanical conversion.
- [x] 6.4 <!-- Non-TDD --> Delete `PreviouslyBoundFunction`, `PreviouslyBoundGlobalProperty`, previous-bind getters/setters, and dependent macros/helpers only after repository search shows no production consumer.
- [x] 6.5 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture.Auxiliary" -Label direct-bind-auxiliary -TimeoutMs 600000` and existing FString format/recreation prefixes.

## 7. Generated, Reflection, and Optional-Plugin Convergence

**Primary files:** UHT emitter and golden fixtures, Runtime `FunctionBinding/`, editor CodeGen templates, reflection fallback bindings, `AngelscriptGameplayTags`, and `AngelscriptGAS`.

- [x] 7.1 <!-- TDD --> Update/add UHT golden tests expecting RuntimeLinked shards to emit file-static `FAngelscriptBind` callbacks with `GeneratedBindings` and explicit `FAngelscriptBinds&` execution.
- [x] 7.2 <!-- TDD --> Update RuntimeLinked emitter/runtime consumption while preserving signature eligibility, statistics, direct/generic caller metadata, and fallback decisions.
- [x] 7.3 <!-- TDD --> Add NativeModuleFunctionAddress emitter/source/runtime regression tests that preserve target-module Runtime independence, POD layout/version, `IModularFeatures` arrival/unload behavior, and Runtime-side explicit engine targeting. The installed binary UE 5.8 build compiles out this source-engine-only feature, so runtime-path coverage is conditional while emitter/source guards remain active.
- [x] 7.4 <!-- TDD --> Adapt only the Runtime-side NativeModuleFunctionAddress outer provider/consumer needed by the new facade; do not replace its transport, remove late replay, change the POD layout, or bump the layout version in this change.
- [x] 7.5 <!-- TDD --> Update editor CodeGen fixture/templates so generated source owns file-static callbacks and generated `StartupModule()` contains no binding submission.
- [x] 7.6 <!-- TDD --> Keep UHT-generated thunks as named generated entries rather than creating hand-written `_Functions` companions; migrate reflection binding entry points to `ReflectionBindings`, reflection-dependent callable synthesis to `PostReflectionBindings`, and verify ineligible signatures and RPC/Net UFunctions retain `BlueprintCallableReflectiveFallback`.
- [x] 7.7 <!-- TDD --> Migrate `AngelscriptGameplayTags` providers and project-owned direct callable implementations to file-static phases plus named companion owners where needed, without changing tag extension/reload semantics or creating empty pairs.
- [x] 7.8 <!-- TDD --> Migrate all `AngelscriptGAS` providers and project-owned direct callable implementations to the same phase/direct-callback/named-owner model without changing GAS behavior.
- [x] 7.9 <!-- Non-TDD --> Run UHT resolver, generated runtime, CodeGen fixture, reflection/RPC, GameplayTags, and GAS prefixes recorded in task 0.3.

## 8. Legacy Lifecycle and Configuration Removal

- [x] 8.1 <!-- TDD --> Replace legacy `CallBinds`/integer-order/config tests with collection finalization, phase ordering, direct execution, and fail-closed publication tests.
- [x] 8.2 <!-- Non-TDD --> Remove nested `FAngelscriptBinds::FBind`, legacy `RegisterBinds`/`CallBinds`, `GetSortedBindArray`, `EOrder`, integer `BindOrder`, and old callback records after all providers migrate.
- [x] 8.3 <!-- TDD --> Update settings tests to assert no `DisabledBindNames` project setting, per-engine filter, alias, dependency cascade, or skip fingerprint remains.
- [x] 8.4 <!-- Non-TDD --> Remove disabled-name settings/storage/UI/config/serialization/dump fields and obsolete tests.
- [x] 8.5 <!-- Non-TDD --> Remove binding submission from Runtime/editor/optional-plugin `StartupModule()`, direct-provider registration handles/leases/unload blockers/late replay, and any intermediate collection copies; retain only the recorded NativeModuleFunctionAddress bridge exception.
- [x] 8.6 <!-- Non-TDD --> Remove any temporary `WITH_ANGELSCRIPT_LEGACY_BINDS` or equivalent dual-path switch from the completed target.
- [x] 8.7 <!-- Non-TDD --> Run the production-source zero-reference guard for all removed symbols/concepts, including generated templates/fixtures and optional plugins, plus the narrow direct-callable-lambda guard for hand-written production bind call sites. Confirm the latter still permits DSL compatibility fixtures and non-AS-entry auxiliary lambdas; attach clean output to this change.

## 9. Diagnostics, Documentation, and Performance

- [x] 9.1 <!-- TDD --> Replace old callback/order or build/apply timing expectations with one-time collection finalization plus per-engine provider/phase/status/duration/publication observations.
- [x] 9.2 <!-- TDD --> Add top-N callback log tests and exact totals for all seven phases, including aborted execution; prove no per-provider clocks/storage when observation defines are absent.
- [x] 9.3 <!-- TDD --> Update `FAngelscriptStateDump` binding tables to observe sealed callback metadata and engine-owned results without invoking providers; add deterministic CSV schema/content tests.
- [x] 9.4 <!-- TDD --> Extend startup performance/allocation tests to compare collection finalization, direct callback execution, total full-create time, absence of per-engine array copy/sort, absence of expanded process binding data, and absence of new per-call tracing/dispatch state against task 0.3.
- [x] 9.5 <!-- Non-TDD --> Update Chinese-first developer/plugin documentation and then English counterparts for file-static callbacks, required phases, explicit Engine context, fluent direct results, the `Bind_<Name>.cpp` + `_Functions.h/.cpp` named-callable convention, lambda API compatibility, pointer-only exemptions, restart-after-native-change, and no runtime disabling.
- [x] 9.6 <!-- Non-TDD --> Update UHT/CodeGen documentation and document that `FAngelscriptType` semantics, generic binding behavior, RPC routing, `Binds.Cache`, and native POD layout are unchanged.

## 10. Final Verification

- [x] 10.1 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label direct-bind-final -TimeoutMs 1800000 -NoXGE` and retain the successful report path.
- [x] 10.2 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.BindingArchitecture" -Label direct-bind-architecture -TimeoutMs 600000`.
- [x] 10.3 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label direct-bind-uht -TimeoutMs 600000`.
- [x] 10.4 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Engine.GeneratedFunctionBinding" -Label direct-bind-generated -TimeoutMs 600000`.
- [x] 10.5 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label direct-bind-bindings -TimeoutMs 600000`.
- [x] 10.6 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.AOT" -Label direct-bind-static-jit-aot-final -TimeoutMs 600000`, then the focused multi-engine, engine lifecycle, generic-call, `FAngelscriptType`, dump, performance, reflection/RPC prefixes recorded during migration plus `Angelscript.GameplayTags.` and `Angelscript.GAS.`.
- [x] 10.7 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix direct-bind-native-core -TimeoutMs 600000`.
- [x] 10.8 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix direct-bind-all -TimeoutMs 600000` and reconcile actual counts with live test guides rather than historical baselines.
- [x] 10.9 <!-- Non-TDD --> Diff pre/post script-visible state, traits/documentation/native behavior, native/trivial form count and classification, generated StaticJIT C++ compile, `Binds.Cache`, UHT output/statistics, generic-call behavior, and startup timing/allocation; explain every intentional architecture-only difference.
- [x] 10.10 <!-- Non-TDD --> Re-run removed-concept and direct-callable-lambda guards, confirm `TLambdaFuncPtr` plus focused lambda fixtures still exist, run `openspec validate refactor-as-manual-binding-architecture --strict` and `git diff --check`, and archive only after all required regression evidence is complete.

## 11. Explicit Phase Naming Follow-up

- [ ] 11.1 <!-- Non-TDD --> Replace every test-only `EAngelscriptBindPhase::ManualBindings` reference and expected diagnostic/source-layout string with `ExplicitBindings`. This includes Runtime `AngelscriptBindSourceLayoutTests.cpp`, `AngelscriptDumpTests.cpp`, and the GAS and GameplayTags binding-architecture tests. Preserve the assertions' behaviour and phase-order intent; this is a name migration, not a new source-layout policy.
- [ ] 11.2 <!-- Non-TDD --> Update the Chinese-first binding architecture guides, knowledge articles, examples, phase tables, and migration matrices from `ManualBindings` to `ExplicitBindings`; retain the OpenSpec directory name as historical change identity. Run a repository search proving no obsolete production/test/documentation terminology remains, then run the focused binding-architecture tests and a build before closing this follow-up.
