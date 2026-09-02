---
name: openspec-continue-change
description: Create the next planning artifact (proposal, specs, design, or tasks) for an active OpenSpec change in this project, driven by the portable Rust openspec.exe. Use when the user wants to progress a change's planning records, produce the next artifact, or fast-forward planning to implementation-ready.
---

# Continue a Change: Create the Next Artifact

Creates exactly **one** next artifact for an active change, then stops.

Read first:

- `.agents/skills/openspec/SKILL.md` — the binary, command surface, and shared operation rules. Never invoke bare `openspec`.
- `.agents/skills/openspec-schema/SKILL.md` — content standards for everything you write (especially the `tasks.md` bar).

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/hardness/scripts/openspec.ps1"
```

## Procedure

1. **Select the change.** Named by the user → use it. Exactly one active (`& $openspec change list --json`) → auto-select. Otherwise show the most recently modified actives with progress and ask. Always announce: "Using change: `<domain>/<leaf>`". If no active change exists, this is a Start, not a Continue — create it first with `change create <domain>/<leaf>` (see the `openspec` skill).
2. **Read readiness.** `& $openspec status --change <id> --json` — per-artifact `ready` / `waiting` / `complete` states.
3. **Pick the next artifact.** The `angelscript` workflow has no hard dependency edges; `proposal → specs → design → tasks` is a sensible default order, not a gate. `specs` and `design` are conditional — skip `specs` when the change has no durable behavior delta, skip `design` when there are no architectural decisions, and say so explicitly instead of writing a hollow file.
4. **Get instructions.** `& $openspec instructions <artifact> --change <id> --json`:
   - `template` is the structure to fill; the workflow `instruction` is the per-artifact brief.
   - `context` and `rules` are constraints **for you** — never copy them into the artifact.
   - Re-read every file in `contextFiles` from disk, not from conversation memory.
5. **Write the artifact** to the returned output path, applying the authoring standards from `openspec-schema`. Verify the file exists on disk afterwards.
6. **Validate and stop.** `& $openspec validate <id> --type change --json`. Report what was created and what the next artifact would be — then stop. Fast-forward (repeat 2–6 until implementation-ready) only when the user explicitly asked for it.

## Guardrails

- One artifact per invocation unless explicitly fast-forwarding.
- Never hand-create change directories or `change.yaml` — the `change create` command owns object identity.
- Planning records only: no code edits in this operation (that is `openspec-apply-change`).
- If implementation has already started and artifacts need revision instead of creation, that is an Update conversation (see the `openspec` skill), not a Continue.
