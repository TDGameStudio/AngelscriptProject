# OpenSpec Skills for AngelscriptProject

## Overview

This directory contains project-local skills that integrate [OpenSpec](https://github.com/fission-ai/openspec) (spec-driven development CLI) with [Superpowers](https://github.com/anthropics/superpowers-claude-plugins-official) (AI coding methodology plugins).

**Architecture pattern: Adapter**

```
OpenSpec (what/where/when)          Superpowers (how)
─────────────────────────           ─────────────────
change lifecycle                    brainstorming
artifact structure                  writing-plans
dependency ordering                 test-driven-development
validation & archive                systematic-debugging
                                    verification-before-completion
        ┌───────────────────┐
        │  Adapter Skills   │  ← this directory
        │  (SUPERPOWER-BEGIN│
        │   /END blocks)    │
        └───────────────────┘
```

- **OpenSpec** controls the change lifecycle and artifact outputs (proposal, specs, design, tasks).
- **Superpowers** provides disciplined thinking and execution methods (brainstorming, TDD, debugging, verification).
- **Adapter blocks** (`<!-- SUPERPOWER-BEGIN/END -->`) override Superpowers defaults to route outputs into OpenSpec paths and inject project-specific conventions.

**Project rule:** OpenSpec is now the authoritative planning system for AngelscriptProject. Legacy `Documents/Plans/Plan_*.md` files are historical references only; do not create or extend them for active work. During implementation, the current OpenSpec change's `tasks.md` is the only active plan.

## Skills

### OpenSpec lifecycle skills

| Skill | Trigger | Phase | Description |
|-------|---------|-------|-------------|
| `openspec-explore` | `/opsx:explore`, `/openspec:explore` | Think | Investigate ideas, compare options, clarify requirements. No code changes. |
| `openspec-propose` | `/opsx:propose`, `/openspec:propose` | Design | Create/continue a change: brainstorm → write artifacts → validate. No code changes. |
| `openspec-apply-change` | `/opsx:apply`, `/openspec:apply` | Implement | Execute tasks from a change with TDD/debugging discipline. Writes code. |
| `openspec-archive-change` | `/opsx:archive`, `/openspec:archive` | Close | Archive a completed change via CLI. Lifecycle action only. |

### Auxiliary skills

Auxiliary skills are NOT part of the OpenSpec lifecycle and do not own a slash command. They are read IMMEDIATELY by the lifecycle skills (typically `openspec-apply-change` during TDD steps) or directly by the developer when a matching task surfaces. They never alter the OpenSpec change state.

| Skill | Trigger | Phase | Description |
|-------|---------|-------|-------------|
| `angelscript-test-guide` _(WIP — disabled)_ | Currently disabled; directory renamed to `_angelscript-test-guide/` so the skill loader cannot discover `SKILL.md` | Implement (test layer) | Pattern handbook for picking the test layer, helper, template, and applying Positive/Negative/Boundary/RoundTrip/Exception coverage. Re-enable by restoring the directory name to `angelscript-test-guide/`. |

## Lifecycle Flow

```
explore ──► propose ──► [user review] ──► apply ──► [verification] ──► finish-branch ──► archive
  │              │                           │
  │   brainstorming thinking        TDD / debugging / verification methods
  │              │                           │
  └── no code    └── only openspec artifacts └── real code changes
```

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
3. If new skills are added, evaluate whether they need adapter blocks in `openspec-apply-change`

### Skill Maintenance

When modifying these skills:
- Adapter blocks (`<!-- SUPERPOWER-BEGIN/END -->`) are the integration boundary. Edit them to adjust how Superpowers methods integrate with OpenSpec.
- Step numbering must be sequential within each skill.
- Cross-skill references should use skill names (`openspec-propose`, `openspec-apply-change`) as primary, with `/opsx:` as supplementary.
- Project test/build conventions are inlined in `openspec-artifact-awareness` and `project-test-conventions` blocks — update these when `Documents/Guides/TestConventions.md` or `Documents/Guides/Test.md` change.

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
