# Talk: task nodes become headings, the list format retires, Files is a diff tree

- Captured: 2026-09-11
- Source: brainstorming draft `harness/task-card-format`, Rounds 1–5. The draft is local and git-ignored, so nothing here links to it; the evidence it cites is copied under `attachments/drafts/` (design, handoff, glossary, findings).
- Requested by: user, after finding the active `tasks.md` plans too coarse, oddly formatted, and inconsistently specified, asking to iterate the task workflow with superpowers `writing-plans` as a reference.

## Context

Seven active plans: five in the retired inline format (Ready = 0), two in the current root-checkbox format whose cards were prose-heavy (Cases as sentence chains, 3 numbered steps across 24 tasks, `## Task X.Y` headings duplicated above each checkbox, four-space indentation, 40–60-line preambles). The delegates plan deferred every symbol into a "finish the design" task because it predated the naming gate.

## Evidence

- `Tools/openspec/src/core/task_plan.rs` recognizes only root `- [ ]` list items as nodes and only `**Files**` (list of code spans) and `**Verification**` as machine sections; headings are ignored; unindented body text is an ownership error.
- `harness/core` "Ready-to-execute Task authoring" made non-machine sections optional; the audit shows optional labels degrade into prose.
- `cargo` and `Publish-OpenSpecPackage.ps1` exist; a parser change is a `Tools/openspec` release (`0.9.0` → `0.10.0`).
- `visual-explain/ascii/changes-comparisons.md` already defines the diff-marked file tree.

## Options considered

- Round 1 A: tighten the card inside the existing parser (no machine-surface change). **Overturned in Round 2** — the user's layout requirement (checkbox on the heading, unindented body) is itself a parser change.
- Round 1 B: step-level checkboxes as in writing-plans. Rejected: tracking already covered by numbered lists and Evidence; the user then removed step-level TDD from cards entirely.
- Round 2 Q1: `## [ ] X.Y` (chosen) / `### [ ]` under `##` groups / keep list format. Chosen for one-`##`-per-card outline.
- Round 2 Q2: retire the list format (chosen) / dual-format parser. Rejected dual: second parse path, contradicts the no-compatibility-parser policy.
- Round 2 Q3 → Round 3 Q1 (diff tree): list with `Create:/Modify:/Test:` prefixes, superseded by the per-card ```` ```diff ```` fence as the machine-read Files surface.
- Round 3 Q1: three Changes (CLI / contract / migration) recommended; user chose **one Change**.
- Round 3 Q2: syntax-only migration (chosen) vs enriching the five thin plans in the migration Change. Rejected enrichment: needs each domain's naming round.
- Cases form: table rejected by the user; Form 2 (named cases with Given / When / Then and a role tag) chosen; Form 4 one-line clauses allowed; Form 3 test sketch optional in Notes.

## Settled decisions

| # | Decision |
|---|---|
| D1 | A task node is `## [ ] X.Y Title` / `## [x] X.Y Title`; body unindented until the next `##`/`#`; first paragraph is the brief. |
| D2 | Root-checkbox list nodes retire; `unsupported-task-format` diagnostic names the heading form. No dual parser. |
| D3 | `**Files**` is a diff-marked tree fence: `+` create, space modify, `-` delete, `/`-terminated directory prefixes, ` # ` comments; `files[]` unchanged, `file_roles[]` added. |
| D4 | Task granularity is one stage-level feature outcome; no step-level TDD in the card; `test-driven-development` runs RED/GREEN from Cases. |
| D5 | Mandatory card content for behavior tasks: brief, Outcome, Interfaces (when any symbol), Cases (Form 2), Files, Verification; Notes optional; Evidence after execution. |
| D6 | Plan header: Goal, Architecture, Global constraints, File map (optional), Requirement coverage + self-review line; execution conventions move to `harness/references/execution-conventions.md`. |
| D7 | Forbidden-phrase list and three-item self-review recorded in `attachments/data/planning-validation.md`. |
| D8 | One Change `harness/refactor-task-cards-heading-nodes`; CLI `0.10.0`; migrate all 7 active plans syntax-only; apply preflight blocks thin cards until their Change updates them. |
