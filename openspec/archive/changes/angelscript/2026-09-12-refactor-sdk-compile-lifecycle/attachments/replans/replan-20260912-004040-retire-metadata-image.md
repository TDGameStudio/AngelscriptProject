---
replan_id: replan-20260912-004040-retire-metadata-image
status: applied
source: user
source_ref: attended 2026-09-12 request to delete MetadataImage in this Change, use DefinitionSet+Registration, comment Binding tests
scope: BindInfo leftover Image exception; Change-terminal deletion of asCMetadataImage
base_commit: 46c9c66d4f727d87687807c775f2b3dced36094e
base_tasks_sha256: E9B1AE8C1F8AD9820DCF3A8AF3EF53E262CF8162E5F79AAADC3E92A712A812AE
result_tasks_sha256: AF8158B5D85D832D97C0E0725F3C0B6008E10610750A192F3893EE6F65CC78C5
created_at: 2026-09-12T00:40:40+08:00
resume_task: 5.2
---

# Replan: retire MetadataImage in this Change

## Trigger and Evidence

User: this Change must finally remove Image-related products, use the new architecture, comment Binding tests, and replan. That falsifies the accepted BindInfo leftover: Image remains BindInfo-only; do not delete `as_metadata_image.*` while Draft/Apply still construct Image.

Draft finding `drafts/findings/metadata-image-removed.md` already deleted the type. Handoff flip condition named this path.

## Decision

Delete `asCMetadataImage` here. BindInfo owner-swaps onto `asCModuleDefinitionSet` + `asCEngineCompileRegistration` so the runtime compiles. Comment Binding tests that fail because Image is gone. Binding GREEN stays with `angelscript/refactor-bindings-two-stage-pipeline`. Do not stub Install. Do not reopen design-mode brainstorming.

## Impact

Proposal, design, definitions/builder/bytecode spec deltas, tasks header, INDEX, and planning-validation now require Image deletion. New nodes 6.1 (owner swap + comment tests) and 6.2 (delete files and Engine Image APIs). 5.2 stays public ByteCodeImage/snapshot removal.

## Old Task Disposition

| ID | Disposition |
|---|---|
| 1.1–5.1 | Remain `[x]`. Historical BindInfo leftover wording stays on those cards. |
| 5.2 | Remains `[ ]`. In-flight public ByteCodeImage/snapshot work continues. Notes: do not delete MetadataImage here. |
| 6.1 | New. Depends on 5.2. |
| 6.2 | New. Depends on 6.1. |

## Diff Snapshot

Path status (planning tree after this replan):

- `M` `tasks.md`, `proposal.md`, `design.md`, `attachments/INDEX.md`, `attachments/data/planning-validation.md`
- `M` `specs/angelscript/language/types/definitions/spec.md`
- `M` `specs/angelscript/language/frontend/builder/spec.md`
- `M` `specs/angelscript/runtime/bytecode/spec.md`
- `??` `attachments/talks/talk-20260912-003900-retire-metadata-image-in-change.md`
- `??` `attachments/replans/replan-20260912-004040-retire-metadata-image.md`

Plugin 5.2 work remains uncommitted in submodule `Plugins/Angelscript` (ByteCodeImage internalized; last `ue.build` Failed on leftover `LinkByteCodeImage`).

Task `+` 6.1, `+` 6.2. Edge `+` 6.1 after 5.2, `+` 6.2 after 6.1. Artifact `~` proposal/design/specs/tasks/INDEX/planning-validation.

## Preserved Work

1.1–5.1 GREEN evidence stays. 5.2 in-flight: public headers moved under `Private/Bytecode`, `Prepare(snapshot)` removed, proving VM tests retargeted; compile is not GREEN.

## References and Result

Talk: `attachments/talks/talk-20260912-003900-retire-metadata-image-in-change.md`. Resume `5.2`. Then `6.1`, then `6.2`.
