---
replan_id: replan-20260908-182226-text-wildcard-metadata
status: applied
source: implementation-evidence
source_ref: task 4.8 RED run 49d0e58358dc440b813a8206852d2415
scope: admit the canonical wildcard through metadata signature definition and frozen validation
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: f9a4b95063d6bd6e35f8cca3552a25ae0a21007f129e401140f21d82d07cada5
result_tasks_sha256: 7fbf9383dca0728c6b99ec9c77eefbf41ba6ab7e4c6889a6bb187066121e1cf8
created_at: 2026-09-08T18:22:26Z
resume_task: 4.8
---

# Trigger and Evidence

After the task 4.8 parser/identity correction built successfully, exact run `49d0e58358dc440b813a8206852d2415` again produced six successes and one failure. The complete provider now parses and resolves `const ?&`, then `asCMetadataImage::DefineFunction` rejects its `ttQuestion` parameter because metadata data-type admission and canonical reconstruction know only ordinary primitives.

# Decision

Add `as_metadata_image.*` to task 4.8. Admit `ttQuestion` only as a function parameter type and reconstruct it as the canonical Wildcard identity during frozen definition validation. Retain the existing rejection for wildcard globals, properties, template arguments and return types.

# Impact

- Task 4.8, its cases, proving command and DAG remain unchanged.
- The file boundary gains the exact metadata owner exposed by the advanced RED.
- Completed work and all other pending tasks remain preserved.

# Old Task Disposition

- Task 4.8: `preserved`; resumes with the same one failing complete-provider case.
- Every other task: `preserved`.

# Diff Snapshot

- Task changes: `~4.8` file boundary; no task or edge additions/removals.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.
- Wildcard parser/identity/application implementation and successful build `db96edce3ae145009e431698381ae861` are preserved.

# Preserved Work

Six behavior cases remain green. The failure is transactional before callable attachment and does not invalidate their outputs or isolation evidence.

# References and Result

- RED summary: `Saved/Harness/Unreal/Runs/49d0e58358dc440b813a8206852d2415/Summary.json` — six successes, one failure, zero warnings.
- Diagnostic: `FText Format(const FText& Format, const ?& Arg0) no_discard`: invalid signature or callable owner.
- Inverse patch: `attachments/data/replans/replan-20260908-182226-text-wildcard-metadata-before.patch`.
- Strict validation: run `2a28ec826b424fcfabaa9ebdc781cedf`, PASS.
- Result: task 4.8 owns the metadata admission required to carry its wildcard identity to a frozen image.
