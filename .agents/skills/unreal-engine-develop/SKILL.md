---
name: unreal-engine-develop
description: Use when building Unreal Editor/Game targets, running UE Automation, invoking RunBuild/RunTests/RunTestSuite/RunCommandlet, listing registered Unreal Engine installations, choosing test suites (Smoke, All, NativeCore, Standalone), or diagnosing UBT processes.
---

# Unreal Engine Develop

UE build, test, and commandlet runners for this project. Do not call `Build.bat`, `dotnet UnrealBuildTool.dll`, or `UnrealEditor-Cmd.exe` directly.

**Announce at start:** "I'm using the unreal-engine-develop skill for build/test."

These `scripts/` files are copies of `Tools\` runners, with repo-root resolution patched for this skill path. `Tools\` still has the originals. If you edit one copy, sync the other until ownership is fully moved.

## Which script

| Task | Script |
|------|--------|
| Editor/Game UBT build | `scripts/RunBuild.ps1` |
| One prefix or automation group | `scripts/RunTests.ps1` |
| Named suite (serial) | `scripts/RunTestSuite.ps1` |
| Full suite, fast (~5–8 min) | `scripts/RunTestSuiteFast.ps1` |
| Full suite, parallel | `scripts/RunTestSuiteParallel.ps1` |
| Commandlet | `scripts/RunCommandlet.ps1` |
| List UBT processes | `scripts/Get-UbtProcess.ps1` |
| List registered engine installations (JSON) | `scripts/Get-EngineInstallations.ps1` |
| Internal parallel entry | `scripts/RunTestSuiteEntry.ps1` (do not call by hand) |

Shared helpers live in `scripts/Shared/`. Do not invoke them directly.

Not copied here (still run from `Tools\`): `RunPackage.ps1`, `RunAngelscriptJIT.ps1`, `RunStaticJITTests.ps1`, Cache/JIT package smokes, Coverage wrappers, `RunStandaloneExternalSmoke.ps1`. Do not use `Tools\RunAutomationTests.ps1`.

## Prerequisites

Need a Hardness-managed `AgentConfig.ini` at the selected workspace root (`Paths.EngineRoot`, workspace-owned `Paths.ProjectFile`, `Build.*`, `Test.DefaultTimeoutMs`). If missing or stale:

```powershell
Import-Module ./.agents/skills/hardness/scripts/Hardness.psd1
$context = New-HardnessContext                         # discover from the current directory
# $context = New-HardnessContext -WorkspaceRoot D:\work\my-linked-workspace
Invoke-Hardness -Command workspace.bootstrap -Context $context
Invoke-Hardness -Command workspace.activate -Context $context
```

Build and test entry points verify the managed workspace identity and the active PowerShell-session selection before resolving UE paths. Work selected for one registered worktree therefore cannot accidentally target the primary checkout. Codex `/goal` continuation does not change the selected workspace.

Every command must pass an explicit timeout. Build max `3600000`; test max `900000` unless a dedicated long runner (package/cache) says otherwise.

## Commands

From the repository root:

```powershell
# Build (concurrent worktrees: default -NoMutex -NoEngineChanges)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunBuild.ps1 -Label agent-build -TimeoutMs 180000

# Disable XGE / write shared engine output
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunBuild.ps1 -Label agent-build -TimeoutMs 180000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunBuild.ps1 -Label engine-write -TimeoutMs 180000 -SerializeByEngine

# Game target / configuration override
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunBuild.ps1 -Target AngelscriptProject -Configuration Shipping -Label game-shipping -TimeoutMs 1800000 -NoXGE

# One test prefix / group
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTests.ps1 -Group AngelscriptSmoke -Label smoke -TimeoutMs 600000

# Named suites
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTestSuite.ps1 -ListSuites
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTestSuite.ps1 -Suite Smoke -LabelPrefix smoke -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTestSuite.ps1 -Suite NativeCore -LabelPrefix native-core -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTestSuite.ps1 -Suite Standalone -LabelPrefix standalone -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTestSuite.ps1 -Suite StandaloneRelease -TimeoutMs 1200000

# Fast / parallel All
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTestSuiteFast.ps1 -LabelPrefix all-fast -TimeoutMs 900000 -ContinueOnFail
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunTestSuiteParallel.ps1 -Suite All -Strategy CoarseDynamic -TimeoutMs 3600000 -ContinueOnFail

# Commandlet / UBT process list
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\RunCommandlet.ps1 -Commandlet AngelscriptBlueprintImpactScan -Label blueprint-impact-scan -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\Get-UbtProcess.ps1 -CurrentWorktreeOnly

# Registered engine roots on this machine (JSON on stdout)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\unreal-engine-develop\scripts\Get-EngineInstallations.ps1 -Pretty
```

## Rules

- Default tests add `-NullRHI`. Add `-Render` only when GPU is required.
- Crash-only tests (`Angelscript.CrashOnly.*`) must run alone. `RunTests.ps1` rejects a wide `Angelscript` prefix that would include them.
- Standalone CTest counts (`19/19`) are not additive with UE Automation / NativeCore / catalogued C++ numbers.
- `StandaloneRelease` is the Release ZIP gate; it is not part of `All`.
- Output is per-run: `Saved/Build/<Label>/<RunId>/` and `Saved/Tests/<Label>/<RunId>/`. Do not share log files across worktrees.
- `Get-EngineInstallations.ps1` prints JSON only on stdout. Parse that object; do not scrape registry yourself. `identifier` is the `.uproject` `EngineAssociation` value (`5.8` or `{GUID}`).

## Suites

`RunTestSuite.ps1 -ListSuites` is authoritative. Current names: `Smoke`, `NativeCore`, `Standalone`, `StandaloneRelease`, `RuntimeCpp`, `Bindings`, `HotReload`, `Cache`, `CachePackage`, `Debugger`, `FunctionalSamples`, `All`.

Guides: `Documents/Guides/Build.md`, `Documents/Guides/Test.md`.
