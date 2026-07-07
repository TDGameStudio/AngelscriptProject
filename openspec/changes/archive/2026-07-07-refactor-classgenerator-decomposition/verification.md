# ClassGenerator Decomposition Verification

## Pre-split characterization checkpoint

| Check | Command | Result | Artifact |
|---|---|---:|---|
| Whitespace | `git -C "D:\Workspace\AngelscriptProject\Plugins\Angelscript" diff --check -- Source/AngelscriptTest/Shared/AngelscriptNativeScriptTestObject.h Source/AngelscriptTest/ClassGenerator/AngelscriptComponentMetadataValidationTests.cpp` | `PASS` | terminal output |
| Build | `./Tools/RunBuild.ps1 -Label classgen-characterization-verifyclass-fix8 -NoXGE -TimeoutMs 1800000` | `PASS` | `D:\Workspace\AngelscriptProject\Saved\Build\classgen-characterization-verifyclass-fix8\20260703_155533_916_e73fa844\RunMetadata.json` |
| VerifyClass narrow tests | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.Component" -Label classgen-characterization-verifyclass-fix8 -Fast -TimeoutMs 1800000` | `10/10 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-characterization-verifyclass-fix8\20260703_155557_844_a9f72eae\Report\index.json` |
| Combined characterization | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ReloadPlanning.InterfaceList+Angelscript.TestModule.ClassGenerator.Analyze.NameConflict+Angelscript.TestModule.ClassGenerator.ReloadPlanning.Propagation+Angelscript.TestModule.ClassGenerator.ASFunction.ArgumentMatrix+Angelscript.TestModule.ClassGenerator.Component" -Label classgen-characterization-combined -Fast -TimeoutMs 1800000` | `28/28 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-characterization-combined\20260703_155702_255_18c14856\Report\index.json` |
| OpenSpec strict validation | `openspec validate "refactor-classgenerator-decomposition" --strict --json` | `PASS` | `valid=true`, `issues=[]` |

Notes:
- This checkpoint gates the first `.cpp` phase movement; it is not the final post-split verification.
- `VerifyClass` editor-only parent/root and `Dev.*` helper-module cases intentionally assert diagnostics and reflected output, not private generator state.

## Post-split verification

| Check | Command | Result | Artifact |
|---|---|---:|---|
| ClassGenerator diff whitespace | `git -C "D:\Workspace\AngelscriptProject\Plugins\Angelscript" diff --check -- Source/AngelscriptRuntime/ClassGenerator Source/AngelscriptTest/ClassGenerator Source/AngelscriptTest/Shared` | `PASS` | terminal output |
| Build | `./Tools/RunBuild.ps1 -Label classgen-phase-split-fix1 -NoXGE -TimeoutMs 1800000` | `PASS` | `D:\Workspace\AngelscriptProject\Saved\Build\classgen-phase-split-fix1\20260703_163722_372_c1ecd163\RunMetadata.json` |
| Combined characterization | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ReloadPlanning.InterfaceList+Angelscript.TestModule.ClassGenerator.Analyze.NameConflict+Angelscript.TestModule.ClassGenerator.ReloadPlanning.Propagation+Angelscript.TestModule.ClassGenerator.ASFunction.ArgumentMatrix+Angelscript.TestModule.ClassGenerator.Component" -Label classgen-phase-split-characterization -Fast -TimeoutMs 1800000` | `28/28 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-phase-split-characterization\20260703_163852_373_e5511eb1\Report\index.json` |
| Affected themes | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator+Angelscript.TestModule.HotReload+Angelscript.TestModule.Inheritance+Angelscript.TestModule.Interface+Angelscript.TestModule.Component+Angelscript.TestModule.Actor+Angelscript.TestModule.Delegate+Angelscript.TestModule.GC" -Label classgen-phase-split-affected -Fast -TimeoutMs 1800000` | `304/304 PASS` (`299` success + `5` success-with-warnings, `0` failed) | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-phase-split-affected\20260703_164141_467_0e9882fa\Report\index.json` |
| OpenSpec strict validation | `openspec validate "refactor-classgenerator-decomposition" --strict --json` | `PASS` | `valid=true`, `issues=[]` |

Notes:
- The first-stage implementation is a member-definition relocation split: `AngelscriptClassGenerator.h` remains the only `FAngelscriptClassGenerator` declaration source.
- `AngelscriptClassGeneratorShared.h` owns shared constants and `GetBlueprintEventByScriptName` only; it does not become a private declaration header.
- `ASClass` / `UASFunction` / explicit `UASFunction_*` UHT-facing declaration movement is deferred to a follow-up change.
- `CreateDebugValuePrototype`, exact live-instance destructor counting, and remaining direct positive ASClass component/namespaced-UCLASS coverage stay tracked as follow-up coverage because adding production seams would exceed this behavior-preserving `.cpp` split.
