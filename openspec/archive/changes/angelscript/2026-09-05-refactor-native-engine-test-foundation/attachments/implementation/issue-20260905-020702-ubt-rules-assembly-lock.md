---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-020702-ubt-rules-assembly-lock
status: rejected
source: dogfooding
source_ref: run-acb2038e5eb345f38f12949d7c3540ee
affected_tasks: ["1.1"]
created_at: 2026-09-05T02:07:02+08:00
resolved_at: 2026-09-05T02:21:22+08:00
resolution_ref: run-96b26c7ff9944f7bb37faf222ddc3ee2
---

# Transient UBT rules-assembly lock after a terminal Harness build

## Symptom

The first build after editing `AngelscriptTest.Build.cs` failed before C++ compilation because UnrealBuildTool could not access `Intermediate/Build/BuildRules/AngelscriptProjectModuleRules.dll`; Windows reported that another process was using the file.

## Investigation Log

1. Harness build `99c5bff430e146f78ace045bfe653697` reached the expected CQTest include RED and was recorded terminal `Failed`.
2. After the minimal Build.cs correction, Harness build `acb2038e5eb345f38f12949d7c3540ee` failed while invalidating the makefile and recompiling project rules.
3. `ue.run.status` reported both builds terminal. `ue.process.list` and a bounded `Win32_Process` query found no live UBT, dotnet, AutomationTool, or matching-workspace Editor process.
4. Repeating the exact `Auto` build once advanced through project-rules compilation and reached C++ compilation, where it exposed an unrelated local test syntax error. After that syntax correction, the same build parameters succeeded as run `7f8a14e018154327b370bde6d943c47d`.

## Root Cause

The holder of the rules assembly was not observable after the failure, so the root cause is not yet demonstrated. Current evidence is consistent with a transient file-handle release race around UBT project-rules recompilation, but does not prove whether the holder was the preceding managed worker, UBT itself, or an external process not present by the time of inspection.

## Disposition

Reject a Harness implementation change for this observation. Six later editor-build attempts progressed past project-rules compilation, including three final successful builds, and no live holder was attributable to Harness. The transient observation remains preserved; a recurrence must capture the holder before a new root-cause claim or repair is opened.

## Evidence

### Failure Evidence (RED)

- Exact command: `Invoke-Harness -Command ue.build` for `AngelscriptProjectEditor Win64 Development` with `BuildConcurrency = Auto` and `ConcurrencyPolicy = Auto`.
- Run: `acb2038e5eb345f38f12949d7c3540ee`.
- Artifact: `Saved/Harness/Unreal/Runs/acb2038e5eb345f38f12949d7c3540ee/UBT.log`.
- First bad boundary: UBT project-rules assembly access, before C++ compilation.

### Resolution Evidence (GREEN)

No root-cause repair has been made. The exact build parameters subsequently passed in run `7f8a14e018154327b370bde6d943c47d`; this only proves the lock was transient for that attempt.

### Rejected Evidence

- The unrelated Editor process belonged to `D:\Workspace\SigilProject` and did not match this workspace.
- The following build's C++ syntax failure proves CQTest dependency resolution progressed after the lock cleared; it does not explain the lock.
- Later managed builds `241e160fc05242788c7bf27cc7c6ddca`, `7f8a14e018154327b370bde6d943c47d`, `7741ac5d1eaf4c53bf5a9321b862fd0b`, `cbc47db8a21b4884a1a089b2b04ac350`, `0a29f74c0b2a4add94ec82e7b0757d15`, `97311c1159154e8ba64cd91cbd5ef6ae`, and `96b26c7ff9944f7bb37faf222ddc3ee2` all progressed through the same project-rules boundary without another assembly lock.
- Because no reproducible Harness-owned cause was demonstrated, changing lane policy, retry behavior, or cache handling would be speculative.

### What This Proves

- Harness retained terminal records and private logs for both failures.
- A terminal failed build can be followed immediately by a project-rules DLL access failure even when no matching process is visible afterward.

### What This Does Not Prove

- It does not prove a Harness lease defect, a UBT defect, or interference from the other-project Editor.
- It does not justify disabling UBA/XGE, changing the accepted `Auto` verification contract, deleting intermediates, or silently retrying future recurrences.

## Links

- Task `1.1` in `tasks.md`.
- `.agents/skills/unreal-engine-develop/references/concurrency.md`.
- `.agents/skills/openspec/references/implementation-issues.md`.
