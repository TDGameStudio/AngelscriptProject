## Why

RalphLoop is useful beyond this Unreal host project, but it currently lives as a local tool directory with duplicated root-level entry points and provider assumptions tied to the current workspace. Extracting it into a standalone-ready tool boundary lets this repository consume it as `Tools/RalphLoop` while keeping the runner reusable for other projects.

## What Changes

- Refactor RalphLoop into a standalone-ready PowerShell tool layout under `Tools/RalphLoop`.
- Preserve the existing basic loop runner behavior for repeated command execution.
- Add a read-only PRD workflow that selects the next unfinished Ralph-style user story and injects it into the iteration prompt.
- Add a Claude provider profile alongside Codex and opencode.
- Add an explicit trusted-agent mode so dangerous provider flags are opt-in.
- Update RalphLoop documentation and usage examples for standalone repository and submodule use.

## Capabilities

### New Capabilities
- `ralphloop-runner`: Runs agent CLI iterations with provider profiles, logging artifacts, verification hooks, timeout handling, and explicit trusted mode.
- `ralphloop-prd-workflow`: Reads Ralph-style `prd.json` and `progress.txt`, selects the next incomplete story, and injects read-only story context into loop prompts.

### Modified Capabilities
- None.

## Impact

- Affected tool code: `Tools/RalphLoop/ralph-loop.ps1`, provider profiles, prompt templates, wrappers, and RalphLoop tests.
- Affected docs: RalphLoop `README.md`/`Agents.md` and project tooling references that mention root-level RalphLoop entry points.
- No Unreal plugin runtime, editor, or test module behavior is changed.
