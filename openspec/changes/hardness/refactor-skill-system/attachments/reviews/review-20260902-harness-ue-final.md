---
state: superseded
reviewed_at: 2026-09-02T21:48:48.1788462+08:00
review_scope: Hardness, Workspace, Review/Replan, systematic-debugging, Unreal command leaf, and changed public Tools PowerShell shims
snapshot:
  parent_base: 4129487f63fab930800a896ae7f932d7bd4e6e70
  branch: goal/refactor-hardness-skill-system
  scope_file_count: 73
  scope_current_tree_sha256: a88bc2113eb216ae818f2d8c38eb2b2613e93d4016da233078c2c6317d1e9bac
  scope_tracked_diff_sha256: 6fb781945f06f1615e41c7916125bedcc52e1f62fbce12fb5ada3e76f7587fc2
verdict: REQUEST_CHANGES
superseded_at: 2026-09-03T00:54:49.5677584+08:00
superseded_by: replan-20260903-005449-defer-unreal-leaf-and-limit-binary-history
---

# Hardness and Unreal Coordination Review

The reviewed snapshot has a strong Workspace safety foundation and its focused tests pass in both supported PowerShell hosts. It is not ready for the Task 2.4 gate, however: Goal-mode native routes can act on the caller's checkout, two package-smoke workflows reference a missing leaf, and several UE execution, suite, evidence, and compatibility contracts are not yet enforced by the implementation or tests.

The snapshot digest above covers every current regular file below `.agents/skills/hardness/**`, `.agents/skills/git-workflow/**`, `.agents/skills/code-review/**`, `.agents/skills/systematic-debugging/**`, and `.agents/skills/unreal-engine-develop/**`, plus the twelve changed public `Tools/*.ps1` shims. It is SHA-256 over sorted `relative-path + NUL + file-SHA256` records. The tracked-diff digest is SHA-256 over the LF-normalized `git diff --full-index --no-ext-diff` text for the same pathspecs; together with `parent_base`, it also captures deletions while the current-tree digest captures untracked implementation files.

## Verification Story

- PowerShell 7.6.0: `Hardness.Tests.ps1`, `Protocol.Tests.ps1`, `Test-Hardness.Tests.ps1`, `Workspace.Tests.ps1` (including `Workspace.Safety.Tests.ps1`), and `UnrealEngineDevelop.Tests.ps1` all passed.
- Windows PowerShell 5.1.26100.8875: the same five focused test entry points all passed.
- All twelve changed public `Tools/*.ps1` shims parsed in both hosts. Their public parameter-name sets match the base snapshot; the specialized mapping probes in `UnrealEngineDevelop.Tests.ps1` passed.
- `git diff --check` passed for the complete review scope; Git emitted only working-copy LF/CRLF notices.
- A temporary-fixture probe called build, automation, suite, commandlet, package, JIT, and coverage with `-PlanOnly`; the fixture remained byte-for-byte empty (`Before=[]`, `After=[]`).
- The previously closed Workspace safety snapshot remains unchanged: `Workspace.psm1` SHA-256 is `e4fb10ccc84c1c5864513e71a60a8d8e7078a3b56f9caeef775d0735bb77c4d4`. Static inspection and the fixtures found no automatic merge or push, and worktree removal remains a separate explicit, guarded operation.
- No real Unreal build or Automation run was performed in this review. Complete All and StaticJIT All were not run, as required by the assigned scope.

## Finding 1 — Goal Native Routes Execute in the Caller's Working Directory

```yaml
severity: Critical
status: resolved
dimensions: [correctness, architecture, security]
```

Files and lines:

- `.agents/skills/hardness/scripts/Hardness.psm1:205-259`

`Invoke-Hardness` resolves a Goal route's executable from `Context.WorkspaceRoot`, but the native branch invokes it without changing its working directory or supplying the selected project root. OpenSpec discovers its project from the process current directory, so a persistent shell that remains in the primary checkout validates or mutates the primary OpenSpec tree while apparently using a Goal context.

The read-only reproduction imported Hardness from the Goal worktree, created a Goal context with primary root `D:\Workspace\AngelscriptProject` and workspace root `D:\Workspace\AngelscriptProject\.worktrees\refactor-hardness-skill-system`, then invoked `openspec.status --json` while the shell was in the primary root. Hardness returned the primary result (`No active changes`) exactly, while direct execution from the Goal root returned `hardness/refactor-skill-system` with 13 Task nodes. `MatchesPrimary=True` and `MatchesGoal=False`.

Impact: Goal-mode `status` and `validate` inspect the wrong record; mutating commands such as `init`, `change`, `spec`, or `archive` can write to the dirty primary checkout and violate the central isolation/authority boundary.

Resolution condition: execute every native route with `Context.WorkspaceRoot` (Goal) or `Context.ProjectRoot` (Current) as an explicit working directory, restore the caller's location in `finally`, and add PowerShell 5.1/7 regressions with distinct primary and Goal OpenSpec trees. The test must prove both selected-tree behavior and caller-location preservation for read and mutation fixtures.

## Finding 2 — Completed or Timed-out Asynchronous Runs Are Not Reaped Without Polling

```yaml
severity: Required
status: resolved
dimensions: [correctness, performance, architecture]
```

Files and lines:

- `.agents/skills/unreal-engine-develop/scripts/Private/Core.ps1:209-295`
- `.agents/skills/unreal-engine-develop/scripts/Private/Coordination.ps1:9-27`

Process exit, deadline enforcement, stream draining, state finalization, and lease release occur only inside `Pump-AngelscriptExecution`, which runs only when the caller asks for status or wait. `-AsJob` therefore does not have independently owned lifecycle semantics.

Two temporary-process reproductions demonstrate the defect:

1. A child exited successfully after 100 ms. After waiting 500 ms without polling, its OS process had exited, but a second build in the same PowerShell session failed with `Unreal workflow lease is busy`. The first status request then changed the recorded state to `Succeeded` and released the stale lease.
2. A child slept for two seconds with a 200 ms total timeout. At 650 ms, before any status call, the process was still alive. The first status request killed it and changed the state to `TimedOut` with exit code 2.

The same polling design advances only one outstanding `ReadLineAsync` chain, so an unpolled high-output child can also fill redirected pipes. Completed `Process`, readers, tasks, and execution records are retained indefinitely in the synchronized table, which makes a long-lived agent session unbounded.

Resolution condition: give each asynchronous execution an active monitor that continuously drains both streams, enforces the total deadline, atomically finalizes state, releases the semaphore exactly once, and disposes live process/stream resources independently of user polling. Preserve queryable immutable snapshots with bounded retention. Add regressions for normal exit without polling, timeout without polling, high-volume stdout/stderr, lease reuse, log completeness, and repeated-session resource cleanup.

## Finding 3 — Package-smoke Workflows Reference a Missing Skill-owned Runner

```yaml
severity: Required
status: resolved
dimensions: [correctness, architecture]
```

Files and lines:

- `.agents/skills/unreal-engine-develop/scripts/RunAngelscriptCachePackageSmoke.ps1:143-168`
- `.agents/skills/unreal-engine-develop/scripts/RunAngelscriptJITPackageSmoke.ps1:407-428`
- `.agents/skills/unreal-engine-develop/scripts/Private/PackageJitDiagnostics.ps1:21-46`
- `.agents/skills/unreal-engine-develop/scripts/Private/PackageJitDiagnostics.ps1:84-103`

Both non-skipped package-smoke implementations launch `Join-Path $PSScriptRoot 'RunPackage.ps1'`, but `.agents/skills/unreal-engine-develop/scripts/RunPackage.ps1` does not exist. The public `Tools/RunPackage.ps1` shim exists, but the workflows intentionally execute the skill-owned directory and therefore fail before packaging. `Test-AngelscriptToolchain` checks build, tests, and commandlet leaves, but not this required package leaf, and the current tests exercise only PlanOnly/mapping paths.

Impact: `CachePackageSmoke` and `StaticJitPackageSmoke` are broken in their default, non-`SkipPackage` mode even though route planning and installation checks report success.

Resolution condition: add the actual skill-owned package runner or refactor both workflows onto one non-recursive package implementation while retaining the parent workflow lease and total deadline. Extend installation/toolchain checks and add safe mocked non-PlanOnly tests proving both workflows reach and correctly parameterize the package implementation in PowerShell 5.1 and 7.

## Finding 4 — Coarse and Monolithic Execution Ignore the Selected Suite

```yaml
severity: Required
status: resolved
dimensions: [correctness, architecture]
```

Files and lines:

- `.agents/skills/unreal-engine-develop/scripts/Private/Tests.ps1:106-128`
- `.agents/skills/unreal-engine-develop/scripts/RunTestSuiteParallel.ps1:111-165`
- `.agents/skills/unreal-engine-develop/scripts/RunTestSuiteParallel.ps1:181-196`
- `.agents/skills/unreal-engine-develop/scripts/RunTestSuiteParallel.ps1:255-285`

The module's PlanOnly result is built from the requested suite for every strategy, but the actual parallel runner uses global coarse shards for `Coarse` and a global monolithic prefix for `Monolithic`. It even prints the suite as `<n/a>` unless the strategy is `Fine`. Typed entries under non-Fine strategies are remapped into `All`.

The read-only reproduction planned `Suite=Smoke, Strategy=Coarse` through the module and received the six Smoke prefixes. Running the selected leaf with `-Suite Smoke -Strategy Coarse -DryRun` instead emitted global commands beginning with `Angelscript.TestModule`, `Angelscript.Editor`, `Angelscript.GAS`, `Angelscript.GameplayTags`, and `Angelscript.Template`, and printed `Suite: <n/a>`.

Impact: the advertised plan and the launched work diverge; a focused suite request can unexpectedly expand to nearly All, increasing runtime and executing unrelated or high-risk tests.

Resolution condition: either make every accepted strategy derive execution entries from the selected suite, or reject non-All suites for strategies that are intentionally global. The module plan and leaf DryRun must be generated from one planner. Add a matrix over at least Smoke and All across Serial, CoarseDynamic, Coarse, Monolithic, and Fine, asserting identical entry identities and heavy-cap behavior.

## Finding 5 — The All Catalog Claims Coverage That the Source Does Not Provide

```yaml
severity: Required
status: resolved
dimensions: [correctness, verification]
```

Files and lines:

- `.agents/skills/unreal-engine-develop/scripts/Shared/TestSuiteDefinitions.ps1:79-110`
- `.agents/skills/unreal-engine-develop/scripts/Private/Tests.ps1:3-10`
- `.agents/skills/unreal-engine-develop/tests/UnrealEngineDevelop.Tests.ps1:208-216`

The new policy marks `Learning` as included at `Angelscript.TestModule.Learning`, but the current plugin source contains zero registered definitions with that prefix; its only occurrence is a comment describing a removed trace-style test. The policy also treats `Angelscript.TestModule.CppTests` as the complete CppTests theme, while the source has five registered `Angelscript.CppTests.*` definitions in addition to the three `Angelscript.TestModule.CppTests.*` definitions. The current test verifies only that a policy row says `Include` or `Exclude`; it does not prove discovery or complete prefix coverage.

Impact: All contains a guaranteed zero-test entry and still omits active C++ tests while reporting the theme as included. PlanOnly therefore cannot be used as an authoritative catalog audit.

Resolution condition: reconcile the catalog with actual registered automation names: remove or explicitly exclude the nonexistent Learning entry, and include both live CppTests namespaces or migrate them under one verified namespace. Add a source/discovery-backed catalog test that rejects zero-match included prefixes and detects active definitions left outside the declared All policy.

## Finding 6 — Coverage Accepts Stale and Non-terminal Evidence

```yaml
severity: Required
status: resolved
dimensions: [correctness, verification]
```

Files and lines:

- `.agents/skills/unreal-engine-develop/scripts/Private/Tests.ps1:57-71`
- `.agents/skills/unreal-engine-develop/scripts/Private/PackageJitDiagnostics.ps1:49-72`

`Get-AngelscriptAutomationSummary` counts every unknown state as skipped and defines success only as `Failed == 0`. `Resolve-AngelscriptCoverageEvidence` accepts any explicit pre-existing path without checking that this run created or changed it. Consequently, a process that does no work can reuse a stale report whose only test is still `Running`.

The temporary reproduction wrote `{"tests":[{"state":"Running"}]}` before starting the coverage command, used a child that immediately exited zero, and supplied that unchanged path explicitly. The result was `Succeeded`, `AcceptedStaleRunningOnlyReport=True`, and `EvidencePredatesRun=True`.

Impact: the Coverage gate can pass without a completed test and without evidence produced by the reviewed invocation.

Resolution condition: bind evidence to the current run (known output path or pre/post identity/hash), reject unknown/non-terminal states, require the expected structured report schema and at least one completed successful test, and preserve report provenance in execution data. Add regressions for stale explicit evidence, Running/unknown states, all-skipped reports, failed reports, and a fresh successful report.

## Finding 7 — General Public Shims Collapse Established Exit Semantics

```yaml
severity: Required
status: resolved
dimensions: [correctness, compatibility]
```

Files and lines:

- `Tools/RunBuild.ps1:8-15`
- `Tools/RunTests.ps1:8-12`
- `Tools/RunCommandlet.ps1:8-12`
- `Tools/RunPackage.ps1:7-9`

The public parameter lists are preserved, but these general shims convert every leaf exception to exit code 1. At the fixed base commit, build, tests, commandlet, and package distinguish a total-timeout result with exit code 2; the new module also records timeout as status `TimedOut`, exit code 2. The wrapper discards that distinction. Specialized shim tests explicitly protect their legacy error/timeout exits, but no equivalent coverage exists for the four general entry points.

Impact: CI and agent callers that distinguish timeout/retry from a normal build, test, commandlet, or packaging failure receive a different result after the compatibility migration.

Resolution condition: define and preserve the public exit-code contract for every changed shim, including timeout/config/ordinary failure where previously observable, and add isolated mock probes for all public entry points in both PowerShell hosts. Argument-forwarding tests must also cover `ExtraArgs`, parameter sets/aliases, and switches for the general wrappers.

## Finding 8 — Workspace Finish Overstates Goal-level Readiness

```yaml
severity: Advisory
status: resolved
dimensions: [architecture, authority]
```

Files and lines:

- `.agents/skills/git-workflow/scripts/Workspace.psm1:634-761`
- `.agents/skills/git-workflow/git-worktree.md:3-19`

`Complete-HardnessWorkspace` correctly performs only Git/submodule work, but it returns `ReadyToIntegrate = $true` after checking cleanliness and exact gitlinks. It has no evidence that the Task DAG, Review Gates, required verification, closure metadata, or declared non-gates are complete. In this change, commits are intentionally planned before the final layered verification task, so the property can become true while the Goal is explicitly not ready.

Resolution condition: keep the Workspace leaf's result scoped to Git facts (for example, committed/clean/exact) and let the Hardness/OpenSpec coordinator report Goal-level `ready-to-integrate` only after closure evidence is verified. Align the examples and result name so an automation consumer cannot mistake Git cleanliness for authorization to integrate.

## Positive Results

- The Workspace implementation retains the independently reviewed physical containment, dirty-submodule preservation, exact-gitlink, object-store, ignored-data, primary-checkout, and explicit-removal guards. Both PowerShell hosts reran the complete fixtures successfully.
- Hardness exposes only four public functions, keeps leaf lookup lazy, returns independent run IDs, and preserves native non-zero diagnostics in its result envelope.
- Review, Replan, Task DAG, and closure references are concise and keep review arrival separate from triage and Replan. They clearly prohibit automatic merge, push, archive fabrication, and worktree removal.
- PlanOnly is side-effect free across the tested UE route families, per-run output directories are isolated, parameter names are preserved for all twelve public shims, and the specialized mapping tests cover important JIT/cache/Standalone arguments.
- Named workflow synchronization uses `System.Threading.Semaphore` rather than a thread-affine mutex, and the focused status/wait/cancel behavior works when the caller actively polls.

## Decision

**REQUEST CHANGES.** Keep this review open. Finding 1 is Critical and Findings 2 through 7 are Required; all must be resolved with focused regressions and a new fixed-snapshot re-review before Task 2.4 can close. Finding 8 is Advisory and may be resolved in this change or deferred only with a concrete named follow-up. This review does not decide whether any finding requires Replan; the coordinator must triage that question under the Review/Replan protocol.

## Scope-cut disposition — 2026-09-03

This fixed-snapshot review remains evidence of the mixed Hardness/Workspace/UE prototype. The user subsequently removed the entire `unreal-engine-develop` leaf and public wrapper migration from this delivery because the project is undergoing a large refactor. Replan `replan-20260903-005449-defer-unreal-leaf-and-limit-binary-history` therefore supersedes this review for the current delivery. Findings 2-7 are resolved for this delivery solely by removing every affected implementation and public wrapper path; this is not a technical approval of the recoverable UE prototype.

- Finding 1 is retained in the core scope and has a two-host Goal/Current workspace regression; it must be re-evaluated by the new Hardness-core review.
- Finding 8 is retained in the core scope and has been narrowed to Git-state facts; it must be re-evaluated by the new Hardness-core review.
- Findings 2-7 are non-gating for this delivery because all affected code was removed from its snapshot. Their unresolved technical work remains preserved with stash object `a5c22b287fff34e9af1bf07e1d28c73e97862a31` for a separately created future change.
- This REQUEST_CHANGES verdict is not converted to APPROVE. Task 2.4 requires a new fixed-snapshot review whose scope excludes the deferred UE WIP.

Coordinator resolution evidence:

- Finding 1 is resolved in the current core by canonical primary-worktree selection, safe Goal-name and direct-child validation, registered-worktree and physical-path checks before leaf loading, and create-then-route regressions in both PowerShell hosts. The new core re-review remains responsible for approval.
- Finding 8 is resolved by limiting Workspace completion output to Git facts and leaving Task DAG, verification, Review, closure, and integration authority with Hardness/OpenSpec. The new core re-review remains responsible for approval.
- Findings 2-7 remain technically unresolved inside the extracted stash, but are resolved for this delivery because none of their affected implementation or wrapper paths is present.
