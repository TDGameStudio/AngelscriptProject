# Runtime Change Ownership

## Purpose

This record separates test-coverage work from production changes already
discovered while implementing the suite. The coverage OpenSpec may add the
regressions that expose a defect, but it must not be the only owner of a
ThirdParty/runtime semantic repair.

Ownership is hunk-based. A file may participate in more than one linked change;
the exact behavior and regression, not the filename alone, determine ownership.

## Root-cause owners

| Linked OpenSpec | Production behavior owned | Primary reviewed files/hunks | Representative regression owners |
| --- | --- | --- | --- |
| `fix-as-reference-bytecode-ownership-persistence` | Reference/object-type bytecode operands retain correct type/function ownership through compilation, execution, reference release, successful-GC discarded-module retirement, save, and restore. | `as_bytecode.cpp`, relevant `as_compiler.cpp`/`as_context.cpp` reference opcodes, `as_module.cpp::UpdateReferencesInScriptBytecode`, `as_scriptfunction.cpp::{AddReferences,ReleaseReferences}`, the pinned-2.38-compatible successful-GC retirement branch in `as_scriptengine.cpp::GarbageCollect`, bytecode pointer/index translation portions of `as_restore.cpp`, and the layout-neutral read-only internal diagnostic `asCTypeInfo::GetInternalReferenceCountForTesting()` in `as_typeinfo.h`. The internal class header is compiled by Runtime translation units that do not define `WITH_ANGELSCRIPT_UNITTESTS`, so conditionally changing the class definition is not a valid cross-module seam. | Reference resolution/lifetime, bytecode mutation/optimization, module discard/GC retirement, module save/load. |
| `fix-as-script-class-restore-lifecycle` | Restored script classes rebuild inherited/value-property layouts, retain default special-member behavior, and clean constructed members/base state correctly across failure and teardown. | `as_builder.cpp::CreateDefaultDestructors`, constructor/destructor/member-init hunks in `as_compiler.cpp`, script-class layout/type/property restore hunks in `as_restore.cpp/.h`, `as_scriptobject.cpp` exceptional destructor cleanup, related context cleanup hunks. | Script-class save/load lifecycle, constructor/destructor partial failure, default special members. |
| `fix-as-object-last-native-calling-convention` | Native object-last/system calls use the fork's caller payload and stack/object argument order consistently at registration, compile, bytecode, execution, and save/load boundaries. | `as_callfunc.cpp/.h`, object-last/system-call emission in `as_compiler.cpp`, dispatch/argument cleanup in `as_context.cpp`, native-call pointer translation in `as_restore.cpp`. | Embedding calling-convention and object registration tests. |
| `fix-as-engine-property-default-initialization` | Every engine property has a deterministic constructor default, including `typeCheckSwitchEnums`, and independent engines do not inherit uninitialized state. | `as_scriptengine.cpp` engine-property constructor initialization. | Engine property profile and isolation tests. |
| `fix-as-static-jit-debug-text-whitespace` | StaticJIT instruction debug text and generated AOT comments do not retain a synthetic trailing separator. | P019, `StaticJIT/AngelscriptBytecodes.cpp::GetInstrDebugString`. | `FAngelscriptStaticJITAotTests::GeneratedOutputVerify`, `JIT-004`, and literal generated-output whitespace scan. |
| `fix-as-switch-int-max-lowering` | Switch range grouping and dense-table iteration do not overflow at the upper signed 32-bit boundary. | P066-P069, `as_compiler.cpp::CompileSwitchStatement`. | `FSwitchTests::SelectorsByCaseAndExit`, `LANG-CF-SWITCH`, `LANG-CF-005`, and `LANG-CF-006`. |
| `fix-as-double-int64-bytecode-execution` | The interpreter decodes `dTOi64`/`dTOu64` from the current-fork two-word destination/source layout and advances past both words. | P091-P092, `as_context.cpp::ExecuteNext`. | Interpreter: `FConstructorParameterTests::ParameterTypesByArityAndSelection` (`1/1`) and `FNumericConversionTests::SourceTargetFormAndValue` within Numeric (`4/4`). Generated parity: `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter`, proven by the canonical AOT workflow (`11/11`). |
| `refactor-as-native-sdk-regression-suite` | The seven real string utility functions, including numeric scan helpers, have DLL visibility without signature or implementation changes so raw SDK tests exercise the production implementation. | String utility declarations plus the two `AngelscriptEngine.cpp` Runtime export definitions. | `FRONTEND-STRING-SCAN-BOUNDARIES` and the predecessor's direct StringUtility tests. |

## Supporting integration outside vendored source

Changes in `AngelscriptRuntime/ClassGenerator/ASClass*`,
`Core/AngelscriptEngine.cpp`, `Core/angelscript.*`, and related script-object
allocation hooks must be assigned by the behavior they implement. Raw script
object allocation/refcount cleanup belongs with script-class lifecycle unless a
separate independently reviewable root cause is found. StaticJIT changes remain
outside an existing owner unless a linked repair explicitly depends on them.

## Reconciliation rule

Before final verification:

1. enumerate every changed production hunk in the plugin;
2. assign it to exactly one primary linked change and any required integration
   dependencies;
3. give the linked change a focused failing/passing regression and rollback
   boundary;
4. leave only test code, test support, and coverage records under this
   comprehensive-coverage change.

If a semantic hunk cannot be explained by an exact root cause, create another
linked OpenSpec rather than silently expanding this coverage change.

P073/P074 are the only current exceptions to behavioral ownership: the user
explicitly authorized these two comment-only terminology cleanups. They are
terminal non-semantic rows, not evidence for a runtime repair.

## Linked-change closure status — 2026-07-27

| Linked OpenSpec | Current closure evidence | Remaining work |
| --- | --- | --- |
| `fix-as-engine-property-default-initialization` | **Complete**: all 46 `ep` fields have explicit constructor assignments; the bare default for `typeCheckSwitchEnums` is `false`, while plugin configuration deliberately applies `true`; the focused profile, independent-engine isolation, repair build, and current 666/666 SDK prefix pass. | None in that linked change. Preserve the assignment and profile/isolation regression. |
| `fix-as-reference-bytecode-ownership-persistence` | Coverage and production hunks exist, including interpreter/StaticJIT reference-copy ownership, P022's narrow `Process` export, P138/P142/P149/P150/P151's exact GETOBJ `asBCTYPE_W_rW_ARG` reader/writer contract, P165's layout-neutral TypeInfo internal-reference diagnostic seam, and P166's pinned-2.38-compatible successful-GC discarded-module retirement. The named precompiled remap owner has historical red/green evidence. P166 is green through Variables 3/3, Engine 40/40, focused Module user-data 1/1, and Module 52/52 after its exact oracle transition. | Complete stream compatibility and remaining malformed-stream/lifetime gates, the unit-tests-disabled build confirming P165 introduces no test-module dependency, StaticJIT/AOT execution, complete SDK/final suites, and the fresh linked verification checklist. |
| `fix-as-script-class-restore-lifecycle` | Coverage and production hunks exist for restored layout/special members and exceptional object cleanup. Public raw ownership, unrelated-TypeInfo rejection, destructor resurrection, and derived-to-base VM ownership now have linked red/green evidence: ThisPointer 1/1, ScriptObject 4/4, Runtime 44/44. | Complete the remaining per-hunk lifecycle ownership, fresh/restored equivalence, failure ordering, outstanding-object shutdown policy, StaticJIT execution parity, and full linked verification checklist. |
| `fix-as-object-last-native-calling-convention` | Coverage and production hunks exist across callfunc/compiler/context/restore. | Complete ABI-shape/rejection inventory, save/load identity, cleanup/isolation evidence, and linked verification checklist. |
| `fix-as-static-jit-debug-text-whitespace` | P019 and `GeneratedOutputVerify` exist; `JIT-004` retains AOT 10/10 and zero literal trailing-whitespace lines. | Run and record fresh linked build/AOT generation/automation and artifact scan. |
| `fix-as-switch-int-max-lowering` | P066-P069 and `FSwitchTests::SelectorsByCaseAndExit` exist; retained evidence includes the exact red and ControlFlow 4/4 repair reports. | Run and record fresh linked build, Switch/ControlFlow, and complete SDK evidence. |
| `fix-as-double-int64-bytecode-execution` | **Complete**: P091-P092 and the constructor/numeric interpreter regressions pass Parameters `1/1` and Numeric `4/4`. Exact generated owner `FAngelscriptStaticJITAotTests::DoubleInt64ConversionsMatchInterpreter` passes inside canonical regenerated/built AOT `11/11`, with generated artifact, three-entry attachment, entry counters, parity, and cleanup retained by the linked verification record. Complete SDK passes `674/674`; strict/planning/whitespace gates pass; the standalone coherent `-NoXGE` build succeeds up to date with process/runner exit `0/0` and `TimedOut=false`. `BitCastAndNumericParity` remains explicitly non-owning because it tests the opposite direction. | None in that linked change. Preserve the scope boundary: these results do not claim NativeCore, whole-project full-suite, Disabled-test, obj-last, or counted-reference behavior. |
| `refactor-as-native-sdk-regression-suite` | **Complete**: tasks 2.4 and 5.3 explicitly own the real string utility exports and direct scan behavior; its 105/105 tasks are checked and its verification records strict validation plus the final SDK runs. | Preserve the two Runtime definition exports and direct Frontend regressions. |

The reconciled final audit in
`handoffs/production-hunk-ownership-final.csv` covers the current 23 production
files and all 166 zero-context hunks without duplicates or omissions. It
assigns 64 hunks to reference-bytecode ownership, 56 to script-class
lifecycle, 34 to object-last calling, one to engine-property defaults, two
string-scan exports to the completed native-SDK regression-suite owner, one to
StaticJIT debug text, four to upper-bound switch lowering, two to
double-to-64-bit interpreter execution, and two to explicit user-authorized
non-semantic cleanup. There are zero `Unowned` rows and no semantic hunk is
owned only by this coverage change. Task 2.6 is complete; task 2.7 remains open
for fresh final linked build/runtime evidence.
