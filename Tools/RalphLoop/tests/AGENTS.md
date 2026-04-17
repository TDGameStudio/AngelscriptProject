# TESTS KNOWLEDGE BASE

## OVERVIEW

`tests/` owns fast smoke coverage, mocks, CLI repro scripts, and disposable output.

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Default smoke suite | `tests/test-ralph-loop.ps1` | Main regression entrypoint |
| Shared assertions | `tests/test-helpers.ps1` | Reuse for new PowerShell test files |
| Mock provider behavior | `tests/mock-agent.ps1` | Captures env + prompt artifacts |
| Mock verify behavior | `tests/mock-verify.ps1` | Controls early-stop contract |
| Timeout behavior | `tests/mock-slow-agent.ps1` | Forces timeout path |
| Reference sync coverage | `tests/test-reference-sync.ps1` | Uses local git repos only |
| Real provider coverage | `tests/test-real-agents.ps1` | Opt-in only; command-availability gated |
| Shell/encoding repros | `tests/pwsh-file-repro*.ps1` | Use only for shell-specific bugs |
| Disposable artifacts | `tests/.tmp/` | Safe to recreate; never commit reference material here |

## CONVENTIONS

- Keep `tests/test-ralph-loop.ps1` fast, deterministic, and mock-first.
- Use `tests/.tmp/` for all generated files.
- Prefer `pwsh` when wrapper behavior matters; keep Windows PowerShell coverage only where shell differences are the subject.
- Real CLI coverage for `codex` or `opencode` belongs in a separate opt-in script or explicit switch.
- Gate real CLI tests with environment checks and command-availability checks before execution.
- Assert exit codes, created files, timeout behavior, and stop conditions before asserting console text.

## ANTI-PATTERNS

- Do not replace mock smoke tests with real-agent tests.
- Do not make tests depend on SSH cloning or reference sync.
- Do not write long-lived state outside `tests/.tmp/`.
- Do not assert shell-specific formatting unless that is the exact bug under test.
- Do not require auth or network access in the default test path.
