# Worked example: one **Cases** block in the open-shapes form

Written 2026-09-11 18:14 against the settled Round 1–2 decisions (open kinds, fixed case header, closed role set, one `Setup:` paragraph, example-table allowed for ≥4 homogeneous rows, sequence steps as action → observation). Content is adapted from `refactor-sdk-drop-native-gc` task 1.1 so the shapes are exercised by a real feature; the numbers are illustrative, not that Change's plan.

## What preflight reads

Only the header line of each case, matched by:

```
^\d+\. \*\*[^*]+\*\* — (new RED|existing control|boundary)( · [a-z][a-z-]*)?\s*$
```

Everything under the header is free Markdown. Preflight counts at least one `new RED`; the `· kind` suffix is optional and is not validated against a list.

## The block

```markdown
**Cases**

Setup: one `asIScriptEngine` created through `FScopedNativeEngine` with a destructor-counting class `Node` registered as `asOBJ_REF | asOBJ_SCRIPT_OBJECT`; `Node.next` is a `Node@` handle. Oracle for every lifetime case is `Node::DestructorCount`, read after the named step and again after engine teardown.

1. **RejectGcFlag** — new RED · behavior
   Given `DefineType("Gc", asOBJ_REF | asOBJ_GC | asOBJ_SCRIPT_OBJECT)` When the module is frozen and registered Then registration fails with `asERR_ILLEGAL_OBJECT_FLAGS` naming `Gc`, and `GetTypeInfoByName("Gc")` is null.

2. **UnrootedSelfCycleLeaks** — new RED · sequence
   Replaces: `UnrootedSelfCycleFinalizesOnce` (asserted collection; deleted in this task).
   1. `Node@ a = Node(); a.next = a;` inside `main()` → after `Execute`, `DestructorCount == 0` (the cycle is unreachable and nothing collects it).
   2. `ctx->Unprepare()` → still `0`; the context held no reference to `a`.
   3. `engine->ShutDownAndRelease()` → `DestructorCount == 1`; teardown destroys leased objects without a collector.

3. **LastReleaseDestroys** — existing control · behavior
   Given Setup When an acyclic `Node` is allocated by script and its last handle is released by `asVmRelease` Then `DestructorCount` becomes `1` exactly once and does not change at teardown.

4. **ReleaseMatrix** — boundary · example-table
   Template: Given Setup and the script `<script>` When `Execute` then `Unprepare` Then `DestructorCount == <after execute>` and after teardown `== <after teardown>`.

   | script | after execute | after teardown |
   |---|---|---|
   | `Node@ a = Node();` | 1 | 1 |
   | `Node@ a = Node(); Node@ b = a;` | 1 | 1 |
   | `Node@ a = Node(); a.next = Node();` | 2 | 2 |
   | `Node@ a = Node(); a.next = a;` | 0 | 1 |
   | `Node@ a = Node(); Node@ b = Node(); a.next = b; b.next = a;` | 0 | 2 |

5. **NoPublicCollect** — new RED · absence
   Must not compile against `asIScriptEngine` in `NewVersion/Bindings/GcAbsenceTests.cpp`: `GarbageCollect`, `GetGCStatistics`, `NotifyGarbageCollectorOfNewObject`, `GetObjectInGC`, `SetEngineProperty(asEP_AUTO_GARBAGE_COLLECT, 0)`. Oracle: the file is compiled with each symbol under `#if AS_EXPECT_NO_GC_API` and the build selector `ue.build -Target AngelscriptTestEditor` reports the five expected errors and no other.

6. **ReleaseCostUnchanged** — boundary · measurement
   Corpus: `Tests/Corpus/lifetime-10k.as` (10 000 acyclic allocations, checked in).
   Metric: wall time of `Execute` + `Unprepare`, median of 20 runs, Development build, single thread.
   Bound: ≤ 1.05 × Baseline.
   Baseline: `attachments/data/lifetime-baseline.json` captured on the parent commit before this task with the same command; the measurement fails if the file is missing rather than measuring against nothing.
```

## Why each shape earns its place here

```
Setup:              // one fixture host and one oracle stated once; cases say "Given Setup" instead of repeating 40 words
1 behavior          // the plain Form 2 sentence still works; nothing changed for simple cases
2 sequence          // three moments in one test, each step is action → observation; one role, one oracle; "Replaces:" keeps lineage as prose, not as a fourth role
3 existing control  // unchanged Form 2, tagged so TDD does not count it as RED evidence
4 example-table     // five homogeneous rows under one clause template; this is the Gherkin Scenario Outline shape, and the reason tables come back only here
5 absence           // a negative contract with an explicit compile oracle; Given/When/Then would have read oddly
6 measurement       // four fixed fields; the baseline file is named so the bound is independently derived
```

## What did not change

- The card still has `**Interfaces**` above and `**Files**` / `**Verification**` below; the Rust parser reads none of this.
- `test-driven-development` derives the RED group from cases 1, 2, 5 and treats 3, 4, 6 as controls and boundaries; no step in case 2 becomes a checkbox or a work item.
- A kind word that is not in the catalog (`· protocol`, `· golden`) is legal; the catalog in `openspec/references/cases.md` is recommended shapes, not a whitelist.
