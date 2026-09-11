---
record: harness-workflow-evaluation-v1
result: passed
change: harness/refactor-code-review-single-skill
closure_kind: completed
input_sha256: 5ef56fad93b809a74294e64a67bde61eea26cc25039e1588750b269752cb02f1
captured_at: 2026-09-11T08:04:11+00:00
---

# Terminal workflow evaluation

## Lifecycle

- Brainstormed as a `research` draft (inventory, superpowers comparison, 18 candidate rules), upgraded to `design` on the user's decision; Round 1 settled directory shape, name, rule scope, and delivery; carryover round confirmed one talk and one knowledge candidate.
- `openspec-create-change` created the Change and seeded `attachments/drafts`, `talks`, `knowledges`, `INDEX`; `openspec-continue-change` wrote proposal, `harness/core` delta, and a three-node Task DAG.
- Implemented 1.1 (single `code-review` Skill, retired directories removed, routing/README updated), 1.2 (coordinator conduct and re-review/fan-out in `review.md`), 2.1 (test assertions).

## Verification

- Grouped RED observed with the new assertions before 1.1/1.2; GREEN after: scoped `OpenSpecSkill.Tests.ps1` exit 0, `Protocol.Tests.ps1` temp copy PASS, Skill validator exit 0, strict Change validation and strict `harness/core` spec validation Succeeded after sync.

## Material friction and corrective action

- The `/goal` test had special-cased the `code-review` directory to skip the disabled superpowers files; removing the exclusion is part of the fix rather than a separate issue.
- No material issue admitted.

## Spec and knowledge disposition

MODIFIED requirement merged into the current `harness/core` spec with four new scenarios. Knowledge candidate `review-rule-provenance.md` remains `candidate`; no promotion.

## Scope boundary and provenance

Harness Quick, Performance, Integration, and Unreal operations omitted: the Change touches only Skills, a Harness reference, tests, and OpenSpec records. Round text lives in the git-ignored draft `openspec/drafts/harness/code-review-skills/`.