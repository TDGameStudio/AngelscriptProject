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
