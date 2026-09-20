# Legacy UE test source isolation

Use this reference only when preserving an old Unreal test corpus as readable source while removing it from the active build and reflection graph.

## Required layout

Place the complete old tree beneath a source-free parent named `Legacy/`, then place `.ubtignore` in that parent:

```text
AngelscriptTest/
|-- AngelscriptTest.Build.cs
|-- AngelscriptTestModule.cpp
|-- Core/AngelscriptTestModule.h
|-- NativeEngine/                     NativeEngine layer homes
|-- Bindings/
|-- Framework/
|-- FrameworkTests/
|-- Baseline/
|-- TestCode/
|-- TestFramework/
`-- Legacy/
    |-- .ubtignore                    hard source-discovery boundary
    |-- Core/                         retained old sources
    |-- Bindings/
    `-- ...
```

Keep the active module implementation, any module header required by it, and replacement tests outside the ignored parent. A marker does not provide a supported runtime toggle: restoring the old corpus requires a later explicit OpenSpec Change that removes the boundary and repairs dependencies and startup behavior.

## Why the marker needs a parent

In UE 5.8, `UEBuildModuleCPP.FindInputFilesFromDirectory()` notices `.ubtignore`, and the recursive caller stops before visiting descendants. However, normal source enumeration can still collect `.cpp` files located directly beside the marker before that return. UHT checks the marker separately and can exclude the same directory's headers earlier. Putting the marker directly beside old `.cpp` files can therefore create an invalid split graph: C++ still compiles old unity inputs while their generated headers disappear.

The reliable shape is an otherwise source-free ignored parent with all old code below it. UBT encounters the marker before visiting any child source directory, and UHT excludes the same complete subtree.

Engine source evidence:

- `Engine/Source/Programs/UnrealBuildTool/Configuration/UEBuildModuleCPP.cs`: `FindInputFilesFromDirectoryRecursive()` and `FindInputFilesFromDirectory()`.
- `Engine/Source/Programs/UnrealBuildTool/System/UHTExecution.cs`: `.ubtignore` checks used by header discovery.
- `Engine/Source/Programs/UnrealBuildTool/System/TargetMakefile.cs`: ignored-directory participation in source topology tracking.

## Do not wrap reflected types in the legacy macro

UHT rejects `UCLASS`, `USTRUCT`, `UINTERFACE`, `UFUNCTION`, and `UPROPERTY` declarations inside arbitrary preprocessor blocks; `WITH_EDITORONLY_DATA` is the narrow supported exception. A whole-file `#if WITH_ANGELSCRIPT_UNITTESTS` guard is therefore unsuitable for legacy test headers that contain reflected fixtures. It can also leave stale generated thunks referring to implementations removed from guarded `.cpp` files.

Use the directory boundary for source discovery. Keep `WITH_ANGELSCRIPT_UNITTESTS=0` as the policy gate for any active module shell, force include, engine-pool startup, and legacy-only dependency declaration that remains outside the ignored tree.

## Transition and verification

After adding, removing, or relocating a `.ubtignore` boundary, bypass cached UBT makefiles for the transition build so the source graph is rebuilt from disk:

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{
    Target = 'AngelscriptProjectEditor'
    Platform = 'Win64'
    Configuration = 'Development'
    BuildConcurrency = 'Auto'
    ConcurrencyPolicy = 'Auto'
    ExtraArguments = @('-NoUBTMakefiles')
    TimeoutMs = 3600000
}
```

Then run an ordinary incremental Harness build and the narrow replacement-test prefix. Inspect the returned managed operation's `Data.State` and `Data.ExitCode`, plus `UBT.log` or `Summary.json`; do not infer native success only from the outer Harness dispatch envelope.

For the current baseline, confirm retained old sources stay below an ignored `Legacy/` parent, the four tenant homes remain outside those parents, and generated JIT artifacts were not rewritten. The historical quarantine helper under the archived `refactor-legacy-runtime-tests-quarantine` Change still names `NewVersion/` and is not a current selector.
