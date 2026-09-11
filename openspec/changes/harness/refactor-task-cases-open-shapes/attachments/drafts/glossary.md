# Glossary — harness/cases-expression

Settled names (Rounds 1–3, 2026-09-11). Source for every task's **Interfaces** in the target Change.

| Name | Kind | Decision | Alternatives rejected |
|---|---|---|---|
| `harness/refactor-task-cases-open-shapes` | Change ID | Round 2 Q9 A | `harness/feature-task-case-kinds` (it is a refactor of an existing contract, not a new capability) |
| case header | syntax | `N. **Name** — <role> · <kind>`; `· <kind>` optional; Round 2 Q5 A | `[role] (kind)`; kind on first body line |
| role | standard set + defined custom | standard: `new RED`, `existing control`, `boundary`, `deferred RED until X.Y`; any other word legal when defined in `Roles:`; Round 3 Q10/Q12 A, user 18:22 openness | strictly closed set; `replaces <old>` as a role; `red / green / limit` wording |
| `Roles:` / `Kinds:` | Cases paragraphs | one-line definitions of non-standard role or kind words, after `Setup:`, before the list; user 18:22 | definitions in Notes; no definitions |
| kind | open vocabulary | any `[a-z][a-z-]*` word; recommended catalog: `behavior`, `sequence`, `example-table`, `invariant`, `absence`, `measurement`, `golden`; Round 2 Q2 B, Round 3 Q11 A | closed set with preflight validation; `concurrency` and `manual` catalog entries (not adopted) |
| `Setup:` | Cases paragraph | one unnumbered paragraph before the list; cases say "Given Setup"; Round 2 Q7 A | none allowed; multiple named setups |
| `Replaces:` | Cases body line | prose lineage line inside a case body; Round 2 Q6 A | role value |
| `openspec/references/cases.md` | reference file | `.agents/skills/openspec/references/cases.md`, catalog + header regex + one filled example per kind; Round 2 Q8 A | inline in `tasks.md`; `visual-explain/ascii/` |
| example-table | kind | one clause template with `<placeholders>` plus a table of ≥4 homogeneous rows; Round 1 Q3 A | tables anywhere; tables banned |
| sequence | kind | numbered steps, each `action → observation`; one role and one oracle per case; Round 1 Q4 A | per-step roles; split into cases |
