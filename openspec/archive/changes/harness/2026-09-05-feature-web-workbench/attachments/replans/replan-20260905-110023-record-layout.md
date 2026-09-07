---
replan_id: replan-20260905-110023-record-layout
status: applied
source: user
source_ref: user-feedback-change-document-selection-and-layout
scope: vertical Change document navigation and usable desktop layout
base_commit: d4f69984b0611ca44956577c242266edad24002b
base_tasks_sha256: 9dc483182ac583e45688d2d0300c8e30d90c81fee577ecc44eec4c12b885eb23
result_tasks_sha256: d1e5ed221d4db043827b12d55b142252b0046d8e2619cc543abf1b8ba4873d3a
created_at: 2026-09-05T11:00:23.8893231+08:00
resume_task: "3.3"
---
## Trigger and Evidence

The user reported difficult selection in horizontal Change document tabs, excessive left/right blank space in the selected records page, and requested a layout/style inspection. At 1600px, browser measurements showed the document body beginning at x688/y508 with a 780px cap; tabs required 2101px of content in a 947px viewport and tasks.md was outside the initial visible area. At 375px, document content began at y769. This invalidates the accepted selected-record arrangement while preserving functional behavior already verified.

## Decision

Use a vertical searchable file explorer beside the reading pane. Replace the competing record list in selected mode with compact back and record-switch controls, retaining record filters and URLs. Reduce shared desktop gutters and repetitive header space. Keep long paths distinguishable, active selection accessible, and narrow navigation usable.

## Impact

Proposal and design now record this layout; the delta specification adds observable record-document navigation behavior. Add task 3.3 after completed 3.2. Refresh only affected UI/browser verification and final closure identity after implementation.

## Old Task Disposition

Tasks 1.1 through 3.2 remain complete with their earlier evidence. The previous terminal evaluation becomes stale while task 3.3 is pending. No completed work is unchecked.

## Diff Snapshot

- Affected status: Tools/harness-web/, the active Change, and openspec/specs/harness/web/ are new untracked paths owned by this work; existing unrelated dirty paths remain outside scope.
- Existing tracked integration diff: OpenSpec Skill 1 line replaced; reference retrieval registry 22 lines added. Reference README also contains earlier unrelated changes.
- Task +3.3; no task deletion or renumbering.
- DAG edge +3.2 -> 3.3; no existing edge removed.
- Artifacts modified: proposal, design, delta spec, tasks and attachment INDEX; one applied replan added.

## Preserved Work

The original 55 unit tests, nine browser workflows, native adapter, protected editor and local access boundaries remain valid evidence for their tested source. Source and browser checks will be rerun only for the affected layout batch before handoff.

## References and Result

The candidate graph was validated before applying it: eight unique task nodes, valid references, no cycle and the existing seven completed nodes unchanged. Resume task 3.3; use the selected workspace and the user's batch-testing cadence.