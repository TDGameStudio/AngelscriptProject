## Why

Hardness currently records cheap ignored observations and one tracked workflow evaluation per self-hosting Change, but it has no durable admission rule for a material problem discovered through dogfooding outside ordinary implementation cadence. Such a problem can therefore appear only in an agent handoff and disappear from the next session without an owner, status, disposition, or closure gate. The existing detailed material-issue lifecycle already provides the right tracked owner; it needs a versioned schema and explicit dogfooding intake rather than a parallel finding system. The earlier Hardness refactors also retained only four focused talks and did not preserve one coherent user-intent baseline for the original Harness request, even though later carryover policy requires non-obvious rationale to enter indexed talks selectively.

The completed `hardness/integrate-unreal-development` Change exposed this gap after archive: `git.commit` correctly rejected staged content outside the requested scope, so delivery used Git's native path-only commit while preserving the outside staged index. The workaround was safe, but the capability gap and its evidence were reported only in conversation. The completed archive must remain immutable, so this Change is the required successor record.

## What Changes

- Keep raw `hardness.observe` records cheap, ignored, and non-blocking, while admitting a material workflow discovery into the existing `attachments/implementation/issue-*.md` lifecycle using `openspec-material-issue-v2`.
- Require every admitted v2 issue to end as `resolved`, `rejected` with evidence, or `superseded` by an exact `hardness/<change>#issue-<id>` owner; an open issue blocks archive.
- Reconstruct one explicitly dated original-intent talk from bounded conversation evidence and immutable records, and add a judgment-based, major-only planning checkpoint without copying transcripts or requiring boilerplate talks for ordinary Changes.
- Make `hardness.evolution.status` summarize active v2 material-issue frontmatter and a versioned workflow-evaluation result without bulk-loading attachment bodies.
- Extend closure and attachment guidance so a material post-archive or delivery-stage discovery enters one exact suitable active Change, creating a successor only when no suitable owner exists, rather than remaining in chat or rewriting history.
- Add an explicit `PreserveOutsideStaged` opt-in for exact scoped commits. The default continues to reject outside staged content; the opt-in uses path-only commit semantics and verifies that the outside index is unchanged.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `hardness/core`: Extend the existing material-issue lifecycle with durable dogfooding intake, disposition, summary, intent-carryover, and closure rules.
- `hardness/git`: Support an explicit, auditable path-only scoped commit that preserves unrelated staged index entries.

## Impact

- Hardness observation/evolution status, material-issue protocol tests, closure guidance, and attachment routing.
- Git scoped-commit implementation, preview/result evidence, focused integration tests, and commit reference.
- Current Hardness core and Git specifications after the Change is verified and synchronized.
- No Unreal Engine build or test, plugin source change, OpenSpec executable rebuild, `Tools/openspec` gitlink update, push, integration, or worktree removal.
- The archived `2026-09-03-integrate-unreal-development` record remains byte-for-byte unchanged.
