# Defaults and construction evidence

## Provenance and limits

Observed on 2026-09-06 in the selected workspace. Paths below are repository-relative unless prefixed Engine/. Installed engine source was UE 5.8; resolve its location from AgentConfig.ini rather than hardcoding a machine path. This is read-only inspection of a changing reconstruction workspace, not a fixed-snapshot Review or passing runtime evidence. Re-read symbols before implementation. No build or Automation test was run for this exploration.

## Maintained compiler

Prefix: Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/.

| Source | Observation | Consequence |
| --- | --- | --- |
| frontend/as_frontend_parser.cpp:164,349,408 | Class-body KwDefault collects statements into one ClassDefault function; statement capture already accepts braces. | Changing to a block alone does not remove the special phase. Remove only the class-body production. |
| frontend/as_compilation_session.cpp:434,495,720 | Resolves the special return/identity and analyzes retained default statements. | Parser removal must accompany consumer cleanup. |
| frontend/as_frontend_sema_access.cpp:35 | ClassDefault and Defaults modifiers acquire defaults context; ordinary constructors do not automatically acquire it. | Define reflected-construction permissions; do not conflate access with callback registration. |
| frontend/as_ast_fwd.h:36; frontend/as_type_identity.h:163 | Dedicated function and identity kinds exist. | Removing a kind affects stable representations and enum numbering. |
| frontend/as_ast_codec.h:30; frontend/as_ast_codec.cpp; frontend/as_ast_projection.cpp | The current AST codec version is 8 and special payloads have explicit encoding/validation. | Deliberately invalidate or preserve old wire values; recheck current version when implementing. |
| as_metadata_image.cpp:463,691; frontend/as_definition_consumer.cpp | Metadata and definitions consume special implicit functions. | Removal is wider than syntax. |

The inspected maintained source contained 15 .cpp/.h files matching ClassDefault, ClassDefaultStmt or asCClassDefaultStmt. This is a bounded search observation, not a total implementation estimate.

Relevant existing replacement tests include BuilderStageTests.cpp (ClassDefaultStatementsShareOneActualLexicalBodyScope; ParsedClassDefaultsProduceOneImplicitActualFunctionInSourceOrder), BodyAccessTests.cpp (OrdinaryConstructorDoesNotAcquireEditDefaultsPermission), BodyCallContextTests.cpp and ImplicitFunctionDefinitionTests.cpp. These are migration inputs; their presence is not proof of replacement UE lifecycle execution.

## Preserved host reference

Prefix: Plugins/Angelscript/Source/.

| Source | Observation |
| --- | --- |
| AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Finalize.cpp:883,894 | Calls GetDefaultObject(true); records construct and own __InitDefaults functions separately. |
| AngelscriptRuntime/ClassGenerator/ASClass_Construction.cpp:304,346,367 | Defaults execute base-to-derived; ApplyScriptDefaults is independently callable; script allocation finishes the most-derived constructor before defaults. |
| AngelscriptRuntime/ClassGenerator/ASClass_Construction.cpp:650 | Actor path constructs native state/default components before script constructor, then defaults. Defaults are not CDO-only. |
| AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Analyze.cpp:1339 | DefaultsCode changes suggest a full reload to propagate property changes. |
| AngelscriptEditor/HotReload/ClassReloadHelper.cpp:210 | Reapplies script defaults to replacement-class CDOs. This is a replay hook, not a universal object reset. |

The durable runtime/startup spec keeps legacy runtime services dormant. Do not enable them to claim replacement acceptance.

## UE evidence

| Engine-relative source | Observation |
| --- | --- |
| Engine/Source/Runtime/CoreUObject/Private/UObject/Class.cpp:5044 | CreateDefaultObject obtains parent defaults, allocates and records the CDO, then invokes the registered constructor with FObjectInitializer. |
| Engine/Source/Runtime/CoreUObject/Private/UObject/UObjectGlobals.cpp:4240 | Post-construction initialization includes template property copying and later subobject/post-init work. Constructor assignment is not necessarily the final serialized value. |
| Engine/Source/Runtime/CoreUObject/Public/UObject/UnrealType.h:929 | FProperty supports typed property copying; this does not reconstruct arbitrary external state. |
| Engine/Source/Editor/PropertyEditor/Private/PropertyHandleImpl.cpp:1157 | Editor reset additionally handles object instancing, transactions and property notifications. |
| Engine/Source/Editor/PropertyEditor/Private/PropertyNode.cpp:2010 | Default-value lookup can use archetypes, not simply every object's class CDO. |

Epic's [Live Coding documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-live-coding-to-recompile-unreal-engine-applications-at-runtime) describes limits on updating existing instances after constructor-default edits and the separate object-reinstancing mechanism. Hazelight's [C++ differences documentation](https://angelscript.hazelight.se/scripting/cpp-differences/#use-the-default-keyword-instead-of-constructors) explains why its integration prefers default statements during hot reload. These support treating reload as real migration work, not retaining that syntax as an engine requirement.

## Existing authoring examples

Script/Examples/Extended/Example_BlueprintSubclass.as:27 uses default SetReplicates(true), and :71 overrides inherited PickupValue. Script/Game/Example_Actor.as:16-17 also uses replication and Tags.Add. The bounded search `rg -n '^\s*default\s+' Script -g '*.as'` found 10 lines. Container mutation illustrates why replay on an existing object can differ from restoring a template snapshot.

## Decision carryover

The user prioritizes C++-style construction and fewer language concepts. Blocks reduce repeated tokens but preserve the unwanted special stage; an automatic named hook has the same drawback. Constructor-only initialization is the selected direction. Reconsider only if a concrete required capability cannot be delivered through legitimate construction, bounded restoration or reload migration at acceptable cost; source presence alone is not that evidence.
