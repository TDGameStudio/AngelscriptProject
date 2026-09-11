---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.1", "1.2"]
---

# Collapse code-review to one Skill and define review rules

## Execution context

The accepted handoff is `attachments/drafts/handoff.md`. Work lands in the parent repository only. Preserve unrelated dirty files. Harness routes run in the current PowerShell 7 session. Tests are Pester-free PowerShell scripts executed directly; `Protocol.Tests.ps1` runs through a temporary copy that downgrades only the pre-existing closure-v1 archive assertion.

## 1. Skill and reference

- [x] 1.1 Flatten `code-review` to one Skill with reviewer-side rules

    **Outcome**

    `.agents/skills/code-review/SKILL.md` exists with frontmatter `name: code-review`; `.agents/skills/code-review/code-reviewer/`, `receiving-code-review/`, and `requesting-code-review/` do not exist. The Skill keeps the existing reviewer contract and adds rules 1–10 from `attachments/drafts/design.md` §3.

    **Context and interfaces**

    New public names (from the draft glossary): Skill `code-review` at `.agents/skills/code-review/SKILL.md`; section heading `Verified sound`; terms `planning finding`, `re-review`, `fan-out`. Severity names unchanged (`Critical`, `Required`, `Advisory`) with new definitions. Routing row in `harness/references/routing.md` and README line for `code-review/code-reviewer` point to the new path.

    **Cases**

    - RED: `OpenSpecSkill.Tests.ps1` after 2.1 asserts `.agents/skills/code-review/SKILL.md` contains `name: code-review`, `Verified sound`, `planning finding`, `never dispatch`, `Critical`/`Required`/`Advisory` definition sentences, and that the three old directories are absent; before this task those assertions fail.
    - `quick_validate.py .agents/skills/code-review` exits 0.
    - `routing.md` and `.agents/skills/README.md` contain `code-review/SKILL.md` / `` `code-review` `` and no `code-reviewer`.

    **Implementation**

    1. `git mv .agents/skills/code-review/code-reviewer/SKILL.md .agents/skills/code-review/SKILL.md`; delete the two `_SKILL.md` files and their empty directories.
    2. Rewrite frontmatter and body: input contract, tests first, read-only inspection, no sub-dispatch, no broad gate rerun, severity definitions, planning findings, "Verified sound", verdict.
    3. Update `routing.md` row and README line.

    **Files**

    - `.agents/skills/code-review/SKILL.md`
    - `.agents/skills/harness/references/routing.md`
    - `.agents/skills/README.md`

    **Verification**

    Run from the workspace root.

    ```powershell
    $env:PYTHONUTF8=1; python C:\Users\scottmei\.agent\skills\skill-creator-for-knot\scripts\quick_validate.py .agents/skills/code-review
    ```

    All selected cases must execute and pass.
    **Evidence**

    2026-09-11 16:05: `git mv code-review/code-reviewer/SKILL.md code-review/SKILL.md`; `receiving-code-review/_SKILL.md` and `requesting-code-review/_SKILL.md` deleted with their directories. SKILL.md rewritten with `name: code-review`, input contract, "How to read", severity definitions, planning finding, "Verified sound", verdict. `routing.md` row and README line updated. `quick_validate.py .agents/skills/code-review` printed its localized pass line, exit 0. RED observed first: with 2.1's assertions in place the scoped test failed on "The single code-review Skill must live at .agents/skills/code-review/SKILL.md."

- [x] 1.2 Add coordinator triage rules to `review.md`

    **Outcome**

    The Triage section of `.agents/skills/harness/references/review.md` states rules 11–18 from `attachments/drafts/design.md` §3: reproduce before acting, clarify all ambiguous findings first, repair order with per-repair verification, user-owned-decision routing, usage evidence for unused functionality, plain repair language, re-review bound, fan-out.

    **Context and interfaces**

    No new public names. Terms `re-review` and `fan-out` used as defined in 1.1. Routing for the user-owned case names `openspec-update-change`.

    **Cases**

    - RED: after 2.1, `OpenSpecSkill.Tests.ps1` asserts `review.md` contains `Clarify every ambiguous finding`, `Critical → Required → Advisory`, `new immutable snapshot`, `non-overlapping scopes`, and `openspec-update-change`; before this task those fail.
    - Existing `review.md` tokens asserted by the tests remain present.

    **Implementation**

    1. Extend "Triage and Replan" with a "Coordinator conduct" subsection and a "Re-review and fan-out" subsection.

    **Files**

    - `.agents/skills/harness/references/review.md`

    **Verification**

    Run from the workspace root.

    ```powershell
    rg -n "Clarify every ambiguous finding|Critical → Required → Advisory|new immutable snapshot|non-overlapping scopes" .agents/skills/harness/references/review.md
    ```

    All four patterns must match at least once.
    **Evidence**

    2026-09-11 16:08: `review.md` gained "Coordinator conduct" (7 bullets) and "Re-review and fan-out" (2 bullets) under "Triage and Replan". `rg` matched all four required patterns (lines 88, 89, 97, 98). Existing review.md tokens in the tests still pass.

## 2. Tests

- [x] 2.1 Update skill tests for the single `code-review` Skill

    **Outcome**

    `OpenSpecSkill.Tests.ps1` asserts the new Skill path, the reviewer and triage tokens, the absence of the three old directories, and drops `code-review` from the `/goal` exclusion regex; the scoped run passes and `Protocol.Tests.ps1` still passes.

    **Context and interfaces**

    No new public names. Test tokens as listed in 1.1 and 1.2 Cases.

    **Cases**

    - RED: with the new assertions and 1.1/1.2 reverted, the test fails on the missing new path; with 1.1/1.2 applied, it passes.
    - `Protocol.Tests.ps1` temp copy passes (closure-v1 archive assertion downgraded, pre-existing).
    - `openspec.validate harness/refactor-code-review-single-skill --strict` passes.

    **Implementation**

    1. Replace `code-review` in the `/goal` exclusion regex; add token loops for `.agents/skills/code-review/SKILL.md` and `review.md`; assert the old paths do not exist.
    2. Run the scoped test and the Protocol temp copy.

    **Files**

    - `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`

    **Verification**

    Run from the workspace root.

    ```powershell
    & ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths @('.agents/skills/code-review', '.agents/skills/harness', '.agents/skills/openspec', 'openspec/changes/harness/refactor-code-review-single-skill', 'openspec/specs/harness')
    ```

    All selected cases must execute and pass.
    **Evidence**

    2026-09-11 16:09: `/goal` exclusion regex no longer excludes `code-review`; new assertions for the Skill path, 13 reviewer tokens, the per-task cadence prohibition, 7 review.md triage tokens, absence of the three retired directories, and routing surfaces. RED before 1.1/1.2 (missing Skill path); GREEN after: scoped `OpenSpecSkill.Tests.ps1` exit 0, `Protocol.Tests.ps1` temp copy PASS (pre-existing closure-v1 assertion downgraded), `openspec.validate harness/refactor-code-review-single-skill --strict` Succeeded.
