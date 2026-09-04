## Why

An exact `git.commit` for the completed Scenario authoring Change was rejected because Git similarity detection classified a new in-scope archive spec as a copy of an unchanged spec in an older out-of-scope archive. Harness treated that advisory copy classification like a true rename crossing the scope boundary. The safe commit required the unchanged source path to be added artificially to the allowed scope.

## What Changes

- Allow a target-only addition to be committed when an unchanged tracked path outside scope has identical or similar content.
- Continue rejecting a true staged rename whose source deletion and target addition cross the requested scope.
- Make candidate isolation reason from actual path mutations rather than Git's optional copy-similarity label.
- Update focused Git fixtures, exact-commit guidance, and the durable `harness/git` contract.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `harness/git`: Distinguish unsafe cross-scope renames from safe in-scope additions that Git reports as copies of unchanged tracked content.

## Impact

This parent-repository Harness change affects the Git operations module, its direct fixture, exact-commit guidance, and the current `harness/git` spec. It does not weaken outside staged-path, intent-to-add, unmerged-index, hook expansion, ref/index restoration, or exact commit-content checks.
