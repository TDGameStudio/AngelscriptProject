# Task Case Catalog

Load this reference when writing or reviewing the `**Cases**` block of a behavior task, or when preflight must judge a case header. The Rust parser reads none of this; Skill preflight reads only the header line of each case and the definition paragraphs described here. The card contract that owns the surrounding labels is [tasks.md](tasks.md).

## Shape

```text
**Cases**
Setup: <one shared precondition paragraph, optional, unnumbered>       // cases say "Given Setup"
Roles: `<word>` — <what it means; how RED/GREEN treats it>             // only for roles outside the standard set
Kinds: `<word>` — <what the body carries; what its oracle is>          // only for kinds outside the catalog

N. **Name** — <role> · <kind>                                          // header: the one line preflight reads; "· <kind>" optional
   <free Markdown body>                                                // literal input, independently derived expectation, named oracle
   Replaces: <old case name>                                           // optional prose lineage line
```

Header grammar, one per numbered list item:

```text
^\d+\. \*\*[^*]+\*\* — (?<role>[^·]+?)( · (?<kind>[a-z][a-z-]*))?\s*$
```

`—` is an em dash; `·` is a middle dot. A header with no kind is a `behavior` case. Every Form 2 header (`1. **Name** — new RED`) matches unchanged.

## Roles

A role says what the case does in grouped RED/GREEN. The standard set needs no definition:

| role | meaning | RED/GREEN behaviour |
|---|---|---|
| `new RED` | behaviour this card adds | written first, observed failing together, green together after implementation; at least one per behavior card |
| `existing control` | behaviour that already holds and must not break, including first-time characterization of old behaviour | green before and after; never counted as RED evidence |
| `boundary` | a limit: edge or out-of-scope input, measurement bound | failure means the line was crossed, not that the feature is missing |
| `deferred RED until X.Y` | written and observed red in this card, made green by task `X.Y` | red here and recorded in Evidence; excluded from this card's GREEN set; `X.Y` must exist in `task_graph` and its Evidence cites the case turning green |

Any other role word is legal when the block defines it once in `Roles:`; an undefined word fails preflight. Example: `` Roles: `quarantined` — runs and is recorded; neither red nor green counts toward this card; re-enabled by 3.2 ``. Lineage is the prose `Replaces:` line, never a role.

## Kinds

A kind says how the body is shaped. The catalog below is recommended, not a whitelist: any lowercase word is legal when defined once in `Kinds:` (`` Kinds: `protocol` — message round-trip table; oracle is the checked-in .trace file ``). Rules for every kind: steps and rows are observations, never work items or checkboxes; a sequence longer than about eight steps or a case with two oracles is two cases; heterogeneous table rows are a list of behaviors, not an example-table; tables appear only inside `example-table`.

### behavior (default)

Given / When / Then, one line or a short paragraph; literal input and derived expectation.

```markdown
1. **RejectGcFlag** — new RED · behavior
   Given `DefineType("Gc", asOBJ_REF | asOBJ_GC | asOBJ_SCRIPT_OBJECT)` When the module is frozen and registered Then registration fails with `asERR_ILLEGAL_OBJECT_FLAGS` naming `Gc`, and `GetTypeInfoByName("Gc")` is null.
```

### sequence

Numbered steps, each `action → observation`; one role and one oracle for the whole case; several moments in one test.

```markdown
2. **UnrootedSelfCycleLeaks** — new RED · sequence
   Replaces: `UnrootedSelfCycleFinalizesOnce` (asserted collection; deleted in this task).
   1. `Node@ a = Node(); a.next = a;` inside `main()` → after `Execute`, `DestructorCount == 0`.
   2. `ctx->Unprepare()` → still `0`; the context held no reference to `a`.
   3. `engine->ShutDownAndRelease()` → `DestructorCount == 1`; teardown destroys leased objects without a collector.
```

### example-table

`Template:` clause with `<placeholders>`, then a table of at least four homogeneous rows; normally one parameterized test whose rows red and green together.

```markdown
4. **ReleaseMatrix** — boundary · example-table
   Template: Given Setup and the script `<script>` When `Execute` then `Unprepare` Then `DestructorCount == <after execute>` and after teardown `== <after teardown>`.

   | script | after execute | after teardown |
   |---|---|---|
   | `Node@ a = Node();` | 1 | 1 |
   | `Node@ a = Node(); Node@ b = a;` | 1 | 1 |
   | `Node@ a = Node(); a.next = Node();` | 2 | 2 |
   | `Node@ a = Node(); a.next = a;` | 0 | 1 |
```

### invariant

`For all <x> in <named set>: <predicate>`; the oracle is the artifact that defines the set.

```markdown
5. **EveryInventorySiteDisposed** — new RED · invariant
   For all rows in `attachments/data/provider-migration.csv`: `disposition ∈ {active, compile-excluded, policy-excluded, test-only, no-output}`; an unexplained row fails. Oracle: the CSV itself, compared against the compiled provider list.
```

### absence

`Must not exist` / `Must not compile:` a symbol list; the oracle is the compile or lookup selector that proves it.

```markdown
6. **NoPublicCollect** — new RED · absence
   Must not compile against `asIScriptEngine` in `NewVersion/Bindings/GcAbsenceTests.cpp`: `GarbageCollect`, `GetGCStatistics`, `NotifyGarbageCollectorOfNewObject`, `GetObjectInGC`. Oracle: each symbol compiled under `#if AS_EXPECT_NO_GC_API`; the build reports exactly the four expected errors.
```

### measurement

Four fields `Corpus / Metric / Bound / Baseline`; the baseline is a checked-in artifact and a missing baseline fails the case rather than measuring against nothing; normally a `boundary`, and when it is a card's only `new RED` (a performance card) RED means the bound is currently exceeded.

```markdown
7. **ReleaseCostUnchanged** — boundary · measurement
   Corpus: `Tests/Corpus/lifetime-10k.as` (10 000 acyclic allocations, checked in).
   Metric: wall time of `Execute` + `Unprepare`, median of 20 runs, Development build, single thread.
   Bound: ≤ 1.05 × Baseline.
   Baseline: `attachments/data/lifetime-baseline.json` captured on the parent commit with the same command.
```

### golden

`Input:`, `Expected:` path of a checked-in file, the comparison rule (byte, line, normalized) and how the expected file is regenerated; red while the expected file is absent or differs.

```markdown
8. **DiagnosticTextGolden** — new RED · golden
   Input: `Tests/Golden/duplicate-key.as`. Expected: `Tests/Golden/duplicate-key.diag.txt`. Compare line by line after trimming trailing whitespace. Regenerate with `openspec-test --update-golden duplicate-key` only when the diagnostic wording change is the task's Outcome.
```

## How TDD and preflight consume the block

- Preflight (plan acceptance in `openspec-continue-change`, task start in `openspec-apply-change`) checks: every header matches the grammar; at least one `new RED`; every role or kind word outside the standard set / catalog is defined in `Roles:` / `Kinds:` of the same block; every `deferred RED until X.Y` names a task present in `task_graph`; tables appear only inside `example-table`.
- `test-driven-development` groups by role: all `new RED` cases of the card are written first and observed red in one run, then one implementation, then green together; `existing control` runs alongside and stays green; `boundary` is judged as a limit; `deferred RED` is observed red, excluded from this card's GREEN set, and cited green by the target task; a custom role follows its definition.
- Kind decides the test's inner shape: `sequence` is one test with several assertions; `example-table` is normally one parameterized test; `measurement` compares against the checked-in baseline; `golden` compares against the expected file; `absence` compiles or looks up the listed symbols.
