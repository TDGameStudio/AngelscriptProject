## Context

`Plugins/Angelscript` is both the primary deliverable and a Git submodule. The parent `main` gitlink was at `ed22fbdf`, while the clean plugin local `main` was at descendant `5472045`; fetched `origin/main` was an ancestor of both and 69 commits behind local main. Existing workspace bootstrap correctly restores the parent gitlink, but workspace-sensitive execution had no main-baseline freshness check.

## Goals / Non-Goals

**Goals:**

- Make stale plugin commits visible and fail closed before primary-main execution.
- Use deterministic local Git refs and preserve Harness's no-network status contract.
- Permit detached submodule checkout when its commit equals the resolved main tip.
- Preserve feature-branch and linked-worktree development.

**Non-Goals:**

- Implicit fetch, checkout, merge, reset, commit, or push.
- Requiring a clean plugin working tree before compilation.
- Replacing the parent's exact gitlink/bootstrap contract.
- Treating an unfetched remote as proof of global network freshness.

## Decisions

1. The guard applies only when the selected parent branch is exactly `main`. Feature branches need to compile commits that intentionally differ from main.
2. The resolved baseline prefers `refs/heads/main`; a fresh submodule clone without a local branch falls back to `refs/remotes/origin/main`.
3. When both refs exist, `origin/main` must be an ancestor of local main. Local unpublished integration commits are valid, but a known remote commit missing from local main is not.
4. Plugin HEAD must equal the resolved baseline commit. Attached versus detached state is irrelevant; commit identity is authoritative.
5. Fast workspace status remains cheap. The comparison is included in detailed status and always runs in the existing execution guard immediately before an external workspace-sensitive operation.
6. Diagnostics return exact commit IDs, selected baseline source, and a non-mutating recovery direction.

## Risks / Trade-offs

- Remote freshness is only as current as the last explicit fetch. This is intentional: ordinary Harness status and build planning do not perform network mutation or depend on credentials.
- A developer on parent `main` cannot intentionally build an older plugin commit through Harness. They must use a feature branch/worktree, which makes the deviation explicit.
- Local main may be ahead of `origin/main`; this remains valid so locally integrated work can be built before separately authorized publication.
