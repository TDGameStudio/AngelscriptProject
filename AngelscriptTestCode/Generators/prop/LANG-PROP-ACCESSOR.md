# LANG-PROP-ACCESSOR

Author reference for `FPropAccessorGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented order, uppercase catalog tokens, hyphen-separated. Multiword tokens keep internal underscores.

1. Scenario: `GETTER_READ_MUTABLE` | `GETTER_READ_CONST` | `GETTER_NONCONST_READ_MUTABLE` | `GETTER_NONCONST_READ_CONST_REJECTED` | `GETTER_WRITE_MISSING` | `GETTER_COMPOUND_MISSING_SET` | `SETTER_WRITE_MUTABLE` | `SETTER_WRITE_CONST_REJECTED` | `SETTER_READ_MISSING` | `SETTER_COMPOUND_MISSING_GET` | `BOTH_READ_MUTABLE` | `BOTH_WRITE_MUTABLE` | `BOTH_COMPOUND_MUTABLE` | `BOTH_COMPOUND_CONST_REJECTED` | `RECURSIVE_GETTER` | `RECURSIVE_SETTER` | `THROWING_GETTER` | `THROWING_SETTER`
2. Source shape: `SINGLE_LINE` | `MULTILINE` | `PARENTHESIZED` | `HELPER_CALL`

Product ID prefix: `LANG-PROP-ACCESSOR`. Complete set: 18×4 = 72 cells. Normal-return aggregate = 36. Compile reject = 28. Runtime fault = 8 (`THROWING_GETTER` and `THROWING_SETTER`). Non-reject aggregate (normal + fault) = 44.

Reject cells: `GETTER_NONCONST_READ_CONST_REJECTED`, `GETTER_WRITE_MISSING`, `GETTER_COMPOUND_MISSING_SET`, `SETTER_WRITE_CONST_REJECTED`, `SETTER_READ_MISSING`, `SETTER_COMPOUND_MISSING_GET`, `BOTH_COMPOUND_CONST_REJECTED`.

Example: `LANG-PROP-ACCESSOR-GETTER_READ_MUTABLE-SINGLE_LINE` → `int EntryLangPropAccessorGetterReadMutableSingleLine()`.

## Source branches

Shared helpers, emitted once per aggregate or isolated reject module: `class FRegisteredProperty`, `CreateRegisteredProperty(int)`, `ObserveRegisteredProperty`.

Each entry constructs `CreateRegisteredProperty(31)` (const receiver when the scenario is const) and applies `Receiver.Value` as read, write `= 73`, or compound `+= 5`. Shapes wrap that operation as a single statement, a split assignment, a parenthesized lvalue/rvalue, or `InvokeRegisteredProperty_<Entry>`. Recursive scenarios emit a reenter helper. Throwing scenarios return `1 / Zero`.

`BuildRegisteredPropertySource` is positive-only and returns empty for reject cells. `BuildRejectSource` and `ListRejectCaseIds` own the 28 reject modules. Empty `FunctionName` emits `Entry`. Invalid identifiers such as `bad-name` emit no source.

## Observation

Independent oracle for normal-return cells:

- read: `31`
- write: `73`
- `BOTH_COMPOUND_MUTABLE`: `36`

`GetExpected` uses this formula for the 36 normal IDs and returns 0 for reject, fault, and unknown IDs. That zero fallback is not membership proof. There is no real expected-zero normal cell.

Normal rows are `ReturnValue` + `RequiresHostSetup`. Fault rows are `RuntimeException` / `Divide by zero` with no integer expectation. Reject rows are `CompileReject` with no declaration. Host notes name `CreateRegisteredProperty` and `ObserveRegisteredProperty`.
