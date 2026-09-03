## Why

The project workflow framework was named `Hardness`, but its actual role is a test/control harness. `Harness` is the correct product and code identity; retaining the mistaken name would continue spreading misleading module, route, environment, schema, local-data, and OpenSpec identifiers. The user requested an immediate main-workspace correction and a hard public cutover.

## What Changes

- Rename the live entry Skill, PowerShell modules, exported/internal functions, tests, Codex hooks, route namespace, environment variables, record schemas, mutex/lease/temp identities, Saved data roots, LocalAppData registry root, and default commit scope from Hardness to Harness.
- Move the live OpenSpec `hardness` domain to `harness` through the portable CLI so current domains, specs, and this active Change move together while old IDs remain aliases.
- Provide explicit compatibility only for persisted data: `workspace.bootstrap` migrates `[Hardness]` schema v2 to `[Harness]` schema v3, readers may inspect historical `Saved/Hardness` evidence, the first real UE operation migrates the drive registry under lock, and evolution status may read old evaluation records in immutable archives.
- Make old public imports, function names, routes, and environment variables unavailable after cutover.
- Update maintained parent-repository contracts, Skill documentation, OpenSpec configuration, Codex hooks, coupled tests, root README routing, and the two surviving root helper scripts that directly call renamed functions.
- Verify isolated module behavior, workspace/data migration, OpenSpec integrity, complete Harness gates, and one real `AngelscriptSmoke` launch before same-round archive and exact commit.

## Capabilities

### New Capabilities

None. This Change corrects the identity of the existing project workflow framework.

### Modified Capabilities

- `harness/core`: Rename the public framework identity, routes, record formats, local evidence roots, and compatibility boundary to Harness.
- `harness/workspace`: Introduce explicit `[Hardness]` v2 to `[Harness]` v3 bootstrap migration and new environment-variable behavior.
- `harness/git`: Rename the public PowerShell API and default commit scope while preserving exact Git semantics.
- `harness/unreal`: Rename the public PowerShell API and migrate the machine-local Unreal drive registry only on a real operation.

## Impact

The parent repository changes across `.agents/skills`, `.codex/hooks`, live OpenSpec records/specs/configuration, `AGENTS.md`, `README.md`, and two retained root helper scripts. `Tools/openspec` remains a clean pinned submodule and is not updated, tagged, or published. Plugin submodules are unaffected.

Immutable OpenSpec archives, `Documents/`, `Reference/`, ignored historical `Saved/Hardness` evidence, and the separately deferred Unreal build failure are outside scope. No push, integration, worktree creation/removal, broad root-Tools cleanup, or backward-compatible public alias layer is authorized.
