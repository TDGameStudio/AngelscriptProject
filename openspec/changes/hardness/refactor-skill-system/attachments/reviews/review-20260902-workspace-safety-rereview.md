---
state: superseded
reviewed_at: 2026-09-02T20:57:33.0537065+08:00
review_scope: .agents/skills/git-workflow/** and the Workspace route boundary in .agents/skills/hardness/scripts/Hardness.psm1
snapshot:
  parent_base: 4129487f63fab930800a896ae7f932d7bd4e6e70
  scope_tree_sha256: f44c3aec45ffaacd25d1001568120d7ca83db69bac377f4d2243d866ed848bce
  scope_file_count: 13
verdict: SUPERSEDED
---

# Workspace Safety Re-review

The gate remains open. The reviewed snapshot fixes the primary-checkout finish defect, ordinary dirty-submodule verification, malformed `.gitmodules` handling, normal logical-name/path storage, and the common wrong-branch cases. However, one Critical and three Required findings remain. The current implementation must not be approved for destructive Goal-worktree lifecycle use yet.

## Verification Evidence

- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\git-workflow\tests\Workspace.Tests.ps1`: PASS.
- `pwsh.exe -NoProfile -File .agents/skills/git-workflow/tests/Workspace.Tests.ps1`: PASS.
- `Hardness.Tests.ps1`: PASS in Windows PowerShell 5.1 and PowerShell 7.6.0, including Goal-route leaf selection.
- Parser and module-manifest validation: PASS in both hosts for all 10 PowerShell files in the reviewed workspace boundary.
- `git diff --check -- .agents/skills/git-workflow/** .agents/skills/hardness/scripts/Hardness.psm1`: PASS; only Git line-ending warnings were emitted.
- Static command scan found no `merge` or `push` operation in the implementation. `git worktree remove --force` exists only in the explicit remove primitive; finish itself does not merge, push, or remove.
- The existing fixture independently confirms that finish refuses the primary checkout even under `-WhatIf`, `-RequireClean` rejects a dirty submodule hidden by `submodule.<name>.ignore=dirty`, malformed `.gitmodules` is fatal, and a dirty submodule on an unrelated named branch is not committed.

The passing fixture covers the normal path, but it does not exercise the destructive and physical-path cases below.

## Finding 1 — Reparse Ancestors Bypass the Canonical Container and Remove Gate

```yaml
severity: Critical
status: resolved
dimensions: [correctness, security]
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:75-83`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:356-378`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:589-628`

Containment is still lexical. Removal rejects only when the worktree root itself has the `ReparsePoint` attribute; it does not reject or physically resolve a reparse-point ancestor such as `.worktrees`.

Two independent temporary-repository reproductions demonstrate both sides of the defect:

1. With `.worktrees` created as a junction to a sibling external directory, `New-HardnessWorkspace` succeeded and physically created `external-container/escaped-physical`. Git registered the physical external path, after which `workspace.finish` refused it as outside the canonical container. Creation therefore escaped the promised boundary and returned a workspace that the lifecycle could not manage.
2. A normal registered `.worktrees/swapped` worktree was moved to a sibling external directory, then `.worktrees` was replaced by a junction to that directory. The target root itself was not a reparse point, Git still reported the registered lexical path, and `Remove-HardnessWorkspace -WhatIf` accepted the operation:

```text
ContainerIsReparse=True
TargetRootIsReparse=False
MovedPhysicalExists=True
Registered=.../repo/.worktrees/swapped
RemoveWhatIfAccepted=True
```

Without `-WhatIf`, the accepted path reaches `git worktree remove --force`, which can recursively remove the physical target outside the canonical container. This contradicts the documented reparse and canonical-containment guarantee.

Required resolution:

- Reject a reparse point anywhere in the physical chain from the primary checkout through `.worktrees` to the target, or resolve final physical paths and validate containment against a non-reparse canonical container.
- Apply the same physical check before creation and immediately before destructive removal, not only once near the start of remove.
- Add Windows fixtures for a pre-existing junction container and a post-registration junction swap. The latter must prove that the external payload survives a refused removal.

## Finding 2 — Bootstrap Moves a Dirty Submodule Before Inspecting It

```yaml
severity: Required
status: resolved
dimensions: [correctness, security]
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:172-198`

`Initialize-WorkspaceSubmodules` invokes `git submodule update --init --checkout` before it reads the current submodule HEAD or dirty state. The dirty guard at lines 190-198 runs only after that command fails. Git is allowed to switch commits while preserving a non-conflicting local modification, so the command can move a dirty checkout without throwing.

The isolated reproduction started with parent gitlink `A`, checked the submodule out at newer commit `B`, modified a tracked file unchanged between the commits, and called `Initialize-HardnessWorkspace`. The result was:

```text
Expected=A
Before=B
After=A
Dirty=" M stable.txt"
Threw=False
```

The local content happened to survive, but the dirty checkout was silently moved from `B` to `A`. This violates the explicit invariant that bootstrap never moves a dirty submodule and can change the context in which unfinished work is interpreted.

Required resolution:

- Before any `submodule update` or checkout, inspect an existing exact submodule repository, record its HEAD, and refuse to move it whenever tracked or untracked content is dirty.
- Keep the no-data partial-directory fallback separate from the existing-repository path.
- Add regressions for both a non-conflicting tracked modification and an untracked file at a non-required HEAD; HEAD and content must remain byte-for-byte unchanged after refusal.

## Finding 3 — Remove Accepts Non-exact or Effectively Uninitialized Submodules

```yaml
severity: Required
status: resolved
dimensions: [correctness, security]
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:131-137`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:301-322`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:606-628`

The remove gate checks parent/submodule dirtiness but never requires every configured submodule to be initialized and at its exact parent gitlink. There are two distinct failures:

1. With an initialized, clean submodule detached at `B` while the parent records `A`, setting `submodule.sdk.ignore=all` hid the parent gitlink change. Status correctly recorded `SubExact=False`, but `Remove-HardnessWorkspace -WhatIf` still accepted removal:

```text
ParentDirty=False
SubExact=False
SubDirty=False
RemoveWhatIfAccepted=True
```

2. `Test-WorkspaceGitRepository` only asks `git rev-parse --is-inside-work-tree`. Git walks upward, so an ordinary directory at a deinitialized submodule path is incorrectly treated as the parent repository. A local-only payload placed under that gitlink path was invisible to both parent dirty and ignored scans. Status reported the path as initialized, and remove again accepted without `-DiscardIgnoredFiles`:

```text
ParentDirty=False
ParentIgnored=[]
PayloadExists=True
RemoveWhatIfAccepted=True
```

The subsequent forced worktree removal would delete that unreported payload. This means the original ignored-payload finding is not fully resolved.

Required resolution:

- Make repository detection prove that the candidate's canonical `--show-toplevel` equals the candidate path and that it is the expected submodule checkout, rather than accepting upward discovery of the parent repository.
- Make remove require every declared top-level submodule to be initialized, exact, and clean. Reuse the strict workspace verification result or enforce the same invariants directly.
- When a configured gitlink path is not an initialized submodule, inspect the physical directory before removal and refuse any payload by default; do not rely on superproject `git status` to enumerate files below a gitlink.
- Add regressions for `ignore=all` plus a clean wrong HEAD, and for a deinitialized submodule path containing a local file or nested repository. Both must be refused and preserved.

## Finding 4 — Logical Submodule Names Can Escape the Object-store Root

```yaml
severity: Required
status: resolved
dimensions: [security, correctness]
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:102-113`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:162-169`
- `.agents/skills/git-workflow/scripts/Workspace.psm1:212-220`

Preserving the logical submodule name separately from its checkout path fixes the normal name/path mismatch, but the name is interpolated into `.git/modules/<name>` without a containment check. Git accepts a manually authored section such as `[submodule "../../../../outside-store"]`. The reviewed code parsed it and resolved its fallback store to:

```text
Name=../../../../outside-store
Store=C:\Users\scottmei\AppData\Local\outside-store
Escapes=True
```

If normal update fails and that external path is a Git directory containing the required commit, fallback proceeds to `cat-file` and `git worktree add` against storage outside the repository's common Git directory. Repository metadata must not be allowed to redirect a recovery operation to an arbitrary local Git store.

Required resolution:

- Canonicalize the derived module-store path and require it to remain under `<git-common-dir>/modules/` before probing or mutating it.
- Reject absolute names, `.`/`..` traversal, and reparse escapes while retaining legitimate nested logical names where Git supports them.
- Add a malicious logical-name fixture proving no path outside the module-store root is read or modified.

## Positive Results Retained

- Primary checkout finish refusal is now enforced before staging, including `-WhatIf`.
- Goal creation requested from an existing linked worktree resolves the primary checkout as the lexical container.
- Normal `.gitmodules` parsing retains both logical name and checkout path; malformed configuration is no longer treated as an empty manifest.
- `-RequireClean` independently promotes explicit submodule dirtiness to an error.
- Dirty submodules on unrelated named branches and existing dedicated branches at different commits are refused before commit.
- Finish commits submodules before the parent, leaves the worktree registered, and contains no merge, push, or removal path.
- PowerShell 5.1 and PowerShell 7 execute the current normal-path fixture and Hardness Workspace routing successfully.

## Decision

**REQUEST CHANGES.** Keep this review `open`. A new fixed snapshot must resolve the Critical physical-containment issue and all three Required findings, add the missing regressions, rerun both PowerShell hosts, and receive another independent review before the workspace safety gate can close.

## Coordinator Resolution and Supersession

The requested fixed snapshot was produced and independently reviewed in `review-20260902-workspace-safety-final.md`. That review closes all four findings with direct implementation references and seven regression fixtures: pre-existing and swapped junction containment, tracked and untracked dirty-submodule preservation, `ignore=all` wrong-HEAD refusal, deinitialized-payload refusal, and logical-name/object-store escape refusal. `Workspace.Tests.ps1` passed on Windows PowerShell 5.1 and PowerShell 7.6.0. The reviewed 13-file scope remained stable at SHA-256 `a475eaa0d3158a1eb9d9fdef0ac374c70d0be69fcc83d5fd9a8cada0857af4a2`; the final verdict is APPROVE with no Critical or Required finding remaining. This earlier REQUEST_CHANGES snapshot is therefore superseded, while its original evidence remains preserved above.
