# Source and decision provenance

## Capture boundary

Captured during the 2026-09-05 planning conversation in the primary selected
workspace. Exploration inspected the historical workspace read-only; it did not
switch workspaces, integrate branches or run its old UE wrappers. Present
delivery edits only the new Change directory. Source counts below are inventory,
not test or coverage counts, and may change during concurrent reconstruction.

## Historical script-corpus work

Workspace: `D:/Workspace/AngelscriptProject.worktree/script-corpus`.
Parent branch `test-as-script-corpus-and-functional-coverage`, observed HEAD
`a81f8e497f1aba7352d753de07c58e97b1b91a03`. Plugin branch
`test-as-script-corpus-and-functional-coverage-plugin`, observed HEAD
`35d2396298df67172f3c18eb20503cfacc869d5b`.

The `test-as-data-driven-engine-harness` and
`test-as-script-corpus-and-functional-coverage` historical Changes were inspected
starting with tasks. Neither had an attachments/INDEX at the inspected location.

| Evidence | Observed capability | Disposition |
|---|---|---|
| Plugin `Shared/AngelscriptTestScriptCorpus.h` | Source lookup, enumeration, generated-source registration, in-memory compilation | Source-only parts inform TestCode; old engine coupling is not adopted |
| Plugin `DataDriven/AngelscriptDataDrivenAutomation.*` | Snapshot enumeration and individual Automation leaf execution | Reuse the public bridge pattern, update identity/gates/results |
| Plugin `DataDriven/AngelscriptComplexSession.*` and Fixtures | Per-leaf resources, World/Blueprint helpers | Preserve ownership lesson; runtime-dependent execution remains deferred |
| HEAD DataDriven harness/profile implementation | VM and actual cache publish/restore, representative World/BP observations | Real historical work, not current reconstruction availability |
| Plugin `Shared/AngelscriptTestCode.*` and `TestCode/` | CaseKey source registration and wrappers from C++ inline source | Existing untracked prototype; retain public name and separate source from execution |
| Plugin `Shared/AngelscriptTestSnippet.*` | Tag/path query, deterministic sample, dump/preview | Existing untracked prototype; consolidate public source queries |

Git inspection found 18 tracked DataDriven, 3 tracked corpus and 12 tracked
Fixture files. TestCode/Snippet additions remained untracked; the TestCode tree
contained 379 files, including 189 C++ files and no AS files. Some tracked files
also contained later uncommitted edits, so the worktree is not equivalent to its
HEAD snapshot.

The following retained `Summary.json` files were read; these tests were **not
rerun** during this planning work:

| Historical report under workspace Saved/Tests | Reported total / passed / failed |
|---|---|
| `data-driven-all/20260819_170122_693_4a56075d` | 88 / 88 / 0 |
| `snippet-library-testcode/20260820_072855_013_5e6f2574` | 22 / 22 / 0 |
| `snippet-library-catalog/20260820_073038_022_9cf40e5b` | 12 / 12 / 0 |
| `snippet-library-products/20260820_073207_263_15976b66` | 10 / 10 / 0 |
| `snippet-library-bind/20260820_073354_287_5590432c` | 45 / 45 / 0 |

All listed summaries reported exit code zero. Some old backend profiles used
Info-skip that was counted as PASS. These results establish historical work,
not complete JIT execution coverage or compatibility with current UE 5.8.

## Exact external-AS-to-C++ design source

The historical Change's
`research/test-system-restructure-draft.md`, section 4.3 (around lines 238-328),
records `.as + inventory -> script exporter -> generated C++ -> runtime lookup`.
It explicitly distinguishes a source center from generation of new AS programs.
It recommends small packed descriptor shards instead of one static registrar
per case and per-consumer ForceLink calls.

The same draft's release section (around lines 580-605) describes parent-authored
source, plugin-owned generated release, content digests and regeneration compare.
`test-as-testcode-bindings2-entry/snippet-library.md` and `authoring-and-web.md`
record the earlier SnippetAuthoring/Generate-TestCode proposal.

The complete authoring-to-generated-C++ exporter was not found. Existing
`as.DumpTestSnippets` implements the opposite observation direction: registered
runtime source to an external snapshot. Do not claim it is the missing importer.

## Current main workspace

- `TestSource/README.md` explicitly says corpus presence is not compile/runtime
  verification. Its opening phase counts and old inventory links are stale.
- Static enumeration found 3,079 AS files. `Generation/Contracts` contained only
  index.json, whose source count was 3,041 and whose contract/reviewed counts were
  zero. No per-source V2 migration should be inferred from the schema's existence.
- `TestSource/Generation/README.md` describes the Python reference implementation
  and excludes portable C++/plugin release emission from that old wave.
- `Generation/python/angelscript_generation/authored.py` rejects old v1 records
  as current exports and requires reviewed, source-parity-clean V2. Its output is
  source/metadata/cells, not C++ translation units.
- V2 is AS-specific: AS paths, callable declarations and typed AS values are
  required. It cannot be the unchanged universal schema for AS-free C++ tests.
- `case_key.py` derives old CaseKeys from paths. New semantic identity must not
  silently retain that path-coupling under a different type name.
- At initial exploration, NewVersion had 20 C++ files with 141 CQTest methods
  plus 3 plain Automation declarations. These are static counts, not a fresh
  Automation enumeration or execution result.

The replacement NativeEngine foundation Change, archived as
`2026-09-05-refactor-native-engine-test-foundation`, establishes isolated CQTest,
the replacement gate and name composition. The concurrent
`angelscript/refactor-builder-engine-independent` Change remains separately owned.

## Existing SourceHistory implementation

The current `TestSource/ReloadHistory.md` and
`Generation/python/angelscript_generation/reload_history.py` retain root body plus
comment-contained child snapshots. The Python code generates/applies/reverses
diffs. Two actual history fixtures are AddModifyLookupFlow and
FailureKeepsOldCodeAndDiagnostics.

During exploration this focused command passed:

```powershell
python -B -m pytest TestSource/Generation/python/tests/test_reload_history.py -q -p no:cacheprovider
```

Observed result: **2 passed**. This proves those parser/diff examples only;
there was no compilation, class-identity or live last-good test.

Read-only probes and code inspection also showed:

| Documented shape | Actual limitation |
|---|---|
| @Tree and @depends | Rejected by the current closed marker sets |
| @path | A name is accepted/discarded; following steps are not implemented |
| NoChange | Identical snapshots fail in empty diff handling |
| Delete | Nonempty child snapshot is required; no module deletion state exists |
| Closed compile modes | Unknown values can be accepted |
| Root parent validation | Parsing clears the root parent before later validation |
| Failed-parent rules | @onto is recorded without live activation semantics |
| Public history auditing | audit_v2 excludes SourceHistory paths without calling tree validation |

These are bounded reasons for the new contracts. They do not authorize repairing
the existing parser during this planning delivery.

## CQTest and inline macro evidence

UE 5.8 `CQTest/Public/CQTest.h` has no built-in data-row method registration:
methods are `void (Derived::*)()`, and registration enumerates method names.
`ASSERT_THAT` expands through `this->Assert` and returns from the current method
on failure. `FNoDiscardAsserter` has a public Automation-test constructor and
typed bool-returning assertion methods. This supports the chosen member-Run
fixture contract without an engine fork or private CQTest macro dependency.

The local UE 5.8 `AutomationTest.h` signatures match the proposed adapter's
EAutomationTestFlags return, uint32 device count and const GetTests.
`AutomationTest.cpp` prepends the beautified family name to a relative row label,
so `Rows.<RowId>` yields the intended complete public path. Native frontend
snapshot/manager/identifier/diagnostics headers also support the proposed input
fixture and owned diagnostic-record copies. These are source checks, not a
compiled proof of the new declarations.

`FAutomationTestBase` has no ordinary per-item Skip return. Controller-side state
includes Skipped, but Harness `Private/AutomationReport.ps1:274-295` treats an
empty report as Incomplete while an all-skipped nonempty report can be
PassedWithWarnings. The design therefore excludes optional unavailable rows
before discovery and preserves their reasons separately. Required absence and
direct selection of an excluded item fail before fixture creation.

Current Harness `Private/Operations.ps1:586` and `Private/Suites.ps1:244` already
pass `-ReportExportPath`. The proposed writer can use this root without adding a
Harness injection protocol or guessing a managed RunId.

`Legacy/Shared/AngelscriptTestMacros.h` bundles source normalization with engine
pool/helper headers. ASTEST_AS returns FString; ASTEST_AS_ANSI converts to UTF-8
std::string. Normalization strips all outer blank lines, while the separate
PreserveLines helper has a narrower envelope rule and a newline-mode heuristic.
The old `PreserveLinesHelperKeepsBlankLinesAndNewlineMode` test is in
`Legacy/AngelScriptSDK/Support/AngelscriptNativeCaseSupportTests.cpp`.

A read-only clang preprocessing probe of a multiline raw-literal macro showed
__LINE__ at the closing delimiter rather than the AS first line. New logical AS
mapping therefore cannot pretend a single host line anchor has arbitrary body
precision. Current NewVersion tests already exercise invalid bytes/NUL and UTF-8
byte columns, which require the explicit byte input path.

## Skill consolidation sources

`Documents/UnitTest/UnitTest.md` supplies class-local helpers, no anonymous
namespace solely for one class, public hooks, visible test flow, meaningful
reload observations and checked helper results. Its old gate, shared engine,
prefix and Tools execution rules conflict with the current baseline.

Current Skill findings to address in future Tasks 1.1 and 7.1:

- SKILL.md starts with correct replacement guidance but contains a long legacy
  preferred skeleton later in the same default-read file.
- SKILL_ZH.md calls Documents/UnitTest/UnitTest.md the current authority.
- cqtest-guide_EN.md and cqtest-guide.md retain old Tools runner guidance.
- The isolation reference's active quarantine script path is stale. The script
  exists at `openspec/archive/changes/angelscript/2026-09-04-refactor-legacy-runtime-tests-quarantine/attachments/scripts/Test-LegacyTestQuarantine.ps1`.
- Many obsolete routes are backticked prose, not Markdown links; link resolution
  alone will not validate the guide's execution advice.

The Skill validator exists at
`C:/Users/scottmei/.codex/skills/.system/skill-creator/scripts/quick_validate.py`.
It is a future Skill-edit check; it was not needed to claim a Skill update in
this delivery because no Skill file was modified.
