---
replan_id: replan-20260907-220002-named-callables-no-lambda
status: applied
source: user
source_ref: "User-approved language-surface plan on 2026-09-07; angelscript/refactor-language-surface-ue-focused/proposal.md and design.md"
scope: "Remove Lambda/closure goals; retain named/member callbacks and explicit payloads; consume canonical callable SDK from the language-surface Change"
base_commit: d8343d314f0b948a43a323fc443cf305ff2f5dc3
base_tasks_sha256: e81adeb5513c946275fffd0a73ea1004107af0685b8fe7e48198e8799a17ff52
result_tasks_sha256: 454e5cd58de36ddfef2c72095085a20ffd984653a9e291a56ef60e0811c59b3c
created_at: 2026-09-07T22:00:02.073370+08:00
resume_task: "1.1"
---

## Trigger and Evidence

The user explicitly removed all Lambda/anonymous-function syntax and authorized synchronizing the existing delegate plan. The old proposal promised captures and Lambda-specific Bind/Create/Add operations; task 2.2 promised escaping closures and retained positive noncapturing function(...) controls. Those requirements conflict with the accepted UE language reduction. UE delegate/event interop remains requested in this record, with named functions/members and explicit payloads.

Before mutation, the existing record passed portable OpenSpec strict validation. Candidate proposal/tasks/INDEX were materialized separately. Candidate task frontmatter and every task ID/check state matched the original after newline normalization, so the existing validated local DAG remains unchanged. Static candidate assertions verified absence of the old Lambda implementation file and Closures proving prefix. No product state was mutated.

## Decision

Replace Lambda/lexical-capture scope with explicit typed receiver/payload state. Preserve task 2.2's permanent ID and its role as the callback-lifetime prerequisite. Its selector becomes `Angelscript.UnitTest.Delegates.Payloads`; its test file becomes PayloadTests.cpp. Named AddOffset(Value, Offset) bound with payload 10 returns 15 for input 5 after factory return. Native retained callback uses payload 40 and input 2 to return 42. Runtime fault cleanup, managed handle payload leases and weak UObject member receivers remain required.

Task 1.1 checks the completed `asCCallableType` / `CreateCallableType` / `CreateCallableSignature` interface proof supplied by task 2.1 of `angelscript/refactor-language-surface-ue-focused` before delegate product work. This is an external semantic prerequisite, not a foreign node inserted into the local DAG. Existing host/Blueprint/cooked design completion remains pending.

## Impact

Proposal changes: intended usage, callable scope, subscription operations, payload compatibility, non-goals, capability descriptions and ownership. Tasks change: 1.1's contract inputs, 2.2's pending outcome/Files/selector/cases, and dependent 2.3/3.1/3.3/4.1 oracles. No new product task or implementation file is created. The historical UE inventory remains unchanged and its former Lambda observations no longer authorize that scope.

## Old Task Disposition

- 1.1: preserved pending planning task; external interface and no-Lambda constraints added.
- 1.2, 1.3, 2.1, 3.2: preserved pending outcomes and IDs.
- 2.2: preserved ID and binding-lifetime role; old anonymous-function behavior superseded by explicit named-target payload behavior under the user decision.
- 2.3, 3.1, 3.3, 4.1: preserved pending outcomes, with closure-dependent acceptance rewritten to named-target/payload equivalents.
- All ten tasks remain unchecked. No completed task was reset or evidence rewritten.

## Diff Snapshot

Affected-path Git status before update: `?? openspec/changes/angelscript/feature-delegates-ue-interop/`. `git diff --stat -- <that path>` is empty because the record was already untracked. Do not interpret the empty tracked diff as no content change.

- Task `+`: none. Task `-`: none. Task `~`: 1.1, 2.2, 2.3, 3.1, 3.3, 4.1.
- Local DAG edge `+/-`: none. Graph/check states preserved.
- External dependency `+`: language-surface task 2.1 interface evidence checked by local 1.1.
- Artifacts `~`: proposal.md, tasks.md, attachments/INDEX.md.
- Artifacts `+`: this applied replan, small reverse patch, alignment-verification record.

The indexed reverse patch restores the small preexisting untracked planning text from the applied result. It is historical provenance, not current scope. Original proposal SHA-256: `4a9687c75a06abf71cca3868cfdfa4ac24cb470d5c7851f630a89bdbf14c1c39`; result: `3c867e78ce0f9e3b6fcb53df4dc279c378fae9c8a9c9e12706e22a36ad7d6402`.

## Preserved Work

Keep the six declaration families/60 supported spellings, 31 explicit deferred diagnostics, raw delegate/event syntax, named/member/virtual binding, payload values, multicast handles/reentrancy, native live-event views, dynamic reflection and real Blueprint/cooked fixture requirements. No Lambda shorthand replaces named bindings. No callback payload is implicitly serialized as a dynamic delegate. Retain runtime fault/unwind and host-control semantics despite source exception/coroutine removal.

## References and Result

- `../../proposal.md` and `../../tasks.md`: applied current requirements and sole task state.
- `../data/language-surface-alignment-verification.md`: post-application checks and omitted product verification.
- `../data/replans/replan-20260907-220002-named-callables-no-lambda-before.patch`: recoverable old untracked text.
- `openspec/changes/angelscript/refactor-language-surface-ue-focused/design.md`: canonical public callable migration and source boundary.

Resume remains task 1.1 after a later request to continue this feature. This applied planning replan grants no implementation, UE execution, archive, commit or push authority.
