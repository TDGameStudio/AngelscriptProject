# Worktree build failure: UBT MAX_PATH (260)

Date: 2026-08-21  
Worktree: `D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`  
Branch: `refactor-as-canonical-typed-ast-compiler`  
This is an environment / path-length failure. It is not a C++ compile error, not a missing file, and not an engine-source problem.

## Command that failed

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File "D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler\Tools\RunBuild.ps1" `
    -Label worktree-verify-canonical-typed-ast `
    -TimeoutMs 1800000
```

Resolved by `AgentConfig.ini`:

| Key | Value |
| --- | --- |
| Target | `AngelscriptProjectEditor` |
| Platform | Win64 |
| Configuration | Development |
| EngineRoot | `C:\Program Files\Epic Games\UE_5.8` |
| ProjectFile | `D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler\AngelscriptProject.uproject` |

Logs:

- `Saved\Build\worktree-verify-canonical-typed-ast\20260821_001102_975_234738f7\Build.log`
- `Saved\Build\worktree-verify-canonical-typed-ast\20260821_001102_975_234738f7\UBT.log`

Exit:

- ProcessExitCode: `6`
- FinalExitCode: `1`
- UBT Result: `Failed (OtherCompilationError)`
- Duration: `15.08s`

`OtherCompilationError` is a UBT bucket name. No `cl.exe` / `error Cxxxx` occurred.

## What succeeded before the failure

UBT got far enough to prove the worktree, engine, and plugin were loadable:

1. Resolved the worktree `.uproject`.
2. Created a makefile (`no existing makefile`).
3. Built `AngelscriptUHTTool.ubtplugin.csproj` (`0` errors).
4. Ran Internal UnrealHeaderTool with `-WarningsAsErrors`.
5. AngelscriptUHTTool analyzed `5812` functions and wrote `11` generated binding files.
6. UHT finished in `7.68s` and wrote `203` generated files.

Failure happened **after** UHT, while preparing the compile ActionGraph.

## Exact failure

UBT message (repeated, then thrown as `BuildException`):

```text
The following action paths are longer than 260 characters. Please move the engine to a directory with a shorter path.
```

Call site from the log:

```text
at UnrealBuildTool.ActionGraph.CheckPathLengths(...)
    Engine\Source\Programs\UnrealBuildTool\Actions\ActionGraph.cs:line 374
at UnrealBuildTool.BuildMode.BuildAsync(...)
    Engine\Source\Programs\UnrealBuildTool\Modes\BuildMode.cs:line 480
```

The hint to “move the engine” is misleading. `EngineRoot` is the installed UE 5.8 tree and was not over the limit. Every listed path is under the **project/worktree**, not under `C:\Program Files\Epic Games\UE_5.8`.

Windows legacy `MAX_PATH` is 260 characters. UBT refuses any compile/link action whose absolute path is longer than 260 before it launches `cl.exe`.

## Paths that exceeded 260

Worktree prefix (84 characters):

```text
D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler
```

Main checkout prefix (35 characters):

```text
D:\Workspace\AngelscriptProject
```

The worktree prefix is 49 characters longer than main. That extra prefix is what pushed already-long generated and test paths over 260.

| Chars | Path |
| ---: | --- |
| 277 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_AngelscriptRuntime_Aggregator.cpp` |
| 275 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_NavigationSystem_Aggregator.cpp` |
| 273 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_EngineSettings_Aggregator.cpp` |
| 272 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_AssetRegistry_Aggregator.cpp` |
| 272 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_EnhancedInput_Aggregator.cpp` |
| 268 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_Landscape_Aggregator.cpp` |
| 268 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_UMGEditor_Aggregator.cpp` |
| 267 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_AIModule_Aggregator.cpp` |
| 267 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_UnrealEd_Aggregator.cpp` |
| 265 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_Engine_Aggregator.cpp` |
| 262 | `...\Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\AS_FunctionBinding_UMG_Aggregator.cpp` |
| 261 | `...\Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK\Compiler\TypedSemanticIR\SourceProvenance\AngelscriptNativeTypedSemanticIRGeneratedSourceProvenanceIntegrationTests.cpp` |

Two families:

1. **UHT-generated function-binding aggregators** under  
   `Plugins\Angelscript\Intermediate\Build\Win64\x64\UnrealEditor\Development\AngelscriptRuntime\Gen\AngelscriptGeneratedFunctionBindingWrappers\`.  
   These names are structurally long (`AS_FunctionBinding_<Module>_Aggregator.cpp`) and already sit behind a deep Intermediate path. They are the majority of the overflow.
2. **One authored test source** with a deep Native SDK folder plus a long filename:  
   `AngelscriptNativeTypedSemanticIRGeneratedSourceProvenanceIntegrationTests.cpp` (261).  
   This file exists in main too; it only exceeds 260 once the worktree prefix is added.

No listed path is an engine path.

## Why main builds and this worktree did not

Main `ProjectFile` is:

```text
D:\Workspace\AngelscriptProject\AngelscriptProject.uproject
```

The same aggregator file under main is about `277 - 49 = 228` characters, under 260. The worktree used `git worktree add .worktrees/<change-name>`, which is the documented default, but the change name `refactor-as-canonical-typed-ast-compiler` plus `.worktrees\` is enough to break UBT’s 260 check.

This is the same class of problem already handled by `D:\as-lns` → `.worktrees\improve-as-library-namespace-canonicalization`.

## Mitigation recorded here

Do **not** move the engine. Do **not** rename generated aggregators just to pass this setup build.

1. Create a short directory junction (no admin required on Windows):

   ```bat
   mklink /J D:\as-cta D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler
   ```

2. Point **this worktree only** `AgentConfig.ini` at the short path:

   ```ini
   [Paths]
   EngineRoot=C:\Program Files\Epic Games\UE_5.8
   ProjectFile=D:\as-cta\AngelscriptProject.uproject
   LLVMRoot=D:\LLVM\clang+llvm-22.1.8-x86_64-pc-windows-msvc
   ```

   Keep `EngineRoot` / `LLVMRoot` identical to main. Only `ProjectFile` changes.

3. Invoke the runner through the short path so UBT and logs also use `D:\as-cta`:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass `
       -File "D:\as-cta\Tools\RunBuild.ps1" `
       -Label worktree-verify-canonical-typed-ast-short `
       -TimeoutMs 3600000
   ```

Expected length after the junction: longest aggregator `277 - 84 + 9 = 202` characters.

## Evidence the 260 check was the only first-run blocker

Retry with `ProjectFile=D:\as-cta\AngelscriptProject.uproject` passed `CheckPathLengths` and completed the editor target:

- Command: `D:\as-cta\Tools\RunBuild.ps1 -Label worktree-verify-canonical-typed-ast-short -TimeoutMs 3600000`
- ProjectFile: `D:\as-cta\AngelscriptProject.uproject`
- Log: `D:\as-cta\Saved\Build\worktree-verify-canonical-typed-ast-short\20260821_001442_205_c76febb5\`
- UHT: `197` generated files written
- XGE: `231` actions, `Rebuild All: 1 succeeded, 0 failed, 0 skipped`
- Result: `Succeeded`
- ProcessExitCode: `0`
- Duration: `369.53s` (XGE `356.66s`)
- Output binary: `C:\Program Files\Epic Games\UE_5.8\Engine\Binaries\Win64\UnrealEditor.exe`

The first run aborted before `cl.exe`. The short-path retry compiled and linked the worktree editor target. Remaining warnings (C4996 overlay-slot access, C4191 JIT function-pointer casts, CS8632 nullable annotations in `AngelscriptRuntime.Build.cs`) are pre-existing and did not fail the build.

## What not to “fix”

- Do not treat this as a typed-AST / canonical-compiler source bug.
- Do not delete or shorten `AS_FunctionBinding_*_Aggregator.cpp` names for this incident.
- Do not enable `-UniqueBuildEnvironment`.
- Do not change main workspace `AgentConfig.ini` or its dirty files.
- Do not assume Windows long-path policy will save UBT; UBT enforces 260 in `ActionGraph.CheckPathLengths` regardless of the OS long-path setting.

## Follow-up for later worktrees

If `Tools\RunBuild.ps1` dies in ~15s with `action paths are longer than 260 characters` after a successful UHT:

1. Count the worktree root length.
2. Junction it to `D:\as-<short>`.
3. Set that worktree `AgentConfig.ini` `Paths.ProjectFile` to the junction `.uproject`.
4. Rebuild through the junction `Tools\RunBuild.ps1`.
