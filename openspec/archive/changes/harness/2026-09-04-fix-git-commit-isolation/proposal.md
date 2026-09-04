## Why

Scoped commit validation currently runs after `git commit`. A successful `pre-commit` hook can stage an outside path and place it in the new commit before Harness detects the violation, while failed hooks and `commit-msg` hooks can leave the live index polluted. The operation then reports failure after the branch has already advanced or loses the caller's original staged/unstaged shape.

## What Changes

- Run every exact-scope commit with path-only Git semantics, not only outside-staged preservation mode.
- Snapshot the affected repository's live index before Harness stages its scope, and restore the ref and exact index on hook/commit/validation failure when the ref still matches the attempted commit.
- Validate the resulting commit and all outside staged/intent-to-add state before accepting it; keep post-validation as defense rather than a false success signal.
- Preserve normal hooks, including scope-local formatting and commit-message edits, and explicitly report that arbitrary hook worktree or external side effects are detected but never destructively overwritten.
- Retain child-before-parent resumable partial completion across repositories while making each affected repository's ref and index transactional.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/git`: Make exact scoped commits hook-safe at the repository ref/index boundary.

## Impact

The parent repository changes `git-operations` implementation, tests, commit guidance, and the durable Harness Git specification. The Harness route surface and Git publication/integration operations do not change.
