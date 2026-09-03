## Why

The Hardness Skill refactor compressed `openspec-explore` and the former authoring-schema guidance too aggressively. The repository retained Task DAG, Review, Replan, and closure structure, but lost the deep pre-Change discovery boundary, zero-context task quality, material implementation issue lifecycle, and capability knowledge indexing. The root README still advertised the incompatible `openspec-work` flow.

Dogfooding exposed the practical consequence: this implementation began from an accepted conversation plan without first registering an active OpenSpec Change. The user caught the missing record before commit. This change repairs the workflow and preserves the deviation honestly instead of fabricating earlier compliance.

A second dogfood observation showed that small follow-up edits were cheap to implement and test but expensive when every expansion immediately launched another broad Review. The user selected three explicit routes: exceptional Incident Review for demonstrated major problems, Final Review after scope freeze only for broad-impact work, and user/agent-started External Review. Small low-impact changes skip Review with an explicit rationale. Reviewer subagents should run asynchronously against immutable snapshots while the coordinator continues disjoint work.

## What Changes

- Restore `openspec-explore` as a deep read-only entry used only before the target Change is created, with progressively loaded exploration and question-round references.
- Restore a reviewed visual-marker vocabulary for exploration and carry accepted decisions, diagrams, and reusable insights into indexed talks and change-local knowledge only after Change creation.
- Keep implementation-time technical exploration inside the Ready task and route invalid planning truth through update/replan.
- Require an active Change checkpoint before Apply; a decision-complete handoff is planning input, not an active record.
- Restore focused task-authoring, material-issue, attachment-routing, and knowledge-promotion contracts without reviving the deleted `openspec-schema` Skill.
- Add protocol tests for active implementation issues, immutable archive indexes, local references, capability knowledge indexes, and stale workflow entry points.
- Replace task-cadence Review with Incident, impact-gated Final, and External routes; define low-impact skip disposition, asynchronous fixed-snapshot execution, truthful lifecycle timestamps, and final-snapshot closure.
- Record this late-Change-registration incident and promote only its reusable checkpoint into Hardness capability knowledge after verification and review.

## Capabilities

### Modified Capabilities

- `hardness/core`: add pre-creation exploration, active Change registration, executable task authoring, issue history, and indexed knowledge requirements.

## Impact

This is a parent-repository Skill, PowerShell test, OpenSpec record/spec, and documentation change. It does not modify plugin submodules, `Tools/openspec`, the packaged executable, UE build behavior, StaticJIT, or Unreal test suites. Existing archives remain immutable and receive compatibility-only audits.

## Non-Goals

- Reintroducing `openspec-work`, the independent `openspec-schema` Skill, legacy Graph/After truth, a global emoji state machine, or a project-level `openspec/knowledges/` tree.
- Copying complete exploration transcripts or treating markers, talks, or knowledge candidates as current execution truth.
- Adding attachment validation to the Rust CLI or publishing another `openspec.exe`.
- Rewriting historical implementation attachments to satisfy the new future-facing issue schema.
- Limiting Review report length or removing detailed findings, evidence, resolution conditions, and re-review history.
- Running UE, StaticJIT, Performance, or Integration gates for this Skill-only change.
