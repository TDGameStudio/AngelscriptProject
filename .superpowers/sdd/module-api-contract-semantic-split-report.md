# Module API contract semantic-owner split report

Status: `DONE`

## Result

The eight-product Module API Contract aggregate was replaced by eight
one-product CQTest owners. Every registered method body, product/case ID,
generated source, diagnostic, public API oracle, lifecycle, cleanup, import
state, user-data callback, and recovery behavior remains byte-preserved.

Frozen aggregate:

- `Module/AngelscriptNativeModuleApiContractTests.cpp`;
- 1,461 lines / 44,530 bytes / LF;
- SHA-256
  `D6A60007951683E26078DB57F72A1A6C3E2354574D87299EC3526DDBBF1ED184`;
- 1 class / 8 methods / 8 products;
- 31 case IDs;
- 155 physical / 153 unique assertion hashes;
- 20 dynamic source reports;
- 16 raw sources / 16 ANSI wrappers;
- 9 engine Create/Destroy pairs;
- 14 context create/release lifecycles;
- 17 module discard operations.

The aggregate is absent after the split.

## Physical owners and hashes

| File | Class | Method | Product | Lines | SHA-256 |
| --- | --- | --- | --- | ---: | --- |
| `AngelscriptNativeModuleRenameReindexTests.cpp` | `FModuleRenameReindexTests` | `RenameReindexesEngineLookup` | `MOD-API-RENAME-REINDEX` | 199 | `8297BE81F053F43122B7FCA78C54FA8B3F7A801F832198201A768F5382D3DF98` |
| `AngelscriptNativeModuleCompileFunctionTests.cpp` | `FModuleCompileFunctionTests` | `CompileFunctionDetachedAttachedAndInvalid` | `MOD-API-COMPILE-FUNCTION` | 292 | `19B01B37A2A2C32B45CDD9F93A45E323D8177F2072880B287F6A5C62331CC3D3` |
| `AngelscriptNativeModuleRemoveFunctionTests.cpp` | `FModuleRemoveFunctionTests` | `RemoveFunctionPreservesExternalOwnership` | `MOD-API-REMOVE-FUNCTION` | 211 | `41F442FC29B2B1F9F54FEA9F445F833DCF1B73991B216892E3644E88D2BF25E4` |
| `AngelscriptNativeModuleTypedefInventoryTests.cpp` | `FModuleTypedefInventoryTests` | `TypedefInventoryUsesForkEmptyBoundary` | `MOD-TYPEDEF-INVENTORY-BOUNDS` | 149 | `BFC962B0C560AA456E8DA6CE23C82DD6EDD1E2B9009E087B9FA65B5FD152F6C7` |
| `AngelscriptNativeModuleUserDataLifecycleTests.cpp` | `FModuleUserDataLifecycleTests` | `UserDataTransitionsAndCleanup` | `MOD-USERDATA-LIFECYCLE` | 193 | `42E237E25E47829A54C4A09AA1E91EFA116DE91ACF1B70E6ED931801A25925EC` |
| `AngelscriptNativeModuleImportUnbindAllTests.cpp` | `FModuleImportUnbindAllTests` | `UnbindAllImportsThenRebinds` | `MOD-IMPORT-UNBIND-ALL` | 368 | `B88B7640F745A71E18E61964FB840D6DF08CF7F7F837250DF5A314EA997EEACF` |
| `AngelscriptNativeModulePreClassMetadataTests.cpp` | `FModulePreClassMetadataTests` | `PreClassMetadataAppliesOnlyToExactDeclaration` | `MOD-PRECLASS-METADATA-APPLICATION` | 253 | `E87022980DA34A361F9BC32D2F67138D570A862BD379D4226335BF0753D5224D` |
| `AngelscriptNativeModuleNestedImportVisibilityTests.cpp` | `FModuleNestedImportVisibilityTests` | `NestedImportModuleVisibilityAndDeduplication` | `MOD-NESTED-IMPORT-VISIBILITY` | 224 | `48E1A8CED74F4B589D2B44537F53A03345CED83360B4514339EE1BFE5BD23ECF` |

Every class retains:

`Angelscript.TestModule.AngelScriptSDK.Module.ApiContracts`

All files are below 1,000 lines and all file/class names are unique.

## Frozen method hashes

All eight inclusive-brace method hashes match:

- Rename:
  `4D1964C802BCD9662502E6EF9E1A9433DCD1797EA421270F17A4485ADB8CD328`;
- CompileFunction:
  `68EAD2785A973E63213E06091A476689D83EF959A2FD7F98AA16A5786F294F72`;
- RemoveFunction:
  `02F0DD489E56E5DD2A682848EDDB02F89EA7AF86B8826C8AABC04333DA28AFEF`;
- TypedefInventory:
  `F8CAFDF168D72819482E0C5B3E182344CF7C1FAA44D9A644DA1822F148CF03F4`;
- UserDataLifecycle:
  `C1811DC20493B890668F7021A2A27B4A7F0E5CEF9D08BD108A20A4BA204EE974`;
- ImportUnbindAll:
  `1AAC035A93A08FF7F77093E237BCA01889C474FA6A92C9371C9DD8DE1024C924`;
- PreClassMetadata:
  `E4BF281855BC4FC1DC2BA7A508CB8DFFBF6D489D9B22FD2FEDE2613C2E4B6647`;
- NestedImportVisibility:
  `DBAC69685667D997CD23BB1EE3216E9C227530FCB2053ACFE622C407BBB38A6D`.

The target method ranges are respectively:

`74-196`, `74-289`, `74-208`, `40-146`, `66-190`, `138-365`,
`45-250`, and `74-221`.

No brief-to-current-source mismatch was found.

## Ownership boundary

No support header or file-level helper API was added.

Both class-private `PrintSource` overloads remain in all eight owners, giving
each file one direct `PrintGeneratedAsSource` site. `ExecuteFunction` remains
only in Rename, CompileFunction, RemoveFunction, ImportUnbindAll, and
NestedImportVisibility. `ExpectUnboundFunctionException` remains only in
ImportUnbindAll. User-data state/callbacks remain only in UserDataLifecycle,
and the metadata token type remains only where required.

There is no anonymous namespace, file-level assertion alias, forwarding test
wrapper, class-owned engine, CQTest lifecycle hook, add-on, UE fixture, or
debugger integration.

## Exact behavior totals

Case cardinalities remain:

`1, 4, 4, 2, 6, 4, 6, 4` = 31/31 unique IDs.

Assertion distribution remains:

`14, 28, 15, 14, 16, 26, 27, 15` = 155 physical / 153 unique.

Only these hashes have multiplicity 2:

- `e34af2bb6941a6736f81d6a59e0af45e3c669a9b1f7f97ac0d9d7026c1aec2d1`;
- `53d49519f57011b4f8ec84ce8b06a53b82d569582b1bfdab1a24c899a2ef2529`.

Every other assertion hash has multiplicity 1.

Dynamic source reports remain:

`2, 4, 2, 2, 2, 3, 2, 3` = 20.

Raw/ANSI source distribution remains:

`1, 2, 2, 2, 2, 3, 1, 3` = 16/16.

Engine Create/Destroy distribution remains:

`1, 1, 1, 1, 2, 1, 1, 1` = 9/9.

Context lifecycle distribution remains:

`2, 2, 1, 0, 0, 7, 0, 2` = 14/14.

Module discard distribution remains:

`2, 2, 2, 2, 1, 3, 2, 3` = 17.

CompileFunction and RemoveFunction retain explicit external function release
ownership. UserDataLifecycle retains its explicit destroy/recreate protocol.

## Current record migrations

Updated:

- all eight product owners in `catalogs/coverage-products.psd1`;
- all eight generated-source registry file/class owners;
- all eight rows in `assertion-depth-runtime-module-review.csv`;
- all seven matching rows in `assertion-depth-module-repair-review.csv`;
- the UserData predecessor owner in both current predecessor records;
- the living quality CSV and every living Markdown count/list;
- tasks 4.7, 5.5, and 5.8;
- issue `SDK-QUALITY-206`.

Assertion-depth ranges now cover the complete owner/helper closures:

`10-197`, `10-290`, `10-209`, `10-147`, `10-191`, `10-366`,
`10-251`, and `10-222`.

Task 4.7 is complete. All 14 original mixed-responsibility owners are closed.
Task 5.5 remains open only for linked restore-runtime and final gates. Task
5.8 no longer claims a remaining physical split. `SDK-QUALITY-206` is
resolved.

Historical build/test evidence, stage snapshots, lifecycle repair handoffs,
and implementation-ledger history were not rewritten.

## Current inventory and quality

Official current inventory:

- 271 files;
- 688 methods;
- 8,154 assertions;
- 162,642 lines;
- 301 raw blocks;
- 294 ANSI wrappers;
- 674 active / 14 Disabled methods.

Living quality parity:

- 271 rows / 271 unique physical source keys;
- 231 `CompliantCaseOwned`;
- 228 `NotLarge`;
- 43 retained cohesive generated owners;
- 0 split-required owners.

The top table, current list/heading/narrative, bottom summary, CSV, and
physical source tree agree.

## Static verification

- Coverage expansion: PASS, 317 products / 46,140 cases.
- Catalog/registry validation: PASS, 46,140 unique IDs.
- Current inventory export: PASS, exact 271 / 688 / 8,154 / 162,642 /
  301 / 294 / 674 / 14.
- Source reconciliation with completeness required: PASS, 0 incomplete
  products and 0 unresolved methods.
- API audit with completeness required: PASS, 365 rows / 0 missing /
  0 incomplete.
- Predecessor reconciliation with final dispositions required: PASS,
  222 required scenarios checked.
- Internal finalization/reconciliation: PASS, 1,002 final / 0 pending.
- Boundary audit: PASS, 0 violations.
- Inline AngelScript audit: PASS, 301/301 conforming / 0 violations.
- Planning validation: PASS, 0 violations.
- Strict OpenSpec validation: PASS, 1/1.
- Focused file/method/product/source guard: PASS, eight exact owners and
  hashes, aggregate absent.
- Focused case/assertion guard: PASS, 31/31 and 155/153 with only the two
  named duplicate hashes.
- Focused protocol guard: PASS, exact source, engine, context, discard, and
  explicit-release distributions.
- Focused current-record guard: PASS, no retired owner in current catalog,
  registry, assertion-depth, predecessor, quality, or task records.
- Scoped whitespace/EOF and authored terminology guard: PASS.

## Problems and corrections

1. The first generated-owner script passed single helper ranges through a
   nested PowerShell array. PowerShell flattened six one-range entries, and
   those six provisional files each gained 51 unintended lines. The aggregate
   was still intact. Line/hash checks rejected the provisional files; they
   were deleted and regenerated with explicit helper start/end fields. All
   eight exact target hashes then matched before the aggregate was removed.
2. The first focused discard guard counted only direct `DiscardModule` calls
   and omitted wrapper `.Discard()` operations. It stopped before accepting
   the protocol result. The corrected guard counts both forms and confirms the
   exact 17-operation distribution.
3. The first protocol guard derived context lifecycles only from helper calls
   and omitted ImportUnbindAll's direct context. The partial result was not
   accepted. The corrected formula includes direct method contexts after
   excluding helper definitions and confirms `2,2,1,0,0,7,0,2`.

No rejected or partial result was used as final evidence.

## Execution boundary

No build was run. No UE Automation test was run. No commit or worktree was
created. No unrelated source, add-on, UE integration, support API, historical
checkpoint, or external record was modified.

## Review finding fixes

The independent review reported two High living-record findings. Both were
corrected without changing source or any other CSV field:

- the eight Module API rows in
  `handoffs/assertion-depth-runtime-module-review.csv` now use complete
  owner/helper ranges `10-197`, `10-290`, `10-209`, `10-147`, `10-191`,
  `10-366`, `10-251`, and `10-222`;
- the seven matching rows in
  `handoffs/assertion-depth-module-repair-review.csv` now use the same required
  ranges; no UserDataLifecycle row was added.

Focused verification command:

```powershell
@'<focused Python CSV parser and physical-owner range guard>'@ | python -
openspec validate test-as-native-sdk-comprehensive-coverage --strict --json
```

The focused parser loaded both CSV files through `csv.DictReader`, resolved all
eight runtime/module owner triples, found exactly eight plus seven affected
rows, matched all fifteen exact ranges, and verified every end line against
the physical owner EOF. It also checked both CSV files for final newline and
trailing whitespace.

Results:

- `FOCUSED_CSV_PASS`;
- runtime/module rows: 8/8;
- repair rows: 7/7;
- exact owner/range matches: 15/15;
- physical EOF-bounded ranges: 15/15;
- trailing whitespace: 0;
- final newlines: 2/2;
- strict OpenSpec: 1/1 valid, 0 failed, no issues.

No command was rejected or required correction during this focused review
repair. No build, UE Automation test, or commit was run.
