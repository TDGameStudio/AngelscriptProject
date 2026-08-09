# Variable lifetime semantic-owner split brief

## Scope and frozen baseline

Refactor only:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp`

Separate ordinary variable exit/nesting lifetime behavior from counted-reference
assignment ownership transitions. Do not change either method body, case IDs,
generated AngelScript, bytecode/metadata diagnostics, lifecycle callbacks,
runtime oracles, cleanup, recovery, or save/load behavior.

Frozen current source:

- 1,551 lines / 58,194 bytes / LF;
- full-file SHA-256:
  `48F449F71E546FF47CAE578F7A9278E8D036A83FF78487E8BD02ACB5BBB205A0`;
- 1 class / 2 methods / 2 products;
- 107 cases: 100 ordinary lifetime plus 7 counted-reference scenarios;
- 87 physical and unique assertion hashes;
- 2 direct `PrintGeneratedAsSource` sites;
- 2 raw-engine Create/Destroy pairs;
- 2 context Create/Release call sites;
- no class-owned engine or CQTest lifecycle hook.

Method hashes cover `TEST_METHOD` through the matching final method brace,
excluding the following newline:

- `OwnersByExitAndNesting`, 2,903 bytes:
  `F462718EF15E0CE9E4617BEE0B5CF9F4EE9E93A6ADC0249C2224E8BD9683CE83`;
- `CountedReferenceAssignmentsBalanceAcrossOwnershipTransitions`, 17,144
  bytes:
  `3FEB71438FBB0C798ACBB715D024370B7CDA87C629C3DBD9B481B46A3C59F476`.

Both complete method bodies must remain byte-preserved.

## Required physical owners

Retain:

1. `Language/Variables/AngelscriptNativeVariableLifetimeTests.cpp`
   - class `FVariableLifetimeTests`
   - method `OwnersByExitAndNesting`
   - product `LANG-VAR-LIFETIME`
   - 100 cases
   - 46 assertions
   - exact target: 945 lines / 32,778 bytes
   - expected full-file SHA:
     `B18D5FA3136D9668D02B8A6DC1C352470C3E6C1BC24770B06854F0FF7F787030`

Create:

2. `Language/Variables/AngelscriptNativeCountedReferenceAssignmentTests.cpp`
   - class `FCountedReferenceAssignmentTests`
   - method
     `CountedReferenceAssignmentsBalanceAcrossOwnershipTransitions`
   - product `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT`
   - 7 cases
   - 41 assertions
   - exact target: 791 lines / 30,545 bytes
   - expected full-file SHA:
     `1E25823602E8C36DC015367B6C2C9878ABDA8BEDB22E077599AE7E80219086AA`

Both classes retain:

`Angelscript.TestModule.AngelScriptSDK.Language.Variables.Lifetime`

Use unique C++ class names for unity/ODR safety.

## No new shared support surface

Do not add a header or enlarge an existing shared header.

Copy only these three stateless, assertion-free class-private helpers into both
unique classes:

- `DescribeBytecode`;
- `ContainsBytecodeOpcode`;
- `DescribeNativeReferenceRegistration`.

This preserves unqualified calls in both frozen method bodies without changing
assertion ownership or exposing a new shared interface.

The retained owner keeps only ordinary-lifetime cases/tables, source builders,
expectation helpers, `VerifyLifecycle`, and `ExecuteCell`.

The counted owner keeps only counted-reference scenario definitions, source
builder, object-move/function-layout/object-lifetime metadata helpers, and its
registered method.

## Ordinary lifetime responsibility

Preserve all 100 cells:

`4 owner kinds × 5 exit paths × 5 nesting forms`

Keep the exact exit → nesting → owner iteration order and:

- one case-owned raw engine for the product;
- registration of native value/reference fixtures;
- per-cell lifecycle reset and complete source print;
- independent module compilation and exact entry/recovery lookup;
- one context per cell;
- finished or exception result with exact return/exception metadata;
- `Unprepare`;
- exact construction/copy/assignment/destruction counts and order;
- unique identities, no duplicate destruction, balanced reference
  AddRef/Release, and zero live objects;
- same-context recovery returning 89 without hidden lifecycle events;
- context release, exact module discard/null lookup, and final zero-live check.

Retain the currently inactive
`ELifetimeExpectation::CurrentForkRawClassRetention` helper branch. Do not
remove frozen helper behavior during this physical split.

## Counted-reference responsibility

Preserve the seven exact scenarios:

- `factory_local`;
- `overwrite`;
- `null_assignment`;
- `parameter_return`;
- `exception_frame`;
- `save_load`;
- `parameter_return_save_load`.

Keep:

- one case-owned raw engine and one native registration;
- exact reference flags, user-data absence, AddRef/Release behaviours;
- per-scenario recorder reset and complete source print;
- exact entry lookup, bytecode print, automatic-object metadata;
- parameter/return object-move, offsets, ABI and call-layout checks;
- `REFCPY`/`RefCpyV` and object-type operand-size checks;
- typed save/load and legacy-unframed rejection/overread boundary;
- source-module discard, restored-module creation/load and exact restored
  metadata/layout;
- one context per scenario with normal/exception identity behaviour;
- `Unprepare`, exact construction/AddRef/Release/destruction counts, and zero
  live objects;
- same-context recovery returning 89, second `Unprepare`, release, and module
  discard.

Do not introduce class-owned recorder/engine or CQTest hooks.

## Assertion and source-print preservation

Expected assertions:

- retained owner: 39 helper + 7 method = 46;
- counted owner: 41 method = 41;
- combined: 87;
- unique hashes: 87;
- every assertion hash multiplicity: 1;
- global current assertions remain 8,154.

Each file has exactly one direct `PrintGeneratedAsSource` site. Dynamic reports
remain 100 + 7 = 107.

## Catalog, registry, and Variables record

In `catalogs/coverage-products.psd1`:

- keep `LANG-VAR-LIFETIME` unchanged;
- change only the counted-reference product owner to the new file/class/method;
- preserve every ID, scenario axis, classification, evidence, and expected
  text.

In `catalogs/generated-source-registry.csv`:

- keep the ordinary owner and change its `PrintSites` from 2 to 1;
- move the counted row to the new file/class and change its `PrintSites` from
  2 to 1;
- preserve generators, formatting contracts, and reasons.

Update `coverage/variables.md` because its current living total omits the
already implemented counted-reference product:

- add `LANG-VAR-COUNTED-REFERENCE-ASSIGNMENT` and its seven existing cases;
- describe factory, overwrite, null, parameter/return, exception and save/load
  ownership transitions;
- update Variables from 1,933 to 1,940 expected cases;
- add the new physical owner to current ownership;
- do not add or remove any catalog case.

## Living records and tasks

Update:

- living quality CSV and Markdown;
- task 4.7;
- task 5.8;
- both Variable Lifetime rows in
  `handoffs/assertion-depth-language-conformance-review.csv`.

Assertion-depth evidence must resolve to the complete current owner/helper
closure:

- ordinary owner: `15-943`;
- counted owner: `15-789`.

Quality rows:

- both are `CompliantCaseOwned` / `NotLarge` / `None.`.

Relative to stable post-Identity state:

- source owners 263 → 264;
- `CompliantCaseOwned` 223 → 224;
- `NotLarge` 218 → 220;
- retained cohesive owners remain 43;
- split-required owners 2 → 1.

Task 4.7 records the preserved 100 + 7 cases, 46 + 41 assertions, two method
hashes, prints, and independent protocols, with Module API Contract as the only
remaining split. Task 5.8 must also state one remaining split but remains open
until final build/runtime gates.

Regenerate official current outputs:

- expected cases and product cardinalities;
- current files, methods, assertions, and summary;
- implementation and method-product reconciliation;
- API use;
- predecessor and internal reconciliation;
- boundary, inline-source, and planning records.

Expected current summary for the exact layout:

- files: 264;
- methods: 688;
- assertions: 8,154;
- lines: 162,214;
- raw blocks: 301;
- ANSI wrappers: 294;
- active/Disabled methods: 674/14.

Do not rewrite historical checkpoints or old build/test evidence.

## Lifecycle and style requirements

Follow `Documents/UnitTest/UnitTest.md`:

- direct scenario-specific methods and class-private helpers;
- `public:` immediately before the test region;
- self-contained includes outside one balanced unit-test body gate;
- file-scope-aligned CQTest terminators;
- no anonymous namespace, file-level assertion alias, or top-level forwarding
  wrapper;
- case-owned raw engines with immediate RAII destroy guards;
- no class-owned engine or `BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL`;
- no add-on, `FAngelscriptEngine`, UObject/world fixture, or debugger
  integration;
- preserve complete generated source and current Allman formatting.

Use `apply_patch` only. Do not build, run UE Automation, commit, or touch
unrelated files.

## Static verification

Before reporting complete:

- aggregate pre-hash and both frozen method hashes match;
- both exact post-layout full-file hashes match;
- each file has exactly 1 class / 1 method / 1 product / 1 print /
  1 engine Create/Destroy pair;
- cardinalities remain 100 + 7 = 107 unique IDs;
- assertions remain 46 + 41 = 87 physical and unique, all multiplicity 1;
- global catalog remains 317 / 46,140 unique and global assertions 8,154;
- retained owner has no counted product/scenario/save-load/object-layout code;
- counted owner has no ordinary owner/nesting/exit tables, `VerifyLifecycle`,
  or `ExecuteCell`;
- both engine/context/module/lifecycle protocols remain exact;
- no new/expanded shared header;
- unique classes and class-private copied helpers are unity/ODR safe;
- Variables living total is 1,940;
- both registry rows have `PrintSites=1`;
- both assertion-depth rows resolve through their complete evidence ranges;
- quality CSV/Markdown exactly match 264 physical source owners and
  224/220/43/1 dispositions;
- task 4.7 and 5.8 state one remaining split;
- catalog, source, registry, API, predecessor, internal, boundary, inline-AS,
  planning, strict OpenSpec, whitespace/EOF, and current/history checks pass.

Record and correct every failed command/path/parameter/input. Do not accept a
rejected/default result as evidence.

## Report

Write:

`.superpowers/sdd/variable-lifetime-semantic-split-report.md`

Record hashes, case/assertion/source-print distribution, both protocols,
current record changes, official/static results, all problems and corrections,
and explicit confirmation that no build, UE Automation, commit, or unrelated
edit occurred.
