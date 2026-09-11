# Talk: open-shape Cases with defined roles and kinds

Captured 2026-09-11 18:27 from draft `openspec/drafts/harness/cases-expression/` (Rounds 1–4 and the user's openness correction at 18:22). Paraphrased; the original wording is in the draft `log.md`.

## Context

The archived `harness/2026-09-11-refactor-task-cards-heading-nodes` fixed Cases as Form 2: numbered named cases, a three-value role tag, one Given / When / Then sentence, tables banned. Within hours of migrating the seven active plans, the strain was visible: `refactor-sdk-drop-native-gc` uses tables with a "Replaces X" column and carries a case that must stay red until a later task; `refactor-bindings-two-stage-pipeline` writes a five-step lifetime as one 40-word sentence. The user's upcoming features need lifecycle sequences, homogeneous matrices and measurement gates at the same time.

## Evidence

- `attachments/drafts/findings/case-forms-landscape.md`: eight expression needs observed in active plans against ten available forms, with where Form 2 strains.
- `attachments/drafts/findings/example-open-shapes-card.md`: one filled Cases block exercising Setup, behavior, sequence, existing control, example-table, absence and measurement.
- The Rust parser reads no Cases content; only Skill preflight does. Any shape change is Skill-side and needs no CLI release.

## Options

- Round 1 Q2 flexibility: closed typed kinds with preflight validation (agent recommendation) vs open kinds with free Markdown (chosen) vs merely relaxing Form 2.
- Round 1 Q3 tables: back only as an `example-table` kind for ≥4 homogeneous rows (chosen) vs still banned vs anywhere.
- Round 1 Q4 sequences vs the no-step-level-TDD rule: allowed as `action → observation` steps with one role and one oracle (chosen) vs split into cases vs per-step roles.
- Round 2: header `N. **Name** — <role> · <kind>` vs bracket forms; lineage as a prose `Replaces:` line vs a fourth role; one `Setup:` paragraph vs none vs several; catalog in a new `cases.md` vs inline; Change named as a refactor vs a feature; active plans untouched vs patched.
- Round 3: add `deferred RED until X.Y` (chosen) vs move such cases to the later card vs let `boundary` absorb them; catalog additions `golden` (chosen), `concurrency` (not adopted), `manual` (rejected); keep the English role words (chosen).
- 18:22 correction: the agent had written roles as a closed set; the user asked for openness — a custom role or kind is fine if the card says what it is for. Roles became standard-plus-defined rather than closed.

## Settled decision

Cases keep one numbered list with a fixed header line `N. **Name** — <role> · <kind>` that preflight reads. Standard roles: `new RED`, `existing control`, `boundary`, `deferred RED until X.Y`. Kinds are open with a recommended catalog (`behavior`, `sequence`, `example-table`, `invariant`, `absence`, `measurement`, `golden`). Any non-standard role or kind is legal when defined once in a `Roles:` / `Kinds:` paragraph of the same Cases block; an undefined word fails preflight. `Setup:` is one optional shared paragraph; `Replaces:` is a prose lineage line. Tables appear only inside `example-table`. The only fixed requirement remains at least one `new RED` per behavior card. No parser change; active plans are not edited.

## Consequences

TDD groups by role and shapes tests by kind; a `deferred RED` case is observed red in its card, excluded from that card's pass set, and cited green by the later task. Existing Form 2 cards match the new header grammar unchanged. Vocabulary can grow from usage: a custom role that recurs is promoted to the standard set instead of the set being closed.

## Flip condition

If defined custom roles proliferate until TDD grouping becomes ambiguous, promote the common ones to the standard set; do not reintroduce a closed vocabulary. If tables reappear outside `example-table` and hurt diff review, tighten the example-table rule rather than banning tables again.

## Sources

- Draft `openspec/drafts/harness/cases-expression/log.md`: Round 1 (18:12), Round 2 (18:12), Round 3 (18:19), openness correction (18:22), Round 4 carryover (18:26).
- `attachments/drafts/design.md`, `attachments/drafts/glossary.md`.
