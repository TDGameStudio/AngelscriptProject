# INDEX

## Current position

All six tasks complete with inline Evidence (2026-09-11; 4.1-4.2 added after draft Rounds 2-4). Carryover confirmed by the user on 2026-09-11 14:41 and materialized as one talk and one knowledge candidate below. Spec sync done 2026-09-11 15:30: the `harness/core` delta (MODIFIED Two-tier exploration, Exploration markers and durable carryover; ADDED Persistent brainstorming drafts, Naming confirmation before implementation) was merged into `openspec/specs/harness/core/spec.md`; the scenario "Scan a question round without changing semantics" was replaced by its renamed successor "Scan a grilling round without changing semantics", and the unspecified scenario "Reject transcript accumulation" was preserved. With user authorization the same edit re-indented pre-existing two-space and detached blockquote detail blocks in unrelated scenarios of that spec (text unchanged) so `openspec.validate harness/core --type spec --strict` passes. Closure: completed. The source discussion lives in `openspec/drafts/harness/brainstorming-drafts/` (git-ignored, local).

Known baselines not owned here: unscoped `OpenSpecSkill.Tests.ps1` English audit and `Protocol.Tests.ps1` closure-v1 archive INDEX audit both fail on pre-existing committed records; see task 3.1 Evidence.

## Hard conclusions

- Drafts persist under `openspec/drafts/`; the Change carries copies of the approved design and handoff only.
- Naming is grilled during brainstorming and task authoring; apply never asks and records `Naming assumed` for review.
- `openspec-create-change` is the only Skill that creates a Change from a designed draft and seeds its attachments.
- Skill name is `brainstorming`; `openspec-brainstorming` is the fallback if the superpowers collision proves harmful.

## Forbidden

- Do not make Harness scan `openspec/drafts/`.
- Do not change `markers.md` or the decision-complete handoff heading set.

## Attachment index

- drafts/design.md — approved design copied from the draft — read before editing any Skill text.
- drafts/handoff.md — decision-complete handoff copied from the draft — read when checking scope or carryover.
- talks/talk-20260911-144100-brainstorming-lifecycle-decisions.md — the three user-owned decisions (draft lifecycle, question-free execution, dedicated create-change Skill) with rejected alternatives and flip conditions — read before proposing to change any of them.
- knowledges/external-skill-concept-mapping.md — candidate: how mattpocock/superpowers concepts were mapped onto project records — read before adapting another external skill.
- `data/workflow-evaluation.md` — terminal harness-workflow-evaluation-v1.
