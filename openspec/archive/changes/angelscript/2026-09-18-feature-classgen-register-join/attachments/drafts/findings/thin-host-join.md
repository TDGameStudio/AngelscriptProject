# Thin host: Builder+Register skips Stage1–4; preprocessor descriptors still feed ClassGen

Date: 2026-09-18. Workspace: `git_3b46972bbc7ef05a4244fd2890d18183`.
Scope: Q1 = C. Source: local draft finding; translated for Change export.

## Conclusion

`CompileModules` cannot be fixed by editing only `CompileModule_Types_Stage1`. After Stage1 errors, later steps still assign `asNOT_SUPPORTED` and one loop **unconditionally** sets `bCompileError = true`. The thin host must replace the whole dead compile block with one Builder+Register, then fall into existing ClassGen. ClassGen input stays the preprocessor `ModuleDesc` (already has `CodeSuperClass`).

## The dead compile is wider than Stage1

Before ClassGen, `CompileModules` still:

```
CompileModule_Types_Stage1
  └─ always: Legacy module compilation is unavailable
ParallelFor / GenerateTypes / Layout / Functions
  └─ Result = asNOT_SUPPORTED → bCompileError
Allocate globals (~6351)
  └─ non-null ScriptModule unconditionally sets bCompileError
CompileModule_Functions_Stage2 / CompileModule_Code_Stage3
  └─ mark failure again
```

Register first, then run the old stage loops, and every module still fails. The thin host must **skip** this block, not turn it green.

## Thin-host join

```
Preprocessor InModules              // ModuleName=dotted; Code=ProcessedCode; CodeSuperClass resolved
        │
        ▼
asCBuilder.RunThrough(ByteCodeEmitted)
  Path = ModuleName                 // Register shell name matches preprocessor; SwapIn SetName is identity
  TypeContext = host HostProcess bind context
        │
        ▼
Register(Sets, Output)              // host Engine; asCModule shell + Type.module
        │
        ▼
InModule.ScriptModule = same-name Output shell
        │
        ▼
skip Stage1–4 dead block
        │
        ▼
existing ClassGenerator.AddModule / Setup / Soft|FullReload
```

## Name join

| Surface | Value | Source |
|---|---|---|
| Preprocessor `ModuleDesc.ModuleName` | `VirtualPath.ToModuleName()`, e.g. `Player` | `AngelscriptPreprocessor.cpp` / `AngelscriptSource.cpp` |
| Project / Register shell name | `Fragment.GetLogicalSourceKey()` = `Source.GetPath()` | `as_descriptor_consumer.cpp:348`; `as_source_manager.cpp` |
| Test source Path | `First.as` | `MakeSharedSource` |
| Host source Path | `VirtualPath.ToString()`, e.g. `/Angelscript/Game/Player.as` | `AssignHostLogicalPath` |
| `SwapIn` | `ScriptModule->SetName(MakeModuleName(ModuleName))`; `MakeModuleName` is identity today | `AngelscriptEngine.cpp:5313` |

Do not use a disk path as the Builder key. Write Builder source Path as the preprocessor `ModuleName` so Register shells match `ActiveModules`. ClassGen `GetType(ClassName)` uses the pointer, not the dotted name.

## Feed ProcessedCode

The preprocessor writes `UCLASS` helpers, `StaticClass`, defaults, and range-for into `Module.Code[].Code` (`ProcessedCode`). Old Stage1 compiled that text. Builder still lexes/semas; the input must stay that expanded text, not the disk original. Otherwise ClassGen descriptors and asType diverge.

## `CodeSuperClass`

Preprocessor `ResolveSuperClass` already fills `UClass*` (bind name `Actor`, not `AActor`). `CreateFullReloadClass` uses it unconditionally. C does not make Project the authority, so it does not resolve again after Register unless a test path has no preprocessor descriptor.

`USTRUCT` / `UENUM` do not take this path. A `UCLASS` without a native parent crashes.

## ClassGen stays on the host

`GetNamespacedTypeInfoForClass` reads `FAngelscriptEngine::Get().Engine`. Tests need `FAngelscriptEngineScope` and must Register onto that same host Engine. `asCreateScriptEngine()` is not enough.

Setup uses `Module->GetType(ClassName)`. Register already `AddClassType`. UserData is still written by existing Full/SoftReload `SetUserData`.

## Out of this Change

- ClassGen algorithm, frontend UObject, `ALWAYS_CREATE` / `Build`
- Delegate / event UserData acceptance
- CacheV2 function reuse: it reads `ScriptModule->builder`; Register shells have no builder
- Replacing preprocessor descriptors with Project (that is B / H2)

## Left to later work

Whether reload uses the same Builder skip. Initial is enough for the first editor `.as` → UCLASS. Full/SoftReload still hits the dead Stage block if left unchanged. Cache reuse is a later Change.
