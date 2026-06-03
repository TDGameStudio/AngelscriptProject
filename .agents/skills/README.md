# OpenSpec Skills for AngelscriptProject

## Overview

This directory contains project-local skills that integrate [OpenSpec](https://github.com/fission-ai/openspec) (spec-driven development CLI) with [Superpowers](https://github.com/anthropics/superpowers-claude-plugins-official) (AI coding methodology plugins).

**How it fits together**

```
OpenSpec (what/where/when)          Superpowers (how)
─────────────────────────           ─────────────────
change lifecycle                    brainstorming
artifact structure                  test-driven-development
free-form records                   systematic-debugging
archive                             verification-before-completion
```

- **OpenSpec** controls the change lifecycle and artifact outputs (proposal, specs, design, tasks) plus free-form supporting files.
- **Superpowers** provides disciplined thinking and execution methods (brainstorming, TDD, debugging, verification).
- The single `openspec-work` skill weaves these together: it routes Superpowers outputs into OpenSpec paths and inlines project-specific conventions directly in the skill text.

**Project rule:** OpenSpec is the authoritative **record** system for AngelscriptProject, used in a lightweight way — not as a heavy procedural gate. Legacy `Documents/Plans/Plan_*.md` files are historical references only; do not create or extend them for active work. The current change's `tasks.md` is the working checklist, but it is a disposable living record you may rewrite freely; background notes, research, and performance/benchmark data may be stored alongside it in the change directory.

## Skills

### OpenSpec lifecycle skill

OpenSpec is a lightweight **record**, not a procedural gate. `openspec-explore`, `openspec-propose`, `openspec-apply-change`, and `openspec-archive-change` have all been **merged into the single `openspec-work` skill** — there is no phase wall between exploring, proposing, implementing, and closing.

| Skill | Trigger | Phase | Description |
|-------|---------|-------|-------------|
| `openspec-work` | `/opsx:work` (also `/opsx:explore`, `/opsx:propose`, `/opsx:apply`, `/opsx:archive`, and the `/openspec:` equivalents) | Explore + Record + Implement + Archive | One flow for the whole lifecycle. Supports explore/think-only sessions (no change created), plan-only deliverables (a thorough, ready-to-execute plan at `superpowers:writing-plans` quality, then stop without implementing), record-while-implementing, continuing an existing change, or archiving a finished one. Record depth follows intent — plan-only is thorough, implement-now can start lean. Explore/think uses `superpowers:brainstorming`. Plans are disposable; edit artifacts and code together. Archiving is an ordinary closing action (`openspec archive "<name>"`), not a gate. |

### Auxiliary skills

Auxiliary skills are NOT part of the OpenSpec lifecycle and do not own a slash command. They are read IMMEDIATELY by the lifecycle skills (typically `openspec-work` during TDD steps) or directly by the developer when a matching task surfaces. They never alter the OpenSpec change state.

| Skill | Trigger | Phase | Description |
|-------|---------|-------|-------------|
| `angelscript-test-guide` _(WIP — disabled)_ | Currently disabled; directory renamed to `_angelscript-test-guide/` so the skill loader cannot discover `SKILL.md` | Implement (test layer) | Pattern handbook for picking the test layer, helper, template, and applying Positive/Negative/Boundary/RoundTrip/Exception coverage. Re-enable by restoring the directory name to `angelscript-test-guide/`. |

## Lifecycle Flow

```
                openspec-work (one skill, whole lifecycle)
  ┌───────────────────────────────────────────────────────────┐
  │  explore/think ──► record ◄──┐                             │
  │  (brainstorming)     │       │  iterate: edit artifacts +  │
  │                      └───────┘  code together, overturn    │
  │                      │          the plan freely            │
  │                      ▼                                      │
  │                  archive  (openspec archive "<name>";       │
  │                            ordinary closing action, no gate)│
  └───────────────────────────────────────────────────────────┘

Explore/think-only is a valid session (no change need be created).
Plan-only is also valid: produce a thorough, ready-to-execute plan
(writing-plans quality) and stop — implement later on the same change.
Superpowers methods (brainstorming, TDD, systematic-debugging,
verification-before-completion) are used actively throughout.
What is relaxed is OpenSpec's own ceremony, not the engineering discipline.
Verify at key milestones (not every step); verification may be a task in tasks.md.
```

Note: `openspec-work` supports stopping after recording only — either a lean record or a full plan-only deliverable — with no implementation yet. Implementation can continue later, or in another session, on the same change. Record depth follows intent: plan-only should be thorough, not a skeleton.

## Prerequisites

### OpenSpec CLI

```powershell
# Verify installation
openspec --version

# Should output 1.x.x
```

If not installed, install via npm:

```powershell
npm install -g @fission-ai/openspec
```

### Superpowers Plugin

Superpowers must be installed as a Claude Code plugin. The skills reference these Superpowers skills:

- `superpowers:brainstorming` — requirement discovery and design thinking
- `superpowers:writing-plans` — plan structure and task decomposition methods
- `superpowers:test-driven-development` — TDD discipline for implementation
- `superpowers:systematic-debugging` — root cause investigation
- `superpowers:verification-before-completion` — evidence before claims
- `superpowers:finishing-a-development-branch` — branch completion options
- `superpowers:using-git-worktrees` — worktree isolation guidance
- `superpowers:receiving-code-review` / `superpowers:requesting-code-review` — review workflows

## Platform Compatibility

| Platform | Status | Notes |
|----------|--------|-------|
| Codex | Primary | Skills live in `.codex/skills/`, auto-discovered |
| Claude Code | Manual | `.codex/skills/` is not auto-discovered; requires `.claude/commands/` wrappers or CLAUDE.md references |
| Cursor | Separate | `.cursor/skills/` has its own skills (e.g., `full-test-suite`) |

## Upgrading

### OpenSpec CLI Upgrade

```powershell
# Upgrade CLI
npm update -g @fission-ai/openspec

# Sync instruction files after upgrade
openspec update

# Verify schema compatibility
openspec schemas --json
openspec templates --json
```

After CLI upgrade, check:
1. Schema structure unchanged (`openspec templates --json` shows same artifact IDs)
2. `openspec instructions <artifact> --change "<name>" --json` returns expected fields (`outputPath`, `template`, `instruction`, `dependencies`, `unlocks`)
3. `openspec validate --all --json` passes on any existing changes

### Superpowers Plugin Upgrade

Superpowers is managed externally by the plugin system. After upgrade:
1. Check if referenced skill names still exist (e.g., `superpowers:brainstorming`)
2. Verify default output paths haven't changed (adapters override `docs/superpowers/specs/` and `docs/superpowers/plans/`)
3. If new methods are added, evaluate whether `openspec-work` should reference them

### Skill Maintenance

When modifying the skill:
- `openspec-work` references Superpowers methods inline in its step text — adjust those references to change how Superpowers integrates with OpenSpec.
- Step numbering must be sequential within the skill.
- References should use the skill name (`openspec-work`) as primary, with `/opsx:` as supplementary.
- Project test/build conventions are inlined in `openspec-work`'s "Record the change" and project-test-conventions text — update these when `Documents/Guides/TestConventions.md` or `Documents/Guides/Test.md` change.
- Both copies of the skill (`.claude/skills/` and `.agents/skills/`) must be kept identical; verify with `Get-FileHash` after edits.

## Project Conventions Injected

These skills inject the following project-specific knowledge that Superpowers does not have:

### Test Conventions (from `Documents/Guides/TestConventions.md`)
- Test layer matrix (Runtime CppTests / Editor / Native Core / Runtime Integration / UE Functional / Bindings CQTest / Learning)
- File naming: `Angelscript` prefix required
- Automation prefix: theme-first for functional, layer-first for native/learning
- Harness: `FAngelscriptTestWorld`, `FCoverageModuleScope`, `AngelscriptNativeTestSupport.h`
- Templates in `Plugins/Angelscript/Source/AngelscriptTest/Template/`

### Build Conventions (from `Documents/Guides/Build.md`)
- Only `Tools\RunBuild.ps1` as build entry point
- Never hand-write UBT/Build.bat/RunUBT.bat commands
- Timeout constraints and `-NoXGE` / `-SerializeByEngine` rules

### Test Execution (from `Documents/Guides/Test.md`)
- Only `Tools\RunTests.ps1` and `Tools\RunTestSuite.ps1` as test entry points
- Standard groups and suites
- CQTest framework patterns

### OpenSpec Change Names
- Format: `<type>-<scope>-<outcome>` in lowercase kebab-case.
- Allowed type prefixes: `feature`, `fix`, `refactor`, `improve`, `docs`, `test`, `chore`.
- Use `feature` rather than `feat`; Git commits may still use `Feat`.
- Choose `refactor` for structural boundary/dependency/module-shape changes, and `improve` for quality, diagnostics, performance, readability, or ergonomics improvements without major structural reshaping.

## Troubleshooting

### "openspec: command not found"

CLI not in PATH. Install or check scoop/npm/nvm setup.

### "No active changes" when expecting one

Check you're in the right directory. OpenSpec discovers changes relative to project root (where `openspec/` lives).

### Validate reports errors after propose

Read the JSON output from `openspec validate "<name>" --strict --json`. Common issues:
- Missing `## Capabilities` in proposal.md
- Spec file name doesn't match kebab-case capability name in proposal
- tasks.md missing checkbox syntax

### Skills not triggering in Claude Code

`.codex/skills/` is not auto-discovered by Claude Code. Either:
- Add wrapper commands in `.claude/commands/`
- Reference skill paths in CLAUDE.md
- Use Codex as the primary platform for OpenSpec workflows
