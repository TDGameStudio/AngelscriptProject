# Attachment Index

- `data/workflow-evaluation.md` — Terminal evaluation of scoped Git hook isolation and ref/index recovery.

## Conclusions

- Exact commits execute normal hooks against a candidate index and validate every candidate stage before acceptance.
- A rejected candidate leaves no accepted ref and restores the complete live index when the attempted ref remains owned.
- Scope-local formatter and message-hook output remains supported; arbitrary worktree or external hook effects are never overwritten.

## Forbidden interpretations

- Repository-local ref/index recovery is not a promise to undo arbitrary hook processes, network calls, or external file writes.
- A later repository failure does not roll back already accepted child commits; those remain explicit resumable partial work.
