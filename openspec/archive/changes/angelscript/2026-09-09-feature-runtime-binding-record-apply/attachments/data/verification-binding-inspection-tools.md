# Binding inspection tool verification

Task 1.7 adds standard-library-only validation and semantic comparison for the version 1 binding manifest. The validator checks schema/scope, canonical and unique type/member identities, provider provenance, nominal base/interface/member references, native alignment and property bounds, decimal int64 reflection values, expectations, and base/by-value cycles while allowing handle cycles. It consumes exporter-supplied typed categories and does not implement another AngelScript parser.

The diff validates both inputs before comparison. It ignores type/member/provider presentation order, preserves native recipe order, and reports added, removed, and changed types and members plus provider and reflection changes. Both commands emit structured JSON reports with symbol/source diagnostics and preserve Unicode.

## Behavioral RED

The exact command below initially ran nine tests and produced nine `ModuleNotFoundError` errors because `validate_bindings.py` and `diff_bindings.py` did not exist. This established the missing standalone behavior independently of Unreal Engine.

## Final GREEN

Command:

```text
python -m unittest discover -s Plugins/Angelscript/Tools/BindingInspection/tests -p "test_*.py"
```

Result: nine tests ran in 0.286 seconds and all passed, process exit code 0. The cases cover a hand-authored Pair/Derived/Test/constant-7/wide-enum manifest; overloads and namespace globals; missing base/provider; duplicate and noncanonical identities; alignment/property bounds; base and by-value cycles versus mutual handles; unsupported schema, malformed enum values, and partial scope; independent required/forbidden/provider expectations; added/removed/base/default/constant/recipe-order diffs; reorder-only equality; malformed files, Unicode paths, report output, and CLI exit codes 0/1/2.

## Identities

| Path | SHA-256 |
|---|---|
| `validate_bindings.py` | `CF901486738F2FF736B4DA7201DFFE644DBE0BF0D8BD2422298ACAD3AEC48F44` |
| `diff_bindings.py` | `A3FED23B4350EF070EA6EC42707A5A11F7566F1D7E5B90D526A8E9A8E32B364D` |
| `README.md` | `4447753BB10BCC4306CC26B165BF59821B3B710C5D2C634D7A23AB9C8CBE2D3B` |
| `tests/test_binding_inspection.py` | `41FC8854ECFEDB9E6A9194D739A3B699AE797775196331BD31364B30E3512510` |

The hashes were captured after the final exact run.
