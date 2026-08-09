# Reference direction semantic-owner split report

Status: `DONE`

## Result

The current-fork mutable-global rejection was moved out of the positive
reference-direction owner without changing either registered method body,
product, generated source, case ID, diagnostic, assertion, runtime oracle,
lifecycle, cleanup, or recovery path.

Pre-edit:

- `Language/References/AngelscriptNativeReferenceDirectionTests.cpp`
- 1,068 lines / 27,376 bytes
- SHA-256:
  `ae609c84ca6b6750d2a71a3d3991ad050889c46d62d90a51eb5d84a793b29474`
- 1 class / 2 methods / 2 products
- 97 cases: 96 positive + 1 current-fork rejection
- 37 assertions: 33 positive-owner/helper sites + 4 rejection sites
- 1 shared source-print site
- 2 engine Create/Destroy call-site pairs

Post-edit:

| Owner | Class | Method | Product | Cases | Assertions | Print sites | Lines |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| `Language/References/AngelscriptNativeReferenceDirectionTests.cpp` | `FReferenceDirectionTests` | `DirectionsByAliasAndNullState` | `LANG-REF-DIRECTION` | 96 | 33 | 1 | 993 |
| `Language/References/AngelscriptNativeReferenceDirectionMutableGlobalRejectionTests.cpp` | `FReferenceDirectionMutableGlobalRejectionTests` | `CurrentForkRejectsMutableScriptGlobals` | `LANG-REF-DIRECTION-FORK-GLOBAL` | 1 | 4 | 1 | 119 |

Post-split complete-file hashes:

- positive owner:
  `c2cda6c296db62f56d5548b18903c0c2036bd4b0eb00d11eb756a1c1a161b8f3`
- rejection owner:
  `8e9ef8445fb2379319811e2b8a2cef3a389bad27deec2e18a7e9e68ac7d55e06`

Both classes retain:

`Angelscript.TestModule.AngelScriptSDK.Language.References.Direction`

Their class components are unique, so the two registrations and their
class-private `CompileAndReport` copies are unity/ODR safe.

## Preservation evidence

The inclusive-brace method hashes match the frozen baseline exactly:

| Method | Post-split SHA-256 | Result |
| --- | --- | --- |
| `CurrentForkRejectsMutableScriptGlobals` | `226baffa6a4832f01f36a40fb4c53e390996dc2420d00c59a1d9088dedadc0ed` | exact |
| `DirectionsByAliasAndNullState` | `2aa232584475e13691573302c2ce56b23ff087dc0693c0204a55ad6eadb16a64` | exact |

Canonical expansion remains:

- `LANG-REF-DIRECTION`: 96/96
  (`4 directions × 4 null states × 6 alias relations`)
- `LANG-REF-DIRECTION-FORK-GLOBAL`: 1/1
- combined: 97 rows / 97 unique case IDs

The positive owner retains the exact direction → null-state → alias-relation
loop order and all positive-only aliases, types, tables, builders, callbacks,
metadata checks, snapshot/value/identity oracles, execution helpers, native
ownership cleanup, sorted created/destroyed reconciliation, and
`CompileAndReport`.

Its one isolated-engine call site still owns:

- one immediate destroy guard per cell;
- module compilation and exact metadata lookup;
- one context creation;
- entry and clean-recovery prepare/execute/unprepare operations;
- one context release;
- exact module discard;
- `State.ReleaseRetainedNativeObject()`;
- zero-live-object assertion;
- exact constructed/destroyed identity reconciliation.

The rejection owner contains only its two required aliases, its private
`CompileAndReport` copy, and the byte-preserved rejection method. It retains:

- case ID `LANG-REF-DIRECTION-FORK-GLOBAL-MUTABLE`;
- module name `ReferenceDirectionForkMutableGlobal`;
- the mutable global and recovery function with the same Allman source and
  blank line;
- complete source printing before compilation;
- a negative build result;
- diagnostic fragments `must be const` and
  `Mutable global variables are not supported`;
- failed-module discard and exact-name null lookup;
- one case-owned engine Create/Destroy pair;
- zero context creation.

The positive owner contains no rejection method, product, mutable-global
fixture, or fork diagnostic. The rejection owner contains no positive
direction/null/alias table, generator, callback, context execution, snapshot,
runtime, native-identity, or lifecycle oracle.

No new support header was created, and
`AngelscriptNativeReferenceTestSupport.h` was not changed or enlarged.

## Files changed or created

Source:

- retained and narrowed
  `Language/References/AngelscriptNativeReferenceDirectionTests.cpp`
- created
  `Language/References/AngelscriptNativeReferenceDirectionMutableGlobalRejectionTests.cpp`

Authored current records:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`
- `tasks.md`

Officially regenerated current outputs:

- `audits/expected-coverage.csv`
- `audits/product-cardinalities.csv`
- `audits/current-files.csv`
- `audits/current-methods.csv`
- `audits/current-assertions.csv`
- `audits/current-summary.json`
- `audits/implementation-reconciliation.csv`
- `audits/method-product-reconciliation.csv`
- `audits/api-use.csv`
- `audits/predecessor-baseline.csv`
- `audits/internal-method-dispositions.csv`
- `audits/internal-method-reconciliation.csv`
- `audits/boundary-violations.csv`
- `audits/inline-source-baseline.csv`
- `audits/planning-record-violations.csv`

Historical checkpoint evidence was not rewritten.

## Static verification

- `ExpandCoverageProducts.ps1`: PASS, 317 products / 46,140 expected
  cases; Reference Direction remains 96 + 1.
- `ValidateCoverageCatalogs.ps1`: PASS, 317 products / 46,140 cases /
  46,140 unique IDs; both source registry owners and their one print site
  reconcile.
- `ExportCurrentNativeSdkInventory.ps1`: PASS, 262 source files / 688
  methods / 8,141 assertions / 161,858 lines / 301 raw blocks / 674 active
  methods / 14 Disabled methods.
- `ReconcileNativeSdkSource.ps1 -RequireComplete`: PASS, 317 products /
  316 enabled implementations / 1 Disabled implementation / 0 incomplete
  products / 688 methods / 0 unresolved methods.
- `AuditNativeSdkApiUse.ps1 -RequireComplete`: PASS, 365 rows / 357
  observed / 1 contract-covered / 7 deferred / 0 missing / 0 incomplete.
- `ReconcilePredecessorScenarios.ps1 -RequireFinalDisposition`: PASS, all
  222 terminal dispositions checked.
- `FinalizeInternalMethodDispositions.ps1` followed by
  `ReconcileInternalMethods.ps1 -RequireComplete`: PASS, 1,002 final /
  0 pending.
- `AuditNativeSdkBoundaries.ps1 -RequireClean`: PASS, 0 violations.
- `AuditInlineAsFormatting.ps1 -RequireClean`: PASS, 301/301 conforming /
  0 violations.
- `ValidatePlanningRecords.ps1 -RequireClean`: PASS, 0 violations.
- `openspec validate test-as-native-sdk-comprehensive-coverage --strict
  --json`: PASS, 1/1 valid with no issues.
- Focused source scan: PASS, exactly 2 unique classes / 2 methods /
  2 products; both method hashes exact; 37 assertions split 33 + 4; static
  source printing split 1 + 1; both body gates balanced; no lifecycle hooks,
  class-owned engine member, anonymous namespace, file-level CQTest assertion
  alias, add-on, `FAngelscriptEngine`, UObject/world fixture, or debugger
  integration; both classes globally unique; `CompileAndReport` appears once
  per physical owner; positive/rejection responsibilities do not leak across
  files.
- Positive lifecycle scan: PASS, one engine Create/Destroy call-site pair,
  one context creation, two prepare/execute/unprepare paths, one release, one
  discard, retained-native release, zero-live-object check, and exact identity
  reconciliation remain.
- Rejection lifecycle scan: PASS, one engine Create/Destroy call-site pair,
  zero contexts, both diagnostic fragments, one failed-shell discard, and one
  exact-name null lookup remain.
- Current record scan: PASS, 97/97 Reference Direction IDs unique; two exact
  registry rows with print total 2; 262 quality rows / 262 unique current
  source keys / 0 missing / 0 stale.
- Living quality totals: PASS, 222 case-owned / 9 direct-engine / 8 immutable
  registration / 22 no-engine / 1 recreation / 0 red; 217 `NotLarge` /
  42 retained / 3 split-required. This change adds one physical source owner
  and one case-owned classification, adds two `NotLarge` owners, and reduces
  remaining required splits from four to three.
- Scoped whitespace/EOF and authored-text scan: PASS, zero trailing
  whitespace, final newlines present, and no newly authored occurrence of the
  user-forbidden generic term.

## Problems and constraints

No brief-to-current-source mismatch was found. The pre-edit length, byte size,
full-file hash, method identities, product identities, assertion distribution,
and lifecycle shape all matched the frozen brief.

The split was applied as one size-bounded `apply_patch`, and all subsequent
official and focused static checks passed on their first authoritative
invocation. No rejected static result was reinterpreted as evidence.

No build was run. No UE Automation test was run. No commit was created. No
unrelated source, support header, or OpenSpec change was edited.

## Independent review and focused record repair

Independent two-stage review first returned source/code-quality PASS but found
two stale rows in the current Language assertion-depth handoff:

- `LANG-REF-DIRECTION-FORK-GLOBAL` still named the retired aggregate
  file/class and its old source range;
- `LANG-REF-DIRECTION` retained the pre-split method range `1040-1068`, beyond
  the retained file's new 993-line EOF.

Both current rows were repaired without changing source or historical
checkpoints. The rejection row now names
`AngelscriptNativeReferenceDirectionMutableGlobalRejectionTests.cpp`,
`FReferenceDirectionMutableGlobalRejectionTests`, and evidence `17-116`. The
positive row retains its owner and now cites the complete current class/helper
range `7-991`.

Focused re-review resolves both paths and ranges against physical source,
reproduces both frozen method hashes and both post-split full-file hashes, and
reconfirms 97 unique cases, 37 assertions, both registry rows, both lifecycles,
262/262 living source keys, and current/historical separation. Final verdict:
specification PASS and code-quality PASS with no remaining findings.
