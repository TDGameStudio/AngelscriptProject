---
talk_schema: "harness-talk-v1"
talk_id: "grill-20260918-090740-keyword-deprecation-then-delete-736e7d"
change: "angelscript/feature-delegates-ue-interop"
workspace_id: "git_3b46972bbc7ef05a4244fd2890d18183"
workspace_root: "D:\\Workspace\\AngelscriptProject"
session_id: "87924172-delegates-replan"
revision: 3
status: "closed"
scope: "current-change"
summary: "Q11 folded into verification-stages replan: reject keywords this Change; delete lexer tokens later."
source_ref: "user: 旧关键字 已经完全弃用了, 之后会删除的"
questions: [{"id": "Q11", "question": "How should leftover delegate/event keywords live after this Change?", "source": "user: 旧关键字 已经完全弃用了, 之后会删除的", "answer": "Fully deprecated now: do not admit, no aliases, no wrappers. Keep only a transitional reject so leftover source cannot still parse as callables. Delete KwDelegate/KwEvent from the lexer in a later Change, not this one."}]
resume_task: "1.1"
disposition: "no-change"
created_at: "2026-09-18T09:07:40.065537+00:00"
updated_at: "2026-09-18T09:15:10.730163+00:00"
history: [{"revision": 1, "status": "open", "summary": "delegate/event are fully deprecated this Change: reject only. Token deletion is a later Change.", "questions": [{"question": "How should leftover delegate/event keywords live after this Change?", "source": "user: 旧关键字 已经完全弃用了, 之后会删除的", "id": "Q11", "answer": "Fully deprecated now: do not admit, no aliases, no wrappers. Keep only a transitional reject so leftover source cannot still parse as callables. Delete KwDelegate/KwEvent from the lexer in a later Change, not this one."}], "updated_at": "2026-09-18T09:07:40.065543+00:00"}, {"revision": 2, "status": "settled", "summary": "Q11: keywords fully deprecated this Change (reject only). Lexer token deletion is a later Change.", "questions": [{"id": "Q11", "source": "user: 旧关键字 已经完全弃用了, 之后会删除的", "question": "How should leftover delegate/event keywords live after this Change?", "answer": "Fully deprecated now: do not admit, no aliases, no wrappers. Keep only a transitional reject so leftover source cannot still parse as callables. Delete KwDelegate/KwEvent from the lexer in a later Change, not this one."}], "updated_at": "2026-09-18T09:07:49.048074+00:00"}]
---

# Discussion

- Summary: Q11 folded into verification-stages replan: reject keywords this Change; delete lexer tokens later.
- State: closed
- Resume task: 1.1

## Decisions

- Q11: How should leftover delegate/event keywords live after this Change? — Fully deprecated now: do not admit, no aliases, no wrappers. Keep only a transitional reject so leftover source cannot still parse as callables. Delete KwDelegate/KwEvent from the lexer in a later Change, not this one.

## Conversation
