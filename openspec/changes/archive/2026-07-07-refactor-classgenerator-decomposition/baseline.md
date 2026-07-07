# ClassGenerator Decomposition Baseline

Captured before moving `AngelscriptClassGenerator.cpp` phase units.

| Scope | Command | Result | Report |
|---|---|---:|---|
| `ClassGenerator` | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator" -Label baseline-classgenerator -Fast -TimeoutMs 1800000` | `48/48 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\baseline-classgenerator\20260703_121401_416_86cd0210\Report\index.json` |
| `HotReload` | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload" -Label baseline-hotreload -Fast -TimeoutMs 1800000` | `122/122 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\baseline-hotreload\20260703_121750_674_3810287c\Report\index.json` |
| `Inheritance+Interface+Component+Actor+Delegate+GC` | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.Inheritance+Angelscript.TestModule.Interface+Angelscript.TestModule.Component+Angelscript.TestModule.Actor+Angelscript.TestModule.Delegate+Angelscript.TestModule.GC" -Label baseline-functional-classgen-related -Fast -TimeoutMs 1800000` | `108/108 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\baseline-functional-classgen-related\20260703_122020_153_59a57128\Report\index.json` |

Notes:
- `Angelscript.TestModule.HotReload.NativeScript.FAngelscriptNativeScriptHotReloadTests.Phase2A` and `Phase2B` are present in the `HotReload` report.
- Baseline has no known failures in the scoped runs above.

## Characterization added before phase split

| Scope | Command | Result | Report |
|---|---|---:|---|
| `ReloadPlanning.InterfaceList+Analyze.NameConflict` | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ReloadPlanning.InterfaceList+Angelscript.TestModule.ClassGenerator.Analyze.NameConflict" -Label classgen-characterization-front -Fast -TimeoutMs 1800000` | `PASS` | recorded by `classgen-characterization-front` run |
| `ReloadPlanning.Propagation` | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ReloadPlanning.Propagation" -Label classgen-reload-propagation -Fast -TimeoutMs 1800000` | `PASS` | recorded by `classgen-reload-propagation` run |
| `ASFunction.ArgumentMatrix` compile | `./Tools/RunBuild.ps1 -Label classgen-asfunction-argument-matrix-compile8 -NoXGE -TimeoutMs 1800000` | `PASS` | `D:\Workspace\AngelscriptProject\Saved\Build\classgen-asfunction-argument-matrix-compile8\20260703_134031_256_6fe4e50b\RunMetadata.json` |
| `ASFunction.ArgumentMatrix` | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ASFunction.ArgumentMatrix" -Label classgen-asfunction-argument-matrix7 -Fast -TimeoutMs 1800000` | `1/1 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-asfunction-argument-matrix7\20260703_134053_696_aa0cdd6b\Report\index.json` |
| `VerifyClass` compile | `./Tools/RunBuild.ps1 -Label classgen-characterization-verifyclass-fix8 -NoXGE -TimeoutMs 1800000` | `PASS` | `D:\Workspace\AngelscriptProject\Saved\Build\classgen-characterization-verifyclass-fix8\20260703_155533_916_e73fa844\RunMetadata.json` |
| `Component` / `VerifyClass` | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.Component" -Label classgen-characterization-verifyclass-fix8 -Fast -TimeoutMs 1800000` | `10/10 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-characterization-verifyclass-fix8\20260703_155557_844_a9f72eae\Report\index.json` |
| Combined characterization | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ReloadPlanning.InterfaceList+Angelscript.TestModule.ClassGenerator.Analyze.NameConflict+Angelscript.TestModule.ClassGenerator.ReloadPlanning.Propagation+Angelscript.TestModule.ClassGenerator.ASFunction.ArgumentMatrix+Angelscript.TestModule.ClassGenerator.Component" -Label classgen-characterization-combined -Fast -TimeoutMs 1800000` | `28/28 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-characterization-combined\20260703_155702_255_18c14856\Report\index.json` |

## Post phase-split validation

| Scope | Command | Result | Report |
|---|---|---:|---|
| Build | `./Tools/RunBuild.ps1 -Label classgen-phase-split-fix1 -NoXGE -TimeoutMs 1800000` | `PASS` | `D:\Workspace\AngelscriptProject\Saved\Build\classgen-phase-split-fix1\20260703_163722_372_c1ecd163\RunMetadata.json` |
| Combined characterization | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator.ReloadPlanning.InterfaceList+Angelscript.TestModule.ClassGenerator.Analyze.NameConflict+Angelscript.TestModule.ClassGenerator.ReloadPlanning.Propagation+Angelscript.TestModule.ClassGenerator.ASFunction.ArgumentMatrix+Angelscript.TestModule.ClassGenerator.Component" -Label classgen-phase-split-characterization -Fast -TimeoutMs 1800000` | `28/28 PASS` | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-phase-split-characterization\20260703_163852_373_e5511eb1\Report\index.json` |
| Affected themes | `./Tools/RunTests.ps1 -TestPrefix "Angelscript.TestModule.ClassGenerator+Angelscript.TestModule.HotReload+Angelscript.TestModule.Inheritance+Angelscript.TestModule.Interface+Angelscript.TestModule.Component+Angelscript.TestModule.Actor+Angelscript.TestModule.Delegate+Angelscript.TestModule.GC" -Label classgen-phase-split-affected -Fast -TimeoutMs 1800000` | `304/304 PASS` (`299` success + `5` success-with-warnings, `0` failed) | `D:\Workspace\AngelscriptProject\Saved\Tests\classgen-phase-split-affected\20260703_164141_467_0e9882fa\Report\index.json` |

Characterization notes:
- Ordinary generated `float32` parameters/returns classify as four-byte VM behavior; ordinary `float64` classifies as eight-byte VM behavior.
- Native `AActor.ReceiveTick(float DeltaSeconds)` override classifies the parameter as `FloatExtendedToDouble`; runtime verification uses spawned actor tick dispatch rather than direct `ReceiveTick` `ProcessEvent`.
- `VerifyClass` editor-only parent/root diagnostics are observable as error diagnostics on a handled helper compile path; tests pin the diagnostic and reflected class/property shape rather than requiring `bCompiled == false`.
- A `Dev.*` helper module name does not prove the developer-only bypass in this test harness; current behavior is characterized as diagnostic-producing until a real published script-module path proves `UASClass::IsDeveloperOnly()` true.