## Why

`AngelscriptTest/Bindings` grew before the current CQTest and inline AngelScript formatting rules, and before `AngelscriptTest/Coverage` (backed by OpenSpec `test-coverage`) became the authoritative large-matrix coverage layer. Two problems remain:

1. **Structure/formatting** (Stage 1, done): many Bindings files used file-level `RunXxxSection()` wrappers, legacy raw-string inline AS, and ignored helper results.
2. **Responsibility** (Stage 2, implemented): even after formatting normalization, Bindings still hosted large semantic matrices that duplicated `Coverage/` — FString method/format/split/join semantics, TArray/TMap/TSet type/return/nested-rejection matrices, WorldCollision hit/miss physics parity, UObject lifecycle/flag/nesting, EnhancedInput full mapping construction, and Math numeric semantics. Meanwhile `Documents/UnitTest/UnitTest.md` §4 and `Documents/Guides/TestConventions.md` still actively recommended "type matrix / API entry-point coverage / boundary / exception" as the Bindings organizing dimensions, which kept pulling new work toward duplicating Coverage.

The narrowed goal: **Bindings proves the binding surface** — "is this manually/default-bound class, function, method, property, operator, or namespace entry visible to AS, callable through the expected declaration, and wired to the intended native path?" — as narrow smoke/contract checks. **Coverage owns the broad semantic matrices.** Stage 1 recorded this boundary as a spec requirement; Stage 2 makes the source and the docs actually match it.

## What Changes

### Stage 1 — Layout and formatting normalization (done)

- Move executable test flow into `TEST_CLASS_WITH_FLAGS` / `TEST_METHOD` bodies instead of file-level `RunXxxSection()` wrappers.
- Normalize inline AS to `ASTEST_AS(...)` / `ASTEST_AS_ANSI(...)` and enforce `ASInlineFormattingRule.md`.
- Consume `ExpectGlobal*` / `Execute*` / parity / math helper results through matcher assertions.
- Record the Bindings-vs-Coverage responsibility boundary in `responsibility-boundary.md` and the spec.

### Stage 2 — Responsibility narrowing and source consolidation (implemented)

- Realign the docs first: rewrite `UnitTest.md` §4 and `TestConventions.md` Bindings rows so Bindings is described as a **binding-surface contract/smoke layer**, not a per-type coverage matrix.
- Produce a per-file disposition audit for all Bindings `.cpp` files with one of four labels: `Keep as contract`, `Trim to smoke`, `Move/Delete duplicate (Coverage owns it)`, `Needs missing contract`.
- Produce a `Bind_*.cpp` → Bindings contract-smoke inventory so it is knowable which manual/default binds have a dedicated contract smoke and which are only reached indirectly.
- Execute dispositions batch-by-batch, starting with the heaviest, most Coverage-duplicating families (FString, TArray/TMap/TSet, WorldCollision, UObject, EnhancedInput, Math). **Migration rule: never delete a Bindings test until Coverage already has an equivalent matrix row (add to Coverage first if missing), then trim Bindings to the minimal entrypoint smoke.**
- Decide and record the FunctionLibraries mixin placement: either explicitly declare function-library mixin binds as part of Bindings contract, or split them to their own directory/prefix.

Both stages remain test-only: no runtime binding behavior, public plugin APIs, or generated binding contracts change.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `as-bindings-test-execute-and-naming`: Tightens layout, naming, assertion consumption, inline AS formatting, and the Bindings-vs-Coverage responsibility boundary; Stage 2 additionally requires the project docs to describe Bindings as a binding-surface contract layer rather than a coverage matrix, and requires a per-file disposition and `Bind_*.cpp` contract inventory before large matrix content is trimmed or moved.

## Impact

- Source (Stage 1): all C++ test files under `Plugins/Angelscript/Source/AngelscriptTest/Bindings` (`89` `.cpp`, `6` `.h`) audited; `88` `.cpp` plus the shared section header edited.
- Source (Stage 2): the same Bindings directory now has `90` active `.cpp` files and `5` helper/fixture `.h` files after adding `AngelscriptBlueprintTypeBindingsTests.cpp` and removing the obsolete `AngelscriptTArrayBindingsTestHelpers.h`; `Coverage/` matrices receive content migrated out of Bindings; `~121` `Bind_*.cpp` files in `AngelscriptRuntime/Binds` are the reference surface for the contract inventory (no runtime edits).
- Docs (Stage 2): `Documents/UnitTest/UnitTest.md` §4 and `Documents/Guides/TestConventions.md` Bindings rows must be realigned to the contract-smoke framing.
- Coverage boundary: `Coverage/` and OpenSpec `test-coverage` remain the home for broad behavior matrices; migrated matrix content lands there.
- Validation: full plugin build; `Angelscript.TestModule.Bindings.` automation prefix; for any migrated content, the corresponding `Angelscript.TestModule.Coverage.` prefix.
- Behavior: test code structure/placement and docs only; Angelscript runtime/editor behavior unchanged.
