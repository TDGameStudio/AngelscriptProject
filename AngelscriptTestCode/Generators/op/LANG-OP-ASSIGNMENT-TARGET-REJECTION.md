# LANG-OP-ASSIGNMENT-TARGET-REJECTION

Author reference for `FOpAssignmentTargetRejectionGenerator`. This file is not part of the ordinary `.as` projection.

Naming assumed: `EOpAssignmentTargetRejectionTarget` — product stem plus rejected-target axis.
Naming assumed: `EOpAssignmentTargetRejectionOperation` — product stem plus Operation axis.
Naming assumed: `EOpAssignmentTargetRejectionType` — product stem plus Type axis.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Operation and type share one `_` token. Legacy underscore smash is normalized.

1. Target: `CONST_INVALID` | `TEMPORARY_INVALID`
2. Operation+type: the 111 legal assignment pairs from LANG-OP-ASSIGNMENT

Complete set: 2 × 111 = 222 reject cells. Normal-return aggregate = 0. Runtime fault = 0.

Example: `LANG-OP-ASSIGNMENT-TARGET-REJECTION-CONST_INVALID-ASSIGN_INT` → `int EntryLangOpAssignmentTargetRejectionConstInvalidAssignInt()`.

## Source branches

Each reject module is isolated.

- `CONST_INVALID`: `const Type Value = Input;` then `Value <op> Source; // ASSIGNMENT_CAUSE`
- `TEMPORARY_INVALID`: `MakeRejectedAssignmentTemporary(Input) <op> Source; // ASSIGNMENT_CAUSE` plus the identity helper that calls `RecordAssignmentTemporaryProducer()`

`BuildTargetRejectionSource` accepts only supported pairs. Empty `FunctionName` emits `Entry`. `bad-name`, invalid enums, and unsupported pairs emit no source. `BuildRejectSource` / `ListRejectCaseIds` own all 222 modules. `BuildAllSource` emits no entries (`OutCaseCount = 0`).

## Observation

Compile-reject rows have no integer expectation. `GetExpected` is 0 for every listed ID and for unknown IDs; that zero is not membership. Outcome `CompileReject`, execution `SourceOnly`, empty `EntryDeclaration`.
