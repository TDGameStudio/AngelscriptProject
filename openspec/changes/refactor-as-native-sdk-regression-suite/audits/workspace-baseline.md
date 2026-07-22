# Workspace Baseline

This record freezes the workspace facts observed during the final OpenSpec review on 2026-07-23. It is a coordination baseline, not permission to reset, overwrite, stage, or commit any listed path. Implementation MUST capture a fresh baseline before its first write because the user-owned worktree can continue changing.

## Repository identity

- Parent repository: `D:/Workspace/AngelscriptProject`
- Parent branch: `main`
- Parent HEAD at review: `8cd338f94ea58da9d63e06d2a70d1554f6812b62`
- Editing location: the current checkout; no secondary worktree is authorized for this change.
- Plugin delivery repository: `Plugins/Angelscript`
- Plugin branch: `main`
- Plugin HEAD at review: `b90357171d2ac2f973e58f87179a2910366d6de4`
- Plugin HEAD subject: `[Automation] Fix: stabilize automation suite execution`

## Corrected builder ownership

`ThirdParty/angelscript/source/as_builder.cpp` is clean at this baseline. Its enum-description cleanup fix is already committed in plugin commit `b903571`; it is no longer an uncommitted edit owned by another active change.

This change SHALL:

- retain an executable regression for the post-build enum-description cleanup;
- treat the production implementation at `b903571` as baseline behavior;
- avoid reapplying, reverting, or taking ownership of the production fix;
- modify the production source only if a newly reproduced, causally separate defect is proven and the OpenSpec is updated first.

## Parent worktree overlap

The parent worktree already contains user changes outside this OpenSpec. The implementation-relevant overlapping paths observed at review include:

- `AGENTS.md`
- `AGENTS_ZH.md`
- `Config/DefaultEngine.ini`
- `Documents/Guides/TechnicalDebtInventory.md`
- `Documents/Guides/TestCatalog.md`
- `Documents/UnitTest/UnitTest.md`
- the `Plugins/Angelscript` gitlink/worktree marker

Many other unrelated modified, deleted, and untracked paths also exist. They remain user-owned and out of scope. Whole-file replacement is forbidden for overlapping tracked files; patches MUST be hunk-scoped after inspecting the current diff.

## Plugin worktree overlap

The plugin worktree had the following user-owned modifications at review:

- `Source/AngelscriptTest/Coverage/AngelscriptCoverageInputTests.cpp`
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageLoopTests.cpp`
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageUStructTests.cpp`
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageWidgetTests.cpp`
- `Source/AngelscriptTest/Debugger/AngelscriptDebuggerDatabaseTests.cpp`
- `Source/AngelscriptTest/StaticJIT/AOT/AngelscriptStaticJITAotGeneration.cpp`

The Coverage files are evidence for behavioral depth but are not implementation targets of this change. The Debugger overlap must be inspected before moving the SDK debugger-value and reification tests. The StaticJIT overlap is not owned by this change.

## Fresh-baseline gate

Immediately before implementation, record the output of:

```powershell
git rev-parse HEAD
git status --short
git diff --name-only
git -C Plugins/Angelscript rev-parse HEAD
git -C Plugins/Angelscript status --short
git -C Plugins/Angelscript diff --name-only
```

For every path that overlaps this change, inspect its actual diff before editing. At each phase checkpoint, compare the new diff to that fresh baseline and prove that no pre-existing hunk was removed or rewritten.

## Implementation-start observation

The fresh baseline was captured immediately before the first implementation write on 2026-07-23.

- Parent HEAD remained `8cd338f94ea58da9d63e06d2a70d1554f6812b62`.
- Plugin HEAD remained `b90357171d2ac2f973e58f87179a2910366d6de4`.
- The six user-owned plugin changes listed above remained present and were not edited.
- The first change-owned plugin paths are limited to the fourteen approved ThirdParty headers and the SDK Atomic, Thread, StringUtil, native smoke, support, adapter, execution-helper, and SDK type tests. No Coverage, Debugger, StaticJIT, Build.cs, project configuration, or `as_builder.cpp` path was written by this change.
- The parent OpenSpec directory remains untracked as a whole; only this change directory is modified by the implementation record.
