# Open-shape Cases with defined roles and kinds for Task Cards

## Why

The heading-node contract archived this morning fixes `**Cases**` as Form 2: a numbered list of named cases, each with one of three role tags and one Given / When / Then sentence, tables banned. Within hours of migrating the seven active plans the strain is visible (`attachments/drafts/findings/case-forms-landscape.md`): `refactor-sdk-drop-native-gc` writes its cases as tables with a "Replaces X" column and carries a case that must stay red until a later task; `refactor-bindings-two-stage-pipeline` writes a five-step lifetime as one 40-word sentence; negative compile contracts, set invariants and performance bounds have no home. The user's upcoming features need lifecycle sequences, homogeneous matrices and measurement gates at the same time, and asked for a form that stays open: an agent may introduce a role or kind the contract did not foresee, as long as the card says what it is for.

## What Changes

**Case header and definitions.** Each case keeps one header line that Skill preflight reads: `N. **Name** — <role> · <kind>`, the `· <kind>` suffix optional. Standard roles are `new RED`, `existing control`, `boundary` and the new `deferred RED until X.Y` (observed red here, made green by task `X.Y`, which must cite it). Kinds are open with a recommended catalog of seven: `behavior`, `sequence`, `example-table`, `invariant`, `absence`, `measurement`, `golden`. A non-standard role or kind is legal when the Cases block defines it once in a `Roles:` / `Kinds:` paragraph — what it means and how RED/GREEN treats it, or what the body carries and its oracle; an undefined word fails preflight. One optional `Setup:` paragraph shares a precondition; `Replaces:` is a prose lineage line. Tables return only inside `example-table` (one clause template plus ≥4 homogeneous rows). Sequence steps are `action → observation`, one role and one oracle per case; the no-step-level-TDD rule stands. The only fixed requirement remains at least one `new RED` per behavior card. Existing Form 2 cards match the grammar unchanged.

**Catalog file.** New `.agents/skills/openspec/references/cases.md` owns the header grammar, the roles table, the kind catalog with one filled example each (seeded from `attachments/drafts/findings/example-open-shapes-card.md`), the `Setup:` / `Roles:` / `Kinds:` / `Replaces:` rules and the role-to-grouping / kind-to-test-shape mapping. `tasks.md`'s Cases rule shrinks to three sentences and a link; `openspec/config.yaml` rules.tasks and the `angelscript` workflow template follow.

**Preflight and TDD wording.** `openspec-continue-change` (plan acceptance) and `openspec-apply-change` (task start) check the header grammar, the `new RED` count, that every non-standard word is defined, and that a `deferred RED` target exists in `task_graph`. `test-driven-development` groups by role and shapes tests by kind; `deferred RED` is excluded from the card's GREEN set and cited green by the later task. `execution-conventions.md` "What counts as PASS" names the exclusion.

**Specification.** `harness/core` MODIFIED "Ready-to-execute Task authoring": the Cases sentence and the preflight sentence.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: "Ready-to-execute Task authoring" — Cases carry a fixed header with role and optional kind, standard roles include `deferred RED until X.Y`, custom roles and kinds are legal when defined in the block, `Setup:` and `Replaces:` paragraphs exist, tables are allowed only inside `example-table`; preflight checks header grammar, `new RED` count, definitions and deferred targets.

## Impact

Owned paths: `.agents/skills/openspec/references/tasks.md`, `.agents/skills/openspec/references/cases.md` (new), `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/test-driven-development/SKILL.md`, `.agents/skills/harness/references/execution-conventions.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/openspec/tests/Authoring.Tests.ps1`, `openspec/config.yaml`, `openspec/workflows/angelscript/templates/tasks.md`, `openspec/specs/harness/core/spec.md` (via sync). Parent repository only; `Tools/openspec` is not touched and the packaged `openspec 0.10.0` serves as the parser-neutrality control.

Non-goals: any parser or CLI release; editing other Changes' Cases (the `refactor-sdk-drop-native-gc` tables become legal once that Change adds header lines — its decision); a `manual` kind; a `concurrency` catalog entry; changes to Files, Verification, the plan header or the heading-node syntax; any Git commit without explicit user authorization.
