## Why

The parent repository still recorded `Plugins/Angelscript` at `ed22fbdf`, an intermediate Typed Semantic HIR/TypedASTJIT integration commit, while the plugin's clean local `main` had advanced by 57 commits to `5472045`, including the completed CanonicalAST refactor. Harness could build whichever submodule commit happened to be checked out and did not identify this stale primary-main baseline.

## What Changes

- Advance the parent `Plugins/Angelscript` gitlink to the clean local `main` tip that already contains the fetched `origin/main` history.
- Add a deterministic Harness workspace check for the primary parent `main` baseline: the initialized plugin HEAD must equal the local `main` tip, and a known `origin/main` tip must be contained by that local `main`.
- Apply that fail-closed check to workspace-sensitive execution so a primary-main build cannot silently use an intermediate plugin commit.
- Keep linked worktrees and non-main parent branches available for intentional plugin feature-branch development.
- Verify the integrated CanonicalAST plugin with the real UE 5.8 `AngelscriptProjectEditor Win64 Development` build.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/workspace`: Define primary-main AngelScript submodule baseline alignment and execution rejection.

## Impact

- Parent repository: updates the `Plugins/Angelscript` gitlink and Harness workspace tests/specification.
- `Plugins/Angelscript`: no source rewrite; selects its existing clean local `main` commit `5472045`.
- Harness entry points: workspace status exposes the baseline state and the execution guard rejects a stale primary-main plugin checkout.
- Network boundary: Harness does not fetch or push implicitly. The check uses explicit local and remote-tracking refs; this run explicitly fetched `origin/main` before selecting the local main baseline.
- Non-goals: pushing the plugin or parent repository, rewriting CanonicalAST, forcing feature worktrees onto main, or changing unrelated dirty parent files.
