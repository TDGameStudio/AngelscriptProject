---
replan_id: replan-20260908-023255-complete-controlflow-discovery
status: applied
source: verification
source_ref: issue-20260908-023255-duplicate-controlflow-registration
scope: complete-controlflow-discovery-and-final-binary-proof
base_commit: 62d15e1ab9721fd12ad85fec55a2fc5569dd6059
base_tasks_sha256: aa109ec7b59779afee913519abf723091e1a815fe8a2f765e27fc4d1ff8d51c5
result_tasks_sha256: 988dbecf0bbeaadee43b82cc31e66255f5aac5c4293b878119927a68a4b54865
created_at: 2026-09-08T02:32:55.518311+08:00
resume_task: 5.3
---

## Trigger and Evidence

Baseline warning inspection exposed a duplicate CQTest class identity. NativeEngine run d8a6408a76894173b17110dbfa9bddd4 executed 960 cases but omitted all eight methods from BodySemanticTests.cpp's BodiesControlFlow class. BodyControlFlowTests.cpp's same-named twelve-case class won registration. The duplicate warning also exists in the original Syntax RED startup log. Aggregate selector success therefore does not establish the required retained control-flow regression.

## Decision

Add a narrow test-registration repair and current-binary NativeEngine proof as 5.3, then same-binary startup refresh as 5.4. Only one C++ class identity changes; fixtures/assertions and VM identities remain intact. Language/library requirements and implementation design are unchanged.

## Impact

The verification contract now explicitly requires all eight recovered methods plus the original twelve-case class. Expected NativeEngine discovery increases from 960 to 968. The prior runs remain valid for their actual executed identities; they no longer represent final completion.

## Old Task Disposition

Tasks 1.1-5.1 remain complete. Baseline 5.2 is marked complete using its observed three-case success with one warned case. No completed history is unchecked. Follow-up task IDs are permanent 5.3 and 5.4.

## Diff Snapshot

- Task +: 5.3, 5.4; task ~: 5.2 evidence/check; task -: none.
- Edge +: 5.3 depends on 5.2; 5.4 depends on 5.3. Existing edges preserved.
- Artifacts ~: tasks.md, attachments/INDEX.md, implementation-verification.md; one issue and this applied replan added.
- Base affected status: M openspec/changes/angelscript/refactor-language-surface-ue-focused/tasks.md
- Base diff stat: .../refactor-language-surface-ue-focused/tasks.md  | 56 ++++++++++++++++------;  1 file changed, 42 insertions(+), 14 deletions(-)

## Preserved Work

All 44 LanguageSurface cases, SDK audits and add-on removal proof remain valid. No product source changed in this planning update. Unrelated parent changes and delegate tasks remain untouched.

## References and Result

Candidate validation before tracked writes proved ten unique nodes, a topologically valid tail extension, one exact proving command per node and preserved eight completed cards. Strict OpenSpec and TaskPlan validation follow before source mutation.

- [Issue](../implementation/issue-20260908-023255-duplicate-controlflow-registration.md)
- [Reverse planning patch](../data/replans/replan-20260908-023255-complete-controlflow-discovery-before.patch)
