# Source-to-Topic Content Crosswalk

Captured: 2026-07-25

This crosswalk assigns every Hazelight Markdown source file, every `Documents/Knowledges/ZH` Markdown file, and every current host `.as` example/test file to the v1 topic architecture.

Disposition vocabulary:

- `adapt`: rewrite the subject for the current fork and Wiki audience;
- `split`: divide a large source across depth-specific or topic-specific pages;
- `reference-only`: preserve as evidence; do not migrate prose directly;
- `defer`: keep available, but outside the foundation and first content batches;
- `superseded-candidate`: verify against current code before deciding whether any content remains useful.

No disposition authorizes deletion.

## 1. Hazelight documentation source

The repository contains 29 Markdown files: one repository README plus 28 site-content pages.

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `README.md` | `reference-differences-version/L5` | reference-only | Records that the repository is the source text for the public site and uses Zola. |
| `content/_index.md` | `start/L0` | adapt | Mission, high-level benefits, editor support, Blueprint/C++ cooperation, debugging. Rewrite for this fork. |
| `content/getting-started/_index.md` | `start/L0` | reference-only | Directory intent only. |
| `content/getting-started/installation.md` | `start/L1` | split | Separate source-engine/project setup, plugin setup, and project-owned VS Code extension guidance. |
| `content/getting-started/introduction.md` | `start/L1` | split | First Actor path, components, Blueprint interop, examples, next reading. Use current examples and UE 5.7 behavior. |
| `content/scripting/_index.md` | `unreal-language/L0` | reference-only | Candidate checklist for feature coverage, not a direct page. |
| `content/scripting/actors-components.md` | `unreal-core/L1-L3` | split | Actor/component usage, defaults, spawn, construction, overrides, lookup. |
| `content/scripting/cpp-differences.md` | `start/L0-L3` | split | Beginner transition page plus deeper type/default/float-width boundaries. |
| `content/scripting/delegates.md` | `unreal-language/L1-L4` | adapt | Merge with current delegate/event source evidence and current tests. |
| `content/scripting/editor-script.md` | `unreal-language/L2-L3` | adapt | Editor conditions, directory rules, simulated cooked verification. |
| `content/scripting/fname-literals.md` | `unreal-language/L1-L4` | adapt | Pair syntax usage with parser/compile representation. |
| `content/scripting/format-strings.md` | `unreal-language/L1-L4` | split | Short user guide plus current format-specifier/reference and implementation page. |
| `content/scripting/function-libraries.md` | `unreal-core/L1-L3` | adapt | Function-library usage, namespace simplification, Math boundary. |
| `content/scripting/functions-and-events.md` | `unreal-language/L1-L4` | split | Plain/UFUNCTION/Blueprint event/global/Super behavior. |
| `content/scripting/gameplaytags.md` | `topics-integrations/GameplayTags/L1-L3` | adapt | Optional plugin classification and current replay/editor behavior must be added. |
| `content/scripting/mixin-methods.md` | `unreal-language/L1-L4` | adapt | Distinguish AS `mixin` keyword from C++ `ScriptMixin` metadata. |
| `content/scripting/networking-features.md` | `topics-integrations/Networking/L1-L3` | split | Domain topic; include current RPC fallback and replication boundaries. |
| `content/scripting/properties-and-accessors.md` | `unreal-language/L1-L4` | split | Property declaration, metadata, access, and current property-accessor status. |
| `content/scripting/script-tests.md` | `testing-diagnostics-release/L1-L3` | split | Current test framework differs significantly; use as comparison and migrate only verified concepts. |
| `content/scripting/structs-refs.md` | `type-object-reflection/L1-L3` | adapt | Value/reference directions, out params, serialization/replication. |
| `content/scripting/subsystems.md` | `unreal-core/L1-L4` | adapt | Align with current engine/game-instance subsystem ownership and tests. |
| `content/cpp-bindings/_index.md` | `bindings-uht-extensions/L0` | reference-only | Directory intent only. |
| `content/cpp-bindings/automatic-bindings.md` | `bindings-uht-extensions/L1-L4` | split | User-facing exposure rules plus current generated/direct/reflective paths. |
| `content/cpp-bindings/mixin-libraries.md` | `bindings-uht-extensions/L2-L4` | adapt | C++ `ScriptMixin` path and current function-library locations. |
| `content/cpp-bindings/precompiled-data.md` | `runtime-jit-vm/L2-L4` | split | Cache/JIT workflow, compatibility, packaging, reload boundaries; verify current StaticJIT terminology. |
| `content/project/_index.md` | `reference-differences-version/L0` | reference-only | Directory intent only. |
| `content/project/development-status.md` | `reference-differences-version/L1-L3` | reference-only | Hazelight status is historical/reference data, not this fork's status page. |
| `content/project/license.md` | `reference-differences-version/L2` | reference-only | Covers engine/library/plugin code licenses, not a separate website-content license. |
| `content/project/resources.md` | `reference-differences-version/L1` | adapt | Review every external link, version, project identity, and relevance before reuse. |

## 2. Chinese knowledge base

### Architecture family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Arch_EditorTestDumpCollaboration.md` | `architecture-maintenance/L4-L5` | split | Editor/Test/Dump ownership, then link to testing and diagnostics topics. |
| `Arch_ErrorDiagnostics.md` | `testing-diagnostics-release/L4-L5` | split | Compile diagnostics, collection, output, recovery. |
| `Arch_ModuleLoading.md` | `compile-module-preprocessor/L4-L5` | split | Module inventory, load phases, dependencies. |
| `Arch_Overview.md` | `architecture-maintenance/L0-L5` | split | High-level orientation plus deeper module/source ownership. |
| `Arch_RuntimeLifecycle.md` | `runtime-jit-vm/L4-L5` | split | Engine/subsystem lifecycle; cross-link hot reload and world contexts. |
| `Arch_UHTToolchain.md` | `bindings-uht-extensions/L4-L5` | split | Toolchain architecture, generated artifacts, layout contract. |

### AngelScript kernel family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `AS_ByteCode.md` | `runtime-jit-vm/L4` | adapt | Instruction model and current fork differences. |
| `AS_CallingConventions.md` | `runtime-jit-vm/L4-L5` | adapt | Native/generic calling conventions and binding implications. |
| `AS_Compiler.md` | `compile-module-preprocessor/L4` | adapt | Compiler stages and emitted bytecode. |
| `AS_ForkDifferences.md` | `reference-differences-version/L3-L5` | adapt | Selective 2.38 strategy and verified fork deltas. |
| `AS_GarbageCollector.md` | `runtime-jit-vm/L4` | adapt | GC model and UObject integration boundaries. |
| `AS_LanguageSyntax.md` | `language/L0-L3` | split | Basic syntax guide, reference, and unsupported constructs. |
| `AS_ObjectLifecycle.md` | `type-object-reflection/L4` | split | Script object lifecycle plus runtime ownership. |
| `AS_Parser.md` | `compile-module-preprocessor/L4` | adapt | Recursive-descent parser and fork grammar. |
| `AS_ScriptEngine.md` | `runtime-jit-vm/L4-L5` | split | Engine architecture, registration, modules, contexts. |
| `AS_StringFactory.md` | `runtime-jit-vm/L4` | adapt | String interning/factory behavior; cross-link FString feature. |
| `AS_TypeRegistration.md` | `bindings-uht-extensions/L4-L5` | split | SDK registration API and Unreal bridge. |
| `AS_VirtualMachine.md` | `runtime-jit-vm/L4` | adapt | Context execution and VM model. |

### Difference family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Diff_HazelightDefaultStatement.md` | `reference-differences-version/L3-L5` | adapt | Link from language-feature default pages. |
| `Diff_HazelightInsightsToBorrow.md` | `reference-differences-version/L4-L5` | split | Review each insight against current implementation and current audit logs. |
| `Diff_VerseArchitecture.md` | `reference-differences-version/L3-L5` | defer | Valuable comparison, not part of first AngelScript documentation batches. |

### Guide family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Guide_ClassBinding.md` | `bindings-uht-extensions/L1-L4` | split | User-facing binding guide and source-level binding paths. |
| `Guide_DelegateSystem.md` | `unreal-language/L1-L3` | adapt | Pair with deeper `Syntax_DelegateEvent`. |
| `Guide_EditorExtension.md` | `editor-ide-debugging/L2-L4` | split | Menus, categorization, editor-specific ownership. |
| `Guide_QuickStart.md` | `start/L0-L2` | split | First-batch Chinese input; reduce 1084-line source into outcomes and runnable steps. |
| `Guide_RuntimeLifecycle.md` | `runtime-jit-vm/L1-L4` | split | Reader lifecycle path with links into compilation and hot reload. |
| `Guide_ScriptMixin.md` | `unreal-language/L1-L3` | adapt | Separate AS keyword and C++ metadata paths. |
| `Guide_SyntaxFeatures.md` | `unreal-language/L0-L3` | split | First-batch feature index; replace “待写” references with actual catalog status. |
| `Guide_UHTToolchain.md` | `bindings-uht-extensions/L1-L4` | split | Operational guide plus generated artifact safety. |

### Note family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Note_CQTest.md` | `testing-diagnostics-release/L2-L5` | split | CQTest authoring, helpers, and project test conventions. |
| `Note_InterfaceBinding.md` | `bindings-uht-extensions/L3-L5` | adapt | Current limitations and binding behavior; verify ongoing edits. |
| `Note_InternalsEngineFactory.md` | `runtime-jit-vm/L4-L5` | adapt | Internals factory and engine creation boundaries. |
| `Note_ScreenshotTestHelper.md` | `testing-diagnostics-release/L2-L5` | defer | Specialized test authoring topic; not first content batch. |
| `Note_UBT.md` | `bindings-uht-extensions/L3-L5` | split | Build/UHT constraints and generated paths. |

### Runtime subsystem family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `RT_CodeCoverage.md` | `testing-diagnostics-release/L2-L5` | split | Use, export, external visualization, implementation ownership. |
| `RT_Debugger.md` | `editor-ide-debugging/L1-L5` | split | VS Code use through DebugServer V2 internals and protocol evidence. |
| `RT_GlobalState.md` | `architecture-maintenance/L4-L5` | split | Runtime state ownership, containment, teardown. |
| `RT_HashMetadata.md` | `architecture-maintenance/L4-L5` | reference-only | Specialized maintainer evidence; link from related internals. |
| `RT_HotReload.md` | `hot-reload/L0-L5` | split | Primary deep source for the dedicated hot-reload topic. |
| `RT_StateDump.md` | `testing-diagnostics-release/L2-L5` | split | User diagnostics, snapshot/diff outputs, observer architecture. |
| `RT_StaticJIT.md` | `runtime-jit-vm/L2-L5` | split | User packaging/performance through JIT internals and tests. |
| `RT_ThirdPartyKernel.md` | `runtime-jit-vm/L4-L5` | split | Vendored kernel, fork policy, source boundary. |

### Authoring rule

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Rule.md` | `reference-differences-version/L5` | adapt | Input to Wiki authoring rules; do not carry GitHub-only formatting or mandatory long-article shape blindly. |

### Language feature and type syntax family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Syntax_AccessSpecifiers.md` | `unreal-language/L1-L4` | split | User syntax, semantics, parser/access checks. |
| `Syntax_DefaultComponent.md` | `unreal-language/L1-L4` | split | Components/attach/root/override and generator behavior. |
| `Syntax_DefaultStatement.md` | `unreal-language/L1-L4` | split | Usage, expansion, construction mapping. |
| `Syntax_DelegateEvent.md` | `unreal-language/L1-L4` | split | Declaration, generated representation, binding/broadcast. |
| `Syntax_FInstancedStruct.md` | `type-object-reflection/L1-L4` | split | User use and type-erasure implementation. |
| `Syntax_FString.md` | `unreal-language/L1-L4` | split | Format reference and compile-time expansion. |
| `Syntax_Mixin.md` | `unreal-language/L1-L4` | split | AS keyword and cross-module behavior. |
| `Syntax_PropertyAccessor.md` | `unreal-language/L3-L4` | adapt | Removed/changed behavior and explicit Get/Set migration. |
| `Syntax_TArray.md` | `type-object-reflection/L1-L4` | split | Secondary link from language-feature container overview. |
| `Syntax_TMap.md` | `type-object-reflection/L1-L4` | split | Hash/key constraints and script behavior. |
| `Syntax_TOptional.md` | `type-object-reflection/L1-L4` | split | Nullable-value behavior and current null-handle changes. |
| `Syntax_TSet.md` | `type-object-reflection/L1-L4` | split | Set behavior and shared map internals. |
| `Syntax_TSoftObjectPtr.md` | `type-object-reflection/L1-L4` | split | Soft object/class references and loading boundaries. |
| `Syntax_TSubclassOf.md` | `type-object-reflection/L1-L4` | split | Type-safe UClass references and editor integration. |
| `Syntax_TWeakObjectPtr.md` | `type-object-reflection/L1-L4` | split | Weak object validity and current implementation. |
| `Syntax_UFUNCTION.md` | `unreal-language/L1-L4` | split | Function specifiers, reflection, Blueprint/RPC behavior. |
| `Syntax_UPROPERTY.md` | `unreal-language/L1-L4` | split | Property specifiers, metadata, editor/Blueprint behavior. |

### Test architecture family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Test_Infrastructure.md` | `testing-diagnostics-release/L2-L5` | split | Harnesses, runners, helpers, lifecycle. |
| `Test_Layering.md` | `testing-diagnostics-release/L0-L5` | split | Entry orientation plus maintainer layer contracts. |
| `Test_RuntimeInternal.md` | `testing-diagnostics-release/L4-L5` | adapt | Runtime-owned test protocol versus C++ test module. |
| `Test_TopicClusters.md` | `testing-diagnostics-release/L3-L5` | adapt | Theme/prefix mapping and selection guidance. |

### Type and generation family

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Type_BaseClass.md` | `type-object-reflection/L2-L5` | split | Script base-class extension and production surface. |
| `Type_BindSystem.md` | `bindings-uht-extensions/L3-L5` | split | Bind database, timing, execution strategies. |
| `Type_ClassGeneration.md` | `type-object-reflection/L3-L5` | split | Class/reflection generation and reload links. |
| `Type_Core.md` | `type-object-reflection/L3-L5` | split | Type system core and representation. |
| `Type_FunctionCaller.md` | `bindings-uht-extensions/L3-L5` | split | Call bridge, marshaling, dispatch. |
| `Type_FunctionLibrary.md` | `unreal-core/L2-L4` | split | Reader namespaces plus binding internals. |
| `Type_Preprocessor.md` | `compile-module-preprocessor/L2-L5` | split | Directives, module descriptors, dependency context. |
| `Type_StructGeneration.md` | `type-object-reflection/L3-L5` | split | Script struct to Unreal reflection generation. |

### Knowledge index

| Source | Primary target | Disposition | Notes |
|---|---|---|---|
| `Index.md` | `reference-differences-version/L5` | reference-only | Migration inventory and historical prefix map; replaced as reader navigation by topic metadata. |

## 3. Host AngelScript examples and tests

| Source | Primary target | Disposition |
|---|---|---|
| `Script/Examples/Core/Example_AccessSpecifiers.as` | `unreal-language/L1-L3` | adapt |
| `Script/Examples/Core/Example_Array.as` | `type-object-reflection/L1-L2` | adapt |
| `Script/Examples/Core/Example_BehaviorTreeNodes.as` | `topics-integrations/AI-BehaviorTree/L1-L2` | adapt |
| `Script/Examples/Core/Example_CharacterInput.as` | `topics-integrations/EnhancedInput/L1-L2` | reference-only |
| `Script/Examples/Core/Example_ConstructionScript.as` | `unreal-core/L1-L3` | adapt |
| `Script/Examples/Core/Example_Delegates.as` | `unreal-language/L1-L2` | adapt |
| `Script/Examples/Core/Example_Enum.as` | `language/L1-L2` | adapt |
| `Script/Examples/Core/Example_FormatString.as` | `unreal-language/L1-L2` | adapt |
| `Script/Examples/Core/Example_Functions.as` | `language/L1-L2` | adapt |
| `Script/Examples/Core/Example_FunctionSpecifiers.as` | `unreal-language/L1-L3` | adapt |
| `Script/Examples/Core/Example_Map.as` | `type-object-reflection/L1-L2` | adapt |
| `Script/Examples/Core/Example_Math.as` | `unreal-core/L1-L2` | adapt |
| `Script/Examples/Core/Example_MixinMethods.as` | `unreal-language/L1-L2` | adapt |
| `Script/Examples/Core/Example_MovingObject.as` | `start/L1` | adapt |
| `Script/Examples/Core/Example_Overlaps.as` | `unreal-core/L1-L2` | adapt |
| `Script/Examples/Core/Example_PropertySpecifiers.as` | `unreal-language/L1-L3` | adapt |
| `Script/Examples/Core/Example_Struct.as` | `type-object-reflection/L1-L2` | adapt |
| `Script/Examples/Core/Example_Timers.as` | `unreal-core/L1-L2` | adapt |
| `Script/Examples/Core/Example_Widget_UMG.as` | `topics-integrations/UI-UMG/L1-L2` | adapt |
| `Script/Examples/EnhancedInput/Example_EI_Component.as` | `topics-integrations/EnhancedInput/L1-L2` | adapt |
| `Script/Examples/EnhancedInput/Example_EI_InterfaceCall.as` | `topics-integrations/EnhancedInput/L2-L3` | adapt |
| `Script/Examples/EnhancedInput/Example_EI_PlayerController.as` | `topics-integrations/EnhancedInput/L1-L2` | adapt |
| `Script/Examples/Extended/Example_BlueprintSubclass.as` | `unreal-core/L2-L3` | adapt |
| `Script/Examples/Extended/Example_ConsoleWorkflow.as` | `editor-ide-debugging/L1-L2` | adapt |
| `Script/Examples/Extended/Example_InterfaceDispatch.as` | `type-object-reflection/L2-L3` | adapt |
| `Script/Examples/Extended/Example_NetworkReplication.as` | `topics-integrations/Networking/L1-L3` | adapt |
| `Script/Examples/Extended/Example_SubsystemLifecycle.as` | `unreal-core/L1-L3` | adapt |
| `Script/Game/Example_Actor.as` | `start/L1` | adapt |
| `Script/Tests/Test_ActorLifecycle.as` | `testing-diagnostics-release/L2-L3` | reference-only |
| `Script/Tests/Test_Enums.as` | `language/L2-L3` | reference-only |
| `Script/Tests/Test_ExampleActorFixture.as` | `testing-diagnostics-release/L2-L3` | reference-only |
| `Script/Tests/Test_GameplayTags.as` | `topics-integrations/GameplayTags/L2-L3` | reference-only |
| `Script/Tests/Test_Handles.as` | `language/L2-L3` | reference-only |
| `Script/Tests/Test_Inheritance.as` | `language/L2-L3` | reference-only |
| `Script/Tests/Test_MathNamespace.as` | `unreal-core/L2-L3` | reference-only |
| `Script/Tests/Test_SystemUtils.as` | `unreal-core/L2-L3` | reference-only |

The source listing contains 36 unique `.as` files and the table contains one canonical primary row per path. Later migrations record any secondary topics as metadata rather than duplicate rows.

## 4. Supporting guides and source evidence

The following are mandatory supporting evidence groups but are not bulk prose-migration inputs:

| Source group | Primary topics |
|---|---|
| `Documents/Guides/Build.md`, `Test.md`, `TestConventions.md`, `TechnicalDebtInventory.md` | `testing-diagnostics-release`, `architecture-maintenance` |
| `Documents/Guides/AngelscriptForkStrategy.md`, `ASSDK_Fork_Differences.md` | `reference-differences-version`, `runtime-jit-vm` |
| `Documents/Guides/BindGapAuditMatrix.md`, `BlueprintTypeBindingsOptimization.md` | `bindings-uht-extensions` |
| `Documents/Guides/GlobalStateContainmentMatrix.md` | `architecture-maintenance`, `runtime-jit-vm` |
| `Documents/Guides/VSCodeAngelscript.md` and `Extensions/AngelscriptVSCode/README.md` | `editor-ide-debugging` |
| `Documents/Hazelight/HazelightAngelscriptEngineChangeReport.txt` | `reference-differences-version/hazelight-architecture-differences`, `hazelight-audit-maintenance`; historical non-exhaustive engine-path evidence |
| `Documents/Hazelight/ScriptClassImplementation.md`, `ScriptStructImplementation.md`, `DelegateShadowTypeSemantics.md` | `type-object-reflection`, `unreal-language`, `reference-differences-version`; revalidate source/count/performance claims before migration |
| `openspec/changes/docs-wiki-content-foundation/research/hazelight-comparison-audit.md` | Required evidence contract and detailed function-bind/UHT/class/struct comparison seed |
| `openspec/changes/docs-wiki-content-foundation/research/hazelight-engine-change-inventory.md` | Exact thirteen visible report paths, current extra engine/UHT families, latest editor-only candidate |
| `openspec/changes/docs-wiki-content-foundation/research/tiddlywiki-expression-showcase.md` | `showcase-lab`; B13–B15, P15–P16, L11 authoring/security/verification contract |
| Current OpenSpec specs and archived changes | all technical topics as normative/versioned behavior evidence |

## 5. First content-batch recommendation

After the foundation implementation, the first Chinese content batch should use:

1. `Guide_QuickStart.md`
2. `Guide_SyntaxFeatures.md`
3. current `Script/Examples/Core`
4. Hazelight getting-started and scripting pages as rewrite references
5. current source/tests for each promoted claim

The first batch should produce:

- a concise L0 product introduction;
- a tested L1 first Actor path;
- an L0 Unreal language-feature map;
- initial L1 feature pages for `UPROPERTY`, `UFUNCTION`, `default`, default components, delegate/event, mixin, access, f-string, and FName literals;
- explicit links to planned L3/L4 internals rather than copying the existing 800–1600-line deep articles into beginner pages.
