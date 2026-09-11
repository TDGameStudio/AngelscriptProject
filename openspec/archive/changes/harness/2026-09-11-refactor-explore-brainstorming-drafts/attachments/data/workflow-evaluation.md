---
record: harness-workflow-evaluation-v1
result: passed
change: harness/refactor-explore-brainstorming-drafts
closure_kind: completed
input_sha256: 773e04329b657166f53cb171b8a4773adaa7d93450018c7d2bba1cc951d8117f
captured_at: 2026-09-11T07:30:09+00:00
---

# Terminal workflow evaluation

## Lifecycle

- Brainstormed in four grill rounds plus six user directives recorded in the local draft `openspec/drafts/harness/brainstorming-drafts/`; the Change was created from the approved design and handoff.
- Implemented 1.1 (`openspec-explore` → `brainstorming` with grilling, drafts, naming references), 1.2 (naming gate in task authoring and apply), 2.1 (Harness, OpenSpec, and project guidance re-routing), 3.1 (tests and validators).
- Post-handoff corrections 4.1 (question-free execution, `/goal` collapsed to two files, new `openspec-create-change` Skill) and 4.2 (entry modes `research` / `proposal` / `design`, auto-open rule, drafts git-ignored) were added as new task IDs after Rounds 2–4.

## Verification

- `OpenSpecSkill.Tests.ps1` scoped to the owned surfaces exits 0; Skill validator exits 0 for `brainstorming` and `openspec-create-change`.
- `Protocol.Tests.ps1` passes every assertion except the pre-existing closure-v1 archive INDEX compatibility check (4 issues in two September archives), verified through a temporary copy with only that assertion downgraded.
- Strict validation of the Change and of `harness/core --type spec` passes after sync; `git check-ignore` confirms `/openspec/drafts/`.

## Material friction and corrective action

- No Skill owned `change create`; draft carryover was jammed into `openspec-continue-change` step 5. Corrected by the dedicated `openspec-create-change` Skill.
- The English audit repeatedly caught original-language quotations in Change records; policy settled on English paraphrase in talks with the original wording kept only in the draft log.
- Unscoped `OpenSpecSkill.Tests.ps1`, `Protocol.Tests.ps1`, and `openspec.validate --all --strict` fail on unrelated pre-existing records; these baselines are reported, not repaired here.

## Spec and knowledge disposition

The `harness/core` delta was merged into the current spec (two MODIFIED requirements, two ADDED requirements); the same authorized edit re-indented pre-existing detail blocks in unrelated scenarios so the current spec validates strictly. One change-local knowledge candidate (`knowledges/external-skill-concept-mapping.md`) remains `candidate`; no promotion.

## Scope boundary and provenance

Harness Quick, Performance, Integration, and all Unreal operations were omitted: the Change touches only Skills, Markdown, tests, `.gitignore`, and OpenSpec records. Raw round text lives in the git-ignored draft; the Change keeps indexed copies of `design.md` and `handoff.md`, one talk, and one knowledge candidate.
