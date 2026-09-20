# Harness Git Knowledge Index

- [Planning, Implementation and Final Closure](lifecycle-checkpoints.md)
  - Summary: Distinguish formal planning commits, implementation commits and Git-persisted archive closure; explain exact selection, partial recovery and honest incomplete outcomes.
  - Serves: Lifecycle planning persistence, scoped Git candidates and recoverable queue closure.
  - Source: Change `harness/feature-lifecycle-git-closure`, tasks 1.1–1.6 and 2.3–2.4, owning source modules and its indexed lifecycle consumer audit.
  - Status: current; real temporary-repository proof and bounded simulated explanation evidence, no UI or reliability guarantee

- [Separate Git Delivery Authorities](delivery-authorities.md)
  - Summary: Keep commit, local integration, push, and worktree cleanup as explicit independent authority boundaries.
  - Serves: Scoped Git status and commit, reviewed local integration, ordered push, and safe Goal retention.
  - Source: `openspec/archive/changes/harness/2026-09-03-refactor-workspace-git-operations`, validated by real temporary parent/submodule/remote fixtures.
  - Status: current
