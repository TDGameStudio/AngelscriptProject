---
replan_id: replan-20260908-092053-binding-definition-modifiers
status: applied
source: implementation
source_ref: "task 2.4; as_binding_declaration.cpp Read and as_type_identity.cpp ValidateFunction inspected before implementation"
scope: "Task 2.4 parser consumer ownership for recorded definition modifiers"
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: a691ddd1ab222e9fb5ea30edb1d99bcc8ef0b6064bb1720fd30e80ddf5f68f64
result_tasks_sha256: 5191760e69adaa6c61bb1d94e484343fd55c35692535e12fbba8901d97dbdf02
created_at: 2026-09-08T09:20:53.943011+00:00
resume_task: "2.4"
---

## Trigger and Evidence

The binding parser interns a Function descriptor immediately and has no input for definition modifiers. ValidateFunction requires exact equality of DefinitionModifiers, and metadata image validation reconstructs NoDiscard, Deprecated, Property and Generated flags from the completed function. Setting these recorded facts only after parsing therefore cannot produce an authenticated frozen image. Task 2.4 owns the outcome and tests, but its Files omitted the required parser entry point.

## Decision

Extend the task's file ownership to frontend/as_binding_declaration.h and .cpp. Supply definition modifiers before interning. Keep one canonical producer context and the existing parser; do not introduce a temporary identity namespace or bypass frozen validation. Update design current truth before task authoring.

## Impact

The accepted behavior, nine-case member proving group, task count and all dependency edges are unchanged. The candidate preserves the exact validated YAML graph and all five completed checkboxes; only task 2.4's Files and consumer wiring explanation change. RED dd73cb9fb4e841fdb286789d28838c0f executed nine cases and failed all nine on the missing Install implementation/diagnostics; this does not separately claim the modifier mismatch was observed at runtime.

## Old Task Disposition

2.4 remains pending and Ready with its existing identity and proving command. No task is superseded or reopened.

## Diff Snapshot

- Before status: the Change directory and both parser files are untracked. The parser files are already task 2.2's tested implementation. New task 2.4 Apply.h/.cpp and RuntimeBindingMembersTests.cpp are untracked compilable skeleton/tests.
- Tracked diff stat for the affected Change is empty; untracked planning content is preserved by an inverse task hunk below.
- Task ~2.4: add parser Files and modifier-input wiring. Task +/-: none. Edge +/-: none.
- Artifact ~design.md, ~tasks.md, ~INDEX.md; add this applied record and the bounded inverse hunk.

## Preserved Work

Keep all tested Recording, declaration and layout work, existing source/binary evidence, the nine member RED cases, full Runtime migration scope and unrelated user changes. No product implementation changes occur during this replan.

## References and Result

Resume task 2.4 after strict validation and derived task.status. The before-task snapshot is recoverable by applying data/replans/replan-20260908-092053-binding-definition-modifiers-before.patch to the resulting tasks content. Hashes above bind both states; the record remains immutable.
