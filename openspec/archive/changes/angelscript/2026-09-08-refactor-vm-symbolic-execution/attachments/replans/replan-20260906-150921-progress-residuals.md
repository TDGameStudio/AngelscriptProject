---
replan_id: replan-20260906-150921-progress-residuals
status: applied
source: review
source_ref: "attachments/reviews/review-20260906-145538-progress-reviewer.md P01-P05"
scope: "Follow-up owners for incomplete 6.4/7.1 proof and serial Context/snapshot writes before 8.3"
base_commit: d8343d314f0b948a43a323fc443cf305ff2f5dc3
base_tasks_sha256: 24d36331b6fc818accdc077087e0de4ef661ac5f24a5a59cde21927182c35313
result_tasks_sha256: edc3c32d9efe4613e9a58d7b8484204718733c167eafab2e07f13407a12f26f1
created_at: 2026-09-06T15:09:21+08:00
resume_task: "6.5"
---

## Trigger and Evidence

Progress External Review `review-20260906-145538-progress-reviewer.md` is CHANGES_REQUIRED. P03/P04 show checked 6.4 admits unterminated fallthrough, skips `CallEffect==0xFFFF`, and treats cleanup as a function-wide set. P01/P02 show checked 7.1 stores raw published pointers and `ActiveScriptData` recurses when `scriptData` is absent. P05's MissingBinding oracle is already aligned; destructor-once remains 8.3. Completed IDs cannot be unchecked; residual contracts need new owners.

## Decision

Add 6.5 after 6.4 for signature-derived call effects, CFG termination and Normal/Exception path cleanup. Add 7.3 after 7.2 for publication/Context snapshot leases and non-recursive no-code Prepare. 8.3 now requires 7.3 because both write `as_context.*`, `as_execution_snapshot.*` and `as_scriptengine.*`. Put 6.5 on 11.3 so it cannot be skipped. Keep 6.4 and 7.1 checked with `needs_followup`.

## Impact

Task IDs +2. Edges: 6.5←6.4, 7.3←7.2, 8.3←7.3, 11.3←6.5. Requirements and capability deltas unchanged. 9.1/9.2 stay after 7.2; overlapping Context/opcode Files still serialize at apply time.

## Old Task Disposition

- 6.4 preserved + needs_followup → 6.5
- 7.1 preserved + needs_followup → 7.3
- 8.2 preserved; P05 destructor oracle is 8.3
- All other checked nodes preserved with existing evidence

## Diff Snapshot

```text
?? openspec/changes/angelscript/refactor-vm-symbolic-execution/
```

- Task +: 6.5, 7.3
- Task ~: 6.4/7.1 disposition; 8.3 after 7.3 and destructor oracle; 11.3 after 6.5
- Edge +: 6.5←6.4, 7.3←7.2, 8.3←7.3, 11.3←6.5
- Artifact ~: tasks.md, INDEX.md, design.md, proposal.md, acceptance-gap-matrix.md
- Artifact +: this applied record

## Preserved Work

No product/test source is edited by this record. Prior applied replans and both Review files stay immutable. Historical 1.1-5.5 and follow-ups 6.1-8.2 remain `[x]`.

## References and Result

Resume at 6.5 (Ready, disjoint from 7.3). Then 7.3, then 8.3. `result_tasks_sha256` is filled after the saved tasks hash. Strict change validation is the planning proof; no UE run is claimed here.
