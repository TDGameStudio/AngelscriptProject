## Why

The existing `git-workflow` Skill has three incompatible identities: its directory is `git-workflow`, its Skill name is `using-git-worktrees`, and its title is `Git Workspace Lifecycle`. More importantly, it mixes safe worktree/configuration lifecycle with commit creation through `workspace.finish`. That makes ownership unclear, encourages broad staging, and leaves local integration knowledge outside the Hardness command surface.

`AgentConfig.ini` is currently copied byte-for-byte. A copied absolute `Paths.ProjectFile` may still select the primary checkout from a Goal worktree, and configuration validation does not record the workspace identity that owns the file. Existing build/test tooling already isolates mutexes, outputs, execution slots, and UBT process discovery by worktree; the missing control is an execution-time identity gate that prevents one selected workspace from launching another workspace's build or test.

The project Skills are temporarily disabled during the wider refactor, making this the appropriate point for a direct cut rather than another compatibility layer. The user explicitly selected Current/main implementation, Hardness-owned local configuration, local integration without push or branch cleanup, and merge-based history preservation.

## What Changes

- Replace `git-workflow` with `workspace-lifecycle`, retaining worktree creation/bootstrap/status/verification/removal and all existing safety invariants.
- Make `AgentConfig.ini` a Hardness-managed per-workspace local configuration with managed identity, target-local `ProjectFile`, controlled get/set/status routes, and session activation.
- Add an execution guard to build/test/commandlet configuration resolution while preserving all-worktree UBT process discovery and per-worktree concurrency.
- Add `git-operations` with structured status, exact scoped commit, submodule-first Goal closure, explicit local Goal-to-primary integration, and separately authorized push.
- Replace `workspace.finish` with `git.commit`; add `git.status`, `git.integrate`, and explicit `git.push` without automatic publication, force push, source-branch deletion, or worktree removal.
- Rebaseline durable contracts from `hardness/core` into new `hardness/workspace` and `hardness/git` capabilities.

## Capabilities

### Added Capabilities

- `hardness/workspace`: canonical workspace lifecycle, local configuration identity, session selection, and workspace-sensitive execution guards.
- `hardness/git`: scoped multi-repository commits and explicit resumable local integration.

### Modified Capabilities

- `hardness/core`: route the two new leaves and retain only coordination/authority boundaries.

## Impact

This change modifies parent-repository Skills, PowerShell modules/tests, local configuration handling, shared build/test configuration guards, OpenSpec specs, and live root guidance. It does not modify plugin submodule source, the OpenSpec executable, UE build behavior after configuration resolution, build/test mutex design, output layout, UBT process discovery, or remote Git state.

## Non-Goals

- A daemon, database, global active-workspace file, or duplicated Git worktree registry.
- Automatic semantic conflict resolution, automatic publication, force push, branch deletion, or worktree deletion during integration.
- Moving or rewriting historical OpenSpec archives or soon-to-be-removed `Documents/` content.
- Running Unreal builds, UE Automation, StaticJIT All, or long Unreal suites for this Skill/PowerShell refactor.
