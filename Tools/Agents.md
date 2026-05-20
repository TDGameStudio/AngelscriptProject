# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-07
**Repo Status:** no git metadata in workspace

## OVERVIEW

PowerShell-first tool workspace for project automation.
RalphLoop lives under `Tools/RalphLoop` and is intended to become the standalone `TDGameStudio/RalphLoop` repository consumed as a submodule. Root-level RalphLoop script copies are legacy and should not be extended.

## STRUCTURE

```text
Tools/
├── RalphLoop/                      # standalone-ready RalphLoop tool
├── RunBuild.ps1                    # project build runner
├── RunTests.ps1                    # project automation test runner
├── RunTestSuite.ps1                # project test-suite orchestrator
└── <planner/review tools>/         # project-specific tools that may call RalphLoop
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| RalphLoop orchestration | `Tools/RalphLoop/ralph-loop.ps1` | Main loop engine |
| RalphLoop provider profiles | `Tools/RalphLoop/agents/profiles.psd1` | Provider CLI differences |
| RalphLoop docs | `Tools/RalphLoop/README.md`, `Tools/RalphLoop/Agents.md` | Source of truth for RalphLoop behavior |
| Fast RalphLoop coverage | `Tools/RalphLoop/tests/test-ralph-loop.ps1` | Default mock-based suite |
| PRD workflow coverage | `Tools/RalphLoop/tests/test-prd-workflow.ps1` | Read-only PRD workflow suite |

## CURRENT TARGET

- Keep project-specific tools calling `Tools/RalphLoop/ralph-loop.ps1` directly.
- Keep RalphLoop-specific conventions inside `Tools/RalphLoop/Agents.md`.
- Treat root-level RalphLoop copies as legacy until removed or replaced by the submodule.

## CONVENTIONS

- Use `Tools/RalphLoop/README.md` for RalphLoop CLI examples.
- Do not add new root-level RalphLoop wrappers.
- Do not make project-specific tools depend on RalphLoop runtime output outside documented artifacts.

## ANTI-PATTERNS

- Do not extend root-level `Tools/ralph-loop.ps1` or root-level RalphLoop wrappers.
- Do not duplicate RalphLoop provider logic in project-specific tools.
- Do not make project tool tests depend on real agent CLIs unless they are explicitly opt-in.

## COMMANDS

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-ralph-loop.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File Tools\RalphLoop\tests\test-prd-workflow.ps1
cmd /c Tools\RalphLoop\run-ralph-loop.bat -Prompt "prompt text" -MaxIterations 3 -Agent codex
```

## NOTES

- Future RalphLoop edits should happen under `Tools/RalphLoop` and remain portable to the standalone repository.
- Real agent coverage belongs in RalphLoop opt-in tests, not default project smoke paths.

