---
replan_id: replan-20260908-015841-accessor-consumer-declarations
status: applied
source: implementation
source_ref: task-3.1-preflight-Core-AngelscriptEngine.h-640-643
scope: task-3.1-accessor-consumer-declarations
base_commit: 62d15e1ab9721fd12ad85fec55a2fc5569dd6059
base_tasks_sha256: db7f540dbd73361b5a5943bd9201d43ac0f4b432860937e1bf9d40f0100a370e
result_tasks_sha256: 9d9de465f81e91a9ed7a54e199607d0977bea933c05c3a1ec126dcf8554947b0
created_at: 2026-09-08T01:58:41.346476+08:00
resume_task: 3.1
---

## Trigger and Evidence

Ready task 3.1 already owns Core/AngelscriptEngine*.cpp and removal of dedicated Blueprint accessor consumers. Preflight finds the paired VerifyBlueprintSetFunc and VerifyBlueprintGetFunc declarations in Core/AngelscriptEngine.h:640/:643, omitted from Files. Their definitions and the property-verification call sites are already in scope.

## Decision

Add only Core/AngelscriptEngine.h to task 3.1 for deleting these paired declarations. Requirements/design already demand consumer removal and need no semantic revision. No unrelated Engine interface is owned.

## Impact

The consumer deletion is now complete at both declaration and implementation boundaries. No new source behavior, reflection feature or startup path is added.

## Old Task Disposition

Tasks 1.1/1.2/2.1/2.2 remain complete. Pending task 3.1 retains its ID and exact proving command. All eight nodes and edges are unchanged.

## Diff Snapshot

- Task ~: 3.1 Files only; task +/-: none; edge +/-: none.
- Artifact ~: tasks.md and attachments/INDEX.md.
- Base affected status: M openspec/changes/angelscript/refactor-language-surface-ue-focused/tasks.md
- Base diff stat: .../refactor-language-surface-ue-focused/tasks.md  | 36 ++++++++++++++++------;  1 file changed, 27 insertions(+), 9 deletions(-)

## Preserved Work

SDK GREEN `5b8c8befc37c488491541315fb53f651` remains 7/7 on build `4ed68a88d7ce494680e6b7854ac8b0a9`. No implementation changed during this preflight update.

## References and Result

Candidate comparison before tracked writes proved identical frontmatter, permanent checkbox identities/history and exact proving commands. Resume task 3.1 after strict validation. The reverse patch preserves the uncommitted task text.

- [Current tasks](../../tasks.md)
- [Reverse planning patch](../data/replans/replan-20260908-015841-accessor-consumer-declarations-before.patch)
