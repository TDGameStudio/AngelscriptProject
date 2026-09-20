## Why

Register already creates one `asCModule` per file, but `CompileModules` still runs a dead Stage1–4 block. ClassGen never sees a shell, so the first editor compile cannot emit `UASClass` / `UASStruct` / `UEnum`.

## What Changes

- `CompileModules(Initial)` compiles preprocessor `ProcessedCode` through one `asCBuilder`, registers onto the host Engine, attaches same-name shells, and skips the whole Stage1–4 dead block.
- Existing `FAngelscriptClassGenerator` still consumes preprocessor descriptors, including already-filled `CodeSuperClass`.
- `ClassGenMaterialization` proves class / struct / enum UserData and reverse pointers after that Initial compile.

## Capabilities

### New Capabilities

- `angelscript/runtime/class-generation`: Initial host compile materializes UCLASS / USTRUCT / UENUM UserData from preprocessor descriptors after Builder+Register.

### Modified Capabilities

None. Frontend `CompileDeclarations` null-pointer contracts stay unchanged.

## Impact

Plugin: `FAngelscriptEngine::CompileModules` Initial path; NativeEngine Compile `ClassGenMaterialization` tests.

Parent repository: this Change's OpenSpec records only.

## Non-goals

Full/SoftReload Builder skip. CacheV2 function reuse. Delegate / event UserData. Frontend UObject creation. Rewriting ClassGen. Restoring `ALWAYS_CREATE` / `Build` or `BindRegisteredTypesForClassGeneration`. Replacing preprocessor descriptors with Project.
