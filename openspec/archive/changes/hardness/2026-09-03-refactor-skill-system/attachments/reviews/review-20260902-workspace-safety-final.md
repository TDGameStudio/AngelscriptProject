---
state: closed
reviewed_at: 2026-09-02T21:25:31.6752525+08:00
review_scope: .agents/skills/git-workflow/**
snapshot:
  parent_base: 4129487f63fab930800a896ae7f932d7bd4e6e70
  scope_tree_sha256: a475eaa0d3158a1eb9d9fdef0ac374c70d0be69fcc83d5fd9a8cada0857af4a2
  scope_file_count: 13
  workspace_module_sha256: e4fb10ccc84c1c5864513e71a60a8d8e7078a3b56f9caeef775d0735bb77c4d4
  safety_tests_sha256: eddff93ac58f046928c923800e7f4d50d5c16948604f87799df4c15975cd6208
  workspace_tests_sha256: 078751cab4662e6a02690090cd56e0c7bb09002ae7913be83ea4df38ac7c620b
verdict: APPROVE
---

# Workspace Safety Final Review

The fixed snapshot closes all four findings from `review-20260902-workspace-safety-rereview.md`. No Critical or Required workspace-safety finding remains open in this scope. The Workspace safety gate is approved; this scoped verdict does not by itself approve the rest of the Hardness change or authorize integration.

## Fixed-snapshot Evidence

- The reviewed scope contains 13 files. Its deterministic path-plus-file-hash digest is `a475eaa0d3158a1eb9d9fdef0ac374c70d0be69fcc83d5fd9a8cada0857af4a2`; the principal module and both test-file digests are recorded in the front matter.
- Windows PowerShell `5.1.26100.8875`: `.agents/skills/git-workflow/tests/Workspace.Tests.ps1` PASS, including all seven safety regressions.
- PowerShell `7.6.0`: `.agents/skills/git-workflow/tests/Workspace.Tests.ps1` PASS, including all seven safety regressions.
- `Test-ModuleManifest` passed in both PowerShell hosts for `Workspace.psd1` and its declared PowerShell 5.1 compatibility.
- `git diff --check -- .agents/skills/git-workflow` exited successfully. Git emitted only working-copy LF/CRLF conversion warnings.
- Static inspection found the production `git worktree remove --force` only after the physical-path, registration, strict workspace-state, and ignored-data gates. The bootstrap cleanup removes only an already-proven empty, non-reparse directory after initialization failure.

## Finding 1 — Physical and Reparse Containment

```yaml
severity: Critical
status: resolved
dimensions: [correctness, security]
```

`Assert-WorkspacePathChainSafe` now validates lexical containment and walks every existing component from the canonical primary root through the target, rejecting any reparse point (`Workspace.psm1:97-135`). Creation runs this guard before any mutation and again after creating `.worktrees` but before `git worktree add` (`Workspace.psm1:538-562`). Removal runs it before state inspection and immediately before `git worktree remove --force` (`Workspace.psm1:772-812`).

The Windows regressions cover both previously demonstrated bypasses (`Workspace.Safety.Tests.ps1:168-215`): a pre-existing `.worktrees` junction cannot receive a new worktree, and a post-registration junction swap cannot reach removal. The latter fixture additionally proves that a sentinel payload in the external physical target survives the refused operation.

## Finding 2 — Dirty Submodule Inspection Before Checkout

```yaml
severity: Required
status: resolved
dimensions: [correctness, security]
```

Bootstrap now identifies an existing expected submodule repository, captures its current HEAD, and enumerates tracked and untracked changes before invoking `git submodule update` (`Workspace.psm1:321-355`). A dirty checkout at a non-required HEAD is rejected before any checkout; an exact dirty checkout is retained without running update. A non-repository directory with payload is also rejected rather than treated as an initialization target.

The tracked and untracked regressions (`Workspace.Safety.Tests.ps1:218-267`) place the submodule at commit B while the parent requires A, then verify after refusal that HEAD is still B and that the relevant file bytes are unchanged. These assertions close the ordering defect rather than merely checking for an error message.

## Finding 3 — Strict Initialized, Exact, and Clean Removal

```yaml
severity: Required
status: resolved
dimensions: [correctness, security]
```

Repository detection now requires the candidate's canonical `--show-toplevel` to equal the candidate directory (`Workspace.psm1:207-219`). Submodule detection additionally requires the checkout's common Git directory to equal one of the expected parent-owned submodule stores (`Workspace.psm1:288-303`). Status therefore distinguishes a real initialized checkout from an ordinary directory beneath a gitlink and records local payload for the latter (`Workspace.psm1:479-514`).

Strict verification rejects every uninitialized or non-exact submodule and promotes direct submodule dirtiness to an error (`Workspace.psm1:596-631`). Removal requires that strict result before it considers ignored data or invokes Git (`Workspace.psm1:788-812`). This remains effective even when the superproject uses `submodule.<name>.ignore=all`, because HEAD and dirty state are inspected directly in each submodule checkout.

The regressions prove that a clean submodule at the wrong HEAD is refused despite `ignore=all`, and that a deinitialized gitlink path containing a local-only payload is refused and preserved (`Workspace.Safety.Tests.ps1:269-315`).

## Finding 4 — Logical-name and Object-store Containment

```yaml
severity: Required
status: resolved
dimensions: [security, correctness]
```

Logical submodule names now reject rooted paths, drive/ADS syntax, empty segments, `.` and `..`, invalid filename characters, and non-portable trailing characters while retaining legitimate nested names (`Workspace.psm1:137-159`). `.gitmodules` parsing applies that validation immediately (`Workspace.psm1:161-190`). The derived store path must remain below `<git-dir>/modules`, and its existing path chain must contain no reparse point (`Workspace.psm1:253-267`). Fallback revalidates the store before `cat-file` and again before `git worktree add` (`Workspace.psm1:383-397`).

The malicious-name regression proves that `../../../../outside-store` is rejected without modifying an external binary sentinel. It also proves that a nested name cannot traverse a junction under `modules`, while a legitimate nested logical name such as `vendor/sdk` remains inside the store root (`Workspace.Safety.Tests.ps1:317-352`).

## Decision

**APPROVE.** Findings 1 through 4 are resolved on the fixed snapshot above, the regressions pass in both supported PowerShell hosts, and no additional Critical or Required issue was found within the reviewed Workspace safety boundary.
