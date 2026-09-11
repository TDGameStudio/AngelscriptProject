# Deep Exploration and Handoff

Load this reference only before creating the target OpenSpec Change. Be curious, grounded, adaptive, and opinionated when evidence supports a recommendation. The objective is a decision-complete engineering handoff written to the draft's `handoff.md`; the round-by-round diary belongs in the draft `log.md`, not in the handoff.

## 1. Classify the opening

Identify the dominant shape before gathering detail:

- **Vague idea** — discover the real problem, users, and success condition.
- **Specific problem** — prove current behavior and locate the boundary that owns it.
- **Choice** — identify the criteria that can distinguish viable options and settle scope or architecture before durable planning begins.

## 2. Establish facts before questions

Inspect only evidence that can change the decision: relevant code and tests, current OpenSpec artifacts, attachment INDEX entries, documentation, and recent commits. Separate observed facts, strong inferences, assumptions, and user-owned product choices. Do not ask the user to supply facts available in the repository.

## 3. Shape the scope

- State the problem and measurable success criteria.
- Decompose independent systems before discussing implementation detail.
- Map architecture, integration points, existing patterns, ownership boundaries, and hidden complexity.
- Name exclusions, compatibility constraints, migrations, operational limits, and failure modes.
- Reduce scope with YAGNI: keep only behavior needed to satisfy the success criteria.

## 4. Compare viable options

Compare two or three genuinely viable options when a choice exists. Use the smallest deciding view: concise prose, a compact table, or a small diagram only when it materially reduces ambiguity. Evaluate behavior, fit with existing architecture, complexity, migration, verification, and failure containment.

Give one recommendation with:

- the evidence-backed reason;
- the important tradeoff being accepted;
- the assumption or new evidence that would flip the choice;
- remaining risks, unknowns, or a bounded spike needed to settle them.

Do not manufacture alternatives after one option is already forced by requirements and repository evidence.

Use the optional [marker vocabulary](markers.md), compact Markdown tables, and small text diagrams when they materially reduce ambiguity. Visuals must remain understandable in plain text and must not introduce an independent state model.

## 5. Converge

Resolve blocking engineering decisions before Change creation. Non-blocking assumptions and explicit out-of-scope questions may remain. Every unconfirmed user-owned choice, including naming, is asked through [grilling.md](grilling.md) rounds with the user present; the handoff is not decision-complete while any such choice is open.

## Decision-complete handoff

Write `openspec/drafts/<domain>/<topic>/handoff.md` with these headings when applicable. Its first line names the source draft and acceptance date.

```text
Draft
Problem
Success Criteria
Evidence
Scope and Exclusions
Constraints
Options
Decision and Rationale
Flip Condition
Architecture, Components, and Data Flow
Failures and Edge Cases
Verification
OpenSpec Handoff
Exploration Carryover
```

`OpenSpec Handoff` identifies the likely domain/change identity, affected or new capabilities, required artifacts, and independently reviewable task boundaries. It is input to Change creation, not an OpenSpec artifact by itself.

`Exploration Carryover` lists the material the user confirmed in the carryover round, without writing it into the Change yet. Each talk or knowledge entry names its source in the draft, its target, and the reason:

```text
Canonical truth  -> proposal/spec/design/tasks
Draft copy       -> design.md and handoff.md -> attachments/drafts/ (indexed once)
Talk candidate   -> `log.md` Round 2 Q1-Q3 (draft lifecycle) -> talks/ -> rationale would otherwise be re-decided
Knowledge candidate -> `findings/external-references.md` -> knowledges/ -> reusable mapping beyond this Change
Discard          -> temporary round navigation, redundant or one-off visuals (the draft log already keeps the conversation)
```

After acceptance, `openspec-create-change` creates the target Change, copies the draft design and handoff, and materializes exactly the confirmed talks and knowledge candidates; `openspec-continue-change` then writes the planning artifacts. The draft remains the owner of the conversation; the Change never becomes a parallel transcript.
