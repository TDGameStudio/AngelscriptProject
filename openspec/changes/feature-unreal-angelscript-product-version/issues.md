# Implementation Issues

## TOOL-001: Initial build wait detached while build continued

- **Observed:** The first `RunBuild.ps1` shell wrapper had a five-second tool wait limit and returned code 124 while its child PowerShell/UBT process continued normally. A second invocation was correctly rejected by the repository worktree mutex.
- **Diagnosis:** This was an orchestration wait timeout, not a UBT timeout, compiler error, or source failure. Process inspection showed the original `RunBuild.ps1` and `dotnet UnrealBuildTool` command still running with the expected isolated log.
- **Resolution:** No process was killed and no duplicate build was forced. The original build was monitored through its run directory until it completed successfully.
- **Evidence:** `Saved/Build/unreal-angelscript-version/20260730_013430_085_6bee0761/` reports `Result: Succeeded`, 94/94 actions, and 101.61 seconds.

## Source and runtime findings

- No compiler error was caused by the version implementation.
- No focused, NativeCore, or full-suite test failed.
- No crash, timeout, missing report, skipped/not-run case, or residual UnrealEditor/CrashReportClient process was observed.
- Build warnings came from pre-existing fixture calling-convention casts, constructor initialization order, and deprecated widget-slot field access outside this change.
