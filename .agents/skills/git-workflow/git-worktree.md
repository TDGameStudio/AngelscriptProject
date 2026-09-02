# Git Worktree (AngelscriptProject)

## When to create a worktree

Only when the user explicitly asks for an isolated workspace. The project default is
working in the current workspace/main checkout — never create a worktree proactively.

Worktrees always live at `.worktrees/<change-name>` under the repository root. Do not
use sibling directories or user-global locations.

## Scripts owned by this skill

| Script | Purpose |
|--------|---------|
| `scripts/NewWorktree.ps1` | One-shot: parent worktree + submodule init/fallback + `AgentConfig.ini` + OpenSpec skeleton |
| `scripts/BootstrapWorktree.ps1` | Re-initialize an *existing* worktree (AgentConfig.ini, submodules, TargetInfo prewarm) |
| `scripts/BootstrapWorktree.bat` | cmd wrapper for `BootstrapWorktree.ps1` |

The scripts dot-source `Tools\Shared\UnrealCommandUtils.ps1` via relative paths and
resolve the repository root as four levels up. They must stay at
`.agents\skills\git-workflow\scripts\`; moving them breaks path resolution.

## One-shot creation (run from the main workspace root)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File .agents\skills\git-workflow\scripts\NewWorktree.ps1 -Name <change-name>
```

`<change-name>` becomes the worktree directory (`.worktrees/<change-name>`), the parent
branch name, and the OpenSpec change directory (`openspec/changes/<change-name>/`).

Common switches: `-DryRun`, `-NoOpenSpec`, `-NoPrewarm`, `-EngineRoot <path>`,
`-Verify`, `-Force`.

## Re-bootstrap an existing worktree

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
    -File .agents\skills\git-workflow\scripts\BootstrapWorktree.ps1 `
    -EngineRoot "<EngineRoot>" -NoPrewarm
```

A fresh worktree has no `AgentConfig.ini`, so pass `-EngineRoot` explicitly (read it
from the main workspace's `AgentConfig.ini`). Use `-AllRegisteredWorktrees` to
normalize every registered worktree at once.

## When something fails

If submodule init fails (typically `fatal: reference is not a tree` because the parent
repo records a submodule commit that is not on the remote), the worktree is left in
place for manual recovery. Follow strategies A/B/C and the troubleshooting table in
`Documents/Guides/SubmoduleWorktreeWorkflow.md` — that guide remains the authoritative
manual workflow.
