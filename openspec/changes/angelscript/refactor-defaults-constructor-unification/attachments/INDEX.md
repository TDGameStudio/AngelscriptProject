# INDEX

## Maintenance baseline — 2026-09-12

Read [Current-baseline maintenance](data/maintenance-20260912.md) before historical attachments. It records current source ownership, preserved task state, exact format checks and remaining planning boundaries. Historical talks, research snapshots and applied replans are provenance rather than current API authority.

## Current position

Creation-only record following the user's accepted constructor-unification direction. Read proposal.md for canonical motivation and scope, then tasks.md for the pending planning outcome. No product implementation or runtime verification has occurred.

## Hard conclusions

- Reduce language noise by removing class-body default syntax and its separate executable phase, not by renaming that phase.
- Constructors can establish CDO defaults; supported default restoration is a host data operation and does not require ClassDefault.
- Replay, explicit reset and reload migration have different effects. Preserve those distinctions and Blueprint/instance overrides.
- Existing compiler evidence and dormant legacy-host evidence have different validity boundaries.

## Attachment index

- data/defaults-construction-evidence.md — Read-only source evidence and migration hotspots from the September 6 exploration; read when completing design, scope and focused verification.

- [Applied current-baseline replan](replans/replan-20260912-073639-current-baseline.md) — accepted record maintenance; current paths, ownership and proof boundaries; read before resuming the pending plan.
