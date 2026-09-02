# TestSource current recheck and theme-expansion baseline — 2026-08-21

## Decision

The first implementation review remains valid history for explaining why the generated-looking Bind sources were rejected. It is no longer the current source shape: later source rework restored runner-readable observations.

The current automated audit classifies 571 Bind files as `StructurallyComplete`, five as `UnsafeForDefaultExecution`, and all 38 TestFramework files as `ProvisionalExternalOracle`. No file is promoted to source-semantic or external acceptance by this recheck because the original per-file tasks remain unchecked and no AngelScript compile/run was performed.

## Reproducible evidence

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec/changes/test-as-manual-bind-source-coverage/scripts/AuditTestSourceImplementation.ps1 -Check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File openspec/changes/test-as-manual-bind-source-coverage/scripts/BuildTestSourceThemeInventory.ps1 -Check
```

Current source audit:

| Measure | Current |
|---|---:|
| Planned/materialized paths | 614 / 614 |
| Bind files | 576 |
| `Observe_*` functions | 2,420 |
| Non-void `Observe_*` | 2,420 |
| `Observe_*` with parameters | 284 |
| Void/no-argument `Observe_*` | 0 |
| Discarded local observations | 0 |
| Tautologies / permissive fixture passes | 0 / 0 |
| Structurally complete Bind files | 571 |
| Unsafe-for-default-execution Bind files | 5 |
| High-impact calls in those files | 19 |
| Provisional TestFramework files | 38 |
| Accepted Bind / framework files | 0 / 0 |

The five unresolved safety files are:

- `TestSource/Bindings/FGenericPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as`;
- `TestSource/Bindings/FPlatformApplicationMisc/Test_NamespaceAndGlobalFunctions_01.as`;
- `TestSource/Bindings/FPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as`;
- `TestSource/Bindings/FPlatformProcess/Test_NamespaceAndGlobalFunctions_01.as`;
- `TestSource/Bindings/UWorld/Test_Behavior_01.as`.

## Theme expansion

The full-theme inventory accounts for 4,645 real current test methods, 3,672 candidate raw-string blocks, 37 host `Script/**/*.as` files, and 614 materialized TestSource files. It emits 2,427 new handwritten source tasks and keeps generation-owned, native-only, host-only, teaching, duplicate, blocked, and non-script evidence visible without emitting false source tasks.

This recheck modifies only the current OpenSpec record. It does not rewrite TestSource, compile AngelScript, execute UE Automation, implement the external framework oracle, or make the five high-impact sources default-safe.
