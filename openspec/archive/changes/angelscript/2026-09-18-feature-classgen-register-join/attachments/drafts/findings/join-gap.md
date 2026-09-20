# Why Register still cannot materialize UE types

Date: 2026-09-18. Workspace: `git_3b46972bbc7ef05a4244fd2890d18183`.
Source: local draft finding; translated for Change export.

## Conclusion

`asCModule` shells now appear after `Register(Sets, Output)`. ClassGen still cannot emit `UASClass` / `UASStruct` / `UEnum` from that chain. Registration must land on the **host** `FAngelscriptEngine` Engine, `CodeSuperClass` must be present, and the same ModuleDesc must reach the existing `FAngelscriptClassGenerator`.

## Already joined

```
asCBuilder.RunThrough
  └─ asCEngineCompileRegistration.Register(Sets, Output)
        ├─ Type.engine / TypeId
        ├─ asCModule(ModuleName, engine)
        ├─ Type.module / ModuleDesc.ScriptModule
        └─ AddClassType / AddEnumType / AddCallableType
```

`GetNamespacedTypeInfoForClass`'s `check(Module != nullptr)` is no longer hit by a missing shell. `Module->GetType(name, ns)` needs `allLocalTypes`; Register already `AddClassType`.

## Still broken

1. **ClassGen binds the host singleton, not a test Engine.**
   `GetNamespacedTypeInfoForClass` reads `FAngelscriptEngine::Get().Engine`. Register onto `asCreateScriptEngine()` then `AddModule` and ClassGen looks at the wrong Engine.
2. **`CodeSuperClass` stays empty on Project descriptors.**
   The new Project fills the `SuperClass` string only. Preprocessor `ResolveSuperClass` uses `FAngelscriptType::GetByAngelscriptTypeName` to fill `UClass*`. `CreateFullReloadClass` uses `CodeSuperClass` unconditionally (`IsChildOf` / `GetPropertiesSize`). A `UCLASS` without a native parent crashes. `USTRUCT` / `UENUM` do not.
3. **Host four-stage compile is a dead path.**
   `CompileModule_Types_Stage1` always errors: `Legacy module compilation is unavailable; use frozen Builder inputs.`
   `CompileModules` still sends preprocessor ModuleDesc values into ClassGen, but Stage1 failure leaves `ScriptModule` null and `AddModule` is skipped. Later loops can still fail even after a shell exists; see [thin-host-join.md](thin-host-join.md).
4. **Name spaces differ.**
   Project `ModuleName` = `LogicalSourceKey` (e.g. `First.as`). Host `MakeModuleName` / `VirtualPath.ToModuleName()` is dotted (`Game.Player`). SwapIn renames the `asCModule`; join by file, do not assume the names already match.
5. **The previous join pieces were withdrawn.**
   `BindRegisteredTypesForClassGeneration` and `ClassGenMaterializationTests.cpp` are gone. `PerformFullReload` is not `ANGELSCRIPTRUNTIME_API`. The accepted design still lives in archived Change `feature-classgen-type-materialization`: resolve `CodeSuperClass` after Register, ClassGen Setup/Reload, prove class/struct/enum UserData. This Change keeps preprocessor `CodeSuperClass` instead of resolving it again.

## Join options

**A. Test join (reuse the accepted ClassGen design)**
Register CompileOutput on the host Engine → resolve `CodeSuperClass` → `AddModule` / Setup / FullReload. NativeEngine.Compile proves UserData. Editor `CompileModules` still fails.

**B. Host compile also uses Builder**
Replace Stage1–4 in `CompileModules` with one Builder+Register, then fall into existing ClassGen/SwapIn. The editor can emit UCLASS from `.as`. Larger: cache, hot reload, dotted module names, whether preprocessor descriptors stay authoritative.

**C. Test join + thin host (Q1 selected)**
A's proof, plus one Builder+Register in `CompileModules` that **skips the whole** Stage1–4 block (including the unconditional globals failure). Preprocessor descriptors stay the ClassGen input. Not B: do not change authority, do not join CacheV2 reuse. Details in [thin-host-join.md](thin-host-join.md).

Previous Change: do not rewrite ClassGen; do not create UObject in the frontend. Under C, `CodeSuperClass` stays filled by the preprocessor.
