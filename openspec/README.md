# AngelscriptProject OpenSpec

This directory is the current OpenSpec record system. The ignored `openspec-old/` directory is only a historical backup and is never scanned or migrated automatically.

## Customization

- `config.yaml`: project context, artifact rules, and apply/archive guidance.
- `workflows/angelscript/workflow.yaml`: required/optional artifacts, dependencies, operation gates, and validation profile.
- `workflows/angelscript/templates/`: proposal, specification, design, and Task DAG templates.
- `.agents/skills/openspec/commands/`: English command documentation for the packaged portable executable; read only the selected command document.

Configuration and templates are reloaded for every `instructions` call, so an Agent or PowerShell session does not need to restart. Maintained OpenSpec records use English. Files explicitly named with `_ZH` are the only temporary localization exception and are retained for later user-directed removal.

## Invocation

Import Harness once in a PowerShell 7.0-or-later (`Core`) session and reuse the context. The maintained harness does not support Windows PowerShell 5.1:

```powershell
Import-Module .\.agents\skills\harness\scripts\Harness.psd1
$context = New-HarnessContext -WorkspaceRoot $PWD

Invoke-Harness -Command openspec.doctor -Context $context -ArgumentList @('--json')
Invoke-Harness -Command openspec.workflow -Context $context -ArgumentList @('validate', 'angelscript')
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--all', '--strict', '--json')
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--archived', '--strict', '--json')
```

Do not invoke a bare `openspec` from `PATH`, the official Node CLI, or a `Tools/openspec/target` build for project operations.

## Current workflow

- A new feature, architecture refactor, or major behavior change receives deep read-only exploration before its OpenSpec Change is created unless an accepted decision-complete handoff already exists. Once the target Change exists, corrections use update/replan and never restart `openspec-explore`. Clear fixes and mechanical documentation changes may skip the pre-creation gate.
- `proposal.md` and `tasks.md` are required; apply depends on tasks.
- `specs/**/*.md` exists only for durable behavior changes.
- `design.md` exists only for non-obvious architecture, compatibility, or migration decisions.
- Durable requirements use progressive Scenario Cards from `.agents/skills/openspec/references/specs.md`; each complex behavior clause may own an immediately indented clause-owned detail block with quoted labels, prose, ordered or unordered lists, examples, or tables and no Task state, while simple clauses remain one line.
- `record-v1` and `requirements-v1` are validator profile identifiers, not a content version, storage format, or migration sequence. Scenario Cards work with either profile.
- The `angelscript` workflow continues to use `record-v1` because it requires non-empty proposal/tasks artifacts and a valid Task DAG while allowing specs to remain optional for maintenance, documentation, and internal refactors.
- `requirements-v1` is an explicit opt-in for a workflow that requires Requirement deltas in every Change; it is not an upgrade from `record-v1` or a generic validator for arbitrary paths.
- `validate --archived` audits closure provenance and Task history; it does not rerun implementation verification.
- Current archives use `closure-v1`; explicitly marked `legacy-completed-v0` records receive the legacy completed audit.

The only current execution truth for a change is `tasks.md`; a conversation or exploration handoff is not an active Change. Resolve the canonical Change and Ready Task DAG before implementation mutation. Implementation-time technical uncertainty stays inside the Ready task and triggers replan only when evidence invalidates current truth. Load attachments progressively from `attachments/INDEX.md`; Review, material implementation issues, knowledge promotion, replan, and closure policy lives under `.agents/skills/openspec/references/`.
