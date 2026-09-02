---
state: superseded
reviewed_at: 2026-09-02T19:20:46+08:00
review_scope: Goal worktree lifecycle safety in .agents/skills/git-workflow/**
snapshot:
  parent_base: 4129487f63fab930800a896ae7f932d7bd4e6e70
  allowed_diff: .agents/skills/git-workflow/**
  diff_patch_id: e17a72291476df794a8b910693fef2000dcaf15b
---

# Workspace Safety Review

The review gate remains open. The normal exact-gitlink path, dirty-submodule preservation during bootstrap, and the finish boundary of no merge, push, or removal are present. However, one Critical and seven Required findings must be resolved or rejected with evidence before this gate can close.

## Verification Evidence

- `tests/Workspace.Tests.ps1`: PASS.
- PowerShell parser: PASS for all 9 `.ps1`, `.psm1`, and `.psd1` files in the allowed diff.
- `git diff --check -- .agents/skills/git-workflow`: PASS; only line-ending conversion warnings were emitted.
- Safe primary-checkout reproduction: `Complete-HardnessWorkspace -ProjectRoot D:\Workspace\AngelscriptProject -WhatIf` reported `Branch = main` and `WouldCommitParent = True`.
- Safe nested-root reproduction: invoking `NewWorktree.ps1 -Name nested-probe -DryRun` from the reviewed Goal worktree reported a repository root inside that Goal worktree and a nested `<goal>/.worktrees/nested-probe` target.

## Finding 1 — Finish Can Commit the Primary Checkout

```yaml
severity: Critical
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:388-393`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:440-443`
- `.agents/skills/git-workflow/scripts/FinishWorktree.ps1:3`
- `.agents/skills/git-workflow/scripts/FinishWorktree.ps1:12`

The finish primitive rejects only a detached parent. It does not require a linked worktree, a registered target under the primary checkout's `.worktrees/`, or a Goal branch. It then stages all visible parent changes with `git add -A` and commits them. The thin script defaults `ProjectRoot` to the checkout containing the installed script.

Reproduction:

1. Leave tracked or untracked changes in the primary checkout on `main`.
2. Invoke `FinishWorktree.ps1` without `ProjectRoot`, or call `Complete-HardnessWorkspace` with the primary checkout.
3. With `-WhatIf`, observe `Branch = main` and `WouldCommitParent = True`; without `-WhatIf`, the implementation reaches `git add -A` and `git commit` in the primary checkout.

Expected fix:

- Make Goal finish reject `IsWorktree == false` by default.
- Resolve the primary checkout and require the target to be a registered worktree in its canonical `.worktrees/` container.
- If Current-mode committing is required later, expose it as a separate explicit operation or opt-in; do not infer it from the Goal finish default.
- Add a regression test proving a dirty primary checkout is unchanged and finish refuses it.

## Finding 2 — Remove Silently Deletes Ignored Payloads

```yaml
severity: Required
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:126-130`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:477-485`
- `.agents/skills/git-workflow/tests/Workspace.Tests.ps1:76`
- `.agents/skills/git-workflow/tests/Workspace.Tests.ps1:83-89`
- `.agents/skills/git-workflow/tests/Workspace.Tests.ps1:121-122`

The clean gate is based on `git status --porcelain=v1 --untracked-files=all`, which omits ignored content. Removal then always calls `git worktree remove --force` because submodules were initialized. Ignored local configuration, build output, caches, secrets, or nested repositories can therefore be removed while the worktree is reported clean.

Reproduction:

1. Create a registered Goal worktree and put a file under an ignored path, such as `AgentConfig.ini` or an ignored cache directory.
2. Ensure tracked and ordinary untracked state is clean.
3. Invoke `Remove-HardnessWorkspace`.
4. The clean gate passes and forced removal deletes the ignored payload with the worktree. The current integration test already creates and copies ignored `AgentConfig.ini`, then removes the whole target without a preservation or explicit-destruction assertion.

Expected fix:

- Inventory ignored and untracked payloads before forced removal.
- Refuse non-allowlisted ignored data by default.
- Require explicit caller authorization for destructive cleanup and report the exact payload being discarded.
- Add tests for an ignored file, an ignored directory, and a nested ignored repository.

## Finding 3 — New Worktrees Nest Under the Calling Goal Worktree

```yaml
severity: Required
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:4-6`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:61-72`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:231-240`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:284-296`
- `.agents/skills/git-workflow/scripts/NewWorktree.ps1:17-18`

Repository discovery follows the checkout containing the installed module. Creation then places `.worktrees/` below that checkout. `Get-PrimaryWorkspaceRoot` exists but is not used to choose the creation or removal container.

Reproduction:

1. Run the reviewed copy of `NewWorktree.ps1 -Name nested-probe -DryRun` from the Goal worktree.
2. Observe `RepositoryRoot` equal to the Goal worktree itself.
3. Observe `WorktreeRoot` equal to `<goal-worktree>/.worktrees/nested-probe`, rather than `<primary-checkout>/.worktrees/nested-probe`.

Expected fix:

- Derive one canonical primary checkout from the common Git directory or registered-worktree metadata.
- Always place Goal worktrees under `<primary-checkout>/.worktrees/`.
- Permit an explicit start point from the current checkout without using that checkout as the physical container.
- Apply the same canonical-root rule to remove and add tests from both the primary checkout and an existing Goal worktree.

## Finding 4 — Finish Can Reuse or Mutate the Wrong Submodule Branch

```yaml
severity: Required
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:421-431`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:432-435`

If a dirty submodule is already on any named branch, finish commits directly to that branch, including `main`. If it is detached and the desired submodule branch already exists, finish checks out the existing ref without proving that the ref points at the exact starting gitlink or that another worktree does not own it.

Reproduction:

1. Let the parent require submodule commit `A`.
2. Create submodule branch `goal/x` at unrelated commit `B`.
3. In the Goal worktree, detach the submodule at `A` and make a non-conflicting change.
4. Finish with parent/submodule branch `goal/x`.
5. The implementation checks out the existing branch at `B`, carries the local change, and commits it on the wrong lineage. If another worktree owns that branch, finish instead fails after beginning the operation.

An alternate reproduction is to check out submodule `main`, make it dirty, and finish; the code commits directly to `main` because the branch is non-empty.

Expected fix:

- Require a dedicated Goal branch for every changed submodule.
- Accept an existing branch only when its ref equals the current expected HEAD and it is not checked out elsewhere.
- Otherwise refuse and request an explicit per-submodule branch mapping or recovery decision.
- Never silently commit a dirty Goal submodule to `main` or another pre-existing branch.
- Cover detached collision, checked-out collision, and already-on-`main` cases in tests.

## Finding 5 — Local Fallback Confuses Submodule Name and Path

```yaml
severity: Required
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:86-101`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:180-190`

The parser retains only each submodule path. Local object-store fallback constructs `.git/modules/<path>`, but Git keys that store by the `.gitmodules` section name, which may differ from the checkout path. The project's current five submodules happen to use equal names and paths, so the defect is latent in the current manifest.

Reproduction:

1. Define `[submodule "sdk"]` with `path = Vendor/SDK`.
2. Ensure normal update cannot fetch, while the required commit exists in `.git/modules/sdk`.
3. Run bootstrap.
4. Fallback looks for `.git/modules/Vendor/SDK` and incorrectly reports that no local object store exists.

Expected fix:

- Parse and preserve `{ Name, Path }` for every submodule.
- Resolve the module store from the logical name, preferably through Git's own path-resolution facilities.
- Add an offline fallback test where name and path differ and the exact required commit exists only in the local store.

## Finding 6 — `.gitmodules` Parse Failures Are Treated as No Submodules

```yaml
severity: Required
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:89-100`

Any non-zero result from `git config -f .gitmodules --get-regexp` returns an empty submodule list. This conflates a legitimate no-match result with malformed configuration, I/O failure, and other parse errors. Creation and verification can then skip all exact-gitlink gates.

Reproduction:

1. Use a committed malformed `.gitmodules` file that makes `git config -f .gitmodules ...` fail with a configuration error.
2. Run workspace status or verification.
3. `Get-WorkspaceSubmodulePaths` returns an empty array instead of surfacing the parse failure, so no submodule invariant is checked.

Expected fix:

- Treat only the documented no-match result as an empty list.
- Throw on syntax, I/O, and other Git failures with the original diagnostic.
- Add a malformed-manifest regression test.

## Finding 7 — `RequireClean` Can Accept Dirty Submodules

```yaml
severity: Required
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:355-364`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:373-376`

Explicit submodule dirtiness is always recorded as a warning. `RequireClean` creates an error only when the parent status is dirty. A superproject or local setting such as `submodule.<name>.ignore=dirty` can suppress the parent status entry while the explicit submodule scan still reports dirty, yielding `IsValid = True` under `RequireClean`.

Reproduction:

1. Configure `submodule.<name>.ignore=dirty` in the superproject.
2. Modify a file inside that initialized submodule.
3. Run `Test-HardnessWorkspace -RequireClean`.
4. The submodule appears in warnings, but no clean error is added if the parent status remains clean.

Expected fix:

- Under `RequireClean`, promote every dirty submodule to an error independently of the parent's status representation.
- Add a regression test with `ignore=dirty`.

## Finding 8 — Remove Uses Lexical Rather Than Physical Containment

```yaml
severity: Required
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:75-84`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:459-485`

Containment uses `GetFullPath` and string-prefix comparison. It does not detect a Windows junction or other reparse point whose physical target is outside the intended workspace container. Registration checks reduce accidental exposure but do not protect a registered path that is later replaced or redirected before forced removal.

Reproduction:

1. Register a worktree at a lexical path below the canonical `.worktrees/` directory.
2. Replace or redirect that path through a Windows reparse point before removal.
3. The lexical containment test still sees a child path and does not provide a physical-target or reparse-point rejection before force removal.

Expected fix:

- Refuse reparse-point worktree roots for destructive removal, or resolve the final physical target and validate containment again.
- Revalidate immediately before executing the destructive Git operation.
- Add a Windows-only junction safety test where supported.

## Finding 9 — “Every Submodule” Excludes Nested Submodules

```yaml
severity: Advisory
status: resolved
```

Files and lines:

- `.agents/skills/git-workflow/SKILL.md:16`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:142-153`

The documented invariant says every submodule is initialized at its exact parent gitlink. The implementation enumerates only the root `.gitmodules` and invokes non-recursive update. Nested submodules are not initialized, inspected, or included in clean/removal gates. No nested `.gitmodules` was found under the project's current five product submodules, so this is presently a contract and future-compatibility gap rather than a reproduced product failure.

Reproduction:

1. Add a submodule that itself contains a committed nested submodule.
2. Create or bootstrap a Goal worktree.
3. Observe that only the root submodule is initialized and verified; the nested gitlink is outside the reported state.

Expected fix:

- Either implement recursive exact-gitlink initialization, verification, dirty checks, and safe removal handling, or narrow the documented invariant explicitly to top-level product submodules.
- Add a nested fixture only if recursive support is part of the intended contract.

## Required Regression Coverage

Resolution of the findings above should add coverage for:

- primary/main finish refusal and dirty-main preservation;
- canonical creation from both the primary checkout and an existing Goal worktree;
- offline fallback with name/path divergence and missing exact objects;
- malformed `.gitmodules`;
- detached branch collisions and an already-named dirty submodule;
- `RequireClean` with `ignore=dirty`;
- ignored payload refusal during remove;
- unregistered, escaping, and Windows reparse targets;
- `WhatIf` zero mutation and bootstrap-failure recovery;
- invariant checks showing finish does not merge, push, or remove a worktree.

The existing passing integration test remains useful for the normal path, but it does not cover these safety gates.

## Coordinator resolution evidence

The coordinator reproduced the findings and kept this original review immutable above. The implementation and regression suite now contain the following candidate resolutions for independent re-review:

- Finding 1: `Complete-HardnessWorkspace` resolves the canonical primary checkout and rejects the primary checkout, detached/unregistered targets, paths outside the registered primary `.worktrees` container, and non-Goal branches before staging. The regression fixture calls finish against a dirty primary checkout (including `-WhatIf`) and proves that its branch, index, worktree list, and files remain unchanged.
- Finding 2: removal inventories tracked, ordinary untracked, ignored parent, and ignored submodule payloads. It refuses ignored content by default, returns the exact inventory, and requires the explicit `-DiscardIgnoredFiles` switch before destructive removal. Fixtures cover ignored `AgentConfig.ini`, ignored directories, and nested ignored repository payloads.
- Finding 3: create/remove canonicalize through the primary checkout. A request made from an existing Goal worktree still creates below the primary `.worktrees` container, while the caller's current commit remains the explicit start point.
- Finding 4: dirty submodules may be committed only on a dedicated Goal branch. Existing branch reuse requires the exact current commit, correct ancestry, and no other worktree owner; named `main`, wrong-lineage, detached-collision, and occupied-branch cases refuse before mutation.
- Finding 5: `.gitmodules` parsing preserves both logical `Name` and checkout `Path`; fallback resolves `.git/modules/<logical-name>`. The offline fixture uses `submodule.sdk.path = Vendor/SDK` and verifies exact-gitlink recovery from the logical-name object store.
- Finding 6: only Git's no-match exit is treated as an empty manifest. Malformed `.gitmodules`, I/O failures, and other parser errors propagate their diagnostics and block bootstrap/verification.
- Finding 7: `-RequireClean` promotes every explicitly dirty top-level submodule to an error independently of superproject ignore configuration. The regression fixture sets `submodule.sdk.ignore=dirty` and still refuses the dirty submodule.
- Finding 8: destructive removal rejects reparse-point worktree roots and revalidates canonical registration/containment immediately before removal. The Windows fixture covers a junction/reparse target without deleting its external payload.
- Finding 9: the user-facing invariant is now explicitly scoped to top-level project submodules; recursive nested-submodule support is not claimed by this version.

Verification rerun on 2026-09-02:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\git-workflow\tests\Workspace.Tests.ps1
PASS

pwsh.exe -NoProfile -File .agents/skills/git-workflow/tests/Workspace.Tests.ps1
PASS
```

The candidate workspace diff was `60a6615c0e63d2ec04c674146f13113b72d2c0f6` for tracked patch content at this checkpoint; the re-review snapshot must additionally bind all newly added workspace module, thin-entry, and test files before closing this review.

## Closure and Supersession

This initial snapshot is superseded by `review-20260902-workspace-safety-rereview.md` and the closed fixed-snapshot confirmation in `review-20260902-workspace-safety-final.md`. Findings 1–8 are resolved by the coordinator evidence above plus the final review's direct code inspection and PowerShell 5.1/7 regression evidence. Finding 9 is resolved by narrowing the published invariant to top-level project submodules; recursive nested-submodule support is not claimed. The final review binds 13 files at scope digest `a475eaa0d3158a1eb9d9fdef0ac374c70d0be69fcc83d5fd9a8cada0857af4a2` and reports no remaining Critical or Required finding.
