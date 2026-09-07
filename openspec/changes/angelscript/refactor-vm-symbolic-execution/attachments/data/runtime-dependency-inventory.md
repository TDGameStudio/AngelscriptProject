# SDK Runtime Dependency Inventory

## Provenance and meaning

Read-only source inspection on 2026-09-06 +08:00. Parent HEAD d4f69984b0611ca44956577c242266edad24002b; Plugins/Angelscript HEAD f8e9bd701902e3707bcb2d5207bf4c2e0c6356f0. Both worktrees are dirty and those commits alone do not reproduce the inspected tree. Preserve existing edits. The following raw file digests pin the principal observations, not a complete immutable review snapshot:

| File beneath Plugins/Angelscript/Source/AngelscriptRuntime | SHA-256 |
|---|---|
| Core/angelscript.h | 4d805c4cc7ab60757a046eb3566654b132824c6d7e93e3629525512718b9c9fd |
| ThirdParty/angelscript/source/as_context.cpp | b957b6bfeffeae31715babc9ca44afff7193f8c562d9397df420ee167d8ccd53 |
| ThirdParty/angelscript/source/as_metadata_image.cpp | 1be7492d25d93dc27bf6945923fcca39fdf72f34fbc96b9e180d7aa345c16f50 |
| ThirdParty/angelscript/source/as_callfunc.cpp | c28aa312ef3ddf75c1d8a2c0dbf3168a907450f5dd4d1ea3e7eb3dfb0e99fbcb |

Line anchors below describe this observation only; re-read symbols if lines move. No build, Automation or VM execution was performed for this inventory.

## Current dependencies and accepted migration owner

Paths are relative to the Runtime module above; unqualified filenames below the table refer to ThirdParty/angelscript/source/.

| Current source / symbol | Observation | Accepted migration / tasks |
|---|---|---|
| as_metadata_image.cpp:496 CreateObjectType; as_typeinfo.h GetStableKey | Actual object receives its key before Engine creation | Preserve identity at creation; 1.1 |
| as_metadata_image.cpp:426, :1078 ValidateFrozenDefinitions / Freeze | Freeze is not full identity authentication; private witnesses cover only selected facts | Complete fingerprint authentication without strengthening shell Freeze; 1.1 |
| as_metadata_image.h:85 IsFrozen | State != Building includes Attaching and Retired | Explicit state/ownership admission; 1.1, 2.3 |
| frontend/as_type_identity.cpp:291 Function encoding | Ordinary identity omits return type/definition modifiers | Full schema and callable ABI contracts; 1.1, 2.3 |
| as_metadata_image.cpp:761, :900, :960 | AddProperty lacks native offset; SetNativeLayout only size/alignment; FinalizeLayouts computes sequential offsets | Explicit native addressing/preservation; 1.2 |
| as_metadata_image.cpp:1012, :1071 | Semantic field layout begins at zero/base size; not VM callframes | Preserve payload layout; prepare frames/storage separately; 2.3, 3.1, 3.3 |
| as_scriptengine_metadata.cpp:33, :57, :100, :144 | Whole-image registration uses original pointers, enforces one Engine, publishes metadata maps | Keep registration; add separate transactional executable snapshot; 2.3 |
| as_scriptengine.cpp:1675 GetScriptFunction | Public lookup already checks metadataFunctionsById | Preserve existing useful lookup; do not falsely describe every lookup as legacy; 2.3 |
| as_context.cpp:2013 CALL and other direct consumers | Interpreter still indexes legacy scriptFunctions and old global/import tables | Prepare checked snapshot slots, not per-opcode locked map lookups; 3.1, 3.4 |
| as_scriptengine.cpp:1695 CreateContext | Current active entry returns asNOT_SUPPORTED | Restore explicit SDK Context route; 3.1 |
| as_callfunc.cpp:406, :414, :462, :472 | Active CallSystemFunction rejects; Generic/typed caller logic retained under #if 0, raw backends separately disabled | Supported Generic and typed caller only; 3.2 |
| Core/angelscript.cpp:5 GetObjectType | UASClass raw registry, UASStruct then UObject fallback | SDK-owned dynamic type route; 3.3 |
| Core/angelscript.h:1540; as_scriptobject.cpp:295, :380 | Public ref/weak methods and constructor body dormant; GetEngine reads raw type engine | Real SDK storage/reference ownership and accessor routes; 3.3, 3.5 |
| as_scriptengine.cpp:5090, :5119, :5128 | Allocation/construct hooks are global; raw free/ref services use UASClass | Explicit SDK per-Engine runtime services; 3.3 |
| as_metadata_image.cpp:822; as_scriptengine_metadata.cpp:239 | Metadata behaviour/factory declarations exist, runtime construction/delegates remain dormant | Prepared behaviour/vtable/native slots, no frozen mutation; 2.3, 3.3, 3.4 |
| as_scriptengine.cpp:5520; as_context.cpp:3643 | Interface casts consult UE helpers | Actual SDK relationships and explicit host boundary; 3.4 |
| as_gc.cpp:479, :502, :622 | Collector teardown/behaviours consume dormant tables | Actual SDK roots, behaviours, cycle collection and weak state; 3.5 |
| as_context.cpp:48, :700, :1135, :1216, :5934 | UE settings/Blueprint/JIT/DebugServer/WorldContext coupling in execution | Remove SDK prerequisites, explicit observers; 3.1, 3.2, 3.6 |
| as_scriptengine.cpp:1196; as_scriptengine_metadata.cpp:154 | Metadata retirement currently precedes required future runtime cleanup | Admission stop, Context/object drain, then retirement; 3.5, 3.6 |
| as_scriptfunction.h ScriptFunctionData | Interpreter needs bytecode, stack and local-object/exception cleanup data | Versioned image/frame contract, not code bytes alone; 2.1-2.3, 3.1 |
| as_bytecode.h:66 | Existing assembler constructor takes asCBuilder | New production symbolic authoring boundary; 2.1 |
| as_module.cpp:2164, :2187; as_restore.cpp:35 | Save/LoadByteCode and detached restore are unsupported | Remain dormant; new independent executable codec; 2.1, 4.1 |
| Cache/AngelscriptCacheRestore.cpp; Core/Artifacts/AngelscriptArtifactIdentity.cpp | Old Cache V2 restore is isolated; stable-key projection is not full integration | No implicit cache migration or producer restoration; 4.1 |

## Retained test oracles

The following files are beneath Plugins/Angelscript/Source/AngelscriptTest/Legacy/AngelScriptSDK/. They are read-only behavioural references, not build inputs or fixture helpers to enable:

| Prior family / files | Reuse | New owners |
|---|---|---|
| Runtime/AngelscriptNativeContextInvocationTests.cpp; ContextReturnValueTests and ContextExceptionTests families | Prepare/Execute and argument/return/exception expectations | 3.1, 3.6 |
| Runtime/AngelscriptNativeContextControlTests.cpp; Runtime/Debug/AngelscriptNativeNestedContextTests.cpp | Suspend/resume/reuse/nested state | 3.6 |
| Embedding/AngelscriptNativeCallingConventionTests.cpp; AngelscriptNativeGenericInterfaceDepthTests.cpp | Supported native receiver, parameter, return and sentinel oracles | 3.2 |
| Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp | Construction/copy/destruction/partial failure | 3.3 |
| Language/Inheritance/ and Conformance/AngelscriptNativeInterfaceSemanticsTests.cpp | Actual dispatch/cast/interface results | 3.4 |
| Runtime/AngelscriptNativeGarbageCollectorTests.cpp | Self/two-node cycles, live roots and collection lifecycle | 3.5 |
| Compiler/ bytecode-generation/jump/opcode families | Instruction and branch semantics, not the old source-compiling setup | 2.1, 2.2, 3.1, 4.2 |

## Ownership and concurrency

The exact Files lines in tasks.md own future edits. Existing source is confined to maintained ThirdParty files and the public SDK object surface in Core/angelscript.h/.cpp. New tests are replacement-only; frontend shared helpers do not acquire an ambient Engine. No startup gates, host project, generated bindings, Legacy trees, Cache V2 or Standalone edits are implicitly permitted.

Tasks 1.2 and 2.1 can be Ready together after fingerprint foundations, with disjoint source files; later runtime groups intentionally serialize shared as_context/as_scriptengine/as_execution_snapshot edits. Build and Automation are single-coordinator exclusive resources. Other active Changes can overlap definitions/public SDK headers; resolve writer scheduling without silently adding cross-Change product dependencies.

