# Candidate: thin host joins Register to ClassGen on Initial

Source: local draft `angelscript/classgen-register-join` scope `register-classgen-join`. Approval: R4. Translated from the approved Chinese design; identifiers unchanged.

## Problem

Register already creates one `asCModule` per file. Editor `CompileModules` still runs the dead Stage1–4 block, so ClassGen never sees a shell and cannot emit `UASClass` / `UASStruct` / `UEnum`.

## Accepted

- Preprocessor `ModuleDesc` remains the ClassGen input, including an already-resolved `CodeSuperClass`.
- Only `ECompileType::Initial` source compiles: one `asCBuilder` plus `Register(Sets, Output)` onto the host Engine, then skip the whole Stage1–4 block.
- Full/SoftReload keep the current dead path. CacheV2 function reuse is out of this Change.
- Builder source Path equals the preprocessor `ModuleName`. Input text is `ProcessedCode`.
- Modules that already have `ScriptModule` or `bLoadedPrecompiledCode` do not run Builder again.
- No new public helper. Do not rewrite ClassGen. Do not create UObject in the frontend. Do not restore `ALWAYS_CREATE` / `Build`.
- Delegate / event UserData is not accepted.
- Test class `ClassGenMaterialization`. Target Change `angelscript/feature-classgen-register-join`.

## Call chain

```
FAngelscriptPreprocessor
  └─ InModules                    // CodeSuperClass, UCLASS flags, ProcessedCode
        │
        ▼
CompileModules(Initial)
  ├─ asCBuilder.RunThrough(ByteCodeEmitted)
  │    Path = ModuleName
  │    TypeContext = HostProcess bind context
  ├─ asCEngineCompileRegistration.Register(Sets, Output)
  │    asCModule shell + Type.module + AddClassType
  ├─ InModule.ScriptModule = same-name shell
  ├─ skip Stage1–4 dead block     // includes unconditional globals failure
  └─ FAngelscriptClassGenerator
       AddModule / Setup / Soft|FullReload
       asType.SetUserData(UASClass|UASStruct|UEnum)
```

`CodeSuperClass` / `Class` / `ScriptType` stay null after `CompileDeclarations`. Materialization happens only in host ClassGen.

Reload:

```
CompileModules(FullReload|SoftReloadOnly)
  └─ existing Stage1–4            // still fails; follow-up Change
```

## Acceptance

| Path | Proof |
|---|---|
| `ClassGenMaterialization` through `CompileModules(Initial)` | No Legacy Stage1 error; `ScriptModule` non-null; one class, one struct, one enum; UserData and reverse pointers |
| Frontend ReflectionDescriptors | `CodeSuperClass` still null after CompileDeclarations |
| Full/SoftReload | Not required green |

## Out of scope

- Project descriptors replacing the preprocessor (option B)
- Reload Builder skip (Q2=I)
- CacheV2 `ScriptModule->builder` reuse
- Delegate / event UserData
- ClassGen rewrite, frontend UObject, withdrawn `BindRegisteredTypesForClassGeneration`
