---
replan_id: replan-20260908-082422-admission-contract-producers
status: applied
source: review
source_ref: review-20260908-081954-vm-residuals-reviewer.md
scope: real-callable-ABI-and-CFG-lifetime-verification
base_commit: 533114cb401e3c00d8ff61dfdc682ebf3f6c7baa
base_tasks_sha256: 4fb0e42b428f90531e336badc94ff7acc096fe8db785d514e311ce65ac16984a
result_tasks_sha256: 781e0fa81b45fa3a3b6899f2fdf335bdaf6b01536def787f2750e105816a081c
created_at: 2026-09-08T08:24:22.671589+08:00
resume_task: 6.7
---

## Trigger and Evidence

Fixed snapshot fee967996643bab573c3e6ece2a7c197952c9da4898fcf298daac49e2b4fccaf demonstrates W01 (real producer omits width facts) and W02 (static cleanup coverage is not CFG lifetime validation). These invalidate 6.6 and 11.3 completion coverage, not the accepted product requirements. V02 and V04 implementations improved and remain preserved pending complete boundary evidence.

## Decision

Preserve 45 checked nodes. Add 6.7 for real callable ABI admission and 6.8 for CFG lifetime admission; 11.4 depends on both and historical 11.3. Correct current design before task writes. No dormant services or unrelated feature scope is added.

## Impact

Explicit parameter/result storage/category facts require producer, codec/witness and linker authentication. Lifetime state requires consistent verifier/emitter/linker transitions and actual-operation fixtures. Both nodes have concrete grouped RED/GREEN and direct proving selectors; full regression belongs to final acceptance after shared-contract changes.

## Old Task Disposition

6.6 and 11.3: needs_followup, owned by 6.7/6.8/11.4. All earlier work preserved; no checkbox is unchecked and no passing historical run is relabeled as newer proof.

## Diff Snapshot

- Task +: 6.7, 6.8, 11.4; Task -: none.
- Edge +: 6.7 <- 6.6; 6.8 <- 6.6; 11.4 <- 11.3, 6.7, 6.8. Existing edges unchanged.
- Artifact ~: design.md, tasks.md, attachments/INDEX.md; new Review and this Replan.
- Base affected status: ?? openspec/changes/angelscript/refactor-vm-symbolic-execution/attachments/reviews/review-20260908-081954-vm-residuals-reviewer.md
- Base diff stat: none

## Preserved Work

All existing runtime, metadata, opcode and source implementations and historical evidence remain. Parent language-surface commit and unrelated user changes are untouched. No product source changes occur in this planning operation.

## References and Result

`review-20260908-081954-vm-residuals-reviewer.md` contains source lines and resolution conditions. Candidate audit confirms exactly three new pending nodes and all 45 checked nodes preserved; new edges target existing completed nodes or the two new owners and cannot add a cycle. OpenSpec strict and derived TaskPlan verification run before implementation. Resume 6.7; 6.8 is also Ready but shared writers/build resources are serialized.
