---
replan_id: replan-20260915-091349-current-tag-format
status: applied
source: user
source_ref: current conversation reminder to support the new tag format
scope: tag-aware aggregate dump and comparison
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: f10138ce6a3d646c86770f8b4e9937ebe6d3e84ceb68673b8c35de1692ec9aa9
result_tasks_sha256: 39dec9a59681abf3fffb691a2ed169351f85bc735ffc543504f7581461b0d0ea
created_at: 2026-09-15T09:13:49.409187+00:00
resume_task: 1.1
---

## Trigger and Evidence

User requires compatibility with the new tag format. Inspected current container_parser, annotation_parser, validation, model, code-database spec and source/case headers. Version tags are not restricted to an ASCII identifier; annotations have escaped literal forms and typed clean-byte positions.

## Decision

Reuse the current parser. Distinguish file v1, source VersionTag and carrier format=v2. Use JSON-escaped headers and compare metadata/annotations in the same aggregate operation. No additional Automation methods. Preserve clean-byte normalization and escaped literals.

## Impact

Update design, source-preservation Scenario and task 7.3. Remove the planning verifier's blanket end-marker substring prohibition; the existing container parser owns valid literal/marker recognition.

## Old Task Disposition

~ 7.3 includes tag/annotation compatibility in its existing proof. All 50 tasks remain pending and IDs/edges are unchanged.

## Diff Snapshot

Affected Change remains untracked; tracked diff stat is empty. Task +0/-0/~1; edge +0/-0. Artifact ~ design, spec, tasks, planning verifier, INDEX. One new applied record; previous applied record remains immutable.

## Preserved Work

47 containers, two aggregate .as outputs and one comparison report, one new dump method, existing framework tests and legacy provenance scope remain unchanged.

## References and Result

[Current design](../../design.md), [tasks](../../tasks.md), [shared verifier](../scripts/verify-fixture.py). Candidate graph remains unchanged. This is a planning update, not an implementation result.
