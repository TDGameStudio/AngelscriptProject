## Context

`Hardness` currently identifies a coordinated parent-repository framework rather than one isolated module. The word appears in the entry Skill and module, shared context/result helpers imported by workspace/Git/Unreal leaves, tests and fixtures, Codex hooks, three public routes, process environment variables, AgentConfig, ignored Saved output, a machine-global Unreal drive registry, live OpenSpec identities, and maintained guidance. A simple directory rename would leave callers, persisted state, and closure checks inconsistent.

The workspace also contains extensive unrelated staged/unstaged/untracked refactor work. The rename must therefore be a path-bounded parent-repository change, preserve unrelated README additions while editing the same file, and avoid touching clean top-level submodules. Existing OpenSpec archives are immutable evidence; the active domain and current specs are mutable product truth.

## Goals / Non-Goals

**Goals:**

- Establish `Harness` as the only maintained public and internal framework identity.
- Keep stable leaf routes (`workspace.*`, `git.*`, `openspec.*`, `task.*`, `ue.*`) behaviorally unchanged while renaming only the framework-owned `hardness.*` routes.
- Preserve valid machine-local configuration and registry state through explicit, testable migration owners.
- Move live OpenSpec identity without losing object identity or old-ID resolution.
- Verify both absence of the old public API and successful real UE startup before same-round closure.

**Non-Goals:**

- Public compatibility aliases, deprecation shims, or dual Hardness/Harness operation.
- Rewriting immutable archives, historical ignored output, Documents, Reference, or pinned OpenSpec source/release history.
- Updating the independent `Tools/openspec` submodule or changing its CLI behavior.
- Fixing the deferred AngelscriptJIT build failure or broad root Tools deletion.
- Publishing, pushing, integrating, or creating/removing a worktree.

## Decisions

### 1. Apply one hard identity matrix

The cutover uses one mechanical mapping across maintained live paths and content:

| Old | New |
|---|---|
| `hardness` public domain/route/schema prefix | `harness` |
| `Hardness` modules, symbols, types, paths, messages | `Harness` |
| `HARDNESS_*` process environment | `HARNESS_*` |
| `[Hardness] SchemaVersion=2` | `[Harness] SchemaVersion=3` |
| `Saved/Hardness` new-write root | `Saved/Harness` |
| `TDGameStudio/Hardness` current LocalAppData root | `TDGameStudio/Harness` |
| `[Hardness]` generated/default commit scope | `[Harness]` |

The stable leaf command namespaces do not change. The framework-owned routes become exactly `harness.status`, `harness.observe`, and `harness.evolution.status`.

### 2. Move live OpenSpec identity through the CLI

After planning is complete, run `openspec domain move hardness --to harness`. This moves the domain manifest, current specs, and active Change together and updates canonical IDs while retaining old IDs as aliases. No directory is hand-moved. The existing `openspec/archive/changes/hardness/**` tree is excluded from all content rewrites and path moves.

The active Change then continues canonically as `harness/rename-hardness-to-harness`; its delta paths move to `specs/harness/**`. Current specs are semantically synchronized before archive.

### 3. Break the mistaken public API immediately

No compatibility exports or forwarding functions are added for `Hardness.psd1`, `*-Hardness*`, `hardness.*`, or `HARDNESS_*`. Fresh-process tests import only `Harness.psd1` and explicitly verify old module/function/route absence. PowerShell modules whose exports change advance from `2.0.0` to `3.0.0`; existing GUIDs remain stable so module identity history is preserved.

Narrow old-name string constants are permitted only inside migration or historical-read logic. Tests and audit tooling distinguish those constants/fixtures from public aliases.

### 4. Make bootstrap the sole AgentConfig migration writer

The supported current file contains `[Harness]` with `SchemaVersion=3`. Parser/read operations recognize a legacy-only `[Hardness]` schema-v2 section only to emit an explicit bootstrap-required failure. `workspace.bootstrap` performs the migration using the existing atomic configuration-write path:

1. Validate the legacy managed identity against the selected Git workspace.
2. Preserve managed values, comments, blank lines, non-managed keys, and unrelated sections.
3. Replace the legacy section header/schema with the current Harness header/schema.
4. Remove any stale legacy managed section and validate the resulting current file.

Activation writes `HARNESS_WORKSPACE_ROOT`, `HARNESS_PRIMARY_ROOT`, and `HARNESS_GIT_COMMON_DIR` in process scope, then removes corresponding `HARDNESS_*` variables. No other route silently repairs the file.

### 5. Migrate the Unreal registry only at the real side-effect boundary

The current registry remains the stable unsuffixed `DriveAssignments.json` under `%LOCALAPPDATA%/TDGameStudio/Harness/Unreal`. `PlanOnly` resolves and reports plans without creating directories or moving either registry. At the first real operation that needs registry coordination, the existing registry mutex is acquired, then:

- old only: create the new parent and move the file without changing bytes;
- new only: continue normally;
- neither: create new state only when the normal operation requires it;
- both with identical bytes: retain the current file and leave the historical duplicate untouched for explicit cleanup;
- both with different bytes: fail with both exact paths and overwrite neither.

This Change does not encode implementation schema versions in filenames. The mutex, lease, drive-alias metadata, and temporary identities also move to Harness naming.

### 6. Preserve historical read compatibility without historical writes

New observations and evaluations use `Saved/Harness` and `harness-workflow-evaluation-v1`. `harness.evolution.status` searches current Harness evidence first and may read old `Saved/Hardness` observations or `hardness-workflow-evaluation-v1` only as historical input. It never rewrites those records. The same rule applies to the legacy Unreal registry before real-operation migration.

Immutable archives keep old prose, IDs, paths, and record frontmatter. Pinned release notes/changelogs in the independent OpenSpec source may also retain historical wording.

### 7. Keep the implementation bounded to maintained live owners

The rename covers `.agents/skills/hardness` to `.agents/skills/harness`, coupled leaf Skills/modules/tests, `.codex/hooks`, `AGENTS.md`, `.agents/skills/README.md`, `openspec/config.yaml`, `openspec/README.md`, live OpenSpec manifests/specs/Change, and maintained root README routing. Two surviving root helpers that directly invoke shared renamed symbols are included: `Tools/Shared/UnrealCommandUtils.ps1` and `Tools/Diagnostics/powershell/ResolveAgentCommandTemplates.ps1`. Other root Tools deletions/refactors remain untouched.

Because `README.md` already contains unrelated uncommitted additions, isolate that exact file before the mechanical rename, apply the clean-baseline rename, then restore the unrelated additions and commit only the rename hunks. If restoration conflicts, reconstruct and verify the unrelated lines before continuing.

### 8. Verify the cutover in layers

First add/update fixtures for the renamed module surface and migrations, then mechanically rename implementation and make tests green. Run isolated core/workspace/Git/OpenSpec/Unreal tests, the Quick and Integration profiles, strict current/all/archived OpenSpec validation, doctor, and an allowlisted old-name audit. The audit permits old names only in immutable archives, pinned independent source/history, Documents/Reference, explicit migration/history-read constants, and negative fixtures.

The real acceptance operation is one `AngelscriptSmoke` suite launch through Harness. A UE build is explicitly excluded. The Change then receives a `harness-workflow-evaluation-v1` record, terminal evolution check, completed archive, post-move validation/gate, and one exact parent commit without push.

## Risks / Trade-offs

- **Missed string or path:** broad case-sensitive/case-insensitive audits plus fresh-process negative tests prevent partial public cutover.
- **Accidental historical rewrite:** path allowlists exclude archives/Documents/Reference/pinned source, and Git diff audits verify immutable archive identities outside this Change.
- **Lost local state:** bootstrap and real UE migration own separate atomic transitions; PlanOnly and normal pre-bootstrap reads remain non-mutating.
- **Dirty-worktree contamination:** exact path-scoped commits and README hunk isolation preserve unrelated changes.
- **Breaking callers:** intentional. The user selected an immediate hard cutover; no demonstrated external compatibility obligation exists.
- **Registry ambiguity:** conflicting dual files fail closed instead of guessing or merging.
- **Large mechanical diff:** semantic behavior remains concentrated in migration functions and tests; the rest is validated by deterministic name audits and module gates.
