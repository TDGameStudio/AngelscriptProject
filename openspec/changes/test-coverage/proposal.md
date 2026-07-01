## Why

`Documents/Coverage/` accumulated 80 scattered coverage documents, including plans, progress notes, reports, and "task completed" celebration notes. Their status columns are badly outdated: `Coverage_MasterIndex.md` still claims roughly 12% overall completion and 0% for "very high priority" areas such as physics, input, and UI. In reality, `Plugins/Angelscript/Source/AngelscriptTest/Coverage/` already contains **89 test files, 90 Automation themes, and about 980 `TEST_METHOD`s**, with physics, enhanced input, touch, UI animation, networking, and more already implemented. The documents are out of sync with code and cannot be used as a trustworthy record.

Following the project convention that "OpenSpec = record", `Documents/Coverage/` is retired and coverage records are consolidated into this OpenSpec change. This change rebuilds the coverage record in a unified matrix format, using **actual test code as the single authoritative source**.

This change is positioned as a bridge between past and future work: it records completed coverage work in a unified matrix and turns remaining gaps plus documentation retirement into executable follow-up work.

- Add coverage matrix records: `coverage-matrix.md` serves as the **main index**, with unified legend, column definitions, domain index, and global summary. Details are split by **AS type / feature area** into **18 domain matrices** under `matrices/`, such as `01-basic-types.md`, `03-containers.md`, `06-ustruct.md`, and standalone large-system documents for physics, input, Widget, networking, and related areas.
- Treat domain matrices as **expanded design specifications**, not file indexes: each row is a **specific verifiable scenario** or usage pattern. Rows record coverage status, ✅/🟡/⬜/🚫, and the `TEST_METHOD` that asserts the scenario, so they document current coverage and guide future test implementation. ⬜ rows are pending work items.
- Calibrate the current true scale by mechanically counting leading `TEST_METHOD(...)` lines: **89 files / 90 themes / 1010 methods**. This corrects historical counting drift in files such as `UFunction`, `FRotatorExpression`, and `Debug`; the older "about 980" estimate was low. After adding G1/G2/G5/G6/G8/G10 on 2026-07-01, AnimInstance +1, SaveGame +1, TArrayAdvanced +1, TMapAdvanced +1, UClass +1, ClassLifecycle +1, plus a backfilled Comment +1 omitted from the main index.
- Add `coverage-gaps.md` to record real pending/enhancement items, fork-unsupported or not-applicable boundaries, and corrections for historical "false gaps". Code audit confirmed items such as GC cycles and dynamic material parameters are already covered.
- Use `tasks.md` sections 4-6 for follow-up work: documentation retirement cutover, selected low/medium-priority gap additions, and matrix maintenance rules. Cutover first redirects test `.cpp` header comments and two skill documents from `Documents/Coverage/` to this record, then removes that directory.
- Establish OpenSpec as the single source of truth for Coverage records, replacing scattered documents under `Documents/Coverage/`.
- Documentation retirement cutover has already run: 38 test `.cpp` header comment references and two skill documents now point to this record, then `Documents/Coverage/` was removed with its 80 files. The initial edits were comment-string-only; on 2026-07-01, six local Coverage tests for G1/G2/G5/G6/G8/G10 were also added.

## Capabilities

### New Capabilities

- `as-test-coverage`: defines that AngelScript Coverage test coverage is recorded in OpenSpec through unified matrices, using actual test code as the authoritative source and distinguishing covered, pending, and fork-unsupported states.

### Modified Capabilities

- None.

## Impact

- Added inside this change directory:
  - `openspec/changes/test-coverage/coverage-matrix.md`, the main index
  - `openspec/changes/test-coverage/matrices/01-basic-types.md ... 18-misc-systems.md`, the 18 expanded domain matrices
  - `openspec/changes/test-coverage/coverage-gaps.md`
  - `openspec/changes/test-coverage/specs/as-test-coverage/spec.md`
- Removed during follow-up cutover: the full `Documents/Coverage/` directory.
- Added in the submodule on 2026-07-01: `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageAnimInstanceTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageSaveGameTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTArrayAdvancedTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageTMapAdvancedTests.cpp`, and `Plugins/Angelscript/Source/AngelscriptTest/Coverage/AngelscriptCoverageUClassTests.cpp`.
