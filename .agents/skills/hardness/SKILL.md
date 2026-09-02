---
name: hardness
description: Entry harness that chains all AngelscriptProject skills together. Provides the skill route table, the unattended loop iteration protocol (RalphLoop), and the feedback loop for evolving the harness itself. Use as the first skill to read when starting an unattended agent loop iteration, when unsure which project skill applies to a task, or when recording a harness problem discovered during work.
disable-model-invocation: true
---

# Hardness (Harness)

Version: 0.2.0 (2026-09-02)

The single entry point that chains project skills together. It does three things:

1. **Route** — a dispatch table mapping task types to the skill file to read.
2. **Loop protocol** — the fixed iteration contract for unattended runs driven by `Tools/RalphLoop`.
3. **Feedback loop** — problems found while using the harness are recorded under `feedback/`; a developer + AI session later evaluates them and updates the harness. Agents never update the harness themselves.

How other skills or prompts should reference this skill: "Read and follow `.agents/skills/hardness/SKILL.md`".

## Route Table

Read the target SKILL.md (by path) before doing that kind of work. Status reflects the ongoing skill refactor; do not use `pending` skills as authority until activated.

| Task type | Skill path | Status |
|---|---|---|
| OpenSpec CLI primitive + shared operation rules (Start/Update/Verify) | `.agents/skills/openspec/SKILL.md` — CLI calls go through `scripts/openspec.ps1` wrapper (below) | active |
| Write / organize any file under `openspec/` (change tree & specs tree schema) | `.agents/skills/openspec-schema/SKILL.md` | active |
| Create the next planning artifact for a change | `.agents/skills/openspec-continue-change/SKILL.md` | active |
| Implement a change's tasks (implementation discipline) | `.agents/skills/openspec-apply-change/SKILL.md` | active |
| Merge delta specs into current specs | `.agents/skills/openspec-sync-specs/SKILL.md` | active |
| Close and archive a change (close policy) | `.agents/skills/openspec-archive-change/SKILL.md` | active |
| Explore / research before deciding | `.agents/skills/openspec-explore/SKILL.md` | active |
| Receiving code review feedback | `.agents/skills/code-review/receiving-code-review/SKILL.md` | active |
| Requesting code review before completion | `.agents/skills/code-review/requesting-code-review/SKILL.md` | active |
| C++ automation tests (CQTest, inline AS fixtures) | `.agents/skills/angelscript-test-guide/SKILL.md` | active |
| TDD discipline for any feature/bugfix | `.agents/skills/test-driven-development/SKILL.md` | active |
| Git worktree, branch, commit workflow | `.agents/skills/git-workflow/SKILL.md` | active |
| Hazelight upstream update audit | `.agents/skills/hazelight-update-audit/SKILL.md` | active |
| Unreal Engine development knowledge | `.agents/skills/unreal-engine-develop/SKILL.md` | active |
| Visual explanation / diagrams for discussion | `.agents/skills/visual-explain/SKILL.md` | active |
| Polished standalone diagrams (HTML/SVG) | `.agents/skills/external/archify/SKILL.md` | active |
| TiddlyWiki / WikiText editing | `.agents/skills/external/tiddlywiki-wikitext/SKILL.md` | active |

Removed — never follow if they resurface in history or transcripts: `openspec-work` (replaced by openspec + the four operation skills + openspec-schema + openspec-explore plus this harness), `openspec-Implementation` and `openspec-replan` (superseded by `openspec-apply-change`).

Do not use `npx @fission-ai/openspec`, a globally installed openspec, or `Tools/openspec` build outputs directly; all OpenSpec CLI calls go through `scripts/openspec.ps1`.

## Loop Iteration Protocol (unattended runs)

Every RalphLoop iteration starts fresh with no memory. Follow these steps in order:

1. Read this SKILL.md fully (route table + rules below).
2. Locate the task source named in the loop prompt — normally `openspec/changes/<change>/tasks.md`. Pick the first unchecked task.
3. Consult the route table and read the relevant skill file(s) before touching code.
4. Do the smallest complete step for that task. Apply TDD where code behavior changes.
5. Run the verification command given by the loop prompt (or the task's own verify note). Do not claim success without passing output.
6. On success, check off the task in `tasks.md` and end with a concise final message: what was done, what was verified, what is next.
7. If you hit a harness deficiency (wrong route, stale path, unclear protocol, missing skill), record it under `feedback/open/` per `feedback/README.md`. Check for an existing similar entry first; append evidence instead of duplicating.
8. Stop signals in the final message line:
   - `HARNESS_COMPLETE` — all tasks checked and verification passes.
   - `HARNESS_BLOCKED: <reason>` — cannot proceed without human input (also record a feedback entry).

## Protected Files (hard rule)

During unattended runs, agents must NOT modify:

- `.agents/skills/hardness/SKILL.md`, `SKILL_ZH.md`
- `.agents/skills/hardness/feedback/README.md`
- `.agents/skills/hardness/scripts/`

The only allowed write inside this skill is adding/appending entries under `feedback/open/`. Harness updates happen exclusively in a developer-attended review session (below). Wrapper-level verification may reject any iteration whose diff touches protected paths.

## Feedback Review (developer + AI, interactive only)

1. Read all entries in `feedback/open/`.
2. For each: accept (update route table / protocol / scripts, bump the Version line) or reject (state why).
3. Move the entry to `feedback/archived/` with a `Verdict:` line appended — rejected entries are archived too, so future iterations stop re-proposing them.
4. Keep `SKILL.md` and `SKILL_ZH.md` in sync.

## Scripts

**`scripts/openspec.ps1`** — wrapper for the project-local OpenSpec CLI (`.agents/skills/openspec/bin/openspec.exe`). Works from any cwd; passes all arguments through; preserves exit code.

```powershell
# print resolved exe path
.agents/skills/hardness/scripts/openspec.ps1 -GetPath
# run any openspec command
.agents/skills/hardness/scripts/openspec.ps1 validate "my-change" --strict
```
