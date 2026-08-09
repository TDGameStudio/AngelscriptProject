# Expression evaluation semantic-owner split report

Status: `DONE_WITH_CONCERNS`

## Result

The mixed expression-evaluation aggregate was retired and replaced by the two
required semantic owners plus one narrow instrumentation header. The complete
registered method bodies, product IDs, 612 generated case IDs, generated
source builders, independent result/marker oracles, diagnostics, assertions,
case-owned lifecycles, cleanup, and Automation directory were preserved.

Pre-edit:

- `Language/Expressions/AngelscriptNativeExpressionEvaluationTests.cpp`
- SHA-256
  `b743ffc8915b338408cbb16b3c3d326cb0531a143bc15872f21884bfcd68eb81`
- 1 owner / 1 class / 2 methods / 2 products / 612 cases / 54
  `ASSERT_THAT` sites / 2 `PrintGeneratedAsSource` sites
- 2 engine Create/Destroy pairs, 2 context
  Create/Unprepare/Release paths, and 2 discard/null-lookup paths

Post-edit:

| Owner | Class | Method | Product | Cases | Assertions | Print sites | Lines |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: |
| `Language/Expressions/AngelscriptNativeLazyExpressionEvaluationTests.cpp` | `FLazyExpressionEvaluationTests` | `LazyFormsBySelectorOutcomeAndShape` | `LANG-EXPR-LAZY-EVALUATION` | 72 | 27 | 1 | 537 |
| `Language/Expressions/AngelscriptNativeEagerExpressionOrderTests.cpp` | `FEagerExpressionOrderTests` | `CompositionsByCountOutcomeAndSourceShape` | `LANG-EXPR-EVAL-ORDER` | 540 | 27 | 1 | 859 |

The new files have these complete-file hashes:

- lazy owner:
  `81369d84547ae0b3f255cc689f667a08b1240a73b884ddbc5572b5026e61366d`
- eager owner:
  `46eb9a47ba5f43cc112cea061fea8f9563837c066a775a9474d9af961c4d3cb0`
- shared header:
  `94df25b08c44f1c70c282105f01297f21badeb2495028bcd5bceff8149aac6ec`

Both classes retain:

`Angelscript.TestModule.AngelScriptSDK.Language.Expressions.Evaluation`

The class portions are intentionally unique, so the two registrations remain
unity-safe.

## Preservation evidence

The inclusive-brace method hashes match the frozen baseline exactly:

| Method | Post-split SHA-256 | Result |
| --- | --- | --- |
| `LazyFormsBySelectorOutcomeAndShape` | `8cec00ff3981cdee207db1dc27740ebbeb19e535f4458b454236a0f72b0b54b2` | exact |
| `CompositionsByCountOutcomeAndSourceShape` | `7701e1000dae1f1ec27ac6c1e75014126f46f87a798727784e70a90aeb4700aa` | exact |

The newline-joined method sequence remains:

`a3bd9a46fa58ed6dbc43ade3270313ece3d2cfd83a33fa51db70095466e1e517`

The newline-joined product sequence remains:

`dc9ff22e92ed33d2884562c45cb273c45908f0242d15a6237824a71346229738`

Canonical product expansion proves:

- lazy:
  `3 forms × 3 outcomes × 2 selectors × 4 source shapes = 72`
- eager:
  `9 compositions × 3 operand counts × 4 outcomes × 5 source shapes = 540`
- combined: 612 rows / 612 unique case IDs

Each owner contains exactly one static full-source print site. The registry now
has one lazy row and one eager row, each with `PrintSites=1`; the static total
remains 2 and the generated report count remains 612.

Each owner independently retains:

- one local `FNativeTestEngine`;
- one immediate `ON_SCOPE_EXIT` destroy guard;
- all four expression callback registrations;
- one context Create/Unprepare/Release path;
- one module discard and exact-name null lookup;
- per-cell recorder/lifecycle/message reset;
- the clean same-context follow-up returning 89 or 137.

The shared header exports only these eight required top-level definitions:

- `ExpressionEvaluationRecorderUserDataSlot`
- `FExpressionEvaluationRecorder`
- `GetActiveExpressionEvaluationRecorder`
- `RecordExpressionBool`
- `RecordExpressionInt`
- `RecordEagerStage`
- `CompleteEagerBoundary`
- `RegisterExpressionEvaluationFunctions`

All shared functions are `inline`, the slot is `inline constexpr`, and the
header contains no CQTest registration, product marker, generated-source
printing, generator, expected-result helper, marker oracle, or test flow.
The lazy owner contains no eager table/builder/oracle and the eager owner
contains no lazy table/builder/oracle.

## Files changed or created

Source:

- retired
  `Language/Expressions/AngelscriptNativeExpressionEvaluationTests.cpp`
- created
  `Language/Expressions/AngelscriptNativeLazyExpressionEvaluationTests.cpp`
- created
  `Language/Expressions/AngelscriptNativeEagerExpressionOrderTests.cpp`
- created
  `Support/AngelscriptNativeExpressionEvaluationTestSupport.h`

Authored current records:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `coverage/expressions.md`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`
- `tasks.md`
- `audits/predecessor-dispositions.csv`
- `handoffs/predecessor-terminal-disposition-review.csv`

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

Historical checkpoint records retaining the former aggregate path were not
rewritten.

## Static verification

- `ExpandCoverageProducts.ps1`: PASS, 317 products / 46,140 expected
  cases; expression products remain 72 + 540.
- `ValidateCoverageCatalogs.ps1`: PASS, 317 products / 46,140 cases /
  46,140 unique IDs; registry owner, generator, and print-site checks pass.
- `ExportCurrentNativeSdkInventory.ps1`: PASS, 261 source files / 688
  methods / 8,141 assertions / 161,814 lines / 301 raw blocks / 674 active
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
- Focused source scan: PASS, aggregate absent; exact 2 unique classes /
  2 methods / 2 products; method/product sequence hashes exact; 54 assertions
  split 27 + 27; prints split 1 + 1; required engine/context/module cleanup
  split 1 + 1; no class-owned engine or CQTest lifecycle hook; both body gates
  correct; both class names globally unique; shared header has exactly the
  eight required top-level definitions and zero forbidden test/generator
  responsibilities; no cross-owner helper leakage.
- Current-record scan: PASS, 612/612 expression case IDs unique; zero stale
  aggregate path in current records; 261 quality rows / 261 unique current
  source keys / 0 missing / 0 stale.
- Living quality totals: PASS, 221 case-owned / 9 direct-engine / 8 immutable
  registration / 22 no-engine / 1 recreation / 0 red; 215 `NotLarge` /
  42 retained / 4 split-required. Expression changes one current source owner
  into two, increases case-owned by one, increases `NotLarge` by two, and
  decreases remaining required splits from five to four.
- Scoped whitespace/EOF scan: PASS, zero trailing-whitespace findings and a
  final newline in all three new source files and all eight authored current
  records.

## Problems and corrections

The first generated multi-file `apply_patch` was transported through a shell
output channel whose direct result was truncated. The truncated patch applied
the support header and only part of the intended source payload while also
retiring the aggregate. This was a tool-transport problem, not a source or
brief mismatch.

The exact 51,340-byte pre-delete content remained available in the immutable
`apply_patch` event record. Both owners were regenerated from that frozen
content with separate, size-bounded patches. The two complete method hashes,
method/product sequence hashes, cardinalities, static responsibilities, and
all current audits were then recomputed; no source was guessed or weakened to
recover from the truncation.

The first focused method extractor attempted full lexical brace parsing and
failed on generated C++ source-string syntax. The authoritative check instead
used the frozen known complete method spans and the specified normalization;
both hashes matched exactly. Two later combined PowerShell structural scans
also exited before producing evidence because of command composition/argument
errors; the same checks were separated and passed.

The first predecessor and internal reconciliation invocations omitted their
strict switches/finalized input. They produced non-authoritative intermediate
summaries (`FinalDispositionChecked=False` and a pending raw inventory).
They were immediately corrected by running predecessor reconciliation with
`-RequireFinalDisposition`, regenerating the final internal dispositions, and
running internal reconciliation with that final input and `-RequireComplete`.
The canonical outputs now report 222 terminal predecessor dispositions and
1,002 final internal rows with zero pending.

No brief-to-source baseline mismatch was found. No build was run. No UE
Automation test was run. No commit was created. No unrelated source or
OpenSpec change was edited.
