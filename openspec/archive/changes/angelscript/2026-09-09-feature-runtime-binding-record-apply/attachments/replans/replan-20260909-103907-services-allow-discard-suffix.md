---
replan_id: replan-20260909-103907-services-allow-discard-suffix
status: applied
source: implementation
source_ref: task 7.9 RED run fee0888f5816493c924492144765b573
scope: parse the existing allow_discard callable suffix required by the complete Runtime test-helper surface
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 0aabe3ca41dd571062a26be3325751b1a06000874d38caa31f85b83813864a79
result_tasks_sha256: 435c8a17bcaf1fadaae07fc3ff7873307fc98183a260a89a2d496f6438b7660a
created_at: 2026-09-09T10:39:07.9863065+08:00
resume_task: 7.9
---

# Trigger and Evidence

Task 7.9's exact five-case group reached detached validation after the service providers were made safe to record without an Engine. Four cases then failed during `Seal` on the existing declaration `FAngelscriptTestCommandBuilder Do(...) const allow_discard`; the host-declaration parser reported unexpected tokens after the callable declaration.

The shared language frontend and builder already recognize `allow_discard`, and the Runtime helper provider uses it on eight command-builder methods. Task 7.9 requires that complete existing helper surface, but its accepted file boundary omitted the detached declaration parser that owns the grammar handoff.

# Decision

Add `ThirdParty/angelscript/source/frontend/as_binding_declaration.*` to task 7.9's owned files and explicitly name the existing `allow_discard` suffix in its outcome. Accept it as a declaration attribute after a callable signature, alongside the already supported `no_discard` suffix. Callable identity and runtime invocation behavior remain unchanged.

# Impact

- Proposal, durable specifications, design, cases, exact verification, and dependency edges remain valid.
- Task 7.9 keeps its ID and remains the Ready resume node.
- The implementation boundary expands by one focused parser pair.
- The existing service RED remains valid and will be rerun after the grammar repair.

# Old Task Disposition

- Task 7.9: `preserved`; remains active with its grouped RED evidence.
- Completed tasks and evidence: `preserved`.
- All other pending tasks and DAG edges: `preserved`.

# Diff Snapshot

- Affected path status before the replan: `m Plugins/Angelscript`; the active Change was untracked in the parent workspace.
- Parent diff stat reported only the dirty plugin gitlink because the active Change is untracked; detailed plugin work remains owned by prior and current tasks.
- Task changes: `~7.9` file boundary and explicit suffix handoff; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `+ inverse sidecar`, `~ attachments/INDEX.md`.

# Preserved Work

The five service cases, setup builds, Engine-access namespace repairs, captured subsystem-reflection snapshot path, and exact RED run remain valid. No helper declaration or case is removed to bypass the parser boundary.

# References and Result

- Exact RED: `Saved/Harness/Unreal/Runs/fee0888f5816493c924492144765b573/Summary.json` — one pass and four failures.
- Language support: `as_frontend_parser.cpp` maps `allow_discard` to `asEFunctionModifiers::AllowDiscard`; builder coverage maps it to `asTRAIT_ALLOWDISCARD`.
- Runtime dependency: `Testing/AngelscriptTest.cpp` authors eight `allow_discard` command-builder declarations.
- Inverse task patch: `attachments/data/replans/replan-20260909-103907-services-allow-discard-suffix-before.patch`.
- Result: task 7.9 resumes with its required detached grammar owner in scope.
