# Separate Git Delivery Authorities

## Operation boundaries

```text
git.commit    -> create selected local commits
git.integrate -> merge an exact reviewed Goal into local target branches
git.push      -> publish explicitly named branches without force
workspace.remove -> remove an explicitly selected clean worktree, preserve branch
```

Success at one boundary does not authorize the next. In particular, Goal completion does not imply integration, local integration does not imply publication, and publication does not imply cleanup.

## Multi-repository ordering

For commits and publication, top-level submodules precede the parent so every parent gitlink is backed by the intended commit. For local integration, each changed submodule preserves both selected histories before the parent records the final integrated submodule head.

Cross-repository integration is resumable rather than physically atomic. Preflight rejects known unsafe state; an ordinary conflict aborts only the current repository merge and preserves earlier committed integrations for an idempotent rerun.
