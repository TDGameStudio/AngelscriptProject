# LANG-PROP-FORK-SEMANTICS

Author reference for `FPropForkSemanticsGenerator`. This file is not part of the ordinary `.as` projection.

## Axes

Documented families and the variants that belong to each family. IDs use uppercase tokens with internal underscores.

1. `SCRIPT_DECORATOR`: `GETTER` | `SETTER` | `INDEXED_GETTER` | `INDEXED_SETTER`
2. `NATIVE_REGISTRATION`: `GETTER` | `SETTER` | `INDEXED_GETTER` | `INDEXED_SETTER`
3. `AUTOMATIC_ACCESS`: `READ` | `WRITE` | `INDEXED_READ` | `INDEXED_WRITE`
4. `DIRECT_METHOD`: `READ_WRITE_INDEXED`

Product ID prefix: `LANG-PROP-FORK-SEMANTICS`. Complete set: 13 cells. Normal-return aggregate = 1. Compile reject = 12. Runtime fault = 0.

Example: `LANG-PROP-FORK-SEMANTICS-DIRECT_METHOD-READ_WRITE_INDEXED` → `int EntryLangPropForkSemanticsDirectMethodReadWriteIndexed()`.

## Source branches

Decorator modules declare `get_Value`/`set_Value` with the removed `property` decorator. Native-registration modules comment `RegisterObjectMethod(..., "... property")`. Automatic-access modules read or write `Receiver.Value` or `Receiver.Value[2]`. The one normal cell calls `GetValue() + GetIndexedValue(2)` after `SetValue(41)` and `SetIndexedValue(2, 43)`.

`BuildDirectMethodSource` is positive-only and returns empty for reject cells, including the default constructor and mismatched family/variant pairs. `BuildRejectSource` and `ListRejectCaseIds` own the 12 reject modules. Empty `FunctionName` emits `Entry` for the direct-method cell. Invalid identifiers such as `bad-name` emit no source.

## Observation

`GetExpected = 88` for `DIRECT_METHOD-READ_WRITE_INDEXED` (`41 + 47` from the two method results). Reject and unknown IDs return 0; that fallback is not membership proof. There is no real expected-zero normal cell.

The normal row is `ReturnValue` + `RequiresHostSetup`. Host notes name `CreatePropertyForkCarrier`, `GetValue`, and `GetIndexedValue`.
