# Verification

## Final linked verification — 2026-07-28

| Gate | Evidence | Result |
| --- | --- | --- |
| Static signature/opcode ownership | `static-reconciliation.md`, `supported-contract.md`, and the main change's final 166-hunk ownership audit | **PASS**: all 34 object-last/native-caller hunks and every supported/rejected shape have an explicit owner and oracle. |
| Coherent build after Unity repairs | `Saved/Build/as-native-sdk-comprehensive-counted-implicit-final-fix1/20260727_233018_434_7aecbf0f` | **PASS**, process/final exit 0/0. Three accidental Unity dependencies were repaired with direct includes or a class-local helper forwarder. |
| Restored final build | `Saved/Build/as-native-sdk-unit-tests-restored-final/20260728_000229_699_38a673dd` | **PASS**, 56 actions and process/final exit 0/0. |
| Counted/no-count implicit handles | `Saved/Tests/as-native-sdk-counted-implicit-focused-final/20260727_233047_572_5126e973`; `Saved/Tests/as-native-sdk-generic-interface-depth-final/20260727_233145_097_9f390a2d` | Exact owner **1/1** and parent **3/3 PASS**. The printed source exercises both no-count and counted entries; counted cleanup performs exactly one AddRef and one Release and restores the baseline. |
| Calling conventions | `Saved/Tests/as-native-sdk-object-last-calling-convention-final/20260727_233221_477_7217a3f2` | **6/6 PASS**, including sentinels, return storage, exception, reuse, cleanup, and isolation. |
| Save/load native-call identity | `Saved/Tests/as-native-sdk-object-last-module-saveload-final/20260727_233300_739_3895a942` | **5/5 PASS** in the destination engine. |
| Affected parents | `Saved/Tests/as-native-sdk-runtime-theme-final/20260727_234116_301_e3c93908`; `Saved/Tests/as-native-sdk-module-theme-final/20260727_234154_745_6cecb96f` | Runtime **45/45** and Module **52/52 PASS**. |
| Generated object-last path | `Saved/Tests/as-native-sdk-comprehensive-current-final-green1_04_tests/20260727_222852_888_6d5de814` | Canonical AOT **12/12 PASS**; the generated constructor entry preserves the explicit argument sentinels. |
| Restored final SDK and project suite | `Saved/Tests/as-native-sdk-comprehensive-restored-final/20260728_000418_207_c7795abc`; final restored All suite | SDK **683/683** and All **2,396/2,396 PASS**, zero failed/skipped/timeouts/crashes. |
| Record gates | Strict validation of this and the main change; parent/plugin `git diff --check` | **PASS**. |

All task-1 through task-4 verification obligations are complete. Current-fork
rejected shapes remain explicit negative contracts; selected 2.38 behavior is
not enabled by this repair.
