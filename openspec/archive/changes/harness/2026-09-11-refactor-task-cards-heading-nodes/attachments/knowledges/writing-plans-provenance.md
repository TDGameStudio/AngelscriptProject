---
disposition: candidate
---

# Knowledge candidate: provenance of the heading-node task contract against superpowers `writing-plans`

Reusable insight: when adapting an external planning guide, compare it idea-by-idea against the project's existing contract; most ideas are present under other names, a few are missing (plan header, interface Consumes/Produces, forbidden-phrase list, three-item self-review, right-sizing rule), and at least one premise (step-level TDD checkboxes, per-step commits) conflicts with the project's grouped RED/GREEN and Git authority and is rejected explicitly.

Evidence: the comparison below, captured 2026-09-11; the source finding is copied at `attachments/drafts/findings/writing-plans-comparison.md`. Direction A there was later overturned (Round 2: the user's layout requirement needs a parser change); see the indexed talk.

Boundaries: describes `Reference/superpowers/skills/writing-plans/SKILL.md` as of the pinned clone; the project contract lives in `.agents/skills/openspec/references/tasks.md`, not here.

Application: read before adapting any other external planning or task-authoring guidance; reuse the adopt / adapt / reject reading of the table.

---
## Idea by idea

| writing-plans idea | Current contract | Gap |
|---|---|---|
| Plan header: Goal (1 sentence), Architecture (2–3), Tech stack, **Spec path**, **Global Constraints** copied verbatim from spec | None. Preamble is free-form "conventions" | Add a fixed header; move conventions out |
| File structure first: map every created/modified file and its single responsibility before drawing tasks | "Build the file, artifact and exclusive-resource map before drawing dependencies" — one sentence, no artifact | Make the map a visible section (table) in the plan |
| **Task right-sizing**: smallest unit with its own test cycle, worth a fresh reviewer's gate; fold setup/docs into the task that needs them; split only where a reviewer could reject one and approve the other | "smallest independently acceptable feature outcome… split when one deliverable can pass acceptance while another is rejected" | Same principle; ours lacks the "own test cycle" and "reviewer gate" test that makes it operational |
| **Bite-sized steps**: each step one action (2–5 min): write failing test / run to see fail / implement minimal / run to see pass / commit — each a checkbox | Numbered lists "preferred" for execution steps; checkboxes forbidden below root; in practice 3 steps in 24 tasks | Make the five-step TDD skeleton mandatory for behavior tasks (as a numbered list, parser-neutral) |
| `**Files:**` with roles: `Create:` / `Modify: path:123-145` / `Test:` | `**Files**` flat list of paths or globs | Add role prefix; discourage `**` globs |
| `**Interfaces:**` Consumes (exact signatures from earlier tasks) / Produces (exact names, params, returns later tasks rely on) | "Context and interfaces" prose; new public names listed with source | Add Consumes/Produces sub-blocks with signatures in a code fence |
| Code blocks required for code steps: the actual failing test, the actual minimal implementation | Code fences allowed, not required | Require the failing-test fence and the interface fence for behavior tasks |
| `Run:` + `Expected:` for every test step (RED shows the expected failure text; GREEN shows PASS) | One proving command per task; RED "observed" is described in prose | Require RED expected-failure line and GREEN expected line under the steps |
| **No placeholders** list: TBD/TODO, "add appropriate error handling", "write tests for the above", "similar to Task N", steps without code, references to undefined types | Semantic authoring check bans "known values", "existing fixtures", "preserve behavior" | Merge into one forbidden-phrase list; make preflight scan for it |
| **Self-review**: spec coverage (every requirement → a task), placeholder scan, type consistency across tasks | "map every requirement and acceptance condition to a task, check IDs, dependencies…" — prose | Make it a three-item checklist recorded in the plan (or INDEX) before tasks are accepted |
| Scope check: multiple subsystems → separate plans | "Keep unrelated outcomes in separate Changes" (harness) | Present |
| Commit per step | Commit per Change with explicit authorization | Keep ours; Git authority is a project rule |
| Execution handoff: subagent-per-task vs inline | `openspec-apply-change`, attended or unattended | Present |

## What to keep from ours that writing-plans lacks

- The DAG frontmatter and Ready/Blocked/Parallel derivation (`task.status`); writing-plans is linear.
- Machine-checked `Files` and `Verification` sections; stable permanent IDs; replan dispositions.
- Evidence appended after execution; no prefilled success.
- Naming gate (`Naming assumed`), grouped RED/GREEN, impact-scoped verification.
- Separation of durable behavior (specs) from execution (tasks).

## Directions

### A. Tighten the card inside the existing parser (recommended)

Keep root-checkbox nodes, DAG frontmatter, `Files` and `Verification` as the machine surface. Change the authoring contract so a **behavior task** must carry, in this order:

1. `**Outcome**` — one paragraph; what is included, what is excluded.
2. `**Files**` — role-prefixed list: `Create:` / `Modify:` (with line range or symbol when known) / `Test:`; globs only with an explicit exclusion sentence. (Parser reads the paths as today.)
3. `**Interfaces**` — `Consumes:` and `Produces:` with signatures in a code fence; every new public name with its glossary source.
4. `**Cases**` — a table of literal input → expected result → role (new RED / existing control / boundary).
5. `**Steps**` — numbered, each one action, following the TDD skeleton: write the failing test (fence with the actual test), run it (command + expected failure text), implement minimal (fence or exact edit description), run it (command + expected pass), refactor/reverify. No checkboxes.
6. `**Verification**` — the one proving command (unchanged).
7. `**Evidence**` — after execution (unchanged).

Plus a fixed **plan header** (Goal / Architecture / Spec / Global constraints / File map table), a single **forbidden-phrase list**, a **three-item self-review** recorded before acceptance, a **right-sizing rule** ("own test cycle + reviewer could reject it alone"), and moving per-Change conventions into `harness/references/` so the preamble is one link. Document-only tasks get a lighter skeleton (Outcome / Files / Steps / Verification).

Cost: rewrite `openspec/references/tasks.md` and its example, update `openspec-continue-change` and `openspec-apply-change`, add preflight tokens to tests, update the `harness/core` "Ready-to-execute Task authoring" requirement. No Rust CLI change.

### B. Adopt writing-plans step checkboxes (parser change)

Allow nested `- [ ]` steps inside a card and track them. Needs the OpenSpec Rust CLI to distinguish node checkboxes from step checkboxes and `task.status` to expose step progress. Larger blast radius (CLI release, package hash, Harness fixtures) for a tracking feature that numbered lists plus Evidence already approximate.

### C. Two documents per task

Keep `tasks.md` as thin nodes; put the writing-plans-style detail in `attachments/plans/<task>.md`. Rejected in principle: splits the execution truth the contract says must live in one file, and the thin node is exactly what the audit shows degrades.

## Migration of the five retired-format plans

Independent of A/B/C. Options: (1) migrate all five to the new card shape in one baseline Change; (2) migrate each when its Change is next touched; (3) abandon stale ones. This is a user decision because it decides which plans stay alive.

## Recommendation

A, with the migration question put to the user. It fixes what the audit shows (prose where code should be, no steps, components instead of test-cycle units) without touching the parser, and it keeps the DAG/Ready machinery that writing-plans does not have.
