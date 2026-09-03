# TestSource generation contract

Reviewed, language-neutral generation data for `test-as-source-generation-rules`.
Python in `python/` is the independent reference implementation for this wave.
Portable C++ and plugin release emitters are out of this wave.

## Layout

- `schema/` — request, result, recipe, and comment-fact schemas
- `goldens/` — SplitMix64-v1, FNV-1a CaseKey, and representative CaseKeys
- `recipes/` — one file per recipe-family registry row
- `Rules/Authored/` — 614 authored fixture export rules plus `index.json`
- `Rules/NativeSDK/` — 271 product rules (45,760 mandatory cells declared)
- `Rules/Coverage/` — GeneratedRecipe Coverage candidates
- `Rules/Inline/` — GeneratedRecipe inline candidates
- `Contracts/` — authored Contract V2 truth plus generated coverage index
- `Tasks/` — deterministic per-domain migration projections (never authority)
- `python/` — schema/canonical/CaseKey/SplitMix64/recipe/authored export

Default generation output is in-memory. This tree does not store bulk generated
`.as` files.

## Tests

```
python -m pytest TestSource/Generation/python/tests -q
```

## Authored Contract V2

`schema/authored-case-contract-v2.json` defines the reviewed, function-level
contract used while migrating the handwritten AngelScript corpus. Each source
contract is stored at `Contracts/<source-relative-path>.json`; for example,
`TestSource/Bindings/TArray/Test_Queries_01.as` maps to
`Contracts/Bindings/TArray/Test_Queries_01.as.json`. A contract records exact AS
owner-qualified declarations (including callable annotations), semantic and legacy identities,
typed inputs/returns/writebacks, comparison policy, comment facts,
fixture/lifecycle ownership, coverage evidence, and review state.

The generated `Contracts/index.json` reports migration coverage truthfully.
Generated `Tasks/<domain>.md` files display old/new declarations, typed vectors,
comments, fixtures, cleanup, and the domain verification command. Edit the
per-source contract, never either projection.

### Audit existing sources

Audit scans every `.as` file outside `Generation/`, inventories callables while
ignoring strings/comments, and reports missing contracts, comments, legacy
names, unsafe oracle shapes, and stale or duplicate contract data. The current
non-migrated corpus is expected to return non-zero; that result is its migration
inventory, not a tool failure.

```powershell
python TestSource/Generation/python/validate_testsource.py `
  --root TestSource --mode audit --max-diagnostics 50
```

Use `--format json` for the complete deterministic diagnostic set.
`--write-projections` attempts to regenerate `Contracts/index.json` and all task
projections. Projection writes are fail closed: every source must be globally
unique, reviewed, and strict source-parity-clean before the first output is
touched. A dirty audit preserves any existing index/tasks unchanged.

### Strict validation of a migrated domain

Strict mode requires an exact reviewed contract and adjacent knowledge comment
for every callable and source in the selected domain. Domain selection is a
source-relative prefix; unrelated legacy directories are deliberately excluded.

```powershell
python TestSource/Generation/python/validate_testsource.py `
  --root TestSource --mode strict --domain Bindings/TArray
```

A clean strict source result establishes source parity only. Coverage status
must keep compile, runtime, and external-oracle verification unverified until a
fresh corresponding runner command supplies evidence. A contract claiming
`strict-pass`, `compile-verified`, `runtime-verified`, or
`external-oracle-verified` without matching passing evidence is rejected.

Active authored export accepts a reviewed, current-source-clean Contract V2
document only. Legacy v1 authored rules remain readable migration evidence
through the explicit adapter, but cannot supply declarations, entry points,
vectors, or a default compile-pass claim.
