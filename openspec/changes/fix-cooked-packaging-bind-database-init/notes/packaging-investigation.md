# Packaging Investigation Trace

Chronological record of the failures encountered while making the project package
for the first time, and how each was diagnosed and fixed.

## Error chain

1. **Plugin won't compile for non-editor target** — editor-only code (`HasMetaData`/
   `GetMetaData`, UHT-emitted editor entries) referenced in cooked builds where
   `WITH_EDITOR == 0`.
   → Guarded with `WITH_EDITORONLY_DATA`; UHT generator emits `#if WITH_EDITOR`.

2. **Cook fails: AngelScript class not found for Blueprint** — `BP_AExampleActorType`
   couldn't resolve its parent `AExampleActorType`; runtime skips `Examples/` in
   non-editor builds.
   → Initially used `-as-force-preprocess-editor-code`; later replaced by relocating
   `Example_Actor.as` to `Script/Game/`.

3. **Precompiled-data generation crash (StaticJIT assertion)** —
   `UnrealEditor-Cmd.exe -as-generate-precompiled-data` crashed in StaticJIT codegen.
   → Added `bSkipStaticJITCodeGen` + `-as-skip-static-jit-codegen`.

4. **Editor rebuild blocked by Live Coding** — running editor instance held the DLL.
   → User closed the editor instance.

5. **Cook shutdown crash (AS struct destructor)** — GC destroyed `UASStruct` after the
   AngelScript engine was released, calling into freed memory.
   → `GAngelscriptEnginesReleasedForExit` flag + guard in `FASStructOps::Destruct`.

6. **RunPackage.ps1 boolean parsing** — `:$false` not parsed via `-File`.
   → Invoke via `-Command "& ..."`.

7. **Packaged exe crash: `Binds.Cache` not found** —
   `DirectoriesToAlwaysStageAsUFS=(Path="Script")` resolved relative to `Content/`.
   → Changed to `../Script`.

8. **Packaged exe crash: mass type-registration errors** — hundreds of
   `"X is not a data type in global namespace"` for `FMargin`, `UObject`,
   `UActorComponent`, etc.
   - First (wrong) hypothesis: editor-script pollution from
     `-as-force-preprocess-editor-code`. Relocating the script + removing the flag
     fixed cook-time issues but NOT the runtime crash.
   - Second (incomplete): crash surfaced in `CompileOutIfNoLog` via a null `Function`;
     suspected worker-thread `FindObject` racing.
   - **True root cause**: `FAngelscriptBindDatabase::Get().Load(Binds.Cache)` was
     called BEFORE the engine-owned `BindDatabase` was constructed in
     `Initialize_AnyThread()` (~line 1865). `Get()` fell back to a static
     `LegacyBindDatabase`; cache data went there while the engine's database stayed
     empty, so every `ExistingClass` lookup failed.
   → Fixes (combined):
     - Move `BindDatabase = MakeUnique<FAngelscriptBindDatabase>();` before `Load`.
     - `ShouldInitializeThreaded()` returns false for cooked (`AS_USE_BIND_DB`).
     - Null-guard the `CompileOut*` helpers.

9. **Zen storage server connection failure during staging** — transient, caused by
   concurrent diagnostic builds.
   → Retried after ensuring no conflicting processes.

## Final verified state

Packaged `AngelscriptProject.exe` launches, loads `PrecompiledScript.Cache`, enters
`ActorTestMap`, registers all AngelScript types (zero `not-a-data-type`), and runs
without crashing. `BP_AExampleActorType` was not placed in the level, but the script
system itself is confirmed functional.

## Touched files

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` / `.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASStruct.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/BlueprintCallableReflectiveFallback.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/AngelscriptStateDump.cpp`
- `Plugins/Angelscript/Source/AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`
- `Config/DefaultEngine.ini`, `Config/DefaultGame.ini`
- `Tools/RunPackage.ps1` (new)
- `Script/Examples/Core/Example_Actor.as` → `Script/Game/Example_Actor.as`
