# INDEX

## Current position

Both Task DAG nodes are complete. The false-positive issue is resolved, the durable Git contract is synchronized, and focused verification passed. The Change is ready for terminal closure.

## Hard conclusions

- A copy classification does not imply a source mutation.
- True rename pairs must remain wholly inside an exact scope.
- Actual staged paths, not similarity heuristics, define commit containment.

## Forbidden

- Do not weaken outside staged-path, intent-to-add, unmerged-index, hook, or restoration checks.
- Do not require unchanged source paths to be added artificially to exact scopes.

## Attachment index

- `implementation/issue-20260904-220329-copy-scope-false-positive.md` — resolved dogfooding issue for the false rejection — read during Task 1.1 and closure.
- `data/git-copy-scope-red.md` — compact failed-commit diagnostic and safe-restoration evidence — read with the implementation issue.
- `data/workflow-evaluation.md` — final lifecycle and verification evidence; added during completion.
- `data/completed-closure.yaml` — explicit completed closure; added only for archive.
