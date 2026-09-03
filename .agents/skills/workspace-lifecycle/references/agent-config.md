# Local Agent Configuration

`AgentConfig.ini` is ignored, machine-local, and owned by Harness at each workspace root. It is configuration, not a credential store, shared database, or source of Git topology.

## Managed Identity

```ini
[Harness]
SchemaVersion=3
WorkspaceRoot=D:\Workspace\AngelscriptProject
PrimaryRoot=D:\Workspace\AngelscriptProject
GitCommonDir=D:\Workspace\AngelscriptProject\.git
```

Harness owns these four keys and `[Paths] ProjectFile`. `Topology`, `WorktreeName`, `Branch`, and `Head` are live Git facts and are never persisted. `HarnessRoot` is the checkout supplying the loaded Harness module and may differ from the selected `WorkspaceRoot`.

Explicit bootstrap migrates schema v1 and v2 in place. A legacy `[Hardness]` schema-v2 section is accepted only by bootstrap and is atomically renamed to `[Harness]` schema v3. Bootstrap removes the former workspace-kind and goal-name identity keys plus `[References] HazelightAngelscriptEngineRoot`, rebinds `ProjectFile`, and preserves unrelated values, sections, comments, and newline style. When a new linked workspace has no local file, machine-shared values are copied from the canonical primary checkout before its managed fields are rebound.

`[References] HazelightAngelscriptEngineRoot` is forbidden after migration. Its presence makes workspace identity invalid, blocks execution, and cannot be recreated through `workspace.config.set`; run `workspace.bootstrap` to remove it without disturbing unrelated local settings.

## Configuration Routes

```powershell
Invoke-Harness -Command workspace.config.status -Context $context

Invoke-Harness -Command workspace.config.get -Context $context -Parameters @{
  Section = 'Paths'
  Key = 'EngineRoot'
}

Invoke-Harness -Command workspace.config.set -Context $context -Parameters @{
  Section = 'Paths'
  Key = 'EngineRoot'
  Value = 'J:\UnrealEngine\UERelease'
}
```

`status` reports identity and key availability without dumping values. `get` reads one exact key. `set` updates one non-managed, single-line value atomically while preserving unrelated local content.

Trusted leaf modules may call the exported `Get-HarnessWorkspaceConfigValues` function to read up to 64 named entries after one live status or execution-guard check. This batch boundary avoids repeating Git identity validation for every key; it does not cache configuration bytes, authorization, or mutation preconditions, and it is not an additional Harness route.

## Process-local Selection

`workspace.activate` writes only these process environment variables for child commands:

```text
HARNESS_WORKSPACE_ROOT
HARNESS_PRIMARY_ROOT
HARNESS_GIT_COMMON_DIR
```

A later explicit selection replaces all three. No repository mode or workflow name is stored. Separate PowerShell 7 processes can therefore select different registered worktrees without modifying each other's local configuration.

Before a workspace-sensitive command launches an external process, the execution guard compares the requested root, Git registration and common directory, schema-v3 identity, root `.uproject`, optional process selection, and caller location. Read-only listing remains available across all registered worktrees. A legacy-only `[Hardness]` section is rejected with a bootstrap-required diagnostic and is never rewritten by an ordinary read or execution route.

When the selected parent branch is `main` and `.gitmodules` declares `Plugins/Angelscript`, the same execution guard verifies that the initialized plugin HEAD equals the latest known main baseline. A local `refs/heads/main` is authoritative when present; otherwise Harness uses the fetched `refs/remotes/origin/main`. When both exist, local main must contain the fetched remote-tracking tip. Detailed workspace status exposes the compared commits, while fast status remains free of submodule inspection. Harness never fetches, checks out, merges, resets, commits, or pushes as part of this check; refresh network refs explicitly before relying on remote freshness. Non-main parent branches remain exempt for intentional plugin feature development.
