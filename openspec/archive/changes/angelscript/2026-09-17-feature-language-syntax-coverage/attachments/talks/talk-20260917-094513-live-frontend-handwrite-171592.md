---
talk_schema: "harness-talk-v1"
talk_id: "talk-20260917-094513-live-frontend-handwrite-171592"
change: "angelscript/feature-language-syntax-coverage"
workspace_id: "git_3b46972bbc7ef05a4244fd2890d18183"
workspace_root: "D:\\Workspace\\AngelscriptProject"
session_id: "syntax-coverage-replan-20260917"
revision: 3
status: "closed"
scope: "current-change"
summary: "Fold live-frontend coverage corrections into the Task DAG and require handwritten author exploration."
source_ref: "user:plan-handwrite-no-python"
questions: [{"id": "Q1", "question": "Fold the live-frontend gap research into this Change Task DAG?", "answer": "Yes. Drop illegal local auto-ref and class-level final. Add live operators, fallthrough, foreach keyword, protected, access, interface extras, handle/foreach-key auto, and heredoc. Live spellings are nullptr and Cast.", "source": "user:plan-handwrite-no-python"}, {"id": "Q2", "question": "How must authors be written?", "answer": "Hand-write every @begin. Inspect the live frontend while authoring. Do not generate author .as with Python or any batch author script.", "source": "user:plan-handwrite-no-python"}, {"id": "Q3", "question": "Do delegate and event belong in this Change?", "answer": "Yes. They are live frontend callable types. Add parallel task 7.2 Language/Delegate and Language/Event. funcdef stays out.", "source": "user:plan-handwrite-no-python"}]
resume_task: "1.1"
disposition: "applied"
created_at: "2026-09-17T09:45:13.231358+00:00"
updated_at: "2026-09-17T09:48:53.303778+00:00"
history: [{"revision": 1, "status": "open", "summary": "Fold live-frontend coverage corrections into the Task DAG and require handwritten author exploration.", "questions": [{"question": "Fold the live-frontend gap research into this Change Task DAG?", "answer": null, "source": null, "id": "Q1"}, {"question": "How must authors be written?", "answer": null, "source": null, "id": "Q2"}, {"question": "Do delegate and event belong in this Change?", "answer": null, "source": null, "id": "Q3"}], "updated_at": "2026-09-17T09:45:13.231365+00:00"}]
replan_ref: "replans/replan-20260917-174852-live-frontend-handwrite.md"
---

# Discussion

- Summary: Fold live-frontend coverage corrections into the Task DAG and require handwritten author exploration.
- State: closed
- Resume task: 1.1

## Decisions

- Q1: Fold the live-frontend gap research into this Change Task DAG? — Yes. Drop illegal local auto-ref and class-level final. Add live operators, fallthrough, foreach keyword, protected, access, interface extras, handle/foreach-key auto, and heredoc. Live spellings are nullptr and Cast.
- Q2: How must authors be written? — Hand-write every @begin. Inspect the live frontend while authoring. Do not generate author .as with Python or any batch author script.
- Q3: Do delegate and event belong in this Change? — Yes. They are live frontend callable types. Add parallel task 7.2 Language/Delegate and Language/Event. funcdef stays out.

## Conversation
