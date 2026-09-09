---
replan_id: replan-20260908-170752-string-declaration-suffixes
status: applied
source: implementation-evidence
source_ref: task 4.7 RED run 6275b187ade94d58bac0b1a3085771ee
scope: parse the existing FString callable suffixes required by the complete detached provider surface
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 2c741c1b0d13704a6d5a63145919298c8e1452a52e64cf30405ca3551b122e30
result_tasks_sha256: 378c1264a38afcdb7a9282bcae20220d4d81f7b06ff47012d932450bfb11fe19
created_at: 2026-09-08T17:07:52Z
resume_task: 4.7
---

# Trigger and Evidence

Task 4.7's exact six-case group failed six cases with zero warnings in run `6275b187ade94d58bac0b1a3085771ee`. After the provider was made safe to enter without an Engine, every Engine-backed case stopped during detached validation at the real declaration `FString& Append(const FString& Other) accept_temporary_this`. The parser reported `unexpected tokens after callable declaration (bytes 38..59)`.

The provider inventory and task outcome require the complete existing FString surface, including its `accept_temporary_this` and `no_discard` suffixes. The accepted task file boundary omitted the declaration parser that owns this grammar.

# Decision

Add `ThirdParty/angelscript/source/frontend/as_binding_declaration.*` to task 4.7's owned files and state the two existing suffixes explicitly in the task outcome. The parser will accept these suffixes as declaration attributes after a callable signature. This does not change callable identity, the Task DAG, or ownership of dynamic cross-type `ToString` contributions in task 7.10.

# Impact

- Proposal, durable specifications, design and dependency edges remain valid.
- Task 4.7 keeps its ID, exact proving command and six prepared cases.
- The task's implementation boundary expands by one focused parser pair.
- Later providers using the same existing suffix grammar consume the corrected parser behavior.

# Old Task Disposition

- Task 4.7: `preserved`; remains active with its grouped RED evidence.
- Completed tasks and their evidence: `preserved`.
- All other pending tasks and DAG edges: `preserved`.

# Diff Snapshot

- Affected current artifact: `tasks.md` within the active uncommitted Change.
- Task changes: `~4.7` file boundary and explicit suffix handoff; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.
- Implementation evidence at capture consisted of the new string/name test fixture plus bounded FString/FName recording guards; unrelated root and plugin workspace changes were preserved.

# Preserved Work

The six task cases, the successful setup build `7c010d8951554049b3e8480746cb5a08`, the initial Engine-access crash `2716fcb2fe6042cf95ce1a462e0a6f93`, and the complete non-crashing six-failure run remain valid. No case or provider declaration is removed to bypass the parser boundary.

# References and Result

- RED summary: `Saved/Harness/Unreal/Runs/6275b187ade94d58bac0b1a3085771ee/Summary.json` — six failures, zero warnings, exit 255, SHA-256 `e12eb5abf956cbde98240799eb9d772137da39a1cc34e1163346fdc894206b9c`.
- Exact parser diagnostic: `Saved/Harness/Unreal/Runs/c30eef49aad34deca9504dc52e280f73/Unreal.log` at the task fixture failure.
- Inverse task patch: `attachments/data/replans/replan-20260908-170752-string-declaration-suffixes-before.patch`.
- Candidate strict validation: run `5f60f005ab3b41309de258e50b0df388`, PASS.
- Result: task 4.7 remains the Ready resume node with its required grammar owner in scope.
