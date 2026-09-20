# UCLASS reload ProcessEvent

See [attachments/drafts/design.md](attachments/drafts/design.md) for the accepted scoped design.

## Call chains

```
Inline UCLASS ScriptV1 / ScriptV2
→ FAngelscriptPreprocessor::AddFile + Preprocess
→ GetModulesToCompile()
→ FAngelscriptEngine::CompileModules(Initial | SoftReloadOnly | FullReload)
→ ClassGen Analyze + Generation
→ NewObject or FKismetEditorUtilities::CreateBlueprint
→ UObject::ProcessEvent(GetVersion)
```

Measured at: 38e1b7a4fe9bbc540106f28d7858ccd5d899868f (workspace dirty)

dirty: this Change owns `ClassGenUClassReloadTests.cpp`, preprocessor `__InitDefaults` inject, Builder CodeSuperClass rebase + StaticClassHelper strip, TypeDatabase UObject seed, `UpdateConstructAndDefaultsFunctions` name lookup, and editor `UnrealEd`/`BlueprintGraph` test deps. Unrelated primary-tree and submodule dirt remains outside this Change.
