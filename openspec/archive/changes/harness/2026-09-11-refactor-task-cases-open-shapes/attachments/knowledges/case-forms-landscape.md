---
disposition: candidate
---

# Knowledge candidate: matching a test case's expression form to what it must say

Reusable insight: before writing a Cases block, classify each case by what it has to express, then pick the form; a single sentence form (Given / When / Then) fits one input and one observation and strains on everything else. The eight needs seen in real plans and the form that carries each:

| Need | Form that carries it | What the form must still state |
|---|---|---|
| One input, one observation | behavior (Given / When / Then) | literal input, derived expectation |
| Several moments in one test | sequence of `action → observation` steps | one role, one oracle for the whole case |
| Many same-shape rows | example-table: one clause template + table | ≥4 rows, placeholders named in the template |
| Predicate over a set | invariant `For all x in <set>` | the artifact that defines the set (oracle) |
| Something must not exist or compile | absence: symbol list | the compile or lookup selector that proves it |
| Cost must stay within a bound | measurement: Corpus / Metric / Bound / Baseline | a checked-in baseline; missing baseline fails |
| Output must match a stored expectation | golden: input, expected file, comparison rule | how the expected file is regenerated |
| A test known to stay red until later work | role `deferred RED until X.Y` | the later task must cite it turning green |

Two signals that a case is mis-shaped: a sequence longer than about eight steps or with two oracles (it is two cases), and a table whose rows differ in shape (it is a list of behaviors, not an example-table).

## Evidence

- `attachments/drafts/findings/case-forms-landscape.md`: the strain table built from `refactor-bindings-two-stage-pipeline` 1.1 (`Baseline.Reuse`, inventory invariant), `refactor-sdk-drop-native-gc` 1.1/2.1 (tables with lineage, "stay RED until 2.1", `NoPublicCollect`), and the performance plans' threshold needs.
- `attachments/drafts/findings/example-open-shapes-card.md`: the filled block showing each form on one feature.

## Boundaries

Applies to authoring and reviewing Cases in heading-node Task Cards; the parser reads none of it, so the forms are authoring guidance enforced only by Skill preflight (header line, ≥1 `new RED`, defined custom words). It does not prescribe test framework code; `test-driven-development` maps role to grouping and kind to test shape.

## Application

When a card's Cases read as long sentences, tables with mixed rows, or prose saying "this stays red for now", reshape by the table above before implementation; when a needed form is missing, define a custom kind in `Kinds:` rather than bending an existing one.

## Sources

Draft `openspec/drafts/harness/cases-expression/` Rounds 1–3 (2026-09-11); `attachments/drafts/design.md` §5–§6.
