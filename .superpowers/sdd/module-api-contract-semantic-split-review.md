# Module API Contract Semantic-Owner Split — Independent Review

Date: 2026-07-27

Reviewer: independent SDD review agent

Verdict: **FAIL**

Findings: **2**

## Executive conclusion

The eight physical CQTest owners are an exact semantic-preserving replacement
for the retired Module API Contract aggregate. Every frozen file hash, method
hash, method byte length, method range, product marker, case identifier,
assertion identity, generated-source count, lifecycle count, Automation
prefix, and whole-tree inventory value recomputed from current source matches
the binding brief. The source layout also satisfies the required
UnitTest/CQTest, visibility, lifecycle, unity/ODR, formatting, and raw-SDK
boundaries.

The review nevertheless fails because both mandatory assertion-depth living
records are incomplete:

1. all eight Module API rows in
   `handoffs/assertion-depth-runtime-module-review.csv` retain line ranges from
   the retired 1,461-line aggregate; and
2. all seven matching rows in
   `handoffs/assertion-depth-module-repair-review.csv` retain a different set
   of ranges from that same retired aggregate.

The binding brief requires those fifteen evidence locations to cover the
complete helper/method closure in each new owner. The implementation report
claims that exact migration was completed, but the checked-in CSV values do
not support the claim. Several recorded ranges exceed the total line count of
their named file, so they cannot be used to navigate or reproduce the
assertion-depth review.

No source-code, build, runtime, API, inventory, quality, task, issue, or
generated-audit defect was found.

## Findings

### Finding 1 — High: runtime/module assertion-depth evidence retains all eight retired aggregate ranges

Artifact:

`openspec/changes/test-as-native-sdk-comprehensive-coverage/handoffs/assertion-depth-runtime-module-review.csv`

Affected rows are lines 12-19 of the CSV. Their `Owner` values correctly name
the new file/class/method, but their `ExactSourceEvidence` values still carry
the old aggregate ranges:

| Product | Required complete owner/helper range | Recorded range | Result |
| --- | ---: | ---: | --- |
| `MOD-API-RENAME-REINDEX` | `10-197` | `96-177` | stale |
| `MOD-API-COMPILE-FUNCTION` | `10-290` | `178-342` | stale and exceeds the 292-line file |
| `MOD-API-REMOVE-FUNCTION` | `10-209` | `343-460` | stale and wholly outside the 211-line file |
| `MOD-TYPEDEF-INVENTORY-BOUNDS` | `10-147` | `461-546` | stale and wholly outside the 149-line file |
| `MOD-USERDATA-LIFECYCLE` | `10-191` | `547-672` | stale and wholly outside the 193-line file |
| `MOD-IMPORT-UNBIND-ALL` | `10-366` | `673-825` | stale and wholly outside the 368-line file |
| `MOD-PRECLASS-METADATA-APPLICATION` | `10-251` | `826-995` | stale and wholly outside the 253-line file |
| `MOD-NESTED-IMPORT-VISIBILITY` | `10-222` | `996-1096` | stale and wholly outside the 224-line file |

This directly violates the binding brief's “Current handoffs and predecessor
mapping” requirement and its current-record guard. It also contradicts the
implementation report's statement that all eight rows were updated and that
the ranges are `10-197`, `10-290`, `10-209`, `10-147`, `10-191`, `10-366`,
`10-251`, and `10-222`.

Required correction: replace the evidence location in each of the eight rows
with its required new file range while retaining the migrated owner,
disposition, evidence layers, oracle text, and review conclusion.

### Finding 2 — High: Module repair review retains all seven retired aggregate ranges

Artifact:

`openspec/changes/test-as-native-sdk-comprehensive-coverage/handoffs/assertion-depth-module-repair-review.csv`

Affected rows are lines 3-9 of the CSV. UserDataLifecycle correctly has no row
in this artifact, but every one of the seven required rows retains an aggregate
range:

| Product | Required complete owner/helper range | Recorded range | Result |
| --- | ---: | ---: | --- |
| `MOD-API-RENAME-REINDEX` | `10-197` | `164-287` | stale and exceeds the 199-line file |
| `MOD-API-COMPILE-FUNCTION` | `10-290` | `288-504` | stale and extends past the 292-line file |
| `MOD-API-REMOVE-FUNCTION` | `10-209` | `505-640` | stale and wholly outside the 211-line file |
| `MOD-TYPEDEF-INVENTORY-BOUNDS` | `10-147` | `641-748` | stale and wholly outside the 149-line file |
| `MOD-IMPORT-UNBIND-ALL` | `10-366` | `875-1103` | stale and wholly outside the 368-line file |
| `MOD-PRECLASS-METADATA-APPLICATION` | `10-251` | `1104-1310` | stale and wholly outside the 253-line file |
| `MOD-NESTED-IMPORT-VISIBILITY` | `10-222` | `1311-1458` | stale and wholly outside the 224-line file |

This is a distinct required living handoff from Finding 1. It likewise
violates the binding brief and contradicts the implementation report's claim
that all seven matching rows were updated.

Required correction: replace the seven `ExactSourceEvidence` ranges with the
required complete new owner/helper closures. Do not add a UserDataLifecycle
row.

## Stage 1 — exact semantic recomputation

### Retired aggregate and exact owner set

The retired source is absent:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Module/AngelscriptNativeModuleApiContractTests.cpp`

All eight required replacement files exist. No additional owner was accepted
as part of the split.

### File and method fingerprints

Hashes were recomputed from the current filesystem. Method hashes cover the
inclusive opening-to-closing brace range of the sole `TEST_METHOD`.

| Owner file | Lines | File SHA-256 | Method | Range | Bytes | Method SHA-256 |
| --- | ---: | --- | --- | ---: | ---: | --- |
| `AngelscriptNativeModuleRenameReindexTests.cpp` | 199 | `8297BE81F053F43122B7FCA78C54FA8B3F7A801F832198201A768F5382D3DF98` | `RenameReindexesEngineLookup` | `74-196` | 3,619 | `4D1964C802BCD9662502E6EF9E1A9433DCD1797EA421270F17A4485ADB8CD328` |
| `AngelscriptNativeModuleCompileFunctionTests.cpp` | 292 | `19B01B37A2A2C32B45CDD9F93A45E323D8177F2072880B287F6A5C62331CC3D3` | `CompileFunctionDetachedAttachedAndInvalid` | `74-289` | 7,011 | `68EAD2785A973E63213E06091A476689D83EF959A2FD7F98AA16A5786F294F72` |
| `AngelscriptNativeModuleRemoveFunctionTests.cpp` | 211 | `41F442FC29B2B1F9F54FEA9F445F833DCF1B73991B216892E3644E88D2BF25E4` | `RemoveFunctionPreservesExternalOwnership` | `74-208` | 4,040 | `02F0DD489E56E5DD2A682848EDDB02F89EA7AF86B8826C8AABC04333DA28AFEF` |
| `AngelscriptNativeModuleTypedefInventoryTests.cpp` | 149 | `BFC962B0C560AA456E8DA6CE23C82DD6EDD1E2B9009E087B9FA65B5FD152F6C7` | `TypedefInventoryUsesForkEmptyBoundary` | `40-146` | 3,673 | `F8CAFDF168D72819482E0C5B3E182344CF7C1FAA44D9A644DA1822F148CF03F4` |
| `AngelscriptNativeModuleUserDataLifecycleTests.cpp` | 193 | `42E237E25E47829A54C4A09AA1E91EFA116DE91ACF1B70E6ED931801A25925EC` | `UserDataTransitionsAndCleanup` | `66-190` | 3,886 | `C1811DC20493B890668F7021A2A27B4A7F0E5CEF9D08BD108A20A4BA204EE974` |
| `AngelscriptNativeModuleImportUnbindAllTests.cpp` | 368 | `B88B7640F745A71E18E61964FB840D6DF08CF7F7F837250DF5A314EA997EEACF` | `UnbindAllImportsThenRebinds` | `138-365` | 6,349 | `1AAC035A93A08FF7F77093E237BCA01889C474FA6A92C9371C9DD8DE1024C924` |
| `AngelscriptNativeModulePreClassMetadataTests.cpp` | 253 | `E87022980DA34A361F9BC32D2F67138D570A862BD379D4226335BF0753D5224D` | `PreClassMetadataAppliesOnlyToExactDeclaration` | `45-250` | 6,849 | `E4BF281855BC4FC1DC2BA7A508CB8DFFBF6D489D9B22FD2FEDE2613C2E4B6647` |
| `AngelscriptNativeModuleNestedImportVisibilityTests.cpp` | 224 | `48E1A8CED74F4B589D2B44537F53A03345CED83360B4514339EE1BFE5BD23ECF` | `NestedImportModuleVisibilityAndDeduplication` | `74-221` | 4,390 | `DBAC69685667D997CD23BB1EE3216E9C227530FCB2053ACFE622C407BBB38A6D` |

Every value matches the binding brief and implementation report. Every file
uses LF only, ends in LF, contains no NUL, contains no trailing whitespace,
and is below 1,000 lines.

### Owner cardinality and Automation identity

Each file has exactly:

- one `TEST_CLASS_WITH_FLAGS`;
- one `TEST_METHOD`;
- one `AS_NATIVE_PRODUCT`;
- one direct `PrintGeneratedAsSource` site; and
- one balanced `#if WITH_ANGELSCRIPT_UNITTESTS` body gate.

All eight retain exactly:

`Angelscript.TestModule.AngelScriptSDK.Module.ApiContracts`

Each class name occurs in exactly one SDK source file. The aggregate class and
file are absent from the physical source tree.

### Exact 31 case identifiers

The expanded expected-coverage rows have 31 rows, 31 unique IDs, and the
following exact product cardinalities:

- `MOD-API-RENAME-REINDEX` — 1:
  `MOD-API-RENAME-REINDEX-OLD-TO-NEW`.
- `MOD-API-COMPILE-FUNCTION` — 4:
  `...-DETACHED`, `...-ATTACHED`, `...-INVALID-FLAGS`,
  `...-NULL-SOURCE`.
- `MOD-API-REMOVE-FUNCTION` — 4:
  `...-FOREIGN-REJECTED`, `...-OWNED-REMOVED`,
  `...-EXTERNAL-REFERENCE-EXECUTES`, `...-REPEAT-REJECTED`.
- `MOD-TYPEDEF-INVENTORY-BOUNDS` — 2:
  `...-SCRIPT-TYPEDEF-REJECTED`, `...-EMPTY-INDEX-ZERO`.
- `MOD-USERDATA-LIFECYCLE` — 6:
  `...-UNSET`, `...-INSTALLED`, `...-REPLACED`, `...-CLEARED`,
  `...-DISCARD-DEFERRED`, `...-ENGINE-SHUTDOWN-CLEANUP-MISSING`.
- `MOD-IMPORT-UNBIND-ALL` — 4:
  `...-BOUND`, `...-UNBOUND-EXCEPTION`, `...-REBOUND`,
  `...-ZERO-IMPORT`.
- `MOD-PRECLASS-METADATA-APPLICATION` — 6:
  `...-INITIAL-USER-DATA-EXACT`,
  `...-INITIAL-USER-DATA-UNMATCHED-CONTROL`,
  `...-PROPERTY-OFFSET-EXACT`,
  `...-PROPERTY-OFFSET-UNMATCHED-CONTROL`,
  `...-TYPE-SIZE-EXACT`, `...-TYPE-SIZE-UNMATCHED-CONTROL`.
- `MOD-NESTED-IMPORT-VISIBILITY` — 4:
  `...-DIRECT-PROVIDER`, `...-FLATTENED-BASE`,
  `...-REPEAT-PROVIDER`, `...-REPEAT-BASE`.

The independently sorted 31-ID fingerprint is:

`7bd92537965bfad1b0aa18e0fc7508162efa0518c38b3b76bacf39d5dafd74dc`

The complete catalog remains 317 products and 46,140 unique expanded IDs.

### Assertion identity

Assertion bodies were extracted with the current inventory exporter's
multiline `ASSERT_THAT` semantics and normalized before hashing.

| Owner | Physical | Unique |
| --- | ---: | ---: |
| Rename/Reindex | 14 | 14 |
| CompileFunction | 28 | 28 |
| RemoveFunction | 15 | 15 |
| TypedefInventory | 14 | 14 |
| UserDataLifecycle | 16 | 16 |
| ImportUnbindAll | 26 | 24 |
| PreClassMetadata | 27 | 27 |
| NestedImportVisibility | 15 | 15 |
| **Total** | **155** | **153** |

Only two hashes have multiplicity two; both duplicates remain inside
ImportUnbindAll:

- `53d49519f57011b4f8ec84ce8b06a53b82d569582b1bfdab1a24c899a2ef2529`
  — `IsTrue(ExecuteFunction(*TestRunner,*ScriptEngine,*LocalOnly,97))`;
- `e34af2bb6941a6736f81d6a59e0af45e3c669a9b1f7f97ac0d9d7026c1aec2d1`
  — `IsTrue(ExecuteFunction(*TestRunner,*ScriptEngine,*Entry,172))`.

Every other assertion hash has multiplicity one. This matches the frozen
aggregate exactly.

### Generated source and lifecycle protocol

Counts were recomputed from the actual method/helper call graph. Definitions
were excluded from call counts. Wrapper `.Discard()` calls and direct
`DiscardModule()` calls were both included. ImportUnbindAll's direct reusable
context was added to its helper-created contexts.

| Owner | Reports | Raw / ANSI | Engine create / destroy | Context create / release | Discards | Explicit external function releases |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Rename/Reindex | 2 | 1 / 1 | 1 / 1 | 2 / 2 | 2 | 0 |
| CompileFunction | 4 | 2 / 2 | 1 / 1 | 2 / 2 | 2 | 2 |
| RemoveFunction | 2 | 2 / 2 | 1 / 1 | 1 / 1 | 2 | 1 |
| TypedefInventory | 2 | 2 / 2 | 1 / 1 | 0 / 0 | 2 | 0 |
| UserDataLifecycle | 2 | 2 / 2 | 2 / 2 | 0 / 0 | 1 | 0 |
| ImportUnbindAll | 3 | 3 / 3 | 1 / 1 | 7 / 7 | 3 | 0 |
| PreClassMetadata | 2 | 1 / 1 | 1 / 1 | 0 / 0 | 2 | 0 |
| NestedImportVisibility | 3 | 3 / 3 | 1 / 1 | 2 / 2 | 3 | 0 |
| **Total** | **20** | **16 / 16** | **9 / 9** | **14 / 14** | **17** | **3** |

`ExecuteFunction` remains only in Rename, CompileFunction, RemoveFunction,
ImportUnbindAll, and NestedImportVisibility.
`ExpectUnboundFunctionException` remains only in ImportUnbindAll.
CompileFunction retains releases for its detached and attached external
functions; RemoveFunction retains the final release of the externally held
removed function.

User-data callback slots/state and the explicit destroy/recreate observation
remain local to UserDataLifecycle. PreClassMetadata retains only the token type
and method-local token needed by that product; it has no static callback state.

### Whole-tree current inventory

The official exporter was rerun against current source into a temporary output
directory:

| Metric | Recomputed |
| --- | ---: |
| SDK `.cpp` files | 271 |
| CQTest methods | 688 |
| assertions | 8,154 |
| lines | 162,642 |
| raw blocks | 301 |
| ANSI wrappers | 294 |
| active methods | 674 |
| Disabled methods | 14 |

All values match the required post-split inventory and the checked-in
`current-summary.json`.

## Stage 2 — engineering quality and record review

### UnitTest/CQTest layout

`Documents/UnitTest/UnitTest.md` was read in full before the engineering
review. The eight owners satisfy the applicable structure:

- all includes are outside the single unit-test body gate;
- each file has one scenario-specific CQTest method;
- narrow source/execute/exception/callback helpers are class-private;
- `public:` precedes the test method;
- class and method terminators are file-scope aligned;
- every ordinary engine creation is immediately followed by an
  `ON_SCOPE_EXIT` destroy guard;
- UserDataLifecycle's deliberate early `Destroy()` is balanced by the
  same-case recreate required by its scope guard;
- every context path releases its context, including ImportUnbindAll's direct
  reusable context;
- there is no anonymous namespace, file-level assertion alias, top-level
  forwarding wrapper, class-owned engine, or CQTest lifecycle hook;
- there is no SDK add-on, `FAngelscriptEngine`, UObject/world fixture, UE
  debugger integration, or compiled-out owner;
- all generated AngelScript remains complete, visible, and Allman-formatted.

### Visibility, unity, and ODR

All eight `FModule...Tests` class names are globally unique across the SDK
source tree. Helpers are class members, not file-scope symbols. The only
class-owned mutable callback state is the required UserDataLifecycle state,
and it is declared `inline static`, avoiding cross-TU storage definitions.
No new support header or non-inline header definition was introduced. No
unity/ODR collision or accidental shared helper surface was found.

### Catalog and generated-source registry

The eight `coverage-products.psd1` owners match the exact new
file/class/method triples. The generated-source registry has exactly eight
matching rows, each with the correct product, generator chain
`PrintSource; PrintGeneratedAsSource`, and `PrintSites` equal to one.

No retired aggregate owner appears in the current catalog, current registry,
official current inventory, official current implementation/method
reconciliation, API-use output, current predecessor records, current internal
records, quality records, or tasks.

The historical `SDK-DEPTH-165` row in `issues.md`, old stage snapshots,
implementation-ledger history, and lifecycle-repair handoffs continue to name
the aggregate as historical evidence. Those occurrences are within the
brief's explicit preserve-history boundary and were not treated as stale
current ownership.

### Current handoff and predecessor records

| Artifact | Review |
| --- | --- |
| `assertion-depth-runtime-module-review.csv` | **FAIL**: all 8 owners migrated, all 8 ranges stale; Finding 1 |
| `assertion-depth-module-repair-review.csv` | **FAIL**: all 7 owners migrated, all 7 ranges stale; Finding 2 |
| `audits/predecessor-dispositions.csv` | PASS: UserData maps to the new lifecycle owner |
| `handoffs/predecessor-terminal-disposition-review.csv` | PASS: identical UserData terminal mapping to the new owner |

### Living quality, tasks, and issue

The quality CSV and Markdown agree with each other and with physical source:

- 271 rows, 271 unique file keys;
- 231 `CompliantCaseOwned`;
- 228 `NotLarge`;
- 43 `RetainCohesiveGeneratorOrOwner`;
- zero `SplitRequiredMixedResponsibilities`;
- all eight new Module owners are
  `CompliantCaseOwned` / `NotLarge` / `None.`;
- the retired aggregate has no current quality row.

The quality Markdown's top counts, current owner lists, Module list, large-file
summary, and bottom living-record summary agree with those values.

Task review:

- 4.7 is complete and states all fourteen original mixed-responsibility
  owners are closed, including the eight one-product Module owners;
- 5.5 remains open only for linked restore-runtime reconciliation and final
  gates;
- 5.8 contains no stale physical-split requirement;
- 5.10 remains unchanged as required.

`SDK-QUALITY-206` is resolved with all fourteen splits complete, 43 cohesive
large owners retained, and zero split-required owners.

## Authoritative static gate reruns

To preserve the user's read-only constraint, scripts that normally overwrite
living audit files were run with explicit output paths beneath:

`C:\Users\scottmei\AppData\Local\Temp\codex-module-api-split-review-cc27de86659f4f878e94c2ce9d031d48`

Catalog expansion/validation was run against a temporary copy of the change
record with a junction to the real plugin source. No gate wrote into the
repository.

| Gate | Result |
| --- | --- |
| `ExpandCoverageProducts.ps1` | PASS: 317 products, 46,140 expected cases, 45,994 CurrentFork, 65 FutureDisabled |
| `ValidateCoverageCatalogs.ps1` | PASS: 317 products, 46,140 cases, 14 Language themes, 46,140 unique IDs |
| `ExportCurrentNativeSdkInventory.ps1` | PASS: exact 271 / 688 / 8,154 / 162,642 / 301 / 294 / 674 / 14 |
| `ReconcileNativeSdkSource.ps1 -RequireComplete` | PASS: 316 Implemented + 1 DisabledImplemented, 0 incomplete; 688 methods, 0 unresolved |
| `AuditNativeSdkApiUse.ps1 -RequireComplete` | PASS: 365 rows, 357 Observed, 1 ContractCovered, 7 Deferred, 0 missing/incomplete |
| `ReconcilePredecessorScenarios.ps1 -RequireFinalDisposition` | PASS: 222 required, 24 scanner-present, 198 scanner-missing with terminal dispositions checked |
| `FinalizeInternalMethodDispositions.ps1` | PASS: 1,002 rows = 171 DirectCovered + 803 PublicContractCovered + 28 ApiDeferred |
| `ReconcileInternalMethods.ps1 -RequireComplete` | PASS: 1,002 Final, 0 Pending |
| `AuditNativeSdkBoundaries.ps1 -RequireClean` | PASS: 0 violations |
| `AuditInlineAsFormatting.ps1 -RequireClean` | PASS: 301 Conforming + 2 RegisteredExactInput, 0 violations |
| `ValidatePlanningRecords.ps1 -RequireClean` | PASS: 0 violations |
| `openspec validate test-as-native-sdk-comprehensive-coverage --strict --json` | PASS: 1 item passed, 0 failed, no issues |

Fifteen rerun artifacts matched their checked-in official current counterpart
byte-for-byte:

- `expected-coverage.csv`;
- `product-cardinalities.csv`;
- `current-files.csv`;
- `current-methods.csv`;
- `current-assertions.csv`;
- `current-summary.json`;
- `implementation-reconciliation.csv`;
- `method-product-reconciliation.csv`;
- `api-use.csv`;
- `predecessor-baseline.csv`;
- `internal-method-dispositions.csv`;
- `internal-method-reconciliation.csv`;
- `boundary-violations.csv`;
- `inline-source-baseline.csv`;
- `planning-record-violations.csv`.

This proves the official generated current artifacts are reproducible at the
reviewed source state. The passing generic gates do not inspect the two stale
handoff range fields and therefore do not supersede Findings 1 and 2.

## Rejected, failed, or partial commands and corrections

No rejected or partial output was accepted as evidence.

1. An initial Stage 1 inventory loop was piped directly from a PowerShell
   `foreach` block and failed with `An empty pipe element is not allowed`.
   The result was discarded; the loop was assigned to an array and rerun.
2. An initial helper search used a Windows wildcard path directly with `rg`.
   `rg` rejected that path. The successful first half of the compound command
   was retained only for helper-definition location; the wildcard portion was
   discarded and rerun with explicit owner paths.
3. The first Stage 2 source-shape loop repeated the invalid direct
   `foreach ... | Format-Table` form and failed with the same parser error.
   It was discarded and rerun through an output array.
4. The first corrected source-shape file list used four shortened guessed
   names (`TypedefTests`, `UserDataTests`, `PreClassRegistrationTests`, and
   `NestedEnumTests`) and therefore returned only four owners. That partial
   result was not accepted. `rg --files` established the exact filenames and
   the check was rerun across all eight.
5. The first script-header inventory looked for
   `scripts/ExportCurrentNativeSdkInventory.ps1`; that path does not exist.
   The error was recorded. `rg --files` found the authoritative exporter at
   `audits/tools/ExportCurrentNativeSdkInventory.ps1`, whose parameter
   contract was then inspected and used.
6. The first temporary-copy command used `Copy-Item -LiteralPath` with a
   wildcard. Literal paths do not expand wildcards, so it copied zero files.
   The partial mirror was rejected and the copy was rerun with `-Path`; 187
   files / 43,118,168 bytes were confirmed before running catalog gates.
7. The first post-gate CSV summary loop piped directly from `foreach` and
   failed with the PowerShell empty-pipe parser error. It was discarded and
   rerun via an array, confirming 301 conforming and two registered exact
   inputs.
8. The first programmatic handoff-range comparison repeated the same invalid
   direct-pipe form. It was discarded and rerun through an array, producing
   the exact fifteen-row mismatch tables reported in Findings 1 and 2.

## Execution and mutation boundary

- No build was run.
- No Unreal Automation or other runtime test was run.
- No commit, branch, worktree, push, or external mutation was performed.
- No plugin source, catalog, audit, handoff, task, issue, history, or unrelated
  file was edited.
- The only repository write made by this review is this review artifact.
- Temporary gate outputs were written outside the repository solely to keep
  the review read-only.

## Acceptance decision

**FAIL with 2 findings.**

The physical semantic-owner split itself is exact and all generic static gates
pass. Acceptance requires correcting the eight stale ranges in
`assertion-depth-runtime-module-review.csv` and the seven stale ranges in
`assertion-depth-module-repair-review.csv`, then rerunning the focused
current-record guard and independent review.

## Focused re-review

Date: 2026-07-27

Scope: the two findings above after the implementation report's appended
`## Review finding fixes`.

Final verdicts:

- **Spec compliance: PASS**
- **Code quality: PASS**
- **Prior findings resolved: 2/2**
- **New findings: 0**

This focused result supersedes the original acceptance decision for the two
living-record findings. The original review remains above as the audit trail
of what was found before the correction.

### Independent 15-row verification

Both CSV files were parsed independently with PowerShell `Import-Csv`; no
text-only search was accepted as the row oracle. The required product mapping
was reconstructed from the binding brief and joined to each physical source
file.

`handoffs/assertion-depth-runtime-module-review.csv` contains exactly the
required eight rows:

| Product | Exact owner | Range | Physical bound |
| --- | --- | ---: | --- |
| `MOD-API-RENAME-REINDEX` | `Module/AngelscriptNativeModuleRenameReindexTests.cpp\|FModuleRenameReindexTests\|RenameReindexesEngineLookup` | `10-197` | closing `};` at 197, EOF 199 |
| `MOD-API-COMPILE-FUNCTION` | `Module/AngelscriptNativeModuleCompileFunctionTests.cpp\|FModuleCompileFunctionTests\|CompileFunctionDetachedAttachedAndInvalid` | `10-290` | closing `};` at 290, EOF 292 |
| `MOD-API-REMOVE-FUNCTION` | `Module/AngelscriptNativeModuleRemoveFunctionTests.cpp\|FModuleRemoveFunctionTests\|RemoveFunctionPreservesExternalOwnership` | `10-209` | closing `};` at 209, EOF 211 |
| `MOD-TYPEDEF-INVENTORY-BOUNDS` | `Module/AngelscriptNativeModuleTypedefInventoryTests.cpp\|FModuleTypedefInventoryTests\|TypedefInventoryUsesForkEmptyBoundary` | `10-147` | closing `};` at 147, EOF 149 |
| `MOD-USERDATA-LIFECYCLE` | `Module/AngelscriptNativeModuleUserDataLifecycleTests.cpp\|FModuleUserDataLifecycleTests\|UserDataTransitionsAndCleanup` | `10-191` | closing `};` at 191, EOF 193 |
| `MOD-IMPORT-UNBIND-ALL` | `Module/AngelscriptNativeModuleImportUnbindAllTests.cpp\|FModuleImportUnbindAllTests\|UnbindAllImportsThenRebinds` | `10-366` | closing `};` at 366, EOF 368 |
| `MOD-PRECLASS-METADATA-APPLICATION` | `Module/AngelscriptNativeModulePreClassMetadataTests.cpp\|FModulePreClassMetadataTests\|PreClassMetadataAppliesOnlyToExactDeclaration` | `10-251` | closing `};` at 251, EOF 253 |
| `MOD-NESTED-IMPORT-VISIBILITY` | `Module/AngelscriptNativeModuleNestedImportVisibilityTests.cpp\|FModuleNestedImportVisibilityTests\|NestedImportModuleVisibilityAndDeduplication` | `10-222` | closing `};` at 222, EOF 224 |

`handoffs/assertion-depth-module-repair-review.csv` contains exactly the seven
required file/range pairs:

| Product | Exact source file | Range | Physical bound |
| --- | --- | ---: | --- |
| `MOD-API-RENAME-REINDEX` | `Module/AngelscriptNativeModuleRenameReindexTests.cpp` | `10-197` | closing `};` at 197, EOF 199 |
| `MOD-API-COMPILE-FUNCTION` | `Module/AngelscriptNativeModuleCompileFunctionTests.cpp` | `10-290` | closing `};` at 290, EOF 292 |
| `MOD-API-REMOVE-FUNCTION` | `Module/AngelscriptNativeModuleRemoveFunctionTests.cpp` | `10-209` | closing `};` at 209, EOF 211 |
| `MOD-TYPEDEF-INVENTORY-BOUNDS` | `Module/AngelscriptNativeModuleTypedefInventoryTests.cpp` | `10-147` | closing `};` at 147, EOF 149 |
| `MOD-IMPORT-UNBIND-ALL` | `Module/AngelscriptNativeModuleImportUnbindAllTests.cpp` | `10-366` | closing `};` at 366, EOF 368 |
| `MOD-PRECLASS-METADATA-APPLICATION` | `Module/AngelscriptNativeModulePreClassMetadataTests.cpp` | `10-251` | closing `};` at 251, EOF 253 |
| `MOD-NESTED-IMPORT-VISIBILITY` | `Module/AngelscriptNativeModuleNestedImportVisibilityTests.cpp` | `10-222` | closing `};` at 222, EOF 224 |

For every one of the fifteen rows:

- the product appears exactly once in its required CSV;
- the evidence file and range exactly match the brief;
- source line 10 is the expected `TEST_CLASS_WITH_FLAGS` for that product;
- the expected `TEST_METHOD` occurs exactly once in that file;
- the expected `AS_NATIVE_PRODUCT` marker occurs exactly once;
- the range end is the class-closing `};`;
- the range end is exactly EOF minus two, leaving only the blank line and
  body-gate `#endif`; and
- the range is therefore valid and covers the complete class-private
  helper/method closure.

The repair CSV has no `MOD-USERDATA-LIFECYCLE` row, as required.

### Collateral-change guard

The preserved pre-fix temporary mirror from the original review was used as a
row/field baseline. The comparison checked header sequence, row count, row-key
sequence, and every field of every row:

- runtime/module review: 53 data rows, identical header and row-key order;
- Module repair review: 16 data rows, identical header and row-key order;
- changed fields: exactly 15;
- all 15 changes are the `ExactSourceEvidence` field on the intended eight
  plus seven products;
- each new value equals the old value with only its `file:range` line range
  replaced by the brief-required range;
- unexpected changed fields: zero;
- changed non-target rows: zero.

This independently confirms the implementation report's claim that no other
CSV row or field was changed.

### Focused whitespace and strict validation

Focused file checks:

| File | Data rows | Ends in LF | Trailing-whitespace lines | Extra blank EOF lines | NUL bytes | SHA-256 |
| --- | ---: | --- | ---: | ---: | ---: | --- |
| `assertion-depth-runtime-module-review.csv` | 53 | yes | 0 | 0 | 0 | `B1CBC9B482092F12CF53B996DE269138ED60AB7E621AAB82CDEC53E51B84C8EE` |
| `assertion-depth-module-repair-review.csv` | 16 | yes | 0 | 0 | 0 | `094D4FB318053377125BAD9EA8A7155E81367DECA686062DCD364F6D91A8883E` |

Strict OpenSpec validation was rerun:

```text
openspec validate test-as-native-sdk-comprehensive-coverage --strict --json
```

Result: **PASS**, one change item valid, zero failed items, and no issues.

### Re-review command correction

The first collateral-comparison script correctly reported zero unexpected
field changes but also tried to read an `Owner` column from the Module repair
CSV. That CSV intentionally has no `Owner` column, so the resulting seven
owner-subcheck failures were invalid and were not accepted as evidence.

The corrected parser derived the repair owner from
`ExactSourceEvidence`, joined it to the brief's file/class/method mapping, and
verified the class, method, product marker, range, closing class line, and EOF
directly in source. The corrected run completed 76/76 checks with zero
failures, exactly 15 intended changed fields, and zero unexpected field
changes.

### Focused execution boundary

- No build was run.
- No Unreal Automation or other runtime test was run.
- No commit, branch, worktree, push, source edit, CSV edit, or unrelated edit
  was performed.
- The only repository write made during this focused re-review is this
  append-only review section.

### Final focused acceptance

**Spec compliance: PASS.**

**Code quality: PASS.**

Both prior findings are resolved. No new finding remains in the focused
re-review scope.
