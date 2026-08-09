# Reference direction semantic-owner split brief

## Scope and frozen baseline

Refactor only:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Language/References/AngelscriptNativeReferenceDirectionTests.cpp`

Separate the positive reference-direction behavior from the current-fork
mutable-global rejection. Do not change generated source, case IDs, diagnostics,
assertions, runtime oracles, lifecycle, cleanup, or recovery behavior.

Frozen current source:

- 1,068 lines / 27,376 bytes;
- full-file SHA-256:
  `AE609C84CA6B6750D2A71A3D3991AD050889C46D62D90A51EB5D84A793B29474`;
- 1 class / 2 methods / 2 products;
- 97 cases: 96 positive plus 1 current-fork rejection;
- 37 assertion call sites: 33 positive-owner helpers plus 4 rejection-method
  assertions;
- 1 shared physical `PrintGeneratedAsSource` site serving 97 runtime reports;
- 2 engine Create/Destroy call-site pairs and 97 isolated runtime engines;
- no class-owned engine or CQTest lifecycle hook.

Inclusive-brace method hashes use LF normalization, per-line trailing
horizontal-whitespace removal, whole-block strip, UTF-8, and SHA-256:

- `CurrentForkRejectsMutableScriptGlobals`:
  `226BAFFA6A4832F01F36A40FB4C53E390996DC2420D00C59A1D9088DEDADC0ED`;
- `DirectionsByAliasAndNullState`:
  `2AA232584475E13691573302C2CE56B23FF087DC0693C0204A55AD6EADB16A64`.

Both complete method bodies must remain byte-preserved after the move.

## Required physical owners

Retain:

1. `Language/References/AngelscriptNativeReferenceDirectionTests.cpp`
   - class `FReferenceDirectionTests`
   - method `DirectionsByAliasAndNullState`
   - product `LANG-REF-DIRECTION`
   - 96 cases
   - 33 assertion sites in the owner/helpers
   - 1 static source-print site

Create:

2. `Language/References/AngelscriptNativeReferenceDirectionMutableGlobalRejectionTests.cpp`
   - class `FReferenceDirectionMutableGlobalRejectionTests`
   - method `CurrentForkRejectsMutableScriptGlobals`
   - product `LANG-REF-DIRECTION-FORK-GLOBAL`
   - 1 case
   - 4 assertion sites
   - 1 static source-print site

Both classes retain the exact Automation directory:

`Angelscript.TestModule.AngelScriptSDK.Language.References.Direction`

The full CQTest leaf class component necessarily changes for the moved method.
Do not reuse one class name in two `.cpp` files because unity compilation would
see duplicate definitions.

## No new shared support boundary

Reuse `AngelscriptNativeReferenceTestSupport.h` unchanged. Do not create a new
header or enlarge the existing support surface.

The retained owner keeps every positive-only alias, enum, struct, table,
generator, callback, oracle, execution helper, cleanup helper, identity
reconciliation helper, and `CompileAndReport`.

The new rejection owner contains only:

- `AngelscriptNativeReferenceTestSupport.h` and `CQTest.h` includes outside the
  unit-test gate;
- one correctly balanced `WITH_ANGELSCRIPT_UNITTESTS` body gate;
- `FReferenceDirectionMutableGlobalRejectionTests`;
- the existing `FNativeCaseContext` and `FNativeTestEngine` aliases;
- a byte-preserved class-private copy of `CompileAndReport`;
- `public:` followed by the byte-preserved rejection method;
- a file-scope-aligned CQTest class terminator.

The narrow class-private `CompileAndReport` duplication is intentional. Both
physical owners must contain their own source reporting call site for generated
source registry validation, while distinct class names keep it unity/ODR safe.
Do not rename the helper at the moved call site.

## Positive owner responsibility

Preserve all 96 cells:

`4 directions × 4 null states × 6 alias relations`

Keep the exact direction → null-state → alias-relation iteration order and case
ID construction. Each cell must retain:

- one isolated raw SDK engine with immediate destroy guard;
- module compilation and exact metadata lookup;
- context create, prepare, execute, unprepare, clean recovery execution, and
  release;
- before/inside/after reference identity and value observations;
- exact module discard;
- retained-native-object release;
- zero live-object result;
- exact creation/destruction count and sorted identity reconciliation.

## Rejection owner responsibility

Preserve the single `RejectByFork` case and its exact:

- case ID and `FNativeCaseContext` literal;
- module name;
- mutable global declaration and recovery function source;
- Allman formatting and blank line;
- complete source print before compilation;
- negative build result;
- both diagnostic fragments: `must be const` and
  `Mutable global variables are not supported`;
- failed-module discard and exact-name null lookup;
- case-owned engine Create/Destroy lifecycle;
- no context creation.

## Generated-source registry and catalogs

In `catalogs/coverage-products.psd1`:

- keep `LANG-REF-DIRECTION` unchanged;
- change only the owner of `LANG-REF-DIRECTION-FORK-GLOBAL` to the new
  file/class/method;
- preserve product ID, axis, classification, evidence, and expected text.

In `catalogs/generated-source-registry.csv`:

- retain the positive row on the retained owner with `PrintSites=1`;
- add one rejection row for the new owner with:
  - generator
    `AppendGeneratedAsLine; CompileAndReport; PrintGeneratedAsSource`;
  - `PrintSites=1`;
  - a formatting contract describing the Allman source, one statement per
    line, the blank line before recovery, and complete pre-compile printing;
  - a reason describing exact fork rejection, owning diagnostics, failed-shell
    discard, and absence of partial name-visible state.

Static print sites become 1 + 1; runtime reports remain 96 + 1.

## Living and generated records

Update authored current records:

- `catalogs/coverage-products.psd1`;
- `catalogs/generated-source-registry.csv`;
- `handoffs/fixture-and-large-file-quality-review.csv`;
- `handoffs/fixture-and-large-file-quality-review.md`;
- task 4.7 in `tasks.md`.

Replace the old quality row with two `CompliantCaseOwned` / `NotLarge` /
`None.` rows. With a stable post-Expression baseline, derive absolute values
from current source. This split adds one physical source owner and one
`CompliantCaseOwned`, adds two `NotLarge` owners, and removes one remaining
split-required owner.

In task 4.7, record that the retained owner keeps all 96 positive cells and the
new owner keeps the single mutable-global rejection. Preserve both methods, all
97 cases, generated sources, diagnostic fragments, and case-owned lifecycle
sequences. Do not close task 4.7 until every other named split is complete.

Regenerate official current outputs rather than hand-editing generated rows:

- expected cases and product cardinalities;
- current files, methods, assertions, and summary;
- implementation and method-product reconciliation;
- API use;
- boundary, inline-source, and planning records.

Keep historical evidence unchanged. Current internal-method records contain no
Reference Direction rationale that needs owner migration.

## Lifecycle and style requirements

Follow `Documents/UnitTest/UnitTest.md`:

- keep both complete test flows inside their `TEST_METHOD` or directly visible
  class-private helpers;
- no file-level `RunXxxSection` forwarding wrapper;
- no anonymous namespace or file-level CQTest assertion alias;
- restore `public:` before each method;
- keep includes outside the unit-test body gate;
- align CQTest terminators at file scope;
- use self-contained, unity-safe includes;
- preserve current Allman-generated AngelScript formatting;
- no class-owned engine, lifecycle hook, add-on, `FAngelscriptEngine`,
  UObject/world fixture, or debugger integration.

Use `apply_patch` for edits. Do not build, run UE Automation, commit, or touch
unrelated files.

## Static verification

Before reporting complete:

- exactly two unique classes, two methods, and two products remain;
- both frozen method hashes match;
- post-split full-file hashes are recorded;
- exact product cardinalities remain 96 and 1, with 97 unique IDs;
- global catalog remains 317 products / 46,140 unique IDs unless an explicitly
  reviewed concurrent change alters that baseline;
- assertion distribution remains 33 + 4 and no assertion text/hash disappears;
- source-print distribution is 1 + 1 and the registry has both exact rows;
- each file has one engine Create/Destroy call-site pair;
- positive context/module/native-state cleanup and rejection failed-shell
  cleanup remain exact;
- retained owner contains no rejection method/product;
- rejection owner contains no positive direction tables, generators, callbacks,
  runtime or identity oracles;
- no new shared header or expanded shared surface exists;
- class names and helper ownership are unity/ODR safe;
- current quality CSV exactly matches the physical SDK source tree;
- catalog, source ownership, registry, API, predecessor, internal, boundary,
  inline-AS, planning, strict OpenSpec, whitespace/EOF, and current-record
  checks pass;
- remaining split count decreases by one from the stable post-Expression value.

If any command fails because of an incorrect host, parameter, path, or input,
correct and record the tooling problem; do not reinterpret rejected output as
source evidence.

## Report

Write:

`.superpowers/sdd/reference-direction-semantic-split-report.md`

Report exact files, pre/post counts, hashes, case/assertion/source-print and
lifecycle preservation, static commands/results, encountered problems, and
confirmation that no build, UE Automation, commit, or unrelated edit occurred.
