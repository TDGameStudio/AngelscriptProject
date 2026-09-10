# Attachment index

## Current position

Implementation and local 0.9.0 cutover are verified. Read tasks.md and final-verification.md for exact completion scope. Existing business records and pre-existing archives remain unchanged.

## Accepted boundaries

- No web work, no old-format compatibility, no automatic business-record migration.
- Detailed content uses ordinary owned Markdown; task status and dependency authority remain singular.
- The implementation record transitions from installed-package bootstrap syntax to the new syntax at local package cutover.

## Evidence

- [Implementation evidence](implementation-evidence.md): Task and Scenario RED/GREEN, adjacent graph/validator checks and verification scope.
- [Authoring exercise](authoring-exercise.md): same raw requests, honest before/after comparison, observed indentation defect and correction.
- `data/authoring-before.md` - original independent old-guidance output.
- `data/authoring-after.md` - original independent new-guidance output, including the two detected continuation defects.
- `data/authoring-after-spec-corrected.md` - focused corrected Spec output; original outputs remain unchanged.
- [Final verification](final-verification.md): final release identity, package/Harness gates, old-format cutover and preserved scope.
- `data/closure.yaml` - explicit completed closure input.
- `data/workflow-evaluation.md` - terminal workflow evaluation, written last against the final active-record digest.
