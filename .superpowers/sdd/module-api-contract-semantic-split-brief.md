# Module API contract semantic-owner split brief

## Scope and frozen baseline

Refactor only:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Module/AngelscriptNativeModuleApiContractTests.cpp`

Replace the eight-product aggregate with eight one-product physical owners.
Do not change any registered method body, product/case ID, generated source,
diagnostic, public API oracle, lifecycle, cleanup, import state, user-data
callback, or recovery behavior.

Frozen aggregate:

- 1,461 lines / 44,530 bytes / LF;
- full-file SHA-256:
  `D6A60007951683E26078DB57F72A1A6C3E2354574D87299EC3526DDBBF1ED184`;
- 1 class / 8 methods / 8 products;
- 31 `CurrentFork` case IDs;
- 155 physical / 153 unique assertion hashes;
- 20 dynamic source reports through 1 direct physical print site;
- 16 raw source blocks / 16 ANSI wrappers;
- 9 engine Create/Destroy call-site pairs;
- 14 context create/release lifecycles;
- 17 module discard operations;
- no class-owned engine or CQTest lifecycle hook.

Method hashes cover `TEST_METHOD` through the matching final method brace,
excluding the following newline:

| Method | Bytes | SHA-256 |
| --- | ---: | --- |
| `RenameReindexesEngineLookup` | 3,619 | `4D1964C802BCD9662502E6EF9E1A9433DCD1797EA421270F17A4485ADB8CD328` |
| `CompileFunctionDetachedAttachedAndInvalid` | 7,011 | `68EAD2785A973E63213E06091A476689D83EF959A2FD7F98AA16A5786F294F72` |
| `RemoveFunctionPreservesExternalOwnership` | 4,040 | `02F0DD489E56E5DD2A682848EDDB02F89EA7AF86B8826C8AABC04333DA28AFEF` |
| `TypedefInventoryUsesForkEmptyBoundary` | 3,673 | `F8CAFDF168D72819482E0C5B3E182344CF7C1FAA44D9A644DA1822F148CF03F4` |
| `UserDataTransitionsAndCleanup` | 3,886 | `C1811DC20493B890668F7021A2A27B4A7F0E5CEF9D08BD108A20A4BA204EE974` |
| `UnbindAllImportsThenRebinds` | 6,349 | `1AAC035A93A08FF7F77093E237BCA01889C474FA6A92C9371C9DD8DE1024C924` |
| `PreClassMetadataAppliesOnlyToExactDeclaration` | 6,849 | `E4BF281855BC4FC1DC2BA7A508CB8DFFBF6D489D9B22FD2FEDE2613C2E4B6647` |
| `NestedImportModuleVisibilityAndDeduplication` | 4,390 | `DBAC69685667D997CD23BB1EE3216E9C227530FCB2053ACFE622C407BBB38A6D` |

All eight complete methods must remain byte-preserved.

## Required physical owners

Delete the aggregate and create:

| File / class | Method / product | Target layout / SHA-256 |
| --- | --- | --- |
| `AngelscriptNativeModuleRenameReindexTests.cpp` / `FModuleRenameReindexTests` | `RenameReindexesEngineLookup` / `MOD-API-RENAME-REINDEX` | 199 lines; method 74-196; `8297BE81F053F43122B7FCA78C54FA8B3F7A801F832198201A768F5382D3DF98` |
| `AngelscriptNativeModuleCompileFunctionTests.cpp` / `FModuleCompileFunctionTests` | `CompileFunctionDetachedAttachedAndInvalid` / `MOD-API-COMPILE-FUNCTION` | 292 lines; method 74-289; `19B01B37A2A2C32B45CDD9F93A45E323D8177F2072880B287F6A5C62331CC3D3` |
| `AngelscriptNativeModuleRemoveFunctionTests.cpp` / `FModuleRemoveFunctionTests` | `RemoveFunctionPreservesExternalOwnership` / `MOD-API-REMOVE-FUNCTION` | 211 lines; method 74-208; `41F442FC29B2B1F9F54FEA9F445F833DCF1B73991B216892E3644E88D2BF25E4` |
| `AngelscriptNativeModuleTypedefInventoryTests.cpp` / `FModuleTypedefInventoryTests` | `TypedefInventoryUsesForkEmptyBoundary` / `MOD-TYPEDEF-INVENTORY-BOUNDS` | 149 lines; method 40-146; `BFC962B0C560AA456E8DA6CE23C82DD6EDD1E2B9009E087B9FA65B5FD152F6C7` |
| `AngelscriptNativeModuleUserDataLifecycleTests.cpp` / `FModuleUserDataLifecycleTests` | `UserDataTransitionsAndCleanup` / `MOD-USERDATA-LIFECYCLE` | 193 lines; method 66-190; `42E237E25E47829A54C4A09AA1E91EFA116DE91ACF1B70E6ED931801A25925EC` |
| `AngelscriptNativeModuleImportUnbindAllTests.cpp` / `FModuleImportUnbindAllTests` | `UnbindAllImportsThenRebinds` / `MOD-IMPORT-UNBIND-ALL` | 368 lines; method 138-365; `B88B7640F745A71E18E61964FB840D6DF08CF7F7F837250DF5A314EA997EEACF` |
| `AngelscriptNativeModulePreClassMetadataTests.cpp` / `FModulePreClassMetadataTests` | `PreClassMetadataAppliesOnlyToExactDeclaration` / `MOD-PRECLASS-METADATA-APPLICATION` | 253 lines; method 45-250; `E87022980DA34A361F9BC32D2F67138D570A862BD379D4226335BF0753D5224D` |
| `AngelscriptNativeModuleNestedImportVisibilityTests.cpp` / `FModuleNestedImportVisibilityTests` | `NestedImportModuleVisibilityAndDeduplication` / `MOD-NESTED-IMPORT-VISIBILITY` | 224 lines; method 74-221; `48E1A8CED74F4B589D2B44537F53A03345CED83360B4514339EE1BFE5BD23ECF` |

All eight classes retain:

`Angelscript.TestModule.AngelScriptSDK.Module.ApiContracts`

Every new file/class name must be globally unique. All eight files must remain
below 1,000 lines.

## No new shared support surface

Keep the aggregate's three support includes in each focused owner. Do not add a
new header or file-level helper API.

Copy both class-private `PrintSource` overloads into all eight owners. Every
physical `.cpp` must contain one direct `PrintGeneratedAsSource` call site for
registry validation.

Copy `ExecuteFunction` only into Rename, CompileFunction, RemoveFunction,
ImportUnbindAll, and NestedImportVisibility. Its exact-return and context
release assertions are part of those products and must not be replaced by a
weaker generic helper.

Keep:

- `ExpectUnboundFunctionException` only in ImportUnbindAll;
- user-data token, slots, callback and inline static state only in
  UserDataLifecycle;
- only the required token type in PreClassMetadata.

No anonymous namespace, file-level assertion alias, test-flow wrapper, or
expanded support API.

## Exact product and structural invariants

Case cardinalities:

- Rename: 1;
- CompileFunction: 4;
- RemoveFunction: 4;
- TypedefInventory: 2;
- UserDataLifecycle: 6;
- ImportUnbindAll: 4;
- PreClassMetadata: 6 (`3 observations × 2 targets`);
- NestedImportVisibility: 4;
- total: 31 unique IDs.

Assertions, physical/unique:

- Rename: 14/14;
- CompileFunction: 28/28;
- RemoveFunction: 15/15;
- TypedefInventory: 14/14;
- UserDataLifecycle: 16/16;
- ImportUnbindAll: 26/24;
- PreClassMetadata: 27/27;
- NestedImportVisibility: 15/15;
- total: 155/153.

Only these two ImportUnbindAll hashes have multiplicity 2:

- `e34af2bb6941a6736f81d6a59e0af45e3c669a9b1f7f97ac0d9d7026c1aec2d1`;
- `53d49519f57011b4f8ec84ce8b06a53b82d569582b1bfdab1a24c899a2ef2529`.

Every other assertion hash has multiplicity 1.

Dynamic source reports per owner:

`2, 4, 2, 2, 2, 3, 2, 3` = 20.

Raw/ANSI sources per owner:

`1, 2, 2, 2, 2, 3, 1, 3` = 16/16.

Engine Create/Destroy pairs:

`1, 1, 1, 1, 2, 1, 1, 1` = 9/9.

Context create/release lifecycles:

`2, 2, 1, 0, 0, 7, 0, 2` = 14/14.

Module discards:

`2, 2, 2, 2, 1, 3, 2, 3` = 17.

Preserve explicit function release ownership in CompileFunction and
RemoveFunction and the UserData destroy/recreate protocol.

## Catalog, registry, and generated current outputs

In `catalogs/coverage-products.psd1`, change only the file/class portion of all
eight owners. Preserve method, product, axes, classification, evidence,
expected text, and all 31 IDs.

In `catalogs/generated-source-registry.csv`, change only file/class for each
row. Preserve method/product, generator
`PrintSource; PrintGeneratedAsSource`, `PrintSites=1`, formatting, and reason.

Regenerate:

- expanded expected cases and product cardinalities;
- current files, methods, assertions, and summary;
- implementation and method-product reconciliation;
- API use;
- predecessor and internal reconciliation;
- boundary, inline-source, and planning outputs.

Do not hand-edit generated rows or rewrite stage/history snapshots.

The stable pre-split physical tree after Variable Lifetime is:

- 264 files;
- 688 methods;
- 8,154 assertions;
- 162,214 lines;
- 301 raw blocks;
- 294 ANSI wrappers;
- 674 active / 14 Disabled methods.

The exact eight-owner replacement adds seven files and 428 lines:

- 271 files;
- 688 methods;
- 8,154 assertions;
- 162,642 lines;
- 301 raw blocks;
- 294 ANSI wrappers;
- 674 active / 14 Disabled methods.

## Current handoffs and predecessor mapping

Update all eight rows in
`handoffs/assertion-depth-runtime-module-review.csv` to their new
file/class/method and complete owner/helper ranges:

- Rename: `10-197`;
- CompileFunction: `10-290`;
- RemoveFunction: `10-209`;
- TypedefInventory: `10-147`;
- UserDataLifecycle: `10-191`;
- ImportUnbindAll: `10-366`;
- PreClassMetadata: `10-251`;
- NestedImportVisibility: `10-222`.

Update the seven matching rows in
`handoffs/assertion-depth-module-repair-review.csv`; UserDataLifecycle has no
row there. Ranges must cover every directly called class-private helper.

Migrate `MOD-USERDATA-LIFECYCLE` in:

- `audits/predecessor-dispositions.csv`;
- `handoffs/predecessor-terminal-disposition-review.csv`.

Preserve historical verification, old stage snapshots, lifecycle repair
handoffs, and old implementation ledger evidence.

## Living quality, tasks, and issue closure

Replace the aggregate quality row with eight
`CompliantCaseOwned` / `NotLarge` / `None.` rows whose lifecycle evidence uses
the exact per-owner method and engine Create/Destroy counts.

From the stable post-Variable state:

- rows/source owners: 264 → 271;
- `CompliantCaseOwned`: 224 - 1 + 8 = 231;
- `NotLarge`: 220 + 8 = 228;
- retained cohesive owners: 43 unchanged;
- split-required owners: 1 → 0.

Reconcile every living quality Markdown summary/list/count with the CSV and
physical source. Remove the pending Module bullet and record eight focused
owners. State that no current semantic split remains.

Tasks:

- mark 4.7 complete and state all 14 original mixed-responsibility owners are
  closed, with Module's eight products one-to-one;
- leave 5.5 open only for linked restore-runtime and final gates; remove stale
  Module split/assertion-depth wording;
- remove stale remaining-split wording from 5.8;
- leave 5.10 unchanged.

Resolve `SDK-QUALITY-206`: all 14 named physical splits are complete, 43
cohesive generated owners remain intentionally retained, and zero current
split-required rows remain.

## Lifecycle and style requirements

Follow `Documents/UnitTest/UnitTest.md`:

- one scenario-specific method per class;
- all narrow helpers class-private and `public:` before the method;
- self-contained includes outside one balanced unit-test body gate;
- file-scope-aligned CQTest terminators;
- case-owned engines with immediate RAII destroy guards;
- no class-owned engine or CQTest lifecycle hook;
- no anonymous namespace, file-level assertion alias, or top-level forwarding
  wrapper;
- no add-on, `FAngelscriptEngine`, UObject/world fixture, or debugger
  integration;
- preserve complete generated source and current Allman formatting.

Use `apply_patch` only. Do not build, run UE Automation, commit, or modify
unrelated files.

## Static verification

Before reporting complete:

- frozen aggregate full hash and all eight method hashes match;
- aggregate is absent and all eight exact files/classes exist uniquely;
- all eight exact post-layout file hashes and method line ranges match;
- each owner has 1 class / 1 method / 1 product / 1 direct print site;
- 31/31 unique IDs and exact per-product cardinalities remain;
- assertions remain exact 155 physical / 153 unique, with only the two named
  hashes duplicated;
- source reports, raw/ANSI sources, engine pairs, context lifecycles, discards,
  and explicit function releases match the exact distributions;
- every owner retains the frozen Automation directory;
- catalog/registry/current/assertion-depth/predecessor/quality/task records
  contain no retired aggregate owner outside historical checkpoints;
- current inventory is 271/688/8,154/162,642/301/294/674/14;
- living quality is 271 keys, 231 case-owned, 228 not-large, 43 retained,
  zero split-required;
- task 4.7 is complete and 5.5/5.8 wording is current;
- catalog, source, API, predecessor, internal, boundary, inline-AS, planning,
  strict OpenSpec, whitespace/EOF, unity/ODR, and history/current checks pass.

Record and correct every rejected path/parameter/input/host invocation; never
accept default or rejected output as final evidence.

## Report

Write:

`.superpowers/sdd/module-api-contract-semantic-split-report.md`

Record all hashes, per-owner counts, source/lifecycle distributions, current
record migrations, static commands/results, problems/corrections, and explicit
confirmation that no build, UE Automation, commit, or unrelated edit occurred.
