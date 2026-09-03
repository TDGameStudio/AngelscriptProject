# INDEX

## Current position

All eight Task DAG nodes are complete. The user replaced the former automatic Final Review node before any Review snapshot or record was created; the explicit-only Review/direct-closure correction and its focused gates now pass. The Change is ready for completed closure and deterministic archive. `tasks.md` remains the only execution state.

## Hard conclusions

- Hardness has one Git-derived workspace model; Codex `/goal` is not a repository mode.
- HarnessRoot identifies the loaded harness, while WorkspaceRoot identifies the command target.
- Every registered worktree is valid at its actual path and branch; new worktrees default Branch to Name.
- Task-card detail remains optional Markdown prose; OpenSpec parsing and the executable do not change.
- Raw observations and timing stay ignored under `Saved/Hardness/`; this self-hosting Change tracks one compact workflow evaluation before completed closure.
- Hardness never starts Review automatically. It repairs local defects, replans only when canonical planning truth is invalid, and otherwise archives after verification. Review is a gate only when the user or an external agent explicitly requests it.
- Codex hooks are optional fast-status adapters, not cross-client workflow dependencies.
- Unreal development integration is a separate sequential Change.

## Forbidden

- Do not move existing worktrees, require branch prefixes, revive Goal/Current repository modes, push, integrate, or remove worktrees in this Change.
- Do not modify plugin code, Unreal tooling, the OpenSpec parser/source submodule, or the packaged executable.
- Do not turn optional Task Card prose into YAML or another machine schema.
- Do not load raw observation history into normal Hardness context or run detailed status from hooks.

## Verification evidence

- Pre-implementation Quick baseline: 130.9 seconds, five checks passed; OpenSpecSkill failed only because this INDEX did not yet exist.
- Final Task 3.1 Quick: 6/6 passed; component durations were Hardness 18,879 ms, gate contract 19,715 ms, Protocol 3,178 ms, workspace 21,927 ms, Git operations 79,913 ms, and OpenSpecSkill 9,434 ms (153,046 ms cumulative).
- Task 3.2 performance: 7/7 scenarios passed in 69,500 ms. Median values were fresh process 698.798 ms, persistent dispatch 35.5112 us/op, task status 47.1618 ms, fast workspace status 275.721 ms, Hardness status 271.2346 ms, detailed workspace status 8,069.8695 ms, and observation write 94.3339 ms.
- Task 3.3 strict active validation: 1/1 valid with zero issues in 6 ms. Strict current-spec validation separately passed 4/4 specs with zero issues.
- Task 3.3 PS7 Quick: 6/6 passed in 95,205 ms wall time; component durations were Hardness 14,968 ms, gate contract 8,799 ms, Protocol 2,506 ms, workspace 18,302 ms, Git operations 44,092 ms, and OpenSpecSkill 6,379 ms.
- Spec sync disposition: all core, workspace, and Git delta requirements are merged into current specs; `hardness/core` metadata and two capability knowledge records are updated and materialized in their intended final `current` state. A separate read-only semantic audit passed.
- Task 4.1 direct-closure policy gate: Protocol PASS, OpenSpec Skill/package PASS, strict active validation 1/1, and strict current-spec validation 4/4 in 7,179.704 ms wall time.
- Total implementation and verification elapsed time through Task 4.1 was 1:42:57 (6,177.238 seconds), from `2026-09-03T16:21:17.5902790+08:00` to `2026-09-03T18:04:14.8278407+08:00`.
- This core gate intentionally excludes Unreal build/Automation/Smoke/Standalone/All/StaticJIT, plugin code, and the separately planned Unreal leaf integration.

## Prepared closure inputs

- Intended closure kind: `completed`, after Task 4.1's focused direct-closure policy gates pass.
- Review disposition: no Review was explicitly requested and no Review record exists; direct archive requires no impact classification, Final Review, or placeholder disposition.
- Durable specs: synchronized before final verification; the direct-closure correction is included in Task 4.1 and will be strictly validated before archive.
- Attachments: six applied Replans, one decision talk, and one compact performance/workflow evaluation; no implementation issue or Review exists.
- Performance provenance: ignored Summary SHA-256 `ce93dc14c6ef1ec3fa26c08dd1096b544d644f22d95f5c95313bdddad383cba6`; ignored Samples SHA-256 `5cdf62717763ade503e5e5d9e7e4092263fabfa29d5c1e1af6f49968941e6e02` with 42 rows.
- Post-verification operations are limited to Task/INDEX bookkeeping, explicit completed closure metadata, deterministic archive movement, strict archived validation, the smallest archive-stability gate, and exact scoped commit. No integration, push, or workspace removal is authorized.

## Attachment index

- `talks/talk-20260903-162117-workspace-core-decisions.md` — accepted topology, authoring, hook, maintenance, and timing decisions with the pre-implementation baseline — read when implementation choices or workflow timing provenance need review.
- `replans/replan-20260903-171057-include-live-workflow-config.md` — applied correction adding the live OpenSpec prompt source to Task 2.1 after verification found stale repository-mode guidance — read when reviewing plan-scope evolution.
- `replans/replan-20260903-171426-cover-all-live-mode-guidance.md` — applied correction covering every live Skill/reference surface found by the pre-edit repository-mode audit — read when reviewing Task 2.1 scope completeness.
- `replans/replan-20260903-172102-complete-live-entry-and-spec-sync-scope.md` — applied correction adding two live README entrypoints and complete durable spec metadata/knowledge sync coverage — read when reviewing final live-surface completeness.
- `replans/replan-20260903-172256-publish-project-hook-config.md` — applied correction allowing only the shared `.codex/hooks.json` through the repository ignore boundary — read when reviewing hook publication safety.
- `replans/replan-20260903-172915-align-performance-entry-and-contract-test.md` — applied correction aligning the public performance output default and scenario-count contract with Task 3.2 — read when reviewing performance evidence ownership.
- `replans/replan-20260903-175249-remove-automatic-final-review.md` — user-directed applied correction replacing automatic Incident/Final Review with explicit-only Review intake and direct verified closure — read when evaluating Review latency or archive policy.
- `data/workflow-evaluation.md` — passed timing, friction, correction, and workflow assessment through Task 3.2, with hashes for ignored raw evidence — read before closure or future Hardness planning.
