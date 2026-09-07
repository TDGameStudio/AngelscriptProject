# INDEX

## Current position

Creation-only record following the user's accepted constructor-unification direction. Read proposal.md for canonical motivation and scope, then tasks.md for the pending planning outcome. No product implementation or runtime verification has occurred.

## Hard conclusions

- Reduce language noise by removing class-body default syntax and its separate executable phase, not by renaming that phase.
- Constructors can establish CDO defaults; supported default restoration is a host data operation and does not require ClassDefault.
- Replay, explicit reset and reload migration have different effects. Preserve those distinctions and Blueprint/instance overrides.
- Existing compiler evidence and dormant legacy-host evidence have different validity boundaries.

## Attachment index

- data/defaults-construction-evidence.md — Read-only source evidence and migration hotspots from the September 6 exploration; read when completing design, scope and focused verification.
