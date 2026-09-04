## Context

`Assert-GitNoCrossScopeRenameOrCopy` runs `git diff --cached --name-status --find-renames --find-copies-harder` against an isolated candidate index. `--find-copies-harder` may classify any new file as copied from an unchanged tracked file solely because content is similar. The current check rejects when only one reported endpoint is in scope, even though a copy has no source-side mutation.

## Goals / Non-Goals

**Goals:**

- Validate scope boundaries from actual mutations.
- Keep true cross-scope rename protection.
- Prove a target-only copied addition commits without broadening its scope.

**Non-Goals:**

- Relax outside staged-path, hook, intent-to-add, unmerged-index, or index-preservation checks.
- Change public `git.commit` parameters or commit ordering.
- Disable rename detection.

## Decisions

### Detect renames, not copies, for the crossing check

The boundary helper will request rename detection only and inspect `R` records. A rename represents a paired source deletion and target addition, so both endpoints must be covered. A `C` record is an advisory similarity interpretation for a target addition; its source remains unchanged and is not part of the commit's mutated path set.

### Convert the previous copy-rejection fixture into an acceptance fixture

The direct test will copy a tracked source to a new target, commit only the target scope, and assert that the commit contains exactly the target while the source remains present and unchanged. The existing real rename fixture continues to prove rejection and restored state.

## Risks / Trade-offs

- Removing copy classification from this check could appear to weaken isolation. Other candidate checks still enumerate actual staged paths and reject every path outside scope, so an actual source modification cannot escape detection.
- Git may represent similar changes differently across versions. Basing safety on path mutations rather than similarity scoring makes behavior less dependent on heuristics.
