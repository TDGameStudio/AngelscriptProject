---
record: harness-workflow-evaluation-v1
result: passed
change: harness/fix-evolution-closure-validation
closure_kind: completed
input_sha256: ed0f6a97971332f5fb46169efb2a0add9e6324a3c0e9255e125661174f69c46d
captured_at: 2026-09-04T13:25:53+08:00
---

# Workflow Evaluation

## Lifecycle

- Planned one focused terminal-policy repair with four dependency-ordered tasks.
- Reproduced the original incomplete-TaskPlan bypass through the real exported route in a temporary OpenSpec project.
- Implemented active-only TaskPlan, issue, Review, successor, digest, and terminal-evidence validation.
- Synchronized the durable Harness/OpenSpec guidance and current `harness/core` specification.
- Resolved the single material dogfooding issue; no Review or Replan was requested or required.

## Verification

- `HarnessEvolution.Tests.ps1`: PASS in approximately 2.8 seconds.
- `Protocol.Tests.ps1`: PASS.
- `OpenSpecSkill.Tests.ps1`: package safety and Skill package checks PASS.
- `workflow validate angelscript --json`: valid.
- Strict exact Change and `harness/core` spec validation: valid.
- Quick profile registration: nine fixture checks including `HarnessEvolution.PS7`; the profile itself was not executed.

## Scope boundary

No full Quick, performance, Git, Workspace, UE, build, Editor, Automation, or network validation was run. The focused fixture exercises only the changed evolution route plus the packaged OpenSpec TaskPlan interpreter, and its temporary data is removed after the run.

## Friction and corrective action

- The first active issue scan was direct-child-only and treated schema-less active records as historical. Recursive active schema validation now fails closed.
- The first digest parser normalized an uppercase hash before validation. The final route validates canonical lowercase spelling before comparison.
- The old broad Harness fixture duplicated evolution semantics. The dedicated focused fixture is now registered once in the Quick matrix, while per-edit verification invokes it directly.

## Provenance

- RED aggregate: `data/evolution-closure-red.md`.
- Resolved issue lifecycle: `implementation/issue-20260904-130017-evolution-terminal-bypass.md`.
- Digest covers every ordinary active Change input except this file, using the reported `CurrentInputSha256` immediately before this final write.
