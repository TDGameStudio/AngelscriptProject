---
replan_id: replan-20260909-102527-diagnostics-conditional-surface
status: applied
source: implementation
source_ref: task 7.8 source inspection and Harness GREEN run dc2892f2a71f4e488209b9fb7ac2a8bb
scope: task 7.8 conditional diagnostic-provider acceptance case
base_commit: a9afd56e73b9289ed32dee8210d7b96ac0b3b578
base_tasks_sha256: 0dc7d77b6e5c3ca8daaa7ad044d5e935e98256f348e94446d37ea306aa8b4a64
result_tasks_sha256: 3999773eb3db9595e6d08cd91d87b2ddcb3609bd00850e810e6847b5df8c1a76
created_at: 2026-09-09T10:25:27+08:00
resume_task: 7.8
---

## Trigger and Evidence

Task 7.8 required an unavailable editor-only diagnostic surface to be excluded with a reason. Source inspection of every provider in the task found no editor-only callable surface. `Debugging.Manual` has an editor-only end-play delegate side effect, but all of its script callables are runtime declarations. `Console.Commands` is the actual conditional surface: its native behavior is compiled out by `UE_BUILD_SHIPPING` guards in `Bind_Console_Functions.cpp`.

The completed six-case run `dc2892f2a71f4e488209b9fb7ac2a8bb` proves that a Shipping recording excludes `Console.Commands` with the inspection disposition `excluded-by-condition`, while the Development recording installs the provider. The exact 62-contribution/1-recipe Development surface and the other five acceptance cases remain unchanged.

## Decision

Replace the false editor-only acceptance premise with the source-backed requirement that Development-only console commands are excluded from Shipping with a reason. Add a production registration overload that attaches an existing `FAngelscriptBindRecord::Condition` to a direct provider and use it for `Console.Commands`.

## Impact

Only task 7.8's conditional-surface case text changes. Its outcome, files, proving command, task ID and dependency edges remain unchanged. Proposal, specifications and design remain valid because they already require target-policy-aware provider accounting without naming an editor-only diagnostics callable.

## Old Task Disposition

Task 7.8 remains pending and resumes after this applied correction. All thirty-nine previously completed outcomes and their evidence remain valid.

## Diff Snapshot

- Affected path status: task 7.8 implementation edits `AngelscriptBinds.h/.cpp`, `Bind_Console.cpp`, `Bind_Debugging.cpp`, `Bind_FMessageDialog.cpp`, `Bind_Logging.cpp`, and adds `RuntimeBindingDiagnosticsTests.cpp`.
- Affected implementation diff stat: one conditioned-provider constructor, one provider condition, three detached-recording repairs, and one six-case fixture.
- Task changes: `~ 7.8` acceptance-case wording; no task additions or removals.
- Edge changes: none.
- Artifact changes: `~ tasks.md`, `+ this applied replan`, `~ attachments/INDEX.md`.
- The parent and plugin worktrees contain the larger authorized runtime-binding reconstruction and unrelated user changes; this replan does not reassign them.

## Preserved Work

The console lifetime, log sink, compile-out policy, profiler scope, dialog metadata and provider-accounting cases are preserved. The exact and shared GREEN runs remain valid for their source/binary identities.

## References and Result

Behavioral RED runs `0e4b29168acc419883ad167bac657600` and `33dfc4a5d8d74502931f05f1d50e7b97` identified the detached namespace and Static JIT descriptor defects. Exact GREEN run `dc2892f2a71f4e488209b9fb7ac2a8bb` and shared run `478efd0fca024e1b92a2c79a352a4b81` prove the corrected task boundary. The resulting raw task document hash is `3999773eb3db9595e6d08cd91d87b2ddcb3609bd00850e810e6847b5df8c1a76`; execution resumes at task 7.8.
