---
replan_id: replan-20260909-114051-finalization-provider-boundary
status: applied
source: implementation
source_ref: task 7.10 Harness runs 96efd0e8237d470ca914f3bf9f39b410 and faaa9e36758644eab53f569632184290
scope: record every compiled ToString contribution through its owning provider
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 08a8c5e0e2edf8bf847170d93aaf6e4908454b69c4d1f964e8456d26351ab3be
result_tasks_sha256: 199441f3b857351bacac43c4125be78daa7462780e054245d01316fe54b9b8c8
created_at: 2026-09-09T11:40:51.3118825+08:00
resume_task: 7.10
---

# Trigger and Evidence

Task 7.10 requires every ToString contribution to become a detached effect. The original boundary named the helper and a few effect producers, but exact execution showed that several owning providers still suppressed their contribution while recording. After selecting all compiled contributors, Harness run `96efd0e8237d470ca914f3bf9f39b410` reached 45 effects and exposed the remaining recording-only `FVector2f` type-finder call. The guarded provider and exact count then passed in `faaa9e36758644eab53f569632184290`.

# Decision

Add the six provider files whose recording behavior task 7.10 changes directly: `Bind_FDateTime.cpp`, `Bind_FName.cpp`, `Bind_FRandomStream.cpp`, `Bind_FString.cpp`, `Bind_FText.cpp`, and `Bind_FVector2f.cpp`. Existing family ownership remains valid; this correction covers only their dynamic ToString contribution path and the recording guard needed to observe it.

# Impact

The proposal, specifications, design, cases, proving selector, task ID, and dependency edges remain valid. Task 7.10 stays Ready until its shared regression and evidence are complete. No family task is reopened.

# Old Task Disposition

Task 7.10 remains active with a corrected file boundary. All forty-one completed tasks and their existing evidence remain valid.

# Diff Snapshot

- Affected path status: the parent contains the active untracked Change and modified plugin gitlink; the plugin contains the authorized reconstruction and the six provider paths named above.
- Focused provider/Engine diff at the trigger included 277 insertions and 77 deletions across the visible tracked paths, with additional new Store, Catalog, and test files still untracked in the plugin.
- Task changes: `~ 7.10` file boundary; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.

# Preserved Work

All fixed family declarations, native recipes, provider phases, task cases, and completed family evidence remain unchanged. The correction does not transfer whole provider ownership into task 7.10.

# References and Result

- Exact pre-correction run: `Saved/Harness/Unreal/Runs/96efd0e8237d470ca914f3bf9f39b410/Summary.json`.
- Exact GREEN run: `Saved/Harness/Unreal/Runs/faaa9e36758644eab53f569632184290/Summary.json`.
- Inverse task patch: `attachments/data/replans/replan-20260909-114051-finalization-provider-boundary-before.patch`.
- Result: task 7.10 resumes with all implementation-owned provider files represented explicitly.
