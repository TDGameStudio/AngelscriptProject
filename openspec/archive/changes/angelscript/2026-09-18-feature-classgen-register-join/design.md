# Join Register modules to ClassGen on Initial compile

Seeded from [attachments/drafts/design.md](attachments/drafts/design.md). Approval R4.

Preprocessor descriptors stay the ClassGen input. Only Initial source compile skips the dead Stage1–4 block after Builder+Register.

## Goals / Non-Goals

**Goals:** `CompileModules(Initial)` produces `asCModule` shells on the host Engine and ClassGen UserData for class / struct / enum.

**Non-Goals:** reload skip; CacheV2 reuse; delegate / event UserData; frontend UObject; ClassGen rewrite; `ALWAYS_CREATE` / `Build`; `BindRegisteredTypesForClassGeneration`.

## Decisions

- Builder source Path equals preprocessor `ModuleName`. Input text is `ProcessedCode`.
- TypeContext is the HostProcess bind identity context already on the host Engine.
- Modules with `ScriptModule` or `bLoadedPrecompiledCode` do not rerun Builder.
- `CodeSuperClass` stays preprocessor-filled.
- Test identity is `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization`.

## Call chains

```
FAngelscriptPreprocessor.InModules
→ FAngelscriptEngine::CompileModules(Initial)
   → asCBuilder.RunThrough(ByteCodeEmitted)
   → asCEngineCompileRegistration.Register(Sets, Output)
   → InModule.ScriptModule = same-name shell
   → skip Stage1–4
   → FAngelscriptClassGenerator.AddModule / Setup / Soft|FullReload
   → asType.SetUserData(UASClass|UASStruct|UEnum)
```

Measured at: `38e1b7a4fe9bbc540106f28d7858ccd5d899868f`

dirty: yes; parent tree already has Language fixtures, container authors, and other in-flight Changes. This Change owns `CompileModules` Initial skip and `ClassGenMaterialization` tests listed in `tasks.md`.
