# Source Reference Seed Registry

Captured: 2026-07-25

This is a seed list for future `as-sources` values and the source corpus registry. It records stable key intent and verified local path areas; it does not claim that symbol anchors, line ranges, or excerpt hashes have already been reviewed.

## Key namespaces

| Prefix | Meaning |
|---|---|
| `as-hazelight-doc.*` | Pinned Hazelight documentation source, rewrite/reference-only rules apply |
| `as-hazelight-source.*` | Restricted pinned Hazelight engine/plugin source observation; metadata/paraphrase only, no public source copy |
| `as-hazelight-report.*` | Dated local Hazelight comparison report with its evidence limitations |
| `as-knowledge.*` | Parent `Documents/Knowledges/ZH` input |
| `as-guide.*` | Parent `Documents/Guides` input |
| `as-example.*` | Parent `Script/` example/test input |
| `as-source.*` | Pinned published plugin source corpus entry |
| `as-test.*` | Pinned plugin test source entry |
| `as-wiki.*` | Current Wiki authoring/runtime source |
| `as-openspec.*` | Normative or historical OpenSpec evidence |

Keys describe logical evidence. Repository, revision, path, license, symbol/anchor, range, and hash live in the inventory/registry rather than being encoded into the key.

## Kernel and compilation seeds

| Proposed key | Verified local path | Intended use |
|---|---|---|
| `as-source.kernel-parser` | `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp` | Parser control flow |
| `as-source.kernel-parser-header` | `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.h` | Parser types/interfaces |
| `as-source.kernel-compiler` | `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp` | Semantic analysis and compilation |
| `as-source.kernel-bytecode` | `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode.cpp` | Bytecode building/optimization |
| `as-source.kernel-context` | `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp` | VM/context execution |
| `as-source.kernel-script-engine` | `Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp` | Registration and engine state |
| `as-source.runtime-preprocessor` | `Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` | Unreal-facing preprocessing |
| `as-source.runtime-compilation-context` | `Source/AngelscriptRuntime/Core/Compilation/AngelscriptCompilationContext.cpp` | Compilation context ownership |
| `as-source.runtime-compilation-events` | `Source/AngelscriptRuntime/Core/Compilation/AngelscriptCompilationEvents.cpp` | Compilation event flow |
| `as-source.runtime-source-provider` | `Source/AngelscriptRuntime/Core/AngelscriptSourceProvider.cpp` | Source discovery/provision |

All `ThirdParty/angelscript` keys resolve to the zlib license class, not the plugin MIT class.

## Type, object, reflection, and language-feature seeds

| Proposed key | Verified local path | Intended use |
|---|---|---|
| `as-source.runtime-type-system` | `Source/AngelscriptRuntime/Core/AngelscriptType.cpp` | Unreal/AS type representation |
| `as-source.runtime-as-class` | `Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp` | Script class representation |
| `as-source.runtime-as-class-construction` | `Source/AngelscriptRuntime/ClassGenerator/ASClass_Construction.cpp` | Default objects/components/construction |
| `as-source.runtime-as-class-metadata` | `Source/AngelscriptRuntime/ClassGenerator/ASClass_Metadata.cpp` | Generated metadata |
| `as-source.runtime-as-struct` | `Source/AngelscriptRuntime/ClassGenerator/ASStruct.cpp` | Script struct representation |
| `as-source.runtime-class-generation` | `Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Generation.cpp` | UClass/UStruct generation |
| `as-source.runtime-class-finalize` | `Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Finalize.cpp` | Finalization/registration |
| `as-test.frontend-parser-shape` | `Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeShapeTests.cpp` | AST shape evidence |
| `as-test.frontend-source-range` | `Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp` | Source-range evidence |

Feature-specific keys for default, components, delegate/event, mixin, f-string, FName, UPROPERTY, and UFUNCTION should be created only after a later article batch identifies unambiguous anchors and the exact regression tests for that feature.

## Hot-reload seeds

| Proposed key | Verified local path | Intended use |
|---|---|---|
| `as-source.runtime-class-reload-planner` | `Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassReloadPlanner.cpp` | Reload classification/planning |
| `as-source.runtime-reload-planning` | `Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_ReloadPlanning.cpp` | Generator reload plan |
| `as-source.runtime-soft-reload` | `Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_SoftReload.cpp` | Soft-reload path |
| `as-source.runtime-full-reload` | `Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp` | Full-reload path |
| `as-source.runtime-reinstancing` | `Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp` | Runtime generation/reinstancing |
| `as-source.editor-class-reload-helper` | `Source/AngelscriptEditor/HotReload/ClassReloadHelper.cpp` | Editor-side class replacement |
| `as-source.editor-blueprint-impact` | `Source/AngelscriptEditor/BlueprintImpact/AngelscriptBlueprintImpactScanner.cpp` | Blueprint dependency/impact scan |
| `as-test.editor-class-reload` | `Source/AngelscriptEditor/Tests/AngelscriptClassReloadHelperClassReloadTests.cpp` | Editor reload regression |
| `as-test.hot-reload-blueprint-impact` | `Source/AngelscriptTest/HotReload/AngelscriptHotReloadBlueprintImpactTests.cpp` | Blueprint impact regression |

The file-watcher/coalescing source key remains unassigned until the later hot-reload article verifies the exact editor source owner and its current filename.

## Binding and UHT seeds

| Proposed key | Verified local path | Intended use |
|---|---|---|
| `as-source.runtime-bind-database` | `Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.cpp` | Binding registration database |
| `as-source.runtime-binds` | `Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp` | Core binding orchestration |
| `as-source.runtime-function-callers` | `Source/AngelscriptRuntime/Core/FunctionCallers.h` | Native call bridge/marshalling |
| `as-source.uht-binding-models` | `Source/AngelscriptUHTTool/AngelscriptFunctionBindingModels.cs` | Generator data model |
| `as-source.uht-binding-policy` | `Source/AngelscriptUHTTool/AngelscriptFunctionBindingPolicy.cs` | Eligibility/fallback policy |
| `as-source.uht-binding-emitters` | `Source/AngelscriptUHTTool/AngelscriptFunctionBindingEmitters.cs` | Generated shard emission |
| `as-source.uht-binding-generator` | `Source/AngelscriptUHTTool/AngelscriptFunctionBindingCodeGenerator.cs` | Generation orchestration |
| `as-source.uht-layout-version` | `Source/AngelscriptUHTTool/native-module-function-binding-layout-version.txt` | Layout compatibility contract |
| `as-test.uht-binding-strategy` | `Source/AngelscriptTest/UHTTool/AngelscriptFunctionBindingStrategyTests.cpp` | Strategy selection evidence |
| `as-test.uht-native-module-runtime` | `Source/AngelscriptTest/UHTTool/AngelscriptNativeModuleFunctionBindingRuntimeTests.cpp` | Runtime bridge evidence |

## Hazelight comparison seeds

These keys use Hazelight commit `f459e6322f63deef8d345f1c1624734cc22747e3` for the initial comparison. They are restricted evidence references: a public Wiki registry may retain path/revision/purpose metadata, but it must not emit private source text or a public link that readers cannot access.

| Proposed key | Restricted Hazelight path or local evidence | Intended use |
|---|---|---|
| `as-hazelight-report.engine-source-20260312` | `Documents/Hazelight/HazelightAngelscriptEngineChangeReport.txt` | Historical thirteen-visible-file inventory and report limitations |
| `as-hazelight-source.engine-uclass-hooks` | `Engine/Source/Runtime/CoreUObject/Public/UObject/Class.h` | UClass/UFunction/UScriptStruct hooks and fields |
| `as-hazelight-source.engine-function-pointer-erasure` | `Engine/Source/Runtime/CoreUObject/Public/UObject/CoreNative.h` | Type-erased function/method pointer machinery |
| `as-hazelight-source.engine-property-flags` | `Engine/Source/Runtime/CoreUObject/Public/UObject/ObjectMacros.h`, `UnrealType.h`, `UObjectGlobals.h` | `APF_*` definition, storage, and generated payload |
| `as-hazelight-source.engine-script-dispatch` | `Engine/Source/Runtime/CoreUObject/Private/UObject/ScriptCore.cpp` | `FUNC_RuntimeGenerated` call/event/RPC validation path |
| `as-hazelight-source.engine-object-construction` | `Engine/Source/Runtime/CoreUObject/Private/UObject/UObjectGlobals.cpp` | Script class/CDO/subobject initialization |
| `as-hazelight-source.uht-function-pointers` | `Engine/Source/Programs/Shared/EpicGames.UHT/Exporters/CodeGen/UhtHeaderCodeGeneratorCppFile.cs` | `GetASFunctionPointers` and generated records |
| `as-hazelight-source.uht-property-cache` | `Engine/Source/Programs/Shared/EpicGames.UHT/Types/UhtProperty.cs` | AS flag copy/read/write cache contract |
| `as-hazelight-source.plugin-blueprint-callable` | `Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/Binds/Bind_BlueprintCallable.cpp` | Consuming `ASReflectedFunctionPointers` and registering AS calls |
| `as-hazelight-source.plugin-blueprint-type` | `Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/Binds/Bind_BlueprintType.cpp` | Direct `GetFunctionMap()` enumeration and binding selection |
| `as-hazelight-source.plugin-class-generator` | `Engine/Plugins/Angelscript/Source/AngelscriptCode/Private/ClassGenerator/AngelscriptClassGenerator.cpp` | Class/struct generation and editor-only propagation |
| `as-hazelight-source.plugin-as-class` | `Engine/Plugins/Angelscript/Source/AngelscriptCode/Public/ClassGenerator/ASClass.h` | Hazelight `UASClass` state, proving the hybrid design |
| `as-hazelight-source.plugin-as-struct` | `Engine/Plugins/Angelscript/Source/AngelscriptCode/Public/ClassGenerator/ASStruct.h` | Hazelight `UASStruct` state and editor-only behavior |

Local counterpart keys are the ordinary `as-source.*` and `as-test.*` entries. A comparison row links one or more keys from each side and records the relationship/confidence separately.

## Runtime, debugging, diagnostics, and tests

| Proposed key | Verified local path | Intended use |
|---|---|---|
| `as-source.runtime-engine` | `Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` | Runtime engine integration |
| `as-source.runtime-subsystem` | `Source/AngelscriptRuntime/Core/AngelscriptSubsystem.cpp` | Engine/game-instance subsystem ownership |
| `as-source.runtime-debug-server` | `Source/AngelscriptRuntime/Debugging/AngelscriptDebugServer.cpp` | DebugServer V2 |
| `as-source.runtime-code-coverage` | `Source/AngelscriptRuntime/Extension/CodeCoverage/AngelscriptCodeCoverage.cpp` | Coverage collection |
| `as-source.runtime-coverage-report` | `Source/AngelscriptRuntime/Extension/CodeCoverage/CoverageReportGenerator.cpp` | Report generation |
| `as-test.runtime-code-coverage` | `Source/AngelscriptTest/Core/AngelscriptCodeCoverageTests.cpp` | Core coverage evidence |

State-dump and runtime-test-framework source keys should be expanded by enumerating their exact current files in the article batch; the directory-level inputs are `Source/AngelscriptRuntime/Dump/` and `Source/AngelscriptRuntime/Testing/`.

## Documentation source seeds

| Proposed key | Parent path |
|---|---|
| `as-knowledge.rt-hot-reload` | `Documents/Knowledges/ZH/RT_HotReload.md` |
| `as-knowledge.syntax-default-statement` | `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` |
| `as-knowledge.guide-syntax-features` | `Documents/Knowledges/ZH/Guide_SyntaxFeatures.md` |
| `as-knowledge.arch-uht-toolchain` | `Documents/Knowledges/ZH/Arch_UHTToolchain.md` |
| `as-guide.fork-strategy` | `Documents/Guides/AngelscriptForkStrategy.md` |
| `as-guide.test` | `Documents/Guides/Test.md` |
| `as-example.core-construction-script` | `Script/Examples/Core/Example_ConstructionScript.as` |
| `as-example.extended-network-replication` | `Script/Examples/Extended/Example_NetworkReplication.as` |
| `as-wiki.markdown-basic-showcase` | `Wiki/wiki/tiddlers/examples/MarkdownBasicShowcase.tid` |
| `as-wiki.wikitext-showcase` | `Wiki/wiki/tiddlers/examples/WikiTextSyntaxShowcase.tid` |
| `as-wiki.navigation-procedures` | `Wiki/wiki/tiddlers/as/navigation.tid` |
| `as-openspec.docs-foundation-hazelight-audit` | `openspec/changes/docs-wiki-content-foundation/research/hazelight-comparison-audit.md` |
| `as-openspec.docs-foundation-hazelight-engine-inventory` | `openspec/changes/docs-wiki-content-foundation/research/hazelight-engine-change-inventory.md` |
| `as-openspec.docs-foundation-tw-showcase` | `openspec/changes/docs-wiki-content-foundation/research/tiddlywiki-expression-showcase.md` |

Hazelight documentation keys should follow the path crosswalk, for example `as-hazelight-doc.scripting-delegates`, and resolve to the pinned docs commit plus upstream page. Their reuse rule remains paraphrase/rewrite; media remains excluded without license review.

## Registry review checklist

Before promoting a seed into the machine registry:

1. Resolve it against the exact published snapshot commit.
2. Confirm the path is inside the allowed corpus.
3. Assign the correct top-level or third-party license class.
4. Select a real symbol or specific textual anchor.
5. Select the smallest useful excerpt and calculate its hash.
6. Identify at least one consuming document and the citation purpose.
7. Link one or more tests when the source is used to support behavior.
8. Verify the commit-pinned GitHub URL.
9. Record whether a moved symbol may be proposed automatically or requires manual remapping.

The current local plugin worktree is dirty. These local path checks confirm source areas only; they do not make current uncommitted content eligible for the published corpus.
