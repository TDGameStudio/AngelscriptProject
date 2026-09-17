# LANG-OP-ASSIGNMENT-TYPE-REJECTION

Author reference for `FOpAssignmentTypeRejectionGenerator`. This file is not part of the ordinary `.as` projection.

Naming assumed: `EOpAssignmentTypeRejectionCategory` — product stem plus Category axis.
Naming assumed: `EOpAssignmentTypeRejectionOperation` — product stem plus Operation axis.
Naming assumed: `EOpAssignmentTypeRejectionType` — product stem plus Type axis.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Operation and type share one `_` token. Legacy underscore smash is normalized.

1. Category: `LOCAL` | `FIELD` | `PROPERTY` | `ALIAS`
2. Operation+type: the 32 unsupported assignment pairs (`+ − * / %` on bool; `**=` on non-float; bitwise/shifts on non-integral)

Complete set: 4 × 32 = 128 reject cells. Normal-return aggregate = 0. Runtime fault = 0.

Example: `LANG-OP-ASSIGNMENT-TYPE-REJECTION-LOCAL-ADD_ASSIGN_BOOL` → `int EntryLangOpAssignmentTypeRejectionLocalAddAssignBool()`.

## Source branches

Each reject module is isolated. Every body ends with `<target> <op> Source; // ASSIGNMENT_CAUSE`.

- local / alias: `Type Value = Input;`
- field: `struct FRejectedAssignmentField { Type Value; }` then `Owner.Value <op> Source`
- property: `FAssignmentProperty_<type> Owner = MakeAssignmentProperty_<type>();` then `Owner.Value <op> Source`

`BuildTypeRejectionSource` accepts only unsupported pairs (positive-legal inputs return empty). Empty `FunctionName` emits `Entry`. `BuildRejectSource` / `ListRejectCaseIds` own all 128 modules. `BuildAllSource` emits no entries (`OutCaseCount = 0`).

## Observation

Compile-reject rows have no integer expectation. `GetExpected` is 0 for listed and unknown IDs; that zero is not membership. Outcome `CompileReject`, execution `SourceOnly`.
