## Context

`Plugins/Angelscript/Source/AngelscriptTest/Bindings` historically mixed two responsibilities:

- Binding-surface contract checks: an AS-visible manual/default bind exists, compiles, and reaches the expected native entrypoint.
- Broad semantic coverage: value matrices, type combinations, boundary cases, lifecycle behavior, and runtime state permutations.

The project now has `Plugins/Angelscript/Source/AngelscriptTest/Coverage` plus OpenSpec `test-coverage` matrices as the owner for large semantic coverage. Keeping those matrices in `Bindings/` duplicated test intent, made Bindings harder to audit, and encouraged new tests to expand the wrong layer.

This change therefore completes two passes:

- Stage 1 normalizes Bindings test layout, inline AS formatting, helper-result assertions, and test registration gating.
- Stage 2 narrows Bindings to binding-surface contract/smoke tests and moves or records broad matrix ownership under Coverage before trimming duplicates.

## Goals / Non-Goals

**Goals:**

- Make `Bindings/` prove exposed binding entrypoints are present, callable, and wired to native dispatch.
- Make `Coverage/` the owner for semantic, type, boundary, lifecycle, physics, input, asset, and matrix-style coverage.
- Avoid net coverage loss by adding or confirming Coverage ownership before deleting semantic content from Bindings.
- Keep the change test-only: no runtime binding behavior, generated binding contract, editor behavior, or public plugin API changes.
- Leave a durable per-file disposition and high-value `Bind_*.cpp` contract inventory for later batches.

**Non-Goals:**

- Create a one-to-one test file for every `Bind_*.cpp` runtime binding file.
- Finish every future `Trim later` item recorded in `contract-scope-plan.md`.
- Rename all historical FunctionLibraries automation prefixes in one mass change.
- Refactor Coverage architecture beyond the rows and tests needed to preserve migrated Bindings coverage.

## Decisions

### Bindings is a contract layer

Bindings tests keep only checks that answer whether a declaration, method, property, namespace function, operator, mixin, fallback path, or negative binding boundary is visible and dispatches from AS.

Alternative considered: keep Bindings as a second coverage matrix layer and only fix formatting. That leaves the same ownership ambiguity in place, so broad tests would continue to grow in two directories.

### Coverage owns semantic matrices

Large value/type/runtime matrices move to `Coverage/` or remain there if already covered. The Stage 2 source pass targeted the highest-duplication families first: FString, TArray/TMap/TSet, WorldCollision, UObject, EnhancedInput, AssetRegistry, and Math.

Alternative considered: delete duplicated Bindings matrices without adding Coverage rows. That would make the directory cleaner but reduce regression coverage, so the migration rule forbids it.

### Add-first before delete

When Coverage did not clearly own a moved behavior, the Coverage row/test was added first, then the Bindings duplicate was trimmed. Examples include UObject flag/outer-chain coverage, EnhancedInput runtime mapping construction, and AssetRegistry live query parity.

Alternative considered: record the missing Coverage rows only in OpenSpec and trim Bindings immediately. That would make the implementation incomplete because the safety rule would not be enforced by tests.

### FunctionLibraries stay in Bindings

Function-library mixin tests remain under `Bindings/` because their primary question is whether an AS-visible function-library/mixin entrypoint exists and reaches native code. Historical `Angelscript.TestModule.FunctionLibraries.*` prefixes are not mass-renamed in this pass; future touched files should normalize toward `Angelscript.TestModule.Bindings.FunctionLibraries.*`.

Alternative considered: split function-library tests into a separate directory/prefix. That adds a new test layer without changing the actual ownership question, so it is left out of this refactor.

### `Trim later` means future scoped batch

`contract-scope-plan.md` still records files that are broader than the ideal contract shape. Those are not Stage 2 blockers unless their Coverage owner is already explicit and the task list names them for this pass. This avoids hiding future cleanup while keeping the current change reviewable.

Alternative considered: expand Stage 2 until every broad Bindings file is reduced. That would turn a focused consolidation into a large coverage migration touching many unrelated domains.

## Risks / Trade-offs

- Broad Binding tests may hide useful regression coverage. Mitigation: keep or add Coverage ownership before deleting semantic bodies.
- Contract smokes can become too shallow. Mitigation: each retained smoke must call a representative AS-visible entrypoint and assert an observable native result or expected diagnostic.
- Historical automation totals change. Mitigation: record old and new Bindings totals in `verification.md`.
- Remaining `Trim later` entries can be mistaken for incomplete acceptance. Mitigation: `contract-scope-plan.md` distinguishes executed Stage 2 files from future cleanup candidates, and this design states they are future scoped batches.
- FunctionLibraries prefix inconsistency remains temporarily. Mitigation: record the placement decision now and normalize prefixes only when touching those files.

## Migration Plan

1. Realign `Documents/UnitTest/UnitTest.md` and `Documents/Guides/TestConventions.md` so new tests follow the Bindings-vs-Coverage boundary.
2. Record a per-file Bindings disposition and high-value `Bind_*.cpp` contract inventory in `contract-scope-plan.md`.
3. For each targeted family, confirm or add Coverage ownership before removing broad semantic Bindings content.
4. Trim Bindings files to contract/smoke tests and remove obsolete helpers only after no remaining file uses them.
5. Verify formatting/static checks, build, full Bindings prefix, and affected Coverage prefixes.

## Open Questions

- Which remaining `Trim later` family should be the next scoped batch: date/time, optional, foreach, utility, primitive component, or math orientation?
- Whether FunctionLibraries prefixes should be normalized opportunistically only, or scheduled as a separate mechanical cleanup after this change is archived.
