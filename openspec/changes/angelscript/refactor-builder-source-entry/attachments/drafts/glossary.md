# Confirmed Public Vocabulary

Approved on 2026-09-13 for angelscript/refactor-builder-source-entry. Source identity: selected builder-source-entry design in angelscript/virtual-source-filesystem.

| Contract | Name or signature | Meaning |
|---|---|---|
| Common source | FAngelscriptSource | Sole UE/SDK source type; host fields remain. |
| Preparation | FAngelscriptSource() | Starts with bHasSourceText=false. |
| Ready construction | FAngelscriptSource(FString, FUtf8String&&) | Moves the body. |
| Logical path | GetPath() const -> FStringView | Exact logical identity. |
| Source body | GetSourceText() const -> const FUtf8String& | Non-copying access. |
| Source files | unreal/AngelscriptSource.h/.cpp | Relative to the angelscript SDK root; old Core header forwards. |
| Builder | asCBuilder | Actual three-argument signature below. |
| Execution | RunThrough(asEBuilderStage = ByteCodeEmitted), RunStage(asEBuilderStage) -> bool | Monotonic target execution / strict next stage. |
| Callback interface | asIBuilderCallbacks in as_builder_callbacks.h | Typed hook arguments, no context. |
| Stage hooks | OnBeforeStage(asEBuilderStage), OnAfterStage(asEBuilderStage) -> bool | Ordinary failure short-circuits. |
| Declarations | OnDeclarationsReady(const asCDefinitionCompileOutput&) -> bool | One deep-read-only publication. |
| Final notification | OnBuildFinished(bool, asEBuilderStage, FStringView, const asCCompileOutput&) -> void | Once to all valid registered objects; cannot alter the outcome. |
| Description/diagnostic result | asCCompileOutput, asCDefinitionCompileOutput, GetCompileOutput, TakeCompileOutput | Existing names, stronger lifetime/read-only contract. |
| Definition result | asCModuleDefinitionSet, GetModuleDefinitionSet, TakeModuleDefinitionSet | Existing separate owned product. |

```cpp
asCBuilder(
    TConstArrayView<TSharedRef<const FAngelscriptSource, ESPMode::ThreadSafe>> Sources,
    const asSBuilderOptions& Options,
    TConstArrayView<asIBuilderCallbacks*> Callbacks = {});
```

Retain necessary existing host factories and helpers. Do not introduce another source record, source-collection wrapper, or Builder context. Fine-grained read-only result accessors, internal helpers, and test identities may follow inspected neighboring conventions; they must not silently introduce a second descriptor family. The accepted design does not promise binary ABI stability.
