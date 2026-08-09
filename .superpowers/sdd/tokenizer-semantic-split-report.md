# Tokenizer semantic-owner split report

Status: `DONE_WITH_CONCERNS`

## Result

The raw-SDK tokenizer aggregate was replaced by the five required semantic
owners without changing the twelve `TEST_METHOD` bodies, product IDs, case
cardinalities, generated source IDs/content, assertions, raw-token oracles, or
Automation leaf IDs. The shared header exports only `FTokenCase`,
`FTokenObservation`, `ReadToken`, and `AppendCommentedCase`; operator, numeric,
and text/comment/whitespace structures remain private to their one owner.

Pre-edit:

- `Frontend/AngelscriptNativeTokenizerDeepCoverageTests.cpp`
- SHA-256
  `7e567fcb2a3a64b29fa8f6fae8c88914d95fe2e7e6c65202c94acfda7fd4c5f5`
- 1 owner / 1 class / 12 methods / 12 products / 3,108 cases / 70
  `ASSERT_THAT` sites / 12 `PrintGeneratedAsSource` sites.

Post-edit:

| Owner | Class | Methods | Products | Cases | Print sites | Lines |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| `Frontend/AngelscriptNativeTokenizerKeywordIdentifierDepthTests.cpp` | `FTokenizerKeywordIdentifierDepthTests` | 2 | 2 | 124 | 2 | 191 |
| `Frontend/AngelscriptNativeTokenizerOperatorDepthTests.cpp` | `FTokenizerOperatorDepthTests` | 3 | 3 | 2,635 | 3 | 440 |
| `Frontend/AngelscriptNativeTokenizerNumericDepthTests.cpp` | `FTokenizerNumericDepthTests` | 3 | 3 | 198 | 3 | 309 |
| `Frontend/AngelscriptNativeTokenizerTextCommentWhitespaceDepthTests.cpp` | `FTokenizerTextCommentWhitespaceDepthTests` | 3 | 3 | 131 | 3 | 386 |
| `Frontend/AngelscriptNativeTokenizerDefinitionDepthTests.cpp` | `FTokenizerDefinitionDepthTests` | 1 | 1 | 20 | 1 | 75 |

Totals remain 5 owners / 5 classes / 12 methods / 12 products / 3,108
cases / 70 assertions / 12 print sites. Every class still registers
`Angelscript.TestModule.AngelScriptSDK.Frontend.Tokenizer.DeepCoverage`;
therefore the twelve prefix-plus-method Automation leaf IDs are unchanged.

## Preservation evidence

The canonical newline-joined method sequence still hashes to
`8528ca53fb3e216b4f349fd82bf77c8c2cf08c144b509c0f6984a151368ba4e8`;
the product sequence still hashes to
`8459c2070b996ec3171e4e107d93eab44bbc842f3ec204c0b11b80354875800e`.
A lexical, brace-aware scan produced these complete outer-block hashes:

| Method | Post-split SHA-256 | Frozen comparison |
| --- | --- | --- |
| `TokenTaxonomyCoversActiveKeywordFamilies` | `1e50a16deade5f89ebdfebbb8447d1f5f8bdeae157f12e77bd190c5915607da4` | exact after correcting the brief transcription defect described below |
| `LongestMatchCoversOperatorPrefixAndSuffixBoundaries` | `ccf746d5299e9d4efdb24125203de726d83687728e28d720601b8250ae884f41` | exact |
| `OperatorOperandSpacingCartesianProduct` | `19a840f72c47e6644dd5b64819ebbfe369f46c81b7147a4d64d8d1204d064b81` | exact |
| `OperatorMalformedRecoveryCartesianProduct` | `bd7f942aa51d9086f02cb1df7372815b8e702ca56464f847b7eae5eb11a495e0` | exact |
| `ContextualWordsRemainIdentifierTokens` | `928a105470ace2ae7afccccb7147e1ec9a56e07d2cb0b013013eb3263262a6ff` | exact |
| `NumericLiteralFormsCoverRadixExponentAndSuffixBoundaries` | `afa1a06ead70616fa5445b3e32d56d1318b2ac13e7228c7f4ef2d252b7a46584` | exact |
| `StringCommentAndWhitespaceBoundariesRemainDistinct` | `93033aef13c439388006dd98a0ced9283f2ca89bbd9dc919b8a125c8ed5faff3` | exact |
| `TextLiteralEscapeAndLineEndingCartesianProduct` | `d2402c38892346b1808ed9d98263d708ca8b03dadda95ef5e3a519d0d0e2e04c` | exact |
| `CommentWhitespaceAndEofCartesianProduct` | `7ad4d1bc2ccbdbee5d6c26ce204fc5e52b0239e4d323bbd92fce61e03c40f092` | exact |
| `NumericSignAndTerminationCartesianProduct` | `b2e0eaa7222afbf053cbd0f483eb6464f4952d2b24ac07724bf78d38ab137818` | exact |
| `NumericMalformedRecoveryCartesianProduct` | `341ca6190d38382906f4b6dc15e3e3bccfafcfcb0af9d258455260777cac3478` | exact |
| `TokenDefinitionsRemainAvailableForPublishedKinds` | `ca7fec0607c1b19b48203e18dfce7c49d45595e45b7a3a9839bdba3032eb0687` | exact |

Catalog expansion independently confirms the frozen product cardinalities:
118 + 55 + 2,560 + 20 + 6 + 26 + 23 + 60 + 48 + 160 + 12 + 20 =
3,108.

## Files changed or created

Source:

- Retired
  `Frontend/AngelscriptNativeTokenizerDeepCoverageTests.cpp`.
- Created the five `Frontend/AngelscriptNativeTokenizer*DepthTests.cpp`
  owners listed above.
- Created
  `Support/AngelscriptNativeTokenizerTestSupport.h`.

Authored living records:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`
- `tasks.md`

Task-local records:

- `.superpowers/sdd/tokenizer-semantic-split-brief.md` (corrected one
  malformed frozen SHA-256 transcription after independent recomputation)
- `.superpowers/sdd/tokenizer-semantic-split-report.md`

Officially regenerated current outputs:

- `audits/expected-coverage.csv`
- `audits/product-cardinalities.csv`
- `audits/implementation-reconciliation.csv`
- `audits/method-product-reconciliation.csv`
- `audits/current-files.csv`
- `audits/current-methods.csv`
- `audits/current-assertions.csv`
- `audits/current-summary.json`
- `audits/internal-method-reconciliation.csv`
- `audits/predecessor-baseline.csv`
- `audits/api-use.csv`
- `audits/boundary-violations.csv`
- `audits/inline-source-baseline.csv`
- `audits/planning-record-violations.csv`

Historical snapshots retaining the former path were not rewritten.

## Static verification

- `ValidateCoverageCatalogs.ps1`: PASS, 317 products / 46,140 cases /
  46,140 unique IDs; all twelve tokenizer registry owners and per-file print
  counts reconcile.
- `ReconcileNativeSdkSource.ps1 -RequireComplete`: PASS, 317 products /
  688 methods / 0 incomplete / 0 unresolved.
- `ExportCurrentNativeSdkInventory.ps1` under `pwsh`: PASS, 260 source
  files / 688 methods / 8,141 assertions / 301 raw blocks / 674 active
  methods.
- `ReconcileInternalMethods.ps1` with the required final input: PASS,
  1,002 final / 0 pending.
- `ReconcilePredecessorScenarios.ps1 -RequireFinalDisposition`: PASS,
  all 222 terminal dispositions checked.
- `AuditNativeSdkApiUse.ps1 -RequireComplete` under `pwsh`: PASS, 365
  rows / 357 observed / 1 contract-covered / 7 deferred / 0 missing /
  0 incomplete.
- `AuditNativeSdkBoundaries.ps1 -RequireClean`: PASS, 0 violations.
- `AuditInlineAsFormatting.ps1 -RequireClean`: PASS, 301/301 conforming /
  0 violations; the two registered escaped exact inputs remain explicit.
- `ValidatePlanningRecords.ps1 -RequireClean`: PASS, 0 violations.
- `openspec validate test-as-native-sdk-comprehensive-coverage --strict
  --json`: PASS, 1/1 valid with no issues.
- Focused structural scan: PASS, old aggregate absent; exact 5 classes / 12
  methods / 12 products / 3,108 cases / 70 assertions; print distribution
  `2,3,3,3,1`; five globally unique classes; five correct body gates; no
  raw engine/module/context or UE integration; no `.cpp` file-scope helper
  added; shared header definitions exactly
  `FTokenCase,FTokenObservation,ReadToken,AppendCommentedCase`; family-only
  types occur only in their one class.
- Living quality reconciliation: PASS, 260 CSV rows / 260 unique current
  source keys; lifecycle counts 220 case-owned / 9 direct / 8 immutable /
  22 no-engine / 1 recreation / 0 red; large-file counts 213 `NotLarge` /
  42 retained / 5 split. The required split count decreases from 6 to 5.
- Scoped whitespace/EOF scan: PASS, 0 trailing-whitespace errors and a final
  newline for all five new `.cpp` files, the new header, and the five authored
  living records.

## Corrected planning-data defect and tool corrections

The original brief listed
`1e50a16deade5f89ebdfbb8447d1f5f8bdeae157f12e77bd190c5915607da4`
for `TokenTaxonomyCoversActiveKeywordFamilies`. That string has only 62
hexadecimal characters and cannot be a SHA-256 value; it is missing `eb`
after `...ebdf`. The pre-edit complete-file hash matched the frozen baseline,
the method was copied directly without body edits, the method/product
sequence hashes match, and its actual deterministic 64-character hash is
`1e50a16deade5f89ebdfebbb8447d1f5f8bdeae157f12e77bd190c5915607da4`.
The brief row was corrected to that independently reproduced value with
`apply_patch`; the method source was not changed to accommodate the bad
planning datum. This corrected planning-data defect is retained as the reason
for `DONE_WITH_CONCERNS`.

The first inventory-export invocation used Windows PowerShell 5.1 and failed
before export because that runtime lacks `SHA256.HashData`; the authoritative
rerun used `pwsh` and passed. A combined audit invocation and one standalone
Windows PowerShell API audit exceeded the command window without an
authoritative result; the API, boundary, inline, and planning audits were
rerun separately under `pwsh` and all passed. No repository row was hand
edited to mask these invocation problems.

No build was run. No UE Automation test was run. No commit was created. No
unrelated or parser source was edited.
