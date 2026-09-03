## Context

Hardness currently encodes `Current` and `Goal` in its context, AgentConfig identity, environment variables, lifecycle APIs, Git APIs, tests, and durable specs. That model assumes linked worktrees live below `.worktrees/<goal>` on `goal/<goal>`, but the real repository has registered worktrees at several paths with unrelated branch names. Common status also performs work that optional startup hooks do not need, while existing dogfooding policy has no cheap observation/status surface.

This Change is the workspace and workflow core only. It does not migrate Unreal commands, inspect old loop tools, change plugin code, update the OpenSpec parser/source/package, integrate branches, push, or remove worktrees.

## Decisions

### 1. Git registration is workspace identity

`New-HardnessContext` accepts an optional exact `WorkspaceRoot`; otherwise it resolves the process-local selection and then the caller's registered checkout. It returns:

| Field | Source and meaning |
|---|---|
| `SchemaVersion` | Hardness context schema |
| `HarnessRoot` | checkout containing the loaded Hardness module |
| `WorkspaceRoot` | exact registered checkout targeted by leaf defaults |
| `PrimaryRoot` | first/primary worktree in the common Git directory |
| `GitCommonDir` | canonical `git rev-parse --git-common-dir` result |
| `Topology` | `Primary` when roots match, otherwise `Worktree` |
| `WorktreeName` | linked-root leaf name; empty for Primary |
| `Branch`, `Head` | live Git facts |
| `Managed` | exact AgentConfig v2 identity is present |

`Managed=false` reports bootstrap readiness; it does not invalidate an otherwise registered worktree. HarnessRoot controls module/resource lookup and WorkspaceRoot controls command effects. Codex `/goal` never changes either value.

New worktrees use `.worktrees/<name>` and branch `<name>` by default, with an explicit branch override allowed. Existing registered roots and branches remain untouched.

### 2. Status has a fast default and an explicit diagnostic tier

`workspace.list` reads the current Git worktree registry. Default `workspace.status` returns registration, context identity, branch/HEAD, project binding, and config readiness without `git status`, ignored-file inventory, or recursive submodule dirty scans. `-Detailed` adds the existing parent, gitlink, submodule, ignored-data, and repair diagnostics.

Process-local caching is limited to module paths and bounded canonical-root facts. Create/bootstrap/remove invalidates it; `-Refresh` bypasses it. Registration, branch, HEAD, dirty state, config bytes, ignored data, and all mutation preconditions are always live.

### 3. AgentConfig v2 stores only durable local bindings

Hardness owns these fields:

```ini
[Hardness]
SchemaVersion=2
WorkspaceRoot=<exact registered root>
PrimaryRoot=<exact primary root>
GitCommonDir=<exact common directory>

[Paths]
ProjectFile=<the selected root's unique .uproject>
```

Topology, WorktreeName, Branch, and Head are derived, not persisted. Explicit bootstrap atomically migrates schema v1, removes `WorkspaceKind`, `GoalName`, and `[References] HazelightAngelscriptEngineRoot`, preserves every other user field/comment, and rebinds ProjectFile. Generic config mutation cannot edit managed keys.

Process selection uses only `HARDNESS_WORKSPACE_ROOT`, `HARDNESS_PRIMARY_ROOT`, and `HARDNESS_GIT_COMMON_DIR`. Old mode/name variables and parameters are removed rather than maintained as a second compatibility model.

### 4. Git mutation names exact workspaces and immutable source state

Commit accepts an exact WorkspaceRoot and exact repository/path scopes; explicit all-change intent applies only to that root. Integration accepts PrimaryRoot, exact registered `SourceWorkspaceRoot`, reviewed `ExpectedSourceHead`, and explicit target branches. It retains current staged-content, overlap, submodule-first, resumable merge, and no-force protections. Push remains a separate explicit ordered operation. Worktree removal remains owned by workspace-lifecycle.

### 5. Self-evolution is visible but not an event store

`hardness.status` provides harness version/health plus the fast selected-workspace summary. `hardness.observe` writes one bounded versioned JSON event below ignored `Saved/Hardness/Observations/`, with run ID, UTC timestamp, optional Change/stage/correlation, category, concise summary, optional duration, WorkspaceRoot, and HEAD. It never edits tasks or policy. `hardness.evolution.status` reports counts/latest timestamps and the latest tracked evaluation reference without loading every event body.

Every self-hosting Hardness/OpenSpec Change creates one indexed `attachments/data/workflow-evaluation.md` before completed closure. It trims overall and stage timings, repeated friction, repairs, deferred work, and raw artifact hashes/paths. Promotion to capability knowledge remains explicit and evidence-gated.

### 6. Task Cards gain prose, not schema

The existing YAML `task_graph.depends_on`, checkbox ID/state, `Files:`, and verify text remain the full machine contract. Cards may add only useful Markdown prose or labels such as Context, Constraints, Inputs, Produces, Watch, Notes, or Evidence. Labels are neither mandatory nor parsed. No OpenSpec executable/source change belongs here.

Deep Explore is triggered only for unresolved major pre-Change design. After registration, uncertainty stays in continue/update/apply/replan. `visual-explain` is favored for architecture, state, ownership, DAGs, or at least three related branches, while simple work remains prose-first.

### 7. Codex hooks are optional adapters

Project `.codex/hooks.json` registers only `SessionStart` and `SubagentStart` with a small `additionalContextLimit`. Both call one PS7 adapter, resolve the event workspace from the hook working directory, invoke fast `hardness.status`, emit bounded additional context, and fail open. They do not write observations or run detailed scans. No Stop/PostToolUse hook or user-global config change is introduced; other clients ignore this adapter.

### 8. OpenSpec maintenance remains read-only

`openspec.maintenance.status` compares the tracked `Tools/openspec` gitlink/working HEAD and dirtiness with the packaged release manifest and executable version/hash. It returns evidence and reasons only. Fetch, source update, rebuild, tag, binary replacement, and release commit require a later explicit maintenance Change.

## Migration and Compatibility

1. Land workspace-lifecycle and AgentConfig v2 behavior first.
2. Migrate git-operations and Hardness routes/tests to the new interface; do not retain Mode/GoalName overloads.
3. Align live Skills, focused references, protocol tests, and prepared AGENTS guidance while preserving the temporary top-level Skill-disable rule.
4. Add optional hooks and self-evolution routes, run focused/Quick/performance gates, then sync durable specs.
5. After final verification, diagnose and repair any discovered problem directly; replan only if evidence invalidates planning truth. With no explicitly requested Review, close and archive directly. Integration, push, and cleanup remain out of scope.

Archived records keep historical wording. Existing unbootstrapped worktrees remain registered and usable for read-only discovery, with `Managed=false` until explicitly bootstrapped.

## Risks / Trade-offs

- Removing compatibility parameters is intentionally disruptive while project Skills are disabled; live callers and tests must move together.
- Fast status omits dirty/submodule facts by design. Any mutation or safety decision performs live focused checks regardless of prior status/cache.
- HarnessRoot different from WorkspaceRoot can accidentally redirect relative paths; tests must prove module resources use the former and command defaults use the latter.
- Concurrent observation writers must use unique files or an atomic append discipline and bounded payloads.
- Project hooks require Codex trust and may be unavailable; workflow correctness cannot depend on them.
- The main workspace is heavily dirty. Implementation and commits must preserve unrelated content and stage only exact Change-owned paths or hunks.

## Verification Strategy

- Hermetic PowerShell fixtures prove primary and arbitrary registered-worktree discovery, config migration, branch defaults, cache invalidation, execution guards, exact Git scopes, and integration safety.
- Hardness tests prove the context/result schema, route ownership, ignored observation records, maintenance status, and lack of Mode/GoalName compatibility.
- Protocol/OpenSpec Skill tests prove English live records, optional Task Card prose, explicit Explore/visual triggers, hook bounds, and no parser/package mutation.
- PS7 Quick runs the complete Skill-only matrix. Performance measures correctness and timing without turning one machine comparison into a flaky gate.
- Strict active validation and focused protocol gates prove direct-closure readiness. Any explicitly requested Review must close before archive, but Hardness creates no automatic Final Review.
