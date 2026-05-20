# RalphLoop

RalphLoop is a PowerShell-first loop runner for repeatedly invoking agent CLIs with stable prompts, logs, run state, and optional verification.

This directory is intended to become the standalone repository `TDGameStudio/RalphLoop` and to be consumed by host projects as a submodule at `Tools/RalphLoop`.

## Capabilities

- Runs bounded agent iterations with per-run and per-iteration artifacts.
- Supports provider profiles for `codex`, `opencode`, and `claude`.
- Keeps dangerous unattended permission flags opt-in through `-TrustAgent`.
- Supports a basic prompt loop and a read-only Ralph-style PRD workflow.
- Keeps default tests mock-first and deterministic.

## Basic Usage

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ralph-loop.ps1 `
  -Prompt "Summarize this repository" `
  -MaxIterations 3 `
  -Agent codex
```

Use a custom command when you want to mock or wrap an agent:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ralph-loop.ps1 `
  -Prompt "Run one custom iteration" `
  -MaxIterations 1 `
  -AgentCommand "pwsh -NoProfile -File .\tests\mock-agent.ps1"
```

## Trusted Mode

Built-in providers use safe command templates by default. Use `-TrustAgent` only for unattended runs where the selected provider is allowed to bypass normal permission prompts.

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ralph-loop.ps1 `
  -Prompt "Autonomous iteration" `
  -MaxIterations 5 `
  -Agent codex `
  -TrustAgent
```

For Codex this enables the trusted profile template with `--dangerously-bypass-approvals-and-sandbox`. For Claude this enables the trusted profile template with `--dangerously-skip-permissions`.

## PRD Workflow

PRD mode reads a Ralph-style `prd.json`, selects the first incomplete user story by ascending `priority` and file order, and injects that story plus optional `progress.txt` content into the prompt. It does not modify `prd.json`, `progress.txt`, git branches, or commits.

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\ralph-loop.ps1 `
  -Workflow Prd `
  -PrdFile .\prd.json `
  -ProgressFile .\progress.txt `
  -Prompt "Implement the selected PRD story" `
  -MaxIterations 3 `
  -Agent claude
```

Expected PRD shape:

```json
{
  "project": "MyProject",
  "branchName": "ralph/example",
  "description": "Feature description",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add behavior",
      "description": "Story details",
      "acceptanceCriteria": ["Criterion"],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

PRD iterations write `selected-story.json` and `progress-context.txt` beside the normal iteration artifacts.

## Artifacts

Each run writes:

- `run.json`
- `state.json`
- `iter-*/prompt.txt`
- `iter-*/stdout.log`
- `iter-*/stderr.log`
- `iter-*/last-message.txt`
- `iter-*/verify.stdout.log` and `iter-*/verify.stderr.log` when verification is enabled

## Tests

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tests\test-ralph-loop.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tests\test-prd-workflow.ps1
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tests\test-ralph-loop-no-verify.ps1
```

Real provider tests are opt-in:

```powershell
$env:RALPH_TEST_REAL_AGENTS = '1'
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tests\test-real-agents.ps1 -Agents codex,opencode,claude
```

## Submodule Use

After `TDGameStudio/RalphLoop` exists, host repositories can consume it with:

```powershell
git submodule add git@github.com:TDGameStudio/RalphLoop.git Tools/RalphLoop
git submodule update --init --recursive
```
