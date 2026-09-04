---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["1.2"]
    "2.3": ["2.1", "2.2"]
    "3.1": ["2.3"]
    "3.2": ["3.1"]
---

## 1. Authoring contract

- [x] 1.1 Admit the Scenario Card authoring gap and add failing contract coverage — verify: `observable: OpenSpecSkill.Tests.ps1 exits non-zero for the missing Scenario Card contract and the indexed issue cites that RED run`
  > Files: `.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`, `openspec/changes/harness/enrich-spec-scenario-cards/attachments/INDEX.md`, `openspec/changes/harness/enrich-spec-scenario-cards/attachments/implementation/issue-20260904-*-scenario-card-authoring.md`

  > Context: The ignored Harness observation is inexpensive provenance; the indexed v2 issue becomes the durable owner because this self-hosted workflow gap crosses templates, Skills, synchronization, and current specifications.

  1. Add focused assertions for the central reference, template, workflow/profile, lifecycle links, sync semantics, README profile explanation, and lifted Skill restriction.
  2. Run the focused test and retain the expected failure command and output summary.
  3. Create one open material issue and update the attachment index in the same edit.

- [x] 1.2 Implement the progressive Scenario Card authoring contract — verify: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `.agents/skills/openspec/references/specs.md`, `.agents/skills/openspec/references/record-schema.md`, `.agents/skills/openspec/SKILL.md`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-update-change/SKILL.md`, `.agents/skills/openspec-sync-specs/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/README.md`, `openspec/workflows/angelscript/templates/spec.md`, `openspec/workflows/angelscript/workflow.yaml`, `openspec/config.yaml`, `openspec/README.md`

  > Produces: One central reference plus concise entrypoint links and prompts that teach rich cards without turning optional prose into schema.

  > Constraints: Retain `record-v1`; do not modify `requirements-v1`, workflow version 1, the parser, the packaged executable, command docs, manifests, Tools/openspec, plugins, or Unreal code.

  1. Write the central Requirement/Scenario Card, ownership, delta-sync, and validation-profile contract.
  2. Update the template, workflow/config prompts, lifecycle Skills, and compact README navigation.
  3. Make the task's focused contract test pass without weakening its assertions.

## 2. Durable Harness specifications

- [x] 2.1 Synchronize the Core and Workspace Scenario Cards and repair workspace scenario ownership — verify: `observable: strict spec validation passes and each of the four discovery/status scenario names occurs exactly once under Git-derived workspace discovery and status tiers`
  > Files: `openspec/changes/harness/enrich-spec-scenario-cards/specs/harness/core/spec.md`, `openspec/changes/harness/enrich-spec-scenario-cards/specs/harness/workspace/spec.md`, `openspec/specs/harness/core/spec.md`, `openspec/specs/harness/workspace/spec.md`

  > Produces: Two new self-hosting authoring scenarios, 14 enriched existing Core/Workspace cards, and four uniquely owned discovery/status cards.

  > Constraints: The ownership repair is an explicit current-spec structural correction, not a new Scenario-level MOVED dialect. `Target a workspace from another checkout` and `List heterogeneous worktrees` remain compact.

  1. Semantically merge the Core delta, preserving all unnamed requirements and scenarios.
  2. Merge the Workspace delta and move the four discovery/status cards out of the configuration-migration requirement.
  3. Validate unique scenario ownership, Scenario Card counts, and strict current specs.

- [x] 2.2 Synchronize the Git and Unreal Scenario Cards within their evidence boundaries — verify: `observable: strict spec validation passes and all 13 named cards retain intended clauses and quoted detail without changing any unnamed scenario`
  > Files: `openspec/changes/harness/enrich-spec-scenario-cards/specs/harness/git/spec.md`, `openspec/changes/harness/enrich-spec-scenario-cards/specs/harness/unreal/spec.md`, `openspec/specs/harness/git/spec.md`, `openspec/specs/harness/unreal/spec.md`

  > Constraints: The installed-engine concurrency card identifies fixture-level policy/lane/argument/path-isolation evidence and explicitly does not claim two real UBT builds. Do not enrich `Execute a long registered worktree`.

  1. Semantically merge the six named Git cards as complete same-name replacements.
  2. Semantically merge the seven named Unreal cards as complete same-name replacements.
  3. Confirm unrelated compact cards and requirement bodies remain byte-for-byte or semantically unchanged.

- [x] 2.3 Audit the full delta-to-current semantic merge — verify: `pwsh.exe -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1`
  > Files: `openspec/changes/harness/enrich-spec-scenario-cards/specs/harness/**/spec.md`, `openspec/specs/harness/core/spec.md`, `openspec/specs/harness/workspace/spec.md`, `openspec/specs/harness/git/spec.md`, `openspec/specs/harness/unreal/spec.md`

  > Observables: Current specs contain no delta-operation headers, every intended complete card is present, all unnamed current behavior is preserved, and the resulting counts are 29 enriched/new cards across the four capabilities.

  1. Compare every delta requirement and named scenario with its current target.
  2. Confirm same-name cards were replaced whole, new cards appended, unspecified content preserved, and the explicit workspace reparenting is unique.
  3. Run focused authoring tests and strict current-spec validation.

## 3. Verification and closure preparation

- [x] 3.1 Run the complete authoring, Skill, workflow, record, and Harness gates — verify: `pwsh.exe -NoProfile -File .agents/skills/harness/scripts/Test-Harness.ps1 -Profile Quick`
  > Files: `.agents/skills/openspec/**` excluding `.agents/skills/openspec/bin/**`, `.agents/skills/openspec-continue-change/SKILL.md`, `.agents/skills/openspec-update-change/SKILL.md`, `.agents/skills/openspec-sync-specs/SKILL.md`, `.agents/skills/openspec-verify-change/SKILL.md`, `.agents/skills/README.md`, `openspec/workflows/angelscript/**`, `openspec/config.yaml`, `openspec/README.md`, `openspec/specs/harness/**/spec.md`, `openspec/changes/harness/enrich-spec-scenario-cards/**`

  > Boundaries: This Markdown/Skill change requires no UE build. Validation covers the changed Skill packages, workflow, active/current records, structural ownership, formatting, and the Harness public quick profile.

  1. Run OpenSpec Skill tests and system `quick_validate.py` for every changed Skill package.
  2. Validate the `angelscript` workflow, current specs, exact active Change, all current records, and repository diff whitespace.
  3. Run the Harness Quick profile and investigate any in-scope failure without starting Review automatically.

- [x] 3.2 Resolve the material issue and prepare terminal self-hosting closure evidence — verify: `observable: harness.evolution.status succeeds for harness/enrich-spec-scenario-cards with RequireTerminal true`
  > Files: `openspec/changes/harness/enrich-spec-scenario-cards/tasks.md`, `openspec/changes/harness/enrich-spec-scenario-cards/attachments/INDEX.md`, `openspec/changes/harness/enrich-spec-scenario-cards/attachments/implementation/issue-20260904-*-scenario-card-authoring.md`, `openspec/changes/harness/enrich-spec-scenario-cards/attachments/data/workflow-evaluation.md`

  > Produces: A resolved evidence-backed v2 issue, one indexed passing workflow evaluation, and a fully completed Task DAG ready for deterministic completed archive.

  1. Record GREEN evidence and the bounded proof/exclusion statements in the issue, then mark it resolved and update INDEX.
  2. Write the canonical versioned workflow evaluation with the observation run provenance, lifecycle friction, corrective actions, gates, and spec-sync disposition.
  3. Run the exact terminal evolution gate, mark this node complete, rerun the gate, and hand the complete Change to the separate archive and exact scoped-commit operations.
