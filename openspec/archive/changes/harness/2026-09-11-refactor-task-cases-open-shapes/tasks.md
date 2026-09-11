---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
---

# Open-shape Cases with defined roles and kinds for Task Cards

## Goal

A heading-node Task Card can express lifecycle sequences, homogeneous matrices, set invariants, absence contracts, measurement bounds, golden comparisons and deferred-red cases in its `**Cases**` block, and an agent may add a role or kind the catalog did not foresee by defining it once — while preflight still reads one fixed header line per case and the Rust parser reads nothing.

## Architecture

Cases stay outside the machine surface: the packaged `openspec 0.10.0` projects `files` / `fileRoles` / `after` / `ready` exactly as before and is the parser-neutrality control. A new reference `.agents/skills/openspec/references/cases.md` owns the header grammar, standard roles, kind catalog with examples, `Setup:` / `Roles:` / `Kinds:` / `Replaces:` rules and the role→grouping / kind→test-shape mapping; `tasks.md` links it. `openspec-continue-change`, `openspec-apply-change`, `test-driven-development` and `execution-conventions.md` gain the preflight and grouping sentences. See `design.md`.

## Global constraints

- No change under `Tools/openspec/**`; no CLI release; `.agents/skills/openspec/bin/openspec.exe` stays `0.10.0`.
- Do not edit other Changes' `tasks.md`; `refactor-sdk-drop-native-gc` tables become legal only when that Change adds header lines.
- Existing Form 2 headers (`N. **Name** — new RED`) must keep matching the grammar with no edit.
- The only fixed Cases requirement is at least one `new RED` per behavior card; no size quotas.
- Records are English; no Change file references `openspec/drafts/`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| `harness/core` Ready-to-execute Task authoring — case header, standard roles incl. `deferred RED until X.Y`, catalog kinds, `Setup:` / `Replaces:`, tables only in `example-table`, sequence steps as observations | 1.1 |
| Same — defined custom roles/kinds, preflight (grammar, `new RED` count, definitions, deferred target), TDD grouping by role / shaping by kind, deferred exclusion from GREEN | 2.1 |
| Same — planning self-review record; strict validation of this Change | 3.1 |

Self-review 2026-09-11: coverage complete for the one MODIFIED requirement; placeholders none; symbols consistent with `design.md` and `attachments/drafts/glossary.md`. Record: `attachments/data/planning-validation.md`.

## 1. Contract and catalog

## [x] 1.1 Publish the case grammar and kind catalog

The Cases rule moves out of `tasks.md` into a dedicated `cases.md` that shows every recommended shape once, and the config rule and workflow template point at the new header form. Nothing changes for a Form 2 card.

**Outcome**

`.agents/skills/openspec/references/cases.md` exists with: the header grammar and its regex; the standard roles table (`new RED`, `existing control`, `boundary`, `deferred RED until X.Y`) with RED/GREEN behaviour per role; the seven-kind catalog (`behavior`, `sequence`, `example-table`, `invariant`, `absence`, `measurement`, `golden`) each with body shape and one filled example lifted from `attachments/drafts/findings/example-open-shapes-card.md`; `Setup:`, `Roles:`, `Kinds:`, `Replaces:` rules; the mis-shape signals (sequence > ~8 steps or two oracles; heterogeneous table rows). `tasks.md` item 4 shrinks to: header line, body requirements, link to `cases.md`, ≥1 `new RED`; its filled example gains one `· sequence` case so the reference demonstrates the suffix. `openspec/config.yaml` rules.tasks line 27 says "Cases (one header line `N. **Name** — role · kind` per case, standard roles or defined custom words, at least one new RED; shapes per cases.md)" instead of "named cases with a role tag and Given/When/Then … no tables". The `angelscript` template's Cases placeholder shows the header form with and without `· kind`. Excluded: preflight wording (2.1), spec sync.

**Interfaces**

Consumes:

```text
.agents/skills/openspec/references/tasks.md:39      // item 4 "**Cases** — a numbered list of named cases ... Tables are not used."
.agents/skills/openspec/references/tasks.md:124-156 // filled example card (Declaration policy) with six Form 2 cases
openspec/config.yaml:27                              // rules.tasks sentence naming Cases
openspec/workflows/angelscript/templates/tasks.md:60 // **Cases** placeholder
attachments/drafts/findings/example-open-shapes-card.md // seed block
```

Produces:

```text
.agents/skills/openspec/references/cases.md          // file name: glossary "openspec/references/cases.md"
header regex: ^\d+\. \*\*[^*]+\*\* — (?<role>[^·]+?)( · (?<kind>[a-z][a-z-]*))?\s*$   // glossary "case header"
paragraph labels: Setup: | Roles: | Kinds: | Replaces:   // glossary
```

**Cases**

1. **Catalog tokens present** — new RED · behavior
   Given `OpenSpecSkill.Tests.ps1` extended with a token loop over `cases.md` (`deferred RED until`, `Roles:`, `Kinds:`, `example-table`, `golden`, `action → observation`, the regex text) When run before this task's edits Then it fails on the missing file; after Then every token is found.
2. **Retired wording absent** — new RED · behavior
   Given the same run Then `tasks.md` and `config.yaml` no longer contain `Tables are not used` or `no tables`, and `tasks.md` links `cases.md`.
3. **Form 2 header still matches** — existing control · example-table
   Template: Given header `<header>` When matched against the regex Then role `<role>`, kind `<kind>`.

   | header | role | kind |
   |---|---|---|
   | `1. **RejectGcFlag** — new RED` | `new RED` | (none) |
   | `2. **Baseline.Reuse** — new RED · sequence` | `new RED` | `sequence` |
   | `3. **LastRelease** — existing control` | `existing control` | (none) |
   | `4. **Leftovers** — deferred RED until 2.1` | `deferred RED until 2.1` | (none) |
   | `5. **Handshake** — quarantined · protocol` | `quarantined` | `protocol` |
4. **Malformed headers rejected** — boundary · example-table
   Template: Given header `<header>` Then the regex does not match.

   | header |
   |---|
   | `1. **Name** new RED` (no em dash) |
   | `1. **Name** — new RED · Sequence` (uppercase kind) |
   | `1. Name — new RED` (name not bold) |
   | `- **Name** — new RED` (list bullet, not numbered) |
5. **Parser neutrality** — existing control · behavior
   Given the `tasks.md` filled example with the added `· sequence` case When `Authoring.Tests.ps1` runs it through the packaged `openspec.exe` Then strict valid, `files` = `src/options.rs`, `tests/option_policy.rs`, `fileRoles` unchanged.

**Files**

```diff
+.agents/skills/openspec/references/cases.md
 .agents/skills/openspec/references/tasks.md
 .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1
 .agents/skills/openspec/tests/Authoring.Tests.ps1
 openspec/config.yaml
 openspec/workflows/angelscript/templates/tasks.md
```

**Verification**

Run from the workspace root in PowerShell 7.

```powershell
& pwsh -NoProfile -Command { param($p) & './.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1' -SurfacePaths $p } -args (,@('.agents/skills/openspec', 'openspec/config.yaml', 'openspec/workflows/angelscript/templates/tasks.md'))
```

Exit 0; `Authoring tests passed`; the header-regex fixtures (cases 3–4) are asserted inside the suite.

**Evidence**

2026-09-11 18:40–18:46. RED: scoped `OpenSpecSkill.Tests.ps1` with the new catalog/header assertions → exit 1, `Case catalog reference cases.md is missing` (case 1 observed). GREEN: after writing `cases.md`, shrinking `tasks.md` item 4, adding example case 7 (`— new RED · sequence`), updating `config.yaml` rules.tasks and the template placeholder → exit 0, `OpenSpec skill package tests passed`; header fixtures (cases 3–4) asserted inside the suite; `Authoring tests passed` confirms the seven-case example still projects `files`/`fileRoles` unchanged through the packaged `openspec 0.10.0` (case 5). Two stale expectations repaired in the same run: the old token loop required `Tables are not used` (replaced by `[case catalog](cases.md)`) and `Given / When / Then` (kept by stating a plain case is one Given / When / Then clause). A `.Replace` also hit my own negative list; restored.

## 2. Preflight and TDD

## [x] 2.1 Teach preflight and TDD the header, definitions and deferred RED

The lifecycle Skills check the header grammar and definitions instead of "a role tag and Given/When/Then"; TDD groups by role and shapes by kind; a deferred case is excluded from its card's GREEN set.

**Outcome**

`openspec-continue-change` plan-acceptance preflight and `openspec-apply-change` task-start preflight both state: every case header matches the grammar in `cases.md`; at least one `new RED`; every role or kind word outside the standard set / catalog is defined in `Roles:` / `Kinds:` of the same block; every `deferred RED until X.Y` names an `X.Y` present in `task_graph`; a table appears only inside an `example-table` case. Apply adds: a `deferred RED` case is observed red and excluded from this card's GREEN requirement; the target task's Evidence must cite it green. `test-driven-development` gains one paragraph: group by role, shape by kind (sequence = one test, example-table = one parameterized test whose rows red/green together, measurement normally a boundary against a checked-in baseline, golden red while the expected file is absent or differs), custom roles follow their definition. `execution-conventions.md` "What counts as PASS" adds the deferred exclusion sentence. Excluded: any new test runner; edits to other Changes.

**Interfaces**

Consumes:

```text
.agents/skills/openspec-continue-change/SKILL.md:15   // "every behavior card has at least one case tagged `new RED` and an Interfaces code fence"
.agents/skills/openspec-apply-change/SKILL.md:11      // task-start preflight sentence
.agents/skills/test-driven-development/SKILL.md:22    // "Include useful existing regression controls without calling those controls new RED evidence."
.agents/skills/harness/references/execution-conventions.md:24 // "Grouped RED/GREEN: ..."
.agents/skills/openspec/references/cases.md            // from 1.1
```

Produces:

```text
no new public names; wording only
```

**Cases**

1. **Preflight tokens present** — new RED · behavior
   Given `OpenSpecSkill.Tests.ps1` token loops for continue (`header`, `Roles:`, `Kinds:`, `deferred RED until`, `task_graph`, `example-table`), apply (`excluded from this card's GREEN`, `cites`), TDD (`group by role`, `shape`, `parameterized`, `checked-in baseline`) and execution-conventions (`deferred RED`) When run before the edits Then each loop fails on its first token; after Then all pass.
2. **Old wording absent** — new RED · behavior
   Given the same run Then continue and apply no longer say "a role tag and Given / When / Then" as the case requirement, and `execution-conventions.md` no longer implies every listed case must pass for GREEN.
3. **Protocol fixtures unchanged** — existing control · behavior
   Given `Protocol.Tests.ps1` temp copy (closure-v1 archive assertion downgraded, pre-existing) When run Then PASS; no fixture edit was needed because Cases are not machine-read.

**Files**

```diff
 .agents/skills/openspec-continue-change/SKILL.md
 .agents/skills/openspec-apply-change/SKILL.md
 .agents/skills/test-driven-development/SKILL.md
 .agents/skills/harness/references/execution-conventions.md
 .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1
```

**Verification**

Run from the workspace root in PowerShell 7.

```powershell
& pwsh -NoProfile -Command { param($p) & './.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1' -SurfacePaths $p } -args (,@('.agents/skills/openspec', '.agents/skills/openspec-continue-change', '.agents/skills/openspec-apply-change', '.agents/skills/test-driven-development', '.agents/skills/harness/references'))
```

Exit 0 with the new token loops executed; `Protocol.Tests.ps1` temp copy PASS.

**Evidence**

2026-09-11 18:47–18:49. RED: scoped `OpenSpecSkill.Tests.ps1` with the new continue / apply / TDD / execution-conventions token loops → exit 1, `Continue plan-acceptance preflight is missing the case rule: cases.md` (case 1 observed; the loop stops at its first missing token). GREEN: after the four wording edits → exit 0, `OpenSpec skill package tests passed`; negatives (`a role tag and Given` absent) asserted in the same run (case 2). `Protocol.Tests.ps1` temp copy (closure-v1 archive assertion downgraded, 4 pre-existing issues) → `PASS` with no fixture edit (case 3).

## 3. Closure

## [x] 3.1 Record the self-review and validate the Change

Document task: write the plan's self-review record and prove the Change record is strict-valid with its attachments indexed.

**Outcome**

`attachments/data/planning-validation.md` records the machine checks (`openspec.validate <change> --strict`, INDEX audit) and the three self-review items for this plan; `attachments/INDEX.md` indexes it once and its current position says the plan is complete. `openspec.validate harness/refactor-task-cases-open-shapes --strict` Succeeded; the spec delta validates; `harness/core` sync and archive are separate lifecycle steps not performed here.

**Files**

```diff
+openspec/changes/harness/refactor-task-cases-open-shapes/attachments/data/planning-validation.md
 openspec/changes/harness/refactor-task-cases-open-shapes/attachments/INDEX.md
```

**Verification**

Run from the workspace root in PowerShell 7 with Harness imported.

```powershell
$v = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('harness/refactor-task-cases-open-shapes', '--strict', '--json'); $v.status
```

`Succeeded`; scoped `OpenSpecSkill.Tests.ps1` on the Change directory exits 0 (INDEX audit, English scan).

**Evidence**

2026-09-11 18:50. `attachments/data/planning-validation.md` written and indexed once; INDEX current position updated. `Invoke-Harness openspec.validate harness/refactor-task-cases-open-shapes --strict` → Succeeded; scoped `OpenSpecSkill.Tests.ps1` on the Change directory → exit 0 (INDEX audit, English scan). Spec sync and archive not performed here.
