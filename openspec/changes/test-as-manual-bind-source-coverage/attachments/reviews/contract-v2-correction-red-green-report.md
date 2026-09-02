# Task 1 — Contract V2 implementation report

## Scope

- Product writes are limited to `TestSource/Generation/**`.
- This report is the only explicitly authorized write outside that product scope.
- No `.as` fixture, OpenSpec artifact, plugin/host source, staging area, or commit was modified.

## Review-correction RED/GREEN evidence

### Cluster 1 — owner-qualified inventory and current callable forms

RED command:

```powershell
python -m pytest TestSource/Generation/python/tests/test_as_inventory_current_forms_v2.py -q
```

RED result: `6 failed`. The failures independently demonstrated the missing `owner` identity, all six invisible corpus lambdas, omitted imports, incorrect event/mixin return semantics, constructor/destructor name collision in the test view, and trailing-comment false attachment.

GREEN command:

```powershell
python -m pytest TestSource/Generation/python/tests/test_as_callable_inventory_v2.py TestSource/Generation/python/tests/test_as_inventory_current_forms_v2.py -q
```

GREEN result: `11 passed in 1.18s`. The corpus-backed semantic-signature probe finds 38 cross-owner collision files (a conservative superset of the 34 reviewed files), all six current lambdas, all three imports, and current event/free-mixin forms. Owner-qualified identity, destructor/operator classification, immediate lambda-assignment comments, and rejection of unrelated trailing comments are covered.

### Cluster 2 — contract semantics, source parity, and evidence invariants

RED command:

```powershell
python -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py -q
```

RED result: `33 failed, 12 passed in 0.52s`. Owner/annotation fields were rejected by the old schema, same declarations under distinct owners collapsed, role/return/default/direction/annotation drift was not diagnosed, comparison payload and contradictory diagnostic checks were absent, fixed-role and legacy-history invariants were bypassable, and verified statuses accepted incomplete evidence chains.

Follow-up RED command:

```powershell
python -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py -q -k "orphan_legacy or different_namespaces"
```

Follow-up RED result: `2 failed, 45 deselected in 0.18s`, proving the one-way legacy-history check still allowed orphaned history and a file-level empty/common namespace still blocked valid cross-namespace owner identities.

GREEN command:

```powershell
python -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py -q
```

GREEN result: `47 passed in 0.30s`. The schema now carries owner and exact annotations; uniqueness and parity use owner-qualified declarations; strict validation covers role/kind, semantic return, full parameter/default/direction, annotations, source shape, vector channel consistency, comparison payloads, fixture/cleanup, bidirectional legacy history, fixed names, and cumulative structural evidence prerequisites with `recordedAt`/pass. Evidence validation intentionally checks recorded structure only and makes no claim that arbitrary command strings were executed.

Boundary follow-up RED command:

```powershell
python -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py -q -k "writeback_comparison or v1_rule_remains"
```

Boundary follow-up RED result: `2 failed, 52 deselected in 0.19s`, exposing a missing relation payload check on vector writebacks and proving that using v1 merely as a V2-sidecar locator still let the active boundary consume a v1 input.

Reviewed-state follow-up RED command:

```powershell
python -B -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py -q -k "reviewed_state_without"
```

Reviewed-state follow-up RED result: `1 failed, 54 deselected in 0.17s`, demonstrating that a nominal `reviewed` row could still omit reviewer identity and a valid review date.

### Cluster 3 — fail-closed projections and active V2-only export

RED command:

```powershell
python -m pytest TestSource/Generation/python/tests/test_authored_source_export.py TestSource/Generation/python/tests/test_authored_contract_v2.py -q -k "projection_fails_closed or active_authored_export or v1_rule_cannot"
```

RED result: `6 failed, 48 deselected in 0.24s`. Active export still accepted v1 `plannedSymbols`, guessed declaration/entryPoint, and emitted compile pass; direct V2 export was unsupported; draft/source-dirty V2 was not rejected; and projection generation had no fail-closed error boundary before output mutation.

GREEN focused commands:

```powershell
python -m pytest TestSource/Generation/python/tests/test_authored_source_export.py TestSource/Generation/python/tests/test_authored_contract_v2.py -q -k "projection_fails_closed or active_authored_export or v1_rule_cannot"
python -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py TestSource/Generation/python/tests/test_authored_source_export.py TestSource/Generation/python/tests/test_as_callable_inventory_v2.py TestSource/Generation/python/tests/test_as_inventory_current_forms_v2.py -q
```

GREEN results: `6 passed, 48 deselected in 0.15s`; then `65 passed in 1.55s`. Projection generation runs a complete strict audit before its first mutation, rejects draft/dirty rows, preserves prior outputs on failure, and includes owner/role in task rows. Active export consumes exact reviewed V2 functions/vectors only, rejects missing/draft/source-dirty V2, emits `unverified` unless recorded compile evidence supports a verified status, and never reads `plannedSymbols` as declaration/entryPoint or defaults compile to pass.

Projection-status follow-up RED command:

```powershell
python -B -m pytest TestSource/Generation/python/tests/test_authored_contract_v2.py -q -k "later_verified_status"
```

Projection-status RED result: `1 failed, 56 deselected in 0.20s`, showing that a valid `compile-verified` row was not counted as having passed its prerequisite source-strict stage in the deterministic index.

The two boundary follow-ups subsequently turned GREEN (`2 passed, 52 deselected in 0.10s`), and the reviewed-metadata follow-up turned GREEN (`1 passed, 54 deselected in 0.11s`). V1 is now rejected unconditionally at the active boundary, writeback relations/identity/elements/numeric comparisons require their channel-specific after payload, diagnostic comparisons are forbidden as writebacks, and reviewed state requires reviewer identity plus an ISO date.

The projection-status follow-up turned GREEN (`1 passed, 56 deselected in 0.14s`); strict-pass and every later cumulative verified status now count truthfully toward `strictPassContractCount` / `complete-source-strict`.

## Implementation files

- `TestSource/Generation/schema/authored-case-contract-v2.json`
- `TestSource/Generation/Contracts/index.json` (bootstrap migration-pending projection; SHA-256 `C493D271C3B1B69A39E04E739A7C1DE5DC92FE8BC9C3018C63CB0285793A3C6C`)
- `TestSource/Generation/python/angelscript_generation/as_inventory.py`
- `TestSource/Generation/python/angelscript_generation/contract_v2.py`
- `TestSource/Generation/python/angelscript_generation/audit_v2.py`
- `TestSource/Generation/python/angelscript_generation/projections_v2.py`
- `TestSource/Generation/python/angelscript_generation/cli_v2.py`
- `TestSource/Generation/python/angelscript_generation/authored.py`
- `TestSource/Generation/python/validate_testsource.py`
- `TestSource/Generation/python/tests/test_as_callable_inventory_v2.py`
- `TestSource/Generation/python/tests/test_as_inventory_current_forms_v2.py`
- `TestSource/Generation/python/tests/test_authored_contract_v2.py`
- `TestSource/Generation/python/tests/test_authored_source_export.py`
- `TestSource/Generation/Rules/Authored/TS-BIND-FINSTANCEDSTRUCT-002.json`
- `TestSource/Generation/README.md`

No generated `Tasks/*.md` was written: the unmigrated corpus is intentionally dirty, and the new projection boundary refuses to touch outputs until the complete strict audit is clean. Generated Python bytecode caches were removed after verification.

## Final GREEN verification

```powershell
python -B -m pytest TestSource/Generation/python/tests -q
# 97 passed in 1.55s

python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode audit --max-diagnostics 0
# exit 1, expected migration inventory
# sources=3041 contracts=0 callables=11987 diagnostics=25439

python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --max-diagnostics 0
# exit 1, expected before migration
# sources=3041 contracts=0 callables=11987 diagnostics=25439

python -B TestSource/Generation/python/validate_testsource.py --root TestSource --mode strict --domain Bindings/TArray --max-diagnostics 0
# exit 1, expected before the pilot migration
# sources=8 contracts=0 callables=45 diagnostics=131

python -B -c "from jsonschema import Draft202012Validator; from angelscript_generation.contract_v2 import load_schema; Draft202012Validator.check_schema(load_schema()); print('schema-valid')"
# schema-valid

openspec validate test-as-manual-bind-source-coverage --type change --strict --no-interactive
# Change 'test-as-manual-bind-source-coverage' is valid
```

Full-audit diagnostic counts are `compound-bool-oracle=3523`, `expected-value-wrapper=72`, `legacy-source-name=6975`, `missing-callable-comment=11364`, `missing-contract=3041`, and `unspecified-reference-direction=464`.

The explicit corpus proof inventoried `11987` callables: `constructor=15`, `delegate=326`, `event=84`, `function=8776`, `import=3`, `lambda=6`, `method=2663`, `mixin=18`, and `operator=96`. Semantic-signature grouping found `38` cross-owner collision files / `54` groups / `67` extra callables, conservatively covering all 34 files from the review. It asserted all six known lambda locations, all three import locations, all 84 events, and all 18 free mixins are visible.

## Residual boundaries

- This task establishes infrastructure only. All 3,041 authored sources still lack V2 sidecars, so audit/strict exit non-zero by design; no fixture was migrated or renamed.
- Five of the six existing lambdas have no immediately adjacent assignment/call comment in current source. They are now visible and reported by the audit; later fixture migration must add those comments rather than letting file headers satisfy adjacency.
- Evidence-chain validation proves recorded stage prerequisites, non-empty command text, pass result, and `recordedAt`; static validation deliberately does not claim to authenticate whether arbitrary command text actually ran.
- No UE compile/runtime/external-oracle runner was invoked or claimed by Task 1. Active export therefore remains `unverified` unless a future V2 row carries a structurally valid recorded verification chain.
- The inventory is a deterministic source scanner sufficient for the current corpus, not an AngelScript compiler. Exact declarations remain byte-preserved and semantic fields are independently checked to prevent source/contract lies.
- No files were staged or committed.
