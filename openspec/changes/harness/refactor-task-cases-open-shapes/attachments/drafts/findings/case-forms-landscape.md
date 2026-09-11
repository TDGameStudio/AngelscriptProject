# Case forms: what the current contract fixes, what real plans try to say, and the forms available

Captured 2026-09-11 18:10. Sources: `.agents/skills/openspec/references/tasks.md` (Cases rule, line 39), talk `talk-20260911-171700-heading-node-task-cards.md` (Form 1–4 decision), `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/tasks.md`, `refactor-sdk-drop-native-gc/tasks.md`, `feature-frontend-diagnostics-tooling/tasks.md`.

## What the current rule fixes (Form 2)

```
**Cases**                                      // one numbered list, one entry per case
└─ N. **Name** — <role tag>                    // role ∈ new RED | existing control | boundary
   └─ Given <literal input> When <action> Then <independently derived result>
                                               // one-line clause list allowed when every case fits; tables not used;
                                               // oracle named when a count/invariant is asserted; ≥1 new RED per behavior card
```

Properties it secures, and which the upgrade must keep:

- P1 a case has a stable name that Evidence and test code can cite;
- P2 a case has a role so TDD knows what must be RED first and what is a control;
- P3 input and expected result are literal, not "known values";
- P4 the expected result is derived independently of the implementation (oracle named);
- P5 the list is parser-neutral: the Rust CLI does not read Cases; only Skill preflight checks presence and one `new RED`.

## What real plans try to express (and where Form 2 strains)

| Need | Example in an active plan | Form 2 fit |
|---|---|---|
| Multi-step sequence with intermediate assertions | bindings 1.1 `Baseline.Reuse`: record → prepare → create two owners → release one → invoke survivor → record post-SDK base | one Given/When/Then sentence gets long; no place for the intermediate state |
| Input × expected matrix over many small cases | sdk-drop 1.1: 8 cases, each one input, one expected, one role | list works but scans badly; the plan already uses a table (against the current rule) |
| Lineage: "replaces X" / "existing Y without collect" | sdk-drop `UnrootedSelfCycleLeaks` role column | role tag has only three values; lineage lands in prose |
| Negative compile-time contract | sdk-drop 2.1 `NoPublicCollect`: symbols must not exist | Given/When/Then reads oddly for "does not compile" |
| Invariant over a set | bindings 1.1 "every inventory site has one of five dispositions" | not a single input; needs the oracle named (the inventory file) |
| State/lifecycle across time | `WeakFlagFollowsRelease`: valid while live, invalid after last release | two Then clauses at two moments |
| Threshold or measurement | performance plans: p95 under N ms on a fixed corpus | needs the corpus, the metric, the bound, the comparison baseline |
| Shared setup across cases | bindings: same fixture host for every case | repeated Given text or an implicit reference |

## Forms available (landscape)

1. **Form 2 (current)** — numbered named cases, role tag, Given/When/Then. Best for: 2–8 behavior cases with distinct inputs.
2. **Decision table / example table** — Gherkin `Scenario Outline` + `Examples`: one clause template with placeholders, a table of rows. Best for: many rows, same shape. Cost: tables were rejected in Round 5 for readability in chat and diff noise; the parser ignores them anyway.
3. **Sequence case** — a numbered step list inside one case, each step `do → observe`. Best for: lifecycle or protocol flows. Cost: a step list looks like the step-level TDD script the contract forbids; needs a rule that steps are observations, not work items.
4. **Given-block with shared setup** — a `Setup` paragraph once per card, cases reference it. Best for: fixture-heavy suites. Cost: implicit dependency; case no longer self-contained.
5. **Assertion sketch (Form 3 from Round 5)** — a fenced test skeleton (`TEST_METHOD(...) { ...; ASSERT_THAT(...) }`) per case. Best for: exact API shape and oracle. Cost: drifts into implementation; was made optional under Notes.
6. **State table / transition list** — `state --event--> state (assert)` lines. Best for: lifecycle features (VM object lifetime, GC-less release). Fits the project no-box tree style.
7. **Property / invariant case** — `For all X in <set>: <predicate>`, oracle named. Best for: inventory reconciliation, exhaustive dispositions.
8. **Contract-absence case** — `Must not exist / must not compile: <symbols>`, with the compile selector as oracle. Best for: removal Changes.
9. **Measurement case** — `Corpus / Metric / Bound / Baseline` four fields. Best for: performance gates.
10. **Typed case kinds** — keep one list but let each case declare its kind (`behavior`, `sequence`, `invariant`, `absence`, `measurement`, `example-table`) and give each kind a fixed micro-shape. Best for: flexibility without a free-form section. Cost: more vocabulary to learn; preflight must know the kinds.

## Constraints from the archived design that still bind

- Cases stay outside the machine surface: no Rust parser change is required for any of the forms above (P5). A form that needs machine reading becomes a `Tools/openspec` release.
- No step-level TDD scripts in a card (D4); a sequence case must be phrased as observations.
- No size quotas; labels are information requirements.
- Chat rendering: four-space indented option lines render as code; tables render fine in the IDE but were rejected for chat and diff readability (Round 5).

## Conclusions / Open

- The strain is real and already visible: one active plan uses a table, another writes 40-word sentences, and lineage/absence/measurement have no home.
- The safest direction is 10 (typed case kinds) built from 1, 3, 6, 7, 8, 9, with 2 (example table) allowed as a kind only if the user reverses the Round 5 table decision.
- Open: which feature drives the request; whether the user wants tables back; whether sequence steps are acceptable given D4; whether case kinds should be enumerated (closed set) or free (any bold kind word).
