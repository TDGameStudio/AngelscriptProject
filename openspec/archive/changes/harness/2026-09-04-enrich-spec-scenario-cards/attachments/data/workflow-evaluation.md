---
record: harness-workflow-evaluation-v1
result: passed
change: harness/enrich-spec-scenario-cards
captured_at: 2026-09-04T08:58:16+08:00
---

# Workflow Evaluation

## Lifecycle

- Created the exact parent-repository Change through the packaged OpenSpec route after an accepted decision-complete plan.
- Recorded ignored Harness observation `85c9c9552e4f42c9940e825800b6029b`, then admitted the cross-surface authoring gap to one indexed v2 material issue.
- Built and strictly validated a seven-node Task DAG before implementation.
- Used TDD for the central authoring contract, synchronized four delta specs into current behavior, verified the result, and prepared direct closure without an automatic Review or Replan.
- Total observed lifecycle from pre-Change observation to final evaluation was approximately 22 minutes.

## Durable outcome

- Added `.agents/skills/openspec/references/specs.md` as the central progressive Requirement and Scenario Card contract.
- Updated the spec template, workflow/config prompt, OpenSpec entry/navigation, four lifecycle Skills, and README guidance.
- Retained the `record-v1` validator profile and explained that `record-v1` and `requirements-v1` are profile identifiers rather than content versions.
- Added two Core authoring scenarios and enriched 27 selected existing Harness scenarios.
- Reparented four workspace discovery/status scenarios to their correct Requirement while keeping the two simple cases compact.
- Synchronized current counts are Core `23` Requirements / `64` Scenarios, Workspace `8/24`, Git `5/15`, and Unreal `11/27`, with one `WHEN` and one `THEN` per scenario.

## Verification

| Gate | Result |
|---|---|
| Focused authoring TDD RED | Expected failure: central Scenario Card reference missing; durable capture in `data/scenario-card-red.md` |
| Focused OpenSpec Skill GREEN | PASS |
| Five changed Skill packages through system `quick_validate.py` | 5/5 PASS |
| Independent zero-context compact/complex card authoring evaluation | PASS; no ambiguity or contradiction found |
| Delta-to-current complete-card comparison | 31/31 cards identical; 29 enriched/new plus two compact reparented cards |
| Unnamed current scenario comparison against HEAD | Core 56, Workspace 14, Git 9, Unreal 20 preserved |
| Workspace discovery/status ownership | Four named scenarios occur exactly once under the intended Requirement |
| Long-worktree and installed-build evidence boundaries | PASS; long-worktree card unchanged and two-real-UBT E2E claim explicitly excluded |
| `openspec.doctor` | PASS |
| `openspec.workflow validate angelscript` | PASS; workflow remains version 1 with `record-v1` |
| Strict current specs | 5/5 PASS |
| Strict exact active Change | PASS |
| Strict all current records | PASS |
| Scoped `git diff --check` | PASS; only expected LF-to-CRLF Git notices |
| First Harness Quick | 7/8; correctly rejected the non-durable RED reference |
| Focused Protocol repair gate | PASS after indexing `data/scenario-card-red.md` |
| Final Harness Quick | 8/8 PASS |

## Friction and corrective actions

- Planning exposed that the existing delta dialect has no Scenario-level move operation. The four misplaced workspace cards therefore became one explicit current-spec structural correction with a uniqueness oracle; no implicit `MOVED Scenario` dialect was introduced.
- The first Quick run rejected a session-only RED reference. The exact failure summary was retained under `attachments/data/`, indexed, linked from the issue, and the focused Protocol test passed before the full rerun.
- PowerShell's CRLF line ending required the workflow-profile test regex to accept an optional carriage return. This was an immediate test portability correction and did not change the contract.

## Ownership and exclusions

- Durable reusable guidance is promoted directly into the new central specification reference and current Harness specs; no separate change-local knowledge candidate remains.
- No Review was requested, no planning truth became invalid, and no Replan was created.
- `Tools/openspec`, the packaged executable, release manifest, command docs, manifests, plugins, Unreal code, submodule gitlinks, and UE processes were not changed.
- Fixture evidence for installed-engine concurrency proves policy selection, lane behavior, owned arguments, and path isolation only; it does not prove two real UBT/Unreal builds ran concurrently end to end.

## Raw-data provenance

- Ignored observation: `Saved/Harness/Observations/20260904T003649670Z-85c9c9552e4f42c9940e825800b6029b.json`.
- RED run source chunk: `c47de9`; durable compact copy: `data/scenario-card-red.md`.
- Final Quick source chunk: `b7c873`, reporting `8` passed and `0` failed.

## Terminal assessment

The authoring gap is resolved, durable behavior is synchronized, all required gates pass, and the Change is ready for exact terminal evolution status followed by completed archive.
