# Reference identity semantic-owner split brief

## Scope and frozen baseline

Refactor only:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Language/References/AngelscriptNativeReferenceIdentityTests.cpp`

Separate the 288-cell positive source/operation/qualifier behavior from the
single current-fork derived-to-base input-reference rejection. Do not change
either method body, product/case IDs, source text, diagnostics, runtime
oracles, lifecycle, cleanup, or recovery behavior.

Frozen current source:

- 1,178 lines / 30,982 bytes / LF;
- full-file SHA-256:
  `C45D418DFD45D7F2C36C0A79383588BAB4E4B0E827009792764CCE35B370A353`;
- 1 class / 2 methods / 2 products;
- 289 cases: 288 positive plus 1 `RejectByFork`;
- 43 physical assertion sites and 43 unique assertion hashes;
- 1 direct `PrintGeneratedAsSource` site serving primary/recovery reports;
- 2 engine Create/Destroy call-site pairs;
- no class-owned engine or CQTest lifecycle hook.

Method hashes cover `TEST_METHOD` through the matching final method brace,
excluding the following newline:

- `CurrentForkRejectsDerivedToBaseInputReferenceConversion`, 2,792 bytes:
  `A6B2697F5C25EAB12E099751E22382120E61E7DAEA89D7AB79DACD30FAEB30B3`;
- `SourcesByOperationAndQualifier`, 680 bytes:
  `52DECD7FBF6EE2768733B0CC97F015D3542813246D3487661E897BAD2AB9BC3C`.

Both complete method bodies must remain byte-preserved after the move.

## Required physical owners

Retain:

1. `Language/References/AngelscriptNativeReferenceIdentityTests.cpp`
   - class `FReferenceIdentityTests`
   - method `SourcesByOperationAndQualifier`
   - product `LANG-REF-SOURCE-OP`
   - 288 cases
   - exact post-layout target: 1,081 lines / 28,187 bytes
   - expected full-file SHA:
     `59CBBE9FE5BA877AA934211FD00AD6A0E0731E21362CC49F2BDD3F89E4D80978`

Create:

2. `Language/References/AngelscriptNativeReferenceDerivedInputRejectionTests.cpp`
   - class `FReferenceDerivedInputRejectionTests`
   - method `CurrentForkRejectsDerivedToBaseInputReferenceConversion`
   - product `LANG-REF-FORK-DERIVED-INREF`
   - 1 case
   - exact target layout: 268 lines / 7,754 bytes
   - expected full-file SHA when the required layout is followed:
     `696ADFE0104D285E4DD946C34A47A90E3D612B55603E190CF64A6027DAFFB18C`

Both classes retain the exact Automation directory:

`Angelscript.TestModule.AngelScriptSDK.Language.References.Identity`

Do not reuse the same C++ class name in both files.

The retained owner remains over 1,000 lines but becomes a single cohesive
generated product. Do not split it further merely for line count.

## No new shared support surface

Reuse `AngelscriptNativeReferenceTestSupport.h` unchanged. Do not create a new
header or enlarge the existing shared surface.

The new rejection class copies exactly these aliases:

- `FNativeCaseContext`;
- `FNativeTestEngine`;
- `FReferenceState`.

It copies exactly these five class-private helpers in their existing order and
spelling:

- `BuildReferenceIdentityRecoverySource`;
- `CompileAndReport`;
- `ExecuteRecovery`;
- `VerifyLifecycleCleanup`;
- `CompileAndRunRecoveryModule`.

This is the dependency-complete closure needed to preserve the moved method
body. `CompileAndReport` must remain physically present in both generated-source
owners so each `.cpp` contains its direct `PrintGeneratedAsSource` site.
Moving assertion-bearing recovery/lifecycle helpers into a header would also
remove them from the current `.cpp` assertion inventory. The class-private
copy is intentional and unity/ODR safe because the classes are unique.

Do not copy any positive-only enum, table, source provider, operation builder,
metadata verifier, or `RunCell`.

## Positive owner responsibility

Preserve all 288 cells and their exact iteration order:

`9 operations × 4 qualifiers × 8 sources`

Keep:

- 88 compile-rejection cells;
- 200 successful compilation cells;
- 7 located null runtime-exception cells;
- 193 successful semantic-sentinel cells;
- 288 isolated raw engines;
- 88 failed-shell discard plus same-engine/same-name recovery flows;
- 200 legal entry/recovery same-context flows;
- 288 context lifecycles;
- 376 dynamic source reports: 288 primary plus 88 recovery;
- 376 module discards;
- per-cell native reference lifecycle and identity reconciliation.

## Derived-input rejection responsibility

Preserve the single fork rejection:

- source `FRefDerived`;
- target `const FRefRoot&in`;
- negative build result;
- both exact diagnostic fragments:
  - `No matching signatures`;
  - `Parameter 'First' expected const FRefRoot&, but got FRefDerived&`;
- failed module shell discard;
- same-engine/same-module recovery;
- recovery sentinel `913`;
- native object creation/destruction identity and retain/release balance.

Dynamic order must remain:

engine create → fixture/register → rejected compile → failed-shell discard →
recovery compile → context create/prepare/execute/read/unprepare/release →
recovery discard → retained-native release → lifecycle/identity assertions →
RAII engine destroy.

## Assertion preservation

The positive owner keeps its 38 physical assertion sites. The new rejection
owner contains 13 copied helper sites plus the moved method's 5 sites.

Expected physical distribution:

- retained owner: 38;
- rejection owner: 18;
- combined: 56.

The 13 copied helper sites intentionally increase global physical sites from
8,141 to 8,154, but introduce no new assertion meaning:

- two-file unique assertion hashes remain exactly 43;
- the 13 copied helper hashes each have multiplicity 2;
- every other hash has multiplicity 1;
- the method's 5 hashes move without duplication.

The implementation report must list and verify the 13 duplicated hashes from
the frozen design evidence. Do not replace this exact multiplicity guard with
only an aggregate count.

## Generated-source registry and catalogs

In `catalogs/coverage-products.psd1`:

- keep `LANG-REF-SOURCE-OP` unchanged;
- change only `LANG-REF-FORK-DERIVED-INREF.Owner` to the new
  file/class/method;
- preserve axes, classification, evidence, expected text, and IDs.

In `catalogs/generated-source-registry.csv`:

- retain the positive row unchanged with `PrintSites=1`;
- add one rejection row with:
  - generator
    `AppendGeneratedAsLine; BuildReferenceIdentityRecoverySource`;
  - `PrintSites=1`;
  - stable Allman rejected source followed by same-name recovery source;
  - reason describing exact diagnostics, failed-shell discard, recovery
    sentinel, and native reference reconciliation.

Each resulting `.cpp` must contain one direct `PrintGeneratedAsSource` site.
`PrintSites` is the physical site count, not the number of dynamic reports.

## Living and generated records

Update:

- product catalog and generated-source registry;
- `handoffs/fixture-and-large-file-quality-review.csv`;
- the living section of
  `handoffs/fixture-and-large-file-quality-review.md`;
- task 4.7 and the stale split count in task 5.8;
- both Identity rows in
  `handoffs/assertion-depth-language-conformance-review.csv`.

Quality classification:

- retained owner:
  `CompliantCaseOwned` / `RetainCohesiveGeneratorOrOwner` / `None.`;
- rejection owner:
  `CompliantCaseOwned` / `NotLarge` / `None.`.

Derive final absolute counts from current source. Relative to the stable
post-Direction baseline this split:

- adds one source owner and one `CompliantCaseOwned`;
- adds one `NotLarge`;
- increases retained cohesive owners by one;
- decreases split-required owners by one;
- leaves the over-1,000-file count unchanged.

Regenerate official current outputs instead of hand-editing generated rows:

- expected cases and product cardinalities;
- current files, methods, assertions, and summary;
- implementation and method-product reconciliation;
- API use;
- boundary, inline-source, and planning records.

Expected current summary from the stable post-Direction baseline:

- files: 262 → 263;
- methods: 688 unchanged;
- assertions: 8,141 → 8,154;
- lines: 161,858 → 162,029 for the exact required layout;
- raw blocks: 301 unchanged;
- ANSI wrappers: 294 unchanged;
- active/Disabled methods: 674/14 unchanged.

Preserve historical checkpoint records. Update only current/living ownership
and evidence paths.

## Lifecycle and style requirements

Follow `Documents/UnitTest/UnitTest.md`:

- one direct test flow per physical owner;
- class-private aliases/helpers;
- `public:` before each method;
- includes outside one balanced unit-test body gate;
- file-scope-aligned class terminators;
- no anonymous namespace, file-level assertion alias, or hidden top-level test
  forwarding wrapper;
- case-owned raw engines and immediate RAII destruction guards;
- no class-owned engine or `BEFORE_ALL`/`BEFORE_EACH`/`AFTER_ALL`;
- no add-on, `FAngelscriptEngine`, UObject/world fixture, or debugger
  integration;
- generated AngelScript formatting and complete source reporting unchanged.

Use `apply_patch` only. Do not build, run UE Automation, commit, or touch
unrelated files.

## Static verification

Before reporting complete:

- both method hashes and the two expected post-layout file hashes match;
- exact owners are 1 class / 1 method / 1 product each;
- cardinalities remain 288 + 1 = 289 unique IDs;
- global catalog remains 317 products / 46,140 unique IDs unless an explicitly
  reviewed concurrent change changes the baseline;
- two-file physical assertions are 56, unique hashes 43, and the exact 13
  copied hashes alone have multiplicity 2;
- global current assertion count is 8,154;
- both files have one direct print site and exact registry rows;
- each file has one engine Create/Destroy call-site pair and zero hooks;
- positive and rejection engine/context/module/native-state cleanup remains
  exact;
- retained owner contains no derived-input rejection product;
- rejection owner contains no positive source/operation tables or `RunCell`;
- no new or expanded shared header exists;
- unique file/class names and helper scopes are unity/ODR safe;
- current quality CSV exactly matches the physical SDK tree and remaining
  split count decreases from three to two;
- task 4.7 and task 5.8 both state the current two remaining splits;
- both current assertion-depth handoff rows resolve to real current
  file/class/method/evidence ranges;
- catalog, registry, source, API, predecessor, internal, boundary, inline-AS,
  planning, strict OpenSpec, whitespace/EOF, and current-record checks pass.

Record and correct any failed host/parameter/path/input invocation. Do not use
rejected output as evidence.

## Report

Write:

`.superpowers/sdd/reference-identity-semantic-split-report.md`

Report exact pre/post files, method/file hashes, cardinalities, assertion hash
multiplicity, print/lifecycle preservation, static command results, all
encountered problems, and confirmation that no build, UE Automation, commit,
or unrelated edit occurred.
