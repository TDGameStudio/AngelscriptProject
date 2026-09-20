---
talk_schema: "harness-talk-v1"
talk_id: "grill-20260918-083859-verification-stages-bee9f2"
change: "angelscript/feature-delegates-ue-interop"
workspace_id: "git_3b46972bbc7ef05a4244fd2890d18183"
workspace_root: "D:\\Workspace\\AngelscriptProject"
session_id: "87924172-delegates-replan"
revision: 4
status: "closed"
scope: "current-change"
summary: "Q8=S Q9=R Q10=T Q11 reject-now delete-later. Split 1.5/1.6/1.7; one DECLARE table plus 60-row matrix; keywords transitional reject only."
source_ref: "user: 验证阶段要先确认再 grill 后 replan"
questions: [{"id": "Q8", "question": "Which first-wave verification stages must have their own proving command?", "source": "user-form:Q8", "answer": "S"}, {"id": "Q9", "question": "After stages are confirmed, reshape the already-applied 1.2/1.4 cards to match, or keep those mixed cards?", "source": "user-form:Q9", "answer": "R"}, {"id": "Q10", "question": "How should the six DECLARE families x 0-9 arities be implemented and proven?", "source": "user: 60 种按你选的做成一张声明表 + 一张 60 行期望表", "answer": "T one declaration-form table plus a 60-row expectation matrix, not 60 parsers."}, {"id": "Q11", "question": "How should leftover delegate/event keywords live after this Change?", "source": "user: 旧关键字 已经完全弃用了, 之后会删除的", "answer": "Fully deprecated now: reject only. Delete KwDelegate/KwEvent in a later Change."}]
resume_task: "1.1"
disposition: "applied"
created_at: "2026-09-18T08:38:59.180318+00:00"
updated_at: "2026-09-18T09:17:27.792373+00:00"
history: [{"revision": 1, "status": "open", "summary": "Confirm verification-stage split before any further replan. Diagnostics, preprocess, register, and invoke were packed, not designed as separate proofs.", "questions": [{"question": "Which first-wave verification stages must have their own proving command?", "source": null, "answer": null, "id": "Q8"}, {"question": "After stages are confirmed, reshape the already-applied 1.2/1.4 cards to match, or keep those mixed cards?", "source": null, "answer": null, "id": "Q9"}], "updated_at": "2026-09-18T08:38:59.180323+00:00"}, {"revision": 2, "status": "open", "summary": "Q8=S Q9=R stage split confirmed. Q10 open: 60 DECLARE spellings are a table matrix, not 60 parsers; user asked if support is thought through.", "questions": [{"question": "Which first-wave verification stages must have their own proving command?", "source": "user-form:Q8", "id": "Q8", "answer": "S"}, {"question": "After stages are confirmed, reshape the already-applied 1.2/1.4 cards to match, or keep those mixed cards?", "source": "user-form:Q9", "id": "Q9", "answer": "R"}, {"question": "How should the six DECLARE families x 0-9 arities be implemented and proven?", "source": null, "id": "Q10", "answer": null}], "updated_at": "2026-09-18T08:40:05.581431+00:00"}]
replan_ref: "replans/replan-20260918-091500-verification-stages.md"
---

# Discussion

- Summary: Q8=S Q9=R Q10=T Q11 reject-now delete-later. Split 1.5/1.6/1.7; one DECLARE table plus 60-row matrix; keywords transitional reject only.
- State: closed
- Resume task: 1.1

## Decisions

- Q8: Which first-wave verification stages must have their own proving command? — S
- Q9: After stages are confirmed, reshape the already-applied 1.2/1.4 cards to match, or keep those mixed cards? — R
- Q10: How should the six DECLARE families x 0-9 arities be implemented and proven? — T one declaration-form table plus a 60-row expectation matrix, not 60 parsers.
- Q11: How should leftover delegate/event keywords live after this Change? — Fully deprecated now: reject only. Delete KwDelegate/KwEvent in a later Change.

## Conversation
