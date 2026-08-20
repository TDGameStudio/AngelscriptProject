# Test authoring refactor backlog

Scan of `AngelscriptTest` inline AngelScript (`ASTEST_AS`, `R"AS(`, `TEXT(R"(`) versus changes already recorded. Counts are order-of-magnitude (2026-08-18); they are not a second TestCatalog.

Question-first routing: `openspec/changes/docs-as-test-direction-map/` (`native-fork` / `surface-form` / `bind-contract` / `behavior-matrix` / `world-story` / `reload-generation` / `same-as-profile` / `host-machinery`). This backlog is **how to extract AS files**, not a second taxonomy.

## Already recorded (do not open a fourth epic for these)

| Area | Change | Driver |
|---|---|---|
| Same AS × vm/cache/JIT | `test-as-data-driven-engine-harness` | COMPLEX `DataDriven.*` |
| Shared virtual-path corpus | same, Decision 16 | `FAngelscriptTestScriptCorpus` |
| Coverage type-family slices | same, Wave B+ | generate products + dual-run CQTest |
| HotReload before/after | `test-as-hotreload-script-corpus` | COMPLEX `HotReload.Corpus` + CQTest functional |
| HotReload production boundaries | `refactor-as-hotreload-pipeline` | not a test-authoring rewrite |
| Host `Script/` teaching + `UAngelscriptTestSuite` | `test-as-script-corpus-and-functional-coverage` | **different tree** (`/Angelscript/Game/`) |
| Native SDK generators | `test-as-native-sdk-comprehensive-coverage` (done/ongoing) | keep native; do not copy into Fixtures |

## Next authoring refactors (same pain: AS trapped in C++)

Do these as **separate changes** (or later waves), after the corpus API exists. Do **not** hang them on DataDriven engine profiles unless the axis really is vm/cache/JIT.

| Priority | Theme | Why it matches | How | Do not |
|---|---|---|---|---|
| **1** | `Syntax/` (~19 files, ~580 `TEXT(R"(` blobs) | Compile/execute matrices; see `research/syntax-refactor-map.md` | Authored files + **keep CQTest** (`Assert*FromCorpus`). Packed execute first. DataDriven is optional later consumer of language-only execute files | New Syntax COMPLEX; dump 560 compile-only leaves onto DataDriven; cartesian × JIT |
| **2** | `Debugger/` (`FAngelscriptDebuggerScriptFixture` + `/*MARK:*/`) | Line-sensitive reusable scripts, already called out in Decision 16 | `Fixtures/Debugger/*.as` with markers; fixture helper loads by virtual path | DAP session rewrite; putting DAP observations on the engine harness |
| **3** | `Functional/` (~39 files, ~156 `R"AS(`) | World/Actor unique stories | Authored fixtures + existing `FAngelscriptTestWorld`; load by virtual path | DataDriven engine profiles; generating Widget/Physics from type tables |
| **4** | Coverage unique scenarios (not Wave B products) | TArray.Sort, FString methods, Widget/Net | Authored `Fixtures/Coverage/...` when a scenario is reused; keep CQTest World | Generating matrices 10–18 |
| **5** | StaticJIT TypedASTJIT ScriptCorpus | Already task 9 on the harness | Point at Fixtures | Hand-written `.jit.cpp` copies |

## Consume corpus, do not invent a new COMPLEX

| Theme | Inline scale | Keep as |
|---|---|---|
| `Generator/` | ~106 `ASTEST_AS` | CQTest ClassGenerator evidence; MAY load corpus; planner stays `Generator.ReloadPlanning` |
| `Cache/` | many C++ store tests + some AS | Store/codec/CQTest stays. AS that must survive restore uses harness `cache-roundtrip`, not a Cache COMPLEX expander |
| `StaticJIT/` packager/Provider/ABI | CQTest | Unchanged |
| `RuntimeJIT/` factory/session | CQTest | Unchanged; corpus execute is `runtime-jit` profile |
| `Bindings/` | ~286 `ASTEST_AS` | Bind **contract** one-offs. Coverage/Fixtures own matrices. Do not migrate Bindings into Fixtures |
| `FunctionLibraries/` | ~20 | Same as Bindings |
| `Testing/` (script-suite bridge) | ~51 | Tests of `UAngelscriptTestSuite` / `FBridge`; not Fixtures |

## Keep inline or C++-only (not a corpus rewrite)

| Theme | Reason |
|---|---|
| `AngelScriptSDK/` | Native engine, own generators, line-sensitive tokenizer/parser exceptions |
| `Compiler/` / `Preprocessor/` | Diagnostic row/column often **is** the oracle; extracting files can break offsets. Only extract when the case is not line-sensitive |
| `Dump/` / Offline bundle | Already has `AngelscriptOfflineBundleFixtureReader`; CSV/commandlet, not AS matrices |
| `AngelscriptEditor/Tests/` | Watcher, ClassReloadHelper, BlueprintImpact, SourceNavigation — C++/Editor. Pipeline change, not Fixtures |
| `GC/` `Memory/` `Performance/` `Networking/` `UHTTool/` | Small or C++-owned |
| `Core/` `FileSystem/` `Validation/` | Mostly engine/path contracts; FileSystem virtual-path tests stay with `as-virtual-script-paths` |

## Suggested next OpenSpec names (not created in this scan)

- `test-as-syntax-fixture-corpus` — Syntax `TEXT(R"(` → Fixtures + optional DataDriven compile/execute. After harness Wave A.
- `test-as-debugger-script-corpus` — Debugger MARK fixtures. After corpus API. Keep DAP CQTest.
- Functional World authored fixtures can start **without** a new COMPLEX: CQTest calls `TryGetByVirtualPath` once the API exists.

Do not start Syntax/Debugger extraction before `FAngelscriptTestScriptCorpus` is green.
