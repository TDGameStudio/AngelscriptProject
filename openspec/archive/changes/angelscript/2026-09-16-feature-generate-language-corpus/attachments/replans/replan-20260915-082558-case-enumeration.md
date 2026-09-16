---
replan_id: replan-20260915-082558-case-enumeration
status: applied
source: user
source_ref: current-session-case-enumeration-correction
scope: consumer case enumeration and canonical source lookup across all 122 generators
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: 32cca1ac5adda39547fcd74b7ca8fbf2753c8470d30a3514a33393b5f863a8e7
result_tasks_sha256: 759e8bdab210f7f4b81df3e621c9cba696c4114058fef102c6db1f4b64b92fff
created_at: 2026-09-15T08:25:58.196307+00:00
resume_task: '1.1'
---

# Case descriptor interface replan

## Trigger and Evidence

The user identified that entry names and source counts did not provide a usable case list to an execution consumer. The inspected ForLoop header and all 122 product task interfaces lacked normal/fault enumeration; the prior GetExpected fallback could not identify invalid IDs.

## Decision

Add owned descriptors through ListCases and canonical source through BuildCaseSource to each concrete product. Descriptors carry exact declarations, optional typed observations and explicit execution support. Keep the base empty and leave actual AS execution outside scope. See the indexed consumer-interface talk and current design for exact data contracts.

## Impact

Proposal and specification add consumer discovery/addressing requirements. Task 1.1 produces a shared data-only header and implements it on ForLoop; all other product tasks consume it. Every product adds metadata/source consistency cases. The final acceptance task tests descriptor-driven dispatch without an AS engine.

## Old Task Disposition

All 123 pending task IDs are preserved and revised in place. No completed tasks existed. No product, cell, old fixture or existing ForLoop interface is removed.

## Diff Snapshot

- Before: the exact Change directory was untracked in the parent workspace; no plugin implementation file is edited by this replan.
- Task ~: 1.1 shared types and baseline producer; all 121 other products add descriptor APIs/tests; 14.1 adds consumer proof.
- Edge +: 121 product tasks now directly depend on 1.1. Existing 14.1 prerequisites remain all 122 products.
- Artifact ~: proposal, specification delta, design, tasks, source-export precedence notices, glossary, thirteen catalogs and planning-validation.
- Attachment +: one applied replan and one decision talk, both indexed exactly once.
- Candidate graph: computed in memory, exact 123-key/body equality and acyclic dependencies checked before tracked writes.

## Preserved Work

All 122 products, 36,686 declared cells and int32 observation limits remain. C++ implementation and generated-AS execution have not started. Existing five ForLoop tests remain controls.

## References and Result

Resume task 1.1 after strict validation. Its output unblocks other product implementations. The final acceptance task remains blocked until every product is proven. This record is an applied semantic change, not execution evidence.
