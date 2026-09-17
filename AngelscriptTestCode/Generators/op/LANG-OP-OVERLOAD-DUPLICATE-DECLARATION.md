# LANG-OP-OVERLOAD-DUPLICATE-DECLARATION

Author reference for `FOpOverloadDuplicateDeclarationGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated.

1. Kind: `DUPLICATE`
2. Family: `UNARY` | `BINARY` | `COMPARISON` | `INDEX` | `CALL` | `CONVERSION` | `ASSIGNMENT`

Product ID prefix: `LANG-OP-OVERLOAD-DUPLICATE-DECLARATION`. Complete set: 1×7 = 7 cells. Normal-return aggregate = 0. Compile reject = 7. Runtime fault = 0.

Example: `LANG-OP-OVERLOAD-DUPLICATE-DECLARATION-DUPLICATE-UNARY` → `int EntryLangOpOverloadDuplicateDeclarationDuplicateUnary()`.

## Source branches

Reject-only product. `BuildAllSource` is empty and counts 0. Each family is an isolated module declaring `FOverloadedOperatorValue` with two identical operator methods (`opNeg`, `opAdd`, `opEquals`, `opIndex`, `opCall`, `opImplConv`, `opAssign`). The second copy is marked `// OP_OVERLOAD_DUPLICATE_CAUSE`.

`BuildDuplicateSource` is the reject builder. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Reject cells have no normal-return comparison. `GetExpected` is 0 for every listed reject ID and for unknown IDs. That zero fallback is not membership proof.

All rows are `CompileReject` + `SourceOnly` with an empty `EntryDeclaration`.
