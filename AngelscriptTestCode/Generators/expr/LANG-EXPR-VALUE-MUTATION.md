# LANG-EXPR-VALUE-MUTATION

Author reference for `FExprValueMutationGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Category: `MUTABLE_LVALUE` | `CONST_LVALUE` | `TEMPORARY` | `REFERENCE_ALIAS` | `FIELD` | `PROPERTY` | `INVALID_NON_LVALUE`
2. Mutation: `ASSIGN` | `COMPOUND_ASSIGN` | `PREFIX_INCREMENT` | `POSTFIX_INCREMENT` | `OUT_ARGUMENT`
3. Placement: `LOCAL` | `GLOBAL` | `MEMBER` | `INDEXED`

Product ID prefix: `LANG-EXPR-VALUE-MUTATION`. Complete set: 7×5×4 = 140 cells. Normal-return aggregate = 60 (`mutable_lvalue`, `reference_alias`, `field`). Compile reject = 80 (`const_lvalue`, `temporary`, `property`, `invalid_non_lvalue`). Runtime fault = 0.

Example: `LANG-EXPR-VALUE-MUTATION-MUTABLE_LVALUE-ASSIGN-LOCAL` → `int EntryLangExprValueMutationMutableLvalueAssignLocal()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: `MutationMetadataWitness`, `NextMutationOperand`, `MakeMutationTemporary`, `ReadMutationNonLValue`, `WriteMutationOut`, `BindMutationAlias`, script `FMutationOwner`, `MakeMutationOwner`, and `GetGlobalMutationOwner`.

Writable cells mutate the documented target (`LocalTarget`, case-qualified `GlobalTarget_<Entry>`, `RootOwner.DirectTarget` / `FieldTarget`, or `AliasTarget`) and return `Result * 10000 + After * 100 + AliasAfter`. Global placement uses a case-qualified module-level integer so entries cannot inherit prior mutable initialization. Property remains an explicit current-fork rejection (`GetPropertyTarget()` is not an lvalue).

`BuildExpressionValueCategorySource` is positive-only. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected` for writable cells is `ExpectedResult * 10000 + ExpectedAfter * 100 + ExpectedAfter`:

- assign 20/20 → 202020
- compound_assign 15/15 → 151515
- prefix_increment 11/11 → 111111
- postfix_increment 10/11 → 101111
- out_argument 31/31 → 313131

`GetExpected` returns 0 for reject and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `Standalone`. Reject rows are `CompileReject` with no declaration and `SourceOnly` execution. Native mutation host callbacks are replaced by script stand-ins; host lifetime counters are out of scope.
