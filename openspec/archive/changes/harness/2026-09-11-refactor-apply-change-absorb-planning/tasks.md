---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
---

# Fold planning-artifact creation into openspec-apply-change

## Goal

`openspec-apply-change` takes a Change from created to implemented with one `Ensure plan` step, one preflight text in `tasks.md ### Preflight` is linked at plan acceptance and task start, and the `openspec-continue-change` Skill, its routing row and its README bullets are gone.

## Architecture

Skill wording and tests only; `openspec.status` and `openspec.instructions` remain the mechanics. Apply step 0 carries planning authority (stop on a missing user-owned decision or unsettled public name); steps 1–6 keep implementation authority (never ask, `Naming assumed`). See `design.md` §"Shape of the merged Skill" and §"Preflight consolidation".

## Global constraints

- No CLI change; no edit to any file under `openspec/archive/`; archived records keep their historical `openspec-continue-change` references.
- Records are English; no Change file references `openspec/drafts/`.
- The Skill directory is removed with `git rm`; no redirect stub is left behind.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| `harness/core` Exploration markers and durable carryover — canonical truth enters planning artifacts through apply `Ensure plan`; stop on missing user-owned decision | 1.1 |
| `harness/core` Ready-to-execute Task authoring — single preflight text applied at plan acceptance and task start | 1.1 |
| Retire the Skill: directory, routing row, README bullets, lifecycle chains, tests, naming/deep-exploration references | 2.1 |
| Planning self-review record; strict validation | 3.1 |

Self-review 2026-09-11: coverage complete for the two MODIFIED requirements; placeholders none; symbols consistent with `design.md` and `attachments/drafts/glossary.md`. Record: `attachments/data/planning-validation.md`.

## 1. Merged Skill

## [x] 1.1 Add `Ensure plan` to apply and make `tasks.md` the single preflight

`openspec-apply-change` gains step 0 and links the preflight twice; `tasks.md ### Preflight` becomes the one list with two named moments; `cases.md` names moments rather than Skills. `openspec-continue-change` still exists after this task (removed in 2.1) so the suite stays green between tasks.

**Outcome**

Apply step 0 `Ensure plan` states: trigger (`openspec.status --change` reports a missing required artifact), sources (seeded `attachments/drafts/handoff.md`, `design.md`, `glossary.md`; or the request for a draft-less Change with the skipped-gate assumption in the proposal), rules (specs only for durable behavior; design only for non-obvious decisions; one indexed talk for a new non-obvious decision; never paste `log.md`; never reopen design mode), authority (a missing user-owned decision or unsettled public name stops and reports; `Naming assumed` belongs to steps 1–6 only), and that fast-forward through all missing artifacts is the only mode. The existing preflight sentence in step 2 becomes a link to `tasks.md ### Preflight`. `tasks.md ### Preflight` lists every check and names the two moments (plan acceptance in apply step 0 incl. `planning-validation.md` indexed; task start in apply step 2) without naming `openspec-continue-change`. `cases.md` §"How TDD and preflight consume the block" reads "Preflight (plan acceptance and task start in `openspec-apply-change`)". Excluded: deleting the Skill, other references (2.1).

**Interfaces**

Consumes:

```text
.agents/skills/openspec-apply-change/SKILL.md:10-11   // steps 1–2, task-start preflight sentence
.agents/skills/openspec-continue-change/SKILL.md:8-21 // steps 1–6 and preflight paragraph being absorbed
.agents/skills/openspec/references/tasks.md:57-59     // ### Preflight
.agents/skills/openspec/references/cases.md:121       // preflight sentence naming two Skills
```

Produces:

```text
step heading "0. Ensure plan" in openspec-apply-change/SKILL.md   // glossary "Ensure plan"; internal wording, not a public name
```

**Cases**

1. **Apply carries the plan step** — new RED · behavior
   Given `OpenSpecSkill.Tests.ps1` asserting `$applyText` contains `Ensure plan`, `openspec.status`, `attachments/drafts/handoff.md`, `skipped-gate`, `never reopen`, `stops and reports`, `one indexed talk`, `never paste the draft `log.md`` When run before the edit Then it fails on `Ensure plan`; after Then all found.
2. **Single preflight text** — new RED · behavior
   Given the same suite asserting `$taskReferenceText` `### Preflight` section contains `plan acceptance`, `task start`, `openspec-apply-change`, `cases.md`, `Roles:`, `deferred RED`, `example-table`, and does not contain `openspec-continue-change`; and `$applyText` contains `[Task authoring preflight]` at least twice Then RED before, GREEN after.
3. **Cases catalog names moments** — new RED · behavior
   Given `$casesReferenceText` Then it contains `plan acceptance and task start in `openspec-apply-change`` and not `openspec-continue-change`.
4. **Continue tokens still hold** — existing control · behavior
   Given the pre-existing `$continueText` loops When 1.1 completes Then they still pass (the file is untouched until 2.1).

**Files**

```diff
 .agents/skills/openspec-apply-change/SKILL.md
 .agents/skills/openspec/references/tasks.md
 .agents/skills/openspec/references/cases.md
 .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1
```

**Verification**

Run from the workspace root in PowerShell 7.

```powershell
& pwsh -NoProfile -Command { param($p) & './.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1' -SurfacePaths $p } -args (,@('.agents/skills/openspec', '.agents/skills/openspec-apply-change'))
```

Exit 0; cases 1–3 RED before the edits, GREEN after; case 4 green throughout.

**Evidence**

2026-09-11 19:24–19:30. RED: scoped `OpenSpecSkill.Tests.ps1` (openspec, apply) with the new assertions → exit 1, `Apply Ensure plan step is missing: Ensure plan` (case 1). GREEN after adding step 0, the two preflight links, the single `### Preflight` text and the `cases.md` sentence → exit 0, `OpenSpec skill package tests passed` (cases 1–3); the untouched `\` loops passed in the same run (case 4). Stale expectations retired in the same run: the apply token loops that required the restated preflight (`new RED`, `cases.md`, `Roles:`, `Kinds:`) now assert the link wording (`Task authoring preflight`, `task-start moment`); two token spellings aligned to the text (`Never reopen`, `**Plan acceptance**`).

## 2. Retirement

## [x] 2.1 Remove `openspec-continue-change` and repoint every live reference

Delete the Skill and move every live reference to apply step 0; tests stop reading the file and assert its absence. Archived records are not touched.

**Outcome**

`.agents/skills/openspec-continue-change/` no longer exists. `openspec-create-change` step 6 and the flow line hand the Change to `openspec-apply-change` (`Ensure plan`); its draft-less note says apply states the skipped-gate assumption. `harness/SKILL.md` flow line and handoff bullet, `routing.md` (row "Create the next missing planning artifact" removed; row 18 says "before `openspec-apply-change`"), `.agents/skills/README.md`, `openspec/SKILL.md` lifecycle list, `brainstorming/SKILL.md` (two chains), `naming.md` shared-by list, `deep-exploration.md` closing paragraph, `openspec/README.md` and root `README.md` lifecycle sentences name apply instead. `OpenSpecSkill.Tests.ps1`: `$continueText` and its loops removed; surviving contract tokens (`Never reopen`, `Exploration Carryover`, `attachments/drafts/handoff.md`, `never paste the draft `log.md``, `unattended continuation`) asserted on `$applyText`; link map, mode-free list and required-entry list drop the Skill; a `Test-Path` negative asserts the directory is gone. Excluded: `config.yaml`, templates, archived records.

**Interfaces**

Consumes:

```text
.agents/skills/openspec-create-change/SKILL.md:11,30,36
.agents/skills/harness/SKILL.md:34,38
.agents/skills/harness/references/routing.md:18,21
.agents/skills/README.md:53 ; .agents/skills/openspec/SKILL.md:38
.agents/skills/brainstorming/SKILL.md:52,79 ; references/naming.md:3 ; references/deep-exploration.md:77
openspec/README.md:32 ; README.md:181,325
.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1:822,872,892,1000-1003,1016,1040,1087,1097,1100,1202,1251,1267
```

Produces:

```text
no new public names
```

**Cases**

1. **Directory gone** — new RED · absence
   Must not exist: `.agents/skills/openspec-continue-change/SKILL.md`. Oracle: `Test-Path` negative assertion in the suite; RED while the file exists.
2. **No live reference remains** — new RED · invariant
   For all files in `.agents/skills/**`, `openspec/README.md`, `README.md`, `openspec/config.yaml` (excluding `openspec/archive/**` and `openspec/drafts/**`): the text `openspec-continue-change` does not occur. Oracle: `rg -l openspec-continue-change` over that set returns nothing; asserted in the suite.
3. **Contract tokens moved to apply** — new RED · behavior
   Given the suite asserting `$applyText` contains `Never reopen`, `Exploration Carryover`, `attachments/drafts/handoff.md`, `never paste the draft `log.md``, `unattended continuation` Then RED before (apply lacks `Exploration Carryover`), GREEN after.
4. **Required-entry list updated** — existing control · behavior
   Given the skills README required-entry loop Then it passes with `openspec-continue-change` removed from both the README and the list.

**Files**

```diff
-.agents/skills/openspec-continue-change/SKILL.md
 .agents/skills/openspec-create-change/SKILL.md
 .agents/skills/harness/SKILL.md
 .agents/skills/harness/references/routing.md
 .agents/skills/README.md
 .agents/skills/openspec/SKILL.md
 .agents/skills/brainstorming/SKILL.md
 .agents/skills/brainstorming/references/naming.md
 .agents/skills/brainstorming/references/deep-exploration.md
 .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1
 openspec/README.md
 README.md
```

**Verification**

Run from the workspace root in PowerShell 7.

```powershell
& pwsh -NoProfile -Command { param($p) & './.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1' -SurfacePaths $p } -args (,@('.agents/skills/openspec', '.agents/skills/openspec-apply-change', '.agents/skills/openspec-create-change', '.agents/skills/harness', '.agents/skills/brainstorming', '.agents/skills/README.md', 'openspec/README.md'))
```

Exit 0; `rg -l openspec-continue-change .agents openspec/README.md README.md openspec/config.yaml` prints nothing.

**Evidence**

2026-09-11 19:31–19:38. RED: scoped suite with `\` removed, contract tokens on `\`, `Test-Path` negative and the live-reference scan → exit 1, `Create-change contract is missing: openspec-apply-change` (cases 1–3 red together; loop stops at first). GREEN after repointing 10 files and `git rm` of the Skill → exit 0 (cases 1–4). `rg -l openspec-continue-change .agents openspec/README.md README.md openspec/config.yaml -g '!**/tests/**'` prints nothing; the scan excludes `tests/` because the suite itself carries the literal in its negative assertions. Verification scope corrected from `.agents/skills` + root `README.md` to the owned Skill directories: the whole tree includes external Skills with CJK data files and the root README is Chinese by design, both tripping the English-surface scan unrelated to this task. One repair: `Get-Content -Raw` returns null for an empty file; the scan casts to string.

## 3. Closure

## [x] 3.1 Record the self-review and validate the Change

Document task: planning self-review record and strict validation of this Change.

**Outcome**

`attachments/data/planning-validation.md` records machine checks and the three self-review items, indexed once; `openspec.validate harness/refactor-apply-change-absorb-planning --strict` Succeeded; spec delta strict. Sync and archive are separate lifecycle steps.

**Files**

```diff
+openspec/changes/harness/refactor-apply-change-absorb-planning/attachments/data/planning-validation.md
 openspec/changes/harness/refactor-apply-change-absorb-planning/attachments/INDEX.md
```

**Verification**

Run from the workspace root in PowerShell 7 with Harness imported.

```powershell
$v = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('harness/refactor-apply-change-absorb-planning', '--strict', '--json'); $v.status
```

`Succeeded`; scoped `OpenSpecSkill.Tests.ps1` on the Change directory exits 0.

**Evidence**

2026-09-11 19:40. `attachments/data/planning-validation.md` written and indexed; INDEX current position updated. `openspec.validate harness/refactor-apply-change-absorb-planning --strict` → Succeeded; scoped suite on the Change directory → exit 0; `Protocol.Tests.ps1` temp copy → PASS.
