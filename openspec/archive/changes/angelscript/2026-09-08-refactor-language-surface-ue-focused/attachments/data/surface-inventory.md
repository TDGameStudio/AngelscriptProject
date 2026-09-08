# Source surface and consumer inventory

Inspected in the selected `D:/Workspace/AngelscriptProject` workspace on 2026-09-07. Parent HEAD: `d8343d314f0b948a43a323fc443cf305ff2f5dc3`. The workspace already contains unrelated changes, including the plugin submodule and untracked active Change records. These observations are source inspection, not execution evidence. Paths below are relative to `Plugins/Angelscript/` unless an openspec path is shown.

| Surface | Current evidence | Disposition and owner |
|---|---|---|
| Virtual-property block | `Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp` reports `virtual-property-syntax-removed` | Existing rejection control; 1.1 unifies explicit policy/recovery |
| Property decorator | Same parser reports `property-decorator-removed` | Existing rejection control; 1.1; SDK accessor mode removed by 2.2 |
| Source Lambda | Same parser builds parameters/body and calls `Sema.ActOnLambda`; frontend contains Lambda semantic and representation consumers | Active feature to remove, 1.2; do not describe as merely not implemented |
| Lambda definition identity | `as_metadata_image.h` declares `SetLambdaOrigin`; `Builder/BuilderStageTests.cpp` tests anonymous function origin and lifetime | Remove public origin/construction path, convert dedicated positives to rejection and preserve ordinary leases, 1.2 |
| funcdef metadata | `as_metadata_image.h/.cpp`: `CreateFuncdefType`, `CreateCallableSignature`, `AddChildFuncdef` | Structured callable migration in 2.1, not deletion of retained signatures |
| funcdef SDK registration | `Source/AngelscriptRuntime/Core/angelscript.h` and `as_scriptengine.h/.cpp`: RegisterFuncdef, GetFuncdefCount, GetFuncdefByIndex | Remove text registration/legacy enumeration; image-owned structured lookup replaces it, 2.1 |
| funcdef runtime consumers | `as_datatype.*`, `as_generic.cpp`, `as_callfunc.cpp`, `as_context.cpp`, type info, fingerprints and linking | Migrate names/roles while preserving ABI, dispatch and GC behavior, 2.1 |
| Shared module policy | `as_scriptengine.h`: FindNewOwnerForSharedType/Func, duplicate-sharing policy; `as_scriptfunction.h`: IsShared/SetShared | Remove policy, 2.2; keep definition-image leases and engine binding |
| Mutable legacy provenance | Public function/type module pointer queries and legacy module declarations | Replacement consumers use existing stable identity/image ownership; isolate dormant compatibility instead of reviving legacy runtime, 2.2 |
| Engine-owned inputs | `frontend/as_builder_stages.h`: Dependencies; `as_compilation_session.*`: external definitions and declaration barrier | Preserve; do not remove because a symbol contains External |
| Host-only modifier | Parser accepts `external_implicit_this`; Builder tests preserve its callable trait | Retain, unrelated to source external-module declaration policy |
| Generic invocation | `as_generic.cpp` and public asIScriptGeneric native interface | Retain native ABI mechanism; not user templates |
| Host type applications | `frontend/as_type*`, `as_type_identity*`, semantic external inputs and existing generic type-use tests | Preserve structural arguments, arity/provider checks and supported Cast<T>; not a promise of newly implemented UE bindings |
| Script exceptions/coroutines | Current VM tests cover fault/unwind and suspension through SDK APIs; source execution matrix excludes script try/catch | Enforce source absence in 1.1, preserve runtime safety and host control in 2.2 |
| AS Blueprint accessor metadata | `Core/AngelscriptEngine.cpp` validates BlueprintGetter/Setter signatures/flags; preprocessor/class-generator consumers interpret descriptors | Reject source attributes and remove dedicated consumers in 3.1; do not alter UE engine's native reflection |
| Standalone add-on packages | `Standalone/ThirdParty/AngelScriptAddons/{scriptarray,scriptdictionary,scriptmath,scriptstdstring}` | Delete packages in 4.1 |
| Standalone build wiring | `Standalone/CMakeLists.txt` defines ANGELSCRIPT_ADDON_ROOT, source list, target, include/link dependencies | Remove add-on wiring in 4.1; old maintained-fork list separately refers to as_builder.cpp/as_compiler.cpp and other obsolete paths |
| Standalone stdlib | `Standalone/Source/StdLib/AngelscriptStandaloneStdLib.cpp` includes/registers add-ons | Remove add-on registrations, successful no-op claims and dedicated operations, 4.1 |
| Standalone runtime/identity | `Standalone/Source/Runtime/AngelscriptStandaloneRunner.cpp` uses scriptarray/stdstring; `Source/Compiler/AngelscriptStandaloneNativeCompiler.cpp` embeds add-on identity | Remove exclusive operations or reject explicit optional-library requests before use; remove package identity, 4.1 |
| Standalone test consumers | AddonsTests plus ArchitectureTests, SemanticObserverTests and RuntimeTests refer to packages/includes | Delete exclusive tests, narrow mixed consumers and add absence audit; do not erase unrelated cases, 4.1 |

## Source and SDK test boundary

Use current NewVersion tests. Source rejection is proven through Parser/Sema/Builder output and diagnostics. Bytecode/VM preserved behavior uses real detached metadata and current image/verifier/linker/Context services. Neither Add-on removal nor Lambda removal authorizes deleting native-generic, named callable, object/GC or runtime-exception tests.

Public API absence is a compile-time/maintenance contract. Combine dependent-requires assertions for removed members with bounded public-header alias/enum scans; do not introduce a global spelling test that mistakes GC shared booleans or runtime faults for removed language policy.

## Related planning truth

- `openspec/changes/angelscript/feature-delegates-ue-interop`: existing 2.2 promised explicit captures/escaping closures and positive noncapturing controls. The user explicitly replaced that with named/member bindings and explicit payloads. Proposal/tasks are revised; source-evidence attachment remains historical and its former Lambda observations do not authorize feature restoration.
- `openspec/changes/angelscript/refactor-vm-symbolic-execution`: preserve completed task and raw-test history. Follow-up language/SDK changes require current binary proof and migration of retained assertions. This planning delivery does not reopen or close its existing Reviews.
- Current language specs already separate directive preprocessing, semantic authority, definition lifetime and host materialization. The six delta files add permanent language/API restrictions without removing these retained contracts.

## Remaining execution limits

No current build or test was run for this inventory. No inference of total language or code coverage follows from source presence. Standalone buildability is preexisting unverified debt; the scoped future audit only proves the removed dependency chain is absent. New UE containers, callable payload invocation and Blueprint/cooked fixtures remain in their owning feature scope.
