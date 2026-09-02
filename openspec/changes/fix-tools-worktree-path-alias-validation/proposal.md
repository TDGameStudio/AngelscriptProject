# Proposal

## Why

`Tools\RunTests.ps1` / `RunBuild.ps1` / `RunTestSuite.ps1` refuse to start in most worktrees, with:

```
AgentConfig.ini [Paths] ProjectFile does not belong to project root
'<worktree path>'. Run Tools\Bootstrap\BootstrapWorktree.bat for this worktree.
```

The config is not wrong. `Resolve-AgentConfiguration` compares the configured `ProjectFile` against the entry path **as a string**, and `Normalize-PathValue` is purely lexical (`[System.IO.Path]::GetFullPath`), so it does not resolve junctions, symlinks, or `subst` drives. Every worktree that is reached through a short path alias fails whenever it is entered by its other name.

Five of nine current worktrees use an alias, because the long `.worktrees\<name>\` path breaks UBT at MAX_PATH:

| Alias | Kind | Target |
|---|---|---|
| `D:\as-cta` | junction | `.worktrees\refactor-as-canonical-typed-ast-compiler` |
| `D:\as-lns` | junction | `.worktrees\improve-as-library-namespace-canonicalization` |
| `R:` | subst | `.worktrees\feature-as-angelsea-runtime-jit-plugin` |
| `T:` | subst | `.worktrees\refactor-as-subsystem-typeinfo-bind-cache` |
| `V:` | subst | `.worktree\feature-as-typed-semantic-aot` |

Two further problems make this worse than a cosmetic annoyance:

1. **The suggested remedy is destructive.** `Resolve-ProjectFileForBootstrap` recomputes `ProjectFile` from the `WorktreeRoot` it is handed, and — unlike `EngineRoot` and the `Build` keys — it does *not* go through `Get-PreferredConfigValue`. Running `BootstrapWorktree` from the long path therefore overwrites a working short-path config with the long path, silently removing the MAX_PATH workaround that a real build failure had required.
2. **The diagnosis it invites is wrong.** The message names the project root, not the mismatch, so the failure reads as "the worktree is not configured" or "it still points at the main project". Sessions have concluded exactly that and worked around it, leaving the root cause in place. It recurs on every fresh session.

## What Changes

- Compare project-file identity by canonical path instead of by string, so a worktree entered through any of its names is accepted.
- Keep using the configured (short) `ProjectFile` for execution. Canonicalization is for the equality test only — resolving to the long path for execution would reintroduce the MAX_PATH build failure.
- Stop `BootstrapWorktree` from silently discarding an existing alias-based `ProjectFile`.
- Make the rejection message state the actual mismatch, and stop recommending `BootstrapWorktree` for a case where it makes things worse.

## Out of scope

- Teaching `NewWorktree.ps1` to create aliases automatically, and recording the alias as a first-class `AgentConfig.ini` key. That removes the manual step entirely and is the better end state, but it is a larger workflow change; see `design.md` "Rejected / deferred".
- Migrating the existing nine worktrees. After this fix their current configs all keep working.
