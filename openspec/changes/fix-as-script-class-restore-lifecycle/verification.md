# Verification evidence

## Public raw ScriptObject ownership — 2026-07-27

The comprehensive native SDK coverage run exposed a missing production bridge,
not a test-oracle mismatch. Standalone raw script classes are
`asOBJ_SCRIPT_OBJECT | asOBJ_REF | asOBJ_NOCOUNT`; their canonical
`asCScriptObject` addref/release behaviours are commented out in this fork.
The raw-object registry was already consumed by interpreter and StaticJIT
ownership paths, but public `AddRefScriptObject()` and
`ReleaseScriptObject()` still dispatched only behaviours and therefore did
nothing for these objects.

| Gate | Artifact | Result |
| --- | --- | --- |
| Red Runtime parent | `Saved/Tests/as-native-sdk-runtime-assertion-depth/20260727_132238_926_13c98332/Report/index.json` | **42/44 PASS**. Only the two public ScriptObject final-release owners fail; both observe destructor count zero. The process exits normally without crash or timeout. |
| Runtime source repair | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp` | Public AddRef/Release enter the raw path only for a registered pointer and exact/base/interface-compatible TypeInfo. Ownership and final destruction use the registered dynamic type. Unrelated TypeInfo, UE-backed, and ordinary behaviour-backed paths remain rejected or unchanged. |
| Repair build | `Saved/Build/as-native-sdk-runtime-scriptobject-public-release-fix/20260727_133011_892_d9f7f840/UBT.log` | Four compile/link/metadata actions complete; UBT reports `Result: Succeeded` in 8.08 seconds. The outer wrapper ended before it could finalize exit metadata, so a later coherent terminal build remains required. |
| Focused regression | `Saved/Tests/as-native-sdk-runtime-scriptobject-public-release-fix/20260727_133041_790_0ce9194c/Report/index.json`; sibling metadata/log | **3/3 PASS**, process/final exit zero, normal shutdown. Full generated source is printed. |
| Runtime parent | `Saved/Tests/as-native-sdk-runtime-assertion-depth-final/20260727_133118_732_878ed5f4/Report/index.json`; sibling metadata/log | **44/44 PASS**, process/final exit zero, `TimedOut=false`, normal shutdown, no fatal/assert/unhandled/access-violation marker. A later coherent run will include the subsequently strengthened per-origin destruction increments and post-discard no-repeat assertions. |

Final Module, Constructors, Destructors, Conformance, complete SDK, and
post-teardown gates remain open under tasks 4.1–4.3.

## Polymorphic raw ScriptObject ownership — 2026-07-27

The first strengthened Runtime parent revealed a second part of the same
ownership defect. A derived standalone raw script object assigned to a
base-typed local was retained by the VM using the statically known base
TypeInfo. Exact dynamic/static equality rejected that legal retain; releasing
the temporary freed the object, and virtual dispatch dereferenced the dangling
base slot.

| Gate | Artifact | Result |
| --- | --- | --- |
| Retained red crash | `Saved/Tests/as-native-sdk-runtime-assertion-depth-green/20260727_142038_339_6cc839d3/Automation.log`; crash snapshot under `Saved/Angelscript/CrashSnapshots/99592_20260727_142106_311/` | After 27 successful Runtime tests, `DBG-THIS-CALL-FRAME` crashes with `EXCEPTION_ACCESS_VIOLATION`. The stack is `UASClass::GetFirstASClass` → `asIScriptObject::GetObjectType` → `asCContext::CallInterfaceMethod`. |
| Compatibility repair | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp` | Resolve the registered dynamic type; accept exact, `DerivesFrom`, or `Implements` compatibility; reject unrelated TypeInfo; and use the dynamic type for the ownership transition and final destructor. |
| Terminal repair build | `Saved/Build/as-native-sdk-raw-object-polymorphic-ownership-fix/20260727_142459_213_cee1a389/RunMetadata.json` | **PASS**, 4/4 actions, process/final exit 0, `TimedOut=false`, 8,336 ms. |
| Formerly crashing owner | `Saved/Tests/as-native-sdk-this-pointer-polymorphic-ownership-fix/20260727_142516_653_561267f6/Report/index.json` | **1/1 PASS**. The complete derived-to-base virtual-call source is printed; shutdown is normal with no crash. |
| Public ownership controls | `Saved/Tests/as-native-sdk-scriptobject-polymorphic-ownership-regression/20260727_142553_099_f942dbde/Report/index.json` | **4/4 PASS**. Unrelated-TypeInfo rejection, balanced retain/release, destructor-time resurrection, dynamic identity, and user-data fork behavior remain green. |
| Runtime parent | `Saved/Tests/as-native-sdk-runtime-assertion-depth-final-green/20260727_142630_908_5de63093/Report/index.json`; sibling metadata/log | **44/44 PASS**, zero failed/skipped, process/final exit 0, `TimedOut=false`, status-zero normal shutdown, and no crash/fatal/assert/unhandled/access-violation marker. |

The raw ownership repair now has focused and parent interpreter evidence.
## Final linked verification — 2026-07-28

| Gate | Evidence | Result |
| --- | --- | --- |
| Layout/lifecycle reconciliation | Main change final product, method, predecessor, internal-method, boundary, and production-hunk audits | **PASS**: zero unresolved ownership; all 56 lifecycle hunks remain assigned to this change. |
| Coherent restored build | `Saved/Build/as-native-sdk-unit-tests-restored-final/20260728_000229_699_38a673dd` | **PASS**, process/final exit 0/0, 56 actions, no new error. |
| Module lifecycle | `Saved/Tests/as-native-sdk-script-lifecycle-module-final/20260727_233615_945_16290e4c` | **1/1 PASS**. |
| Constructors and destructors | `Saved/Tests/as-native-sdk-script-lifecycle-constructors-final/20260727_233652_749_e62278ef`; `Saved/Tests/as-native-sdk-script-lifecycle-destructors-final/20260727_233729_741_8a8016a1` | **1/1 + 1/1 PASS**, with expected lifecycle ordering and normal teardown. |
| Runtime lifecycle | `Saved/Tests/as-native-sdk-script-lifecycle-runtime-final/20260727_233807_230_c1041c90` | **4/4 PASS**. |
| Conformance lifecycle | `Saved/Tests/as-native-sdk-script-lifecycle-conformance-final/20260727_233846_127_aa540860` | **4/4 PASS**. |
| Affected parents | `Saved/Tests/as-native-sdk-module-theme-final/20260727_234154_745_6cecb96f`; `Saved/Tests/as-native-sdk-runtime-theme-final/20260727_234116_301_e3c93908` | Module **52/52** and Runtime **45/45 PASS**. |
| Restored final SDK | `Saved/Tests/as-native-sdk-comprehensive-restored-final/20260728_000418_207_c7795abc` | **683/683 PASS**, zero failed/skipped, normal status-zero shutdown, no crash or timeout. |
| Final project suite | Final restored All suite, 35 report directories under `Saved/Tests/as-native-sdk-comprehensive-restored-all-final_*` | **2,396/2,396 PASS**, zero failed/skipped/nonzero exits/timeouts. |
| Record gates | Strict OpenSpec and parent/plugin `git diff --check` | **PASS**. |

Tasks 4.1–4.3 are complete. The outstanding-object engine-shutdown limitation
remains deliberately documented and is not misreported as repaired behavior.
