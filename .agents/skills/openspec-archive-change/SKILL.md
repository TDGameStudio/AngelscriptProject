---
name: openspec-archive-change
description: Close and archive a completed OpenSpec change in this project - the authoritative close policy plus the archive primitive of the portable Rust openspec.exe (a pure directory move with no spec merge and no completion checks). Use when a change is finished and should move to the dated archive.
---

# Archive a Change: Close Policy + Primitive

The `change archive` CLI primitive only writes `archived_at` and moves the directory to `openspec/archive/changes/<domain>/<date>-<leaf>/`. It does **not** merge specs, clean attachments, or check task completion. All gating lives in this skill's close policy.

Read first:

- `.agents/skills/openspec/SKILL.md` — the binary, command surface, and shared operation rules. Never invoke bare `openspec`.
- `.agents/skills/openspec-schema/SKILL.md` — attachment trimming and knowledge promotion requirements.

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/hardness/scripts/openspec.ps1"
```

## Close Policy (every item must pass before invoking archive)

1. `& $openspec doctor --json` reports no structural errors.
2. `& $openspec validate <id> --type change --strict --json` passes.
3. The change's `tasks.md` exists, is non-empty, contains at least one real `- [ ]` / `- [x]` / `- [X]` checkbox outside fenced examples, and every real task is checked.
4. Attachments are closed per `openspec-schema`: `data/` trimmed, `attachments/INDEX.md` current, and knowledge promotion decided — change-level knowledge that serves a capability or spans capabilities is **copied** up before archive (the originals stay and freeze as history).
5. Durable behavior deltas are synchronized into current specs via `openspec-sync-specs`, or the change explicitly records that spec sync is not applicable.

If any item fails, keep the change active, report which item failed and why, and do not invoke archive. Incompleteness is a finding to report, not a gate to bypass silently — the user may still decide to archive an abandoned change as-is; record that decision in the change before archiving.

## Procedure

1. **Select the change.** Named by the user → use it. Exactly one active (`& $openspec change list --json`) → auto-select. Otherwise ask. Always announce: "Using change: `<domain>/<leaf>`".
2. **Run the close policy.** Items 1–2 via CLI; items 3–5 by reading the files directly. No PowerShell policy checker exists yet — inspect, do not assume.
3. **Archive.** `& $openspec change archive <id> [--date YYYY-MM-DD]`.
4. **Audit.** `& $openspec validate --archived --json` and confirm the archived record passes.
5. **Summarize.** Archived path, per-item policy evidence, and the post-archive validation result.

## Guardrails

- Never treat `change archive` succeeding as proof the change was ready — the primitive checks nothing.
- Never hand-move change directories into `archive/`; the CLI owns the move and `archived_at`.
- Archiving with incomplete tasks or overturned plans is allowed only as an explicit user decision, recorded in the change.
