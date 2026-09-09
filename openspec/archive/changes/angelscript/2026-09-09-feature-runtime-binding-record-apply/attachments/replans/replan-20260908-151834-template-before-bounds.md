---
replan_id: replan-20260908-151834-template-before-bounds
status: applied
source: dependency
source_ref: task 4.5 RED run 3bb2692bf704422b82eedce6e3400828
scope: require the template-instance foundation before the complete bounds family surface
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 15cd6f190b147aafb933187b695e64331b1fb428fce71aacb77b4ffcdd2544a6
result_tasks_sha256: 5f331c63680c913d2bdb1893c28d54a750b665b92ccfa51d885e85946b57548a
created_at: 2026-09-08T15:18:34Z
resume_task: 5.2
---

# Trigger and Evidence

Task 4.5's grouped run executed seven cases. The complete 144-record bounds provider inventory passed, while all six Engine-backed cases failed before allocation with `unknown nominal type` for `void f(const TArray<FVector>& Points)` from `FBoxSphereBounds.Functions`. `FSphere.Functions` contains the same complete-surface dependency.

Task 4.2 intentionally publishes only non-template declarations because the generic template installer does not yet exist. Task 5.2 owns the `TArray`, `TSet`, `TMap` and optional template declarations, specializations and native adapters. The prior edge `4.5 -> 4.2` therefore omitted a required interface handoff.

# Decision

Add task 5.2 as a direct prerequisite of task 4.5. Document the consumed `TArray<T>` template declaration and adapter in the 4.5 card. Resume at ready task 5.2, then rerun the already prepared 4.5 group without removing or fabricating any bounds members.

# Impact

- Proposal, durable specifications and design remain valid.
- Task scope and IDs remain unchanged.
- The Task DAG gains one dependency edge: `4.5 -> 5.2`.
- Task 4.5 becomes blocked until 5.2 completes; 5.2 remains Ready because its existing prerequisite 4.2 is complete.
- Downstream tasks already depending on 4.5 inherit the corrected ordering.

# Old Task Disposition

- Task 4.5: `preserved`; pending with one newly explicit prerequisite.
- Task 5.2: `preserved`; becomes the resume task.
- Completed tasks and their evidence: `preserved`.

# Diff Snapshot

- Affected current artifact: `tasks.md` (untracked within the active uncommitted Change).
- Task changes: `~4.5` explanatory handoff only; no task additions or removals.
- Edge changes: `+ 4.5 -> 5.2`.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.
- Workspace stat at capture included the existing parent gitlink plus unrelated root edits; plugin work had 41 modified tracked files and the active untracked implementation files. No unrelated path was changed by this replan.

# Preserved Work

The 4.5 test fixture, 144-record inventory proof, six failing behavior cases, four recording-aware namespace corrections and successful setup build remain valid. Run `3bb2692bf704422b82eedce6e3400828` is retained as the task's grouped RED evidence. Task 4.5 is not marked complete.

# References and Result

- RED summary: `Saved/Harness/Unreal/Runs/3bb2692bf704422b82eedce6e3400828/Summary.json` — one success, six failures, zero warnings, exit 255.
- Inverse task patch: `attachments/data/replans/replan-20260908-151834-template-before-bounds-before.patch`.
- Candidate strict validation: run `aa0bb3d6f6534bef8029452635354cd9`, PASS.
- Result: task 5.2 is the correct Ready resume node; task 4.5 resumes after its template handoff is proven.
