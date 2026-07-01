# Build Session Notes - 2026-06-26

## Implemented in This Session

- `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp`
  - Added an editor-module helper that requests `GEditor->BroadcastClassPackageLoadedOrUnloaded()`.
  - Called it from `FAngelscriptEditorModule::StartupModule()` when the Angelscript engine is already initialized and initial compile has finished.
- `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.h`
  - Added automation-test hooks for the ClassViewer refresh request.
- `Plugins/Angelscript/Source/AngelscriptEditor/Tests/AngelscriptEditorModuleLifecycleTests.cpp`
  - Added `StartupRefreshesClassViewerAfterInitialCompile` to cover the late editor-module startup case.
- C4996 cleanup in editor tests:
  - Replaced `REN_ForceNoResetLoaders` with `REN_AllowPackageLinkerMismatch` in temporary test asset cleanup paths, matching UE 5.8 guidance.

## Verification Completed

- `ReadLints` on edited source/test files: no new diagnostics.
- `git diff --check` on edited files: no whitespace errors.
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.Module" -TimeoutMs 300000`
  - Result from the already-built binary: `12/12 passed`.
  - Important limitation: this run did not include the newly added `StartupRefreshesClassViewerAfterInitialCompile` test because a fresh build had not completed yet.

## Build Blockers Observed

### Live Coding

An initial standard build failed before compilation:

```text
Unable to build while Live Coding is active.
```

Action needed: close the editor or disable Live Coding before a clean verification build.

### Concurrent Builds in the Same Worktree

Later build attempts overlapped with other UBT/MSBuild/Rider builds in the same worktree. Evidence from logs:

- `Saved/Build/rename-flag-warning/.../UBT.log` deleted the outdated `UnrealEditor-AngelscriptEditor.lib` before relinking it.
- Another IDE/MSBuild build tried to consume the same intermediate library at the same time and hit:

```text
LNK1181: cannot open input file
D:/Workspace/AngelscriptProject/Plugins/Angelscript/Intermediate/Build/Win64/x64/UnrealEditor/Development/AngelscriptEditor/UnrealEditor-AngelscriptEditor.lib
```

Root cause: multiple UBT processes writing the same `Plugins/Angelscript/Intermediate/Build/...` tree concurrently.

### UBA / XGE

The default UBT path used Unreal Build Accelerator:

```text
Using Unreal Build Accelerator local executor
UbaServer - Listening on 0.0.0.0:1345
```

To disable UBA for this worktree, the local file was updated:

```xml
Saved/UnrealBuildTool/BuildConfiguration.xml
<BuildConfiguration>
	<bAllowUBAExecutor>false</bAllowUBAExecutor>
</BuildConfiguration>
```

The stale project XML config cache was also deleted:

```text
Intermediate/Build/XmlConfigCache.bin
```

This only affects local build behavior and is not part of the plugin source change.

### Current Residual Build State at Stop Point

At the time this note was written, a user/IDE-initiated build was still active:

```text
dotnet ... UnrealBuildTool.dll AngelscriptProjectEditor ... -FromMsBuild
xgConsole.exe ... Unreal BuildTool Compile
cl.exe ... Module.AngelscriptRuntime.2.cpp.obj.rsp
cl.exe ... Module.AngelscriptRuntime.3.cpp.obj.rsp
```

Do not start another build until these processes exit or are explicitly stopped by the user.

## Next Verification Command

After all editor/build worker processes are gone, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label no-uba-classviewer-refresh -TimeoutMs 600000
```

Expected build log checks:

- It should not print `Using Unreal Build Accelerator local executor`.
- It should not print `UbaServer - Listening`.
- It should compile the new editor module lifecycle test.
- After the build succeeds, rerun:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.Module" -TimeoutMs 300000
```
