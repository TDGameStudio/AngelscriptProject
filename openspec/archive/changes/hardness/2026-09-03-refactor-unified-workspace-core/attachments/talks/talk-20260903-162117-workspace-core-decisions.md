# Unified Workspace Core Decisions

## Context

The repository has one primary checkout and multiple registered worktrees at heterogeneous paths and branch names. The previous Hardness contract conflated Codex `/goal` continuation with Git topology, making common status slow and leaving dogfooding observations largely invisible.

## Evidence

- The registered worktree set is the reliable source of valid checkout roots; existing branch names do not use one Goal prefix.
- Before implementation, a full PS7 Quick baseline took 130.9 seconds. Five checks passed; OpenSpecSkill failed only because the newly registered Change did not yet have `attachments/INDEX.md`.
- Existing default workspace and Git status routes perform repository/submodule work that is unnecessary for session or subagent startup context.
- Planning began at `2026-09-03T08:21:17.5902790Z` on primary branch `main`, HEAD `2cb1c62e1f54eb907b8fd6f2ed9b2438042f7d27`.

## Settled Decision

- Use one Git-derived context with separate HarnessRoot and WorkspaceRoot and no Goal/Current mode.
- Accept all registered worktrees in the common Git directory; use `.worktrees/<name>` and branch `<name>` only as the new-worktree default.
- Keep common status fast, make dirty/submodule diagnosis explicit, and never cache mutation preconditions.
- Store raw lifecycle observations under ignored `Saved/Hardness/` and track one compact evaluation before Final Review.
- Keep richer Task Cards as optional prose so the existing OpenSpec DAG parser and executable remain untouched.
- Add only optional Codex `SessionStart` and `SubagentStart` fast-status hooks.
- Report OpenSpec package/source maintenance state without rebuilding or publishing the executable.

## Consequences and Flip Condition

```text
loaded harness checkout ---> HarnessRoot
explicit/discovered target -> WorkspaceRoot -> Primary | Worktree
Codex /goal ---------------> continuation only

fast status -> normal routing and hooks
detailed status -> explicit diagnosis
raw observations -> ignored Saved data -> one compact tracked evaluation
```

Revisit the split only if real Git evidence cannot identify a registered target safely, or if measured hook/status behavior still requires expensive scans after the fast contract is implemented.

## Sources

- User-approved implementation plan and follow-up decisions in the current conversation.
- Pre-implementation PS7 Quick run reported by the coordinator on 2026-09-03.
- Current Hardness, workspace-lifecycle, and git-operations modules and tests.
