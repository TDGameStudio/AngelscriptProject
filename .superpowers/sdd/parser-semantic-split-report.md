# Parser semantic-owner split report

Status: `DONE`

## Result

The raw-SDK parser aggregate was split by semantic/failure ownership without
changing any registered class name, `TEST_METHOD` name, Automation path,
product ID, generated case/source literal, source-reporting call, assertion,
diagnostic oracle, parser reset/recovery sequence, cleanup, or raw-engine
Create/Destroy ordering.

Pre-edit source:

- `Frontend/AngelscriptNativeParserCartesianDepthTests.cpp`
- 1 physical owner, 1,276 lines, 9 methods, 9 products, 11
  `PrintGeneratedAsSource` call sites, 8 case-owned engine lifecycles.
- Complete-file SHA-256:
  `D7B8F330B4A622ED3E667AF112F3D2BF78D37379A78426A8EA0AD64E3A207813`.

Post-edit owners:

| Owner | Methods | Products | Print sites | Engine lifecycles | Lines |
| --- | ---: | ---: | ---: | ---: | ---: |
| `Frontend/AngelscriptNativeParserCartesianDepthTests.cpp` | 5 | 5 | 7 | 5 | 735 |
| `Frontend/AngelscriptNativeScriptNodeCartesianDepthTests.cpp` | 2 | 2 | 2 | 2 | 293 |
| `Frontend/AngelscriptNativeScriptCodePositionTests.cpp` | 1 | 1 | 1 | 0 | 94 |
| `Frontend/AngelscriptNativeParserSourceRecoveryTests.cpp` | 1 | 1 | 1 | 1 | 129 |

`Support/AngelscriptNativeParserDepthTestSupport.h` contains exactly the three
cross-owner helpers `ParseScriptCase`, `ReleaseParserCase`, and
`ValidateSiblingLinks`. Node-only sibling-count, histogram, and nested-source
helpers remain local to the unity-unique
`TParserScriptNodeDepthTestSupport`. The ScriptCode owner remains value-owned
and engine-free.

## Preservation evidence

A deterministic lexical, brace-aware scan hashed each complete method body
from its opening through matching closing brace while ignoring braces in
strings, character literals, and comments. Every post-split body hash and byte
count is byte-for-byte identical to its pre-edit value:

| Class / method | Product | Body bytes | Pre/post SHA-256 |
| --- | --- | ---: | --- |
| `FParserCartesianDepthTests::DeclarationFamiliesRetainNodeKinds` | `FRONTEND-PARSER-DECLARATION-FAMILIES` | 2,395 | `6C038683C7BA76F6D321C9CEAC3C349821D04C05BFCD898A15F5EEC26F09BC0B` |
| `FParserFunctionCartesianDepthTests::FunctionParameterBodyAndLineEndingCartesianProduct` | `FRONTEND-PARSER-FUNCTION-PARAMETER-BODY-LINE-ENDINGS` | 3,943 | `6FCA6D44303659C1B626C1829FF85C857C951A0DEF485567BF534D2CB75ED269` |
| `FParserExpressionGroupingDepthTests::ExpressionOperatorGroupingCartesianProduct` | `FRONTEND-PARSER-EXPRESSION-OPERATOR-GROUPING` | 3,608 | `B746E4AF4E5DC74B69133DF2096C9EAE688FC3A0DC1B71F99EA86B4993CBD67E` |
| `FParserSemanticExpressionDepthTests::SemanticExpressionShapesByPlacement` | `FRONTEND-PARSER-SEMANTIC-EXPRESSION-PLACEMENT` | 5,651 | `5714462D0689950B4CA8749112F7B866C59530ABD04E0B1B283BEDB742726352` |
| `FParserNodeNestingDepthTests::NodeDeepNestingAndCopyCartesianProduct` | `FRONTEND-NODE-DEEP-NESTING-COPY` | 3,805 | `318518B2CEA5A25D1F3657D48F1A911A5A261B5053FC3418AD6021F713B45A7E` |
| `FParserScriptCodePositionTests::ScriptCodeRowColumnCartesianProduct` | `FRONTEND-SCRIPT-CODE-ROW-COLUMN` | 2,471 | `9907B2E4D38FBFDF0F54878CD57314BB5716AA3B6612AC1D30AE9D6FA7A55054` |
| `FParserExpressionStatementDepthTests::ExpressionAndStatementFamiliesRetainRoots` | `FRONTEND-PARSER-EXPRESSION-STATEMENT-FAMILIES` | 4,863 | `81A3CDDE18289B86AFB876F9C7E660BDB754C084B69760754BEADE7B445A62D6` |
| `FParserNodeTraversalDepthTests::NodeTraversalAndCopyPreserveStructure` | `FRONTEND-NODE-TRAVERSAL-COPY` | 3,265 | `143C578CF98FBE6366AC147F1B8A8EA296F3076753406D45A31F0024A291D663` |
| `FParserSourceRecoveryDepthTests::SourcePositionsAndParserRecoveryRemainStable` | `FRONTEND-SOURCE-POSITIONS-RECOVERY` | 4,704 | `0A2043EFEE50EE7E7A51D758548604DD3717D38270ED6D5A8DCF40CE6D0CB520` |

All nine classes still register
`Angelscript.TestModule.AngelScriptSDK.Frontend.ParserCartesianDepth`.
Catalog/source reconciliation independently confirms their exact
class/method/product ownership and all 46,140 generated case IDs.

## Files changed or created

Source:

- Modified
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeParserCartesianDepthTests.cpp`.
- Created
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeScriptNodeCartesianDepthTests.cpp`.
- Created
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeScriptCodePositionTests.cpp`.
- Created
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeParserSourceRecoveryTests.cpp`.
- Created
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Support/AngelscriptNativeParserDepthTestSupport.h`.

Living records:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`
- `tasks.md`

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

This report was created at
`.superpowers/sdd/parser-semantic-split-report.md`.

## Static verification

- `ValidateCoverageCatalogs.ps1 -ChangeRoot openspec/changes/test-as-native-sdk-comprehensive-coverage`:
  PASS, 317 products / 46,140 cases / 46,140 unique IDs.
- `ReconcileNativeSdkSource.ps1 -ProjectRoot D:/Workspace/AngelscriptProject -RequireComplete`:
  PASS, 317 products / 688 methods / 0 incomplete / 0 unresolved.
- Generated-source registry reconciliation: PASS; resulting owner print
  counts are exactly 7 across five parser rows, 2 across two ScriptNode rows,
  1 ScriptCode row, and 1 recovery row.
- `ReconcileInternalMethods.ps1 -InputPath
  audits/internal-method-dispositions.csv -OutputPath
  audits/internal-method-reconciliation.csv -RequireComplete`: PASS,
  1,002 final / 0 pending.
- `ReconcilePredecessorScenarios.ps1 -DispositionPath
  audits/predecessor-dispositions.csv -RequireFinalDisposition`: PASS,
  222 terminal dispositions checked.
- `AuditNativeSdkApiUse.ps1 -RequireComplete`: PASS, 365 rows / 0
  incomplete.
- `AuditNativeSdkBoundaries.ps1 -RequireClean`: PASS, 0 violations.
- `AuditInlineAsFormatting.ps1 -RequireClean`: PASS, 301/301 conforming /
  0 violations.
- Unity-oriented scan: PASS; 0 new `.cpp` file-scope function definitions,
  0 duplicate local support types, 0 duplicate registered classes, guarded
  shared header, and exactly the required three shared helpers.
- Scoped whitespace scan: PASS for all 10 manually edited source/record files;
  per-new-file scans report 0 trailing whitespace and a final newline for all
  three new `.cpp` files and the new header.
- `ValidatePlanningRecords.ps1 -ProjectRoot
  D:/Workspace/AngelscriptProject -RequireClean`: PASS, 0 violations.
- `openspec validate test-as-native-sdk-comprehensive-coverage --strict
  --json`: PASS, 1/1 valid with no issues.
- `ExportCurrentNativeSdkInventory.ps1`: 256 source files / 688 methods /
  8,141 assertions. The living quality CSV is exactly 256/256 with no missing
  or stale paths; all four parser-owner line/method shapes agree and
  `SplitRequiredMixedResponsibilities` decreases from 7 to 6.

Tool problem: the first internal-method invocation omitted `-InputPath` and
therefore used the script's raw 1,002-row inventory, reporting all rows
unresolved. This is the already documented default-input pitfall, not a source
failure. The invocation was corrected to
`audits/internal-method-dispositions.csv`; the authoritative rerun is 1,002
final / 0 pending. Two ad-hoc PowerShell formatting scans also required syntax
correction before producing their recorded PASS results; no repository data
was changed by those rejected invocations.

No build was run. No UE Automation test was run. No commit was created.

## Independent-review fixes

Status after review: `DONE`

The independent review identified three static-record/style defects, all
confirmed against current source and corrected without changing a method
body:

1. `handoffs/fixture-and-large-file-quality-review.md` still had a stale
   living-count block and referred to seven current split candidates. The
   living section now records 256 source files / CSV rows / unique keys,
   lifecycle counts 220 case-owned / 9 direct / 8 immutable / 18 no-engine /
   1 recreation / 0 red, and large-file counts 208 NotLarge / 42 retained /
   6 split; the prose says six candidates.
2. Five rows in `audits/internal-method-dispositions.csv` retained pre-split
   rationale paths. Only the owner-path fragments were updated:
   `NodeDeepNestingAndCopyCartesianProduct` and
   `NodeTraversalAndCopyPreserveStructure` now name
   `Frontend/AngelscriptNativeScriptNodeCartesianDepthTests.cpp`,
   `ScriptCodeRowColumnCartesianProduct` names
   `Frontend/AngelscriptNativeScriptCodePositionTests.cpp`, and
   `SourcePositionsAndParserRecoveryRemainStable` names
   `Frontend/AngelscriptNativeParserSourceRecoveryTests.cpp`. Retained parser
   methods still name
   `Frontend/AngelscriptNativeParserCartesianDepthTests.cpp`; all statuses,
   IDs, and other rationale wording are unchanged.
3. Exactly one leading tab was removed from the five parser-owner, two
   ScriptNode-owner, and one ScriptCode-owner CQTest class terminators. No
   `TEST_METHOD` body was edited.

Review-fix verification:

- `ReconcileInternalMethods.ps1 -ProjectRoot
  D:/Workspace/AngelscriptProject -InputPath
  openspec/changes/test-as-native-sdk-comprehensive-coverage/audits/internal-method-dispositions.csv
  -OutputPath
  openspec/changes/test-as-native-sdk-comprehensive-coverage/audits/internal-method-reconciliation.csv
  -RequireComplete`: PASS, 1,002 final / 0 pending. The regenerated
  reconciliation contains zero stale pre-split owner/moved-method pairs.
- `ValidateCoverageCatalogs.ps1 -ChangeRoot
  openspec/changes/test-as-native-sdk-comprehensive-coverage`: PASS, 317
  products / 46,140 cases / 46,140 unique IDs.
- `ReconcileNativeSdkSource.ps1 -ProjectRoot
  D:/Workspace/AngelscriptProject -RequireComplete`: PASS, 688 methods / 0
  incomplete / 0 unresolved.
- Generated-source registry scan: PASS, 0 mismatches; owner print sites remain
  7 / 2 / 1 / 1.
- Brace-aware method-body scan: PASS, 0 mismatches across all nine recorded
  hashes.
- Contextual CQTest terminator scan: PASS, 8 registered CQTest classes, 8
  aligned CQTest terminators, and 0 indented contextual terminators. The two
  additional aligned top-level terminators belong to the owner-local support
  templates.
- Living-count scan: PASS, 256 inventory rows / 256 CSV rows / 256 unique
  keys; lifecycle 220 / 9 / 8 / 18 / 1 with 0 red; large-file 208 / 42 / 6;
  Markdown current-count and six-candidate wording present.
- Target whitespace scan: PASS, 0 trailing-whitespace or missing-final-newline
  errors in the three corrected C++ files, living Markdown, dispositions, and
  regenerated reconciliation.
- `ValidatePlanningRecords.ps1 -ProjectRoot
  D:/Workspace/AngelscriptProject -RequireClean`: PASS, 0 violations.
- `openspec validate test-as-native-sdk-comprehensive-coverage --strict
  --json`: PASS, 1/1 valid with no issues.

No build was run. No UE Automation test was run. No commit was created.
