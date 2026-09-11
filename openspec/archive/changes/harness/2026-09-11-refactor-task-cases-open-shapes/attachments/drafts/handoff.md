# Handoff

Draft `harness/cases-expression`; design approved 2026-09-11 18:24; carryover confirmed 18:26 (Round 4: C1 + C2).

## Problem

Form 2 Cases (one Given / When / Then sentence per named case, three role values, tables banned) cannot express lifecycle sequences, homogeneous matrices, lineage, negative compile contracts, measurement gates, or a case known to stay red until a later task. Active plans already violate the rule to say these things.

## Success Criteria

A card can carry any of those shapes and still pass Skill preflight; every case keeps a stable name, a role that drives grouped RED/GREEN, literal input, an independently derived expectation with a named oracle; the Rust parser and `files`/`fileRoles` projection are unchanged; existing Form 2 cards need no edit.

## Evidence

`attachments/drafts/findings/case-forms-landscape.md` (needs × forms, strain table); `attachments/drafts/findings/example-open-shapes-card.md` (filled block); `refactor-sdk-drop-native-gc` tables and "stay RED until 2.1" sentence; `refactor-bindings-two-stage-pipeline` 1.1 `Baseline.Reuse`.

## Scope and Exclusions

Skill-side contract and preflight only. Excluded: parser or CLI release; editing other Changes' Cases; `manual` kind; `concurrency` catalog entry; changes to Files, Verification, header sections, heading-node syntax.

## Constraints

Cases stay outside the machine surface (P5); no step-level TDD scripts (D4 of the archived design); no size quotas; records in English; drafts never referenced from the Change.

## Options, Decision and Rationale, Flip Condition

See `design.md` §3–§6 and the Round 1–4 log. Key decisions: header `N. **Name** — <role> · <kind>`; standard roles `new RED / existing control / boundary / deferred RED until X.Y`, custom roles and kinds legal when defined once in `Roles:` / `Kinds:`; open kind catalog of seven; tables only inside `example-table`; `Setup:` paragraph; `Replaces:` prose line. Flip: if defined custom roles proliferate to the point TDD grouping becomes ambiguous, promote the common ones to the standard set rather than closing the vocabulary.

## Architecture, Components, and Data Flow

Parser (unchanged) → Skill preflight reads case headers and definition paragraphs → TDD groups by role, shapes tests by kind → Evidence cites case names and, for deferred RED, the later task cites the case turning green. Catalog and grammar live in `.agents/skills/openspec/references/cases.md`; `tasks.md` links it.

## Failures and Edge Cases

Undefined custom role or kind → preflight failure naming the word. `deferred RED until X.Y` with missing or unreachable `X.Y` → preflight failure. Sequence > ~8 steps or two oracles → authoring smell, split. Measurement with no checked-in baseline → the case fails rather than measuring against nothing.

## Verification

Scoped `OpenSpecSkill.Tests.ps1`; `Authoring.Tests.ps1` filled example through packaged `openspec 0.10.0` (parser-neutrality control); `openspec.validate <change> --strict`; header-grammar positive/negative fixtures incl. custom-defined words; spec delta strict; `harness/core --type spec --strict` after sync.

## OpenSpec Handoff

- Target Change: `harness/refactor-task-cases-open-shapes`
- Title: Open-shape Cases with defined roles and kinds for Task Cards
- Design: `design.md` (approved 2026-09-11 18:24)
- Requirement changes: MODIFIED `harness/core` "Ready-to-execute Task authoring" (Cases sentence: header form, standard roles incl. deferred RED, definable custom roles/kinds, Setup, example-table, no step-level TDD retained). No new requirement.
- Files owned: `.agents/skills/openspec/references/tasks.md`, new `.agents/skills/openspec/references/cases.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-apply-change/SKILL.md`, `.agents/skills/test-driven-development/SKILL.md`, `.agents/skills/harness/references/execution-conventions.md`, `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `.agents/skills/openspec/tests/Authoring.Tests.ps1`, `openspec/config.yaml` rules.tasks, `openspec/workflows/angelscript/templates/tasks.md`, `openspec/specs/harness/core/spec.md` (via sync).
- Task boundaries: (1) contract + catalog (`cases.md`, `tasks.md`, config, template) with Authoring example; (2) preflight + TDD + execution-conventions wording with Skill tests; (3) planning-validation record and final strict validation.
- Sequencing: 1 before 2 (tests cite the catalog); 3 last.

## Exploration Carryover

Confirmed 2026-09-11 18:26 (Round 4).

- Talk candidate: `log.md` Rounds 1–3 and the 18:22 openness correction → `talks/talk-<ts>-open-shape-cases.md` — open kinds vs closed set, tables only inside example-table, sequence under D4, deferred RED as a standard role, roles extensible by definition; rationale would otherwise be re-decided.
- Knowledge candidate: `attachments/drafts/findings/case-forms-landscape.md` → `knowledges/case-forms-landscape.md` (candidate) — needs observed in real plans against available case forms; reusable when authoring or reviewing Cases.
- Copied by citation (not a talk or knowledge): `attachments/drafts/findings/example-open-shapes-card.md`, cited by `design.md` §5 → `attachments/drafts/findings/`.
- Discard: round navigation; `findings/` files not cited above.
