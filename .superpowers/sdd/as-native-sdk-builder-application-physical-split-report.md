# Builder Application physical split report

## Status

`DONE_WITH_CONCERNS`

The requested physical source split, owner-path migration, review-disposition
update, and scoped static reconciliation are complete. No build or Unreal
Automation test was run, as required by the brief.

One unrelated repository-wide catalog-validation concern remains: the full
`ValidateCoverageCatalogs.ps1` command stops at
`Language/Operators/AngelscriptNativeComparisonOperatorTests.cpp` because the
generated-source registry names `VerifyComparisonMetadata`, while that current
dirty source does not contain the registered builder text. The Builder
Application rows were independently checked and all resolve to their exact new
owners.

## Physical ownership result

| File | CQTest owner | Product / retained compatibility |
| --- | --- | --- |
| `Compiler/AngelscriptNativeBuilderApplicationTests.cpp` | `FBuilderApplicationTests` | `COMPILER-BUILDER-FUNCTION-DECLARATION`; `ParseFunctionDeclarationPreservesParamsDefaultsAndTraits` |
| `Compiler/AngelscriptNativeBuilderScalarApplicationTests.cpp` | `FBuilderScalarApplicationTests` | `COMPILER-BUILDER-SCALAR-DECLARATION`; `ParseDataTypeResolvesPrimitiveAndScriptClass`; `ParseVariableDeclarationExtractsNamespaceNameAndType` |
| `Compiler/AngelscriptNativeBuilderTemplateApplicationTests.cpp` | `FBuilderTemplateApplicationTests` | `COMPILER-BUILDER-TEMPLATE-DECLARATION`; `ParseTemplateDeclSplitsNameAndSubtypeIdentifiers` |
| `Compiler/AngelscriptNativeBuilderPropertyApplicationTests.cpp` | `FBuilderPropertyApplicationTests` | `COMPILER-BUILDER-PROPERTY-VERIFICATION`; `VerifyPropertyAcceptsValidDeclarationAndRejectsNameConflict` |

Each file retains the exact automation directory
`Angelscript.TestModule.AngelScriptSDK.Compiler.Builder.AppInterface`. The
function-only `FScopedScriptFunction` native lifetime support remains solely in
the original file. Each file has a uniquely named subject support base, so
Unreal unity concatenation cannot introduce duplicate namespace-scope support
definitions.

## Preserved test surface

- All nine pre-split `TEST_METHOD` names are present exactly once.
- All four `AS_NATIVE_PRODUCT` IDs remain present exactly once.
- The generated products retain their original case-ID roots, axis tables,
  module labels, `AppendGeneratedAsLine` construction, and
  `PrintGeneratedAsSource` call.
- Product cell cardinalities remain function `48`, scalar `12`, template `12`,
  and property `12`.
- Compatibility methods retain their source fixtures, diagnostics, assertions,
  module cleanup, case-owned engine cleanup, and non-product dispositions.
- Every source registers under the existing
  `WITH_ANGELSCRIPT_UNITTESTS` body gate.

## Catalogs, registries, and current source-backed records

Updated:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `audits/predecessor-dispositions.csv`
- `handoffs/internal-method-engine-frontend-compiler-review-v2.csv`
- `handoffs/internal-method-runtime-language-review.csv`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`

The generated-source registry now records one source-print site in each
physical owner. The large-file review now records four case-owned, subject-only
files as `NotLarge`, reduces `SplitRequiredMixedResponsibilities` from 14 to
13, and removes Builder Application from the outstanding split list.

The source reconciler was extended to recognize the already-used
`TEST_CLASS_WITH_BASE_AND_FLAGS` CQTest registration form. Generated
reconciliation outputs were regenerated through their repository scripts
rather than hand-edited:

- `audits/expected-coverage.csv`
- `audits/product-cardinalities.csv`
- `audits/implementation-reconciliation.csv`
- `audits/method-product-reconciliation.csv`
- `audits/internal-method-dispositions.csv`
- `audits/internal-method-reconciliation.csv`
- `audits/predecessor-baseline.csv`
- `audits/boundary-violations.csv`

## Static validation evidence

### Exact owner and unity scan

The scoped scan checked:

- no literal `tokens truncated` or ellipsis corruption sentinel;
- one matching class, product marker, generated-source print site, and
  automation directory per file;
- all nine methods exactly once;
- balanced raw brace counts in each source;
- no duplicate unity-visible namespace-scope class/namespace name;
- exact generated-source registry file/class/method/product/print-site paths;
- planned owner equals actual owner for all four products.

Result:

```text
Builder split exact-owner/preservation/unity scan: PASS
(4 products, 9 methods, 4 unique support owners)
```

### Coverage expansion and source reconciliation

`ExpandCoverageProducts.ps1`:

```text
Products: 317
ExpectedCases: 46140
CurrentForkCases: 45994
FutureDisabledCases: 65
```

`ReconcileNativeSdkSource.ps1 -RequireComplete`:

```text
Products: 317
Implemented: 316
DisabledImplemented: 1
IncompleteProducts: 0
Methods: 688
ProductOwnedMethods: 312
ProductPartMethods: 50
ExplicitNonProductMethods: 326
UnresolvedMethods: 0
```

All four Builder products have `State=Implemented` and identical planned and
actual owner strings.

### Disposition and boundary reconciliation

`FinalizeInternalMethodDispositions.ps1` and
`ReconcileInternalMethods.ps1 -RequireComplete`:

```text
Rows: 1002
DirectCovered: 171
PublicContractCovered: 803
ApiDeferred: 28
Final: 1002
Pending: 0
```

`ReconcilePredecessorScenarios.ps1 -RequireFinalDisposition` completed with
all 222 required predecessor rows checked against terminal dispositions.

`AuditNativeSdkBoundaries.ps1 -RequireClean`:

```text
Violations: 0
```

### Diff hygiene

`git diff --check` was run for the tracked plugin source and as
`git diff --no-index --check` for the three new plugin sources, the report, and
the touched untracked OpenSpec inputs/generated outputs:

```text
PASS (1 tracked plugin source + 20 untracked/touched files;
no whitespace errors)
```

### Full catalog validator concern

`ValidateCoverageCatalogs.ps1` was invoked, but repository-wide validation
stopped before completion on the unrelated current dirty operator owner:

```text
Generated-source owner
'Language/Operators/AngelscriptNativeComparisonOperatorTests.cpp'
does not contain registered builder 'VerifyComparisonMetadata'.
```

No Builder Application file or record was implicated. The four affected
registry rows were therefore validated by the scoped exact-owner scan and by
the complete source reconciler.

## Intentionally not run

- Unreal Engine build
- Unreal Automation tests

Both were explicitly prohibited by the task brief.
