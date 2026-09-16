# INDEX

## Current position

Task 1.1 complete. Tombstone lifetime and related-replan inventory are recorded. No current-spec SHALL. Ready for completed archive. Knowledge remains a change-local candidate.

## Hard conclusions

- Replacement `_REPLACED_N` `UASClass` objects are tombstones, not immediate `BeginDestroy`.
- Script-deleted classes use the same rename but also unroot and clear `RF_Standalone`.
- `ForceGarbageCollection` after FullReload is about old instances.
- A later lifetime-policy Change replans the listed owners; this Change does not edit them.

## Forbidden

- Do not unroot or `BeginDestroy` replaced classes in this Change.
- Do not add a current-spec SHALL for linger or collect.
- Do not edit sibling `tasks.md`.

## Attachment index

- talks/talk-20260911-121527-record-not-destroy-policy.md — why this Change records and does not destroy — load before adding ClassGenerator lifetime work
- data/planning-validation.md — plan-acceptance self-review — load when judging coverage
- knowledges/replaced-uclass-tombstone.md — candidate: replacement tombstone vs script-deleted unroot — load before any destroy/GC policy
- data/related-replan.md — code, tests, specs, and sibling Changes a later policy must replan — load before creating that Change
- `data/closure.yaml` — Completed-closure input for the archive primitive.
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last.
