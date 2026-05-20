# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-07
**Repo Status:** no git metadata in workspace

## OVERVIEW

PowerShell-first loop shell for repeatedly invoking agent CLIs.
Core target: keep `ralph-loop.ps1` as the runner, keep wrappers thin, and keep provider behavior isolated behind profiles. The directory is standalone-ready for `TDGameStudio/RalphLoop` and can be consumed by host projects as `Tools/RalphLoop`.

## STRUCTURE

```text
codexloop/
├── agents/                         # provider profiles and command templates
├── ralph-loop.ps1                  # main loop engine
├── stop-hook.ps1                   # verify/continue/stop contract
├── run-ralph-loop.bat              # thin Windows entrypoint
├── run-codex-loop.bat              # convenience wrapper that pins codex
├── run-opencode-loop.bat           # convenience wrapper that pins opencode
├── sync-references.ps1             # manifest-driven reference sync helper
├── prompts/loop.txt                # basic prompt skeleton for each iteration
├── prompts/prd-loop.txt            # read-only PRD workflow prompt skeleton
├── references/                     # stable local reference manifest and sync target
├── tests/                          # smoke tests, mocks, repro scripts, temp output
├── docs/superpowers/specs/         # design direction
├── docs/superpowers/plans/         # execution plan
└── .codexloop/runs/                # runtime artifacts only
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Loop orchestration | `ralph-loop.ps1` | Keep one engine; inject provider behavior before loop starts |
| Provider profiles | `agents/profiles.psd1` | Keep provider CLI differences out of the loop body |
| Stop/verify behavior | `stop-hook.ps1` | Exit contract stays agent-neutral: `0` stop, `1` continue, `>1` error |
| Windows launcher | `run-ralph-loop.bat` | Keep wrapper thin; no provider logic explosion here |
| Fixed-provider launchers | `run-codex-loop.bat`, `run-opencode-loop.bat` | Convenience wrappers; only pin `-Agent` |
| Reference sync | `sync-references.ps1`, `references/manifest.psd1` | Clone or fetch stable local references outside runtime dirs |
| Prompt contract | `prompts/loop.txt` | Add provider-neutral fields only |
| PRD prompt contract | `prompts/prd-loop.txt` | Keep PRD/progress read-only unless a caller explicitly asks otherwise |
| Fast regression coverage | `tests/test-ralph-loop.ps1` | Default suite; mock-based and deterministic |
| PRD workflow coverage | `tests/test-prd-workflow.ps1` | Mock-based coverage for PRD story selection and prompt injection |
| Reference sync coverage | `tests/test-reference-sync.ps1` | Local git-only coverage; no network dependency |
| Opt-in real CLI coverage | `tests/test-real-agents.ps1` | Requires `RALPH_TEST_REAL_AGENTS=1` and installed CLIs |
| Design updates | `docs/superpowers/specs/2026-04-07-ralph-loop-design.md` | Must describe the real multi-agent target |
| Execution roadmap | `docs/superpowers/plans/2026-04-07-ralph-loop.md` | Must track provider split, references, and real tests |

## CURRENT TARGET

- Keep `ralph-loop.ps1` as a thin loop shell that repeatedly invokes a selected agent command.
- Let `.bat` choose the prompt text, agent, and related runtime parameters.
- Support `codex`, `opencode`, and `claude` provider profiles.
- Keep built-in provider commands safe by default; require `-TrustAgent` for dangerous unattended permission-bypass templates.
- Support `-Workflow Basic` for normal repeated command execution and `-Workflow Prd` for read-only PRD/story prompt injection.
- Keep iteration artifacts stable: `prompt.txt`, `stdout.log`, `stderr.log`, `last-message.txt`, `verify.stdout.log`, `verify.stderr.log`, `run.json`, `state.json`.
- In PRD mode, also keep `selected-story.json` and `progress-context.txt` in each iteration directory.
- Default terminal output to a compact summary block plus live status lines; only stream raw agent output when `-StreamAgentOutput` is explicitly requested.
- Treat `references/manifest.psd1` and `sync-references.ps1` as supporting tooling for local study, not as the core execution path.
- Keep `.codexloop/runs/` for generated runtime state only.

## CONVENTIONS

- PowerShell owns orchestration.
- Batch files only forward arguments and choose shell.
- Prefer `pwsh`; keep `powershell.exe` as fallback only.
- Introduce generic names such as `Agent`, `AgentCommand`, `AgentHome`; keep codex aliases during migration.
- Prefer `-Prompt` as the primary input name; keep `-Task` only as a compatibility alias.
- Prefer compact status output by default; use `-StreamAgentOutput` only when you really want raw provider output in the console.
- If provider CLIs differ, normalize in a profile or wrapper, not in the core iteration body.
- Resolve configuration with this order: explicit parameter -> environment variable -> provider default.
- Do not make PRD workflow mutate `prd.json`, `progress.txt`, branches, or commits in v1.

## ANTI-PATTERNS

- Do not add new generic-path hardcoding for `codex`.
- Do not move provider selection logic into `.bat` wrappers.
- Do not put dangerous provider bypass flags in default `CommandTemplate`; use `TrustedCommandTemplate`.
- Do not store reference clones under `.codexloop/` or `tests/.tmp/`.
- Do not make default smoke tests depend on network, auth, or paid CLI calls.
- Do not assert exact model wording in real-agent tests.
- Do not auto-clone or auto-update remote references on every test run.

## COMMANDS

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-ralph-loop.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File tests/test-ralph-loop.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File tests/test-prd-workflow.ps1
cmd /c run-ralph-loop.bat -Prompt "prompt text" -MaxIterations 3 -Agent codex
cmd /c run-ralph-loop.bat -Prompt "prompt text" -MaxIterations 3 -Agent codex -TrustAgent
cmd /c run-ralph-loop.bat -Prompt "prompt text" -MaxIterations 3 -Agent codex -StreamAgentOutput
cmd /c run-codex-loop.bat -Prompt "prompt text" -MaxIterations 3
cmd /c run-opencode-loop.bat -Prompt "prompt text" -MaxIterations 3
pwsh -NoProfile -ExecutionPolicy Bypass -File ralph-loop.ps1 -Workflow Prd -PrdFile .\prd.json -ProgressFile .\progress.txt -Prompt "Implement the selected story"
```

## NOTES

- `opencode`, `codex`, and `claude` have different non-interactive CLI surfaces; isolate those differences behind provider profiles.
- Future edits should keep the shell thin: prompt strategy belongs in the prompt content, not in hardcoded PowerShell workflow branches.
- PRD workflow selects a story and injects context only; state mutation belongs to a future explicit feature.
- Existing docs started from a codex-only MVP; future edits must keep the documented target provider-neutral.
- Real CLI coverage is useful, but it should stay opt-in and artifact-focused.
- Default terminal output should remain readable: summary header first, then compact `[iteration/max] provider status... elapsed` lines; raw agent output is opt-in.

