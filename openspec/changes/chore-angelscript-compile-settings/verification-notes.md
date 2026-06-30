# Verification Notes

## Worktree

- Created project-local worktree first at `.worktrees/chore-angelscript-compile-settings` through `Tools\Bootstrap\NewWorktree.ps1 -Name chore-angelscript-compile-settings -NoOpenSpec -NoPrewarm`.
- The project-local worktree hit Windows path length limits during UHT/generated wrapper compilation:
  - `Saved/Build/compile-settings-red/20260630_204205_949_c393d514/Build.log`
  - Failure: generated `AS_FunctionTable_AngelscriptRuntime_*.cpp` action paths reached 260 characters.
- Continued in short-path worktree `D:\ASCS` on branch `chore-as-compile-settings`.
- `Plugins/Angelscript` and `Plugins/AngelscriptGAS` submodules were initialized through the bootstrap local-object-store fallback; `Plugins/AngelscriptGameplayTags` initialized normally.

## RED

- Added `Plugins/Angelscript/Source/AngelscriptTest/Validation/AngelscriptCompileSettingsValidation.cpp` before implementation.
- Command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label compile-settings-red -TimeoutMs 180000 -NoXGE`
- Evidence:
  - `Saved/Build/compile-settings-red/20260630_204416_530_33b5b355/Build.log`
  - Expected compile failure observed: `#error WITH_ANGELSCRIPT_UNITTESTS must be defined by AngelscriptTest.Build.cs.`
  - The runner later timed out after the expected compile error because other actions were still draining; this is accepted as the RED signal for task 2.2.

## Disabled Build

- Checked-in config value: `Config/DefaultAngelscriptCompileOptions.ini` with `bCompileAngelscriptUnitTests=false`.
- Command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label compile-settings-disabled -TimeoutMs 1800000 -NoXGE`
- Result:
  - PASS, exit code 0.
  - Log: `Saved/Build/compile-settings-disabled/20260630_205124_983_ced1510c/Build.log`
- Disabled discovery command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label compile-settings-disabled-discovery -TimeoutMs 300000`
- Result:
  - Expected non-zero exit because no matching tests were registered.
  - Log: `Saved/Tests/compile-settings-disabled-discovery/20260630_205449_426_c335d255/Automation.log`
  - Evidence: `No automation tests matched '^Angelscript.TestModule.AngelScriptSDK'`.

## Enabled Build And Tests

- Temporarily changed `Config/DefaultAngelscriptCompileOptions.ini` to `bCompileAngelscriptUnitTests=true`.
- Command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label compile-settings-enabled -TimeoutMs 1800000 -NoXGE`
- Result:
  - PASS, exit code 0.
  - Log: `Saved/Build/compile-settings-enabled/20260630_205533_449_e9d04823/Build.log`
  - Evidence: `Invalidating makefile for AngelscriptProjectEditor (DefaultAngelscriptCompileOptions.ini modified)`.
- Test command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label compile-settings-enabled-sdk -TimeoutMs 600000`
- Result:
  - PASS, exit code 0.
  - Log: `Saved/Tests/compile-settings-enabled-sdk/20260630_205618_272_2ccf22d3/Automation.log`
  - Evidence: `Angelscript.TestModule.AngelScriptSDK.*` tests were discovered and executed successfully.

## Final State

- Restored `Config/DefaultAngelscriptCompileOptions.ini` to `bCompileAngelscriptUnitTests=false` for the checked-in consumer default.
- Final enabled build after `ForceIncludeFiles` command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label compile-settings-final-enabled -TimeoutMs 1800000 -NoXGE`
- Final enabled build after `ForceIncludeFiles` result:
  - PASS, exit code 0.
  - Log: `Saved/Build/compile-settings-final-enabled/20260630_211021_558_96a68a9f/Build.log`
  - Evidence: `Invalidating makefile for AngelscriptProjectEditor (DefaultAngelscriptCompileOptions.ini modified)`.
- Final enabled SDK test command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label compile-settings-final-enabled-sdk -TimeoutMs 600000`
- Final enabled SDK test result:
  - PASS, exit code 0.
  - Log: `Saved/Tests/compile-settings-final-enabled-sdk/20260630_211117_001_5642470d/Automation.log`
  - Summary: `Saved/Tests/compile-settings-final-enabled-sdk/20260630_211117_001_5642470d/Summary.json`
  - Evidence: `Total=421`, `Passed=421`, `Failed=0`, `Skipped=0`.
- Final checked-in-default build command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label compile-settings-final-disabled -TimeoutMs 1800000 -NoXGE`
- Final checked-in-default build result:
  - PASS, exit code 0.
  - Log: `Saved/Build/compile-settings-final-disabled/20260630_210224_694_0d772cc5/Build.log`
- Final checked-in-default disabled discovery command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label compile-settings-final-disabled-discovery -TimeoutMs 300000`
- Final checked-in-default disabled discovery result:
  - Expected non-zero exit because no matching tests were registered.
  - Log: `Saved/Tests/compile-settings-final-disabled-discovery/20260630_210644_144_a4285353/Automation.log`
  - Evidence: `No automation tests matched '^Angelscript.TestModule.AngelScriptSDK'`.
- Final restored checked-in-default build command:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label compile-settings-final-restored-disabled -TimeoutMs 1800000 -NoXGE`
- Final restored checked-in-default build result:
  - PASS, exit code 0.
  - Log: `Saved/Build/compile-settings-final-restored-disabled/20260630_211317_801_909bf47e/Build.log`
  - Evidence: `Invalidating makefile for AngelscriptProjectEditor (DefaultAngelscriptCompileOptions.ini modified)`.
