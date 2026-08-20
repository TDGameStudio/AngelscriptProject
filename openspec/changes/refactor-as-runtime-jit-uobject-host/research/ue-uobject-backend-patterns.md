# UE UObject backend patterns vs Runtime JIT

Research date: 2026-08-18. Sources: UE5-main Knot, local UE 5.8 headers, current plugin + worktree JIT code.

## 1. What already exists in this repo

### Main plugin (already landed)

- `FAngelscriptJITCoordinator` is the only `asIJITCompiler` per `asIScriptEngine`.
- Optional Runtime backends register `IAngelscriptRuntimeJITBackendFactory` through `IModularFeatures`.
- Each Engine creates at most one `IAngelscriptRuntimeJITBackendSession`.
- Workers consume an owned immutable snapshot and **must not** retain `UObject` / `asIScriptFunction*` pointers.
- Executable code is a thread-safe `FAngelscriptRuntimeJITCodeLease`, not a UObject.
- `UAngelscriptSubsystem` is the process `UEngineSubsystem` that owns the **primary** `FAngelscriptEngine`. Tests and StaticJIT generation create additional Engines.

### Unmerged worktrees

| Worktree | Plugin | Registration |
| --- | --- | --- |
| `.worktrees/feature-as-angelsea-runtime-jit-plugin` | `Plugins/AngelseaRuntimeJIT` | `FAngelseaMirBackendFactory` in `StartupModule` via `IModularFeatures` |
| `.worktrees/feature-as-angelsea-llvm-jit-plugin` | `Plugins/AngelseaLLVMJIT` | `FAngelseaLLVMJITFactory`, same contract |

Neither plugin is a `UObject`. Both implement `CreateSession()` → `TUniquePtr<IAngelscriptRuntimeJITBackendSession>`.

### Current spec constraints that collide with a naive UObject session

From archived `as-runtime-jit-backend` / `as-unified-jit-coordinator`:

- One selected Runtime BackendId per Engine, not a compile chain.
- Sessions are Engine-local; backends must not use a process-current Engine.
- Choosing MIR vs LLVM automatically, or chaining backends per function, is a non-goal of the first slice.
- Backend lowering stays host-neutral (no UObject/UFunction/GC/World includes in the lowering core).

## 2. Closest Unreal Engine analogs

These are the patterns that match "abstract `UCLASS` + plugin subclasses + owner holds `TArray<TObjectPtr<Base>>`".

### A. `UMassProcessor` + `GetDerivedClasses` (best analog for *discovery*)

`UMassProcessor` is an abstract `UObject` (`EditInlineNew`, config). `UMassEntitySettings::BuildProcessorList()` does:

1. `GetDerivedClasses(UMassProcessor::StaticClass(), SubClasses)`
2. skip abstract classes
3. take each subclass **CDO** (`GetMutableDefault<UMassProcessor>`)
4. store `TArray` of processor CDOs on settings, grouped by phase

Plugin modules just compile a `UCLASS()` subclass. There is no `IModularFeatures` factory.

Important: Mass still copies/instantiates processors into an entity manager. The CDO list is a catalog, not the live threaded worker.

GC footnote in UE 5.8: if settings are in the GC-disregard window and a late plugin CDO is not, Mass `AddToRoot()`s that CDO. A JIT catalog would hit the same "plugin loaded after subsystem init" issue.

### B. `UGameFeatureAction` + Instanced array (best analog for *owned polymorphic objects*)

```cpp
UCLASS(DefaultToInstanced, EditInlineNew, Abstract)
class UGameFeatureAction : public UObject

UPROPERTY(EditDefaultsOnly, Instanced)
TArray<TObjectPtr<UGameFeatureAction>> Actions;
```

Lyra inventory fragments, Lyra widget factories, Movie Pipeline settings, Live Link device presets, `UAssetUserData`, and `FPerPlatformSettings` use the same Instanced `TArray` / `TObjectPtr` shape.

This is editor-friendly: details panel, `NewObject` with Outer = owner, GC via Outer.

It is a **config/action** object, executed on game thread during activate/deactivate. It does not own RWX memory or background compilers.

### C. `UMoviePipelineSetting`

Abstract `UObject` settings owned by a pipeline config. `UMoviePipeline` iterates enabled settings by class. Lifecycle: `OnMoviePipelineInitialized` / shutdown. Game-thread export, not a JIT.

### D. `URigVMCompiler`

This is one of the few UE **compilers that are UObjects**. It compiles on the game/editor thread into a RigVM bytecode/program object. It does not publish process-executable native code, does not survive plugin unload with active native readers, and is not a per-script-engine session factory.

### E. Patterns that stay `F` / modular features (counter-examples)

UE does **not** put these compilers on `UObject` backends:

- Blueprint compiler (`FKismetCompilerContext`)
- Niagara compiler / VectorVM
- Shader compiler
- Live Coding (`ILiveCodingModule`)
- StaticJIT in this plugin (`FAngelscriptBytecodeJIT`, Provider registry)

Those systems have worker threads, process-global registries, or executable/native output. They keep UObject at the *asset/config* edge.

## 3. Mapping the user's sketch onto UE

User sketch:

```text
UAngelscriptRuntimeJIT          // abstract UObject
  UAngelscriptMirRuntimeJIT     // plugin subclass
  UAngelscriptLLVMRuntimeJIT    // plugin subclass

UAngelscriptSubsystem
  TArray<TObjectPtr<UAngelscriptRuntimeJIT>> RuntimeJITs
```

This matches **Mass catalog** + **Game Feature Instanced array** on the surface.

It does not match Runtime JIT's actual units of ownership:

| Unit | Current owner | If it becomes a UObject |
| --- | --- | --- |
| Available backends | `IModularFeatures` factories | Subsystem `TArray` or CDO list — good |
| Per-Engine compiler | `FAngelscriptJITCoordinator` | Must stay non-UObject or one-per-Engine, not process-global |
| Per-Engine compile session | `TUniquePtr<IAngelscriptRuntimeJITBackendSession>` | `NewObject` with Outer = ? Engine is not a UObject |
| Executable code | `FAngelscriptRuntimeJITCodeLease` (`TSharedPtr`) | Must not be GC'd while a native call is on stack |
| Background compile | coordinator queue + snapshot | Worker cannot touch the UObject |

`FAngelscriptEngine` is a `USTRUCT`-like / non-UObject engine wrapper stored on the subsystem (`UPROPERTY() FAngelscriptEngine OwnedEngine`). There can be many Engines. A subsystem `TArray` is process-global. If that array *is* the live session, test Engines and generation Engines would share MIR/LLVM contexts, which the current spec forbids.

## 4. Recommended host split

Keep three layers, only the first of which is a UObject:

1. **Catalog UObject** (`UAngelscriptRuntimeJIT`, abstract, `Abstract`, maybe `DefaultToInstanced`): BackendId, display name, platform/config flags, `CreateSession()`. Discovered by `GetDerivedClasses` or Instanced array on the subsystem/settings.
2. **Session F-object** (current `IAngelscriptRuntimeJITBackendSession`): Engine-local, owns MIR/LLVM contexts, not a UObject.
3. **Coordinator** (current `FAngelscriptJITCoordinator`): still the only `asIJITCompiler`.

That is Mass-shaped: UObject for identity/discovery, non-UObject (or a copied instance) for execution.

## 5. Open decision that changes the design

Does the subsystem `TArray` mean:

- **Catalog**: all loaded backends, pick one BackendId per Engine (compatible with current coordinator), or
- **Active set**: several backends live at once, with fallback/chain/comparison?

The archived coordinator spec chose catalog + one selected backend. A live active set would be a new product decision.
