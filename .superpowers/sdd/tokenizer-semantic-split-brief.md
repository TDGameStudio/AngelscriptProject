# Tokenizer semantic-owner split brief

## Scope and frozen baseline

Refactor only:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeTokenizerDeepCoverageTests.cpp`

This is a physical semantic-owner split. Do not change behavior, cases,
assertions, source IDs, generated source, Automation leaf IDs, or the raw
tokenizer API surface.

Frozen current baseline:

- file SHA-256:
  `7e567fcb2a3a64b29fa8f6fae8c88914d95fe2e7e6c65202c94acfda7fd4c5f5`
- 1 class, 12 `TEST_METHOD`s, 12 one-product owners;
- 3,108 exact catalog cases;
- 70 static `ASSERT_THAT` sites;
- 12 static `PrintGeneratedAsSource` sites;
- no engine/module/context lifecycle;
- method-sequence SHA-256:
  `8528ca53fb3e216b4f349fd82bf77c8c2cf08c144b509c0f6984a151368ba4e8`;
- product-sequence SHA-256:
  `8459c2070b996ec3171e4e107d93eab44bbc842f3ec204c0b11b80354875800e`.

Method hashes use the complete outer `{...}` block, LF normalization, trailing
horizontal-whitespace removal per line, whole-block strip, UTF-8, SHA-256:

| Method | SHA-256 |
| --- | --- |
| `TokenTaxonomyCoversActiveKeywordFamilies` | `1e50a16deade5f89ebdfebbb8447d1f5f8bdeae157f12e77bd190c5915607da4` |
| `LongestMatchCoversOperatorPrefixAndSuffixBoundaries` | `ccf746d5299e9d4efdb24125203de726d83687728e28d720601b8250ae884f41` |
| `OperatorOperandSpacingCartesianProduct` | `19a840f72c47e6644dd5b64819ebbfe369f46c81b7147a4d64d8d1204d064b81` |
| `OperatorMalformedRecoveryCartesianProduct` | `bd7f942aa51d9086f02cb1df7372815b8e702ca56464f847b7eae5eb11a495e0` |
| `ContextualWordsRemainIdentifierTokens` | `928a105470ace2ae7afccccb7147e1ec9a56e07d2cb0b013013eb3263262a6ff` |
| `NumericLiteralFormsCoverRadixExponentAndSuffixBoundaries` | `afa1a06ead70616fa5445b3e32d56d1318b2ac13e7228c7f4ef2d252b7a46584` |
| `StringCommentAndWhitespaceBoundariesRemainDistinct` | `93033aef13c439388006dd98a0ced9283f2ca89bbd9dc919b8a125c8ed5faff3` |
| `TextLiteralEscapeAndLineEndingCartesianProduct` | `d2402c38892346b1808ed9d98263d708ca8b03dadda95ef5e3a519d0d0e2e04c` |
| `CommentWhitespaceAndEofCartesianProduct` | `7ad4d1bc2ccbdbee5d6c26ce204fc5e52b0239e4d323bbd92fce61e03c40f092` |
| `NumericSignAndTerminationCartesianProduct` | `b2e0eaa7222afbf053cbd0f483eb6464f4952d2b24ac07724bf78d38ab137818` |
| `NumericMalformedRecoveryCartesianProduct` | `341ca6190d38382906f4b6dc15e3e3bccfafcfcb0af9d258455260777cac3478` |
| `TokenDefinitionsRemainAvailableForPublishedKinds` | `ca7fec0607c1b19b48203e18dfce7c49d45595e45b7a3a9839bdba3032eb0687` |

## Required physical owners

Retire the aggregate `.cpp` and create exactly these five files/classes. Keep
the existing Automation directory
`Angelscript.TestModule.AngelScriptSDK.Frontend.Tokenizer.DeepCoverage` for
every class so all existing leaf IDs remain stable.

### Keyword and contextual identifiers

- File:
  `Frontend/AngelscriptNativeTokenizerKeywordIdentifierDepthTests.cpp`
- Class: `FTokenizerKeywordIdentifierDepthTests`
- Methods/products/cases:
  - `TokenTaxonomyCoversActiveKeywordFamilies` /
    `FRONTEND-TOKEN-TAXONOMY-ACTIVE-KEYWORDS` / 118
  - `ContextualWordsRemainIdentifierTokens` /
    `FRONTEND-TOKEN-CONTEXTUAL-IDENTIFIER-WORDS` / 6
- static print sites: 2; every registry row for this file uses `2`.

### Operators

- File: `Frontend/AngelscriptNativeTokenizerOperatorDepthTests.cpp`
- Class: `FTokenizerOperatorDepthTests`
- Methods/products/cases:
  - `LongestMatchCoversOperatorPrefixAndSuffixBoundaries` /
    `FRONTEND-TOKEN-LONGEST-MATCH-OPERATORS` / 55
  - `OperatorOperandSpacingCartesianProduct` /
    `FRONTEND-TOKEN-OPERATOR-OPERAND-SPACING` / 2,560
  - `OperatorMalformedRecoveryCartesianProduct` /
    `FRONTEND-TOKEN-OPERATOR-MALFORMED-RECOVERY` / 20
- static print sites: 3; every registry row for this file uses `3`.

### Numeric literals

- File: `Frontend/AngelscriptNativeTokenizerNumericDepthTests.cpp`
- Class: `FTokenizerNumericDepthTests`
- Methods/products/cases:
  - `NumericLiteralFormsCoverRadixExponentAndSuffixBoundaries` /
    `FRONTEND-TOKEN-NUMERIC-BOUNDARIES` / 26
  - `NumericSignAndTerminationCartesianProduct` /
    `FRONTEND-TOKEN-NUMERIC-SIGN-TERMINATION` / 160
  - `NumericMalformedRecoveryCartesianProduct` /
    `FRONTEND-TOKEN-NUMERIC-MALFORMED-RECOVERY` / 12
- static print sites: 3; every registry row for this file uses `3`.

### Text, comments, whitespace, and EOF

- File:
  `Frontend/AngelscriptNativeTokenizerTextCommentWhitespaceDepthTests.cpp`
- Class: `FTokenizerTextCommentWhitespaceDepthTests`
- Methods/products/cases:
  - `StringCommentAndWhitespaceBoundariesRemainDistinct` /
    `FRONTEND-TOKEN-TEXT-COMMENT-WHITESPACE-BOUNDARIES` / 23
  - `TextLiteralEscapeAndLineEndingCartesianProduct` /
    `FRONTEND-TOKEN-TEXT-ESCAPE-LINE-ENDINGS` / 60
  - `CommentWhitespaceAndEofCartesianProduct` /
    `FRONTEND-TOKEN-COMMENT-WHITESPACE-EOF` / 48
- static print sites: 3; every registry row for this file uses `3`.

### Published token definitions

- File: `Frontend/AngelscriptNativeTokenizerDefinitionDepthTests.cpp`
- Class: `FTokenizerDefinitionDepthTests`
- Method/product/cases:
  - `TokenDefinitionsRemainAvailableForPublishedKinds` /
    `FRONTEND-TOKEN-DEFINITIONS` / 20
- static print sites: 1; its registry row uses `1`.

Totals after the move must remain exactly 5 classes, 12 methods, 12 products,
3,108 cases, 70 assertion sites, and 12 static print sites.

## Required helper boundary

Create:

`Support/AngelscriptNativeTokenizerTestSupport.h`

It contains only these genuinely cross-family definitions in
`AngelscriptNativeTestSupport`, with header-safe types/`inline` functions:

- `FTokenCase`
- `FTokenObservation`
- `ReadToken`
- `AppendCommentedCase`

Keep family-only structures class-private:

- operator: `FOperatorOperandCase`, `FOperatorSymbolCase`,
  `FOperatorSpacingCase`, `FOperatorRecoveryCase`, `FRecoveryTailCase`;
- numeric: `FNumericLiteralCase`, `FNumericSignCase`,
  `FNumericTerminationCase`, `FMalformedNumericCase`,
  `BuildNumericSignTerminationSource`;
- text/comment/whitespace: `FTextLiteralCase`, `FTextBoundaryCase`,
  `FCommentWhitespaceFamilyCase`, `FCommentWhitespacePayloadCase`,
  `FCommentWhitespaceBoundaryCase`.

The definition class does not include the new tokenizer support unless it
actually uses one of those definitions. Restore `public:` before methods after
any class-private helper block. Do not copy same-named file-scope helpers into
multiple `.cpp` files.

## Preservation and style requirements

- Preserve every `TEST_METHOD` body byte-for-byte so all 12 frozen hashes
  still match.
- Preserve product IDs, case IDs, source tables/order, source/module log
  names, formatting, assertions, token-length/type/text oracles, malformed
  recovery behavior, and generator registry descriptions.
- Preserve existing Automation leaf IDs by keeping the Automation directory
  and method names unchanged.
- Each `.cpp` must have a correct `WITH_ANGELSCRIPT_UNITTESTS` body gate.
- All five files remain raw SDK and engine-free. Do not add
  `FNativeTestEngine`, modules, contexts, add-ons, `FAngelscriptEngine`, UE
  object/world fixtures, or editor/debugger dependencies.
- Follow `Documents/UnitTest/UnitTest.md`; helpers hide mechanics, not the
  main method flow.
- Includes must be self-contained and unity-safe, not accidentally supplied
  by another `.cpp`.
- Do not rename existing generated-source IDs or change the legacy Automation
  directory string during this physical move.
- Use `apply_patch` for every edit.
- Do not build, run UE Automation, commit, or touch unrelated files.

## Living records

Update authored current records:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`
- task 4.7 in `tasks.md`

The current quality CSV must retire the aggregate row and add five
`CompliantNoRawEngineFixture` / `NotLarge` / `None.` rows with current evidence.
Because Parser is now already split, derive final absolute counts from current
source instead of applying stale arithmetic. Tokenizer alone changes one
physical owner into five and reduces the remaining required split count by
one.

Regenerate canonical current outputs with the official scripts; do not
hand-edit generated inventory/reconciliation rows. Preserve historical
snapshots with old paths.

## Static verification

Before reporting complete:

- old aggregate absent; five target `.cpp` and one support header present;
- exact 12 method hashes match this brief;
- exact method/product manifest and 3,108 cardinality preserved;
- 70 assertion sites and static print distribution `2,3,3,3,1` preserved;
- five class names globally unique and Automation leaf IDs unchanged;
- shared header exports only the required four definitions;
- no raw engine/module/context lifecycle introduced;
- catalog, generated-source registry, current inventory/source reconciliation,
  internal-method, predecessor, API, boundary, inline-AS, planning, strict
  OpenSpec, unity/global-symbol, whitespace/EOF, and current quality-record
  checks pass;
- remaining split count decreases from 6 to 5.

If an official script initially fails due to host/runtime or invocation misuse,
correct the invocation and record the tool issue. Do not hide a real source or
record failure.

## Report

Write:

`.superpowers/sdd/tokenizer-semantic-split-report.md`

Return status (`DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED`),
files changed, pre/post counts, preservation hashes/evidence, exact static
results, discovered problems, and explicit confirmation that no build, UE
test, commit, or unrelated edit occurred.
