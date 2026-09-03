# Scoped Commits

## Inspect

```powershell
Invoke-Hardness -Command git.status -Context $context
```

The result reports parent and initialized top-level submodule heads, branches, and staged/unstaged/untracked paths.

## Commit Exact Paths

```powershell
Invoke-Hardness -Command git.commit -Context $context -Parameters @{
  RepositoryScopes = @{
    '.' = @(
      '.agents/skills/workspace-lifecycle'
      '.agents/skills/git-operations'
    )
  }
  CommitMessage = '[Hardness] Refactor: split workspace and Git operations'
}
```

Map `.` to parent-repository paths and a top-level submodule path to paths relative to that submodule. `WorkspaceRoot` comes from the selected context. An omitted scope and any pre-staged path outside the selected scope are rejected.

## Preserve Existing Staged Work Outside the Scope

The default rejection remains the safest choice. When a primary or linked workspace intentionally contains independently staged work, opt into path-only commit semantics explicitly:

```powershell
Invoke-Hardness -Command git.commit -Context $context -Parameters @{
  RepositoryScopes = @{
    '.' = @(
      '.agents/skills/unreal-engine-develop'
      'openspec/archive/changes/hardness/2026-09-03-integrate-unreal-development'
    )
  }
  PreserveOutsideStaged = $true
  CommitMessage = '[Hardness] Feat: integrate workspace-safe Unreal development routes'
  WhatIf = $true
}
```

Inspect `IncludedChanges` and `PreservedStaged`, then repeat without `WhatIf`. Preservation mode performs a literal path-only dry run and commit, verifies that the resulting commit contains only the effective scopes, and compares a stable SHA-256 snapshot of each repository's outside staged paths, index metadata, and binary patch before and after the commit. Preview records use `Validation = 'Pending'`; only an executed and verified commit reports `Validation = 'Preserved'`.

`PreserveOutsideStaged` requires exact `RepositoryScopes` and cannot be combined with `AllChanges`. It fails before mutation for unmerged index entries, outside intent-to-add entries, or a staged rename/copy crossing the scope boundary. Dirty scoped submodules still commit before the parent; the parent path-only commit includes only its explicit paths and the resulting gitlinks. If a later repository fails, successful earlier commits are reported as partial work and are not rolled back.

## Commit an Entire Linked Worktree

Use exact scopes when possible. `AllChanges` is available only for an exact Git-registered linked worktree and remains explicit. Preview it first so every included non-ignored path is visible:

```powershell
Invoke-Hardness -Command git.commit -Context $linked -Parameters @{
  AllChanges = $true
  CommitMessage = '[Hardness] Refactor: complete workspace changes'
  TargetBranches = @{
    'Plugins/Angelscript' = 'refactor-workspace-git-operations'
  }
  WhatIf = $true
}
```

Repeat without `WhatIf` only after checking `IncludedChanges`. Dirty submodules commit first. The parent then commits its selected paths plus the resulting gitlinks. Attached repositories use their actual branches without any required prefix; a detached dirty repository needs an explicit `TargetBranches` entry. The result reports Git facts only; verification, Review, and closure remain separate gates.
