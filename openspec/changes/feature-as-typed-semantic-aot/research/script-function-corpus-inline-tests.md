# Script function corpus → inline C++ tests

Record-only plan for tasks 6.10–6.10d. Do not treat `Script/` as a
TypedASTJIT success suite. Adapt **function** bodies; leave Actor /
container / BlueprintOverride teaching scripts as fallback cases.

## Intent

Prove function JIT lines up:

1. Interpreter VM returns the same integers the current `Script/Tests`
   fixtures encode.
2. `UFUNCTION()`-wrapped scalar versions select TypedASTJIT at
   generation time.
3. Class-constructing and container adaptations stay on BytecodeJIT/VM.

Implementation waits for an explicit go-ahead after this record.

## Source map

| Project source | Original shape | Adaptation | Expected |
|---|---|---|---|
| `Script/Tests/Test_Handles.as` | `int HandlesFixtureValue()` → `9` | Keep body; add `UFUNCTION()` only in the generation case | VM `9`; Typed root |
| `Script/Tests/Test_Enums.as` | `int EnumsFixtureValue()` → `1` | Same | VM `1`; Typed root |
| `Script/Tests/Test_Inheritance.as` | `3 + 4` locals, no real inheritance | Same (name kept; body is scalar) | VM `7`; Typed root |
| `Script/Tests/Test_GameplayTags.as` | `return 1` (no GameplayTag API) | Same | VM `1`; Typed root |
| `Script/Tests/Test_ActorLifecycle.as` | script class + `Step()` → `21` | Keep class + caller | VM `21`; Typed **fallback** |
| `Script/Tests/Test_SystemUtils.as` | script class + `Read()` → `13` | Keep class + caller | VM `13`; Typed **fallback** |
| `Script/Tests/Test_ExampleActorFixture.as` | script class field `42` | Keep class + caller | VM `42`; Typed **fallback** |
| `Script/Tests/Test_MathNamespace.as` | script class field `10` | Keep class + caller | VM `10`; Typed **fallback** |
| `Script/Examples/Core/Example_Array.as` | `UFUNCTION` + `TArray` + `Log` | Reduced `UFUNCTION` that still uses `TArray<int>` | Typed **fallback** |
| `Script/Examples/Core/Example_Math.as` | non-`UFUNCTION` `Math::` calls | **Out of this slice** (native-call / void / no UFUNCTION) | do not add as Typed success |
| `Script/Game/Example_Actor.as` and other Examples | `AActor`, `UPROPERTY`, `BlueprintOverride` | **Out of this slice** | do not add as Typed success |

`Test_ReflectedScriptSuites.as` is not in this first corpus.

## Proposed files

- Tests: `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/ScriptCorpus/AngelscriptTypedASTJITScriptFunctionCorpusTests.cpp`
- Automation prefix: `Angelscript.TestModule.StaticJIT.TypedASTJIT.ScriptCorpus`
- Optional tiny execute helper in that `.cpp` or a same-folder `.h`; do not grow `AngelscriptStaticJITGenerationEngineTests.cpp`

## Proposed `TEST_METHOD`s

- `AdaptedScriptScalarFixturesMatchVmResults`
- `AdaptedScriptClassFixturesMatchVmResults`
- `AdaptedScriptScalarUFunctionsSelectTypedBackend`
- `AdaptedScriptClassAndArrayFixturesFallbackFromTypedBackend`

## Verification (when implementing)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label semantic-aot-script-corpus -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.TypedASTJIT.ScriptCorpus" -Label semantic-aot-script-corpus -TimeoutMs 600000
```

Work from `V:\`. Do not hand-edit generated Provider digests. Do not start
4.17/4.18, 5.7/5.9, 0.7, or group 8 from this record.
