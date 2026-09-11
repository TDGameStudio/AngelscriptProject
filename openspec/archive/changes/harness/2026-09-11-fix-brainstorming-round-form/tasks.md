---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.1", "1.2"]
---

# Compact grill rounds with a structured answer form

## Execution context

The accepted handoff is `attachments/drafts/handoff.md`; the round shape and form rule are in `attachments/drafts/design.md` §3–§5. Work lands in the parent repository only. Preserve unrelated dirty files. Harness routes run in the current PowerShell 7 session. Tests are Pester-free PowerShell scripts executed directly; `Protocol.Tests.ps1` runs through a temporary copy that downgrades only the pre-existing closure-v1 archive assertion.

## 1. Skill text

- [x] 1.1 Rewrite the `grilling.md` round shape and add the answer-form step

    **Outcome**

    `.agents/skills/brainstorming/references/grilling.md` "Round shape" shows the compact template from design §3 (one `##` per round, `**Situation**` marker lines, `**Overall recommendation**`, one `❔ Open decision:` paragraph per question with `- **A.**` bullets, `👉 Recommendation:` and `❗ Flip condition:` lines, no `###` per question) and its rules, followed by a new section "Collect the answers" stating design §4. Other sections of the file are unchanged.

    **Context and interfaces**

    New terms from the draft glossary: `answer form` (the host's structured question tool, `AskQuestion` in Cursor), `compact round`. No new files. `markers.md` labels are referenced, not changed.

    **Cases**

    | Check | Expected | Role |
    | --- | --- | --- |
    | `rg -c "### ❔ Open decision" grilling.md` | 0 | heavy template removed |
    | `rg -n "## Collect the answers" grilling.md` | one match | new step present |
    | `rg -n "AskQuestion" grilling.md` | ≥ 2 matches (existing line 3 caveat + new step) | form named |
    | `rg -n "\(Recommended\)" grilling.md` | ≥ 1 | recommended-first rule |
    | `rg -n "never a round" grilling.md` | ≥ 1 | form does not replace the brief |
    | `rg -n "Never indent option lines" grilling.md` | ≥ 1 | rendering rule |
    | `rg -n "every question to the user is a grill round" grilling.md` | 1 | existing token kept |

    **Implementation**

    1. Replace the "Round shape" section body (template fence and "Rules that keep it scannable" list) with design §3.
    2. Insert "## Collect the answers" after "Round shape" with design §4 text.
    3. Run the Cases checks.

    **Files**

    - `.agents/skills/brainstorming/references/grilling.md`

    **Verification**

    Run from the workspace root.

    ```powershell
    rg -n "## Collect the answers|AskQuestion|\(Recommended\)|never a round|Never indent option lines|every question to the user is a grill round" .agents/skills/brainstorming/references/grilling.md
    ```

    All six patterns must match and `### ❔ Open decision` must not appear.

    **Evidence**

    2026-09-11 16:33: "Round shape" body replaced with the compact template (one `##`, `**Situation**` marker lines, `❔ Open decision:` paragraphs, `- **A.**` bullets) and its rules; "## Collect the answers" inserted after it. `rg` matched `## Collect the answers` (139), `AskQuestion` (3, 141), `(Recommended)` (141), `never a round` (141), `Never indent option lines` (134), `every question to the user is a grill round` (3); `### ❔` has zero matches. RED observed first in 2.1 on `## Collect the answers`.

- [x] 1.2 Add the form bullet and verbatim-log restatement to `SKILL.md`

    **Outcome**

    `.agents/skills/brainstorming/SKILL.md` "Grilling in short" contains a bullet requiring the answer form after the written round (design §4, one sentence), and checklist step 3 contains "Paste the round into `log.md` exactly as sent" (design §5). Frontmatter description unchanged.

    **Context and interfaces**

    Uses the term `answer form` from 1.1. No new public names.

    **Cases**

    - `rg -n "AskQuestion" SKILL.md` matches once, inside "Grilling in short".
    - `rg -n "exactly as sent" SKILL.md` matches once, inside checklist step 3.
    - Existing tokens asserted by `OpenSpecSkill.Tests.ps1` (`situation brief`, `frontier`, `recommended answer`, `Every question to the user is a grill round`, …) remain present.
    - `quick_validate.py .agents/skills/brainstorming` exits 0.

    **Implementation**

    1. Append the bullet to "Grilling in short".
    2. Extend checklist step 3.
    3. Run the validator.

    **Files**

    - `.agents/skills/brainstorming/SKILL.md`

    **Verification**

    Run from the workspace root.

    ```powershell
    $env:PYTHONUTF8=1; python C:\Users\scottmei\.agent\skills\skill-creator-for-knot\scripts\quick_validate.py .agents/skills/brainstorming
    ```

    Exit 0 and both `rg` cases match.

    **Evidence**

    2026-09-11 16:34: "Grilling in short" gained the compact-shape sentence and the answer-form bullet (`AskQuestion`, recommended first, cancelled form falls back to text); checklist step 3 gained "collect the answers through the host's answer form" and "Paste the round into `log.md` exactly as sent". `quick_validate.py .agents/skills/brainstorming` printed its localized pass line, exit 0.

## 2. Tests

- [x] 2.1 Assert the new round contract in the Skill tests

    **Outcome**

    `OpenSpecSkill.Tests.ps1` asserts that `grilling.md` contains `## Collect the answers`, `AskQuestion`, `(Recommended)`, `never a round`, `- **A.**`, `Never indent option lines` and does not contain `### ❔ Open decision`; and that `SKILL.md` contains `AskQuestion` and `exactly as sent`. The scoped run passes; `Protocol.Tests.ps1` temp copy passes.

    **Context and interfaces**

    No new public names. Extends the existing brainstorming token loops near lines 969–1002.

    **Cases**

    - RED: with the new assertions and 1.1/1.2 reverted, the scoped test fails on `## Collect the answers`.
    - GREEN: with 1.1/1.2 applied, the scoped test exits 0.
    - `Protocol.Tests.ps1` temp copy passes.
    - `openspec.validate harness/fix-brainstorming-round-form --strict` passes.

    **Implementation**

    1. Add a token loop for `grilling.md` and extend the `SKILL.md` loop; add a negative assertion for `### ❔ Open decision`.
    2. Observe RED against a stashed copy of 1.1/1.2, then GREEN.

    **Files**

    - `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`

    **Verification**

    Run from the workspace root.

    ```powershell
    & ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths @('.agents/skills/brainstorming', '.agents/skills/harness', '.agents/skills/openspec', 'openspec/changes/harness/fix-brainstorming-round-form', 'openspec/specs/harness')
    ```

    Exit 0 with all selected cases executed.

    **Evidence**

    2026-09-11 16:35: added a `grillingText` token loop (`## Collect the answers`, `AskQuestion`, `(Recommended)`, `never a round`, `- **A.**`, `Never indent option lines`, `every question to the user is a grill round`), a negative assertion for `### ❔ Open decision`, and `exploreText` tokens `AskQuestion` / `exactly as sent`. RED before 1.1/1.2: "Grilling round-form contract is missing: ## Collect the answers" (after first fixing an English-audit hit on quoted Chinese in the seeded design/talk attachments). GREEN after 1.1/1.2: scoped run exit 0. `Protocol.Tests.ps1` temp copy (only the pre-existing closure-v1 assertion downgraded to a warning) printed `Protocol.Tests.ps1: PASS`, exit 0; copy deleted.
