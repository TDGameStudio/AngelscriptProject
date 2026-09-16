# Plan-acceptance self-review

Date: 2026-09-11

## Coverage

| Requirement / acceptance | Task |
| --- | --- |
| Record that `_REPLACED_N` replacement UClasses are tombstones, not immediate `BeginDestroy` | 1.1 |
| Record that they are out of lookup/spawn and only jump stale pointers through `NewerVersion` | 1.1 |
| Record that they usually linger until editor shutdown after instances move | 1.1 |
| Inventory code, tests, historical knowledge, specs, and active Changes for a later lifetime-policy replan | 1.1 |
| Do not change ClassGenerator / ClassReloadHelper / SDK lifetime | 1.1 Outcome exclusion |
| Acceptance: knowledge candidate and related-replan attachment exist with the named evidence strings | 1.1 |

No current-spec delta. Linger-versus-collect remains unchosen.

## Placeholder scan

Scanned proposal, design, tasks, talk, INDEX, and this file. No `TBD`, `TODO`, `implement later`, `fill in details`, `add appropriate error handling`, `add validation`, `handle edge cases`, `write tests for the above`, `similar to Task`, `known values`, or `existing fixtures`.

## Symbols

Names match design vocabulary: `UASClass`, `_REPLACED_N`, `NewerVersion`, `GetMostUpToDateClass`, `CreateFullReloadClass`, `CleanupRemovedClass`, `CLASS_NewerVersionExists`, `RF_Standalone`, `ForceGarbageCollection`. No new public C++ names.
