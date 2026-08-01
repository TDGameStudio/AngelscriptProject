# Verification Record

Verification date: **2026-07-31**. Source reports: 2026-05-11 → 2026-06-03.
Tree: `Plugins/Angelscript/` at the working-tree state of this change.

## Why verification was mandatory

The reports predate 104 archived OpenSpec changes (2026-05-12 → 2026-07-30). Treating them as current would have produced a registry that was wrong in both directions: proposing work already done, and understating problems that grew. Both error types were found.

## Method

1. **Extraction** — the 13 substantive reports were read in full and architecture-level findings extracted verbatim with their cited identifiers. The 2,653 auto-generated `FunctionReview_*` files were excluded as machine-generated per-function noise, not architectural analysis.
2. **Coverage survey** — all 29 active and 104 archived OpenSpec changes were surveyed for existing coverage, so verified findings could be mapped rather than duplicated.
3. **Re-verification** — each high- and medium-severity claim was checked against current source: `wc -l` / `ls -la` for size claims, `grep` plus reading surrounding code for identifier and synchronisation claims, directory listings for structural claims. Counts were re-measured rather than copied.
4. **Manual adjudication** — two claims that automated checking left ambiguous were resolved by direct reading (below).

Reports were treated as **hypotheses**. Verdicts follow the code.

## Claims adjudicated manually

**A6 — `bHadCompileErrors` `ParallelFor` race.** Reported as a race but the initial check could not confirm the write happened inside worker scope. Resolved by reading `AngelscriptEngine.cpp:3885-3925`: `ParallelFor(TaskCount, [&](int TaskIndex)` at `:3891`, and inside the worker body at `:3910-3911`:

```cpp
Module->bCompileError = true;
bHadCompileErrors = true;
```

`bHadCompileErrors` is a plain `bool` captured by reference and written from multiple workers with no atomic and no per-task accumulator. **Confirmed data race** — the one finding in the registry that is a definite correctness defect rather than a structural risk.

**B7 — `AngelscriptEditorCodeGen.cpp` missing header.** Confirmed by listing `AngelscriptEditor/CodeGen/`, which contains only `AngelscriptEditorCodeGen.cpp`. The sole other match tree-wide is `AngelscriptEditor/Tests/AngelscriptEditorCodeGenTests.cpp`. No header exists for a 2,812-line module.

## Where the reports were wrong

Recorded so the reports are not re-mined as if authoritative.

| Report claim | Verified reality |
| --- | --- |
| `AngelscriptClassGenerator.cpp` is a ~208 KB god object | Decomposed into 7 files; largest is 1,990 lines |
| `ASClass.cpp` is a ~100 KB god object | 18 lines; logic in header + 2 focused files |
| Hooks fragmented across 3 layers / 7 registration points | UE side unified behind `FAngelscriptEngineExtensionRegistry` + inlined delegates (removed 133 indirect call sites); only the native AS layer stays separate |
| `ActiveTickOwners` is a static count, not per-world | Identifier does not exist anywhere in the tree |
| Console prefixes fragmented incl. `as.P3_2.` | Only `angelscript.` and `as.` exist; `as.P3_2.` was never present |
| 152 direct vendored includes | 203 — and `ClassGenerator/` (67) and `StaticJIT/` (49) were omitted from the original count entirely |
| 31 `AS_*` static constants | 42 |
| 588 dead lines in editor codegen | 593 |
| 15+ virtuals missing `override` | 11 |
| 177/224 BlueprintCallable lack `Category` | 168/212 — same 79%, so the intervening period produced no improvement |

## Distribution of verdicts

| Verdict | Count | Notes |
| --- | --- | --- |
| STILL TRUE | 30 | includes 1 confirmed data race (A6) |
| REGRESSED | 3 | E1 152→203, G1 31→42, B7 588→593 |
| PARTLY FIXED | 7 | A8, A9, C3, D1, F3, G3, G5 |
| FIXED | 2 | B9, B10 |
| NOT FOUND | 1 | F5 — close without action |
| UNVERIFIED LEAD | 11 | section H, third-party sourced; require repro |

## Confidence

**High** — A1–A6, B1–B8, C1–C6, E1–E5, F1–F4, G1–G5. Directly measured or read in current source; every entry carries a `file:line` or a re-counted figure.

**Medium** — D2–D6. Established by absence of a construct; a differently-named mechanism could exist. Searched for the obvious names and found none.

**Unverified** — H1–H11. Sourced from Hazelight Discord signals and the instrumentation review; not reproduced in this tree. Recorded as leads only, and section H is separated from A–G for exactly this reason.

## Limits of this verification

- Line-count and `grep` verification proves a construct is *present*; it does not prove the risk *manifests*. Thread-safety findings A1–A6 are sound on inspection but no failing test was written — A6's race is real by the C++ memory model regardless of whether it has been observed to fire.
- Coverage mapping relies on change proposals and task checkboxes, not on reading each archived change's diff. A change marked complete is assumed to have delivered its stated scope.
- Section H is explicitly not verified. Nothing there should be scoped as work without reproduction first.
