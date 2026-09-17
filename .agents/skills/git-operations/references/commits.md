# Scoped Commits

## Inspect

```powershell
Invoke-Harness -Command git.status -Context $context
```

The result reports parent and initialized top-level submodule heads, branches, and staged/unstaged/untracked paths.

- In a registered replica, status exposes only editable plugin repositories. The project root and fixed snapshots have no Git commit target.
- Queue closure uses exact plugin scopes with `PluginsOnly = $true` and `PreserveOutsideStaged = $true`. This also applies in primary: plugin commits do not automatically commit parent gitlinks. Primary-repository commits remain separately user-directed.

```powershell
Invoke-Harness git.commit -Context $context -Parameters @{
    RepositoryScopes = @{'Plugins/Angelscript'=@('Source/ExactOwnedFile.cpp')}
    PluginsOnly = $true
    PreserveOutsideStaged = $true
    CommitMessage = '[Angelscript] Fix exact verified behavior'
}
```

## Commit Exact Paths

```powershell
Invoke-Harness -Command git.commit -Context $context -Parameters @{
  RepositoryScopes = @{
    '.' = @(
      '.agents/skills/workspace-lifecycle'
      '.agents/skills/git-operations'
    )
  }
  CommitMessage = '[Harness] Refactor: split workspace and Git operations'
}
```

Map `.` to parent-repository paths and a top-level submodule path to paths relative to that submodule. `WorkspaceRoot` comes from the selected context. An omitted scope and any pre-staged path outside the selected scope are rejected. Exact commits always build a candidate index from the current HEAD, stage only literal effective scopes, run the repository's normal `pre-commit`, `prepare-commit-msg`, and `commit-msg` hooks against that candidate, and validate it before the ref is accepted.

## Preserve Existing Staged Work Outside the Scope

The default rejection remains the safest choice. When a primary or linked workspace intentionally contains independently staged work, opt into an explicit outside-index preservation proof:

```powershell
Invoke-Harness -Command git.commit -Context $context -Parameters @{
  RepositoryScopes = @{
    '.' = @(
      '.agents/skills/unreal-engine-develop'
      'openspec/archive/changes/harness/2026-09-03-integrate-unreal-development'
    )
  }
  PreserveOutsideStaged = $true
  CommitMessage = '[Harness] Feat: integrate workspace-safe Unreal development routes'
  WhatIf = $true
}
```

Inspect `IncludedChanges` and `PreservedStaged`, then repeat without `WhatIf`. All exact scoped commits already use an isolated path-only candidate. Preservation mode additionally compares a stable SHA-256 snapshot of each repository's outside staged paths, index metadata, and binary patch before and after the commit. Preview records use `Validation = 'Pending'`; only an executed and verified commit reports `Validation = 'Preserved'`.

`PreserveOutsideStaged` requires exact `RepositoryScopes` and cannot be combined with `AllChanges`. It fails before mutation for unmerged index entries, outside intent-to-add entries, or a true staged rename crossing the scope boundary. A target-only addition remains valid when Git reports it as copied from an unchanged out-of-scope tracked path; copy similarity does not mutate or authorize that source. A hook that adds any unsafe state or actual outside mutation to the candidate is rejected before acceptance. If a hook or commit fails, or a postcondition detects expansion, Harness restores that affected repository's ref with compare-and-swap and restores the exact pre-attempt live index. Dirty scoped submodules still commit before the parent; if a later repository fails, successful earlier commits are reported as resumable partial work and are not rolled back.

Hook quarantine protects repository refs and indexes. Hooks can still modify worktree bytes, launch processes, use the network, or write outside the repository. Harness reports such residual effects and never overwrites them under a generic rollback claim. A scope-local formatter staged by `pre-commit` and a message edit made by `commit-msg` remain valid candidate output; `post-commit` runs with the isolated index after the ref and live scoped entries are updated.

## Commit an Entire Linked Worktree

Use exact scopes when possible. `AllChanges` is available only for an exact Git-registered linked worktree and remains explicit. Preview it first so every included non-ignored path is visible:

```powershell
Invoke-Harness -Command git.commit -Context $linked -Parameters @{
  AllChanges = $true
  CommitMessage = '[Harness] Refactor: complete workspace changes'
  TargetBranches = @{
    'Plugins/Angelscript' = 'refactor-workspace-git-operations'
  }
  WhatIf = $true
}
```

Repeat without `WhatIf` only after checking `IncludedChanges`. Dirty submodules commit first. The parent then commits its selected paths plus the resulting gitlinks. Attached repositories use their actual branches without any required prefix; a detached dirty repository needs an explicit `TargetBranches` entry. The result reports Git facts only; verification, Review, and closure remain separate gates.
