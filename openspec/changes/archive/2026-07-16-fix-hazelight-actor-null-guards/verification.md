## Verification

- Red test after rebuilding the test module:
  - Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Actor.Mixin" -Label hazelight-actor-null-guards-red-fixed-test -TimeoutMs 600000`
  - Result: `5` total, `4` passed, `1` failed.
  - Failure: `GetAttachedActorsOfClassNullGuards` reported that a null class did not return an empty array.
- Build after the runtime guard and native null-actor regression were added:
  - Command: `Tools\RunBuild.ps1 -ExtraArgs -NoHotReloadFromIDE -TimeoutMs 1800000`
  - Result: succeeded; `AngelscriptRuntime` and `AngelscriptTest` rebuilt successfully.
- Green focused regression run:
  - Command: `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Actor.Mixin" -Label hazelight-actor-null-guards-green -TimeoutMs 600000`
  - Result: `5` total, `5` passed, `0` failed, `0` skipped.
