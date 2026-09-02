---
name: openspec-sync-specs
description: Merge a change's delta specs into the current specs tree (openspec/specs/) in this project. Always agent-driven - the portable Rust openspec.exe never merges specs, and change archive is a pure directory move. Use before archiving a change that has durable behavior deltas, or whenever current specs should absorb a change's spec records without archiving.
---

# Sync Specs: Delta → Current

The CLI **never merges specs** (`change archive` is a content-preserving move), so merging a change's delta specs into the current specs tree is always done by the agent, by hand, idempotently.

Read first:

- `.agents/skills/openspec/SKILL.md` — the binary, command surface, and shared operation rules. Never invoke bare `openspec`.
- `.agents/skills/openspec-schema/SKILL.md` — the specs tree layout (`spec.md`, `knowledges/`).

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/hardness/scripts/openspec.ps1"
```

## Procedure

1. **Select the change.** Named by the user → use it. Exactly one active (`& $openspec change list --json`) → auto-select. Otherwise ask, preferring changes that actually have delta specs. Always announce: "Using change: `<domain>/<leaf>`".
2. **Locate delta specs.** The workflow's `specs` artifact generates `openspec/changes/<domain>/<leaf>/specs/**/*.md`. If none exist, report there is nothing to sync and stop — do not infer deltas from other artifacts.
3. **Resolve the target for each delta.** The current spec document is `openspec/specs/<domain>/<leaf>/spec.md`. If the capability does not exist yet, create it with `& $openspec spec create <domain>/<leaf>` (register missing domains first with `domain create`) — never fabricate `spec.yaml` or spec directories by hand; the CLI owns object identity.
4. **Merge — never overwrite.** Read both the delta and the current spec before writing.
   - When the delta uses operation headers: **ADDED** → add the requirement (update to match if it already exists) · **MODIFIED** → apply, preserving every scenario and passage the delta does not mention · **REMOVED** → delete that requirement block · **RENAMED** → apply FROM/TO.
   - The `angelscript` workflow does not force Requirement/Scenario structure. For free-form deltas, reconcile the durable, externally observable behavior into the target `spec.md` — same principle: merge into the existing document, keep what the delta does not mention.
   - Current specs never contain delta operation headers (`## ADDED/MODIFIED/REMOVED/RENAMED ...`).
   - Idempotent: running the sync twice produces the same result.
5. **Validate.** `& $openspec validate --specs --json`. If validation fails, report the problems and do not claim the sync succeeded.
6. **Summarize.** Which capabilities were updated and what changed. The change stays active — archiving is a separate operation (`openspec-archive-change`).

## Guardrails

- Read both sides before every write; preserve current-spec content the delta does not mention.
- Never copy a delta file over a current spec wholesale.
- Requirement removal that would empty a spec is a retirement decision — stop and confirm with the user instead of deleting the document.
- Show what you are changing as you go.
