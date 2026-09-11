# Design — open-shape Cases for heading-node Task Cards

Draft `harness/cases-expression`, Rounds 1–3 on 2026-09-11. Target Change `harness/refactor-task-cases-open-shapes`. Builds on the archived `harness/2026-09-11-refactor-task-cards-heading-nodes` (heading nodes, Form 2 Cases, Skill-side preflight).

## 1. Problem

The archived contract fixes **Cases** as a numbered list of named cases, each with a three-value role tag and one Given / When / Then sentence, tables banned. Real plans already strain it (`attachments/drafts/findings/case-forms-landscape.md`): multi-step lifetimes become 40-word sentences, homogeneous matrices are written as tables against the rule, lineage ("replaces X") and negative compile contracts have no home, measurement gates have no fields, and one plan carries a case that is known to stay red until a later task. The user's upcoming features need all three families at once: lifecycle sequences, homogeneous matrices, and measurement gates.

## 2. Goals and non-goals

Cases become flexible in shape while keeping what the current rule secures: a stable case name, a role that drives grouped RED/GREEN, literal input, an independently derived expected result with a named oracle, and parser neutrality (the Rust CLI still reads none of it).

Not in scope: any `Tools/openspec` parser change or release; enriching other Changes' Cases; changing Files, Verification, the plan header, or the heading-node syntax; a `manual` (human-observed) case kind; a `concurrency` catalog entry (may be added later as an ordinary open kind).

## 3. Shape

```
**Cases**
Setup: <one shared precondition paragraph, optional, unnumbered>     // cases reference it as "Given Setup"

N. **Name** — <role> · <kind>                                       // header: the only line preflight reads; "· kind" optional
   <free Markdown body>                                              // shape follows the kind; must carry literal input,
                                                                     // independently derived expectation, named oracle
   Replaces: <old case name>                                         // optional prose lineage line
```

Header grammar (preflight regex, one per list item):

```
^\d+\. \*\*[^*]+\*\* — (?<role>[^·]+?)( · (?<kind>[a-z][a-z-]*))?\s*$
role ∈ standard set  |  any word defined in a `Roles:` paragraph of the same Cases block
kind ∈ catalog       |  any word defined in a `Kinds:` paragraph of the same Cases block
```

Existing Form 2 cards match unchanged (`— new RED` with no kind suffix).

## 4. Roles (standard set, extensible by definition)

| role | meaning | RED/GREEN behaviour | preflight |
|---|---|---|---|
| `new RED` | behaviour this card adds | written first, observed failing together, green together after implementation | at least one per behaviour card |
| `existing control` | behaviour that already holds and must not break (includes first-time characterization of old behaviour) | green before and after; never counted as RED evidence | — |
| `boundary` | a limit: edge or out-of-scope input, measurement bound | failure means "crossed the line", not "feature missing" | — |
| `deferred RED until X.Y` | test written and observed red in this card, made green by task `X.Y` | red here and recorded; `X.Y` Evidence must cite it turning green | `X.Y` must exist in `task_graph` and be reachable from this card (same plan) |

The four roles above are the standard vocabulary and need no definition. A card may use any other role word, provided the Cases block defines it once in a `Roles:` paragraph (after `Setup:`, before the list) saying what the role means and how RED/GREEN treats it — red first, green throughout, excluded from this card's pass set, or judged as a limit. An undefined non-standard role fails preflight; a defined one is legal and its definition travels with the card. The only fixed requirement stays: at least one `new RED` case per behaviour card. Lineage is the prose `Replaces:` line, not a role.

```markdown
Roles: `quarantined` — runs and is recorded; neither red nor green counts toward this card; re-enabled by 3.2.
```

## 5. Kinds (open, with a recommended catalog)

Any lowercase word is legal. A kind outside the catalog is defined once in a `Kinds:` paragraph (same place as `Roles:`) saying what its body carries and what its oracle is — one line is enough; a catalog kind needs no definition. The catalog in `.agents/skills/openspec/references/cases.md` gives one filled example and the expected body shape for each recommended kind:

| kind | body shape | typical use |
|---|---|---|
| `behavior` (default when omitted) | Given / When / Then, one line or short paragraph | single input, single observation |
| `sequence` | numbered steps, each `action → observation`; one role, one oracle for the whole case | lifetimes, protocols, state across time |
| `example-table` | `Template:` clause with `<placeholders>` then a table of ≥4 homogeneous rows | matrices of small same-shape cases |
| `invariant` | `For all <x> in <named set>: <predicate>`; oracle named (the file or enumeration that defines the set) | inventory reconciliation, exhaustive dispositions |
| `absence` | `Must not exist / must not compile:` symbol list; oracle = the compile or lookup selector | removal Changes, API contracts |
| `measurement` | four fields `Corpus / Metric / Bound / Baseline`; baseline is a checked-in artifact, missing baseline fails | performance gates |
| `golden` | `Input:` + `Expected:` path of a checked-in file, comparison rule (byte / line / normalized) and how to regenerate | diagnostics text, dumps, generated code |

A filled block exercising Setup, behavior, sequence, existing control, example-table, absence and measurement is in `attachments/drafts/findings/example-open-shapes-card.md`; it seeds the examples in `cases.md`.

Rules that hold for every kind: steps and rows are observations, never work items or checkboxes (D4 of the archived design stands); a sequence longer than about eight steps or a case with two oracles is two cases; tables appear only inside `example-table`.

## 6. How TDD consumes the shapes

`test-driven-development` groups by role, not by kind: all `new RED` cases of a card form the group written first and observed red in one run, then one implementation, then green together; `existing control` runs alongside and must stay green; `boundary` is judged as a limit. Kind decides the test's inner shape: a `sequence` is one test with several assertions; an `example-table` is normally one parameterized test whose rows red and green together; a `measurement` is normally a `boundary`, and when it is a card's only `new RED` (a performance card), RED means "currently exceeds the bound"; a `golden` case is red while the expected file is absent or differs; `deferred RED` is observed red here and excluded from this card's GREEN requirement, then cited green by the named later task.

## 7. Contract and Skill changes (owned files)

```diff
 .agents/skills/openspec/references/tasks.md            # Cases rule shrinks to three sentences + link to cases.md; forbidden-phrase list unchanged
+.agents/skills/openspec/references/cases.md            # header grammar, roles table, kind catalog with one filled example each, Setup/Replaces rules, TDD mapping
 .agents/skills/openspec-continue-change/SKILL.md        # plan-acceptance preflight: header regex, ≥1 new RED, non-standard role/kind words defined in Roles:/Kinds:, deferred target exists in graph
 .agents/skills/openspec-apply-change/SKILL.md           # task-start preflight: same; deferred RED excluded from this card's GREEN; later card cites it
 .agents/skills/test-driven-development/SKILL.md         # one paragraph: grouping by role; kind → test shape; deferred RED handling
 .agents/skills/harness/references/execution-conventions.md   # "What counts as PASS": deferred RED cases are excluded from the card's pass set and named in Evidence
 .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1   # tokens for cases.md, new preflight wording, header regex positive/negative fixtures
 .agents/skills/openspec/tests/Authoring.Tests.ps1       # filled example card with all seven kinds parses through the packaged 0.10.0 unchanged (parser neutrality control)
 openspec/config.yaml                                    # rules.tasks Cases sentence
 openspec/workflows/angelscript/templates/tasks.md       # Cases placeholder shows the header form
 openspec/changes/<change>/specs/harness/core/spec.md    # MODIFIED "Ready-to-execute Task authoring": Cases sentence, roles, kinds, Setup, deferred RED
```

No Rust file changes; the packaged `openspec 0.10.0` is the parser-neutrality control. Active `angelscript/*` plans are not edited; the `refactor-sdk-drop-native-gc` tables become legal as-is once their cases gain header lines, which is that Change's decision.

## 8. Verification of the Change

Scoped `OpenSpecSkill.Tests.ps1` (openspec references, continue / apply / TDD Skills, config, template, Change dir); `Authoring.Tests.ps1` filled example through the packaged EXE (strict valid, `files`/`fileRoles` unchanged); `openspec.validate <change> --strict`; spec delta strict; header-regex fixtures: positive (all four roles, with and without kind, `deferred RED until 2.1`), negative (undefined custom role, missing em dash, kind with uppercase, `deferred RED` without target); positive custom: a `Roles:`-defined role and a `Kinds:`-defined kind accepted.

## 9. Vocabulary and naming

See `glossary.md`: Change ID `harness/refactor-task-cases-open-shapes`; file `openspec/references/cases.md`; standard role words `new RED / existing control / boundary / deferred RED until X.Y`, definition paragraphs `Roles:` / `Kinds:` for custom words; catalog kinds `behavior / sequence / example-table / invariant / absence / measurement / golden`; paragraphs `Setup:` and `Replaces:`.

## 10. Self-review

- Openness (user, 18:22): roles and kinds are both extensible; a custom word needs only a one-line definition in the Cases block. Placeholders: none. Contradictions: `deferred RED` vs "GREEN together" resolved in §6 by excluding deferred cases from the card's pass set. Scope: one Change, Skill-side only, no CLI release. Ambiguity: `boundary` wording kept by user decision (Round 3 Q12); the `cases.md` example must make it unambiguous.
