## Why

The current `as.DumpEngineState` CSV export is useful for broad diagnostics, but it is not a complete member-level snapshot of `FAngelscriptEngine` and it has no built-in before/after diff. Compiler-event tests and future reload/compile investigations need a stable way to capture the full FAS engine footprint plus the underlying AngelScript VM/module internals before and after a compile, then report exactly which state categories changed.

## What Changes

- Add a full diagnostic state snapshot layer for `FAngelscriptEngine` and the underlying AngelScript runtime internals.
- Extend state dump output with stable machine-readable snapshot tables that cover engine member categories, engine-owned collections, AS engine internals, AS module internals, AS type rows, and AS function rows.
- Add a state diff API that compares two snapshots and emits a normalized `StateDiff.csv` table with added, removed, changed, and unchanged summary rows.
- Extend `as.DumpEngineState` diagnostics so the existing human-friendly tables remain available while the new snapshot tables can be used for impact analysis.
- Add focused runtime integration tests proving a compile changes both FAS engine state and low-level AS VM/module state, and that the diff captures those changes.
- Keep snapshot and diff read-only: no compile, reload, module discard, hot-reload queue mutation, or diagnostic emission should happen while observing state.

## Capabilities

### New Capabilities

- `as-engine-state-dump-diff`: Full diagnostic engine state snapshots and before/after diffs for FAS engine state and low-level AngelScript runtime internals.

### Modified Capabilities

- None.

## Impact

- **AngelscriptRuntime**: Add dump-local snapshot/diff types under `Plugins/Angelscript/Source/AngelscriptRuntime/Dump/`, extend `FAngelscriptStateDump`, and add narrow friend/test access where required to observe private engine member categories without exposing mutable runtime internals as public API.
- **AngelScript internals**: Dump implementation will include private AngelScript headers such as `as_scriptengine.h`, `as_module.h`, `as_typeinfo.h`, `as_objecttype.h`, and `as_scriptfunction.h` inside runtime diagnostics code only.
- **Console diagnostics**: `as.DumpEngineState` remains compatible, but output includes additional snapshot tables and summary rows. A later command can be added for direct before/after diff capture if a concrete workflow needs it.
- **AngelscriptTest**: Add runtime integration tests under `Plugins/Angelscript/Source/AngelscriptTest/Dump/` with prefix `Angelscript.TestModule.Dump.StateDiff.*`.
- **Existing reflectable-state change**: `feature-as-engine-reflectable-state` remains separate. That change is for UE reflection-visible summaries; this change is for external diagnostic dump/diff fidelity.
