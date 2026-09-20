# Can the current AS pipeline connect to struct / class generation

Date: 2026-09-17. Workspace: `git_3b46972bbc7ef05a4244fd2890d18183`. Provenance: draft finding `can-connect.md`, topic `angelscript/class-generation-handoff`.

In this repository, "struct / class generation" means `FAngelscriptClassGenerator` materializing script types into `UASClass` / `UASStruct`. Language author pockets `Language/Class` and `Language/Syntax/Struct*` already flow through codegen; that is not this gap.

## Conclusion

The pipeline can connect; half of the path already exists. The new frontend reaches `Resolved` `FAngelscriptClassDesc`. It cannot feed ClassGen yet. The missing piece is a host step that fills ClassGen-required fields and reattaches `ScriptType` from Taken `asCDefinitions`. The frontend must not create `UClass`.

## Two products that are not joined

```
.as source
  ├─ Parser / Sema / CompilationSession
  │    ├─ asCDefinitionConsumer
  │    │    └─ asCObjectType                 // class=asOBJ_REF, struct=asOBJ_VALUE
  │    └─ FAngelscriptDescriptorConsumer
  │         └─ FAngelscriptClassDesc         // Lifecycle=Resolved; ScriptType/Class/Struct=null
  │
  └─ old FAngelscriptPreprocessor
       └─ FAngelscriptClassDesc              // SuperClass / CodeSuperClass filled
            └─ Engine CompileClassGenerationHandoff
                 └─ FAngelscriptClassGenerator.AddModule
                      └─ UASClass / UASStruct
```

Contracts:

- `openspec/specs/angelscript/language/frontend/builder/spec.md`: ClassGen UClass materialization remains a later host step.
- `openspec/specs/angelscript/language/frontend/reflection-dependencies/spec.md`: frontend farthest stage is `Resolved`; no `UClass` / `UStruct` / `asITypeInfo` attach.

## What the new pipeline already does

`asCDefinitionConsumer` builds type shells from verified `asCRecordDecl`:

- `struct` → `asOBJ_SCRIPT_OBJECT | asOBJ_VALUE`
- `class` / default → `asOBJ_SCRIPT_OBJECT | asOBJ_REF`
- then bases, fields, construct / destruct behaviours

`FAngelscriptDescriptorConsumer::ProjectRecord` already recognizes `UCLASS` / `USTRUCT` / `UENUM`:

- `bIsStruct = HasAttr(USTRUCT)`
- `UPROPERTY` → `FAngelscriptPropertyDesc`
- `UFUNCTION` → `FAngelscriptFunctionDesc` (currently a stable `bBlueprintCallable`)
- lifecycle stops at `Resolved`; `Class` / `Struct` / `CodeSuperClass` / `ScriptType` stay empty

`asCBuilder::CompileDeclarations` already uses this projection. NativeEngine test `ResolvedDescriptorsRetainSemanticKeysAndNullMaterializationPointers` locks names without UObject.

## Four gaps that block ClassGen

1. ClassGen-required fields are missing. Analyze reads `SuperClass`, `bSuperIsCodeClass`, `CodeSuperClass`, `ScriptType`, `bIsStruct`. The new consumer stably fills `ClassName` / `bIsStruct` / attributed members. Super class string and `CodeSuperClass` still live in old `FAngelscriptPreprocessor::ResolveSuperClass`.
2. DefinitionsBuilt drops the reflection projection. Once `ModuleDefinitions` exist, `asCBuilderState::RefreshCompileOutput` scans `asCTypeInfo` into a thin ClassDesc (no `UCLASS`/`USTRUCT`, no `bIsStruct`, no attributes) and returns without `DescriptorConsumer.Project`. `CompileOutputReportsClassName` only proves the name remains.
3. `ScriptType` must stay null until the host step. ClassGen `Analyze` uses `ScriptType->GetPropertyCount()`. The Engine path requires `Module->ScriptModule != nullptr` before `AddModule`. Taken definitions are not attached to descriptors.
4. The Engine hot path still eats old preprocessor ModuleDesc. `CompileClassGenerationHandoff` → `PreGenerateClasses` → `ClassGenerator.AddModule`. The new Builder CompileOutput does not replace that input.

## Recommended join

Do not rewrite ClassGenerator. Do not let the frontend materialize UObject.

```
asCBuilder.RunThrough(DefinitionsFrozen)
  ├─ TakeDefinitions()                         // private asCObjectType, Engine=null
  └─ DescriptorConsumer.Project(...)           // authoritative Resolved descriptors
        │
        ▼
host step (reuse asCEngineCompileRegistration)
  ├─ fill SuperClass from resolved bases
  ├─ resolve CodeSuperClass / bSuperIsCodeClass from the bind type library after Registration
  ├─ attach ScriptType from the Taken set by stable name
  └─ hand the same FAngelscriptModuleDesc to existing ClassGenerator
        │
        ▼
FAngelscriptClassGenerator.Setup / Soft|FullReload
```
