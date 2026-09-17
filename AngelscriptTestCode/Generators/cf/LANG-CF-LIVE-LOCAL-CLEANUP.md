# LANG-CF-LIVE-LOCAL-CLEANUP

Author reference for `FLiveLocalCleanupGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scope: `LOOP` | `BRANCH_LOOP` | `NESTED_LOOP` | `SWITCH_LOOP`
2. Exit: `NORMAL` | `BREAK` | `CONTINUE` | `RETURN` | `EXCEPTION`
3. Depth: `ONE` | `TWO` | `THREE`
4. Local count: `ONE` | `TWO`
5. Line ending: `LF` | `CRLF` (typed API only)

Product ID prefix: `LANG-CF-LIVE-LOCAL-CLEANUP`. Declared inventory is 120 cells, all `-LF`. Complete LF set: 4×5×3×2 = 120. Normal-return aggregate = 96. Compile reject = 0. Runtime fault = 24 (`EXCEPTION` × every scope × every depth × both local counts). Typed `BuildLiveLocalSource` still accepts `CRLF` and rewrites line endings; CRLF is not a catalog member of the 120 IDs.

Example: `LANG-CF-LIVE-LOCAL-CLEANUP-LOOP-NORMAL-ONE-ONE-LF` → `int EntryLangCfLiveLocalCleanupLoopNormalOneOneLf()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated module:

- `struct FScopedLifetimeProbe` calling host `BeginNativeScriptLifecycle` / `EndNativeScriptLifecycle`.
- `int Recovery()` returning `97`.

Each entry declares `Trace`, then a scope wrapper around one to three nested `for (int LevelN = 0; LevelN < 1; ++LevelN)` bodies. Each level constructs `Local_{level}_{slot}((level)*100 + slot)` probes and adds `(level)*100` to `Trace`. After the loop it adds `(level)*1000`. The deepest level applies the exit:

- `normal`: no extra transfer
- `break`: `Trace += 7; break;`
- `continue`: `Trace += 11; continue;`
- `return`: `Trace += 13; return Trace;`
- `exception`: `Trace += 17;` then `Trace += 1 / ExceptionDivisor` with divisor 0

Wrappers:

- `loop`: nested levels only
- `branch_loop`: `if (true) { levels }`
- `nested_loop`: `for (ShapeLoop) { if (ShapeLoop >= 0) { levels } }`
- `switch_loop`: `switch (0) { case 0: { levels; break; } default: { break; } }`

Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent oracle `SimulateNestedScopes`:

- enter level: `+(level+1)*100`
- deepest `return`: `+13` and stop (no `*1000`, no Recovery `+97`)
- deepest `break` / `continue`: `+7` / `+11`, then fall through
- deepest `exception`: `+17` and stop; catalog observation is runtime fault, not this integer
- otherwise recurse; a nested return propagates without adding this level's `*1000`
- leave level: `+(level+1)*1000`
- if the walk did not return: `+97` (`Recovery`)

`GetExpected` uses this formula for the 96 normal IDs and returns 0 for the 24 fault IDs and unknown IDs. That zero fallback is not membership proof. No normal LF cell has expected 0.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` with exact text `Divide by zero` and no integer expectation. Host notes name `BeginNativeScriptLifecycle` and `EndNativeScriptLifecycle`.
