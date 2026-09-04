## Why

The project-level agent guidance currently duplicates volatile architecture, test counts, historical milestones, command details, and a second Chinese root guide. That makes the mandatory entry expensive to load and lets project policy drift away from the Skills and durable specifications that own it. Harness self-evolution guidance also presents broad profiles too prominently, which encourages routine documentation and protocol changes to run unrelated regression, performance, integration, or Unreal gates.

## What Changes

- Replace the root `AGENTS.md` with a thin canonical entry that preserves only stable project, workspace, lifecycle, execution, verification, and Git boundaries and progressively routes detailed work to Skills, OpenSpec specifications, and existing indexes.
- Delete the root `AGENTS_ZH.md` and update the two root `README.md` references so `AGENTS.md` is the sole project-level agent entry. Historical archives and `Wiki/Agents_ZH.md` remain unchanged.
- Add one focused Harness verification reference and route Harness apply, completion verification, archive, and task authoring guidance through its shared impact-scoped policy.
- Update the `harness/core` durable contract and focused static regressions so local changes start with the smallest proving scope and expand only for evidenced cross-boundary risk, release policy, or an explicit user request.
- Preserve all public Harness commands and the `Quick`, `Performance`, and `Integration` profiles; this change alters selection policy only.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/core`: Define impact-scoped verification as the default lifecycle behavior and keep one thin canonical project agent entry whose detailed policies are owned by Skills and specifications.

## Impact

The parent repository changes only: root agent/readme guidance, Harness and OpenSpec Skill Markdown, the Angelscript workflow task template, `harness/core` specification text, focused PowerShell static tests, and this OpenSpec record. Unreal code, plugin submodules, Harness route APIs, validator profiles, portable OpenSpec CLI behavior, and `Test-Harness.ps1` profile definitions are out of scope.
