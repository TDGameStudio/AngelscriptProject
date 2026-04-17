# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-07
**Repo Status:** no git metadata in workspace

## OVERVIEW

Windows-first PowerShell loop shell for repeatedly invoking agent CLIs.
Core target: let `.bat` drive the prompt text and parameters, let `ralph-loop.ps1` handle the repeated invocation and logging, and keep provider support focused on `codex` and `opencode` first. Reference sync and real CLI tests are supporting capabilities, not the core loop contract.

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
├── prompts/loop.txt                # prompt skeleton for each iteration
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
| Fast regression coverage | `tests/test-ralph-loop.ps1` | Default suite; mock-based and deterministic |
| Reference sync coverage | `tests/test-reference-sync.ps1` | Local git-only coverage; no network dependency |
| Opt-in real CLI coverage | `tests/test-real-agents.ps1` | Requires `RALPH_TEST_REAL_AGENTS=1` and installed CLIs |
| Design updates | `docs/superpowers/specs/2026-04-07-ralph-loop-design.md` | Must describe the real multi-agent target |
| Execution roadmap | `docs/superpowers/plans/2026-04-07-ralph-loop.md` | Must track provider split, references, and real tests |

## CURRENT TARGET

- Keep `ralph-loop.ps1` as a thin loop shell that repeatedly invokes a selected agent command.
- Let `.bat` choose the prompt text, agent, and related runtime parameters.
- Support `codex` and `opencode` first; treat other providers as optional future work.
- Keep iteration artifacts stable: `prompt.txt`, `stdout.log`, `stderr.log`, `last-message.txt`, `verify.stdout.log`, `verify.stderr.log`, `run.json`, `state.json`.
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

## ANTI-PATTERNS

- Do not add new generic-path hardcoding for `codex`.
- Do not move provider selection logic into `.bat` wrappers.
- Do not store reference clones under `.codexloop/` or `tests/.tmp/`.
- Do not make default smoke tests depend on network, auth, or paid CLI calls.
- Do not assert exact model wording in real-agent tests.
- Do not auto-clone or auto-update remote references on every test run.

## COMMANDS

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-ralph-loop.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File tests/test-ralph-loop.ps1
cmd /c run-ralph-loop.bat -Prompt "prompt text" -MaxIterations 3 -Agent codex
cmd /c run-ralph-loop.bat -Prompt "prompt text" -MaxIterations 3 -Agent codex -StreamAgentOutput
cmd /c run-codex-loop.bat -Prompt "prompt text" -MaxIterations 3
cmd /c run-opencode-loop.bat -Prompt "prompt text" -MaxIterations 3
```

## NOTES

- `opencode` and `codex` have different non-interactive CLI surfaces; isolate those differences behind provider profiles.
- Future edits should keep the shell thin: prompt strategy belongs in the prompt content, not in hardcoded PowerShell workflow branches.
- Existing docs started from a codex-only MVP; future edits must keep the documented target provider-neutral.
- Real CLI coverage is useful, but it should stay opt-in and artifact-focused.
- Default terminal output should remain readable: summary header first, then compact `[iteration/max] provider status... elapsed` lines; raw agent output is opt-in.

