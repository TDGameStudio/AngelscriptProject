---
name: openspec
description: Use when running any OpenSpec operation in this project — starting, continuing, updating, implementing, verifying, syncing, or archiving a change, or inspecting domains, specs, and artifact status. Defines how to locate and invoke the portable Rust openspec.exe instead of the official Node CLI, and the lifecycle operation flows built on it.
---

# OpenSpec Portable CLI (Primitive)

This skill is the single source of truth for **which OpenSpec binary to run and how**. Other skills (change lifecycle, explore, etc.) should reference this skill instead of re-documenting CLI invocation.

## The binary

An optimized **Release build** of the portable executable ships inside this skill folder. Use this fixed runtime location for every project operation:

```text
<repo-root>/.agents/skills/openspec/bin/openspec.exe
```

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/openspec/bin/openspec.exe"
& $openspec change list --json
```

**Never invoke bare `openspec`.** On this machine, PATH resolves `openspec` to the official Node CLI installed globally via npm/scoop. That is a different product with an incompatible command surface (`new`, `list`, `set`, `context-store`, `--store`, ...). The portable binary is manifest-model only. Always call the exe by its full path.

`.agents/skills/openspec/bin/openspec.exe` is the runtime entry point for skills and normal operations; do not use `cargo run` and do not make a skill depend directly on `target/`. The Rust source of truth remains the `Tools/openspec` submodule. After source changes, rebuild and refresh the bundled Release copy (Rust 1.75+):

```powershell
# inside Tools/openspec
cargo build --release
Copy-Item target/release/openspec.exe ../../.agents/skills/openspec/bin/openspec.exe -Force
& ../../.agents/skills/openspec/bin/openspec.exe --version
```

## Command surface (v0.6.0, manifest model)

Prefer JSON when a command exposes `--json` and an agent consumes the result. Treat the bundled executable's `--help` output and `Tools/openspec/openspec/commands/` as the exact command contract for that version.

| Command | Purpose |
|---|---|
| `init [path] [--project-id <id>] [--title <t>] [--workflow <w>]` | Create only `project.yaml`, `config.yaml`, and empty type-first roots |
| `doctor [--json]` | One deterministic snapshot of the repository with all structural diagnostics |
| `validate <id> [--type change\|spec]` | Validate one active change or current spec with the object's selected workflow profile |
| `validate --all\|--changes\|--specs\|--archived [--strict] [--json]` | Batch-validate active records, current specs, or the fixed archived `tasks.md` contract |
| `domain create <id>` | Create a domain plus any missing parent domains |
| `domain list` / `domain show <id>` | Discover domains or resolve one canonical ID/alias |
| `domain move <id> --to <id>` | Cascade a domain move through descendant domains, specs, and changes |
| `spec create <domain>/<leaf> [--title] [--description]` | Create a specification object in a registered domain |
| `spec list` / `spec show <id>` / `spec move <id> --to <id>` | Discover, resolve, or move specs (UID preserved, old ID kept as alias) |
| `change create <domain>/<leaf> [--title] [--goal] [--affected-area <a>]...` | Create an active change with `change.yaml` |
| `change list` / `change show <id>` / `change move <id> --to <id>` | Discover, resolve, or move active changes |
| `change archive <id> [--date YYYY-MM-DD]` | Pure directory move to the dated archive plus `archived_at`; no spec merge |
| `status --change <id> [--workflow <w>]` | Artifact/operation readiness for one change |
| `instructions <artifact> --change <id>` | Template, project context/rules, dependencies, resolved `contextFiles`, output path |
| `instructions apply\|archive --change <id>` | Operation readiness and editable project guidance |
| `workflow list` / `which <name>` / `validate [name]` | Inspect resolved workflow definitions and sources |
| `workflow fork <source> [name]` / `workflow init <name>` | Materialize or scaffold a project-local workflow package |
| `completion generate\|install\|uninstall` | Shell completion management |

Identity rules: spec and change IDs are always full `<domain>/<leaf>` paths (e.g. `engine/runtime/compiler/rework-types`); domain segments must be registered; leaves are lowercase kebab-case; moves preserve `uid` and retain the old canonical ID as an alias; IDs resolve case-insensitively.

## What the binary does NOT do

- No `new` / `list` / `show` / `archive` top-level legacy routes, no `set`, no `--store` flag, and no `context-store` / `initiative` / `workspace` subsystem — those belong to the official Node CLI and must not appear in prompts or skills targeting this binary. Top-level `validate` is a restored first-class command implemented against the manifest/workflow model, not a compatibility route for old Node behavior; it does not support `.openspec.yaml`, `skip_specs`, or merge archive.
- No spec merge on archive: `change archive` is a content-preserving move.
- No AI-tool detection, skill/slash-command generation, `AGENTS.md` editing, or writes into `.agents/` / `.claude/` / `.cursor/` — skills like this one are maintained by the project, not by the CLI.
- No telemetry, HTTP client, machine-global config command, or feedback submission.

## Directory model quick reference

```text
openspec/
├── project.yaml            # repository manifest
├── config.yaml             # editable workflow selector, context, rules, operations
├── workflows/              # optional project-local workflow packages
├── domains/<...>/domain.yaml
├── specs/<domain>/<leaf>/spec.yaml      + project-owned documents
├── changes/<domain>/<leaf>/change.yaml  + proposal/design/tasks/etc.
├── archive/changes/<domain>/<date>-<leaf>/
└── legacy-history/         # optional, not inspected
```

`openspec/config.yaml` is the normal customization point: `workflow` selects the workflow (embedded fallback: `spec-driven`), `context` carries project background, `rules` and `operations` carry per-artifact and per-operation guidance. Unknown keys are rejected. The embedded `spec-driven` workflow has no hard dependency edges between `proposal` / `specs` / `design` / `tasks`.

## Current project state (important)

The root `openspec/` in AngelscriptProject is initialized with the manifest model:

- `openspec/project.yaml` identifies `angelscript-project` and selects `angelscript` as the default workflow;
- `openspec/config.yaml` is the editable project prompt, artifact-rule, and apply/archive-guidance surface;
- `openspec/workflows/angelscript/` is the only current project-local workflow and template package;
- `openspec/domains/`, `specs/`, `changes/`, and `archive/changes/` are the CLI-managed type roots;
- `openspec-old/` is ignored legacy history outside the active CLI repository and must not be migrated, scanned, or rewritten automatically.

Grouped mutating commands may now operate against the root repository. Run `doctor --json` before structural writes. Do not fabricate or manually move `project.yaml`, `domain.yaml`, `spec.yaml`, or `change.yaml`; use the corresponding `domain/spec/change` commands so object identity remains valid.

## Lifecycle operations

The operational flows for acting on a change. **Content standards live in the sibling `openspec-schema` skill** — what a change looks like on disk, how to write `tasks.md`, how to write attachments. There is no phase wall: operations run at any time, in any order; plan-only (record and stop) is a first-class mode.

Four operations have dedicated skills carrying their full authoritative procedure — this file keeps only a one-line summary for each:

| Operation | Skill |
|---|---|
| Continue — create the next artifact | `.agents/skills/openspec-continue-change/SKILL.md` |
| Implement — work the task list | `.agents/skills/openspec-apply-change/SKILL.md` |
| Sync specs — merge deltas into current specs | `.agents/skills/openspec-sync-specs/SKILL.md` |
| Archive — close policy + primitive | `.agents/skills/openspec-archive-change/SKILL.md` |

**Selecting a change.** If the user names one, use it. If exactly one is active (`change list --json`), auto-select. Otherwise present the few most recently modified with their progress and ask. Always announce: "Using change: `<id>`".

**Consuming `instructions` output.** `template` is the structure to fill. `context` and `rules` are **constraints for you, never content for the file** — do not copy them into any artifact. Re-read `dependencies` files from disk, not from conversation memory. Write to the returned output path and verify the file exists afterwards.

### Start

Understand what the user wants to build first — do not proceed without that. If the request spans multiple independent subsystems, recommend splitting into separate changes. Then: `change create <domain>/<leaf>` → `status --change <id> --json` → `instructions <first-artifact> --change <id> --json` → show the template and stop for direction. If the ID already exists, suggest continuing that change.

### Continue

Create the **next** artifact, one per invocation; `specs` and `design` are conditional. Full procedure: `openspec-continue-change` skill.

### Update

Revise existing planning artifacts and keep them coherent; never edit code here. Reconcile in **any direction** — an edit to `tasks.md` may require revising `proposal.md`. Edit only files that already exist. Show each proposed revision and why; write only after the user confirms. If the request changes the change's *intent*, recommend a fresh change.

### Implement

Work `tasks.md` with verification discipline: review the plan critically first, verify before checking any box, pause instead of guessing. Full procedure: `openspec-apply-change` skill.

### Verify (advisory)

Check implementation against artifacts on completeness / correctness / coherence; report CRITICAL / WARNING / SUGGESTION with file-and-line recommendations. Informs the user; never gates archiving.

### Sync specs

The CLI **never merges specs** — archive is a pure move — so merging delta specs into current specs is always agent-driven: merge, don't overwrite; idempotent. Full procedure and merge semantics: `openspec-sync-specs` skill.

### Archive

The `change archive` CLI primitive only writes `archived_at` and moves the directory; it does not merge specs, clean attachments, or check task completion. The project's strict close policy (doctor, strict validation, task completion, attachment closure, spec sync) and the archive procedure live in the `openspec-archive-change` skill — never treat the bare primitive as validation.

### Typical command flow

```powershell
$openspec = Join-Path (git rev-parse --show-toplevel) ".agents/skills/openspec/bin/openspec.exe"

& $openspec doctor --json                                  # health first
& $openspec change create engine/runtime/my-change --title "My change" --goal "..."
& $openspec status --change engine/runtime/my-change --json
& $openspec instructions proposal --change engine/runtime/my-change --json
# ... write artifacts to the returned output path, implement, update tasks ...
& $openspec validate engine/runtime/my-change --type change --strict --json
# ... ensure tasks are complete, attachments are trimmed, and durable specs are synced or explicitly N/A ...
& $openspec change archive engine/runtime/my-change
& $openspec validate --archived --json
```
