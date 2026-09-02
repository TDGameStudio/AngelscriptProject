---
name: openspec-apply-change
description: Implement tasks from an active OpenSpec change in this project, driven by the portable Rust openspec.exe. The implementation-discipline entry - read planning context, review the plan critically, work tasks with TDD and verification, keep checkboxes and attachments current. Use when starting or continuing implementation of a change.
---

# Apply a Change: Implement Tasks

Works through a change's `tasks.md` with verification discipline. This operation edits code; planning artifacts are revised via Update (see the `openspec` skill), not silently patched here.

Read first:

- `.agents/skills/openspec/SKILL.md` — the binary, command surface, and shared operation rules. Never invoke bare `openspec`.
- `.agents/skills/openspec-schema/SKILL.md` — attachments/INDEX.md discipline and where implementation records go.
- `.agents/skills/test-driven-development/SKILL.md` — for every task that changes code behavior.

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/hardness/scripts/openspec.ps1"
```

## Procedure

1. **Select the change.** Named by the user → use it. Exactly one active (`& $openspec change list --json`) → auto-select. Otherwise ask. Always announce: "Using change: `<domain>/<leaf>`".
2. **Read apply readiness.** `& $openspec instructions apply --change <id> --json` — readiness, project context, merged apply rules/guidance, and task progress (the `angelscript` workflow tracks `tasks.md`).
   - Blocked (missing artifacts) → report what is missing and switch to `openspec-continue-change`.
   - All tasks done → suggest `openspec-archive-change`.
   - `context` and merged guidance are prompt-level inputs: consider and apply them, but they are never evidence of task completion, never override a blocked state or an explicit user choice, and are never copied verbatim into code or artifacts.
3. **Read the plan from disk.** `proposal.md`, `design.md`, `tasks.md`, `specs/`, and `attachments/INDEX.md` — the INDEX is the change's working memory and resume point; open other attachments only where it points.
4. **Review the plan before the first task.** Concerns go to the user first. Gaps or design issues discovered here are an Update conversation, not silent patches.
5. **Task loop.** For each unchecked task in order (honoring `[P]` parallel and dependency annotations):
   - Announce the task.
   - Follow its steps exactly, running every verification command it names. Tasks marked `[TDD]` (and any behavior change) go through the TDD skill.
   - Keep changes minimal and focused; protect unrelated workspace changes.
   - Flip `- [ ]` → `- [x]` immediately after its verification passes — never earlier, never for partial or deferred work.
   - Record as you go, per `openspec-schema`: diagnosis and problem disposal → `attachments/implementation/`; knowledge that will be looked up again → `attachments/knowledges/`; update `attachments/INDEX.md` in the same stroke.
6. **Pause instead of guessing** on: an unclear task; a revealed design issue (suggest Update); scope beyond what the artifacts describe — surface it, never absorb it silently; errors, blockers, or verification that keeps failing.
7. **Session end.** Update `attachments/INDEX.md` (current position, resume point). Report progress `N/M`, the verification evidence for what was completed, and the next step. If everything is done, suggest `openspec-archive-change`.

## Guardrails

- No passing verification output → no claiming success, no checking the box.
- Only mark `- [x]` when the task's specified behavior is fully implemented.
- Never narrow, defer, or simplify away specified behavior to make a task fit — surface added scope and ask.
- Task ambiguity, design issues, and errors pause the loop; they are not license to improvise.
