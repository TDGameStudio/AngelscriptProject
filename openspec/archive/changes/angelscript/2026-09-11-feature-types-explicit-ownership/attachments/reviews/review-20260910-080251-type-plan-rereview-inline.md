---
review_schema: review-v2
review_kind: external
requested_by: user
state: superseded
closed_at: 2026-09-10T08:31:24+00:00
assigned_at: 2026-09-10T08:07:13+00:00
reviewed_at: 2026-09-10T08:08:22+00:00
snapshot_ref: openspec/changes/angelscript/feature-types-external-ownership/attachments/reviews/snapshot-20260910-080251-after.json
snapshot_sha256: 997a89fbe1a129954dde7beaca7c447a052cc7d5fdd65f7f22d1930811f16920
verdict: APPROVE
---

# Revised type ownership plan review

The original user request remains applicable to the corrected deliverable. This inline re-review reads the new immutable embedded content, not a moving workspace. All manifest/part hashes were reproduced. Scope includes current SDK proposal/design/deltas/tasks/query matrix, binding planning and preserved implementation prerequisite, source excerpts and static evidence. Product correctness/completion, unrelated changes and historical alternatives are excluded. Tests-first evaluation inspected the amended proving contracts before checking their design/spec counterparts.

## Findings disposition

No open Critical or Required finding in this planning scope.

| Initial finding | Re-review evidence in final snapshot | Result |
| --- | --- | --- |
| R1 registration unit/prerequisites | design.md:29-31 selects closure commit and per-Image generation; type-registry delta:23 and :181 agrees; tasks.md:131-136 distinguishes new/mixed closure, failure and live repeat; :229 covers overlap and :270 owns actual private rejection after the Engine interface exists | Resolved |
| R2 failed-query temporary owner destruction | design.md:15 binds record lifetime to Image without strong reverse ownership; :114 retains all temporary owners outside lock guards; tasks.md:227-228 covers rejected type/function acquisition and rollback with last-owner loss and destructor Registry re-entry; type-registry delta:256 preserves the observable guarantee | Resolved |
| R3 output ownership | design.md:70 defines InvalidArgument precedence and unchanged non-null output; tasks.md:181 and GlobalQueries.Invalid preserve reference counts; type-registry delta:249 and query matrix use the same AddRef-output behavior without a const/custom lease promise | Resolved |

## Broader boundary assessment

Host-created graphs remain host-owned and immutable; receiving Engines own compiled/private graphs. Registry owns IDs and weak live lookup only. Dependency and Engine-use pins protect registration separately from metadata memory references. Global private reflection does not authorize another Engine to adopt, allocate or execute. VM instances keep explicit Engine authority and per-Engine GC; metadata ownership uses Image/refcounts, not script GC. Builder transfer, host preparation retention, private retirement and B survival are still covered by their existing planned groups. Binding task 0.1 retains its implementation/handoff prerequisite. No task edge, proving selector or scope expansion is necessary for these corrections.

## Verification and limits

APPROVE applies to consistency and implementability of this plan. Both affected Changes passed strict validation and task.status; all 37 exact proving commands parsed, and candidate task IDs/DAG/state/commands were preserved. Static evidence is embedded in the snapshot. SDK tasks remain 0/13 complete and binding tasks 0/24. No proposed C++/UE test was run, and this report cannot approve a future implementation or claim observed RED/GREEN, race safety or GC correctness. Implementation must still satisfy the recorded proving commands and source-bound handoff.

## Coordinator closure

All original Required findings are resolved by the fixed-snapshot re-review; no product completion or archive is declared.

## Later user constraint

At 2026-09-10T08:31:24+00:00, the user required VM performance preservation. Applied replan replan-20260910-083124-vm-performance-preservation adds execution baseline and non-regression acceptance. This report is superseded for the updated plan; its original snapshot, observations and APPROVE verdict remain historical. No new formal Review is implied.
