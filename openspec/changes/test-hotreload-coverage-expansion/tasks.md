## 1. Records

- [x] 1.1 Record the HotReload coverage expansion scope
- [x] 1.2 Record the test coverage requirements

## 2. Tests

- [x] 2.1 Add HotReload change classification coverage
- [x] 2.2 Add a Blueprint-child soft reload regression
- [x] 2.3 Preserve the existing EditAnywhere Blueprint-child regression
- [x] 2.4 Add a dedicated HotReload sequence test folder
- [x] 2.5 Add multi-step soft reload coverage for a running Blueprint child actor
- [x] 2.6 Add structural full reload Blueprint recovery coverage

## 3. Verification

- [x] 3.1 Run the focused change classification prefix
  - `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ChangeClassification" -Label hotreload-change-classification-merge-final -TimeoutMs 600000`
  - Report: `Saved\Tests\hotreload-change-classification-merge-final\20260626_162739_359_a96a2cd9\Report\index.json`
  - Result: `22` succeeded, `0` failed, `0` skipped.
- [x] 3.2 Run the focused Blueprint-child prefix
  - `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.BlueprintChild" -Label hotreload-blueprint-child -TimeoutMs 600000`
  - Report: `Saved\Tests\hotreload-blueprint-child\20260625_101103_895_ada41170\Report\index.json`
  - Result: `2` succeeded, `0` warnings, `0` failed, `0` not run.
- [x] 3.3 Run the focused HotReload sequence prefix
  - `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.Sequence" -Label hotreload-sequence -TimeoutMs 600000`
  - Report: `Saved\Tests\hotreload-sequence\20260625_100858_845_8614473b\Report\index.json`
  - Result: `2` succeeded, `0` warnings, `0` failed, `0` not run.

## 4. Resolved Blocker

- [x] 4.1 `UnrealEditor-AngelscriptTest.dll` lock cleared.
- [x] 4.2 Rebuilt after lock removal with `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000`.
  - Report: `Saved\Build\build\20260625_100832_482_0dd79fd0\RunMetadata.json`
  - Result: `ExitCode=0`; `AngelscriptHotReloadSequenceTests.cpp` compiled and `UnrealEditor-AngelscriptTest.dll` linked.
- [x] 4.3 Earlier non-unity/link notes are superseded by the successful focused build above.
- [x] 4.4 `Angelscript.TestModule.HotReload.Sequence` is now discovered and passing: `2` succeeded, `0` failed.
