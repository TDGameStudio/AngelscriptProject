# Verification

## Retained focused evidence

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Build/as-staticjit-reference-copy-reader-red-repair/20260724_062013_356_b6f40271/UBT.log` | Link failed LNK2019 for production `FAngelscriptPrecompiledFunction::Process`. | Historical red module-boundary evidence for P022. |
| `Saved/Build/as-staticjit-reference-copy-reader-export-red/20260724_062146_377_2758579d/UBT.log` | Runtime/Test compiled and linked after the narrow export. | Historical export evidence only. |
| `Saved/Tests/as-staticjit-reference-copy-reader-lookup-red/20260724_062418_724_b79698e1/Report/index.json` | Exact owner 0/1; only post-`Process` destination-type remap failed. | Intended behavioral red evidence. |
| `Saved/Tests/as-staticjit-reference-copy-precompiled-remap-fix/20260724_062620_305_eb0889ec/Report/index.json` | Exact owner 1/1; source bytes, distinct destination type, production-reader remap, and restored result passed. | Historical focused green support. |
| `Saved/Tests/as-staticjit-precompileddata-reference-copy-remap-parent/20260724_062702_144_84a16b63/Report/index.json` | PrecompiledData parent 4/4. | Historical parent support. |

## Pending final gates

The source and focused regression are present, but this linked change has not
completed its broader task 4 verification. Required fresh evidence includes:

1. coherent Runtime/Test build;
2. the fully qualified focused PrecompiledData method from task 4.4;
3. Reference, Compiler, Runtime, Module, StaticJIT PrecompiledData, and complete
   SDK prefixes;
4. malformed-stream, save/load, ownership symmetry, cleanup, shutdown, and
   crash/timeout evidence;
5. `openspec validate fix-as-reference-bytecode-ownership-persistence --strict`
   and scoped whitespace checks.

No fresh build or automation was run while adding this ownership record.

## Retained-function discarded-module red — 2026-07-27

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Tests/as-native-sdk-reference-retained-fix1/20260727_214900_678_0ffd1f4c` | Variables Lifetime is 2/3. The retained-function owner executes and balances its native object, final function `Release()` returns zero, but the registered TypeInfo remains at internal reference count 11 instead of baseline 3. | Fresh behavioral red for `AS-FORK-DEFECT-016` and P166. |
| Current source compared with pinned `Reference/angelscript-v2.38.0/sdk/angelscript/source/as_scriptengine.cpp` | Current `GarbageCollect()` returns immediately after object GC; pinned 2.38 invokes `DeleteDiscardedModules()` only when GC returns zero. | Root-cause and compatibility evidence for the minimal selective backport. |

P166 and the updated retained-function oracle passed their first concentrated
green stage:

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Build/as-native-sdk-reference-gc-linked-batch/20260727_220317_222_5e28cc76` | 8/8 actions, process/final exit 0/0, `TimedOut=false`. | Coherent production/test build for P166 and the linked reference batch. |
| `Saved/Tests/as-native-sdk-reference-gc-green1/20260727_220353_534_b8c79428` | Variables Lifetime 3/3 PASS; the retained-function owner restores TypeInfo 11 to the exact baseline 3 while module lookup remains absent. | Direct red-to-green behavior for P166. |
| `Saved/Tests/as-native-sdk-reference-gc-engine-regression/20260727_220549_122_6a296834` | Engine 40/40 PASS with normal shutdown and no crash marker. | Affected parent regression evidence. |
| `Saved/Tests/as-native-sdk-reference-gc-module-regression/20260727_220629_726_b1e6e120` | Module 51/52, normal failure exit and no crash. The sole failure is the prior negative user-data oracle expecting zero callback; P166 now retires the discarded module during shutdown's successful GC. | Required semantic-oracle transition, not green Module acceptance. |

The Module owner now requires exactly-once callback identity and successor-engine
no-repeat behavior. Its coherent build and affected runtime gates are green:

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Build/as-native-sdk-module-userdata-gc-green/20260727_221434_267_8020fc8b` | 4/4 actions, process/final exit 0/0, `TimedOut=false`; only the existing C5038/C4191 warnings remain. | Coherent build after correcting the Module oracle. |
| `Saved/Tests/as-native-sdk-module-userdata-gc-green-focused/20260727_221458_828_727cac44` | `UserDataTransitionsAndCleanup` 1/1 PASS; both complete review sources are printed; process/final exit 0/0 and normal shutdown. | Exact Module user-data semantic regression. |
| `Saved/Tests/as-native-sdk-module-userdata-gc-green-parent/20260727_221533_694_52383ad1` | Module 52/52 PASS, zero failed/skipped, process/final exit 0/0, normal shutdown and no crash marker. | Affected parent acceptance after P166. |

Fresh cross-execution and aggregate evidence now extends that green stage:

| Evidence | Result | Authority |
| --- | --- | --- |
| `Saved/Tests/as-native-sdk-comprehensive-current-final-green1_04_tests/20260727_222852_888_6d5de814` | Canonical regenerated AOT parent 12/12 PASS, process/final exit 0 and normal shutdown. | Fresh paired-artifact AOT acceptance. |
| `Saved/Tests/as-native-sdk-comprehensive-current-staticjit-full/20260727_222954_004_8d8fb9d3` | Complete StaticJIT 30/30 PASS; `ReferenceCopyTypeOperandsRemapAcrossPrecompiledLoad` passes against the freshly generated and compiled artifacts. | Exact reference-copy precompiled remap plus affected parent acceptance. |
| `Saved/Tests/as-native-sdk-comprehensive-current-sdk-final/20260727_223150_574_a4d2f49c` | Complete SDK 683/683 PASS, zero failed/skipped, process/final exit 0, normal shutdown and no crash marker. | Fresh SDK aggregate acceptance. |
| `Saved/Tests/as-native-sdk-comprehensive-current-nativecore_01_AngelScriptSDK/20260727_223456_989_c28e21cc` | Configured NativeCore 683/683 PASS, zero failed/skipped, process/final exit 0, `TimedOut=false`. | Fresh configured native-core acceptance. |

## Final linked verification — 2026-07-28

| Gate | Evidence | Result |
| --- | --- | --- |
| Static ownership reconciliation | Main change final source/product/method audits and 166-hunk ownership record | **PASS**: 319 products, 46,156 stable IDs, 697 fully dispositioned test methods, and every reference/persistence production hunk assigned to this linked owner. |
| Coherent restored build | `Saved/Build/as-native-sdk-unit-tests-restored-final/20260728_000229_699_38a673dd` | **PASS**: process/final exit 0/0; 56 actions; 96,112 ms. Existing C5038/C4191 fixture warnings remain visible; no new error. |
| Exact precompiled remap | `Saved/Tests/fix-as-reference-bytecode-precompiled-remap-final/20260727_233527_191_44575745` | **1/1 PASS**, normal shutdown and no crash. |
| Reference parent | `Saved/Tests/as-native-sdk-reference-theme-final/20260727_233928_597_62091015` | **10/10 PASS**, zero failed/skipped. |
| Affected parents | `Saved/Tests/as-native-sdk-compiler-theme-final/20260727_234016_890_ad173a0e`; `Saved/Tests/as-native-sdk-runtime-theme-final/20260727_234116_301_e3c93908`; `Saved/Tests/as-native-sdk-module-theme-final/20260727_234154_745_6cecb96f` | Compiler **122/122**, Runtime **45/45**, and Module **52/52**, all with normal shutdown and no crash. |
| Restored final SDK | `Saved/Tests/as-native-sdk-comprehensive-restored-final/20260728_000418_207_c7795abc` | **683/683 PASS**, zero failed/skipped, process/final exit 0/0, `TimedOut=false`, `GIsCriticalError=0`, no crash. |
| Final project suite | `Saved/Tests/as-native-sdk-comprehensive-restored-all-final_01_Editor` through `_35_WorldSubsystem` | **35/35 prefixes and 2,396/2,396 tests PASS**, zero failed/skipped/nonzero exits/timeouts. |
| Record gates | Strict validation of this change and the main change; parent/plugin `git diff --check` | **PASS**, zero validation or whitespace errors. |

Tasks 4.1–4.4 are closed by current-source evidence rather than retained runs.
